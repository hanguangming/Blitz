#include "agentsvr.h"
#include "libgame/param.h"
#include "dbsvr/db_train.h"

struct CL_TrainServlet : CL_Servlet<CL_Train> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        G_Soldier *soldier = player->corps()->get(req->sid);
        if (!soldier) {
            return G_LOGIC_ERROR;
        }
        
        const G_TrainInfo *train_info = G_TrainMgr::instance()->get_info(req->type);
        if (!train_info) {
            return G_LOGIC_ERROR;
        }

        G_Money money;
        switch (req->type) {
        case G_TRAIN_LOW:
            money = soldier->level()->train_low_price();
            if (!player->has_money(money)) {
                return G_LOGIC_ERROR;
            }
            break;
        case G_TRAIN_MIDDLE:
            money = soldier->level()->train_middle_price();
            if (!player->has_money(money)) {
                return G_LOGIC_ERROR;
            }
            break;
        case G_TRAIN_HIGH:
            if (!player->vip()->train_high()) {
                return G_LOGIC_ERROR;
            }
            if (!player->bag()->has_item(G_ParamMgr::instance()->train_item(), 1)) {
                return G_LOGIC_ERROR;
            }
            break;
        default:
            return G_LOGIC_ERROR;
        }

        G_Train *train = soldier->info()->is_hero() ? player->hero_train() : player->soldier_train();
        if (train->count() >= player->vip()->train_limit()) {
            return G_LOGIC_ERROR;
        }

        if (!train->add(req->sid, train_info)) {
            return G_LOGIC_ERROR;
        }

        switch (req->type) {
        case G_TRAIN_LOW:
        case G_TRAIN_MIDDLE:
            player->use_money(money);
            break;
        case G_TRAIN_HIGH:
            player->bag()->remove_item(G_ParamMgr::instance()->train_item(), 1);
            break;
        default:
            return G_LOGIC_ERROR;
        }

        DB_Train msg;
        msg.req->id(player->id());
        msg.req->item_opts = the_bag_opts();
        msg.req->value_opts = the_value_opts();
        msg.req->train_opts = the_train_opts();
        msg.req->soldier_value_opts = the_soldier_value_opts();
        call(msg);
        return 0;
    }
};

GX_SERVLET_REGISTER(CL_TrainServlet, true);


struct CL_TrainCancelServlet : CL_Servlet<CL_TrainCancel> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        G_Soldier *soldier = player->corps()->get(req->sid);
        if (!soldier) {
            return G_LOGIC_ERROR;
        }
        G_Train *train = soldier->info()->is_hero() ? player->hero_train() : player->soldier_train();
        if (!train->cancel(req->sid)) {
            return G_LOGIC_ERROR;
        }


        DB_TrainCancel msg;
        msg.req->id(player->id());
        msg.req->train_opts = the_train_opts();
        msg.req->value_opts = the_value_opts();
        call(msg);

        return 0;
    }
};

GX_SERVLET_REGISTER(CL_TrainCancelServlet, true);

