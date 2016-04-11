#include "agentsvr.h"
#include "mapsvr/ms_pvp.h"
struct CL_MapPvpServlet : CL_Servlet<CL_MapPvp> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        MS_Pvp msg;
        msg.req->id(player->id());
        call(msg);
        return 0;
    }
};

GX_SERVLET_REGISTER(CL_MapPvpServlet, true);

