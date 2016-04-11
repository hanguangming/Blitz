#include "dbsvr.h"

struct DB_ArenaAwardServlet : DB_Servlet<DB_ArenaAward> {
    virtual int execute(request_type *req, response_type *rsp) {
        apply_item_opts(req->id(), req->item_opts);
        apply_value_opts(req->id(), req->value_opts);
        exec(_updateArena, req->arena, req->arena2, req->arena_day, req->id());
        return 0;
    }

    GX_STMT(_updateArena,
            "update player set arena = ?, arena2 = ?, arena_day = ? where uid = ?",
            unsigned, unsigned, unsigned, unsigned);
};

GX_SERVLET_REGISTER(DB_ArenaAwardServlet, false);

