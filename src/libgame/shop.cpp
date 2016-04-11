#include "shop.h"

bool G_ShopMgr::init() {
    auto tab_info = the_app->script()->read_table("the_shop_info");
    if (tab_info->is_nil()) {
        return false;
    }
    for (unsigned i = 1; ; ++i) {
        auto tab_item = tab_info->read_table(i);
        if (tab_item->is_nil()) {
            break;
        }
        unsigned id = tab_item->read_integer("id2", 0);
        G_Money price;
        unsigned shop_type = tab_item->read_integer("type1", 0);
        price.money = tab_item->read_integer("price1", 0);
        price.honor = tab_item->read_integer("price2", 0);
        price.recruit = tab_item->read_integer("price3", 0);
        price.coin = tab_item->read_integer("price4", 0);
        const G_SoldierInfo *soldier = nullptr;
        const G_ItemInfo *info = nullptr;
        unsigned is_item = tab_item->read_integer("type3", 0);
        if (!is_item) {
            soldier = G_SoldierMgr::instance()->get_info(id);
            if (!soldier) {
                log_error("unknown shop soldier, shop = %u, soldier = %u.", shop_type, id);
                return false;
            }
        }
        else {
            info = G_ItemMgr::instance()->get_info(id);
            if (!info) {
                log_error("unknown shop item, shop = %u, item = %u.", shop_type, id);
                return false;
            }
        }

        uint64_t shop_id;
        if (is_item) {
            shop_id = (((uint64_t)shop_type) << 32) | info->id();
        }
        else {
            shop_id = (((uint64_t)shop_type) << 32) | soldier->id();
        }
        G_ShopItemInfo *shop_info = probe_info(shop_id);
        if (shop_info->_info) {
            log_error("dup shop item, shop = %u, item = %u.", shop_type, id);
            return false;
        }

        shop_info->_price = price;
        shop_info->_info = info;
        shop_info->_soldier = soldier;
    }
    return true;
}


