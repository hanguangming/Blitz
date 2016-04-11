#include <sstream>
#include <cstdlib>
#include <cstdio>
#include "log.h"
#include "timeval.h"
#include "application.h"
#include "socket.h"

#ifndef GX_PLATFORM_WIN32
#include <cxxabi.h>
#include <alloca.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#ifndef ANDROID
#include <execinfo.h>
#endif
#endif

GX_NS_BEGIN

ptr<LogPrinter> the_log_printer = object<LogPrinter>();

void LogPrinter::vprintf(int level, const char *file, size_t line, const char *fmt, va_list ap) noexcept {
    vfprintf(stderr, fmt, ap);
    fputc('\n', stderr);
    fflush(stderr);
    if (level == LOG_DIE) {
        assert(0);
        std::exit(1);
    }
}

#ifdef GX_PLATFORM_WIN32
void print_back_trace() noexcept {
}
#elif defined(ANDROID)
void print_back_trace() noexcept {
}
#if 0
#include <android/log.h>
#include <dlfcn.h>
#include <unwind.h>
struct BacktraceState {
    void** current;
    void** end;
};

static _Unwind_Reason_Code __unwind_callback(struct _Unwind_Context *context, void* arg) {
    BacktraceState* state = static_cast<BacktraceState*>(arg);
    uintptr_t pc = _Unwind_GetIP(context);
    if (pc) {
        if (state->current == state->end) {
            return _URC_END_OF_STACK;
        } else {
            *state->current++ = reinterpret_cast<void*>(pc);
        }
    }
    return _URC_NO_REASON;
}

static size_t __capture_backtrace(void** buffer, size_t max) {
    BacktraceState state = {buffer, buffer + max};
    _Unwind_Backtrace(__unwind_callback, &state);

    return state.current - buffer;
}

void print_back_trace() noexcept {
    const size_t max = 30;
    void* buffer[max];
    std::stringstream stream;
    size_t count = __capture_backtrace(buffer, max);

    for (size_t i = 0; i < count; ++i) {
        const void* addr = buffer[i];
        const char* symbol = "";

        Dl_info info;
        //if (dladdr(addr, &info) && info.dli_sname) {
        //    __android_log_print(ANDROID_LOG_INFO, "mtg", "kkkkkkkkkkkkkkkkkkkkkkkkkkkkkk3\n");
        //    symbol = info.dli_sname;
        //}

        stream << "  #" << " " << i << ": " << addr << "  " << symbol << "\n";
    }
    __android_log_print(ANDROID_LOG_INFO, "mtg", "%s", stream.str().c_str());
}
#endif
#else
static void __print_back_trace(char **strings, int count) {
    int status;
    int c;

    for (int j = 0; j < count; j++, strings++) {
        char *p = *strings;
        char *h = p;

        while ((c = *p)) {
            if ('(' == c) {
                *p++ = '\0';
                break;
            }
            p++;
        }

        char *n = p;
        char s = ' ';
        while ((c = *p)) {
            switch (c) {
            case 'a' ... 'z':
            case 'A' ... 'Z':
            case '0' ... '9':
            case '_':
                p++;
                break;
            default:
                s = *p;
                *p = '\0';
                p++;
                goto next;
            }
        }
next:
        char *realname;
        realname = abi::__cxa_demangle(n, 0, 0, &status);
        if (!status) {
            n = realname;
        }
        log_error("%s(%s%c%s", h, n, s, p);
        ::free(realname);
    }
}

void print_back_trace() noexcept {
    int nptrs;
    void *buffer[100];
    char **strings;

    nptrs = backtrace(buffer, 100);
    strings = backtrace_symbols(buffer, nptrs);
    if (strings == nullptr) {
        perror("backtrace_symbols");
    }
    else {
        __print_back_trace(strings, nptrs);
    }
    std::free(strings);
}
#endif

UdpLogPrinter::UdpLogPrinter() {
    _socket = socket(AF_INET, SOCK_DGRAM, 0);
    _name = the_app->name();
    _name_size = strlen(_name);
}

UdpLogPrinter::~UdpLogPrinter() {
    Socket::close_fd(_socket);
}

void UdpLogPrinter::vprintf(int level, const char *file, size_t line, const char *fmt, va_list ap) noexcept {
    timeval_t t = gettimeofday();
    _pool.grow(&level, 1);
    _pool.grow(t);
    _pool.grow(&_name_size, 1);
    _pool.grow0(_name, _name_size);
    _pool.grow1(the_app->id());
    _pool.vprint(fmt, ap);
    _pool.grow1(0);
    unsigned size = _pool.object_size();
    char *p = (char*)_pool.finish();

    ::sendto(_socket, p, size, 0, the_app->log_addr(), Address::length);
    _pool.clear();
}

GX_NS_END

