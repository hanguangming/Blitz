#include "mapsvr.h"

struct MC_LoginServlet : Servlet<MC_Login> {
public:
    virtual int execute(request_type *req, response_type *rsp) {
        G_MapPlayer *player = G_Map::instance()->get_player(req->id);
        if (!player) {
            return -1;
        }
        if (!G_Map::instance()->login(player, req->key, the_context()->peer())) {
            return -1;
        }
        rsp->city = player->city()->id();
        return 0;
    }
};

GX_SERVLET_REGISTER(MC_LoginServlet, 0);

