#include "worldsvr.h"

struct WS_LogoutServlet : WS_Servlet<WS_Logout> {
    virtual int execute(G_World *world, request_type *req) {
        G_WorldPlayer *player = world->get_player(req->uid);
        if (player) {
            world->logout(player);
        }
        return 0;
    }
};

GX_SERVLET_REGISTER(WS_LogoutServlet, false);


