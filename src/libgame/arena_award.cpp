#include "arena_award.h"

G_ArenaAwardInfo::G_ArenaAwardInfo() noexcept
: _award()
{ }


bool G_ArenaAwardMgr::init() {
    auto tab_info = the_app->script()->read_table("the_arena_award_info");
    if (tab_info->is_nil()) {
        return false;
    }
    for (unsigned i = 1; ; ++i) {
        auto tab_item = tab_info->read_table(i);
        if (tab_item->is_nil()) {
            break;
        }

        int rank = tab_item->read_integer("Rank", -1);
        if (rank < 0) {
            continue;
        }

        G_ArenaAwardInfo *info = probe_info(rank);
        unsigned award = tab_item->read_integer("rewardid", 0);
        info->_award = G_AwardMgr::instance()->get_info(award);
        if (!info->_award) {
            log_error("unknown award id '%d'.", award);
            return false;
        }
    }
    return true;
}
