#include "dbsvr.h"

struct DB_TrainServlet : DB_Servlet<DB_Train> {
    virtual int execute(request_type *req, response_type *rsp) {
        apply_value_opts(req->id(), req->value_opts);
        apply_item_opts(req->id(), req->item_opts);
        apply_train_opts(req->id(), req->train_opts);
        apply_soldier_value_opts(req->id(), req->soldier_value_opts);
        return 0;
    }
};

GX_SERVLET_REGISTER(DB_TrainServlet, false);

struct DB_TrainCancelServlet : DB_Servlet<DB_TrainCancel> {
    virtual int execute(request_type *req, response_type *rsp) {
        apply_train_opts(req->id(), req->train_opts);
        apply_value_opts(req->id(), req->value_opts);
        return 0;
    }
};

GX_SERVLET_REGISTER(DB_TrainCancelServlet, false);

