#include "level.h"

bool G_LevelMgr::init() {
    auto tab_info = the_app->script()->read_table("the_level_info");
    if (tab_info->is_nil()) {
        return false;
    }
    _max_level = nullptr;
    for (unsigned i = 1; ; ++i) {
        auto tab_item = tab_info->read_table(i);
        if (tab_item->is_nil()) {
            break;
        }

        unsigned lv = tab_item->read_integer("lv", 0);
        if (!lv) {
            continue;
        }
        if (lv != i) {
            log_error("bad level number '%d'.", lv);
            return false;
        }

        G_LevelInfo *level_info = probe_info(lv);
        level_info->_player_exp = tab_item->read_integer("exp1", 0);
        level_info->_level = lv;
        level_info->_train_low_exp = tab_item->read_integer("tra1", 0);
        level_info->_train_middle_exp = tab_item->read_integer("tra2", 0);
        level_info->_train_high_exp = tab_item->read_integer("tra3", 0);
        level_info->_train_low_price.coin = tab_item->read_integer("cost1", 0);
        level_info->_train_middle_price.coin = tab_item->read_integer("cost2", 0);
        level_info->_soldier_exp = tab_item->read_integer("exp2", 0);
        level_info->_speedup_exp = tab_item->read_integer("up", 0);
        if (lv != 1) {
            _max_level->_next_level = level_info;
        }
        _max_level = level_info;
    }
    return true;
}

