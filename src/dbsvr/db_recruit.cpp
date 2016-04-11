#include "dbsvr/dbsvr.h"

struct DB_RecruitServlet : DB_Servlet<DB_Recruit> {
    virtual int execute(request_type *req, response_type *rsp) {
        apply_value_opts(req->id(), req->value_opts);
        apply_item_opts(req->id(), req->item_opts);
        apply_cooldown_opts(req->id(), req->cd_opts);
        return 0;
    }
};

GX_SERVLET_REGISTER(DB_RecruitServlet, false);
