#include "dbsvr.h"

struct DB_ChatServlet : DB_Servlet<DB_Chat> {
    virtual int execute(request_type *req, response_type *rsp) {
        apply_value_opts(req->id(), req->value_opts);
        return 0;
    }
};

GX_SERVLET_REGISTER(DB_ChatServlet, false);

