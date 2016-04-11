#include "dbsvr.h"

struct DB_TaskUpdateServlet : DB_Servlet<DB_TaskUpdate> {
    virtual int execute(request_type *req, response_type *rsp) {
        apply_task_opts(req->id(), req->task_opts);
        return 0;
    }
};

GX_SERVLET_REGISTER(DB_TaskUpdateServlet, false);

struct DB_TaskFinishServlet : DB_Servlet<DB_TaskFinish> {
    virtual int execute(request_type *req, response_type *rsp) {
        apply_task_opts(req->id(), req->task_opts);
        apply_item_opts(req->id(), req->item_opts);
        apply_value_opts(req->id(), req->value_opts);
        return 0;
    }
};

GX_SERVLET_REGISTER(DB_TaskFinishServlet, false);

