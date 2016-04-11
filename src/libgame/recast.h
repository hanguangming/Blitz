#ifndef __LIBGAME_RECAST_H__
#define __LIBGAME_RECAST_H__

#include "object.h"
#include "item.h"
#include "money.h"

class G_RecastInfo : public G_ObjectInfo {
    friend class G_RecastMgr;
public:
    G_RecastInfo() noexcept
    : _source(), _target(), _use_item(), _use_count()
    { }

    const G_ItemInfo *source() const noexcept {
        return _source;
    }

    const G_ItemInfo *target() const noexcept {
        return _target;
    }

    const G_ItemInfo *use_item() const noexcept {
        return _use_item;
    }

    unsigned use_count() const noexcept {
        return _use_count;
    }
    const G_Money &price() const noexcept {
        return _price;
    }
private:
    const G_ItemInfo *_source;
    const G_ItemInfo *_target;
    const G_ItemInfo *_use_item;
    unsigned _use_count;
    G_Money _price;
};

class G_RecastMgr : public G_ObjectInfoContainer<G_RecastInfo>, public singleton<G_RecastMgr> {
public:
    using G_ObjectInfoContainer<G_RecastInfo>::get_info;
    bool init();
};

#endif

