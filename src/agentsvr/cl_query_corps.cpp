#include "agentsvr.h"
#include "mapsvr/ms_query_corps.h"

struct CL_QueryCorpsServlet : CL_Servlet<CL_QueryCorps> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        MS_QueryCorps msg;
        msg.req->id(player->id());
        call(msg);

        rsp->corps = msg.rsp->corps;
        return 0;
    }
};

GX_SERVLET_REGISTER(CL_QueryCorpsServlet, true);

