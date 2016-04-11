#include "worldsvr.h"

struct WS_PlayerTouchServlet : WS_Servlet<WS_PlayerTouch> {
    virtual int execute(G_World *world, G_WorldPlayer *player, request_type *req, response_type *rsp) {
        return 0;
    }
};

GX_SERVLET_REGISTER(WS_PlayerTouchServlet, false);

