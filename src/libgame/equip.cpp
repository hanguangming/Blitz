#include "equip.h"

/* G_EquipInfo */
G_EquipInfo::G_EquipInfo() noexcept 
: _attack(),
  _attack_speed(),
  _hp()
{ }

/* G_EquipMgr */
bool G_EquipMgr::init() {
    auto tab_info = the_app->script()->read_table("the_equip_info");
    if (tab_info->is_nil()) {
        return false;
    }
    for (unsigned i = 1; ; ++i) {
        auto tab_item = tab_info->read_table(i);
        if (tab_item->is_nil()) {
            break;
        }

        unsigned id = tab_item->read_integer("id", 0);
        unsigned level = tab_item->read_integer("lv", 0);

        G_EquipInfo *info = probe_info((((uint64_t)id) << 32) | level);
        info->_attack = tab_item->read_integer("ap", 0);
        info->_hp = tab_item->read_integer("hp", 0);
        info->_attack_speed = tab_item->read_integer("as", 0);
    }
    return true;
}

/* G_EquipSuitInfo */
G_EquipSuitInfo::G_EquipSuitInfo() noexcept 
: _attack(),
  _hp(),
  _attack_speed()
{ }


/* G_EquipSuitMgr */
bool G_EquipSuitMgr::init() {
    auto tab_info = the_app->script()->read_table("the_equip_suit_info");
    if (tab_info->is_nil()) {
        return false;
    }

    probe_info(0);
    for (unsigned i = 1; ; ++i) {
        auto tab_item = tab_info->read_table(i);
        if (tab_item->is_nil()) {
            break;
        }

        unsigned id = tab_item->read_integer("starnum", 0);

        G_EquipSuitInfo *info = probe_info(id);
        info->_attack = tab_item->read_integer("attbuff", 0);
        info->_hp = tab_item->read_integer("hpbuff", 0);
        info->_attack_speed = tab_item->read_integer("asbuff", 0);
    }
    return true;
}

/* G_EquipUpMgr */
bool G_EquipUpMgr::init() {
    auto tab_info = the_app->script()->read_table("the_equipup_info");
    if (tab_info->is_nil()) {
        return false;
    }
    for (unsigned i = 1; ; ++i) {
        auto tab_item = tab_info->read_table(i);
        if (tab_item->is_nil()) {
            break;
        }

        unsigned type = tab_item->read_integer("type", 0);
        unsigned level = tab_item->read_integer("lv", 0);
        if (!type) {
            continue;
        }

        G_EquipUpInfo *info = probe_info((((uint64_t)type) << 32) | level);
        info->_price.coin = tab_item->read_integer("cost", 0);
    }
    return true;
}


