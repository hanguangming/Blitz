#include "agentsvr.h"
#include "libgame/player.h"

struct AS_LoginServlet : Servlet<AS_Login> {
public:
    virtual int execute(request_type *req, response_type *rsp) {
        G_Player *player = G_PlayerMgr::instance()->prepare_login(req->id());
        if (!player) {
            return GX_ENOTEXISTS;
        }
        rsp->key = player->session_key();
        auto instance = the_app->network()->instance(SERVLET_CLIENT, the_app->id());
        rsp->host = instance.ap();
        rsp->port = instance.port();
        return 0;
    }
};

GX_SERVLET_REGISTER(AS_LoginServlet, false);


