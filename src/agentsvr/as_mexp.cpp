#include "agentsvr.h"
#include "dbsvr/db_mexp.h"

struct AS_MExpServlet : AS_Servlet<AS_MExp> {
public:
    virtual int execute(G_Player *player, request_type *req) {
        unsigned value = player->mexp();
        value += req->mexp;
        if (value > G_MEXP_MAX) {
            value = G_MEXP_MAX;
        }

        if (value != player->mexp()) {
            player->mexp(value);

            DB_MExp msg;
            msg.req->id(player->id());
            msg.req->value_opts = the_value_opts();
            call(msg);
        }

        return 0;
    }
};

GX_SERVLET_REGISTER(AS_MExpServlet, true);

