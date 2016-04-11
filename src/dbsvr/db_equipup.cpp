#include "dbsvr/dbsvr.h"

struct DB_EquipUpServlet : DB_Servlet<DB_EquipUp> {
    virtual int execute(request_type *req, response_type *rsp) {
        apply_item_opts(req->id(), req->item_opts);
        apply_value_opts(req->id(), req->value_opts);
        return 0;
    }
};

GX_SERVLET_REGISTER(DB_EquipUpServlet, false);

