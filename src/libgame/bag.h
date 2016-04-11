#ifndef __LIBGAME_BAG_H__
#define __LIBGAME_BAG_H__

#include <set>
#include "item.h"
#include "libgame/g_bag.h"

class G_Player;
class G_Bag;
class G_BagItem;

class DB_LoadRsp;

struct G_BagItemOwner {
    virtual void on_item_changed(G_BagItem *item) noexcept = 0;
};

class G_BagItem : public G_Object<unsigned, G_ItemInfo> {
    friend class G_Bag;
public:
    G_BagItem() noexcept : G_Object(), _owner(nullptr), _count() { }

    bool used() const noexcept {
        return _owner != nullptr;
    }
    void used(G_BagItemOwner *owner) noexcept;
    void init_owner(G_BagItemOwner *owner) noexcept {
        _owner = owner;
    }
    unsigned count() const noexcept {
        return _count;
    }
    unsigned value() const noexcept {
        return _value;
    }
    void value(unsigned v) noexcept;

    unsigned score() const noexcept {
        if (info()->is_equip()) {
            return info()->quality() * _value * 10;
        }
        return 0;
    }
    using G_Object<unsigned, G_ItemInfo>::info;
    void info(const G_ItemInfo *new_info) noexcept;
private:
    G_BagItemOwner *_owner;
    unsigned _count;
    unsigned _value;
    clist_entry _entry;
};

class G_Bag : public G_ObjectContainer<G_BagItem> {
    friend class G_BagItem;
public:
    const container_type &items() const noexcept {
        return objects();
    }
    void init(G_Player *player, DB_LoadRsp *msg);

    bool has_item(const G_ItemInfo *info, unsigned count);
    void put_item(const G_ItemInfo *info, size_t count);
    bool remove_item(unsigned id);
    bool remove_item(const G_ItemInfo *info, size_t count);
    G_BagItem *get_item(unsigned id);
private:
    static void add_opt(const G_BagItem *item) noexcept;
private:
    typedef gx_list(G_BagItem, _entry) ItemList;
    struct ItemInfo : Object {
        size_t count() const;

        const G_ItemInfo *_info;
        ItemList _list;
    };
    struct ItemInfoCmp {
        bool operator()(const ItemInfo *lhs, const ItemInfo *rhs) const noexcept {
            return lhs->_info < rhs->_info;
        }
    };

    ItemInfo *get_info(const G_ItemInfo *info) noexcept;
    ItemInfo *probe_info(const G_ItemInfo *info) noexcept;
    void update_item_info(G_BagItem *item, const G_ItemInfo *info) noexcept;
private:
    std::set<ptr<ItemInfo>, ItemInfoCmp> _infos;
};

#endif

