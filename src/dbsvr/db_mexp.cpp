#include "dbsvr.h"

struct DB_MExpServlet : DB_Servlet<DB_MExp> {
    virtual int execute(request_type *req, response_type *rsp) {
        apply_value_opts(req->id(), req->value_opts);
        return 0;
    }
};

GX_SERVLET_REGISTER(DB_MExpServlet, false);

