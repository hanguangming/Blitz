#include "soldier.h"
#include "player.h"

const G_SoldierInfo *G_SoldierMakeInfo::get(G_Player *player) const noexcept {
    size_t size = _soldiers.size();

    while (size) {
        unsigned index = player->rand(size);
        const G_SoldierInfo *soldier = _soldiers[index];
        if (index != (size - 1)) {
            const G_SoldierInfo *tmp = _soldiers[size - 1];
            _soldiers[size - 1] = _soldiers[index];
            _soldiers[index] = tmp;
        }
        if (!player->corps()->get(soldier)) {
            return soldier;
        }
        size--;
    }
    return nullptr;
}

bool G_SoldierMgr::init() {
    auto tab_info = the_app->script()->read_table("the_soldier_info");
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

        int type2 = tab_item->read_integer("type2", 0);
        if (type2 != G_TYPE_HERO && type2 != G_TYPE_SOLDIER) {
            log_error("unknown soldier type '%d'.", type2);
        }
        G_SoldierInfo *info = probe_info(id);
        info->_is_hero = (type2 == G_TYPE_HERO);
        info->_quality = tab_item->read_integer("qua", 0);
        info->_star = tab_item->read_integer("star", 0);
        info->_hp = tab_item->read_integer("hp", 0);
        info->_attack = tab_item->read_integer("att", 0);
        info->_attack_speed = tab_item->read_integer("as", 0);
        info->_hp_param = tab_item->read_integer("hpup", 0);
        info->_attack_param = tab_item->read_integer("attup", 0);
        info->_people = tab_item->read_integer("peo", 0);
        if (!info->_is_hero && !info->_people) {
            log_error("bad soldier people.");
            return false;
        }
    }
    return true;
}

bool G_SoldierMakeMgr::init() {
    auto tab_info = the_app->script()->read_table("the_soldier_make_info");
    if (tab_info->is_nil()) {
        return false;
    }
    G_SoldierMakeInfo *info = nullptr;
    for (unsigned i = 1; ; ++i) {
        auto tab_item = tab_info->read_table(i);
        if (tab_item->is_nil()) {
            break;
        }

        int item_id = tab_item->read_integer("itemid", -1);
        if (item_id < 0) {
            if (!info) {
                continue;
            }
        }
        else {
            const G_ItemInfo *item_info = G_ItemMgr::instance()->get_info(item_id);
            if (!item_info) {
                log_error("unknown item id '%d'.", item_id);
                return false;
            }
            info = probe_info(item_id);
            if (info->_use_item) {
                log_error("dup item id '%d'.", item_id);
                return false;
            }
            info->_use_item = item_info;
            info->_use_count = tab_item->read_integer("itemnumber", 0);
            if (!info->_use_count) {
                log_error("bad use item count.");
                return false;
            }
        }

        int soldier_id = tab_item->read_integer("heroid", -1);
        if (soldier_id < 0) {
            continue;
        }

        const G_SoldierInfo *soldier_info = G_SoldierMgr::instance()->get_info(soldier_id);
        if (!soldier_info) {
            log_error("unknown soldier id '%d'.", soldier_id);
            return false;
        }

        info->_soldiers.push_back(soldier_info);
    }
    return true;
}



