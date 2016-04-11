#include "agentsvr.h"
#include "dbsvr/db_forge.h"
#include "libgame/shop.h"

struct CL_ForgeRefreshServlet : CL_Servlet<CL_ForgeRefresh> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        if (req->type >= G_FORGE_UNKNOWN) {
            return -1;
        }

        unsigned cd = G_CD_UNKNOWN;
        switch (req->type) {
        case G_FORGE_LOW:
            cd = G_CD_FORGE_LOW;
            break;
        case G_FORGE_MIDDLE:
            cd = G_CD_FORGE_MIDDLE;
            break;
        case G_FORGE_HIGH:
            if (!player->vip()->forge_high()) {
                return -1;
            }
            cd = G_CD_FORGE_HIGH;
            break;
        default:
            for (auto &item : player->forge()->items()) {
                if (item.info()) {
                    return -1;
                }
            }
            break;
        }

        bool use_item = false;
        if (cd != G_CD_UNKNOWN) {
            if (player->cooldown()->get(cd)) {
                const G_ForgeInfo *forge_info = G_ForgeMgr::instance()->get_forge(req->type);
                if (!player->bag()->has_item(forge_info->use_item(), forge_info->use_count())) {
                    return GX_ELESS;
                }
                player->bag()->remove_item(forge_info->use_item(), forge_info->use_count());
                use_item = true;
            }
        }


        player->forge()->exec(req->type);
        if (cd != G_CD_UNKNOWN && !use_item) {
            player->cooldown()->set(cd);
        }

        DB_ForgeRefresh msg;
        msg.req->id(player->id());
        msg.req->item_opts = the_bag_opts();
        msg.req->cd_opts = the_cd_opts();

        unsigned i = 0;
        for (auto &item : player->forge()->items()) {
            msg.req->forge_opts.emplace_back();
            auto &opt = msg.req->forge_opts.back();
            opt.index = i++;
            opt.id = item.info() ? item.info()->id() : 0;
            opt.used = item.used();
        }

        call(msg);

        CL_NotifyForge notify;
        notify.req->items = std::move(msg.req->forge_opts);
        send(notify);
        return 0;
    }
};

GX_SERVLET_REGISTER(CL_ForgeRefreshServlet, true);

struct CL_ForgeBuyServlet : CL_Servlet<CL_ForgeBuy> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        if (req->index >= G_FORGE_NUM) {
            return -1;
        }

        G_ForgeItem &item = const_cast<G_ForgeItem &>(player->forge()->items()[req->index]);
        if (!item.info()) {
            return GX_ENOTEXISTS;
        }
        if (item.used()) {
            return GX_EREADY;
        }

        const G_ShopItemInfo *shop_item = G_ShopMgr::instance()->get_info(G_FORGE_SHOP, item.info()->id());
        if (!shop_item) {
            return GX_EPARAM;
        }

        if (!player->has_money(shop_item->price())) {
            return GX_ELESS;
        }

        player->use_money(shop_item->price());
        player->bag()->put_item(item.info(), 1);
        item.use();

        DB_ForgeBuy msg;
        msg.req->id(player->id());
        msg.req->value_opts = the_value_opts();
        msg.req->item_opts = the_bag_opts();
        msg.req->index = req->index;

        call(msg);

        CL_NotifyForge notify;
        notify.req->items.emplace_back();
        auto &notify_item = notify.req->items.back();
        notify_item.index = req->index;
        notify_item.used = true;
        notify_item.id = item.info()->id();
        send(notify);

        if (item.info()->quality() >= G_QUALITY_4) {
            AS_SystemNotify msg;
            msg.req->msg_id = 4;
            player->make_chat_info(msg.req->player);
            msg.req->params.push_back(item.info()->id());
            the_app->network()->broadcast(msg);
        }

        return 0;
    }
};

GX_SERVLET_REGISTER(CL_ForgeBuyServlet, true);

