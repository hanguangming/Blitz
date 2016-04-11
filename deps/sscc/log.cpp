#include <cstdio>
#include <cstdlib>
#include <cstdarg>
#include "log.h"

void log_error(const char *fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    vfprintf(stderr, fmt, ap);
    fputc('\n', stderr);
}

void log_info(const char *fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    vfprintf(stdout, fmt, ap);
    fputc('\n', stdout);
}

void log_fail(const char *fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    vfprintf(stderr, fmt, ap);
    fputc('\n', stderr);
    exit(-1);
}

void log_verror(const Location &loc, const char *fmt, va_list ap)
{
    fprintf(stderr, "%s:[%u,%u]:[%u,%u]: ", 
            loc.begin.file, 
            loc.begin.line, loc.begin.col,
            loc.end.line, loc.end.col);
    vfprintf(stderr, fmt, ap);
    fprintf(stderr, "\n");
    exit(-1);
}

void log_vexpect(const Location &loc, const char *fmt, va_list ap)
{
    fprintf(stderr, "%s:[%u,%u]:[%u,%u]: expect ", 
            loc.begin.file, 
            loc.begin.line, loc.begin.col,
            loc.end.line, loc.end.col);
    vfprintf(stderr, fmt, ap);
    fprintf(stderr, "\n");
    exit(-1);
}

void log_error(const Location &loc, const char *fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    log_verror(loc, fmt, ap);
}

void log_expect(const Location &loc, const char *fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    log_vexpect(loc, fmt, ap);
}


