#ifndef __LOG_H__
#define __LOG_H__

#include "token.h"
#include <cstdarg>

#undef log_error
#undef log_info
#undef log_fail

void log_error(const char *fmt, ...);
void log_info(const char *fmt, ...);
void log_fail(const char *fmt, ...);

void log_verror(const Location &loc, const char *fmt, va_list ap);
void log_vexpect(const Location &loc, const char *fmt, va_list ap);

void log_error(const Location &loc, const char *fmt, ...);
void log_expect(const Location &loc, const char *fmt, ...);

#endif


