#ifndef __LIBGAME_RECHARGE_H__
#define __LIBGAME_RECHARGE_H__

#include "object.h"

class G_RechargeMgr;

class G_RechargeInfo : public G_ObjectInfo {
    friend class G_RechargeMgr;
public:
    G_RechargeInfo() noexcept 
    : _platform_money(), _game_money()
    { }

    unsigned platform_money() const noexcept {
        return _platform_money;
    }
    unsigned game_money() const noexcept {
        return _game_money;
    }
    unsigned exp() const noexcept {
        return _exp;
    }
private:
    unsigned _platform_money;
    unsigned _game_money;
    unsigned _exp;
};

class G_RechargeMgr : public G_ObjectInfoContainer<G_RechargeInfo>, public singleton<G_RechargeMgr> {
public:
    using G_ObjectInfoContainer<G_RechargeInfo>::get_info;
    bool init();
};

#endif

