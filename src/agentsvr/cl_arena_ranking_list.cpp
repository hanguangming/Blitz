#include "agentsvr.h"
#include "worldsvr/ws_arena_ranking_list.h"

struct CL_ArenaRankingListServlet : CL_Servlet<CL_ArenaRankingList> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        WS_ArenaRankingList msg;
        msg.req->id(player->id());
        call(msg);
        rsp->list = std::move(msg.rsp->list);
        return 0;
    }
};

GX_SERVLET_REGISTER(CL_ArenaRankingListServlet, true);

