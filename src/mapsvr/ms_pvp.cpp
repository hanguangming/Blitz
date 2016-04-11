#include "mapsvr.h"

struct MS_PvpServlet : MS_Servlet<MS_Pvp> {
    virtual int execute(G_Map *map, G_MapPlayer *player, request_type *req, response_type *rsp) {
        player->pvp();
        return 0;
    }
};

GX_SERVLET_REGISTER(MS_PvpServlet, false);

