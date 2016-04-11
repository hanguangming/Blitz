#include "agentsvr.h"
#include "mapsvr/ms_subscribe.h"

struct CL_MapSubscribeServlet : CL_Servlet<CL_MapSubscribe> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        MS_Subscribe msg;
        msg.req->id(player->id());
        msg.req->city = req->city;
        call(msg);
        return msg.rsp->rc;
    }
};

GX_SERVLET_REGISTER(CL_MapSubscribeServlet, true);

