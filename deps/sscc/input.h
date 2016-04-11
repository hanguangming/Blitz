#ifndef __INPUT_H__
#define __INPUT_H__

#include <string>
#include <list>
#include <cstdio>
#include "libgx/gx.h"
using namespace gx;

struct Position
{
    Position() : file(), line(), col() {}
    const char *file;
    unsigned line;
    unsigned col;
};

struct Location
{
    Position begin;
    Position end;

    Location &operator<<(const Position &pos) {
        if (!begin.line) {
            begin = pos;
        }
        else {
            end = pos;
        }
        return *this;
    }
    Location &operator<<(const Location &loc) {
        if (!begin.line) {
            begin = loc.begin;
        }
        end = loc.end;
        return *this;
    }
};

class InputFile
{
    friend class Input;
public:
    InputFile();
    ~InputFile();
    bool load(ptr<Path> path);
    int cur() {
		while (_pos < _size) {
			if (_data[_pos] != '\r') {
				return _data[_pos];
			}
			++_pos;
		}
		return 0;
    }
    void eat() {
        if (_pos < _size) {
            _newline = (_data[_pos] == '\n');
            if (_newline) {
                ++_position.line;
                _position.col = 1;
            }
            else {
                ++_position.col;
            }
            ++_pos; 
            while (_pos < _size) {
                if (_data[_pos] != '\r') {
                    break;
                }
                ++_pos;
            }
        }
    }
    int look() {
        unsigned n = _pos + 1;
		while (n < _size) {
			if (_data[n] != '\r') {
				return _data[n];
			}
			++n;
		}
		return 0;
    }
private:
    char *_data;
    unsigned _pos;
    unsigned _size;
    Position _position;
    bool _newline;
	ptr<Path> _path;
};

class Input
{
public:
    Input();
    virtual ~Input();
    ptr<Path> load(ptr<Path> path, bool search = true);

    int cur() {
        int c;
        while (!_stack.empty()) {
            InputFile &file = _stack.front();
            if ((c = file.cur())) {
                return c;
            }
            if (_stack.size() == 1) {
                break;
            }
            _stack.pop_front(); 
        }
        return 0;
    }

    void eat() {
        if (!_stack.empty()) {
            InputFile &file = _stack.front();
            file.eat();
            mark_end();
        }
    }

    int look() {
        int c;
        for (auto &file : _stack) {
            if ((c = file.look())) {
                return c;
            }
        }
        return 0;
    }

    bool is_newline() const {
        return _stack.front()._newline;
    }

    const Position &pos() const {
        return _stack.front()._position;
    }

    void mark_begin() {
        _loc.begin = pos();
    }

    void mark_end() {
        _loc.end = pos();
    }

    const Location &loc() const {
        return _loc;
    }

	bool is_root() const {
		return _stack.size() <= 1;
	}

	void addPath(ptr<Path> path);
private:
    Location _loc;
    std::list<InputFile> _stack;
	std::list<ptr<Path>> _searchPaths;
};


#endif

