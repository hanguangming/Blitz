#ifndef __GX_PATH_H__
#define __GX_PATH_H__

#include <string>
#include <stack>

#include "platform.h"
#include "object.h"
#include "memory.h"

#ifdef WIN32
#else
#include <sys/types.h>
#include <dirent.h>
#endif

GX_NS_BEGIN

class PathIterator;

class Path : public Object {
public:
    typedef PathIterator iterator;
public:
    Path() noexcept;
    Path(const char *x) noexcept;
    Path(const std::string &x) noexcept;
    Path(const Path &x) noexcept;

    operator const char*() const noexcept {
        return _path.c_str();
    }

    operator const std::string&() const noexcept {
        return _path;
    }

    const char *c_str() const noexcept {
        return _path.c_str();
    }

    size_t size() const noexcept {
        return _path.size();
    }

    Path &operator=(const char *x) noexcept;
    Path &operator=(const std::string &x) noexcept;
    Path &operator=(const Path &x) noexcept;
    Path &operator=(Path &&x) noexcept;

    Path operator+(const char *x) const noexcept;
    Path operator+(const std::string &x) const noexcept;
    Path operator+(const Path &x) const noexcept;

    void normalize() noexcept;
    std::string filename() const noexcept;
    std::string basename() const noexcept;
    std::string extension() const noexcept;
    void extension(const char *ext) noexcept;
    Path directory() const noexcept;
    bool is_absolute() const noexcept;
    bool operator==(const Path &x) const noexcept {
        return _path == x._path;
    }
    bool operator!=(const Path &x) const noexcept {
        return _path != x._path;
    }
    bool empty() const noexcept {
        return _path.empty();
    }
    void clear() noexcept;

    iterator begin() const noexcept;
    iterator end() const noexcept;

    Path realpath() const noexcept;
    static Path pwd() noexcept;
private:
    std::string _path;
};

class PathIterator {
private:
    struct Directory {
        Directory(const Path &path) noexcept;
        ~Directory() noexcept;

#ifdef GX_PLATFORM_WIN32
        HANDLE _dir;
        WIN32_FIND_DATA _data;
#else
        DIR *_dir;
#endif
        Path _path;
    };
public:
    PathIterator(const Path *path) noexcept;
    PathIterator(const PathIterator &x) noexcept
    : _stack(x._stack)
    { }
    const Path &operator*() noexcept {
        return _path;
    }
    PathIterator& operator++() noexcept;
    PathIterator operator++(int) noexcept {
        PathIterator tmp(*this);
        ++*this;
        return tmp;
    }
    bool operator==(const PathIterator &x) noexcept {
        return _path == x._path;
    }
    bool operator!=(const PathIterator &x) noexcept {
        return _path != x._path;
    }
private:
    std::stack<Directory> _stack;
    Path _path;
};

GX_NS_END


#endif
