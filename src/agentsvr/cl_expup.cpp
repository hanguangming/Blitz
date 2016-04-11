#include "agentsvr.h"
#include "dbsvr/db_expup.h"

struct CL_ExpUpServlet : CL_Servlet<CL_ExpUp> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        G_Soldier *soldier = player->corps()->get(req->sid);
        if (!soldier) {
            return -1;
        }
        if (!soldier->use_expup(req->count)) {
            return -1;
        }

        DB_ExpUp msg;
        msg.req->id(player->id());
        msg.req->item_opts = the_bag_opts();
        msg.req->value_opts = the_soldier_value_opts();
        call(msg);
        return 0;
    }
};

GX_SERVLET_REGISTER(CL_ExpUpServlet, true);

