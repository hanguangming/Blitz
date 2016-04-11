#include "game.h"
#include "libgame/g_gm.h"
#include "gm.h"

struct GM_UpdateTimeServlet : Servlet<GM_UpdateTime> {
    virtual int execute(request_type *req) {
        the_logic_offset = req->time;
        return 0;
    }
};

GX_SERVLET_REGISTER(GM_UpdateTimeServlet, false);


