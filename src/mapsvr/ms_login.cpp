#include "mapsvr.h"

struct MS_LoginServlet : Servlet<MS_Login> {
    virtual int execute(request_type *req, response_type *rsp) {
        G_Map::instance()->login(req->id(), req->info, req->key);
        return 0;
    }
};


GX_SERVLET_REGISTER(MS_LoginServlet, false);



