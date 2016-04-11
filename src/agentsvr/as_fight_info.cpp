#include "agentsvr.h"

struct AS_FightInfoServlet : AS_Servlet<AS_FightInfo> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        if (req->formation >= G_FORMATION_UNKNOWN) {
            return GX_ENOTEXISTS;
        }
        unsigned form_id;
        switch (req->formation) {
        case G_FORMATION_PVE:
            form_id = player->values().get(G_VALUE_FORMATION_PVE);
            break;
        case G_FORMATION_PVP:
            form_id = player->values().get(G_VALUE_FORMATION_PVP);
            break;
        case G_FORMATION_ARENA:
            form_id = player->values().get(G_VALUE_FORMATION_ARENA);
            break;
        default:
            return GX_ENOTEXISTS;
        }
        G_Formation *form = player->formations()->formation(form_id);
        if (!player->corps()->get_fight_info(form, rsp->info)) {
            return GX_ENOTEXISTS;
        }
        return 0;
    }
};

GX_SERVLET_REGISTER(AS_FightInfoServlet, true);
