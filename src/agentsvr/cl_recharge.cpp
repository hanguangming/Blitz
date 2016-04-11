#include "agentsvr.h"
#include "libgame/recharge.h"
#include "dbsvr/db_recharge.h"

struct CL_RechargeServlet : CL_Servlet<CL_Recharge> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        const G_RechargeInfo *info = G_RechargeMgr::instance()->get_info(req->id);
        if (!info) {
            return G_LOGIC_ERROR;
        }
        player->recharge(info);

        DB_Recharge msg;
        msg.req->id(player->id());
        msg.req->value_opts = the_value_opts();
        call(msg);
        return 0;
    }
};

GX_SERVLET_REGISTER(CL_RechargeServlet, true);

