#ifdef __GX_SERVER__
#include "coroutine.h"
#include "log.h"

#include <ucontext.h>

#define GX_CO_CAP       4096
#define GX_CO_MEMSIZE   (64 * 1024)
#define GX_CO_GROW      32
#define GX_CO_CTXSIZE   gx_align_default(sizeof(Coroutine::coctx_t))
#define GX_CO_STKSIZE   (GX_CO_MEMSIZE - gx::offsetof_member(&Coroutine::_placeholder) - sizeof(long) - GX_CO_CTXSIZE)

GX_NS_BEGIN

struct CoManager {
    typedef gx_list(Coroutine, _entry) co_list_t;

    CoManager() noexcept {
        memset(_coroutines, 0, sizeof(_coroutines));
        _size = 0;
        _busy_list.push_front(&_main);
        _main._status = Coroutine::DEAD;
        _main._ctx = &_mainctx;
    }
    ~CoManager() noexcept {
        for (auto co : _coroutines) {
            if (co) {
                Page *page = co->_page;
                co->~Coroutine();
                PageAllocator::instance()->free(page);
            }
        }
    }
    bool grow() noexcept {
        if (_size + GX_CO_GROW > GX_CO_CAP) {
            return false;
        }
        unsigned i = _size;
        _size += GX_CO_GROW;
        for (; i < _size; i++) {
            Page *page = PageAllocator::instance()->alloc(GX_CO_MEMSIZE);
            Coroutine *co = new(page->firstp) Coroutine;
            co->_page = page;
            co->_status = Coroutine::DEAD;
            co->_ctx = (Coroutine::coctx_t*)co->_placeholder;
            co->_stack = co->_placeholder + GX_CO_CTXSIZE;
            _free_list.push_front(co);
            _coroutines[i] = co;
        }
        return true;
    }
    static void routine() noexcept;

    Coroutine *spawn(Coroutine::routine_t routine, void *ud) noexcept {
        Coroutine *co;
        if (!(co = _free_list.pop_front())) {
            if (!grow()) {
                return nullptr;
            }
            co = _free_list.pop_front();
        }
        _yield_list.push_front(co);
        co->_routine = routine;
        co->_ud = ud;
        co->_status = Coroutine::READY;
        if (!co->_context) {
            co->_context = Context::factory();
            co->_context->_co = co;
        }
        return co;
    }
    bool resume(Coroutine *co) noexcept {
        Coroutine *caller = _busy_list.front();
        assert(caller);
        if (caller == co) {
            return false;
        }

        switch (co->_status) {
        case Coroutine::READY:
            Coroutine::set_context(co->_ctx, routine, co->_stack, GX_CO_STKSIZE);
        case Coroutine::SUSPEND:
            co_list_t::remove(co);
            _busy_list.push_front(co);
            co->_status = Coroutine::RUNNING;
            return Coroutine::switch_context(caller->_ctx, co->_ctx);
        default:
            return false;
        }
    }
    bool yield() noexcept {
        Coroutine *co = _busy_list.front();
        assert(co);
        if (co == &_main) {
            return false;
        }

        co_list_t::remove(co);
        _yield_list.push_front(co);
        co->_status = Coroutine::SUSPEND;

        Coroutine *caller = _busy_list.front();
        assert(caller);
        return Coroutine::switch_context(co->_ctx, caller->_ctx);
    }
    Coroutine *self() noexcept {
        Coroutine *co = _busy_list.front();
        assert(co);
        return co;
    }
    void init() noexcept {
        _main._context = Context::factory();
        _main._context->_co = &_main;
    }
    Coroutine *_coroutines[GX_CO_CAP];
    size_t _size;
    Coroutine _main;
    Coroutine::coctx_t _mainctx;
    co_list_t _free_list;
    co_list_t _yield_list;
    co_list_t _busy_list;
};

static CoManager __comgr;

void CoManager::routine() noexcept {
    CoManager *mgr = &__comgr;

    Coroutine *co = mgr->_busy_list.front();
    co->_routine(co->_ud);
    co->_status = Coroutine::DEAD;
    mgr->_busy_list.pop_front();
    mgr->_free_list.push_front(co);
    Coroutine *caller = mgr->_busy_list.front();
    assert(caller);
    Coroutine::switch_context(co->_ctx, caller->_ctx);
}

inline void Coroutine::set_context(coctx_t *ctx, void (*func)(), char *stkbase, long stksiz) noexcept {
    getcontext(ctx);

    ctx->uc_link = nullptr;
    ctx->uc_stack.ss_sp = stkbase;
    ctx->uc_stack.ss_size = stksiz - sizeof(long);
    ctx->uc_stack.ss_flags = 0;

    makecontext(ctx, (void(*)(void))func, 0);
}

inline bool Coroutine::switch_context(coctx_t *octx, coctx_t *nctx) noexcept {
    assert(octx != nctx);
    return swapcontext(octx, nctx) >= 0;
}

Coroutine *Coroutine::spawn(Coroutine::routine_t routine, void *ud) noexcept {
    return __comgr.spawn(routine, ud);
}

bool Coroutine::resume() noexcept {
    return __comgr.resume(this);
}

bool Coroutine::yield() noexcept {
    return __comgr.yield();
}

Coroutine *Coroutine::self() noexcept {
    return __comgr.self();
}

bool Coroutine::is_main_routine() noexcept {
    return __comgr.self() == &__comgr._main;
}

void Coroutine::init() noexcept {
    __comgr.init();
}


GX_NS_END
#endif

