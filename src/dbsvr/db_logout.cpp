#include "dbsvr.h"

struct DB_LogoutServlet : DB_Servlet<DB_Logout> {
    virtual int execute(request_type *req, response_type *rsp) {
        exec(_updatePlayer, req->logout_time, req->id());
        return 0;
    }

    GX_STMT(_updatePlayer, "update player set logout_time = ? where uid = ?", uint64_t, unsigned);
};

GX_SERVLET_REGISTER(DB_LogoutServlet, false);

