#include "agentsvr.h"
#include "libgame/stage.h"
#include "dbsvr/db_stage.h"
#include "libgame/param.h"

struct CL_StageServlet : CL_Servlet<CL_Stage> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        const G_StageInfo *info = G_StageMgr::instance()->get_info(req->id);
        if (!info) {
            return G_LOGIC_ERROR;
        }

        if (info->id() > player->stage()) {
            if (!player->stage()) {
                if (info != G_StageMgr::instance()->first()) {
                    return G_LOGIC_ERROR;
                }
            }
            else if (info->id() != (player->stage() + 1)) {
                return G_LOGIC_ERROR;
            }
        }

        unsigned tiger_count = 0;
        unsigned tiger_times = 0;
        if (!player->has_moders(info->morders())) {
            tiger_times = player->use_tiger_times();
            tiger_count = tiger_times / G_ParamMgr::instance()->tiger_times() + G_ParamMgr::instance()->tiger_grow();
            if (!player->bag()->has_item(G_ParamMgr::instance()->tiger_item(), tiger_count)) {
                return G_LOGIC_ERROR;
            }
        }

        if (tiger_count) {
            player->bag()->remove_item(G_ParamMgr::instance()->tiger_item(), tiger_count);
            player->use_tiger_times(tiger_times + 1);
        }
        else {
            player->sub_morders(info->morders());
        }

        player->cur_stage(info->id());

        DB_Stage msg;
        msg.req->id(player->id());
        msg.req->value_opts = the_value_opts();
        msg.req->item_opts = the_bag_opts();
        call(msg);
        return 0;
    }
};

GX_SERVLET_REGISTER(CL_StageServlet, true);


struct CL_StageEndServlet : CL_Servlet<CL_StageEnd> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        unsigned stage = player->cur_stage();
        if (!stage) {
            return G_LOGIC_ERROR;
        }

        const G_StageInfo *info = G_StageMgr::instance()->get_info(stage);
        if (!info) {
            return G_LOGIC_ERROR;
        }

        player->cur_stage(0);

        const G_AwardInfo *award = nullptr;

        if (req->win) {
            if (stage > player->stage()) {
                player->stage(stage);
            }
            award = info->win_award();
        }
        else {
            award = info->lose_award();
        }

        if (award) {
            award->exec(player, 1, &rsp->awards);
        }

        DB_Stage msg;
        msg.req->id(player->id());
        msg.req->value_opts = the_value_opts();
        msg.req->item_opts = the_bag_opts();
        call(msg);
        return 0;
    }
};

GX_SERVLET_REGISTER(CL_StageEndServlet, true);

struct CL_StageBatchServlet : CL_Servlet<CL_StageBatch> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        if (req->stage > player->stage()) {
            return G_LOGIC_ERROR;
        }
        if (player->stage() < G_ParamMgr::instance()->stage_batch_stage_limit()) {
            return G_LOGIC_ERROR;
        }
        if (req->times > G_ParamMgr::instance()->stage_batch_times_limit()) {
            return G_LOGIC_ERROR;
        }

        const G_StageInfo *info = G_StageMgr::instance()->get_info(req->stage);

        unsigned tiger_count = 0;
        unsigned tiger_times = player->use_tiger_times();
        unsigned morders = 0;

        for (unsigned i = 0; i < req->times; ++i) {
            if (player->has_moders(morders + info->morders())) {
                morders += info->morders();
            }
            else {
                tiger_count += tiger_times / G_ParamMgr::instance()->tiger_times() + G_ParamMgr::instance()->tiger_grow();
                tiger_times++;
            }
        }

        if (tiger_count) {
            if (!player->bag()->has_item(G_ParamMgr::instance()->tiger_item(), tiger_count)) {
                return G_LOGIC_ERROR;
            }
            player->bag()->remove_item(G_ParamMgr::instance()->tiger_item(), tiger_count);
            player->use_tiger_times(tiger_times);
        }

        if (morders) {
            player->sub_morders(morders);
        }

        const G_AwardInfo *award = info->win_award();

        if (award) {
            award->exec(player, req->times, &rsp->awards);
        }

        DB_Stage msg;
        msg.req->id(player->id());
        msg.req->value_opts = the_value_opts();
        msg.req->item_opts = the_bag_opts();
        call(msg);

        return 0;
    }
};

GX_SERVLET_REGISTER(CL_StageBatchServlet, true);

