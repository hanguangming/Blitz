#ifndef __GX_COROUTINE_H__
#define __GX_COROUTINE_H__

#ifdef __GX_SERVER__

#include "platform.h"
#include "object.h"
#include "list.h"
#include "page.h"
#include "context.h"

struct ucontext;

GX_NS_BEGIN

class Coroutine {
    friend class CoManager;
public:
    typedef void(*routine_t)(void *);
    typedef ucontext coctx_t;

    enum {
        DEAD,
        READY,
        RUNNING,
        SUSPEND,
    };

public:
    static Coroutine *spawn(Coroutine::routine_t routine, void *ud) noexcept;
    static void init() noexcept;
    bool resume() noexcept;
    static bool yield() noexcept;
    static Coroutine *self() noexcept;
    static bool is_main_routine() noexcept;

    int status() const noexcept {
        return _status;
    }
    Context *context() noexcept {
        return _context;
    }
    bool running() const noexcept {
        return _status == RUNNING;
    }
private:
    static void set_context(coctx_t *cc, void (*func)(), char *stkbase, long stksiz) noexcept;
    static bool switch_context(coctx_t *octx, coctx_t *nctx) noexcept;

private:
    list_entry _entry;
    int _status;
    ptr<Context> _context;
    Page *_page;
    routine_t _routine;
    char *_stack;
    void *_ud;
    coctx_t *_ctx;
    char _placeholder[1];
};

GX_NS_END

#endif

#endif

