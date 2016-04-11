#include "world_ranking_list.h"
#include "libgame/g_defines.h"

/* G_WorldSoldierRankingList */
inline bool G_WorldSoldierRankingList::less(const G_WorldPlayer *lhs, const G_WorldPlayer *rhs) noexcept {
    if (lhs->_q6 > rhs->_q6) {
        return true;
    }
    if (lhs->_q6 < rhs->_q6) {
        return false;
    }
    if (lhs->_q5 > rhs->_q5) {
        return true;
    }
    if (lhs->_q5 < rhs->_q5) {
        return false;
    }
    if (lhs->_q4 > rhs->_q4) {
        return true;
    }
    if (lhs->_q4 < rhs->_q4) {
        return false;
    }
    return lhs->_id < rhs->_id;
}

void G_WorldSoldierRankingList::add(G_WorldPlayer *new_player) noexcept {
    node **link = &_root;
    node *parent = nullptr;
    int left = 1;

    while (*link) {
        parent = *link;
        G_WorldPlayer *player = containerof_member(parent, &G_WorldPlayer::_soldier_node);
        if (less(new_player, player)) {
            link = &(*link)->_left;
        } else {
            link = &(*link)->_right;
            left = 0;
        }
    }

    if (left) {
        _left = &new_player->_soldier_node;
    }
    rbtree::link(&new_player->_soldier_node, parent, link);
    rbtree::insert(&new_player->_soldier_node);
    _update_dirty = true;

}

void G_WorldSoldierRankingList::update(G_WorldPlayer *player, unsigned *qualities) {
    rbtree::remove(&player->_soldier_node);
    for (unsigned i = 0; i < G_QUALITY_RANKING_NUM; ++i) {
        player->_soldier_qualities[i] = qualities[i];
    }
    add(player);
}

void G_WorldSoldierRankingList::second_timer_handler() noexcept {
    if (_update_dirty) {
        _update_dirty = false;
        build_list();
    }
}

void G_WorldSoldierRankingList::build_list() noexcept {
    rbtree::node *node = _left;

    for (auto player : _list) {
        player->_soldier_rank = 0;
    }

    _list.resize(0);
    while (node) {
        G_WorldPlayer *player = containerof_member(node, &G_WorldPlayer::_soldier_node);
        _list.push_back(player);
        if (_list.size() >= G_RANKING_LIST_NUM) {
            break;
        }
        player->_soldier_rank = _list.size();
        node = node->next();
    }
}

void G_WorldSoldierRankingList::to_list(unsigned begin, unsigned end, obstack_vector<G_SoldierRankingItem> &list) {
    if (begin > end) {
        return;
    }
    begin--;
    end--;
    for (; begin < _list.size() && begin <= end; ++begin) {
        G_WorldPlayer *player = _list[begin];
        list.emplace_back();
        auto &item = list.back();
        item.id = player->_id;
        item.side = player->_side;
        item.vip = player->_vip;
        item.appearance = player->_appearance;
        item.name = player->_name.c_str();
        for (unsigned n : player->_soldier_qualities) {
            item.soldiers.push_back(n);
        }
    }
}

/* G_WorldSoldierRankingList */
inline bool G_WorldScoreRankingList::less(const G_WorldPlayer *lhs, const G_WorldPlayer *rhs) noexcept {
    if (lhs->_score > rhs->_score) {
        return true;
    }
    if (lhs->_score < rhs->_score) {
        return false;
    }
    return lhs->_id < rhs->_id;
}

void G_WorldScoreRankingList::add(G_WorldPlayer *new_player) noexcept {
    node **link = &_root;
    node *parent = nullptr;
    int left = 1;

    while (*link) {
        parent = *link;
        G_WorldPlayer *player = containerof_member(parent, &G_WorldPlayer::_score_node);
        if (less(new_player, player)) {
            link = &(*link)->_left;
        } else {
            link = &(*link)->_right;
            left = 0;
        }
    }

    if (left) {
        _left = &new_player->_score_node;
    }
    rbtree::link(&new_player->_score_node, parent, link);
    rbtree::insert(&new_player->_score_node);
    _update_dirty = true;
}

void G_WorldScoreRankingList::update(G_WorldPlayer *player, unsigned score) {
    if (player->_score == score) {
        return;
    }
    rbtree::remove(&player->_score_node);
    player->_score = score;
    add(player);
}

void G_WorldScoreRankingList::second_timer_handler() noexcept {
    if (_update_dirty) {
        _update_dirty = false;
        build_list();
    }
}

void G_WorldScoreRankingList::build_list() noexcept {
    rbtree::node *node = _left;

    for (auto player : _list) {
        player->_score_rank = 0;
    }

    _list.resize(0);

    while (node) {
        G_WorldPlayer *player = containerof_member(node, &G_WorldPlayer::_score_node);
        _list.push_back(player);
        if (_list.size() >= G_RANKING_LIST_NUM) {
            break;
        }
        player->_score_rank = _list.size();
        node = node->next();
    }
}

void G_WorldScoreRankingList::to_list(unsigned begin, unsigned end, obstack_vector<G_ScoreRankingItem> &list) {
    if (begin > end) {
        return;
    }
    begin--;
    end--;

    for (; begin < _list.size() && begin <= end; ++begin) {
        G_WorldPlayer *player = _list[begin];
        list.emplace_back();
        auto &item = list.back();
        item.id = player->_id;
        item.side = player->_side;
        item.vip = player->_vip;
        item.appearance = player->_appearance;
        item.name = player->_name.c_str();
        item.score = player->_score;
    }
}

