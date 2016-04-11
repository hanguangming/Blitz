#include "agentsvr.h"

struct CL_FightResultServlet : CL_Servlet<CL_FightResult> {
    virtual int execute(G_Player *player, request_type *req) {
        player->fight_response(req->seq, req->info);
        return 0;
    }
};

GX_SERVLET_REGISTER(CL_FightResultServlet, false);



