#ifndef __LIBGAME_GLOBAL_H__
#define __LIBGAME_GLOBAL_H__

#include <vector>
#include "game.h"

struct G_DBInfo {
    std::string host;
    unsigned port;
    std::string user;
    std::string passwd;
    std::string database;
};

extern timeval_t    the_login_wait_time;
extern timeval_t    the_session_keep_time;
extern timeval_t    the_linger_time;
extern size_t       the_cache_player_num;
extern int          the_server_id;
extern std::vector<G_DBInfo> the_db_infos;
extern timeval_t    the_fight_response_time;
extern G_DBInfo     the_global_db_info;

bool load_global();

#endif

