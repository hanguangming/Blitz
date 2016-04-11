#ifndef __LIBGAME_EQUIP_H__
#define __LIBGAME_EQUIP_H__

#include "game.h"
#include "object.h"
#include "item.h"
#include "money.h"

/* G_EquipInfo */
class G_EquipInfo : public G_ObjectInfo {
    friend class G_EquipMgr;
public:
    G_EquipInfo() noexcept;
    unsigned attack() const noexcept {
        return _attack;
    }
    unsigned attack_speed() const noexcept {
        return _attack_speed;
    }
    unsigned hp() const noexcept {
        return _hp;
    }
private:
    unsigned _attack;
    unsigned _attack_speed;
    unsigned _hp;
};

/* G_EquipMgr */
class G_EquipMgr : public G_ObjectInfoContainer<G_EquipInfo>, public singleton<G_EquipMgr> {
    typedef G_ObjectInfoContainer<G_EquipInfo> base_type;
public:
    bool init();
    const G_EquipInfo *get_info(const G_ItemInfo *item, unsigned level) const noexcept {
        return base_type::get_info((((uint64_t)item->type()) << 32) | level);
    }
};

/* G_EquipSuitInfo */
class G_EquipSuitInfo : public G_ObjectInfo {
    friend class G_EquipSuitMgr;
public:
    G_EquipSuitInfo() noexcept;

    unsigned attack() const noexcept {
        return _attack;
    }
    unsigned attack_speed() const noexcept {
        return _attack_speed;
    }
    unsigned hp() const noexcept {
        return _hp;
    }
private:
    unsigned _attack;
    unsigned _hp;
    unsigned _attack_speed;
};

/* G_EquipSuitMgr */
class G_EquipSuitMgr : public G_ObjectInfoContainer<G_EquipSuitInfo>, public singleton<G_EquipSuitMgr> {
public:
    bool init();
    const G_EquipSuitInfo *get_info(uint64_t value) const noexcept {
        auto it = _infos.lower_bound(value);
        if (it == _infos.end()) {
            return nullptr;
        }
        return it->second;
    }
};

/* G_EquipUpInfo */
class G_EquipUpInfo : public G_ObjectInfo {
    friend class G_EquipUpMgr;
public:
    const G_Money &price() const noexcept {
        return _price;
    }
private:
    G_Money _price;
};

/* G_EquipUpMgr */
class G_EquipUpMgr : public G_ObjectInfoContainer<G_EquipUpInfo>, public singleton<G_EquipUpMgr> {
    typedef G_ObjectInfoContainer<G_EquipUpInfo> base_type;
public:
    bool init();
    const G_EquipUpInfo *get_info(const G_ItemInfo *item, unsigned level) const noexcept {
        return base_type::get_info((((uint64_t)item->type()) << 32) | level);
    }
};

#endif

