#include "timer.h"

/* G_TimerObject */
G_TimerObject::G_TimerObject() noexcept 
: _expire(), _mgr()
{ }

G_TimerObject::~G_TimerObject() {
    close_timer();
}

void G_TimerObject::close_timer() noexcept {
    if (_mgr) {
        _mgr->remove(this);
    }
}

/* G_TimerMgr */
G_TimerMgr::G_TimerMgr() noexcept
: _left()
{ }

void G_TimerMgr::remove(G_TimerObject *obj) noexcept {
    if (!obj->_mgr) {
        return;
    }
    assert(this == obj->_mgr);
    obj->_mgr = nullptr;

    if (_left == obj) {
        _left = static_cast<G_TimerObject*>(obj->next());
    }
    rbtree::remove(obj);
}

void G_TimerMgr::schedule(G_TimerObject *new_timer, timeval_t expire) noexcept {
    assert(new_timer->_mgr == nullptr);

    node **link = &_root;
    node *parent = nullptr;
    int left = 1;

    while (*link) {
        parent = *link;
        G_TimerObject *timer = static_cast<G_TimerObject*>(parent);
        if (expire < timer->_expire) {
            link = &(*link)->_left;
        } else {
            link = &(*link)->_right;
            left = 0;
        }
    }

    new_timer->_expire = expire;
    new_timer->_mgr = this;

    if (left) {
        _left = new_timer;
    }
    rbtree::link(new_timer, parent, link);
    rbtree::insert(new_timer);
}

void G_TimerMgr::loop(timeval_t curtime) noexcept {
    G_TimerObject *timer;

    while ((timer = _left)) {
        if (curtime < timer->_expire) {
            break;
        }

        while (1) {
            remove(timer);
            timeval_t d = timer->timer_handler(curtime);
            if (!d) {
                break;
            }
            d += timer->_expire;
            if (d > curtime) {
                schedule(timer, d);
                break;
            }
            timer->_expire = d;
        }
    }
}

