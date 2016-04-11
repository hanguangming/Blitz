#include "agentsvr.h"

struct AS_SystemNotifyServlet : Servlet<AS_SystemNotify> {
    virtual int execute(request_type *req) {
        G_PlayerMgr::instance()->broadcast_system_notify(req);
        return 0;
    }
};

GX_SERVLET_REGISTER(AS_SystemNotifyServlet, false);

