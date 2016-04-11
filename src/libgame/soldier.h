#ifndef __LIBGAME_HERO_H__
#define __LIBGAME_HERO_H__

#include "object.h"
#include "item.h"
#include "fight.h"
class G_Player;

class G_SoldierInfo : public G_ObjectInfo {
    friend class G_SoldierMgr;
public:
    bool is_hero() const noexcept {
        return _is_hero;
    }
    unsigned quality() const noexcept {
        return _quality;
    }
    unsigned hp() const noexcept {
        return _hp;
    }
    unsigned attack() const noexcept {
        return _attack;
    }
    unsigned attack_speed() const noexcept {
        return _attack_speed;
    }
    unsigned hp_param() const noexcept {
        return _hp_param;
    }
    unsigned attack_param() const noexcept {
        return _attack_param;
    }
    unsigned people() const noexcept {
        return _people;
    }
    unsigned star() const noexcept {
        return _star;
    }
    void build_fight_info(unsigned level, G_FightAttr &attr) const noexcept {
        assert(level > 0);
        attr.attack = _attack + (level - 1) * _attack_param;
        attr.hp = _hp + (level - 1) * _hp_param;
        attr.attack_speed = _attack_speed;
    }
private:
    bool _is_hero;
    unsigned _quality;
    unsigned _hp;
    unsigned _attack;
    unsigned _attack_speed;
    unsigned _hp_param;
    unsigned _attack_param;
    unsigned _people;
    unsigned _star;
};

class G_SoldierMgr : public G_ObjectInfoContainer<G_SoldierInfo>, public singleton<G_SoldierMgr> {
public:
    using G_ObjectInfoContainer<G_SoldierInfo>::get_info;
    bool init();
};

class G_SoldierMakeInfo : public G_ObjectInfo {
    friend class G_SoldierMakeMgr;
public:
    G_SoldierMakeInfo() noexcept 
    : _use_item(), _use_count()
    { }

    const G_ItemInfo *use_item() const noexcept {
        return _use_item;
    }
    unsigned use_count() const noexcept {
        return _use_count;
    }
    const G_SoldierInfo *get(G_Player *player) const noexcept;
private:
    const G_ItemInfo *_use_item;
    unsigned _use_count;
    mutable std::vector<const G_SoldierInfo*> _soldiers;
};

class G_SoldierMakeMgr : public G_ObjectInfoContainer<G_SoldierMakeInfo>, public singleton<G_SoldierMakeMgr> {
public:
    using G_ObjectInfoContainer<G_SoldierMakeInfo>::get_info;
    bool init();
};

#endif

