#include "worldsvr.h"

struct WS_SoldierRankingListServlet : WS_Servlet<WS_SoldierRankingList> {
    virtual int execute(G_World *world, G_WorldPlayer *player, request_type *req, response_type *rsp) {
        rsp->self = player->soldier_rank();
        G_World::instance()->soldier_ranking_list()->to_list(req->begin, req->end, rsp->list);
        return 0;
    }
};

GX_SERVLET_REGISTER(WS_SoldierRankingListServlet, false);

