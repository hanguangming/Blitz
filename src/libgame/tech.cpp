#include "tech.h"
#include "libgame/g_defines.h"
#include "player.h"
#include "param.h"
#include "dbsvr/db_tech.h"

/* G_TechInfo */
G_TechInfo::G_TechInfo() noexcept 
: _tech_limit(), 
  _level_limit(), 
  _stage_limit(),
  _soldierup(),
  _soldier_pve(),
  _soldier_pvp(),
  _speed(),
  _soldier(),
  _type(),
  _price_num(),
  _cooldown()
{ }

/* G_TechMgr */
bool G_TechMgr::init() {
    auto tab_info = the_app->script()->read_table("the_tech_info");
    if (tab_info->is_nil()) {
        return false;
    }
    for (unsigned i = 1; ; ++i) {
        auto tab_item = tab_info->read_table(i);
        if (tab_item->is_nil()) {
            break;
        }

        int id = tab_item->read_integer("id", -1);
        if (id < 0) {
            continue;
        }
        G_TechInfo *info = probe_info(id);

        int cond = tab_item->read_integer("untype1", -1);
        int value = tab_item->read_integer("unval1", -1);
        switch (cond) {
        case G_TECH_COND_NONE:
            break;
        case G_TECH_COND_LEVEL:
            info->_level_limit = G_LevelMgr::instance()->get_info(value);
            if (!info->_level_limit) {
                log_error("unknown tech condition level '%d'.", value);
                return false;
            }
            break;
        case G_TECH_COND_STAGE:
            info->_stage_limit = G_StageMgr::instance()->get_info(value);
            if (!info->_stage_limit) {
                log_error("unknown tech condition stage '%d'.", value);
                return false;
            }
            break;
        case G_TECH_COND_PRETECH:
            info->_tech_limit = get_info(value);
            if (!info->_tech_limit) {
                log_error("unknown tech condition pretech '%d'.", value);
                return false;
            }
            break;
        default:
            log_error("unknown tech condition '%d'.", cond);
            return false;
        }

        cond = tab_item->read_integer("untype2", -1);
        value = tab_item->read_integer("unval2", -1);
        switch (cond) {
        case G_TECH_COND_NONE:
            break;
        case G_TECH_COND_LEVEL:
            info->_level_limit = G_LevelMgr::instance()->get_info(value);
            if (!info->_level_limit) {
                log_error("unknown tech condition level '%d'.", value);
                return false;
            }
            break;
        case G_TECH_COND_STAGE:
            info->_stage_limit = G_StageMgr::instance()->get_info(value);
            if (!info->_stage_limit) {
                log_error("unknown tech condition stage '%d'.", value);
                return false;
            }
            break;
        case G_TECH_COND_PRETECH:
            info->_tech_limit = get_info(value);
            if (!info->_tech_limit) {
                log_error("unknown tech condition pretech '%d'.", value);
                return false;
            }
            break;
        default:
            log_error("unknown tech condition '%d'.", cond);
            return false;
        }

        int type = tab_item->read_integer("valtype", -1);
        value = tab_item->read_integer("val", 0);
        type--;
        switch (type) {
        case G_TECH_SOLDIERUP_NUM:
            info->_soldierup = value;
            break;
        case G_TECH_SOLDIER_PVE_NUM:
            info->_soldier_pve = value;
            break;
        case G_TECH_SOLDIER_PVP_NUM:
            info->_soldier_pvp = value;
            break;
        case G_TECH_SOLDIER_UNLOCK:
            info->_soldier = G_SoldierMgr::instance()->get_info(value);
            if (!info->_soldier) {
                log_error("unknown tech soldier id '%d'.", value);
                return false;
            }
            break;
        case G_TECH_SPEED:
            if (value <= 0) {
                log_error("bad tech speed '%d'.", value);
                return false;
            }
            info->_speed = value * 1000;
            break;
        default:
            log_error("unknown tech type '%d'.", type);
            return false;
        }
        info->_type = type;

        info->_price_num = tab_item->read_integer("count", 0);
        info->_price.coin = tab_item->read_integer("silver", 0);
        info->_price.money = tab_item->read_integer("yb", 0);
        info->_cooldown = tab_item->read_integer("time", 0) * 1000;
    }
    return true;
}

/* G_TechItem */
G_TechItem::G_TechItem(unsigned type) noexcept
: G_TimerObject(),
  _type(type), 
  _info(),
  _research(),
  _price_num(),
  _cooldown()
{ }

void G_TechItem::to_opt(G_TechExpireOpt &opt) noexcept {
    opt.type = _type;
    opt.cur = _info ? _info->id() : 0;
    opt.research = _research ? _research->id() : 0;
    opt.price_num = _price_num;
    opt.cooldown = _cooldown;
}

void G_TechItem::to_opt(G_TechOpt &opt) noexcept {
    opt.type = _type;
    opt.cur = _info ? _info->id() : 0;
    opt.research = _research ? _research->id() : 0;
    opt.price_num = _price_num;
    timeval_t t = logic_time();
    opt.cooldown = _cooldown > t ? _cooldown - t : 0;
}

timeval_t G_TechItem::timer_handler(timeval_t now) {
    if (research_finish(now)) {
        DB_TechResearch msg;
        msg.req->id(the_player()->id());
        msg.req->value_opts = the_value_opts();
        msg.req->tech_opts = the_tech_opts();
        msg.req->soldier_value_opts = the_soldier_value_opts();
        the_context()->network()->call(msg);
        the_context()->commit();
    }
    return 0;
}

bool G_TechItem::research_finish(timeval_t now) noexcept {
    G_Player *player = the_player();
    close_timer();
    if (now < _cooldown) {
        timeval_t t = _cooldown - now;
        unsigned n = t / G_ParamMgr::instance()->tech_acc_time();
        if (t % G_ParamMgr::instance()->tech_acc_time()) {
            n++;
        }
        G_Money money = G_ParamMgr::instance()->tech_acc_price() * n;

        if (!player->has_money(money)) {
            return false;
        }
        player->use_money(money);
    }
    switch (_type) {
    case G_TECH_SOLDIER_UNLOCK:
        the_player()->corps()->add(_research->soldier());
        break;
    case G_TECH_SPEED:
        the_player()->mark_speed_dirty();
        break;
    }
    _price_num = 0;
    _cooldown = 0;
    _info = _research;
    _research = nullptr;
    the_data()->_tech_opts.emplace_back();
    to_opt(the_data()->_tech_opts.back());
    player->mark_task_dirty();
    return true;
}

/* G_Tech */
G_Tech::G_Tech() noexcept {
    for (unsigned i = 0; i < G_TECH_UNKNOWN; ++i) {
        _items[i] = object<G_TechItem>(i);
    }
}

bool G_Tech::research(const G_TechInfo *tech) noexcept {
    G_Player *player = the_player();
    G_TechItem *item = _items[tech->type()];

    if (tech->tech_limit()) {
        if (!item || tech->tech_limit() != item->_info) {
            return false;
        }
    }
    if (tech->level_limit()) {
        if (player->level() < tech->level_limit()->level()) {
            return false;
        }
    }
    if (tech->stage_limit()) {
        if (player->stage() < tech->stage_limit()->id()) {
            return false;
        }
    }

    if (item->_research) {
        if (item->_research != tech) {
            return false;
        }
    }
    else {
        item->_research = tech;
    }

    if (item->_price_num < tech->price_num()) {
        if (!player->has_money(tech->price())) {
            return false;
        }
        player->use_money(tech->price());
        item->_price_num++;
        the_data()->_tech_opts.emplace_back();
        item->to_opt(the_data()->_tech_opts.back());
        return true;
    }

    if (item->_cooldown) {
        return item->research_finish(logic_time());
    }

    if (!tech->cooldown()) {
        return item->research_finish(logic_time());
    }

    item->_cooldown = logic_time() + tech->cooldown();
    player->timer_mgr()->schedule(item, item->_cooldown);

    the_data()->_tech_opts.emplace_back();
    item->to_opt(the_data()->_tech_opts.back());
    return true;
}

void G_Tech::init(G_Player *player, DB_LoadRsp *msg) noexcept {

    for (auto &opt : msg->techs) {
        if (opt.type >= G_TECH_UNKNOWN) {
            continue;
        }
        const G_TechInfo *cur = nullptr;
        const G_TechInfo *research = nullptr;

        if (opt.cur) {
            cur = G_TechMgr::instance()->get_info(opt.cur);
            if (!cur) {
                continue;
            }
        }
        if (opt.research) {
            research = G_TechMgr::instance()->get_info(opt.research);
            if (!research) {
                continue;
            }
        }

        G_TechItem *item = _items[opt.type];
        item->_info = cur;
        item->_research = research;
        item->_price_num = opt.price_num;
        item->_cooldown = opt.cooldown;
        if (item->_research && item->_cooldown) {
            player->timer_mgr()->schedule(item, item->_cooldown);
        }
    }
}

void G_Tech::to_opt(obstack_vector<G_TechExpireOpt> &opts) noexcept {
    for (unsigned i = 0; i < G_TECH_UNKNOWN; ++i) {
        opts.emplace_back();
        _items[i]->to_opt(opts.back());
    }
}

void G_Tech::to_opt(obstack_vector<G_TechOpt> &opts) noexcept {
    for (unsigned i = 0; i < G_TECH_UNKNOWN; ++i) {
        opts.emplace_back();
        _items[i]->to_opt(opts.back());
    }
}

