#include "vip.h"

bool G_VipMgr::init() {
    auto tab_info = the_app->script()->read_table("the_vip_info");
    if (tab_info->is_nil()) {
        return false;
    }
    _max_level = nullptr;
    for (unsigned i = 1; ; ++i) {
        auto tab_item = tab_info->read_table(i);
        if (tab_item->is_nil()) {
            break;
        }

        int lv = tab_item->read_integer("viplv", -1);
        if (lv < 0) {
            continue;
        }
        if ((unsigned)lv != i - 1) {
            log_error("bad level number '%d'.", lv);
            return false;
        }

        G_VipInfo *level_info = probe_info(lv);
        level_info->_exp = tab_item->read_integer("vipexp", 0);
        level_info->_level = lv;
        level_info->_forge_high = tab_item->read_integer("equipget", 0);
        level_info->_hero_limit = tab_item->read_integer("heromax", 0);
        level_info->_train_limit = tab_item->read_integer("trainnum", 0);
        level_info->_recruit_high = tab_item->read_integer("vipget", 0);
        level_info->_train_high = tab_item->read_integer("viptrain", 0);
        level_info->_morders_limit = tab_item->read_integer("tilimax", 0);
        level_info->_stage_batch = tab_item->read_integer("saodang", 0);
        
        if (lv) {
            _max_level->_next = level_info;
        }
        _max_level = level_info;
    }
    return _max_level != nullptr;
}


