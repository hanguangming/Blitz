#ifndef __LIBGAME_SHOP_H__
#define __LIBGAME_SHOP_H__

#include "game.h"
#include "object.h"
#include "item.h"
#include "money.h"
#include "soldier.h"

class G_ShopMgr;
class G_ShopItemInfo : public G_ObjectInfo {
    friend class G_ShopMgr;
public:
    G_ShopItemInfo() noexcept : _info() { }
    const G_ItemInfo *item() const noexcept {
        return _info;
    }
    const G_Money &price() const noexcept {
        return _price;
    }
    const G_SoldierInfo *soldier() const noexcept {
        return _soldier;
    }
private:
    G_Money _price;
    const G_ItemInfo *_info;
    const G_SoldierInfo *_soldier;
};

class G_ShopMgr : public G_ObjectInfoContainer<G_ShopItemInfo>, public singleton<G_ShopMgr> {
    typedef G_ObjectInfoContainer<G_ShopItemInfo> base_type;
public:
    using base_type::get_info;
    const G_ShopItemInfo *get_info(unsigned shopid, unsigned id) noexcept {
        return get_info((((uint64_t)shopid) << 32) | (uint64_t)id);
    }
    bool init();
};

#endif

