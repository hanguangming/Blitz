#include "agentsvr.h"
#include "dbsvr/db_use_hero.h"

struct CL_UserHeroServlet : CL_Servlet<CL_UseHero> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        if (!player->corps()->use_hero(req->sid, req->use)) {
            return G_LOGIC_ERROR;
        }

        DB_UseHero msg;
        msg.req->id(player->id());
        msg.req->value_opts = the_soldier_value_opts();
        call(msg);
        return 0;
    }
};

GX_SERVLET_REGISTER(CL_UserHeroServlet, true);

