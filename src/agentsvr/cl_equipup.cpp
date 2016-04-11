#include "agentsvr.h"
#include "libgame/equip.h"
#include "dbsvr/db_equipup.h"

struct CL_EquipUpServlet : CL_Servlet<CL_EquipUp> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        unsigned count = req->count;
        if (count > 10) {
            return G_LOGIC_ERROR;
        }

        G_BagItem *item = player->bag()->get_item(req->item_id);
        if (!item) {
            return G_LOGIC_ERROR;
        }

        const G_ItemInfo *info = item->info();
        if (!info->is_equip()) {
            return G_LOGIC_ERROR;
        }

        unsigned uplevel = item->value();
        if (uplevel + count > player->level()) {
            return G_LOGIC_ERROR;
        }

        G_Money money;
        while (count--) {
            money = money + G_EquipUpMgr::instance()->get_info(info, uplevel++)->price();
        }

        if (!player->has_money(money)) {
            return -1;
        }

        player->use_money(money);
        item->value(uplevel);

        DB_EquipUp msg;
        msg.req->id(player->id());
        msg.req->item_opts = the_bag_opts();
        msg.req->value_opts = the_value_opts();
        call(msg);
        return 0;
    }
};

GX_SERVLET_REGISTER(CL_EquipUpServlet, true);

