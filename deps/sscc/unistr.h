#ifndef __UNISTR_H__
#define __UNISTR_H__

#include <unordered_set>
#include "libgx/gx.h"

using namespace gx;

class Unistr {
public:
    operator const char*() const {
        return _str;
    }
    int type() const {
        return _type;
    }
    int size() const {
        return _size;
    }

    bool operator==(const Unistr &x) const {
        return _hash == x._hash && _size == x._size && strncmp(_str, x._str, _size) == 0;
    }
    static const Unistr &get(const char *str, size_t size = 0, int type = 0, bool trim = false);

private:
    struct hash {
        size_t operator()(const Unistr &str) const { 
            return str._hash;
        }
    };

private:
    Unistr() { }

    char *_str;
    size_t _size;
    int _type;
    size_t _hash;
    static std::unordered_set<Unistr, hash> _set;
    static object<Obstack> _pool;
};



#endif


