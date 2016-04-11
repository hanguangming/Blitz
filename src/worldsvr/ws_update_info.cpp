#include "worldsvr.h"

struct WS_UpdateLevelServlet : WS_Servlet<WS_UpdateLevel> {
    virtual int execute(G_World *world, request_type *req) {
        G_WorldPlayer *player = world->get_player(req->uid);
        if (player) {
            world->update_player_level(player, req->level);
        }
        return 0;
    }
};

GX_SERVLET_REGISTER(WS_UpdateLevelServlet, false);


struct WS_UpdateVipServlet : WS_Servlet<WS_UpdateVip> {
    virtual int execute(G_World *world, request_type *req) {
        G_WorldPlayer *player = world->get_player(req->uid);
        if (player) {
            world->update_player_vip(player, req->vip);
        }
        return 0;
    }
};

GX_SERVLET_REGISTER(WS_UpdateVipServlet, false);


struct WS_UpdateSideServlet : WS_Servlet<WS_UpdateSide> {
    virtual int execute(G_World *world, request_type *req) {
        G_WorldPlayer *player = world->get_player(req->uid);
        if (player) {
            world->update_player_side(player, req->side);
        }
        return 0;
    }
};

GX_SERVLET_REGISTER(WS_UpdateSideServlet, false);


struct WS_UpdateAppearanceServlet : WS_Servlet<WS_UpdateAppearance> {
    virtual int execute(G_World *world, request_type *req) {
        G_WorldPlayer *player = world->get_player(req->uid);
        if (player) {
            world->update_player_appearance(player, req->appearance);
        }
        return 0;
    }
};

GX_SERVLET_REGISTER(WS_UpdateAppearanceServlet, false);
