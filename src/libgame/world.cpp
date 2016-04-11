#include "world.h"
#include "global.h"
#include "libgame/g_defines.h"
#include "soldier.h"
#include "item.h"

G_World::G_World() noexcept 
: _cache(_pool)
{ }

bool G_World::init() noexcept {
    for (auto &db_info : the_db_infos) {
        object<MySQL> mysql(
            db_info.host.c_str(), 
            db_info.port, 
            db_info.user.c_str(), 
            db_info.passwd.c_str(), 
            db_info.database.c_str());

        if (!mysql->connect()) {
            log_error("connect to database false, %s.", mysql->errorMsg());
            return false;
        }

        Statement<unsigned> queryPlayer(
            "select uid, name, side, arena, arena2, arena_day from player where server = ?");
        Statement<unsigned> queryValue(
            "select id, value from value where uid = ? and (id = 5 or id = 7 or id = 22)");
        Statement<> querySoldier(
            "select uid, sid, value from soldier where id = 0 group by uid, sid order by uid");

        Statement<> queryEquip(
            "select uid, base, value from bag where used > 0 order by uid");

        if (!queryPlayer.prepare(mysql)) {
            log_error("prepare query player failed.");
            return false;
        }

        if (!queryValue.prepare(mysql)) {
            log_error("prepare query value failed.");
            return false;
        }

        if (!querySoldier.prepare(mysql)) {
            log_error("prepare query soldier failed.");
            return false;
        }

        if (!queryEquip.prepare(mysql)) {
            log_error("prepare query euqip failed.");
            return false;
        }

        auto player_rs = queryPlayer.query(the_server_id);
        if (!player_rs) {
            log_error("query player failed.");
            return false;
        }
        while (player_rs->fetch()) {
            unsigned uid;
            std::string name;
            unsigned side;
            unsigned arena;
            unsigned vip = 0;
            unsigned level = 0;
            unsigned appearance = 0;
            unsigned arena2;
            unsigned arena_day;

            uid << player_rs;
            name << player_rs;
            side << player_rs;
            arena << player_rs;
            arena2 << player_rs;
            arena_day << player_rs;

            auto value_rs = queryValue.query(uid);
            if (!value_rs) {
                log_error("query value failed.");
                return false;
            }

            while (value_rs->fetch()) {
                unsigned id;
                unsigned value;

                id << value_rs;
                value << value_rs;

                switch (id) {
                case G_VALUE_VIP:
                    vip = value;
                    break;
                case G_VALUE_LEVEL:
                    level = value;
                    break;
                case G_VALUE_APPEARANCE:
                    appearance = value;
                    break;
                }
            }

            G_WorldPlayer *player = add_player(uid, name, side);
            if (!player) {
                continue;
            }
            player->_level = level;
            player->_vip = vip;
            player->_appearance = appearance;
            _arena->set_player(arena, player, arena2, arena_day);
        }

        do {
            auto rs = querySoldier.query();
            if (!rs) {
                log_error("query soldier failed.");
                return false;
            }
            unsigned old_uid = 0;
            unsigned uid;
            unsigned sid;
            unsigned value;
            G_WorldPlayer *player = nullptr;
            while (rs->fetch()) {
                uid << rs;
                sid << rs;
                value << rs;

                if (old_uid != uid) {
                    player = get_player(uid);
                    old_uid = uid;
                }

                if (!player) {
                    continue;
                }

                const G_SoldierInfo *info = G_SoldierMgr::instance()->get_info(sid);
                unsigned quality = info->quality();
                if (quality >= G_QUALITY_RANKING_BEGIN && quality < G_QUALITY_UNKNOWN) {
                    player->_soldier_qualities[quality - G_QUALITY_RANKING_BEGIN]++;
                }
                player->_score = info->star() * value * 100;
            }
        } while (0);

        do {
            auto rs = queryEquip.query();
            if (!rs) {
                log_error("query equip failed.");
                return false;
            }
            unsigned old_uid = 0;
            unsigned uid;
            unsigned base;
            unsigned value;
            G_WorldPlayer *player = nullptr;
            while (rs->fetch()) {
                uid << rs;
                base << rs;
                value << rs;

                if (old_uid != uid) {
                    player = get_player(uid);
                    old_uid = uid;
                }

                if (!player) {
                    continue;
                }

                const G_ItemInfo *info = G_ItemMgr::instance()->get_info(base);
                if (!info) {
                    continue;
                }

                player->_score += (info->quality() * value * 10);
            }
        } while (0);
    }

    for (G_WorldPlayer *player : _players) {
        _soldire_ranking_list->add(player);
        _score_ranking_list->add(player);
    }
    _score_ranking_list->build_list();
    _soldire_ranking_list->build_list();

    
    _timer = the_app->timer_manager()->schedule(
        1000,
        std::bind(&G_World::timer_handler, this, _1, _2));

    return true;
}

timeval_t G_World::timer_handler(Timer&, timeval_t time) {
    _soldire_ranking_list->second_timer_handler();
    _score_ranking_list->second_timer_handler();
    return 1000;
}

G_WorldPlayer *G_World::get_player(unsigned id) const noexcept {
    static G_WorldPlayer tmp;
    tmp._id = id;
    tmp._hash = hash_iterative(&id, sizeof(id));

    auto it = _players.find(&tmp);
    if (it == _players.end()) {
        return nullptr;
    }
    return *it;
}

G_WorldPlayer *G_World::probe_player(unsigned id) noexcept {
    static G_WorldPlayer tmp;
    tmp._id = id;
    tmp._hash = hash_iterative(&id, sizeof(id));

    auto r = _players.emplace(&tmp);
    if (r.second) {
        G_WorldPlayer *player = _cache.construct();
        player->_id = id;
        player->_hash = tmp._hash;
        const_cast<G_WorldPlayer*&>(*r.first) = player;
    }
    return *r.first;
}

G_WorldPlayer *G_World::add_player(unsigned id, const std::string &name, unsigned side) noexcept {
    static G_WorldPlayer tmp;
    tmp._id = id;
    tmp._hash = hash_iterative(&id, sizeof(id));

    auto r = _players.emplace(&tmp);
    if (!r.second) {
        return nullptr;
    }

    G_WorldPlayer *player = _cache.construct();
    player->_id = id;
    player->_hash = tmp._hash;
    const_cast<G_WorldPlayer*&>(*r.first) = player;

    player->_name = name;
    player->_name_hash = hash_iterative(name.c_str(), name.size());
    auto r2 = _names.emplace(player);

    if (!r2.second) {
        _players.erase(r.first);
        _cache.destroy(player);
        return nullptr;
    }

    player->_side = side;
    return *r.first;
}

G_WorldPlayer *G_World::get_player_by_name(const std::string &name) noexcept {
    static G_WorldPlayer tmp;
    tmp._name = name;
    tmp._name_hash = hash_iterative(name.c_str(), name.size());
    auto it = _names.find(&tmp);
    if (it == _names.end()) {
        return nullptr;
    }
    return *it;
}

G_WorldPlayer *G_World::get_player_by_name(const obstack_string &name) noexcept {
    static G_WorldPlayer tmp;
    tmp._name = name;
    tmp._name_hash = hash_iterative(name.c_str(), name.size());
    auto it = _names.find(&tmp);
    if (it == _names.end()) {
        return nullptr;
    }
    return *it;
}

void G_World::login(G_WorldPlayer *player, const G_PlayerInfo &info) noexcept {
    update_player_level(player, info.level);
    update_player_vip(player, info.vip);
    update_player_side(player, info.side);
    update_player_appearance(player, info.appearance);
}

void G_World::logout(G_WorldPlayer *player) noexcept {
}


    


