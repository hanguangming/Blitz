#include "agentsvr.h"
#include "libgame/param.h"
#include "dbsvr/db_shadow.h"
#include "mapsvr/ms_shadow.h"

struct CL_ShadowServlet : CL_Servlet<CL_Shadow> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        unsigned num = player->values().get(G_VALUE_SHADOW);
        G_Money money;
        bool use_money = false;

        if (num >= G_ParamMgr::instance()->free_shadow_num()) {
            num -= G_ParamMgr::instance()->free_shadow_num();
            
            money = G_ParamMgr::instance()->shadow_define_price();
            money = money + G_ParamMgr::instance()->shadow_grow_price() * (num / G_ParamMgr::instance()->shadow_grow_times());
            if (!player->has_money(money)) {
                return false;
            }
            use_money = true;
        }

        unsigned form_id = player->values().get(G_VALUE_FORMATION_PVP);
        G_Formation *form = player->formations()->formation(form_id);
        if (!form) {
            return -1;
        }

        do {
            MS_Shadow msg;
            msg.req->id(player->id());
            player->corps()->get_fight_info(form, msg.req->corps);
            call(msg);
            if (!msg.rsp->ok) {
                return 0;
            }
        } while (0);

        player->add_shadow();
        if (use_money) {
            player->use_money(money);
        }

        do {
            DB_Shadow msg;
            msg.req->id(player->id());
            msg.req->value_opts = the_value_opts();
            int n = call(msg);
            if (n) {
                return n;
            }
        } while (0);

        return 0;
    }
};

GX_SERVLET_REGISTER(CL_ShadowServlet, true);

