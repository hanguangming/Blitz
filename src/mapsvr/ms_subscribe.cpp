#include "mapsvr.h"

struct MS_SubscribeServlet : MS_Servlet<MS_Subscribe> {
    virtual int execute(G_Map *map, G_MapPlayer *player, request_type *req, response_type *rsp) {
        if (req->city) {
            G_MapCity *city = map->get_city(req->city);
            if (city) {
                player->subscribe(city);
            }
        }
        else {
            player->subscribe(nullptr);
        }
        return 0;
    }
};

GX_SERVLET_REGISTER(MS_SubscribeServlet, false);

