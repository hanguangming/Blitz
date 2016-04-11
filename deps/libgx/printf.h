#ifndef __GX_PRINTF_H__
#define __GX_PRINTF_H__

#include <cstdarg>
#include "platform.h"

GX_NS_BEGIN

struct Printf {

    virtual int flush() = 0;
    int format(const char *fmt, va_list ap);

    char *_curpos;
    char *_endpos;
};

GX_NS_END


#endif

