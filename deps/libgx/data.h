#ifndef __GX_DATA_H__
#define __GX_DATA_H__

#include <cstdlib>
#include "platform.h"
#include "object.h"

GX_NS_BEGIN

class Data : public Object {
public:
    Data() noexcept : _ptr(), _size() { }
    Data(size_t size) noexcept {
        _ptr = (char*)std::malloc(size + 1);
        _size = size;
        _ptr[size] = '\0';
    }
    Data(const Data&) = delete;
    Data(Data &&x) noexcept : _ptr(), _size() {
        swap(x);
    }
    ~Data() noexcept {
        if (_ptr) {
            std::free(_ptr);
        }
    }
    void swap(Data &x) noexcept {
        std::swap(_ptr, x._ptr);
        std::swap(_size, x._size);
    }
    Data &operator=(const Data&) = delete;
    Data &operator=(Data &&x) noexcept {
        swap(x);
        return *this;
    }
    char *data() const noexcept {
        return _ptr;
    }
    size_t size() const noexcept {
        return _size;
    }
protected:
    char *_ptr;
    size_t _size;
};

GX_NS_END

#endif

