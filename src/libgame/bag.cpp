#include "bag.h"
#include "player.h"
#include "dbsvr/db_login.h"
#include "context.h"

/* G_BagItem */
void G_BagItem::value(unsigned v) noexcept {
    if (_value != v) {
        bool is_equip = _info->is_equip() && used();
        if (is_equip) {
            the_player()->update_score(-score());
        }
        _value = v;
        G_Bag::add_opt(this);
        if (is_equip) {
            the_player()->update_score(score());
        }
        if (_owner) {
            _owner->on_item_changed(this);
        }
    }
}

void G_BagItem::info(const G_ItemInfo *new_info) noexcept {
    if (_info != new_info) {
        the_player()->bag()->update_item_info(this, new_info);
        _info = new_info;
        G_Bag::add_opt(this);
        if (_owner) {
            _owner->on_item_changed(this);
        }
    }
}

void G_BagItem::used(G_BagItemOwner *owner) noexcept {
    if (used() != (owner != nullptr)) {
        if (owner) {
            owner->on_item_changed(this);
            _owner = owner;
            the_player()->update_score(score());
        }
        else {
            _owner->on_item_changed(this);
            _owner = owner;
            the_player()->update_score(-score());
        }
        G_Bag::add_opt(this);
    }
}

/* G_Bag */
G_Bag::ItemInfo *G_Bag::probe_info(const G_ItemInfo *info) noexcept {
    static object<ItemInfo> tmp;
    tmp->_info = info;

    auto r = _infos.emplace(tmp);
    if (r.second) {
        object<ItemInfo> item_info;
        item_info->_info = info;
        const_cast<ptr<ItemInfo>&>(*r.first) = item_info;
    }
    return *r.first;
}

G_Bag::ItemInfo *G_Bag::get_info(const G_ItemInfo *info) noexcept {
    static object<ItemInfo> tmp;
    tmp->_info = info;
    auto it = _infos.find(tmp);
    if (it == _infos.end()) {
        return nullptr;
    }
    return *it;
}

bool G_Bag::has_item(const G_ItemInfo *info, unsigned count) {
    if (!count) {
        return true;
    }
    ItemInfo *item_info = get_info(info);
    if (!item_info) {
        return false;
    }

    for (auto &item : item_info->_list) {
        if (item.used()) {
            continue;
        }
        if (count <= item._count) {
            return true;
        }
        count -= item._count;
    }
    return false;
}

void G_Bag::put_item(const G_ItemInfo *info, size_t count) {
    if (!count) {
        return;
    }

    ItemInfo *item_info = probe_info(info);
    unsigned pile_limit = info->pile_limit();
    unsigned n;

    if (pile_limit) {
        for (auto &item : item_info->_list) {
            if (!count) {
                break;
            }
            if (item.used()) {
                continue;
            }
            if (item._count < pile_limit) {
                
                n = pile_limit - item._count;
                if (n > count) {
                    n = count;
                }
                item._count += n;
                add_opt(&item);
                count -= n;
            }
        }
    }
    else {
        pile_limit = 1;
    }

    while (count) {
        G_BagItem *item = probe_object(the_player()->make_guid(), info);
        assert(!item->_count);
        n = count > pile_limit ? pile_limit : count;
        item->_count = n;
        count -= n;
        item_info->_list.push_back(item);

        unsigned type = item->info()->type();
        if (type >= G_ITYPE_EQUIP_BEGIN && type <= G_ITYPE_EQUIP_END) {
            item->_value = 1;
        }
        G_Bag::add_opt(item);
    }
}

void G_Bag::update_item_info(G_BagItem *item, const G_ItemInfo *info) noexcept {
    ItemList::remove(item);
    ItemInfo *item_info = probe_info(info);
    item_info->_list.push_back(item);
}

bool G_Bag::remove_item(unsigned id) {
    ptr<G_BagItem> item = remove_object(id);
    if (item) {
        item->_count = 0;
        G_Bag::add_opt(item);
        ItemList::remove(item);
        return true;
    }
    return false;
}

bool G_Bag::remove_item(const G_ItemInfo *info, size_t count) {
    if (!count) {
        return true;
    }

    ItemInfo *item_info = get_info(info);
    if (!item_info) {
        return false;
    }

    for (auto &item : item_info->_list) {
        if (!count) {
            break;
        }
        if (item.used()) {
            continue;
        }
        if (item._count >= count) {
            item._count -= count;
            if (!item._count) {
                remove_item(item.id());
            }
            else {
                add_opt(&item);
            }
            return true;
        }
        else {
            count -= item._count;
            remove_item(item.id());
        }
    }
    return false;
}

void G_Bag::init(G_Player *player, DB_LoadRsp *msg) {
    for (auto &opt : msg->bag) {
        if (!opt.id) {
            continue;
        }
        const G_ItemInfo *info = G_ItemMgr::instance()->get_info(opt.base);
        if (!info) {
            continue;
        }
        ItemInfo *item_info = probe_info(info);
        G_BagItem *item = probe_object(opt.id, info);
        item_info->_list.push_back(item);

        item->_count = opt.count;
        item->_value = opt.value;
        player->check_guid(opt.id);
    }
}

G_BagItem *G_Bag::get_item(unsigned id) {
    return get_object(id);
}

inline void G_Bag::add_opt(const G_BagItem *item) noexcept {
    auto &opts = the_data()->_bag_opts;
    opts.emplace_back();
    G_BagItemOpt &opt = opts.back();

    opt.id = item->id();
    opt.base = item->info()->id();
    opt.count = item->_count;
    opt.used = item->used();
    opt.value = item->_value;
}

