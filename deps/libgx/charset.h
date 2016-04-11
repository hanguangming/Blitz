#ifndef __GX_CHARSET_H__
#define __GX_CHARSET_H__

#include "platform.h"
#include "data.h"
#include "memory.h"

GX_NS_BEGIN

struct Charset {
	static ptr<Data> convert(const Data &source, const char *from, const char *to) noexcept;
};

GX_NS_END

#endif

