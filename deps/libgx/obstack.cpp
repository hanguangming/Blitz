#include "obstack.h"
#include "printf.h"
#include "log.h"

GX_NS_BEGIN

Obstack::Obstack(size_t initsize, PageAllocator *pa) noexcept {
    if (!pa) {
        pa = PageAllocator::instance();
    }

    Page *chunk;
    chunk = pa->alloc(initsize);
    chunk->next = nullptr;

    _pa = pa;
    _chunk = chunk;
    _next_free = _object_base = chunk->firstp;
    _chunk_limit = chunk->endp;
    _maybe_empty_object = false;
}

Obstack::~Obstack() noexcept {
    Page *chunk = _chunk;
    Page *tmp;
    while (chunk) {
        tmp = chunk->next;
        _pa->free(chunk);
        chunk = tmp;
    }
}

void Obstack::clear() noexcept {
    Page *chunk = _chunk;
    Page *tmp;
    while (1) {
        tmp = chunk->next;
        if (!tmp) {
            break;
        }
        _pa->free(chunk);
        chunk = tmp;
    }
    _chunk = chunk;
    _next_free = _object_base = chunk->firstp;
    _chunk_limit = chunk->endp;
    _maybe_empty_object = false;
}

void Obstack::newchunk(size_t length) noexcept {
    register Page *old_chunk = _chunk;
    register Page *new_chunk;
    register size_t new_size;
    register size_t obj_size = _next_free - _object_base;
    char *object_base;

    new_size = obj_size + length + 128;
    new_chunk = _pa->alloc(new_size);

    _chunk = new_chunk;
    new_chunk->next = old_chunk;
    _chunk_limit = new_chunk->endp;

    /* Compute an aligned object_base in the new chunk */
    object_base = new_chunk->firstp;
    memcpy(object_base, _object_base, obj_size);

    if (!_maybe_empty_object && (_object_base == old_chunk->firstp) && old_chunk->next) {
        new_chunk->next = old_chunk->next;
        _pa->free(old_chunk);
    }

    _object_base = object_base;
    _next_free = _object_base + obj_size;
    _maybe_empty_object = false;
}

void Obstack::free(Page *chunk, char *obj) noexcept {
    Page *tmp;
    while ((tmp = chunk->next) && (chunk->firstp >= obj || chunk->endp < obj)) {
        _pa->free(chunk);
        chunk = tmp;
        _maybe_empty_object = true;
    }

    if (!tmp && (chunk->firstp > obj || chunk->endp < obj)) {
        assert(false);
    }

    _object_base = _next_free = obj;
    _chunk_limit = chunk->endp;
    _chunk = chunk;
}


int Obstack::vprint(const char *fmt, va_list ap) noexcept {
    struct print_handler : Printf {
        Obstack *_owner;

        int flush() {
            _owner->_next_free = _curpos;
            if (_owner->_next_free >= _owner->_chunk_limit) {
                _owner->make_rome(128);
                _curpos = _owner->_next_free;
                _endpos = _owner->_chunk_limit;
            }
            return 0;
        }
    };

    print_handler handler;
    handler._curpos = _next_free;
    handler._endpos = _chunk_limit;
    handler._owner = this;

    int n;
    if ((n = handler.format(fmt, ap)) >= 0) {
        _next_free = handler._curpos;
    }
    return n;
}

GX_NS_END

