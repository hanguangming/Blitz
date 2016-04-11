#include "cooldown.h"
#include "dbsvr/db_login.h"
#include "context.h"
#include "player.h"

/* G_CooldownMgr */
G_CooldownMgr::G_CooldownMgr() {
    memset(_cds, 0, sizeof(_cds));
}

void G_CooldownMgr::set(unsigned id, timeval_t time) noexcept {
    assert(id < G_CD_UNKNOWN);
    _cds[id] = time;
}

timeval_t G_CooldownItem::timer_handler(timeval_t now) {
    the_player()->cooldown()->set(_id, 0);
    the_context()->commit();
    return 0;
}

/* G_Cooldown */
G_Cooldown::G_Cooldown() noexcept 
{ }

void G_Cooldown::init(G_Player *player, DB_LoadRsp *msg) {
    for (auto &opt : msg->cd) {
        if (opt.id < G_CD_UNKNOWN && opt.expire > logic_time()) {
            object<G_CooldownItem> item(opt.id);
            player->timer_mgr()->schedule(item, opt.expire);
            _cds[opt.id] = item;
        }
    }
}

timeval_t G_Cooldown::set(unsigned id, timeval_t time) noexcept {
    assert(id < G_CD_UNKNOWN);

    the_data()->_cooldown_opts.emplace_back();
    auto &opt = the_data()->_cooldown_opts.back();
    opt.id = id;

    if (time) {
        object<G_CooldownItem> item(id);
        the_player()->timer_mgr()->schedule(item, time + G_CooldownMgr::instance()->get(id));
        _cds[id] = item;
        opt.expire = item->expire();
    }
    else {
        _cds[id] = nullptr;
        opt.expire = 0;
    }
    return opt.expire;
}

