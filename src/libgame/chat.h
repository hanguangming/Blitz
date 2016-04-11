#ifndef __LIBGAME_CHAT_H__
#define __LIBGAME_CHAT_H__

#include "game.h"
#include "money.h"
#include "libgame/g_defines.h"

class G_ChatInfo : public Object {
    friend class G_ChatMgr;
    friend class G_ChatCooldown;
public:
    G_ChatInfo() noexcept;
    const G_Money &price() const noexcept {
        return _price;
    }
private:
    timeval_t _cooldown;
    G_Money _price;
};

class G_ChatMgr : public Object, public singleton<G_ChatMgr> {
public:
    bool init();

    const G_ChatInfo *get_info(unsigned id) const noexcept {
        assert(id < G_CHAT_CHANNEL_UNKNOWN);
        return _infos[id];
    }
public:
    object<G_ChatInfo> _infos[G_CHAT_CHANNEL_UNKNOWN];
};


class G_ChatCooldown : public Object {
public:
    G_ChatCooldown() noexcept;
    bool check_set(unsigned id) noexcept {
        assert(id < G_CHAT_CHANNEL_UNKNOWN);
        timeval_t t = logic_time();
        if (_times[id] > t) {
            return false;
        }
        _times[id] = t + G_ChatMgr::instance()->get_info(id)->_cooldown;
        return true;
    }
private:
    timeval_t _times[G_CHAT_CHANNEL_UNKNOWN];
};

#endif

