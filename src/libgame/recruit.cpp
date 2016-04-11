#include "recruit.h"
#include "player.h"
#include "cooldown.h"

void G_RecruitSoldiersInfo::get(G_Player *player, unsigned count, std::vector<const G_SoldierInfo*> &result) const noexcept {
    size_t size = _soldiers.size();
    while (size && count) {
        unsigned index = player->rand(size);
        const G_SoldierInfo *soldier = _soldiers[index];
        if (index != (size - 1)) {
            const G_SoldierInfo *tmp = _soldiers[size - 1];
            _soldiers[size - 1] = _soldiers[index];
            _soldiers[index] = tmp;
        }
        if (!player->corps()->get(soldier)) {
            result.push_back(soldier);
            count--;
        }
        size--;
    }
}

bool G_RecuritSoldiersMgr::init() {
    auto tab_info = the_app->script()->read_table("the_recurit_soldier_info");
    if (tab_info->is_nil()) {
        return false;
    }
    for (unsigned i = 1; ; ++i) {
        auto tab_item = tab_info->read_table(i);
        if (tab_item->is_nil()) {
            break;
        }

        int herotype = tab_item->read_integer("herotype", -1);
        if (herotype < 0) {
            continue;
        }
        unsigned id = tab_item->read_integer("heroid", 0);
        const G_SoldierInfo *soldier = G_SoldierMgr::instance()->get_info(id);
        if (!soldier) {
            log_error("unknown soldier id '%d'.", id);
            return false;
        }
        auto info = probe_info(herotype);
        info->_soldiers.push_back(soldier);
    }
    return true;
}

bool G_RecruitMgr::init() {
    if (!_soldiers.init()) {
        return false;
    }

    auto tab_info = the_app->script()->read_table("the_recurit_info");
    if (tab_info->is_nil()) {
        return false;
    }
    for (unsigned i = 1; ; ++i) {
        auto tab_item = tab_info->read_table(i);
        if (tab_item->is_nil()) {
            break;
        }

        int id = tab_item->read_integer("shoplv", -1);
        if (id < 0) {
            continue;
        }

        G_RecruitInfo *info = probe_info(id);
        if (info->_use_item) {
            log_error("dup recruit id '%d'.", id);
            return false;
        }

        switch (id) {
        case G_RECRUIT_NEW:
            break;
        case G_RECRUIT_LOW:
            G_CooldownMgr::instance()->set(G_CD_RECRUIT_LOW, tab_item->read_integer("time", 0) * 1000);
            break;
        case G_RECRUIT_MIDDLE:
            G_CooldownMgr::instance()->set(G_CD_RECRUIT_MIDDLE, tab_item->read_integer("time", 0) * 1000);
            break;
        case G_RECRUIT_HIGH:
            G_CooldownMgr::instance()->set(G_CD_RECRUIT_HIGH, tab_item->read_integer("time", 0) * 1000);
            break;
        default:
            log_error("bad recruit id '%d'.", id);
            return false;
        }

        if (id) {
            unsigned item_id = tab_item->read_integer("id", -1);
            info->_use_item = G_ItemMgr::instance()->get_info(item_id);
            if (!info->_use_item) {
                log_error("unknown use item id '%d'.", item_id);
                return false;
            }
            info->_use_count = tab_item->read_integer("number", 0);
            if (!info->_use_count) {
                log_error("bad use item count.");
                return false;
            }
        }
        info->_recruit_value = tab_item->read_integer("shopval", 0);
        info->_refresh_count = tab_item->read_integer("heronumber", 0);
    }

    auto refresh_tab_info = the_app->script()->read_table("the_recruit_refresh_info");
    if (refresh_tab_info->is_nil()) {
        return false;
    }
    for (unsigned i = 1; ; ++i) {
        auto tab_item = refresh_tab_info->read_table(i);
        if (tab_item->is_nil()) {
            break;
        }

        int recruit_id = tab_item->read_integer("shoplv", -1);
        if (recruit_id < 0) {
            continue;
        }

        G_RecruitInfo *info = const_cast<G_RecruitInfo*>(get_info(recruit_id));
        if (!info) {
            log_error("unknown recruit id '%d'.", recruit_id);
            return 1;
        }

        unsigned soldier_group = tab_item->read_integer("type", 0);
        const G_RecruitSoldiersInfo *soldiers_info = _soldiers.get_info(soldier_group);
        if (!tab_item->read_integer("tag", 0)) {
            info->_default = soldiers_info;
            continue;
        }
        unsigned prob = tab_item->read_integer("rand", 0);
        if (!prob) {
            continue;
        }
        object<G_RecuritRefreshInfo> refresh_info;
        refresh_info->_soldiers = soldiers_info;
        refresh_info->_level_limit = tab_item->read_integer("level", 0);
        info->_probs.push(prob, refresh_info);
    }

    return true;
}

bool G_RecruitMgr::exec(G_Player *player, unsigned type) {
    const G_RecruitInfo *info = get_info(type);
    if (!info) {
        return false;
    }

    unsigned cd = G_CD_UNKNOWN;
    switch (type) {
    case G_RECRUIT_NEW:
        break;
    case G_RECRUIT_LOW:
        cd = G_CD_RECRUIT_LOW;
        break;
    case G_RECRUIT_MIDDLE:
        cd = G_CD_RECRUIT_MIDDLE;
        break;
    case G_RECRUIT_HIGH:
        if (!player->vip()->recruit_high()) {
            return false;
        }
        cd = G_CD_RECRUIT_HIGH;
        break;
    default:
        return false;
    }

    bool use_item = false;
    if (cd != G_CD_UNKNOWN) {
        if (player->cooldown()->get(cd)) {
            if (info->_use_count && !player->bag()->has_item(info->_use_item, info->_use_count)) {
                return false;
            }
            use_item = true;
        }
    }

    if (!info->_refresh_count) {
        return true;
    }

    std::vector<const G_SoldierInfo*> result;
    const G_RecuritRefreshInfo *refresh_info = info->_probs.get(player->rand());
    if (refresh_info) {
        log_debug("recurite refresh rare soldier '%d'.", (int)refresh_info->_soldiers->id());
        if (player->level() >= refresh_info->_level_limit) {
            refresh_info->_soldiers->get(player, 1, result);
        }
    }

    if (info->_refresh_count > result.size()) {
        if (info->_default) {
            info->_default->get(player, info->_refresh_count - result.size(), result);
        }
    }

    unsigned i = G_VALUE_RECRUIT_BEGIN;
    for (const G_SoldierInfo *soldier : result) {
        if (i > G_VALUE_RECRUIT_END) {
            break;
        }
        player->_values.set(i++, soldier->id());
    }
    while (i <= G_VALUE_RECRUIT_END) {
        player->_values.set(i++, 0);
    }

    if (use_item) {
        player->bag()->remove_item(info->_use_item, info->_use_count);
    }

    player->_values.add(G_VALUE_RECRUIT, info->_recruit_value);
    if (cd != G_CD_UNKNOWN && !use_item) {
        player->cooldown()->set(cd);
    }
    return true;
}

