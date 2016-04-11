#include "agentsvr.h"
#include "libgame/item.h"
#include "libgame/shop.h"
#include "libgame/equip.h"
#include "libgame/level.h"
#include "libgame/forge.h"
#include "libgame/recharge.h"
#include "libgame/vip.h"
#include "libgame/recast.h"
#include "libgame/award.h"
#include "libgame/soldier.h"
#include "libgame/recruit.h"
#include "libgame/soldierup.h"
#include "libgame/train.h"
#include "libgame/param.h"
#include "libgame/tech.h"
#include "libgame/stage.h"
#include "libgame/task.h"
#include "libgame/global.h"
#include "libgame/arena_award.h"

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

    if (!G_ShopMgr::instance()->init()) {
        log_error("init shop manager failed.");
        return 1;
    }

    if (!G_ForgeMgr::instance()->init()) {
        log_error("init forge manager failed.");
        return 1;
    }

    if (!G_EquipUpMgr::instance()->init()) {
        log_error("init equip up manager failed.");
        return 1;
    }

    if (!G_LevelMgr::instance()->init()) {
        log_error("init level manager failed.");
        return 1;
    }

    if (!G_RechargeMgr::instance()->init()) {
        log_error("init recharge manager failed.");
        return 1;
    }

    if (!G_VipMgr::instance()->init()) {
        log_error("init vip manager failed.");
        return 1;
    }

    if (!G_RecastMgr::instance()->init()) {
        log_error("init recast manager failed.");
        return 1;
    }

    if (!G_SoldierMakeMgr::instance()->init()) {
        log_error("init solder make manager failed.");
        return 1;
    }

    if (!G_RecruitMgr::instance()->init()) {
        log_error("init recurite manager failed.");
        return 1;
    }

    if (!G_SoldierUpMgr::instance()->init()) {
        log_error("init soldier up manager failed.");
        return 1;
    }

    if (!G_TrainMgr::instance()->init()) {
        log_error("init train manager failed.");
        return 1;
    }

    if (!G_AwardMgr::instance()->init()) {
        log_error("init award manager failed.");
        return 1;
    }

    if (!G_ParamMgr::instance()->init()) {
        log_error("init param manager failed.");
        return 1;
    }

    if (!G_StageMgr::instance()->init()) {
        log_error("init stage manager failed.");
        return 1;
    }

    if (!G_TechMgr::instance()->init()) {
        log_error("init tech manager failed.");
        return 1;
    }

    if (!G_TaskMgr::instance()->init()) {
        log_error("init task manager failed.");
        return 1;
    }

    if (!G_ArenaAwardMgr::instance()->init()) {
        log_error("init arena award manager failed.");
        return 1;
    }

    Context::factory = []() {
        return object<G_AgentContext>();
    };
    G_PlayerMgr::instance()->init();
    the_app->shutdown = std::bind(&G_PlayerMgr::shutdown, G_PlayerMgr::instance());
    the_app->run();
    return 0;
}


