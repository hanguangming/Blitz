#include "dbsvr.h"

struct DB_FormationSaveServlet : DB_Servlet<DB_FormationSave> {
    virtual int execute(request_type *req, response_type *rsp) {
        apply_formation_opts(req->id(), req->formations);
        return 0;
    }
};

GX_SERVLET_REGISTER(DB_FormationSaveServlet, false);

struct DB_FormationUseServlet : DB_Servlet<DB_FormationUse> {
    virtual int execute(request_type *req, response_type *rsp) {
        apply_value_opts(req->id(), req->value_opts);
        return 0;
    }
};

GX_SERVLET_REGISTER(DB_FormationUseServlet, false);

