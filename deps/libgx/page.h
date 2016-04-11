#ifndef __GX_PAGE_H__
#define __GX_PAGE_H__

#include "platform.h"
#include "list.h"
#include "singleton.h"

GX_NS_BEGIN

struct Page {
    friend class PageAllocator;
    union {
        struct {
            Page *next;
            Page **ref;
        };
        list_entry   entry;
        slist_entry  sentry;
        stlist_entry stentry;
        //clist_entry  centry;
    };
    char *firstp;
    char *endp;
    char *p;
    union {
        unsigned index;
        unsigned size;
    };
    unsigned space() const noexcept {
        return endp - firstp;
    }
private:
    unsigned order_size;
    void *base;
};

class PageAllocator : public Object, public singleton<PageAllocator> {
private:
    struct segment {
        list_entry _entry;
        char *_base;
        char *_firstp;
        char *_endp;
    };

public:
    static constexpr const unsigned sys_page_size        = 8192;
    static constexpr const unsigned max_order = 8;
    static constexpr const unsigned min_order = 1;
    static constexpr const unsigned page_boundary_index = 12;
    static constexpr const unsigned page_boundary_size = (1 << page_boundary_index);
    static constexpr const unsigned page_min_size = 1 << (page_boundary_index + min_order);
    static constexpr const unsigned page_max_size = 1 << (page_boundary_index + max_order);
    static constexpr const unsigned iseg_initsize = (1024 * 64 - sizeof(segment));
    static constexpr const unsigned iseg_expand_size = 1024 * 64;
    static constexpr const unsigned cseg_initsize = page_max_size * 16;
    static constexpr const unsigned cseg_expand_size = page_max_size * 16;

private:
    struct page_node {
        list_entry _entry;
        unsigned short _index;
        unsigned short _order;
    };
    struct area {
        static constexpr const unsigned length = 1 << (max_order - min_order);
        page_node _pages[length];
        union {
            char *_base;
            slist_entry _entry;
        };
    };

public:
    PageAllocator() noexcept;
    ~PageAllocator() noexcept;
    Page *alloc(std::size_t size = 1) noexcept;
    void free(Page *p) noexcept;

private:
    segment *segment_create(segment *seg, unsigned size) noexcept;
    void segment_destroy(segment *seg) noexcept;
    bool segment_expand(segment *seg, unsigned size) noexcept;

    void *ialloc(unsigned size) noexcept;

    Page *page_alloc() noexcept;
    void page_free(Page *pg) noexcept;
    area *area_alloc(void *base) noexcept;
    void area_free(area *a) noexcept;
    void *chunk_alloc() noexcept;
    void chunk_free(void *chunk) noexcept;

private:
    gx_list(page_node, _entry) _freetab[max_order];
    segment *_iseg;
    segment *_cseg;
    gx_list(Page, sentry) _pages;
    gx_list(area, _entry) _areas;
    gx_list(segment, _entry) _segments;
};

GX_NS_END

#endif

