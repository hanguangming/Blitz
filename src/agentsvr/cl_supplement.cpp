#include "agentsvr.h"
#include "dbsvr/db_supplement.h"
#include "mapsvr/ms_supplement.h"

struct CL_SupplementServlet : CL_Servlet<CL_Supplement> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        unsigned form_id = player->values().get(G_VALUE_FORMATION_PVP);
        G_Formation *form = player->formations()->formation(form_id);
        if (!form) {
            return -1;
        }

        MS_Supplement supplement_msg;
        if (!player->corps()->supplement_soldier(form, supplement_msg.req->corps)) {
            return -1;
        }

        do {
            DB_Supplement msg;
            msg.req->id(player->id());
            msg.req->item_opts = the_bag_opts();
            msg.req->value_opts = the_value_opts();
            call(msg);
        } while (0);

        supplement_msg.req->id(player->id());
        call(supplement_msg);

        rsp->people = supplement_msg.rsp->people;
        return 0;
    }
};

GX_SERVLET_REGISTER(CL_SupplementServlet, true);

