#include "worldsvr.h"

struct WS_ScoreUpdateServlet : WS_Servlet<WS_ScoreUpdate> {
    virtual int execute(G_World *world, request_type *req) {
        G_WorldPlayer *player = world->get_player(req->uid);
        if (player) {
            player->score(req->score);
        }
        return 0;
    }
};

GX_SERVLET_REGISTER(WS_ScoreUpdateServlet, false);

