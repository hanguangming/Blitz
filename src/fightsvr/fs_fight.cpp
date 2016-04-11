#include "fightsvr.h"
#include "libgame/fight.h"

struct FS_FightServlet : Servlet<FS_Fight> {
public:
    virtual int execute(request_type *req, response_type *rsp) {
        if (!G_FightCalcMgr::instance()->call(req->info, rsp->info)) {
            return GX_EFAIL;
        }
        return 0;
    }
};

GX_SERVLET_REGISTER(FS_FightServlet, false);
