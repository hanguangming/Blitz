#include "agentsvr.h"
#include "libgame/shop.h"
#include "libgame/bag.h"
#include "dbsvr/db_shop.h"

class CL_ShopBuyServlet : public CL_Servlet<CL_ShopBuy> {
public:
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        if (!req->count) {
            return GX_EFAIL;
        }

        if (req->shopid == G_FORGE_SHOP) {
            return -1;
        }

        const G_ShopItemInfo *item = G_ShopMgr::instance()->get_info(req->shopid, req->id);
        if (!item) {
            return -1;
        }

        G_Money used_money = item->price() * req->count;

        if (!player->has_money(used_money)) {
            return GX_ELESS;
        }

        if (item->soldier()) {
            if (req->count != 1) {
                return -1;
            }
            if (player->corps()->hero_count() >= player->hero_limit()) {
                return -1;
            }
            player->corps()->add(item->soldier());
        }
        else {
            player->bag()->put_item(item->item(), req->count);
        }
        player->use_money(used_money);

        DB_ShopBuy msg;
        msg.req->id(player->id());
        msg.req->value_opts = the_value_opts();
        msg.req->item_opts = the_bag_opts();
        msg.req->soldier_value_opts = the_soldier_value_opts();
        call(msg);

        return 0;
    }
};

GX_SERVLET_REGISTER(CL_ShopBuyServlet, true);

