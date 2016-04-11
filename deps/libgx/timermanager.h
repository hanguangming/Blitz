#ifndef __GX_TIMERMANAGER_H__
#define __GX_TIMERMANAGER_H__

#include <functional>
#include "memory.h"
#include "singleton.h"
#include "rbtree.h"
#include "timeval.h"
#include "list.h"
#include "obstack.h"
#include "allocator.h"

GX_NS_BEGIN

class TimerManager;

class Timer : protected rbtree::node, public WeakableObject {
    friend class TimerManager;
public:
    typedef std::function<timeval_t(Timer&, timeval_t)> handler_type;

    void close() noexcept;
    timeval_t expire() const noexcept {
        return _expires;
    }
private:
    timeval_t _expires;
    handler_type _handler;
    TimerManager *_mgr;
};

class TimerManager : public Object, protected rbtree, public singleton<TimerManager> {
public:
    TimerManager() noexcept;
    ~TimerManager();

    Timer *schedule_abs(timeval_t expires, Timer::handler_type handler) noexcept;
    Timer *schedule(timeval_t expires, Timer::handler_type handler) noexcept {
        return schedule_abs(gettimeofday() + expires, Timer::handler_type(handler));
    }
    void modify(Timer *timer, timeval_t expires) noexcept;
    void remove(Timer *timer) noexcept;
    timeval_t loop(timeval_t curtime) noexcept;
    timeval_t loop() noexcept {
        timeval_t cur = adjust_time();
        while (1) {
            timeval_t t = loop(cur);
            cur = adjust_time();
            if (t > cur) {
                return t;
            }
        }
    }

    void clear() noexcept;
private:
    void schedule_timer(Timer *timer) noexcept;
    void modify_timer(Timer *timer, timeval_t expires) noexcept;
    void remove_timer(Timer *timer) noexcept;
private:
    Timer *_left;
    object<Obstack> _pool;
    object_cache<Timer, Obstack> _cache;
};

inline void Timer::close() noexcept {
    if (_mgr) {
        _mgr->remove(this);
    }
}

GX_NS_END

#endif

