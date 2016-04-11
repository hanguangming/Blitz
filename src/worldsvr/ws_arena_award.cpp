#include "worldsvr.h"

struct WS_ArenaAwardServlet : WS_Servlet<WS_ArenaAward> {
    virtual int execute(G_World *world, G_WorldPlayer *player, request_type *req, response_type *rsp) {
        rsp->rank = player->arena_get_award();
        if (!rsp->rank) {
            return GX_EMORE;
        }
        rsp->arena = player->arena();
        rsp->arena2 = player->arena2();
        rsp->arena_day = player->arena_day();
        return 0;
    }
};

GX_SERVLET_REGISTER(WS_ArenaAwardServlet, false);

