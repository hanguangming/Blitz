#ifndef __LIBGAME_RECRUIT_H__
#define __LIBGAME_RECRUIT_H__

#include <map>
#include <vector>
#include "object.h"
#include "item.h"
#include "soldier.h"

class G_Player;

class G_RecruitSoldiersInfo : public G_ObjectInfo {
    friend class G_RecruitMgr;
    friend class G_RecuritSoldiersMgr;
private:
    void get(G_Player *player, unsigned count, std::vector<const G_SoldierInfo*> &result) const noexcept;
private:
    mutable std::vector<const G_SoldierInfo*> _soldiers;
};

class G_RecuritSoldiersMgr : public G_ObjectInfoContainer<G_RecruitSoldiersInfo> {
    friend class G_RecruitMgr;
public:
    using G_ObjectInfoContainer<G_RecruitSoldiersInfo>::get_info;
    using G_ObjectInfoContainer<G_RecruitSoldiersInfo>::probe_info;
    bool init();
};

class G_RecuritRefreshInfo : public Object {
    friend class G_RecruitMgr;

    unsigned _level_limit;
    const G_RecruitSoldiersInfo *_soldiers;
};

class G_RecruitInfo : public G_ObjectInfo {
    friend class G_RecruitMgr;
public:
    G_RecruitInfo() noexcept
    : _use_item(), 
      _use_count(), 
      _recruit_value(), 
      _refresh_count(), 
      _default()
    { }

private:
    const G_ItemInfo *_use_item;
    unsigned _use_count;
    unsigned _recruit_value;
    unsigned _refresh_count;
    const G_RecruitSoldiersInfo *_default;

    ProbContainer<G_RecuritRefreshInfo> _probs;
};

class G_RecruitMgr : public G_ObjectInfoContainer<G_RecruitInfo>, public singleton<G_RecruitMgr> {
public:
    bool init();
    bool exec(G_Player *player, unsigned type);
private:
    G_RecuritSoldiersMgr _soldiers;
};


#endif

