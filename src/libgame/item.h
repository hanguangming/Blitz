#ifndef __LIBGAME_ITEM_H__
#define __LIBGAME_ITEM_H__

#include "object.h"
#include "money.h"

class G_ItemMgr;

class G_ItemInfo : public G_ObjectInfo {
    friend class G_ItemMgr;
public:
    G_ItemInfo() : _type(-1) { }

    unsigned type() const noexcept {
        return _type;
    }
    unsigned quality() const noexcept {
        return _quality;
    }
    const G_Money &sell() const noexcept {
        return _sell;
    }
    bool is_equip() const noexcept {
        return _type >= G_ITYPE_EQUIP_BEGIN && _type <= G_ITYPE_EQUIP_END;
    }
    unsigned level_limit() const noexcept {
        return _level_limit;
    }
    unsigned pile_limit() const noexcept {
        return _pile_limit;
    }
    unsigned value() const noexcept {
        return _value;
    }
    unsigned value2() const noexcept {
        return _value2;
    }
    unsigned star() const noexcept {
        return _star;
    }
private:
    int _type;
    unsigned _quality;
    G_Money _sell;
    unsigned _level_limit;
    unsigned _pile_limit;
    unsigned _value;
    unsigned _value2;
    unsigned _star;
};

class G_ItemMgr : public G_ObjectInfoContainer<G_ItemInfo>, public singleton<G_ItemMgr> {
    typedef G_ObjectInfoContainer<G_ItemInfo> base_type;
public:
    using base_type::get_info;
    bool init();

};

#endif

