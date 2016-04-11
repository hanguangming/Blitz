#ifndef __LIBGAME_POWERLIST_H__
#define __LIBGAME_POWERLIST_H__

#include <unordered_map>
#include "game.h"
#include "libgame/g_powerlist.h"

class G_PowerTree;

class G_PowerPlayer : public Object, protected rbtree::node {
    friend class G_PowerList;
public:
    bool operator<(const G_PowerPlayer &rhs) const noexcept {
        return true;
    }

private:
    unsigned _id;
    unsigned _hash;
    std::string _name;
    unsigned _score;
    unsigned _level;
    unsigned _vip;
    const G_PowerTree *_tree;
};

class G_PowerTree : protected rbtree::node, protected rbtree {
public:
    G_PowerTree() noexcept;
private:
    int cmp(G_PowerInfo *info) const noexcept;
private:
    unsigned _hero_q5_num;
    unsigned _hero_q4_num;
    unsigned _soldier_q5_num;
    unsigned _soldier_q4_num;
    G_PowerPlayer *_left;
    G_PowerPlayer *_right;
    unsigned _count;
};

class G_PowerList : public Object, public singleton<G_PowerList>, protected rbtree {
public:
    G_PowerList() noexcept;
    void emplace(unsigned id, const G_PowerInfo &info) noexcept;

private:
    G_PowerPlayer *get_player(unsigned id) noexcept;
private:
    struct hash {
        size_t operator()(const G_PowerPlayer *player) const noexcept {
            return player->_hash;
        }
    };
    struct cmp {
        bool operator()(const G_PowerPlayer *lhs, const G_PowerPlayer *rhs) const noexcept {
            return lhs->_id == rhs->_id;
        }
    };
    std::unordered_set<ptr<G_PowerPlayer>, hash, cmp> _players;
    G_PowerTree *_left;
    G_PowerTree *_right;
};

#endif

