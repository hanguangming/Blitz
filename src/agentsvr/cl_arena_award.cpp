#include "agentsvr.h"
#include "worldsvr/ws_arena_award.h"
#include "dbsvr/db_arena_award.h"
#include "libgame/arena_award.h"

struct CL_ArenaAwardServlet : CL_Servlet<CL_ArenaAward> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        WS_ArenaAward ws_msg;
        ws_msg.req->id(player->id());
        if (call(ws_msg)) {
            return -1;
        }

        const G_ArenaAwardInfo *award = G_ArenaAwardMgr::instance()->get_info(ws_msg.rsp->rank);
        if (award) {
            award->award()->exec(player);
        }

        DB_ArenaAward msg;
        msg.req->id(player->id());
        msg.req->item_opts = the_bag_opts();
        msg.req->value_opts = the_value_opts();
        msg.req->arena = ws_msg.rsp->arena;
        msg.req->arena2 = ws_msg.rsp->arena2;
        msg.req->arena_day = ws_msg.rsp->arena_day;
        call(msg);
        return 0;
    }
};

GX_SERVLET_REGISTER(CL_ArenaAwardServlet, true);

