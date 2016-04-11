#include "agentsvr.h"
#include "dbsvr/db_use_equip.h"

struct CL_UseEquipServlet : CL_Servlet<CL_UseEquip> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        G_Soldier *soldier = player->corps()->get(req->sid);
        if (!soldier) {
            return G_LOGIC_ERROR;
        }
        if (!soldier->info()->is_hero()) {
            return G_LOGIC_ERROR;
        }
        G_BagItem *item = player->bag()->get_item(req->equip);
        if (!item) {
            return G_LOGIC_ERROR;
        }
        if (!soldier->use_equip(item)) {
            return G_LOGIC_ERROR;
        }

        DB_UseEquip msg;
        msg.req->id(player->id());
        msg.req->value_opts = the_soldier_value_opts();
        msg.req->item_opts = the_bag_opts();
        call(msg);
        return 0;
    }
};

GX_SERVLET_REGISTER(CL_UseEquipServlet, true);

