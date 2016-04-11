#include "mapsvr.h"

struct MS_UpdateLevelServlet : MS_Servlet<MS_UpdateLevel> {
    virtual int execute(G_Map *map, request_type *req) {
        G_MapPlayer *player = map->get_player(req->uid);
        if (player) {
            player->level(req->level);
        }
        return 0;
    }
};

GX_SERVLET_REGISTER(MS_UpdateLevelServlet, false);

struct MS_UpdateVipServlet : MS_Servlet<MS_UpdateVip> {
    virtual int execute(G_Map *map, request_type *req) {
        G_MapPlayer *player = map->get_player(req->uid);
        if (player) {
            player->vip(req->vip);
        }
        return 0;
    }
};

GX_SERVLET_REGISTER(MS_UpdateVipServlet, false);

struct MS_UpdateSideServlet : MS_Servlet<MS_UpdateSide> {
    virtual int execute(G_Map *map, request_type *req) {
        if (req->side < G_SIDE_OTHER) {
            map->get_side(req->side);
        }
        return 0;
    }
};

GX_SERVLET_REGISTER(MS_UpdateSideServlet, false);

struct MS_UpdateAppearanceServlet : MS_Servlet<MS_UpdateAppearance> {
    virtual int execute(G_Map *map, request_type *req) {
        G_MapPlayer *player = map->get_player(req->uid);
        if (player) {
            player->appearance(req->appearance);
        }
        return 0;
    }
};

GX_SERVLET_REGISTER(MS_UpdateAppearanceServlet, false);

struct MS_UpdateSpeedServlet : MS_Servlet<MS_UpdateSpeed> {
    virtual int execute(G_Map *map, request_type *req) {
        G_MapPlayer *player = map->get_player(req->uid);
        if (player) {
            player->speed(req->speed);
        }
        return 0;
    }
};

GX_SERVLET_REGISTER(MS_UpdateSpeedServlet, false);


