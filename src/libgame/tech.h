#ifndef __LIBGAME_TECH_H__
#define __LIBGAME_TECH_H__

#include "object.h"
#include "level.h"
#include "stage.h"
#include "soldier.h"
#include "libgame/g_tech.h"
#include "timer.h"

class DB_LoadRsp;
class G_Player;

/* G_TechInfo */
class G_TechInfo : public G_ObjectInfo {
    friend class G_TechMgr;
public:
    G_TechInfo() noexcept;

public:
    const G_TechInfo *tech_limit() const noexcept {
        return _tech_limit;
    };
    const G_LevelInfo *level_limit() const noexcept {
        return _level_limit;
    }
    const G_StageInfo *stage_limit() const noexcept {
        return _stage_limit;
    }
    unsigned soldierup() const noexcept {
        return _soldierup;
    }
    unsigned soldier_pve() const noexcept {
        return _soldier_pve;
    }
    unsigned soldier_pvp() const noexcept {
        return _soldier_pvp;
    }
    unsigned speed() const noexcept {
        return _speed;
    }
    const G_SoldierInfo *soldier() const noexcept {
        return _soldier;
    }
    unsigned type() const noexcept {
        return _type;
    }
    unsigned price_num() const noexcept {
        return _price_num;
    }
    const G_Money &price() const noexcept {
        return _price;
    }
    timeval_t cooldown() const noexcept {
        return _cooldown;
    }
private:
    const G_TechInfo *_tech_limit;
    const G_LevelInfo *_level_limit;
    const G_StageInfo *_stage_limit;

    unsigned _soldierup;
    unsigned _soldier_pve;
    unsigned _soldier_pvp;
    unsigned _speed;
    const G_SoldierInfo *_soldier;
    unsigned _type;
    unsigned _price_num;
    G_Money _price;
    timeval_t _cooldown;
};

/* G_TechMgr */
class G_TechMgr : public G_ObjectInfoContainer<G_TechInfo>, public singleton<G_TechMgr> {
public:
    using G_ObjectInfoContainer<G_TechInfo>::get_info;
    bool init();
};

/* G_TechItem */
class G_TechItem : public Object, public G_TimerObject {
    friend class G_Tech;
public:
    G_TechItem(unsigned type) noexcept;
    const G_TechInfo *info() const noexcept {
        return _info;
    }
protected:
    timeval_t timer_handler(timeval_t now) override;
private:
    void to_opt(G_TechExpireOpt &opt) noexcept;
    void to_opt(G_TechOpt &opt) noexcept;
    bool research_finish(timeval_t now) noexcept;
private:
    unsigned _type;
    const G_TechInfo *_info;
    const G_TechInfo *_research;
    unsigned _price_num;
    timeval_t _cooldown;
};

/* G_Tech */
class G_Tech : public Object {
public:
    G_Tech() noexcept;
    bool research(const G_TechInfo *tech) noexcept;
    void init(G_Player *player, DB_LoadRsp *msg) noexcept;
    void to_opt(obstack_vector<G_TechExpireOpt> &opts) noexcept;
    void to_opt(obstack_vector<G_TechOpt> &opts) noexcept;

    unsigned soldierup() const noexcept {
        const G_TechInfo *info = _items[G_TECH_SOLDIERUP_NUM]->_info;
        return info ? info->soldierup() : G_SOLDIERUP_NUM;
    }
    unsigned soldier_pve() const noexcept {
        const G_TechInfo *info = _items[G_TECH_SOLDIER_PVE_NUM]->_info;
        return info ? info->soldier_pve() : G_SOLDIER_PVE_NUM;
    }
    unsigned soldier_pvp() const noexcept {
        const G_TechInfo *info = _items[G_TECH_SOLDIER_PVP_NUM]->_info;
        return info ? info->soldier_pvp() : G_SOLDIER_PVP_NUM;
    }
    unsigned speed() const noexcept {
        const G_TechInfo *info = _items[G_TECH_SPEED]->_info;
        return info ? info->speed() : G_SPEED;
    }
    const G_TechItem *get_tech(unsigned index) const noexcept {
        assert(index < G_TECH_UNKNOWN);
        return _items[index];
    }
private:
    ptr<G_TechItem> _items[G_TECH_UNKNOWN];
};

#endif

