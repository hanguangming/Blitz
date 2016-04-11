#include "worldsvr.h"

struct WS_ArenaRankingListServlet : WS_Servlet<WS_ArenaRankingList> {
    virtual int execute(G_World *world, G_WorldPlayer *player, request_type *req, response_type *rsp) {
        unsigned count = 0;
        for (unsigned i = 1; i < world->arena()->size(); ++i) {
            if (count >= G_ARENA_RANKING_LIST_NUM) {
                break;
            }
            G_WorldPlayer *player = world->arena()->get_player(i);
            if (!player) {
                continue;
            }
            count++;

            rsp->list.emplace_back();
            auto &item = rsp->list.back();
            item.id = player->id();
            item.index = i;
            item.side = player->side();
            item.vip = player->vip();
            item.appearance = player->appearance();
            item.level = player->level();
            item.name = player->name();
            item.score = player->score();
        }
        return 0;
    }
};

GX_SERVLET_REGISTER(WS_ArenaRankingListServlet, false);

