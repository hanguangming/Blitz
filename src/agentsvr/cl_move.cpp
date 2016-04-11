#include "agentsvr.h"
#include "mapsvr/ms_move.h"

struct CL_MoveServlet : CL_Servlet<CL_Move> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {

        MS_Move msg;
        msg.req->id(player->id());
        msg.req->type = req->type;
        msg.req->path = std::move(req->path);
        call(msg);
        return 0;
    }
};

GX_SERVLET_REGISTER(CL_MoveServlet, true);

