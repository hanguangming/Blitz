#include "agentsvr.h"
#include "libgame/param.h"
#include "dbsvr/db_employ.h"
#include "agentsvr/as_system_notify.h"

struct CL_EmployServlet : CL_Servlet<CL_Employ> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        if (req->employ) {
            const G_SoldierInfo *info = player->corps()->employ(req->sid);
            if (!info) {
                return -1;
            }

            DB_Employ msg;
            msg.req->id(player->id());
            msg.req->value_opts = the_value_opts();
            msg.req->soldier_value_opts = the_soldier_value_opts();
            call(msg);

            if (info->quality() >= G_QUALITY_4) {
                AS_SystemNotify msg;
                msg.req->msg_id = 1;
                player->make_chat_info(msg.req->player);
                msg.req->params.push_back(info->id());
                the_app->network()->broadcast(msg);
            }
        }
        else {
            G_Soldier *soldier = player->corps()->get(req->sid);
            if (!soldier) {
                return -1;
            }
            if (!soldier->info()->is_hero()) {
                return -1;
            }
            if (soldier->info()->quality() >= G_ParamMgr::instance()->fire_hero_limit()) {
                return -1;
            }
            player->corps()->remove(soldier->id());

            DB_Fire msg;
            msg.req->id(player->id());
            msg.req->soldier_opts = the_soldier_opts();
            msg.req->item_opts = the_bag_opts();
            msg.req->formation_opts = the_formation_opts();
            msg.req->train_opts = the_train_opts();
            call(msg);
        }
        return 0;
    }
};

GX_SERVLET_REGISTER(CL_EmployServlet, true);
