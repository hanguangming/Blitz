#include "agentsvr.h"
#include "worldsvr/ws_arena_list.h"

struct CL_ArenaListServlet : CL_Servlet<CL_ArenaList> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        WS_ArenaList msg;
        msg.req->id(player->id());
        call(msg);
        rsp->self = msg.rsp->self;
        rsp->items = std::move(msg.rsp->items);
        rsp->tops = std::move(msg.rsp->tops);
        return 0;
    }
};

GX_SERVLET_REGISTER(CL_ArenaListServlet, true);

