#include "dbsvr.h"

class DB_ShopBuyServlet : public DB_Servlet<DB_ShopBuy> {
public:
    virtual int execute(request_type *req, response_type *rsp) {
        apply_item_opts(req->id(), req->item_opts);
        apply_value_opts(req->id(), req->value_opts);
        apply_soldier_value_opts(req->id(), req->soldier_value_opts);
        return 0;
    }
};

GX_SERVLET_REGISTER(DB_ShopBuyServlet, false);

