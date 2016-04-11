#include "agentsvr.h"
#include "dbsvr/db_formation.h"

struct CL_FormationSaveServlet : CL_Servlet<CL_FormationSave> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        if (!player->formations()->init(player, req->formations, false)) {
            return false;
        }
        DB_FormationSave msg;
        msg.req->id(player->id());
        msg.req->formations = std::move(req->formations);
        call(msg);
        return 0;
    }
};

GX_SERVLET_REGISTER(CL_FormationSaveServlet, true);

struct CL_FormationUseServlet : CL_Servlet<CL_FormationUse> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        if (!player->use_formation(req->type, req->index)) {
            return -1;
        }

        DB_FormationUse msg;
        msg.req->id(player->id());
        msg.req->value_opts = the_value_opts();
        call(msg);
        return 0;
    }
};

GX_SERVLET_REGISTER(CL_FormationUseServlet, true);

