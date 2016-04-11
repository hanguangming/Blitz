#include "mapsvr.h"
#include "libgame/map_player.h"

struct MS_ShadowServlet : MS_Servlet<MS_Shadow> {
    virtual int execute(G_Map *map, G_MapPlayer *player, request_type *req, response_type *rsp) {
        rsp->ok = player->shadow(req->corps);
        return 0;
    }
};

GX_SERVLET_REGISTER(MS_ShadowServlet, false);

