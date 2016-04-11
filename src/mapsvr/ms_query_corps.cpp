#include "mapsvr.h"

struct MS_QueryCorpsServlet : MS_Servlet<MS_QueryCorps> {
    virtual int execute(G_Map *map, G_MapPlayer *player, request_type *req, response_type *rsp) {
        if (player->corps()) {
            player->corps()->to_unmanaged(rsp->corps);
        }
        return 0;
    }
};

GX_SERVLET_REGISTER(MS_QueryCorpsServlet, false);

