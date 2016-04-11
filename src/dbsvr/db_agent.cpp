#include "dbsvr.h"

struct DB_AgentServlet : DB_Servlet<DB_Agent> {
    virtual int execute(request_type *req, response_type *rsp) {
        exec(_updateAgent, req->server, req->id() - 1, req->time);
        return 0;
    }

    GX_STMT(_updateAgent, "replace into agent (server, id, time) values (?, ?, ?)", unsigned, unsigned, uint64_t);
};

GX_SERVLET_REGISTER(DB_AgentServlet, false);

