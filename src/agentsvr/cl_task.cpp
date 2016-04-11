#include "agentsvr.h"
#include "dbsvr/db_task.h"

struct CL_TaskFinishServlet : CL_Servlet<CL_TaskFinish> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        const G_TaskInfo *task = G_TaskMgr::instance()->get_info(req->id);
        if (!task) {
            return -1;
        }
        if (!player->task()->finish(player, task)) {
            return -1;
        }
        if (task->award()) {
            task->award()->exec(player);
        }

        DB_TaskFinish msg;
        msg.req->id(player->id());
        msg.req->task_opts = the_task_opts();
        msg.req->item_opts = the_bag_opts();
        msg.req->value_opts = the_value_opts();
        return 0;
    }
};

GX_SERVLET_REGISTER(CL_TaskFinishServlet, true);

