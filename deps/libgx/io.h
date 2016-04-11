#ifndef __GX_IO_H__
#define __GX_IO_H__

#include "platform.h"

GX_NS_BEGIN

#define GX_FD_INVALID_VALUE -1
typedef int fd_t;
inline bool fd_valid(fd_t fd) noexcept {
    return fd >= 0;
}

class IO {
public:
    virtual int read(void *buf, size_t size) noexcept = 0;
    virtual int write(const char *buf, size_t size) noexcept = 0;
    virtual void close() noexcept = 0;
};

GX_NS_END

#endif

