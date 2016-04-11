#include "worldsvr.h"
#include "libgame/g_defines.h"

struct WS_ArenaListServlet : WS_Servlet<WS_ArenaList> {
    virtual int execute(G_World *world, G_WorldPlayer *player, request_type *req, response_type *rsp) {
        unsigned arena = player->arena();
        unsigned d;
        if (arena >= 3000) {
            d = 100;
        }
        else if (arena >= 1000) {
            d = 40;
        }
        else if (arena >= 500) {
            d = 20;
        }
        else if (arena >= 100) {
            d = 10;
        }
        else if (arena >= 50) {
            d =  2;
        }
        else {
            d = 1;
        }

        if (arena > G_ARENA_LIST_SIZE) {
            for (unsigned i = 0; i < G_ARENA_LIST_SIZE; i++) {
                arena -= d;
                G_WorldPlayer *p = world->arena()->get_player(arena);
                if (p) {
                    rsp->items.emplace_back();
                    auto &item = rsp->items.back();
                    item.id = p->id();
                    item.index = arena;
                    item.side = p->side();
                    item.vip = p->vip();
                    item.appearance = p->appearance();
                    item.name = p->name();
                }
            }
        }
        else {
            for (arena = G_ARENA_LIST_SIZE + 1; arena; --arena) {
                G_WorldPlayer *p = world->arena()->get_player(arena);
                if (p && p->id() != req->id()) {
                    rsp->items.emplace_back();
                    auto &item = rsp->items.back();
                    item.id = p->id();
                    item.index = arena;
                    item.side = p->side();
                    item.vip = p->vip();
                    item.appearance = p->appearance();
                    item.name = p->name();
                }
            }
        }

        for (unsigned i = 1; i <= G_ARENA_TOP_LIST_SIZE; ++i) {
            G_WorldPlayer *p = world->arena()->get_player(i);
            if (p) {
                rsp->tops.emplace_back();
                auto &item = rsp->tops.back();
                item.id = p->id();
                item.index = i;
                item.side = p->side();
                item.vip = p->vip();
                item.appearance = p->appearance();
                item.name = p->name();
            }
        }

        rsp->self = player->arena();
        return 0;
    }
};

GX_SERVLET_REGISTER(WS_ArenaListServlet, false);

