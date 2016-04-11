#include "agentsvr.h"

struct AS_PlayerSoldierInfoServlet : AS_Servlet<AS_PlayerSoldierInfo> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        for (unsigned i = G_QUALITY_UNKNOWN - 1; i >= G_QUALITY_RANKING_BEGIN; --i) {
            auto &list = player->corps()->quality_list(i);
            for (auto &soldier : list) {
                rsp->list.emplace_back();
                auto &item = rsp->list.back();
                item.id = soldier.id();
                item.level = soldier.level()->level();
            }
        }
        return 0;
    }
};

GX_SERVLET_REGISTER(AS_PlayerSoldierInfoServlet, true);

