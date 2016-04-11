#ifndef __GX_STREAM_H__
#define __GX_STREAM_H__

#include "platform.h"
#include "page.h"
#include "object.h"
#include "io.h"

GX_NS_BEGIN

class Stream : public Object {
protected:
    static size_t chunk_size(Page *chunk) noexcept {
        return chunk->p - chunk->firstp;
    }
    static size_t chunk_space(Page *chunk) noexcept {
        return chunk->endp - chunk->p;
    }
public:
    Stream(PageAllocator *pa = nullptr) noexcept;
    Stream(Stream &&x) : _end_chunk(), _size() {
        swap(x);
    }
    ~Stream() noexcept;

    void swap(Stream &x) noexcept {
        std::swap(_pa, x._pa);
        std::swap(_first_chunk, x._first_chunk);
        std::swap(_end_chunk, x._end_chunk);
        std::swap(_size, x._size);
    }
    std::size_t size() const noexcept {
        return _size;
    }
    void clear() noexcept;
    void shrink() noexcept;
    void read(void *buf, size_t size) noexcept {
        assert(_size >= size);
        _size -= size;

        register Page *chunk = _first_chunk;
        register size_t n = chunk_size(chunk);
        if (gx_likely(n >= size)) {
            if (buf) {
                memcpy(buf, chunk->firstp, size);
            }
            chunk->firstp += size;
            return;
        }
        read(buf, size, chunk, n);
    }
    void write(const void *buf, size_t size) noexcept {
        assert(buf && size);
        _size += size;

        register Page *chunk = _end_chunk;
        register size_t n = chunk_space(chunk);
        if (gx_likely(n >= size)) {
            memcpy(chunk->p, buf, size);
            chunk->p += size;
            return;
        }
        write(buf, size, chunk, n);
    }
    void *blank(size_t size) {
        assert(size);
        _size += size;

        Page *chunk = _end_chunk;
        if (chunk_space(chunk) >= size) {
            void *p = chunk->p;
            chunk->p += size;
            return p;
        }
        return blank(chunk, size);
    }
    void load(const Stream &x) noexcept;
    void load(Stream &&x) noexcept;
    int load(IO &x) noexcept;
    int save(IO &x) noexcept;

    template <typename _T>
    _T read() noexcept {
        _T tmp;
        read(&tmp, sizeof(_T));
        return tmp;
    }

    template <typename _T>
    void write(_T value) noexcept {
        write(&value, sizeof(_T));
    }

    size_t read_size() noexcept {
        unsigned ssize = size();
        if (ssize < 1) {
            return -1;
        }
        size_t size = read<uint8_t>();
        unsigned tmp;
        switch (size & 3) {
        case 1:
            if (ssize < 2) {
                return -1;
            }
            size |= (read<uint8_t>() << 8);
            break;
        case 2:
            if (ssize < 3) {
                return -1;
            }
            size |= (read<uint16_t>() << 8);
            break;
        case 3:
            if (ssize < 4) {
                return -1;
            }
            tmp = 0;
            read(&tmp, 3);
            size |= tmp << 8;
            break;
        }
        size >>= 2;
        return size;
    }
    void write_size(size_t size) noexcept {
        assert(size <= (0xffffffff >> 2));
        if (gx_likely(size <= (0xffu >> 2))) {
            write<uint8_t>(size << 2);
        }
        else if (gx_likely(size <= (0xffffu >> 2))) {
            write<uint16_t>((size << 2) | 1);
        }
        else if (gx_likely(size <= (0xffffffu >> 2))) {
            size <<= 2;
            size |= 2;
            write(&size, 3);
        }
        else {
            size <<= 2;
            size |= 3;
            write<uint32_t>(size);
        }
    }

    Stream &operator=(const Stream &x) noexcept {
        clear();
        load(x);
        return *this;
    }
    Stream &operator=(Stream &&x) noexcept {
        swap(x);
        return *this;
    }

private:
    void init(Page *chunk) noexcept;
    Page *new_chunk(Page *chunk) noexcept;
    Page *alloc_chunk(size_t size = 1) noexcept;
    void free_chunk(Page *chunk) noexcept;
    static void reset_chunk(Page *chunk) noexcept;
    void read(void *buf, size_t size, Page *chunk, size_t n) noexcept;
    void write(const void *buf, size_t size, Page *chunk, size_t n) noexcept;
    void *blank(Page *chunk, size_t size) noexcept;
private:
    PageAllocator *_pa;
    Page *_first_chunk;
    Page *_end_chunk;
    std::size_t _size;
};

GX_NS_END

#endif

