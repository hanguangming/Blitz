#include "chat.h"

/* G_ChatInfo */
G_ChatInfo::G_ChatInfo() noexcept : _cooldown()
{ }

/* G_ChatMgr */
bool G_ChatMgr::init() {
    auto tab_info = the_app->script()->read_table("the_chat_info");
    if (tab_info->is_nil()) {
        return false;
    }
    for (unsigned i = 1; ; ++i) {
        auto tab_item = tab_info->read_table(i);
        if (tab_item->is_nil()) {
            break;
        }

        unsigned id = tab_item->read_integer("id", 0);
        if (id <= 0) {
            continue;
        }

        id--;
        if (id >= G_CHAT_CHANNEL_UNKNOWN) {
            log_error("bad chat channel id '%d'.", id + 1);
            return false;
        }
        
        G_ChatInfo *info = _infos[id];
        info->_cooldown = tab_item->read_integer("time", 0) * 1000;
        info->_price.money = tab_item->read_integer("itemnumber", 0);
    }
    return true;
}

/* G_ChatCooldown */
G_ChatCooldown::G_ChatCooldown() noexcept {
    memset(_times, 0, sizeof(_times));
}

