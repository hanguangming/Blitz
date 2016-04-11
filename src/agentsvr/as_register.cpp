#include "agentsvr.h"

struct AS_RegisterServlet : Servlet<AS_Register> {
    virtual int execute(request_type *req, response_type *rsp) {
        G_PlayerMgr::instance()->register_player(req->id());
        return 0;
    }
};

GX_SERVLET_REGISTER(AS_RegisterServlet, false);

