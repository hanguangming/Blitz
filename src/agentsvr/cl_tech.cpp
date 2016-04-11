#include "agentsvr.h"
#include "dbsvr/db_tech.h"

struct CL_TechResearchServlet : CL_Servlet<CL_TechResearch> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        const G_TechInfo *info = G_TechMgr::instance()->get_info(req->id);
        if (!info) {
            return -1;
        }
        if (!player->tech()->research(info)) {
            return -1;
        }

        DB_TechResearch msg;
        msg.req->id(player->id());
        msg.req->value_opts = the_value_opts();
        msg.req->tech_opts = the_tech_opts();
        msg.req->soldier_value_opts = the_soldier_value_opts();
        
        call(msg);
        return 0;
    }
};

GX_SERVLET_REGISTER(CL_TechResearchServlet, true);

