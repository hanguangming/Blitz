#include "worldsvr.h"
#include "dbsvr/db_arena_challenge.h"
#include "agentsvr/as_system_notify.h"

struct WS_ArenaChallengeServlet : WS_Servlet<WS_ArenaChallenge> {
    virtual int execute(G_World *world, G_WorldPlayer *player, request_type *req, response_type *rsp) {
        unsigned attacker = req->id();
        unsigned defender = req->defender;
        if (attacker == defender) {
            return GX_EPARAM;
        }

        G_WorldPlayer *attack_player = world->get_player(attacker);
        G_WorldPlayer *defend_player = world->get_player(defender);
        if (!attack_player || !defend_player) {
            return GX_EPARAM;
        }

        if (attack_player->arena() > defend_player->arena()) {
            world->arena()->swap(attack_player, defend_player);

            do {
                DB_ArenaChallengeEnd msg;
                msg.req->id(attacker + defender);
                msg.req->attacker = attack_player->id();
                msg.req->attacker_arena = attack_player->arena();
                msg.req->attacker_arena2 = attack_player->arena2();
                msg.req->attacker_arena_day = attack_player->arena_day();

                msg.req->defender = defend_player->id();
                msg.req->defender_arena = defend_player->arena();
                msg.req->defender_arena2 = defend_player->arena2();
                msg.req->defender_arena_day = defend_player->arena_day();
                call(msg);
            } while (0);

            if (attack_player->arena() == 1) {
                AS_SystemNotify msg;
                msg.req->msg_id = 7;
                msg.req->player.uid = player->id();
                msg.req->player.name = player->name();
                msg.req->player.vip = player->vip();
                msg.req->player.appearance = player->appearance();
                the_app->network()->broadcast(msg);
            }

        }
        return 0;
    }
};

GX_SERVLET_REGISTER(WS_ArenaChallengeServlet, true);

