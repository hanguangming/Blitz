#ifndef __LIBGAME_TIMER_H__
#define __LIBGAME_TIMER_H__

#include "game.h"

class G_Player;
class G_TimerMgr;

class G_TimerObject : private rbtree::node {
    friend class G_TimerMgr;
public:
    G_TimerObject() noexcept;
    ~G_TimerObject();
    virtual timeval_t timer_handler(timeval_t now) = 0;
    timeval_t expire() const noexcept {
        return _expire;
    }
    void close_timer() noexcept;
private:
    timeval_t _expire;
    G_TimerMgr *_mgr;
};

class G_TimerMgr : public Object, public rbtree {
    friend class G_TimerObject;
public:
    G_TimerMgr() noexcept;

    void loop(timeval_t curtime) noexcept;
    void schedule(G_TimerObject *timer, timeval_t expire) noexcept;

private:
    void remove(G_TimerObject *obj) noexcept;

private:
    G_TimerObject *_left;
};

#endif

