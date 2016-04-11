#ifndef __GX_OBSTACK_H__
#define __GX_OBSTACK_H__

#include <cstdarg>
#include <string>
#include <cstring>

#include "platform.h"
#include "object.h"
#include "page.h"
#include "singleton.h"

GX_NS_BEGIN

class Obstack : public Object, public singleton<Obstack> {
public:
    Obstack(size_t initsize = 1, PageAllocator *pa = nullptr) noexcept;
    ~Obstack() noexcept;

    int vprint(const char *fmt, va_list ap) noexcept;

    int print(const char *fmt, ...) noexcept GX_PRINTF_ATTR(2, 3) {
        va_list ap;
        va_start(ap, fmt);
        return vprint(fmt, ap);
    }

    char *vprintf(const char *fmt, va_list ap) noexcept {
        vprint(fmt, ap);
        grow1('\0');
        return (char*)finish();
    }

    char *printf(const char *fmt, ...) noexcept GX_PRINTF_ATTR(2, 3) {
        va_list ap;
        va_start(ap, fmt);
        return vprintf(fmt, ap);
    }

    void clear() noexcept;

    void *base() const noexcept {
         return (void*)_object_base;
    }

    void *next_free() const noexcept {
        return _next_free;
    }

    size_t object_size() const  noexcept {
        return _next_free - _object_base;
    }

    size_t rome_size() const noexcept {
        return _chunk_limit - _next_free;
    }

    void make_rome(size_t size) noexcept {
        if (gx_unlikely((size_t)(_chunk_limit - _next_free) < size)) {
            newchunk(size);
        }
    }

    void grow_fast(const void *p, size_t size) noexcept {
        memcpy(_next_free, p, size);
        _next_free += size;
    }

    void grow(const void *p, size_t size) noexcept {
        if (gx_unlikely(_next_free + size > _chunk_limit)) {
            newchunk(size);
        }
        memcpy(_next_free, p, size);
        _next_free += size;
    }

    void grow1(int c) noexcept {
        if (gx_unlikely(_next_free + 1 > _chunk_limit)) {
            newchunk(1);
        }
        *_next_free++ = c;
    }

    void grow0(const void *p, size_t size) noexcept {
        if (gx_unlikely(_next_free + size + 1 > _chunk_limit)) {
            newchunk(size + 1);
        }
        memcpy(_next_free, p, size);
        _next_free += size;
        *_next_free++ = 0;
    }

    template <typename _T>
    void grow(_T obj) noexcept {
        static_assert(std::is_arithmetic<_T>::value || std::is_pointer<_T>::value, 
                      "grow must is arithmetic or pointer.");
        grow(&obj, sizeof(_T));
    }

    template <typename _T>
    Obstack& operator<<(_T obj) noexcept {
        grow(obj);
        return *this;
    }

    void blank_fast(size_t size) noexcept {
        _next_free += size;
    }

    void blank(size_t size) noexcept {
        if (gx_unlikely((size_t)(_chunk_limit - _next_free) < size)) {
            newchunk(size);
        }
        _next_free += size;
    }

    void *alloc(size_t size) noexcept {
        if (gx_unlikely((size_t)(_chunk_limit - _next_free) < size)) {
            newchunk(size);
        }
        _next_free += size;
        return finish();
    }

    void *calloc(size_t size) noexcept {
        void *p = alloc(size);
        memset(p, 0, size);
        return p;
    }

    void *copy(const void *p, size_t size) noexcept {
        grow(p, size);
        return finish();
    }

    void *copy0(const void *p, size_t size) noexcept {
        grow0(p, size);
        return finish();
    }

    void *finish() noexcept {
        char *p = _object_base;
        if (gx_unlikely(_next_free == p)) {
            _maybe_empty_object = true;
        }

        _next_free = (char*)gx_align_default((intptr_t)_next_free);
        if (gx_unlikely(_next_free > _chunk_limit)) {
            _next_free = _chunk_limit;
        }
        _object_base = _next_free;
        return (void*)p;
    }

    void free(void *obj) noexcept {
        char *p = (char*)obj;
        if (p > _chunk->firstp && p < _chunk_limit) {
            _next_free = _object_base = p;
        }
        else {
            free(_chunk, p);
        }
    }

    char *strdup(const char *s, size_t size) noexcept {
        return (char*)copy0(s, size);
    }

    char *strdup(const char *s) noexcept {
        return strdup(s, strlen(s));
    }

    char *strdup(const std::string &s) noexcept {
        return strdup(s.c_str(), s.size());
    }

    template <typename _T, typename ..._Args>
    _T* construct(_Args&&...args) noexcept {
        void *p = alloc(sizeof(_T));
        return new(p) _T(std::forward<_Args>(args)...);
    };

    template <typename _T>
    void destroy(_T *obj) noexcept {
        obj->~type();
    }

private:
    void newchunk(size_t length) noexcept;
    void free(Page *chunk, char *obj) noexcept;

private:
    PageAllocator *_pa;
    Page *_chunk;
    char *_object_base;
    char *_next_free;
    char *_chunk_limit;
    bool _maybe_empty_object;
};

GX_NS_END

#endif

