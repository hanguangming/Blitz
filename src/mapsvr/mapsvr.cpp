#include "mapsvr.h"
#include "libgame/map.h"
#include "libgame/npc.h"
#include "libgame/item.h"
#include "libgame/award.h"
#include "libgame/param.h"

int main(int argc, char **argv) {
    if (!the_app->init(argc, argv)) {
        return 1;
    }

    if (!G_ItemMgr::instance()->init()) {
        log_error("init item manager failed.");
        return 1;
    }

    if (!G_AwardMgr::instance()->init()) {
        log_error("init award manager failed.");
        return 1;
    }

    if (!G_SoldierMgr::instance()->init()) {
        log_error("init soldier manager failed.");
        return 1;
    }

    if (!G_NpcMgr::instance()->init()) {
        log_error("init npc info failed.");
        return 1;
    }

    if (!G_ParamMgr::instance()->init()) {
        log_error("init param manager failed.");
        return 1;
    }

    if (!G_Map::instance()->init()) {
        log_error("init map info failed.");
        return 1;
    }
    the_app->run();
    return 0;
}



