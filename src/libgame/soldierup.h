#ifndef __LIBGAME_SOLDIERUP_H__
#define __LIBGAME_SOLDIERUP_H__

#include "object.h"
#include "soldier.h"
#include "item.h"
#include "money.h"

class G_SoldierUpInfo : public G_ObjectInfo {
    friend class G_SoldierUpMgr;
public:
    G_SoldierUpInfo() noexcept
    : _soldier(), _use_count(), _use_quality(), _use_item()
    { }

    const G_SoldierInfo *soldier() const noexcept {
        return _soldier;
    }
    const G_SoldierInfo *target() const noexcept {
        return _target;
    }
    unsigned use_count() const noexcept {
        return _use_count;
    }
    unsigned use_quality() const noexcept {
        return _use_quality;
    }
    const G_ItemInfo *use_item() const noexcept {
        return _use_item;
    }
    const G_Money &price() const noexcept {
        return _price;
    }
private:
    const G_SoldierInfo *_soldier;
    const G_SoldierInfo *_target;
    unsigned _use_count;
    unsigned _use_quality;
    const G_ItemInfo *_use_item;
    G_Money _price;
};

class G_SoldierUpMgr : public G_ObjectInfoContainer<G_SoldierUpInfo>, public singleton<G_SoldierUpMgr> {
public:
    using G_ObjectInfoContainer<G_SoldierUpInfo>::get_info;
    bool init();
};

#endif

