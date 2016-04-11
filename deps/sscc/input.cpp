#include <cstdlib>
#include <cstdio>
#include "log.h"
#include "input.h"
#include "unistr.h"

/* InputFile */
InputFile::InputFile() 
: _data(), 
  _size(),
  _newline(true)
{
    _position.line = 1;
    _position.col = 1;
}

InputFile::~InputFile() {
    if (_data) {
        std::free(_data);
    }
}

bool InputFile::load(ptr<Path> path) {
    FILE *file = fopen(path->c_str(), "r");
    if (!file) {
		return false;
    }
    fseek(file, 0, SEEK_END);
    off_t size = ftell(file);
    fseek(file, 0, SEEK_SET);
    _data = (char*)std::malloc(size);
    _size = size;
    if ((unsigned)fread(_data, 1, size, file) != size) {
		return false;
    }
    fclose(file);
	_path = path;
    _position.file = path->c_str();
	return true;
}

/* Input */
Input::Input() {
}

Input::~Input() {
}

ptr<Path> Input::load(ptr<Path> path, bool search) {
	ptr<Path> curPath;

	if (!_stack.empty()) {
		curPath = _stack.front()._path;
	}
	_stack.emplace_front(); 
	InputFile &file = _stack.front();

	if (file.load(path)) {
		goto loaded;
	}

	if (search) {
		if (curPath && file.load(object<Path>(curPath->directory() + *path))) {
			goto loaded;
		}

		for (auto searchPath : _searchPaths) {
			if (file.load(object<Path>(*searchPath + *path))) {
				goto loaded;
			}
		}
	}
	log_fail("load file '%s' failed.", path->c_str());
loaded:
	bool first = true;
    for (auto &f : _stack) {
		if (first) {
			first = false;
			continue;
		}
        if (*file._path == *f._path) {
            log_fail("nesting include file '%s'.", path->c_str());
        }
    }

	return file._path;
}

void Input::addPath(ptr<Path> path) {
	_searchPaths.push_back(path);
}

