#ifndef __LIBGAME_FORGE_H__
#define __LIBGAME_FORGE_H__

#include "game.h"
#include "item.h"
#include "money.h"

class G_Player;
class DB_LoadRsp;
class G_Forge;

class G_ForgeItemInfo : public Object {
    friend class G_ForgeMgr;
public:
    G_ForgeItemInfo() noexcept : _item() { }

    const G_Money &price() const noexcept {
        return _price;
    }

    const G_ItemInfo *item() const noexcept {
        return _item;
    }
private:
    const G_ItemInfo *_item;
    G_Money _price;
};


class G_ForgeInfo : public Object {
    friend class G_ForgeMgr;
    friend class G_Forge;
public:
    const G_ItemInfo *use_item() const noexcept {
        return _item;
    }
    unsigned use_count() const noexcept {
        return _count;
    }
private:
    const G_ItemInfo *_item;
    unsigned _count;
    ProbContainer<G_ForgeItemInfo> _groups[G_FORGE_NUM];
};

class G_ForgeMgr : public Object, public singleton<G_ForgeMgr> {
    friend class G_Forge;
public:
    bool init();

    const G_ForgeInfo *get_forge(unsigned id) const noexcept {
        assert(id < G_FORGE_UNKNOWN);
        return std::addressof(_infos[id]);
    }
private:
    G_ForgeInfo _infos[G_FORGE_UNKNOWN];
};

class G_ForgeItem {
    friend class G_Forge;
public:
    G_ForgeItem() : _info(), _used(false) { }
    G_ForgeItem(const G_ItemInfo *info, bool used) : _info(info), _used(used) { }
    bool used() const noexcept {
        return _used;
    }
    void use() noexcept {
        _used = true;
    }
    const G_ItemInfo *info() const noexcept {
        return _info;
    }
private:
    const G_ItemInfo *_info;
    bool _used;
};

class G_Forge : public Object {
public:
    void exec(unsigned type);
    void init(G_Player *player, DB_LoadRsp *msg);
    const std::array<G_ForgeItem, G_FORGE_NUM> &items() const noexcept {
        return _items;
    }
public:
    std::array<G_ForgeItem, G_FORGE_NUM> _items;
};

#endif

