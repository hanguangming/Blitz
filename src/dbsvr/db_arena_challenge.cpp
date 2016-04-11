#include "dbsvr.h"

struct DB_ArenaChallengeStartServlet : DB_Servlet<DB_ArenaChallengeStart> {
    virtual int execute(request_type *req, response_type *rsp) {
        apply_item_opts(req->id(), req->item_opts);
        apply_value_opts(req->id(), req->value_opts);
        return 0;
    }
};
GX_SERVLET_REGISTER(DB_ArenaChallengeStartServlet, false);

struct DB_ArenaChallengeAwardServlet : DB_Servlet<DB_ArenaChallengeAward> {
    virtual int execute(request_type *req, response_type *rsp) {
        apply_item_opts(req->id(), req->item_opts);
        apply_value_opts(req->id(), req->value_opts);
        return 0;
    }
};
GX_SERVLET_REGISTER(DB_ArenaChallengeAwardServlet, false);

struct DB_ArenaChallengeEndServlert : DB_Servlet<DB_ArenaChallengeEnd> {
    virtual int execute(request_type *req, response_type *rsp) {
        exec(_updateArena, req->attacker_arena, req->attacker_arena2, req->attacker_arena_day, req->attacker);
        exec(_updateArena, req->defender_arena, req->defender_arena2, req->defender_arena_day, req->defender);
        return 0;
    }

    GX_STMT(_updateArena,
            "update player set arena = ?, arena2 = ?, arena_day = ? where uid = ?",
            unsigned, unsigned, unsigned, unsigned);
};

GX_SERVLET_REGISTER(DB_ArenaChallengeEndServlert, false);

