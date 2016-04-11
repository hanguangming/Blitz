#include "pool.h"
#include "printf.h"
#include "log.h"

GX_NS_BEGIN

#define list_insert(node, point) do { \
        node->ref = point->ref;       \
        *node->ref = node;            \
        node->next = point;           \
        point->ref = &node->next;     \
    } while (0)

#define list_remove(node) do {        \
        *node->ref = node->next;      \
        node->next->ref = node->ref;  \
    } while (0)

Pool::Pool(PageAllocator *pa) noexcept {
    if (!pa) {
        pa = PageAllocator::instance();
    }
    Page *pg = pa->alloc(PageAllocator::page_min_size);
    pg->next = pg;
    pg->ref = &pg->next;

    _pa = pa;
    _self = pg;
    _active = pg;
    _firstp = pg->firstp;
}

Pool::~Pool() noexcept {
    PageAllocator *pa = _pa;
    Page *tmp;
    Page *pg = _self;
    *pg->ref = nullptr;
    while (pg) {
        tmp = pg->next;
        pa->free(pg);
        pg = tmp;
    }
}

void Pool::clear() noexcept {
    Page *tmp;
    Page *pg = _active = _self;
    pg->firstp = _firstp;

    if (pg->next == _self) {
        return;
    }

    *pg->ref = nullptr;
    pg = pg->next;

    while (pg) {
        tmp = pg->next;
        _pa->free(pg);
        pg = tmp;
    }

    _self->next = _self;
    _self->ref = &_self->next;
}

void *Pool::alloc(Page *active, size_t size) noexcept {
    Page *pg = active->next;

    if (size <= pg->space()) {
        list_remove(pg);
    } else {
        pg = _pa->alloc(size);
    }

    pg->index = 0;

    void *p = pg->firstp;
    pg->firstp += size;

    list_insert(pg, active);
    _active = pg;

    unsigned index = (gx_align(active->space() + 1, PageAllocator::page_boundary_size) - PageAllocator::page_boundary_size) >> PageAllocator::page_boundary_index;

    active->index = index;

    Page *node = active->next;
    if (index >= node->index) {
        return p;
    }

    do {
        node = node->next;
    } while (index < node->index);

    list_remove(active);
    list_insert(active, node);

    return p;
}

#define SPRINTF_MIN_STRINGSIZE 32
char *Pool::vprintf(const char *fmt, va_list ap) noexcept {
    struct print_handler : public Printf {
        Page *_node;
        Pool *_owner;
        bool _got_a_new_node;
        Page *_freelist;

        int flush() {
            Page *node, *active;
            size_t cur_len, size;
            char *strp;
            size_t index;

            active = _node;
            strp = _curpos;
            cur_len = strp - active->firstp;
            size = cur_len << 1;

            if (size < SPRINTF_MIN_STRINGSIZE) {
                size = SPRINTF_MIN_STRINGSIZE;
            }

            node = active->next;
            if (!_got_a_new_node && size <= node->space()) {
                list_remove(node);
                list_insert(node, active);

                node->index = 0;

                _owner->_active = node;

                index = (gx_align(active->space() + 1, PageAllocator::page_boundary_size) - PageAllocator::page_boundary_size) >> PageAllocator::page_boundary_index;

                active->index = index;
                node = active->next;
                if (index < node->index) {
                    do {
                        node = node->next;
                    } while (index < node->index);

                    list_remove(active);
                    list_insert(active, node);
                }

                node = _owner->_active;
            } else {
                node = _owner->_pa->alloc(size);

                if (_got_a_new_node) {
                    active->next = _freelist;
                    _freelist = active;
                }

                _got_a_new_node = true;
            }

            memcpy(node->firstp, active->firstp, cur_len);

            _node = node;
            _curpos = node->firstp + cur_len;
            _endpos = node->endp - 1;
            return 0;
        }
    };

    print_handler handler;
    char *strp;
    size_t size;
    Page *active, *node;
    size_t index;

    handler._node = active = _active;
    handler._owner = this;
    handler._curpos = handler._node->firstp;

    handler._endpos = handler._node->endp - 1;
    handler._got_a_new_node = false;
    handler._freelist = nullptr;

    if (handler._node->firstp == handler._node->endp) {
        handler.flush();
    }

    if (handler.format(fmt, ap) == -1) {
        return nullptr;
    }

    strp = handler._curpos;
    *strp++ = '\0';

    size = strp - handler._node->firstp;
    size = gx_align_default(size);
    strp = handler._node->firstp;
    handler._node->firstp += size;

    node = handler._freelist;
    Page *tmp;
    while (node) {
        tmp = node->next;
        _pa->free(node);
        node = tmp;
    }

    if (!handler._got_a_new_node) {
        return strp;
    }

    active = _active;
    node = handler._node;

    node->index = 0;

    list_insert(node, active);

    _active = node;

    index = (gx_align(active->space() + 1, PageAllocator::page_boundary_size) - PageAllocator::page_boundary_size) >> PageAllocator::page_boundary_index;

    active->index = index;
    node = active->next;

    if (index >= node->index) {
        return strp;
    }

    do {
        node = node->next;
    } while (index < node->index);

    list_remove(active);
    list_insert(active, node);

    return strp;
}

char *Pool::strdup(const char *str, size_t n) noexcept {
    char *res;
    const char *end;

    if (!str) {
        return nullptr;
    }
    end = (const char *)memchr(str, '\0', n);
    if (end != nullptr) {
        n = end - str;
    }
    res = (char *)alloc(n + 1);
    memcpy(res, str, n);
    res[n] = '\0';
    return res;
}

char *Pool::strdup(const char *str) noexcept {
    char *res;
    size_t len;

    if (!str) {
        return nullptr;
    }
    len = strlen(str) + 1;
    res = (char *)alloc(len);
    memcpy(res, str, len);
    return res;
}

GX_NS_END

