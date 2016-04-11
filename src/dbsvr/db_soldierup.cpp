#include "dbsvr/dbsvr.h"

struct DB_SoldierUpServlet : DB_Servlet<DB_SoldierUp> {
    virtual int execute(request_type *req, response_type *rsp) {
        apply_item_opts(req->id(), req->item_opts);
        apply_soldier_opts(req->id(), req->soldier_opts);
        apply_soldier_value_opts(req->id(), req->value_opts);
        apply_formation_opts(req->id(), req->formations);
        apply_train_opts(req->id(), req->train_opts);
        return 0;
    }
};
GX_SERVLET_REGISTER(DB_SoldierUpServlet, false);


struct DB_HeroUpServlet : DB_Servlet<DB_HeroUp> {
    virtual int execute(request_type *req, response_type *rsp) {
        apply_item_opts(req->id(), req->item_opts);
        apply_soldier_opts(req->id(), req->soldier_opts);
        apply_soldier_value_opts(req->id(), req->value_opts);
        apply_formation_opts(req->id(), req->formations);
        apply_train_opts(req->id(), req->train_opts);
        return 0;
    }
};
GX_SERVLET_REGISTER(DB_HeroUpServlet, false);

