#include "dbsvr.h"
#include "libgame/player_init.h"
#include "libgame/global.h"

#include <unistd.h>
DB_ServletSQL the_sqls;

int main(int argc, char **argv) {
    if (!the_app->init(argc, argv)) {
        return 1;
    }

    if (!load_global()) {
        log_error("load global config failed.");
        return 1;
    }

    if (!G_PlayerInitMgr::instance()->init()) {
        log_error("init player init table failed.");
        return 1;
    }

    auto &db_info = the_db_infos[the_app->network()->id()];
    object<MySQL> mysql(
        db_info.host.c_str(), 
        db_info.port, 
        db_info.user.c_str(), 
        db_info.passwd.c_str(), 
        db_info.database.c_str());

    log_info("connect to database host=%s port=%u, user=%s, database=%s.", 
             db_info.host.c_str(), 
             db_info.port, 
             db_info.user.c_str(), 
             db_info.database.c_str());

    if (!mysql->connect()) {
        log_info("connect to database false, %s.", mysql->errorMsg());
        return 1;
    }
    log_info("connect to database ok.");
    if (!StatementContainer::instance()->prepare(mysql)) {
        log_error("mysql prepare statement failed.");
        return 1;
    }
    the_app->run();
    return 0;
}


