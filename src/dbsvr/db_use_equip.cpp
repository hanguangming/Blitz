#include "dbsvr.h"

struct DB_UseEquipServlet : DB_Servlet<DB_UseEquip> {
    virtual int execute(request_type *req, response_type *rsp) {
        apply_soldier_value_opts(req->id(), req->value_opts);
        apply_item_opts(req->id(), req->item_opts);
        return 0;
    }
};

GX_SERVLET_REGISTER(DB_UseEquipServlet, false);

