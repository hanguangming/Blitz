#include "soldierup.h"

bool G_SoldierUpMgr::init() {
    auto tab_info = the_app->script()->read_table("the_soldierup_info");
    if (tab_info->is_nil()) {
        return false;
    }
    for (unsigned i = 1; ; ++i) {
        auto tab_item = tab_info->read_table(i);
        if (tab_item->is_nil()) {
            break;
        }

        int soldier_id = tab_item->read_integer("id", -1);
        if (soldier_id < 0) {
            continue;
        }
        G_SoldierUpInfo *info = probe_info(soldier_id);
        if (info->_soldier) {
            log_error("dup soldier id '%d'.", soldier_id);
            return false;
        }
        info->_soldier = G_SoldierMgr::instance()->get_info(soldier_id);
        if (!info->_soldier) {
            log_error("unknown soldier id '%d'.", soldier_id);
            return false;
        }
        unsigned target_id = tab_item->read_integer("newid", 0);
        info->_target = G_SoldierMgr::instance()->get_info(target_id);
        info->_use_count = tab_item->read_integer("itemnumber", 0);
        if (info->_soldier->is_hero()) {
            info->_use_quality = tab_item->read_integer("costtype", 0);
        }
        else {
            unsigned item_id = tab_item->read_integer("costtype", 0);
            info->_use_item = G_ItemMgr::instance()->get_info(item_id);
        }
        if (info->_soldier == info->_target) {
            log_error("bad soldierup info.");
            return false;
        }
        info->_price.coin = tab_item->read_integer("moneycost", 0);
    }
    return true;
}


