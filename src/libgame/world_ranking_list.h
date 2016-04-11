#ifndef __LIBGAME_WORLD_RANKING_LIST_H__
#define __LIBGAME_WORLD_RANKING_LIST_H__

#include <vector>
#include "game.h"
#include "world_player.h"
#include "libgame/g_world.h"

class G_WorldSoldierRankingList : public Object, public rbtree {
    friend class G_World;
public:
    G_WorldSoldierRankingList() noexcept : _left(), _update_dirty(true) { }
    void add(G_WorldPlayer *player) noexcept;
    void update(G_WorldPlayer *player, unsigned *qualities);
    void to_list(unsigned begin, unsigned end, obstack_vector<G_SoldierRankingItem> &list);
private:
    void build_list() noexcept;
    void second_timer_handler() noexcept;
    static bool less(const G_WorldPlayer *lhs, const G_WorldPlayer *rhs) noexcept;
private:
    rbtree::node *_left;
    std::vector<G_WorldPlayer*> _list;
    bool _update_dirty;
};

class G_WorldScoreRankingList : public Object, public rbtree {
    friend class G_World;
public:
    G_WorldScoreRankingList() noexcept : _left(), _update_dirty(true) { }
    void add(G_WorldPlayer *player) noexcept;
    void update(G_WorldPlayer *player, unsigned score);
    void to_list(unsigned begin, unsigned end, obstack_vector<G_ScoreRankingItem> &list);
private:
    void build_list() noexcept;
    void second_timer_handler() noexcept;
    static bool less(const G_WorldPlayer *lhs, const G_WorldPlayer *rhs) noexcept;
private:
    rbtree::node *_left;
    std::vector<G_WorldPlayer*> _list;
    bool _update_dirty;
};

#endif

