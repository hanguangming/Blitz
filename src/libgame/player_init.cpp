#include "player_init.h"
#include "libgame/g_defines.h"

G_PlayerInitMgr::G_PlayerInitMgr() noexcept 
: coin(), money()
{ }

bool G_PlayerInitMgr::init() {
    auto tab_info = the_app->script()->read_table("the_player_init_info");
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

        unsigned value = tab_item->read_integer("id1", 0);
        switch (id) {
        case G_PLAYER_INIT_MONEY:
            money = value;
            break;
        case G_PLAYER_INIT_COIN:
            coin = value;
            break;
        case G_PLAYER_INIT_ITEM:
            items.push_back(value);
            break;
        case G_PLAYER_INIT_SOLDIER:
            soldiers.push_back(value);
            break;
        default:
            log_error("unknown player init type '%d'.", id);
            return false;
        }
    }
    return true;
}

