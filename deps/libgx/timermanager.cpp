#include "timermanager.h"
#include "log.h"

GX_NS_BEGIN

TimerManager::TimerManager() noexcept
: _left(), _cache(_pool)
{ }

TimerManager::~TimerManager() {
    clear();
}

inline void TimerManager::schedule_timer(Timer *new_timer) noexcept {
    node **link = &_root;
    node *parent = nullptr;
    int left = 1;

    while (*link) {
        parent = *link;
        Timer *timer = static_cast<Timer*>(parent);
        if (new_timer->_expires < timer->_expires) {
            link = &(*link)->_left;
        } else {
            link = &(*link)->_right;
            left = 0;
        }
    }

    if (left) {
        _left = new_timer;
    }
    rbtree::link(new_timer, parent, link);
    rbtree::insert(new_timer);
}

inline void TimerManager::remove_timer(Timer *timer) noexcept {
    if (_left == timer) {
        _left = static_cast<Timer*>(timer->next());
    }
    rbtree::remove(timer);
}

inline void TimerManager::modify_timer(Timer *timer, timeval_t expires) noexcept {
    if (timer->_expires != expires) {
        remove_timer(timer);
        timer->_expires = expires;
        schedule_timer(timer);
    }
}

Timer *TimerManager::schedule_abs(timeval_t expires, Timer::handler_type handler) noexcept {
    Timer *timer = _cache.construct();
    timer->_expires = expires;
    timer->_handler = std::move(handler);
    timer->_mgr = this;
    schedule_timer(timer);
    return timer;
}

timeval_t TimerManager::loop(timeval_t curtime) noexcept {
    Timer *timer;
again:
    while ((timer = _left)) {
        if (curtime < timer->_expires) {
            return timer->_expires;
        }

        while (1) {
            timer->_mgr = nullptr;
            timeval_t d = timer->_handler(*timer, curtime);
            if (!d) {
                remove_timer(timer);
                _cache.destroy(timer);
                goto again;
            }
            d += timer->_expires;
            if (d > curtime) {
                timer->_mgr = this;
                modify_timer(timer, d);
                goto again;
            }
            timer->_expires = d;
        }
    }
    return (timeval_t)-1;
}

void TimerManager::modify(Timer *timer, timeval_t expires) noexcept {
    modify_timer(timer, expires);
}

void TimerManager::remove(Timer *timer) noexcept {
    if (timer->_mgr == this) {
        remove_timer(timer);
        _cache.destroy(timer);
    }
}

void TimerManager::clear() noexcept {
    Timer *timer = _left;
    Timer *tmp;
    while (timer) {
        tmp = static_cast<Timer*>(timer->next());
        _cache.destroy(timer);
        timer = tmp;
    }
    _left = nullptr;
    rbtree::clear();
}

GX_NS_END

