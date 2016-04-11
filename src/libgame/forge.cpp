#include "forge.h"
#include "dbsvr/db_login.h"
#include "player.h"
#include "cooldown.h"

/* G_ForgeMgr */
bool G_ForgeMgr::init() {
    auto tab_info = the_app->script()->read_table("the_forge_info");
    if (tab_info->is_nil()) {
        return false;
    }

    for (unsigned i = 1; ; ++i) {
        auto tab_forge = tab_info->read_table(i);
        if (tab_forge->is_nil()) {
            break;
        }

        unsigned forge_type = tab_forge->read_integer("shoplv", -1);
        unsigned use_item = tab_forge->read_integer("id", 0);
        unsigned use_num = tab_forge->read_integer("number", 0);
        unsigned cooldown = tab_forge->read_integer("time", 0);

        if (forge_type >= G_FORGE_UNKNOWN) {
            log_error("unknown forge type at forge.csv.");
            return false;
        }

        const G_ItemInfo *item_info = nullptr;
        if (forge_type) {
            item_info = G_ItemMgr::instance()->get_info(use_item);
            if (!item_info) {
                log_error("unknown forge use item '%d' at forge.csv.", use_item);
                return false;
            }
        }

        _infos[forge_type]._item = item_info;
        _infos[forge_type]._count = use_num;
        unsigned cd = G_CD_UNKNOWN;
        switch (forge_type) {
        case G_FORGE_LOW:
            cd = G_CD_FORGE_LOW;
            break;
        case G_FORGE_MIDDLE:
            cd = G_CD_FORGE_MIDDLE;
            break;
        case G_FORGE_HIGH:
            cd = G_CD_FORGE_HIGH;
            break;
        }

        if (cd != G_CD_UNKNOWN) {
            G_CooldownMgr::instance()->set(cd, cooldown * 1000);
        }
    }

    auto tab_items = the_app->script()->read_table("the_forge_items_info");
    if (tab_info->is_nil()) {
        return false;
    }

    for (unsigned i = 1; ; ++i) {
        auto tab_item = tab_items->read_table(i);
        if (tab_item->is_nil()) {
            break;
        }
        unsigned forge_type = tab_item->read_integer("shoplv", -1);
        if (forge_type >= G_FORGE_UNKNOWN) {
            log_error("unknown forge type at forge_item.csv.");
            return false;
        }

        unsigned item_id = tab_item->read_integer("goodsid", 0);
        unsigned prob = tab_item->read_integer("rand", 0);
        unsigned price = tab_item->read_integer("price", 0);
        unsigned group_num = tab_item->read_integer("group", 0);
        group_num--;
        if (group_num >= G_FORGE_NUM) {
            log_error("bad forge group at forge_item.csv.");
            return false;
        }
        G_ForgeInfo &forge_info = _infos[forge_type];
        const G_ItemInfo *item_info = G_ItemMgr::instance()->get_info(item_id);
        if (!item_info) {
            log_error("unknown forge item id '%d' at forge_item.csv", item_id);
            return false;
        }

        auto &group = forge_info._groups[group_num];
        object<G_ForgeItemInfo> info;
        info->_item = item_info;
        info->_price.coin = price;
        group.push(prob, info);
    }
    return true;
}

/* G_Forge */
void G_Forge::init(G_Player *player, DB_LoadRsp *msg) {
    for (auto &opt : msg->forge) {
        if (opt.index >= G_FORGE_NUM) {
            continue;
        }
        const G_ItemInfo *info = G_ItemMgr::instance()->get_info(opt.id);
        _items[opt.index]._used = opt.used;
        _items[opt.index]._info = info;
    }
}

void G_Forge::exec(unsigned type) {
    assert(type < G_FORGE_UNKNOWN);
    G_ForgeInfo &forge_info = G_ForgeMgr::instance()->_infos[type];
    G_Player *player = the_player();

    if (!type) {
        unsigned i = 0;
        for (auto &prob : forge_info._groups[0].probs()) {
            if (i >= G_FORGE_NUM) {
                break;
            }
            auto &item = _items[i++];
            item._info = prob.object()->item();
            item._used = false;
        }
        for (; i < G_FORGE_NUM; ++i) {
            auto &item = _items[i];
            item._info = nullptr;
            item._used = false;
        }
    }
    else {
        for (unsigned i = 0; i < G_FORGE_NUM; ++i) {
            unsigned n = player->rand(G_FORGE_NUM);
            auto &group = forge_info._groups[n];
            ptr<G_ForgeItemInfo> info = group.get(player->rand());
            auto &item = _items[i];
            item._info = info ? info->item() : nullptr;
            item._used = false;
        }
    }
}

