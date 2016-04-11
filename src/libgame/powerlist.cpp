#include "powerlist.h"

/* G_PowerTree */
G_PowerTree::G_PowerTree() noexcept 
: _left(),
  _right(),
  _count()
{ }

inline int G_PowerTree::cmp(G_PowerInfo *info) const noexcept {
    return 0;
}

/* G_PowerList */
G_PowerList::G_PowerList() noexcept 
: _left(), 
  _right()
{ }

G_PowerPlayer *G_PowerList::get_player(unsigned id) noexcept {
    object<G_PowerPlayer> tmp;
    tmp->_id = id;
    tmp->_hash = hash_iterative(&id, sizeof(id));
    auto r = _players.emplace(tmp);
    if (!r.second) {
        object<G_PowerPlayer> player;
        player->_id = id;
        player->_hash = tmp->_hash;
        const_cast<ptr<G_PowerPlayer>&>(*r.first) = player;
    }
    return *r.first;
}

void G_PowerList::emplace(unsigned id, const G_PowerInfo &info) noexcept {

}

