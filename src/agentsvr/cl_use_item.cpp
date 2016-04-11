#include "agentsvr.h"
#include "dbsvr/db_use_item.h"
#include "libgame/soldier.h"
#include "libgame/award.h"
#include "agentsvr/as_system_notify.h"

struct CL_UseItemServlet : CL_Servlet<CL_UseItem> {
public:
    int use_item_coin(G_Player *player, G_BagItem *item) {
        G_Money money;
        money.coin += item->info()->value() * item->count();
        player->add_money(money);
        player->bag()->remove_item(item->id());

        DB_UseCoinItem msg;
        msg.req->id(player->id());
        msg.req->value_opts = the_value_opts();
        msg.req->item_opts = the_bag_opts();
        call(msg);
        return 0;
    }

    int use_item_money(G_Player *player, G_BagItem *item) {
        G_Money money;
        money.money += item->info()->value() * item->count();
        player->add_money(money);
        player->bag()->remove_item(item->id());

        DB_UseMoneyItem msg;
        msg.req->id(player->id());
        msg.req->value_opts = the_value_opts();
        msg.req->item_opts = the_bag_opts();
        call(msg);
        return 0;
    }

    int use_item_exp(G_Player *player, G_BagItem *item) {
        player->add_exp(item->info()->value() * item->count()) ;
        player->bag()->remove_item(item->id());

        DB_UseExpItem msg;
        msg.req->id(player->id());
        msg.req->value_opts = the_value_opts();
        msg.req->item_opts = the_bag_opts();
        call(msg);
        return 0;
    }

    int use_item_box(G_Player *player, G_BagItem *item) {
        if (the_player()->level() < item->info()->level_limit()) {
            return G_LOGIC_ERROR;
        }

        unsigned award_id = item->info()->value();
        const G_AwardInfo *award = G_AwardMgr::instance()->get_info(award_id);
        if (award) {
            for (unsigned i = 0; i < item->count(); ++i) {
                award->exec(player);
            }
        }
        player->bag()->remove_item(item->id());

        DB_UseBoxItem msg;
        msg.req->id(player->id());
        msg.req->value_opts = the_value_opts();
        msg.req->item_opts = the_bag_opts();
        call(msg);
        return 0;
    }

    int use_item_soul(G_Player *player, G_BagItem *item) {
        const G_SoldierMakeInfo *info = G_SoldierMakeMgr::instance()->get_info(item->info()->id());
        if (!info) {
            return G_LOGIC_ERROR;
        }

        assert(item->info() == info->use_item());
        if (player->hero_limit() <= player->corps()->hero_count()) {
            return G_LOGIC_ERROR;
        }
        if (!player->bag()->has_item(info->use_item(), info->use_count())) {
            return G_LOGIC_ERROR;
        }
        const G_SoldierInfo *soldier = info->get(player);
        if (!soldier) {
            return G_LOGIC_ERROR;
        }

        player->bag()->remove_item(info->use_item(), info->use_count());
        player->corps()->add(soldier);

        DB_UseSoulItem msg;
        msg.req->id(player->id());
        msg.req->value_opts = the_soldier_value_opts();
        msg.req->item_opts = the_bag_opts();
        call(msg);

        if (soldier->quality() >= G_QUALITY_4) {
            AS_SystemNotify msg;
            msg.req->msg_id = 3;
            player->make_chat_info(msg.req->player);
            msg.req->params.push_back(soldier->id());
            the_app->network()->broadcast(msg);
        }

        return 0;
    }

    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        G_BagItem *item = player->bag()->get_item(req->item_id);
        if (!item) {
            return G_LOGIC_ERROR;
        }
        if (!req->count) {
            return G_LOGIC_ERROR;
        }
        if (item->count() < req->count) {
            return G_LOGIC_ERROR;
        }

        int r = G_LOGIC_ERROR;
        switch (item->info()->type()) {
        case G_ITYPE_COIN:
            r = use_item_coin(player, item);
            break;
        case G_ITYPE_MONEY:
            r = use_item_money(player, item);
            break;
        case G_ITYPE_EXP:
            r = use_item_exp(player, item);
            break;
        case G_ITYPE_SOUL1:
        case G_ITYPE_SOUL2:
            r = use_item_soul(player, item);
            break;
        case G_ITYPE_BOX:
            r = use_item_box(player, item);
            break;
        }
        return r;
    }
};

GX_SERVLET_REGISTER(CL_UseItemServlet, true);

