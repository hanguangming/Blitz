#include "mapsvr.h"

struct MS_SupplementServlet : MS_Servlet<MS_Supplement> {
    virtual int execute(G_Map *map, G_MapPlayer *player, request_type *req, response_type *rsp) {
        player->supplement(&req->corps);
        rsp->people = player->people();
        return 0;
    }
};

GX_SERVLET_REGISTER(MS_SupplementServlet, false);

