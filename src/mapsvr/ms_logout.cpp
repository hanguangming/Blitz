#include "mapsvr.h"

struct MS_LogoutServlet : MS_Servlet<MS_Logout> {
    virtual int execute(G_Map *map, request_type *req) {
        G_MapPlayer *player = map->get_player(req->uid);
        if (player) {
            player->logout();
        }
        return 0;
    }
};

GX_SERVLET_REGISTER(MS_LogoutServlet, 0);

