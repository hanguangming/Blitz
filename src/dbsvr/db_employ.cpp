#include "dbsvr.h"

struct DB_EmployServlet : DB_Servlet<DB_Employ> {
    virtual int execute(request_type *req, response_type *rsp) {
        apply_value_opts(req->id(), req->value_opts);
        apply_soldier_value_opts(req->id(), req->soldier_value_opts);
        return 0;
    }
};
GX_SERVLET_REGISTER(DB_EmployServlet, false);

struct DB_FireServlet : DB_Servlet<DB_Fire> {
    virtual int execute(request_type *req, response_type *rsp) {
        apply_soldier_opts(req->id(), req->soldier_opts);
        apply_item_opts(req->id(), req->item_opts);
        apply_formation_opts(req->id(), req->formation_opts);
        apply_train_opts(req->id(), req->train_opts);
        return 0;
    }
};
GX_SERVLET_REGISTER(DB_FireServlet, false);

