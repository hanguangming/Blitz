#include "agentsvr.h"

struct CL_PlayerSoldierInfoServlet : CL_Servlet<CL_PlayerSoldierInfo> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        if (req->uid == player->id()) {
            for (unsigned i = G_QUALITY_UNKNOWN - 1; i >= G_QUALITY_RANKING_BEGIN; --i) {
                auto &list = player->corps()->quality_list(i);
                for (auto &soldier : list) {
                    rsp->list.emplace_back();
                    auto &item = rsp->list.back();
                    item.id = soldier.id();
                    item.level = soldier.level()->level();
                }
            }
        }
        else {
            AS_PlayerSoldierInfo msg;
            msg.req->id(req->uid);
            call(msg);
            rsp->list = std::move(msg.rsp->list);
        }
        return 0;
    }
};

GX_SERVLET_REGISTER(CL_PlayerSoldierInfoServlet, true);

