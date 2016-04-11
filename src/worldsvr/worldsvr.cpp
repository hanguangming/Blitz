#include "worldsvr.h"
#include "libgame/global.h"
#include "libgame/world.h"
#include "libgame/soldier.h"
#include "libgame/item.h"

int main(int argc, char **argv) {
    if (!the_app->init(argc, argv)) {
        return 1;
    }

    if (!load_global()) {
        log_error("load global config failed.");
        return 1;
    }

    if (!G_ItemMgr::instance()->init()) {
        log_error("init item manager failed.");
        return 1;
    }

    if (!G_SoldierMgr::instance()->init()) {
        log_error("init soldier manager failed.");
        return 1;
    }

    if (!G_World::instance()->init()) {
        log_error("init world failed.");
        return 1;
    }

    the_app->run();
    return 0;
}




