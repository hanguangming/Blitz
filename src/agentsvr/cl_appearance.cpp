#include "agentsvr.h"
#include "dbsvr/db_appearance.h"

struct CL_AppearanceServlet : CL_Servlet<CL_Appearance> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        if (!player->corps()->get(req->appearance_id)) {
            return -1;
        }
        if (player->appearance() != req->appearance_id) {
            player->appearance(req->appearance_id);

            DB_Appearance msg;
            msg.req->id(player->id());
            msg.req->value_opts = the_value_opts();
            call(msg);
        }
        return 0;
    }
};

GX_SERVLET_REGISTER(CL_AppearanceServlet, true);

