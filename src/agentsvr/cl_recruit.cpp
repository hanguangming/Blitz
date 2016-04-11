#include "agentsvr.h"
#include "libgame/recruit.h"
#include "dbsvr/db_recruit.h"

struct CL_RecruitServlet : CL_Servlet<CL_Recruit> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        if (!G_RecruitMgr::instance()->exec(player, req->type)) {
            return -1;
        }

        DB_Recruit msg;
        msg.req->id(player->id());
        msg.req->value_opts = the_value_opts();
        msg.req->item_opts = the_bag_opts();
        msg.req->cd_opts = the_cd_opts();
        call(msg);
        return 0;
    }
};

GX_SERVLET_REGISTER(CL_RecruitServlet, true);

