#include "page.h"
#include "bitorder.h"
#include "log.h"

#include <cstdlib>
#ifndef GX_PLATFORM_WIN32
#include <sys/mman.h>
#include <unistd.h>
#endif
#include <cassert>

#ifdef __GX_SERVER_H__
#define GX_USE_MMAP 1
#else
#define GX_USE_MMAP 0
#endif

GX_NS_BEGIN

static void *__alloc(size_t size) noexcept {
#if !GX_USE_MMAP
    char *p = (char*)std::malloc(size);
    memset(p, 0, size);
    return p;
#else
    char *p = (char*)mmap(nullptr, size, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (p == MAP_FAILED) {
        return nullptr;
    }
    return p;
#endif
}

static void __free(void *p, size_t size) noexcept {
#if !GX_USE_MMAP
    std::free(p);
#else
    munmap(p, size);
#endif
}

PageAllocator::PageAllocator() noexcept
: _iseg(), _cseg()
{ }

PageAllocator::~PageAllocator() noexcept {
    segment  *seg;
    while ((seg = _segments.pop_front())) {
        segment_destroy(seg);
    }
}

PageAllocator::segment *PageAllocator::segment_create(PageAllocator::segment *seg, unsigned size) noexcept {
    assert(size);
    if (!seg) {
        size += sizeof(segment);
    }
    size = gx_align(size, sys_page_size);

    char *p = (char*)__alloc(size);
    if (!p) {
        return nullptr;
    }

    if (!seg) {
        seg = (segment *)p;
        seg->_firstp = p + gx_align_default(sizeof(segment));
    }
    else {
        seg->_firstp = p;
    }
    seg->_base = p;
    seg->_endp = p + size;
    _segments.push_front(seg);
    return seg;
}

void PageAllocator::segment_destroy(PageAllocator::segment *seg) noexcept {
    __free(seg->_base, seg->_endp - seg->_base);
}

bool PageAllocator::segment_expand(PageAllocator::segment *seg, unsigned size) noexcept {
#if !GX_USE_MMAP
    return false;
#else
    unsigned old_size = seg->_endp - seg->_base;
    unsigned new_size = old_size + gx_align(size, sys_page_size);

    char *p = (char *)mremap(seg->_base, old_size, new_size, 0);
    if (p == MAP_FAILED) {
        return false;
    }
    assert(p == seg->_base);
    seg->_endp = p + new_size;
    return true;
#endif
}

inline void *PageAllocator::ialloc(unsigned size) noexcept {
    char *p;
    size = gx_align_default(size);

    while (1) {
        if (!_iseg) {
            _iseg = segment_create(nullptr, size < iseg_initsize ? iseg_initsize : size);
        }

        if (gx_unlikely(_iseg->_firstp + size > _iseg->_endp)) {
            if (!segment_expand(_iseg, iseg_expand_size)) {
                _iseg = nullptr;
                continue;
            }
        }

        p = _iseg->_firstp;
        _iseg->_firstp += size;
        return p;
    }
}

inline PageAllocator::area *PageAllocator::area_alloc(void *base) noexcept {
    area *a = _areas.pop_front();
    if (!a) {
        a = (area *)ialloc(sizeof(area));
        page_node *node = a->_pages;
        for (unsigned i = 0; i < area::length; i++, node++) {
            node->_index = i;
        }
    }
    a->_base = (char *)base;
    a->_pages->_order = max_order;
    return a;
}

inline void PageAllocator::area_free(PageAllocator::area *a) noexcept {
    chunk_free(a->_base);
    _areas.push_front(a);
}

inline Page *PageAllocator::page_alloc() noexcept {
    Page *pg = _pages.pop_front();
    if (!pg) {
        pg = (Page *)ialloc(sizeof(Page));
    }
    return pg;
}

inline void PageAllocator::page_free(Page *pg) noexcept {
    _pages.push_front(pg);
}

inline void *PageAllocator::chunk_alloc() noexcept {
    void *p = (void *)_freetab->pop_front();
    if (p) {
        return p;
    }

    while (1) {
        if (!_cseg) {
            _cseg = (segment *)ialloc(sizeof(segment));
            segment_create(_cseg, cseg_initsize);
        }

        if (gx_unlikely(_cseg->_firstp + page_max_size > _cseg->_endp)) {
            if (!segment_expand(_cseg, cseg_expand_size)) {
                _cseg = nullptr;
                continue;
            }
        }

        p = _cseg->_firstp;
        _cseg->_firstp += page_max_size;
        return p;
    }
}

inline void PageAllocator::chunk_free(void *chunk) noexcept {
    _freetab->push_front((page_node *)chunk);
}

Page *PageAllocator::alloc(size_t size) noexcept {
    unsigned order, norder;
    page_node *node, *buddy;
    area *a;

    Page *pg = page_alloc();

    size = gx_align(size, page_min_size);

    if (gx_likely(size <= (page_max_size >> 1))) {
        size >>= PageAllocator::page_boundary_index;
        order = BitOrder::ordertab[size];
        if (order < min_order) {
            order = min_order;
        }

        auto list = _freetab + order;
        if ((node = list->pop_front())) {
buddy_final:
            node->_order = 0;
            pg->order_size = order;
            pg->base = node;
            a = (area *)(node - node->_index);
            pg->firstp = a->_base + (node->_index * page_min_size);
            pg->endp = pg->firstp + (1 << (page_boundary_index + order));
            return pg;
        }

        norder = order + 1;
        for (list++; norder < max_order; norder++, list++) {
            if ((node = list->pop_front())) {
                break;
            }
        }

        if (!node) {
            void *chunk = chunk_alloc();
            a = area_alloc(chunk);
            node = a->_pages;
            norder = max_order;
        }

        unsigned offset = 1 << (norder - min_order);
        while (norder > order) {
            norder--;
            offset >>= 1;
            buddy = node + offset;
            node->_order = buddy->_order = norder;
            _freetab[norder].push_front(buddy);
        }
        goto buddy_final;
    }
    else if (size == page_max_size) {
        pg->base = chunk_alloc();
        pg->firstp = (char *)pg->base;
        pg->endp = pg->firstp + page_max_size;
        pg->order_size = max_order;
        return pg;
    } else {
        pg->base = __alloc(size);
        pg->order_size = size;
        pg->firstp = (char *)pg->base;
        pg->endp = pg->firstp + size;
        return pg;
    }
}

void PageAllocator::free(Page *pg) noexcept {
    if (gx_likely(pg->order_size < max_order)) {
        page_node *node = (page_node *)pg->base;
        page_node *buddy;
        unsigned buddy_index;
        unsigned order = pg->order_size;

        while (order < max_order) {
            buddy_index = node->_index ^ (1 << (order - min_order));
            buddy = node + (int)(buddy_index - node->_index);
            if (order != buddy->_order) {
                node->_order = order;
                break;
            }

            gx_list(page_node, _entry)::remove(buddy);

            if (node > buddy) {
                node->_order = 0;
                node = buddy;
            } else {
                buddy->_order = 0;
            }

            order++;
            node->_order = order;
        }

        if (order == max_order) {
            area_free((area *)node);
        } else {
            _freetab[order].push_front(node);
        }
    } else if (pg->order_size == max_order) {
        chunk_free(pg->base);
    } else {
        __free(pg->base, pg->order_size);
    }
    page_free(pg);
}

GX_NS_END

