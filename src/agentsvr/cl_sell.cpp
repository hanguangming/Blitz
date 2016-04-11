#include "agentsvr.h"
#include "dbsvr/db_sell.h"

struct CL_SellServlet : CL_Servlet<CL_Sell> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        G_BagItem *item = player->bag()->get_item(req->item_id);
        if (!item) {
            return G_LOGIC_ERROR;
        }
        if (!item->info()->sell().coin) {
            return G_LOGIC_ERROR;
        }

        G_Money money = item->info()->sell() * item->count();

        player->add_money(money);
        player->bag()->remove_item(req->item_id);

        DB_Sell msg;
        msg.req->id(player->id());
        msg.req->value_opts = the_value_opts();
        msg.req->item_opts = the_bag_opts();
        call(msg);
        return 0;
    }
};

GX_SERVLET_REGISTER(CL_SellServlet, true);

