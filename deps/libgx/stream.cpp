#include "stream.h"

GX_NS_BEGIN

Stream::Stream(PageAllocator *pa) noexcept {
    if (!pa) {
        pa = PageAllocator::instance();
    }
    _pa = pa;
    init(nullptr);
}

Stream::~Stream() noexcept {
    Page *chunk = _end_chunk;
    if (chunk) {
        chunk = chunk->next;
        while (1) {
            Page *tmp = chunk->next;
            free_chunk(chunk);
            if (chunk == _end_chunk) {
                break;
            }
            chunk = tmp;
        }
    }
}

inline Page *Stream::alloc_chunk(size_t size) noexcept {
    Page *chunk = _pa->alloc(size);
    chunk->size = chunk->endp - chunk->firstp;
    chunk->p = chunk->firstp;
    return chunk;
}

inline void Stream::free_chunk(Page *chunk) noexcept {
    _pa->free(chunk);
}

inline void Stream::reset_chunk(Page *chunk) noexcept {
    chunk->p = chunk->firstp = chunk->endp - chunk->size;
}

inline Page *Stream::new_chunk(Page *chunk) noexcept {
    chunk = chunk->next;
    if (chunk == _first_chunk) {
        chunk = alloc_chunk();
        chunk->next = _end_chunk->next;
        _end_chunk->next = chunk;
    } else {
        reset_chunk(chunk);
    }
    _end_chunk = chunk;
    return chunk;
}

inline void Stream::init(Page *chunk) noexcept {
    if (!chunk) {
        chunk = alloc_chunk();
    } else {
        reset_chunk(chunk);
    }
    _first_chunk = _end_chunk = chunk;
    chunk->next = chunk;
    _size = 0;
}

void Stream::clear() noexcept {
    Page *chunk = _end_chunk;
    if (chunk) {
        chunk = chunk->next;
        while (chunk != _end_chunk) {
            Page *tmp = chunk->next;
            free_chunk(chunk);
            chunk = tmp;
        }
    }
    init(chunk);
}

void Stream::shrink() noexcept {
    if (!_size) {
        clear();
        return;
    }
    while (!chunk_size(_first_chunk) && _first_chunk != _end_chunk) {
        _first_chunk = _first_chunk->next;
    }
    Page *chunk = _end_chunk->next;
    while (chunk != _first_chunk) {
        Page *tmp = chunk->next;
        free_chunk(chunk);
        chunk = tmp;
    }
    _end_chunk->next = _first_chunk;
}

void Stream::read(void *buf, size_t size, Page *chunk, size_t n) noexcept {
    register char *p = (char *)buf;
    while (1) {
        if (gx_likely(n)) {
            if (buf) {
                memcpy(p, chunk->firstp, n);
                p += n;
            }
            size -= n;
            chunk->firstp += n;

            if (!size) {
                _first_chunk = chunk;
                return;
            }
        }
        chunk = chunk->next;
        n = chunk_size(chunk);
        if (n > size) {
            n = size;
        }
    }
}

void Stream::write(const void *buf, size_t size, Page *chunk, size_t n) noexcept {
    register char *p = (char *)buf;
    while (1) {
        if (gx_likely(n)) {
            memcpy(chunk->p, p, n);
            chunk->p += n;
            size -= n;
            if (!size) {
                _end_chunk = chunk;
                return;
            }
            p += n;
        }

        chunk = new_chunk(chunk);
        n = chunk_space(chunk);
        if (n > size) {
            n = size;
        }
    }
}

void *Stream::blank(Page *chunk, size_t size) noexcept {
    chunk = chunk->next;
    if (chunk == _first_chunk || chunk->size < size) {
        chunk = alloc_chunk(size);
        chunk->next = _end_chunk->next;
        _end_chunk->next = chunk;
    } else {
        reset_chunk(chunk);
    }
    _end_chunk = chunk;
    chunk->p += size;
    return chunk->firstp;
}

void Stream::load(const Stream &x) noexcept {
    Page *chunk = x._first_chunk;
    while (1) {
        size_t n = chunk_size(chunk);
        if (n) {
            write(chunk->firstp, n);
        }
        if (chunk == x._end_chunk) {
            break;
        }
        chunk = chunk->next;
    }
}

void Stream::load(Stream &&x) noexcept {
    Page *chunk = x._first_chunk;
    while (1) {
        Page *tmp = chunk->next;
        std::size_t n = chunk_size(chunk);
        if (n) {
            chunk->next = _end_chunk->next;
            _end_chunk->next = chunk;
            _end_chunk = chunk;
        } else {
            free_chunk(chunk);
        }
        if (chunk == x._end_chunk) {
            break;
        }
        chunk = tmp;
    }
    x._end_chunk = nullptr;
    x._size = 0;
}

int Stream::load(IO &x) noexcept {
    int count = 0;
    Page *chunk = _end_chunk;
    while (1) {
        size_t space = chunk_space(chunk);
        if (space) {
            int n = x.read(chunk->p, space);
            if (gx_likely(n > 0)) {
                count += n;
                chunk->p += n;
                _size += n;
                /*
                if ((size_t)n < space) {
                    return count;
                }*/
            } else if (gx_likely(n == 0)) {
                return count;
            } else {
                return n;
            }
        }
        chunk = new_chunk(chunk);
    }
}

int Stream::save(IO &x) noexcept {
    int count = 0;
    Page *chunk = _first_chunk;
    while (1) {
        size_t size = chunk_size(chunk);
        if (size) {
            int n = x.write(chunk->firstp, size);
            if (gx_likely(n > 0)) {
                count += n;
                chunk->firstp += n;
                _size -= n;
                /*
                if ((size_t)n < size) {
                    _first_chunk = chunk;
                    return count;
                }*/
            } else if (gx_likely(n == 0)) {
                _first_chunk = chunk;
                return count;
            } else {
                _first_chunk = chunk;
                return n;
            }
        }
        if (chunk == _end_chunk) {
            _first_chunk = chunk;
            return count;
        }
        chunk = chunk->next;
    }
}

GX_NS_END

