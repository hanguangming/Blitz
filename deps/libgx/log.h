#ifndef __GX_LOG_H__
#define __GX_LOG_H__

#include <cstdarg>
#include "platform.h"
#include "memory.h"
#include "obstack.h"
#include "io.h"

#ifdef ANDROID
#include <android/log.h>
#endif

GX_NS_BEGIN

enum {
    LOG_DEBUG,
    LOG_INFO,
    LOG_WARNING,
    LOG_ERROR,
    LOG_DIE,
};

class LogPrinter : public Object {
public:
    virtual void vprintf(int level, const char *file, size_t line, const char *fmt, va_list ap) noexcept;

protected:
    Obstack _pool;
};

class UdpLogPrinter : public LogPrinter {
public:
    UdpLogPrinter();
    ~UdpLogPrinter();
    void vprintf(int level, const char *file, size_t line, const char *fmt, va_list ap) noexcept override;
protected:
    fd_t _socket;
    const char *_name;
    unsigned _name_size;
};

extern ptr<LogPrinter> the_log_printer;

inline void log(int level, const char *file, size_t line, const char *fmt, ...) noexcept GX_PRINTF_ATTR(4, 5);
inline void log(int level, const char *file, size_t line, const char *fmt, ...) noexcept {
    va_list ap;
    va_start(ap, fmt);
    the_log_printer->vprintf(level, file, line, fmt, ap);
}

void print_back_trace() noexcept;

GX_NS_END

#define gx_log(level, fmt, ...) gx::log(level, __FILE__, __LINE__, fmt, ##__VA_ARGS__)
#define log_debug(fmt, ...)     gx_log(gx::LOG_DEBUG,   fmt, ##__VA_ARGS__)
#define log_info(fmt, ...)      gx_log(gx::LOG_INFO,    fmt, ##__VA_ARGS__)
#define log_warning(fmt, ...)   gx_log(gx::LOG_WARNING, fmt, ##__VA_ARGS__)
#define log_error(fmt, ...)     gx_log(gx::LOG_ERROR,   fmt, ##__VA_ARGS__)
#define log_die(fmt, ...)       gx_log(gx::LOG_DIE,     fmt, ##__VA_ARGS__)

#ifdef ANDROID
#define  android_log(...)  __android_log_print(ANDROID_LOG_DEBUG, "gx", __VA_ARGS__)
#endif

#endif

