#include "global.h"

timeval_t   the_login_wait_time = 3000;
timeval_t   the_session_keep_time = 1000 * 60 * 5;
timeval_t   the_linger_time = 1000;
size_t      the_cache_player_num = 10000;
int         the_server_id = -1;
timeval_t   the_fight_response_time = 3000;

std::vector<G_DBInfo> the_db_infos;
G_DBInfo    the_global_db_info;

bool load_global() {
    the_server_id = the_app->script()->read_integer("the_server_id, -1");


    if (the_server_id < 0) {
        log_error("bad server id '%d'.", the_server_id);
        return false;
    }

    do {
        auto tab = the_app->script()->read_table("the_global_db");
        if (tab->is_nil()) {
            log_error("no database config.");
            return false;
        }
        the_global_db_info.host = tab->read_string("host");
        the_global_db_info.port = tab->read_integer("port");
        the_global_db_info.user = tab->read_string("user");
        the_global_db_info.passwd = tab->read_string("passwd");
        the_global_db_info.database = tab->read_string("database");
    } while (0);

    do {
        auto tab = the_app->script()->read_table("the_db");
        if (tab->is_nil()) {
            log_error("no database config.");
            return false;
        }
        for (unsigned i = 1; ; ++i) {
            tab = tab->read_table(i);
            if (tab->is_nil()) {
                break;
            }

            the_db_infos.emplace_back();
            auto &info = the_db_infos.back();
            info.host = tab->read_string("host");
            info.port = tab->read_integer("port");
            info.user = tab->read_string("user");
            info.passwd = tab->read_string("passwd");
            info.database = tab->read_string("database");
        }
        if (the_db_infos.empty()) {
            log_error("no database config.");
            return false;
        }
    } while (0);

    the_login_wait_time = the_app->script()->read_integer("the_login_wait_time", the_login_wait_time);
    the_session_keep_time = the_app->script()->read_integer("the_session_keep_time", the_session_keep_time);
    the_linger_time = the_app->script()->read_integer("the_linger_time", the_linger_time);
    the_cache_player_num = the_app->script()->read_integer("the_cache_player_num", the_cache_player_num);
    
    return true;
}

