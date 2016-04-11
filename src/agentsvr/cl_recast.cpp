#include "agentsvr.h"
#include "libgame/recast.h"
#include "dbsvr/db_recast.h"

struct CL_RecastServlet : CL_Servlet<CL_Recast> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        G_BagItem *source_item = player->bag()->get_item(req->item_id);
        if (!source_item) {
            return G_LOGIC_ERROR;
        }
        const G_ItemInfo *source_info = source_item->info();
        const G_RecastInfo *recast_info = G_RecastMgr::instance()->get_info(source_info->id());
        if (!recast_info) {
            return G_LOGIC_ERROR;
        }
        if (req->use_items.size() != recast_info->use_count()) {
            return G_LOGIC_ERROR;
        }

        if (!player->has_money(recast_info->price())) {
            return G_LOGIC_ERROR;
        }
        std::set<unsigned> items;
        for (unsigned use_item_id : req->use_items) {
            if (!items.emplace(use_item_id).second) {
                return G_LOGIC_ERROR;
            }
            G_BagItem *use_item = player->bag()->get_item(use_item_id);
            if (!use_item) {
                return G_LOGIC_ERROR;
            }
            if (use_item->info() != recast_info->use_item()) {
                return G_LOGIC_ERROR;
            }
            if (use_item->used()) {
                return G_LOGIC_ERROR;
            }
        }

        player->use_money(recast_info->price());
        for (unsigned use_item_id : req->use_items) {
            player->bag()->remove_item(use_item_id);
        }
        source_item->info(recast_info->target());

        DB_Recast msg;
        msg.req->id(player->id());
        msg.req->value_opts = the_value_opts();
        msg.req->item_opts = the_bag_opts();
        call(msg);

        if (source_item->info()->quality() >= G_QUALITY_5) {
            AS_SystemNotify msg;
            msg.req->msg_id = 6;
            player->make_chat_info(msg.req->player);
            msg.req->params.push_back(source_item->info()->id());
            the_app->network()->broadcast(msg);
        }
        return 0;
    }
};

GX_SERVLET_REGISTER(CL_RecastServlet, true);

