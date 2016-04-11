#include "stage.h"

G_StageInfo::G_StageInfo() noexcept
: _morders(1), _win_award(), _lose_award()
{ }

bool G_StageMgr::init() {
    _first = nullptr;

    auto tab_info = the_app->script()->read_table("the_stage_info");
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
        G_StageInfo *info = probe_info(id);
        info->_morders = tab_item->read_integer("tili", 1);
        unsigned award = tab_item->read_integer("rewardid", 0);
        info->_win_award = G_AwardMgr::instance()->get_info(award);
        if (!info->_win_award) {
            log_error("unknown award '%d'.", award);
            return false;
        }

        award = tab_item->read_integer("rewardid2", 0);
        info->_lose_award = G_AwardMgr::instance()->get_info(award);

        if (!_first) {
            _first = info;
        }
    }

    if (!_first) {
        log_error("empty stage config.");
        return false;
    }
    return true;
}

