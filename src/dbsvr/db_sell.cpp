#include "dbsvr.h"

struct DB_SellServlet : DB_Servlet<DB_Sell> {
    virtual int execute(request_type *req, response_type *rsp) {
        apply_value_opts(req->id(), req->value_opts);
        apply_item_opts(req->id(), req->item_opts);
        return 0;
    }
};

GX_SERVLET_REGISTER(DB_SellServlet, false);

