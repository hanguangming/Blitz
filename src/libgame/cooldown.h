#ifndef __LIBGAME_COOLDOWN_H__
#define __LIBGAME_COOLDOWN_H__

#include "game.h"
#include "timer.h"

#include "libgame/g_cooldown.h"
#include "libgame/g_defines.h"

class DB_LoadRsp;
class G_AgentContext;
class G_Player;

class G_CooldownMgr : public Object, public singleton<G_CooldownMgr> {
public:
    G_CooldownMgr();
    timeval_t get(unsigned id) const noexcept {
        assert(id < G_CD_UNKNOWN);
        return _cds[id];
    }
    void set(unsigned id, timeval_t time) noexcept;
private:
    timeval_t _cds[G_CD_UNKNOWN];
};

class G_CooldownItem : public Object, public G_TimerObject {
public:
    G_CooldownItem(unsigned id) noexcept
    : _id(id)
    { }

    timeval_t timer_handler(timeval_t now) override;
private:
    unsigned _id;
};

class G_Cooldown : public Object {
public:
    G_Cooldown() noexcept;
    void init(G_Player *player, DB_LoadRsp *msg);
    timeval_t get(unsigned id, timeval_t time) const noexcept {
        assert(id < G_CD_UNKNOWN);
        G_CooldownItem *item = _cds[id];
        if (!item) {
            return 0;
        }
        if (item->expire() <= time) {
            return 0;
        }
        return item->expire() - time;
    }
    timeval_t get(unsigned id) const noexcept {
        return get(id, logic_time());
    }
    timeval_t set(unsigned id, timeval_t time) noexcept;
    timeval_t set(unsigned id) noexcept {
        return set(id, logic_time());
    }
private:
    ptr<G_CooldownItem> _cds[G_CD_UNKNOWN];
};

#endif

