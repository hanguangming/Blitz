#ifndef __LIBGAME_WORLD_PLAYER_H__
#define __LIBGAME_WORLD_PLAYER_H__

#include "game.h"
#include "libgame/g_defines.h"

class G_WorldPlayer {
    friend class G_World;
    friend class G_Arena;
    friend class G_WorldSoldierRankingList;
    friend class G_WorldScoreRankingList;
public:
    G_WorldPlayer() noexcept;
    unsigned id() const noexcept {
        return _id;
    }
    unsigned vip() const noexcept {
        return _vip;
    }
    unsigned level() const noexcept {
        return _level;
    }
    const std::string &name() const noexcept {
        return _name;
    }
    unsigned side() const noexcept {
        return _side;
    }
    unsigned arena() const noexcept {
        return _arena;
    }
    unsigned arena2() const noexcept {
        return _arena2;
    }
    unsigned arena_day() const noexcept {
        return _arena_day;
    }
    unsigned score() const noexcept {
        return _score;
    }
    void score(unsigned value) noexcept;
    void soldiers(unsigned *p) noexcept;
    unsigned appearance() const noexcept {
        return _appearance;
    }
    unsigned arena_get_award() noexcept;
    unsigned soldier_rank() const noexcept {
        return _soldier_rank;
    }
    unsigned score_rank() const noexcept {
        return _score_rank;
    }
private:
    void arena(unsigned rank) noexcept;

private:
    unsigned _id;
    size_t _hash;
    unsigned _vip;
    unsigned _appearance;
    unsigned _level;
    unsigned _side;
    std::string _name;
    size_t _name_hash;
    unsigned _arena;
    unsigned _arena2;
    unsigned _arena_day;
    union {
        unsigned _soldier_qualities[G_QUALITY_RANKING_NUM];
        struct {
            unsigned _q4;
            unsigned _q5;
            unsigned _q6;
        };
    };
    unsigned _score;
    unsigned _soldier_rank;
    unsigned _score_rank;
    rbtree::node _soldier_node;
    rbtree::node _score_node;
};

#endif

