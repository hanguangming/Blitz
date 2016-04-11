#ifndef __LIBGAME_CORPS_H__
#define __LIBGAME_CORPS_H__

#include <set>
#include "game.h"
#include "soldier.h"
#include "value.h"
#include "level.h"
#include "libgame/g_defines.h"
#include "libgame/g_soldier.h"
#include "fight.h"
#include "bag.h"

class G_Player;
class G_Soldier;
class DB_LoadRsp;
class G_Formation;
class G_FightCorps;

class G_SoldierValues : public G_Values<G_SOLDIER_UNKNOWN> {
public:
    G_SoldierValues(G_Soldier *soldier) noexcept 
    : G_Values<G_SOLDIER_UNKNOWN>(), 
      _soldier(soldier) 
    { }

protected:
    void mark_update(unsigned index, unsigned value) noexcept override;

private:
    G_Soldier *_soldier;
};

class G_Soldier : public G_Object<unsigned, G_SoldierInfo>, public G_BagItemOwner {
    friend class G_Corps;
    friend class G_SoldierList;
public:
    G_Soldier() noexcept;
    void add_exp(unsigned value) noexcept;
    void gm_set_level(unsigned value) noexcept;
    const G_SoldierValues &values() const noexcept {
        return _values;
    }
    void copy(G_Soldier *other) noexcept;
    const G_LevelInfo *level() const noexcept {
        return _level;
    }
    bool use_equip(G_BagItem *item) noexcept;
    bool use_expup(unsigned count) noexcept;
    void get_off_all() noexcept;
    unsigned score() const noexcept {
        return info()->star() * _level->level() * 100;
    }
    void mark_fight_info_dirty() noexcept {
        _fight_info_dirty = true;
    }
    void on_item_changed(G_BagItem *item) noexcept override {
        mark_fight_info_dirty();
    }
private:
    void rebuild_fight_info() noexcept;
private:
    const G_LevelInfo *_level;
    G_SoldierValues _values;
    list_entry _entry;
    G_FightAttr _attr;
    bool _fight_info_dirty;
};

class G_SoldierList {
public:
    G_SoldierList() noexcept : _count() { }

    void add(G_Soldier *soldier) noexcept {
        _list.push_front(soldier);
        ++_count;
    }

    void remove(G_Soldier *soldier) noexcept {
        gx_list(G_Soldier, _entry)::remove(soldier);
        --_count;
    }

    unsigned count() const noexcept {
        return _count;
    }

    gx_list(G_Soldier, _entry)::iterator begin() const noexcept {
        return _list.begin();
    }

    gx_list(G_Soldier, _entry)::iterator end() const noexcept {
        return _list.end();
    }
private:
    gx_list(G_Soldier, _entry) _list;
    unsigned _count;
};

class G_Corps : public G_ObjectContainer<G_Soldier> {
    typedef G_ObjectContainer<G_Soldier> base_type;
public:
    G_Corps() noexcept;

    G_Soldier *get(unsigned id) noexcept {
        return get_object(id);
    }
    G_Soldier *get(const G_SoldierInfo *info) noexcept {
        return get(info->id());
    }
    G_Soldier *add(const G_SoldierInfo *info, G_Soldier *other = nullptr) noexcept;
    ptr<G_Soldier> remove(unsigned id) noexcept;
    void init(G_Player *player, DB_LoadRsp *msg) noexcept;

    const G_SoldierList &quality_list(unsigned index) const noexcept {
        assert(index < G_QUALITY_UNKNOWN);
        return _qualities[index];
    }
    const container_type &soldiers() const noexcept {
        return objects();
    }
    unsigned hero_count() const noexcept {
        return _hero_count;
    }
    const G_SoldierInfo *employ(unsigned sid) noexcept;
    bool use_hero(unsigned sid, bool use) noexcept;
    bool get_fight_info(G_Formation *form, G_FightCorps &info) noexcept;
    bool supplement_soldier(G_Formation *form, G_FightCorps &corps) noexcept;
private:
    unsigned _hero_count;
    unsigned _hero_used;
    G_SoldierList _qualities[G_QUALITY_UNKNOWN];
};

#endif


