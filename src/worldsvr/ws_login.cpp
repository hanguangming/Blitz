#include "worldsvr.h"

struct WS_LoginServlet : WS_Servlet<WS_Login> {
    virtual int execute(G_World *world, request_type *req) {
        G_WorldPlayer *player = world->get_player(req->uid);
        if (player) {
            world->login(player, req->info);
        }
        return 0;
    }
};

GX_SERVLET_REGISTER(WS_LoginServlet, false);

