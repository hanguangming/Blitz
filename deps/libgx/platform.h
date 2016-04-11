#ifndef __GX_PLATFORM_H__
#define __GX_PLATFORM_H__

#include <cstddef>
#include <cstdint>
#include <utility>
#include <type_traits>
#include <cassert>
#include <cstring>

#define GX_MT                   0

#define GX_DEBUG                1

#define GX_NS                   gx
#define GX_NS_BEGIN             namespace GX_NS {
#define GX_NS_END               }
#define GX_NS_USING             using namespace GX_NS;

#if defined(WIN32) || defined(_WIN32)
#define GX_PLATFORM_WIN32
#define _CRT_SECURE_NO_WARNINGS 1
#define NOMINMAX
#include <Ws2tcpip.h>
#include <winsock2.h>
#include <windows.h>
#else
#define GX_PLATFORM_LINUX
#endif


#ifdef __GNUC__
#define GX_PRINTF_ATTR(m, n)    __attribute__((format(printf, m, n)))
#define gx_likely(x)            __builtin_expect(!!(x), 1)
#define gx_unlikely(x)          __builtin_expect(!!(x), 0)
#define GX_UNUSED               __attribute__((unused))
#else
#define GX_PRINTF_ATTR(m, n)
#define gx_likely(x)            (x)
#define gx_unlikely(x)          (x)
#define noexcept                throw()
#define constexpr
#define GX_UNUSED
#endif

#define gx_is_p2aligned(x, a)   ((((uintptr_t)(v)) & ((uintptr_t)(a) - 1)) == 0)
#define gx_is_p2(x)             (((x) & ((x) - 1)) == 0)
#define gx_p2align(x, a)        ((x) & -(align))
#define gx_align(x, a)          (((x) + ((a) - 1)) & ~((a) - 1))
#define gx_align_order          3
#define gx_align_size           (1 << gx_align_order)
#define gx_align_default(x)     gx_align(x, gx_align_size)

#include <functional>
using std::placeholders::_1;
using std::placeholders::_2;
using std::placeholders::_3;
using std::placeholders::_4;
using std::placeholders::_5;
using std::placeholders::_6;
using std::placeholders::_7;
using std::placeholders::_8;
using std::placeholders::_9;
using std::nullptr_t;
#endif

