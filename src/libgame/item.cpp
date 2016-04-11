#include "item.h"

/* G_ItemMgr */
bool G_ItemMgr::init() {
    for (unsigned i = 1; i < G_ITEM_UNKNOWN; ++i) {
        probe_info(i);
    }
    auto tab_info = the_app->script()->read_table("the_items_info");
    if (tab_info->is_nil()) {
        return false;
    }
    for (unsigned i = 1; ; ++i) {
        auto tab_item = tab_info->read_table(i);
        if (tab_item->is_nil()) {
            break;
        }
        int id = tab_item->read_integer("id", -1);
        int type = tab_item->read_integer("subtype", -1);
        if (id < 0 || type < 0) {
            continue;
        }

        G_ItemInfo *info = probe_info((uint64_t)id);
        if (info->_type >= 0) {
            log_error("load item info failed, dup item id '%d'.", id);
            return false;
        }
        info->_type = type;
        info->_quality = tab_item->read_integer("quality", 0);
        info->_level_limit = tab_item->read_integer("lv", 0);
        info->_sell.coin = tab_item->read_integer("sell", 0);
        info->_pile_limit = tab_item->read_integer("number", 0);
        info->_value = tab_item->read_integer("val1", 0);
        info->_value2 = tab_item->read_integer("val2", 0);
        info->_star = tab_item->read_integer("star", 0);
    }
    return true;
}


