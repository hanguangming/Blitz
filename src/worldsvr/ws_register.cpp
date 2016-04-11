#include "worldsvr.h"
#include "idsvr/id_gen.h"
#include "dbsvr/db_account.h"
#include "agentsvr/as_register.h"

struct WS_RegisterServlet : Servlet<WS_Register> {
    virtual int execute(request_type *req, response_type *rsp) {
        G_WorldPlayer *player = G_World::instance()->get_player_by_name(req->nickname);
        if (player) {
            return GX_EDUP;
        }

        ID_Gen id_msg;
        id_msg.req->id(1);
        id_msg.req->type = ID_GEN_ACCOUNT;
        call(id_msg);

        player = G_World::instance()->add_player(id_msg.rsp->id, req->nickname, req->side);
        if (!player) {
            return GX_EDUP;
        }

        G_World::instance()->arena()->add_player(player);
        G_World::instance()->soldier_ranking_list()->add(player);
        G_World::instance()->score_ranking_list()->add(player);

        DB_AccountRegister db_msg;
        db_msg.req->id(player->id());
        db_msg.req->user = req->user;
        db_msg.req->passwd = req->passwd;
        db_msg.req->platform = req->platform;
        db_msg.req->nickname = req->nickname;
        db_msg.req->side = req->side;
        db_msg.req->server = the_server_id;
        db_msg.req->arena = player->arena();
        unsigned id = player->id();
        db_msg.req->lb = hash_iterative(&id, sizeof(id)) & 0xffff;
        call(db_msg);

        AS_Register as_msg;
        as_msg.req->id(player->id());
        return call(as_msg);
    }
};

GX_SERVLET_REGISTER(WS_RegisterServlet, true);

