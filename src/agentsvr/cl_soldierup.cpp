#include "agentsvr.h"
#include "libgame/soldierup.h"
#include "dbsvr/db_soldierup.h"
#include "agentsvr/as_system_notify.h"

struct CL_SoldierUpServlet : CL_Servlet<CL_SoldierUp> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        const G_SoldierUpInfo *info = G_SoldierUpMgr::instance()->get_info(req->id);
        if (!info) {
            return G_LOGIC_ERROR;
        }
        if (!info->soldier()) {
            return G_LOGIC_ERROR;
        }
        if (!info->target()) {
            return G_LOGIC_ERROR;
        }
        if (info->target()->quality() > player->tech()->soldierup()) {
            return G_LOGIC_ERROR;
        }
        if (info->soldier()->is_hero()) {
            return G_LOGIC_ERROR;
        }
        G_Soldier *source = player->corps()->get(info->soldier());
        if (!source) {
            return G_LOGIC_ERROR;
        }
        G_Soldier *target = player->corps()->get(info->target());
        if (target) {
            return G_LOGIC_ERROR;
        }
        if (!player->bag()->has_item(info->use_item(), info->use_count())) {
            return G_LOGIC_ERROR;
        }
        if (!player->has_money(info->price())) {
            return G_LOGIC_ERROR;
        }

        target = player->corps()->add(info->target(), source);
        player->formations()->change_soldier(source->info(), target->info());
        player->corps()->remove(info->soldier()->id());

        player->bag()->remove_item(info->use_item(), info->use_count());
        player->use_money(info->price());

        DB_SoldierUp msg;
        msg.req->id(player->id());
        msg.req->item_opts = the_bag_opts();
        msg.req->soldier_opts = the_soldier_opts();
        msg.req->value_opts = the_soldier_value_opts();
        msg.req->formations = the_formation_opts();
        msg.req->train_opts = the_train_opts();
        call(msg);

        if (info->target()->quality() >= G_QUALITY_4) {
            AS_SystemNotify msg;
            msg.req->msg_id = 5;
            player->make_chat_info(msg.req->player);
            msg.req->params.push_back(info->target()->id());
            the_app->network()->broadcast(msg);
        }
        return 0;
    }
};

GX_SERVLET_REGISTER(CL_SoldierUpServlet, true);

struct CL_HeroUpServlet : CL_Servlet<CL_HeroUp> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        const G_SoldierUpInfo *info = G_SoldierUpMgr::instance()->get_info(req->id);
        if (!info) {
            return G_LOGIC_ERROR;
        }
        if (!info->soldier()) {
            return G_LOGIC_ERROR;
        }
        if (!info->target()) {
            return G_LOGIC_ERROR;
        }
        if (!info->soldier()->is_hero()) {
            return G_LOGIC_ERROR;
        }
        G_Soldier *source = player->corps()->get(info->soldier());
        if (!source) {
            return G_LOGIC_ERROR;
        }
        G_Soldier *target = player->corps()->get(info->target());
        if (target) {
            return G_LOGIC_ERROR;
        }
        if (req->use.size() != info->use_count()) {
            return G_LOGIC_ERROR;
        }
        if (!player->has_money(info->price())) {
            return G_LOGIC_ERROR;
        }

        std::set<unsigned> sets;
        for (auto id : req->use) {
            if (id == req->id) {
                return G_LOGIC_ERROR;
            }
            if (!sets.emplace(id).second) {
                return G_LOGIC_ERROR;
            }
            G_Soldier *soldier = player->corps()->get(id);
            if (!soldier) {
                return G_LOGIC_ERROR;
            }
            if (!soldier->info()->is_hero()) {
                return G_LOGIC_ERROR;
            }
            if (soldier->info()->quality() != info->use_quality()) {
                return G_LOGIC_ERROR;
            }
        }

        for (auto id : req->use) {
            player->corps()->remove(id);
        }

        target = player->corps()->add(info->target(), source);
        player->formations()->change_soldier(source->info(), target->info());
        player->corps()->remove(info->soldier()->id());

        player->use_money(info->price());

        DB_HeroUp msg;
        msg.req->id(player->id());
        msg.req->soldier_opts = the_soldier_opts();
        msg.req->value_opts = the_soldier_value_opts();
        msg.req->formations = the_formation_opts();
        msg.req->item_opts = the_bag_opts();
        msg.req->train_opts = the_train_opts();
        call(msg);

        if (info->target()->quality() >= G_QUALITY_4) {
            AS_SystemNotify msg;
            msg.req->msg_id = 2;
            player->make_chat_info(msg.req->player);
            msg.req->params.push_back(info->target()->id());
            the_app->network()->broadcast(msg);
        }

        return 0;
    }
};

GX_SERVLET_REGISTER(CL_HeroUpServlet, true);

