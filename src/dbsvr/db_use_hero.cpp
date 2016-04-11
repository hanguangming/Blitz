#include "dbsvr.h"

struct DB_UseHeroServlet : DB_Servlet<DB_UseHero> {
    virtual int execute(request_type *req, response_type *rsp) {
        apply_soldier_value_opts(req->id(), req->value_opts);
        return 0;
    }
};

GX_SERVLET_REGISTER(DB_UseHeroServlet, false);
