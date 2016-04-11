#ifndef __LIBGAME_PLAYER_INIT_H__
#define __LIBGAME_PLAYER_INIT_H__

#include "game.h"

class G_PlayerInitMgr: public Object, public singleton<G_PlayerInitMgr> {
public:
    G_PlayerInitMgr() noexcept;
    bool init();

    unsigned coin;
    unsigned money;
    std::vector<unsigned> items;
    std::vector<unsigned> soldiers;
};

#endif

