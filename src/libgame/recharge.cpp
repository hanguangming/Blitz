#include "recharge.h"

bool G_RechargeMgr::init() {
    auto tab_info = the_app->script()->read_table("the_recharge_info");
    if (tab_info->is_nil()) {
        return false;
    }
    for (unsigned i = 1; ; ++i) {
        auto tab_item = tab_info->read_table(i);
        if (tab_item->is_nil()) {
            break;
        }

        unsigned id = tab_item->read_integer("id", 0);
        if (!id) {
            continue;
        }
        G_RechargeInfo *info = probe_info(id);
        info->_platform_money = tab_item->read_integer("rmb", 0);
        info->_game_money = tab_item->read_integer("yuanbao", 0) + tab_item->read_integer("addyuanbao", 0);
        info->_exp = tab_item->read_integer("vipexp", 0);
    }
    return true;
}

