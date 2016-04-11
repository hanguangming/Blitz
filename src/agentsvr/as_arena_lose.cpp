#include "agentsvr.h"

struct AS_ArenaLoseServlet : Servlet<AS_ArenaLose> {
    virtual int execute(request_type *req, response_type *rsp) {
        G_Player *player = G_PlayerMgr::instance()->get_player(req->id());
        if (!player) {
            return GX_ENOTEXISTS;
        }

        player->fight_report()->add(req->fight_info);
        if (player->state() == G_PLAYER_STATE_ONLINE) {
            CL_NotifyFightReport msg;
            player->fight_report()->to_opt(msg.req->infos);
            player->send(msg);
        }
        return 0;
    }
};

GX_SERVLET_REGISTER(AS_ArenaLoseServlet, false);

