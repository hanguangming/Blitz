#include "worldsvr.h"

struct WS_SoldierUpdateServlet : WS_Servlet<WS_SoldierUpdate> {
    virtual int execute(G_World *world, request_type *req) {
        G_WorldPlayer *player = world->get_player(req->uid);
        if (player) {
            player->soldiers(req->soldiers.data());
        }
        return 0;
    }
};

GX_SERVLET_REGISTER(WS_SoldierUpdateServlet, false);

