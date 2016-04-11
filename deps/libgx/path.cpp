#include <climits>
#include <cstdlib>

#include "path.h"
#include "log.h"
#include "data.h"
#include "utils.h"
GX_NS_BEGIN

/* PathIterator::Directory */
PathIterator::Directory::Directory(const Path &path) noexcept : _path(path) {
#ifdef GX_PLATFORM_WIN32
    Path tmp = (path + "*").c_str();
    
    _dir =  FindFirstFile((wchar_t*)char2wchar(tmp.c_str())->data(), &_data);
#else
    _dir = opendir(path.c_str());
#endif
}

PathIterator::Directory::~Directory() noexcept {
#ifdef GX_PLATFORM_WIN32
    if (_dir != INVALID_HANDLE_VALUE) {
        FindClose(_dir); 
    }
#else
    if (_dir) {
        closedir(_dir); 
    }
#endif
}

/* PathIterator */
PathIterator::PathIterator(const Path *path) noexcept {
    if (path) {
        _stack.emplace(*path);
        ++(*this);
    }
}

PathIterator& PathIterator::operator++() noexcept {
#ifdef GX_PLATFORM_WIN32
    while (!_stack.empty()) {
        Directory &dir = _stack.top();
        if (dir._dir != INVALID_HANDLE_VALUE) {
            if (dir._data.dwFileAttributes == FILE_ATTRIBUTE_DIRECTORY) {
                if (wcscmp(dir._data.cFileName, L".") == 0 || wcscmp(dir._data.cFileName, L"..") == 0) {
                    if (!FindNextFile(dir._dir, (WIN32_FIND_DATA*)&dir._data)) {
                        dir._dir = INVALID_HANDLE_VALUE;
                    }
                }
                else {
                    _stack.emplace(dir._path + wchar2char(dir._data.cFileName)->data());
                    if (!FindNextFile(dir._dir, (WIN32_FIND_DATA*)&dir._data)) {
                        dir._dir = INVALID_HANDLE_VALUE;
                    }
                }
            }
            else {
                _path = dir._path + wchar2char(dir._data.cFileName)->data();
                if (!FindNextFile(dir._dir, (WIN32_FIND_DATA*)&dir._data)) {
                    dir._dir = INVALID_HANDLE_VALUE;
                }
                return *this;
            }
        }
        else {
            _stack.pop();
        }
    }
    _path.clear();
    return *this;
#else
    struct dirent *ent;
again:
    while (!_stack.empty()) {
        const Directory &dir = _stack.top();
        if (dir._dir && (ent = readdir(dir._dir))) {
            if (ent->d_type & DT_DIR) {
                if (strcmp(ent->d_name, ".") == 0 || strcmp(ent->d_name, "..") == 0) {
                    continue;
                }
                _stack.emplace(dir._path + ent->d_name);
                goto again;
            }
            else {
                _path = dir._path + ent->d_name;
                return *this;
            }
        }
        else {
            _stack.pop();
        }
    }
    _path.clear();
    return *this;
#endif
}

/* Path */
Path::Path() noexcept {
    _path = ".";
}

Path::Path(const char *x) noexcept : _path(x ? x : "") {
    normalize();
}

Path::Path(const std::string &x) noexcept : _path(x) {
    normalize();
}

Path::Path(const Path &x) noexcept : _path(x._path) {
    normalize();
}

void Path::clear() noexcept {
    _path = ".";
}

Path &Path::operator=(const char *x) noexcept {
    *this = Path(x);
    return *this;
}

Path &Path::operator=(const std::string &x) noexcept {
    *this = Path(x);
    return *this;
}

Path &Path::operator=(const Path &x) noexcept {
    _path = x._path;
    return *this;
}

Path &Path::operator=(Path &&x) noexcept {
    _path = std::move(x._path);
    return *this;
}

Path Path::operator+(const char *x) const noexcept {
    return (*this) + Path(x);
}

Path Path::operator+(const std::string &x) const noexcept {
    return (*this) + Path(x);
}

Path Path::operator+(const Path &x) const noexcept {
    if (_path == ".") {
        if (x.is_absolute()) {
            return _path + x._path;
        }
        return x; 
    }
    else if (_path == "/") {
        Path path;
        path._path = _path + x._path;
        return path;
    }
    else {
        Path path;
        path._path = _path + "/" + x._path;
        return path;
    }
}

void Path::normalize() noexcept {
    std::string str = _path;
    char *p = (char*)_path.c_str();
    char *tail = p + strlen(p) - 1;

    while (p <= tail) {
        if (*p != ' ' && *p != '\t') {
            break;
        }
        p++;
    }

    while (p <= tail) {
        if (*tail != ' ' && *tail != '\t') {
            break;
        }
        tail--;
    }

    if (p == tail && *p == '/') {
        _path = "/";
        return;
    }

    while (p <= tail) {
        if ('/' != *tail) {
            break;
        }
        tail--;
    }

    if (tail < p) {
        _path = ".";
    } else {
        _path = std::string(p, tail - p + 1);
    }
}

std::string Path::filename() const noexcept {
    size_t pos = _path.rfind('/');
    std::string result;
    if (pos != std::string::npos) {
        result = _path.substr(pos + 1);
    }
    else if (!_path.empty()) {
        return _path;
    }
    if (result == ".." || result == ".") {
        result.clear();
    }
    return result;
}

std::string Path::basename() const noexcept {
    std::string result = filename();
    if (result.empty()) {
        return result;
    }
    size_t pos = result.rfind('.');
    if (pos == std::string::npos) {
        return result;
    }
    return result.substr(0, pos);
}

std::string Path::extension() const noexcept {
    std::string result = filename();
    if (result.empty()) {
        return result;
    }
    size_t pos = result.rfind('.');
    if (pos == std::string::npos) {
        return "";
    }
    return result.substr(pos + 1);
}

void Path::extension(const char *ext) noexcept {
    *this = directory() + (basename() + "." + ext);
}

Path Path::directory() const noexcept {
    size_t pos = _path.rfind('/');
    Path dir;
    if (pos != std::string::npos) {
        if (pos) {
            dir._path = _path.substr(0, pos); 
        }
        else {
            dir._path = "/";
        }
    }
    return dir;
}


bool Path::is_absolute() const noexcept {
    return *_path.c_str() == '/';
}

Path::iterator Path::begin() const noexcept {
    return iterator(this);
}

Path::iterator Path::end() const noexcept {
    return iterator(nullptr);
}

#ifdef GX_PLATFORM_WIN32
Path Path::realpath() const noexcept {
    char buf[_MAX_PATH];
    return Path(::_fullpath(buf, _path.c_str(), _MAX_PATH));
}
#else
Path Path::realpath() const noexcept {
    char buf[PATH_MAX];
    return Path(::realpath(_path.c_str(), buf));
}
#endif

Path Path::pwd() noexcept {
    return Path(".").realpath();
}

GX_NS_END

