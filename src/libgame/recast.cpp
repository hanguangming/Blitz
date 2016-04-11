#include "recast.h"

bool G_RecastMgr::init() {
    auto tab_info = the_app->script()->read_table("the_recast_info");
    if (tab_info->is_nil()) {
        return false;
    }
    for (unsigned i = 1; ; ++i) {
        auto tab_item = tab_info->read_table(i);
        if (tab_item->is_nil()) {
            break;
        }
        unsigned source_id = tab_item->read_integer("itemid", 0);
        if (!source_id) {
            continue;
        }

        G_RecastInfo *info = probe_info(source_id);
        if (info->_source) {
            log_error("dup source item id '%u'.", source_id);
            return false;
        }

        unsigned target_id = tab_item->read_integer("recasttarget", 0);
        unsigned use_id = tab_item->read_integer("recastcost", 0);

        info->_target = G_ItemMgr::instance()->get_info(target_id);
        if (!info->_target) {
            log_error("unknown recast target id '%u'.", target_id);
            return false;
        }

        info->_use_item = G_ItemMgr::instance()->get_info(use_id);
        if (!info->_use_item) {
            log_error("unknown recast use item id '%u'.", use_id);
            return false;
        }

        info->_use_count = tab_item->read_integer("costnumber", 0);
        if (!info->_use_count) {
            log_error("bad recast use item number.");
            return false;
        }
        info->_price.coin = tab_item->read_integer("moneycost", 0);
    }
    return true;
}


