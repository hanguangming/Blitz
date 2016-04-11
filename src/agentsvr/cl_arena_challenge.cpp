#include "agentsvr.h"
#include "worldsvr/ws_player_touch.h"
#include "worldsvr/ws_arena_challenge.h"
#include "dbsvr/db_arena_challenge.h"
#include "libgame/param.h"

struct CL_ArenaChallengeServlet : CL_Servlet<CL_ArenaChallenge> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        if (req->uid == player->id()) {
            return G_LOGIC_ERROR;
        }
        if (player->values().get(G_VALUE_CHALLENGE)) {
            player->sub_challenge();
        }
        else {
            if (!player->bag()->has_item(G_ParamMgr::instance()->challenge_item(), 1)) {
                return G_LOGIC_ERROR;
            }
            player->bag()->remove_item(G_ParamMgr::instance()->challenge_item(), 1);
        }

        do {
            DB_ArenaChallengeStart msg;
            msg.req->id(player->id());
            msg.req->value_opts = the_value_opts();
            msg.req->item_opts = the_bag_opts();
            call(msg);
        } while (0);

        unsigned form_id = player->values().get(G_VALUE_FORMATION_ARENA);
        G_Formation *form = player->formations()->formation(form_id);
        if (!player->corps()->get_fight_info(form, rsp->fight_info.attacker)) {
            return G_LOGIC_ERROR;
        }

        do {
            AS_FightInfo msg;
            msg.req->id(req->uid);
            msg.req->formation = G_FORMATION_ARENA;
            if (call(msg)) {
                return G_LOGIC_ERROR;
            }
            rsp->fight_info.defender = msg.rsp->info;
        } while (0);
        rsp->fight_info.seed = rand();
        G_FightInfo info = rsp->fight_info;
        if (!player->fight_call(info, true)) {
            return G_LOGIC_ERROR;
        }

        const G_AwardInfo *award = nullptr;
        switch (info.result) {
        case G_FIGHT_ATTACKER_WIN: {
            WS_ArenaChallenge msg;
            msg.req->id(player->id());
            msg.req->defender = rsp->fight_info.defender.uid;
            if (call(msg)) {
                return G_LOGIC_ERROR;
            }

            do {
                AS_ArenaLose msg;
                msg.req->id(rsp->fight_info.defender.uid);
                msg.req->fight_info = rsp->fight_info;
                call(msg);
            } while (0);

            award = G_ParamMgr::instance()->challenge_win_award();
            break;
        }
        case G_FIGHT_DEFENDER_WIN:
            award = G_ParamMgr::instance()->challenge_lose_award();
            break;
        default:
            return G_LOGIC_ERROR;
        }

        award->exec(player);

        do {
            DB_ArenaChallengeAward msg;
            msg.req->id(player->id());
            msg.req->item_opts = the_bag_opts();
            msg.req->value_opts = the_value_opts();
            call(msg);
        } while (0);

        rsp->award = award->id();
        return 0;
    }
};

GX_SERVLET_REGISTER(CL_ArenaChallengeServlet, true);


