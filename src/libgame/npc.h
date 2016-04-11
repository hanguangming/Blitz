#ifndef __LIBGAME_NPC_H__
#define __LIBGAME_NPC_H__

#include <vector>
#include "game.h"
#include "fight.h"
#include "soldier.h"
#include "map_unit.h"
#include "map_side.h"

/* G_NpcTeam */
class G_NpcTeam {
    friend class G_NpcInfo;
    friend class G_NpcMgr;
public:
    G_NpcTeam() noexcept;
    const G_SoldierInfo *hero() const noexcept {
        return _hero;
    }
    const G_SoldierInfo *soldier() const noexcept {
        return _soldier;
    }
    unsigned soldier_num() const noexcept {
        return _soldier_num;
    }
    unsigned x() const noexcept {
        return _x;
    }
    unsigned y() const noexcept {
        return _y;
    }
private:
    const G_SoldierInfo *_hero;
    const G_SoldierInfo *_soldier;
    unsigned _soldier_num;
    unsigned _x;
    unsigned _y;
};

/* G_NpcInfo */
class G_NpcInfo : public G_ObjectInfo {
    friend class G_NpcMgr;
public:
    G_NpcInfo() noexcept;
    unsigned appearance() const noexcept {
        return _appearance;
    }
    const std::vector<G_NpcTeam> &teams() const noexcept {
        return _teams;
    }
private:
    unsigned _appearance;
    unsigned _type;
    std::vector<G_NpcTeam> _teams;
};

/* G_NpcMgr */
class G_NpcMgr : public G_ObjectInfoContainer<G_NpcInfo>, public singleton<G_NpcMgr> {
public:
    using G_ObjectInfoContainer<G_NpcInfo>::get_info;
    bool init();

    const G_NpcInfo *defender() const noexcept {
        return _defender;
    }
private:
    const G_NpcInfo *_defender;
};

/*G_Npc */
class G_MapNpc : public Object, public G_MapUnit {
public:
    G_MapNpc(unsigned type, const G_NpcInfo *info, G_MapSide *side) noexcept;

    unsigned unit_id() const noexcept override {
        return _id;
    }
protected:
    unsigned _id;
    const G_NpcInfo *_info;
};

class G_NpcDefender : public G_MapNpc {
public:
    G_NpcDefender(G_MapSide *side) noexcept 
    : G_MapNpc(G_MAP_UNIT_DEFENDER, G_NpcMgr::instance()->defender(), side)
    { }

    void get_corps(G_FightCorps *corps) noexcept override;
    void set_corps(const G_FightCorps *corps) noexcept override;
    void fight_finish() noexcept override;
};

class G_NpcShadow : public G_MapNpc {
public:
    G_NpcShadow(G_MapPlayer *player, G_FightCorps &corps) noexcept;

    void fight_finish() noexcept override;
    void get_corps(G_FightCorps *corps) noexcept override;
    void set_corps(const G_FightCorps *corps) noexcept override;

    unsigned appearance() const noexcept override {
        return _appearance;
    }
    unsigned level() const noexcept override {
        return _level;
    }
    unsigned vip() const noexcept override {
        return _vip;
    }

private:
    unsigned _vip;
    unsigned _level;
    unsigned _appearance;
    ptr<G_ManagedFightCorps> _corps;
};
#endif

