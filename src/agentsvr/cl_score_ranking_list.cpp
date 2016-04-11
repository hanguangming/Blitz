#include "agentsvr.h"
#include "worldsvr/ws_score_ranking_list.h"

struct CL_ScoreRankingListServlet : CL_Servlet<CL_ScoreRankingList> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        if (req->begin > req->end) {
            return -1;
        }
        if (req->begin > G_RANKING_LIST_NUM) {
            return -1;
        }

        WS_ScoreRankingList msg;
        msg.req->id(player->id());
        msg.req->begin = req->begin;
        msg.req->end = req->end;
        call(msg);

        rsp->self = msg.rsp->self;
        rsp->list = std::move(msg.rsp->list);
        return 0;
    }
};

GX_SERVLET_REGISTER(CL_ScoreRankingListServlet, true);


