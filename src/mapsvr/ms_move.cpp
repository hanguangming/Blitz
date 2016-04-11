#include "mapsvr.h"

struct MS_MoveServlet : MS_Servlet<MS_Move> {
    virtual int execute(G_Map *map, G_MapPlayer *player, request_type *req, response_type *rsp) {
        map->move(player, req->path, req->type);
        return 0;
    }
};

GX_SERVLET_REGISTER(MS_MoveServlet, 0);
