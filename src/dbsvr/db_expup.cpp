#include "dbsvr.h"

struct DB_ExpUpServlet : DB_Servlet<DB_ExpUp> {
    virtual int execute(request_type *req, response_type *rsp) {
        apply_item_opts(req->id(), req->item_opts);
        apply_soldier_value_opts(req->id(), req->value_opts);
        return 0;
    }
};

GX_SERVLET_REGISTER(DB_ExpUpServlet, false);
