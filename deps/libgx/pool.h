#ifndef __GX_POOL_H__
#define __GX_POOL_H__

#include <string>
#include <cstdarg>

#include "object.h"
#include "page.h"
#include "memory.h"
#include "singleton.h"

GX_NS_BEGIN

class Pool : public Object, public singleton<Pool, PageAllocator> {
public:
	Pool(PageAllocator *pa = nullptr) noexcept;
	~Pool() noexcept;

    void clear() noexcept;
    void *alloc(size_t size) noexcept {
        size = gx_align_default(size);
        Page *pg = _active;
        if (gx_likely(size <= pg->space())) {
            void *p = pg->firstp;
            pg->firstp += size;
            return p;
        }
        return alloc(pg, size);
    }
    void *calloc(size_t size) noexcept {
        void *p = alloc(size);
        memset(p, 0, size);
        return p;
    }
    PageAllocator *page_allocator() const noexcept {
        return _pa;
    }
    char *strdup(const char *str, size_t n) noexcept;
    char *strdup(const char *str) noexcept;
    char *strdup(std::string &str) noexcept {
        return strdup(str.c_str(), str.size());
    }
    char *vprintf(const char *fmt, va_list ap) noexcept;
    char *printf(const char *fmt, ...) noexcept GX_PRINTF_ATTR(2, 3) {
        va_list ap;
        va_start(ap, fmt);
        char *strp = vprintf(fmt, ap);
        va_end(ap);
        return strp;
    }
private:
    void *alloc(Page *active, size_t size) noexcept;

private:
    PageAllocator *_pa;
    Page *_self;
    Page *_active;
    char *_firstp;
};

GX_NS_END

#endif

