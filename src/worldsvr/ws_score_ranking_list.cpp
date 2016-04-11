#include "worldsvr.h"

struct WS_SocreRankingListServlet : WS_Servlet<WS_ScoreRankingList> {
    virtual int execute(G_World *world, G_WorldPlayer *player, request_type *req, response_type *rsp) {
        rsp->self = player->score_rank();
        G_World::instance()->score_ranking_list()->to_list(req->begin, req->end, rsp->list);
        return 0;
    }
};

GX_SERVLET_REGISTER(WS_SocreRankingListServlet, false);

