#include "fightsvr.h"
#include "libgame/fight.h"
#include "libfight/libfight.h"

int main(int argc, char **argv) {
    libfight_init(*the_app->script());

    if (!the_app->init(argc, argv)) {
        return 1;
    }

    if (!G_FightCalcMgr::instance()->init()) {
        log_error("init fight calc manager failed.");
        return 1;
    }

    the_app->run();
    return 0;
}




