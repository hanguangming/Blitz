#include "agentsvr.h"
#include "dbsvr/db_gm.h"
#include "dbsvr/db_employ.h"

template <typename _T, typename _Request = typename _T::request_type, typename _Response = typename _T::response_type>
class GM_Servlet : public Servlet<_T, _Request, _Response> {
public:
    typedef _T type;
    typedef typename _T::request_type request_type;
    typedef typename _T::response_type response_type;

    int execute(request_type *req, response_type *rsp) override {
        G_AgentContext *ctx = G_AgentContext::instance();
        G_PlayerStub *stub = G_PlayerMgr::instance()->get_stub(req->id());
        if (!stub) {
            rsp->result = "1, no player";
            return 0;
        }
        if (!stub->attach(ctx)) {
            rsp->result = "1, no player";
            return 0;
        }
        G_Player *player = G_PlayerMgr::instance()->load_player(req->id());
        if (!player) {
            rsp->result = "1, no player";
            return 0;
        }

        if (player->state() != G_PLAYER_STATE_ONLINE) {
            rsp->result = "1, player not online";
            return 0;
        }
        return execute(player, req, rsp);
    }

    virtual int execute(G_Player *player, request_type *req, response_type *rsp) = 0;

    template <typename _Msg>
    void send(_Msg &msg) {
        if (the_context()->peer()) {
            if (this->dump_msg()) {
                msg.req->dump(nullptr, 0, the_context()->pool());
                the_context()->pool()->grow1('\0');
                log_debug("\n%s", (char*)the_context()->pool()->finish());
            }
            the_context()->peer()->send(_Msg::the_message_id, 0, msg.req);
        }
    }
};

struct GM_AddItemServlet : GM_Servlet<GM_AddItem> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        if (req->count > 1000) {
            rsp->result = "1, too more items.";
            return 0;
        }
        const G_ItemInfo *info = G_ItemMgr::instance()->get_info(req->item);
        if (!info) {
            rsp->result = "1, no item.";
            return 0;
        }
        player->bag()->put_item(info, req->count);

        DB_GMValueItem msg;
        msg.req->id(player->id());
        msg.req->item_opts = the_bag_opts();
        call(msg);
        return 0;
    }
};

GX_SERVLET_REGISTER(GM_AddItemServlet, true);

struct GM_AddMoneyServlet : GM_Servlet<GM_AddMoney> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        G_Money money;
        money = player->get_money();

        switch (req->type) {
        case 0:
            money.money = req->value;
            break;
        case 1:
            money.coin = req->value;
            break;
        case 2:
            money.honor = req->value;
            break;
        case 3:
            money.recruit = req->value;
            break;
        default:
            return 0;
        }

        player->set_money(money);

        DB_GMValueItem msg;
        msg.req->id(player->id());
        msg.req->value_opts = the_value_opts();
        call(msg);
        return 0;
    }
};

GX_SERVLET_REGISTER(GM_AddMoneyServlet, true);


struct GM_AddHeroServlet : GM_Servlet<GM_AddHero> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        const G_SoldierInfo *soldier = G_SoldierMgr::instance()->get_info(req->sid);
        if (!soldier) {
            rsp->result = "1, unknown soldier.";
            return 0;
        }
        if (!soldier->is_hero()) {
            rsp->result = "1, unknown soldier is not hero.";
            return 0;
        }
        if (!player->corps()->add(soldier, nullptr)) {
            rsp->result = "1, soldier already exists.";
            return 0;
        }

        DB_Employ msg;
        msg.req->id(player->id());
        msg.req->soldier_value_opts = the_soldier_value_opts();
        call(msg);

        return 0;
    }
};

GX_SERVLET_REGISTER(GM_AddHeroServlet, true);

struct GM_UpdateSoldierLevelServlet : GM_Servlet<GM_UpdateSoldierLevel> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        G_Soldier *soldier = player->corps()->get(req->sid);
        if (!soldier) {
            rsp->result = "1, soldier not exists.";
            return 0;
        }
        if (req->level > player->level()) {
            rsp->result = "1, soldier's level more than player.";
            return 0;
        }
        if (req->level == 0) {
            rsp->result = "1, bad level.";
            return 0;
        }

        soldier->gm_set_level(req->level);
        DB_Employ msg;
        msg.req->id(player->id());
        msg.req->soldier_value_opts = the_soldier_value_opts();
        call(msg);

        return 0;
    }
};

GX_SERVLET_REGISTER(GM_UpdateSoldierLevelServlet, true);

struct GM_UpdateLevelServlet : GM_Servlet<GM_UpdateLevel> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        const G_LevelInfo *info = G_LevelMgr::instance()->get_info(req->level);
        if (!info) {
            rsp->result = "1, level too large.";
            return 0;
        }

        player->gm_update_level(info);

        DB_GMValueItem msg;
        msg.req->id(player->id());
        msg.req->value_opts = the_value_opts();
        call(msg);
        return 0;
    }
};

GX_SERVLET_REGISTER(GM_UpdateLevelServlet, true);

struct GM_UpdateVipServlet : GM_Servlet<GM_UpdateVip> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        const G_VipInfo *info = G_VipMgr::instance()->get_info(req->level);
        if (!info) {
            rsp->result = "1, level too large.";
            return 0;
        }

        player->gm_update_vip(info);

        DB_GMValueItem msg;
        msg.req->id(player->id());
        msg.req->value_opts = the_value_opts();
        call(msg);
        return 0;
    }
};

GX_SERVLET_REGISTER(GM_UpdateVipServlet, true);

struct GM_UpdateStageServlet : GM_Servlet<GM_UpdateStage> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        player->gm_update_stage(req->stage);

        DB_GMValueItem msg;
        msg.req->id(player->id());
        msg.req->value_opts = the_value_opts();
        call(msg);
        return 0;
    }
};

GX_SERVLET_REGISTER(GM_UpdateStageServlet, true);

struct GM_AddExpServlet : GM_Servlet<GM_AddExp> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        if (req->exp) {
            player->add_exp(req->exp);

            DB_GMValueItem msg;
            msg.req->id(player->id());
            msg.req->value_opts = the_value_opts();
            call(msg);
        }
        return 0;
    }
};

GX_SERVLET_REGISTER(GM_AddExpServlet, true);

struct GM_UpdateMordersServlet : GM_Servlet<GM_UpdateMorders> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        player->gm_update_morders(req->morders);
        DB_GMValueItem msg;
        msg.req->id(player->id());
        msg.req->value_opts = the_value_opts();
        call(msg);
        return 0;
    }
};

GX_SERVLET_REGISTER(GM_UpdateMordersServlet, true);


struct GM_FightWithServlet : GM_Servlet<GM_FightWith> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        CL_NotifyFightInfoReq notify;
        unsigned form_id = player->values().get(G_VALUE_FORMATION_PVP);
        G_Formation *form = player->formations()->formation(form_id);
        player->corps()->get_fight_info(form, notify.info.attacker);

        if (req->target != player->id()) {
            AS_FightInfo info_msg;
            info_msg.req->id(req->target);
            info_msg.req->formation = G_FORMATION_PVP;
            if (call(info_msg)) {
                rsp->result = "1, unknown no target player.";
                return 0;
            }
            notify.info.defender = info_msg.rsp->info;
        }
        else {
            notify.info.defender = notify.info.attacker;
        }

        if (player->peer()) {
            player->peer()->send(CL_NotifyFightInfoReq::the_message_id, &notify);
        }
        return 0;
    }
};

GX_SERVLET_REGISTER(GM_FightWithServlet, true);

