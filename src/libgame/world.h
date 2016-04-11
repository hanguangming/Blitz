#ifndef __LIBGAME_WORLD_H__
#define __LIBGAME_WORLD_H__

#include <unordered_set>

#include "game.h"
#include "world_player.h"
#include "arena.h"
#include "world_ranking_list.h"
#include "libgame/g_player.h"

class G_World : public Object, public singleton<G_World> {
public:
    G_World() noexcept;
    G_WorldPlayer *get_player(unsigned id) const noexcept;
    G_WorldPlayer *get_player_by_name(const std::string &name) noexcept;
    G_WorldPlayer *get_player_by_name(const obstack_string &name) noexcept;
    G_WorldPlayer *add_player(unsigned id, const std::string &name, unsigned side) noexcept;
    G_Arena *arena() const noexcept {
        return _arena;
    }
    G_WorldSoldierRankingList *soldier_ranking_list() const noexcept {
        return _soldire_ranking_list;
    }
    G_WorldScoreRankingList *score_ranking_list() const noexcept {
        return _score_ranking_list;
    }
    bool init() noexcept;
    void login(G_WorldPlayer *player, const G_PlayerInfo &info) noexcept;
    void logout(G_WorldPlayer *player) noexcept;
    void update_player_level(G_WorldPlayer *player, unsigned value) noexcept {
        player->_level = value;
    }
    void update_player_vip(G_WorldPlayer *player, unsigned value) noexcept {
        player->_vip = value;
    }
    void update_player_side(G_WorldPlayer *player, unsigned value) noexcept {
        player->_side = value;
    }
    void update_player_appearance(G_WorldPlayer *player, unsigned value) noexcept {
        player->_appearance = value;
    }
private:
    G_WorldPlayer *probe_player(unsigned id) noexcept;
    timeval_t timer_handler(Timer&, timeval_t time);

private:
    struct player_hash {
        size_t operator()(const G_WorldPlayer *player) const noexcept {
            return player->_hash;
        }
    };
    struct player_cmp {
        bool operator()(const G_WorldPlayer *lhs, const G_WorldPlayer *rhs) const noexcept {
            return lhs->_id == rhs->_id;
        }
    };
    struct name_hash {
        size_t operator()(const G_WorldPlayer *player) const noexcept {
            return player->_name_hash;
        }
    };
    struct name_cmp {
        bool operator()(const G_WorldPlayer *lhs, const G_WorldPlayer *rhs) const noexcept {
            return lhs->_name_hash == rhs->_name_hash && lhs->_name == rhs->_name;
        }
    };
private:
    object<Obstack> _pool;
    object_cache<G_WorldPlayer, Obstack> _cache;
    std::unordered_set<G_WorldPlayer*, player_hash, player_cmp> _players;
    std::unordered_set<G_WorldPlayer*, name_hash, name_cmp> _names;
    object<G_Arena> _arena;
    object<G_WorldSoldierRankingList> _soldire_ranking_list;
    object<G_WorldScoreRankingList> _score_ranking_list;
    weak_ptr<Timer> _timer;
};


#endif

