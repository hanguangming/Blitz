#ifndef __LIBGAME_PLAYER_OBJECT_H__
#define __LIBGAME_PLAYER_OBJECT_H__

#include <unordered_set>
#include <set>
#include "game.h"

class G_Peer;

/* G_PlayerObject */
class G_PlayerObject {
    template <typename, typename> friend class G_PlayerContainer;
public:
    G_PlayerObject() noexcept : _id(), _hash() { }

    unsigned id() const noexcept {
        return _id;
    }

    virtual void logout() noexcept = 0;
private:
    unsigned _id;
    unsigned _hash;
};

/* G_PlayerContainer */
template <typename _Tp, typename _Pool>
class G_PlayerContainer {
    static_assert(std::is_base_of<G_PlayerObject, _Tp>::value, 
                  "G_PlayerContainer must containt G_PlayerObject");
private:
    struct G_PlayerTmp : G_PlayerObject {
        void logout() noexcept { }
    };
public:
    typedef _Tp     value_type;
    typedef _Pool   pool_type;

    G_PlayerContainer(ptr<pool_type> pool) noexcept
    : _cache(pool)
    { }

    value_type *get_player(unsigned id) const noexcept {
        static G_PlayerTmp tmp;
        tmp._id = id;
        tmp._hash = hash_iterative(&id, sizeof(id));

        auto it = _players.find(&tmp);
        if (it == _players.end()) {
            return nullptr;
        }
        return static_cast<value_type*>(*it);
    }

    value_type *probe_player(unsigned id) noexcept {
        static G_PlayerTmp tmp;
        tmp._id = id;
        tmp._hash = hash_iterative(&id, sizeof(id));

        auto r = _players.emplace(&tmp);
        if (r.second) {
            G_PlayerObject *player = _cache.construct();
            player->_id = id;
            player->_hash = tmp._hash;
            const_cast<G_PlayerObject*&>(*r.first) = player;
        }
        return static_cast<value_type*>(*r.first);
    }

    void remove_player(unsigned id) noexcept {
        static G_PlayerTmp tmp;
        tmp._id = id;
        tmp._hash = hash_iterative(&id, sizeof(id));

        auto it = _players.find(&tmp);
        if (it != _players.end()) {
            value_type *obj = static_cast<value_type*>(*it);
            _players.erase(it);
            _cache.destroy(obj);
        }
    }

    void remove_player(G_PlayerObject *player) noexcept {
        remove_player(player->_id);
    }

private:
    struct hash {
        size_t operator()(const G_PlayerObject *player) const noexcept {
            return player->_hash;
        }
    };
    struct cmp {
        bool operator()(const G_PlayerObject *lhs, const G_PlayerObject *rhs) const noexcept {
            return lhs->_id == rhs->_id;
        }
    };

private:
    std::unordered_set<G_PlayerObject*, hash, cmp> _players;
    object_cache<value_type, pool_type> _cache;
};

/* G_PeerObject */
class G_PeerObject : public G_PlayerObject {
    friend class G_Peer;
    template <typename> friend class G_PeerContainer;
public:
    G_PeerObject() noexcept
    : _peer()
    { }

    Peer *peer() const noexcept;

    virtual void on_node_peer_close() noexcept {
        logout();
    }
private:
    G_Peer *_peer;
    clist_entry _peer_entry;
};

/* G_Peer */
class G_Peer : public PeerObject {
    template <typename> friend class G_PeerContainer;
    friend class G_PeerObject;
public:
    G_Peer() noexcept
    : _peer()
    { }

    Peer *peer() const noexcept {
        return _peer;
    }

protected:
    void on_peer_close() override {
        if (_close_handler) {
            _close_handler(this);
        }
    }
private:
    Peer *_peer;
    std::function<void(G_Peer*)> _close_handler;
    gx_list(G_PeerObject, _peer_entry) _list;
};

/* G_PeerContainer */
template <typename _Pool>
class G_PeerContainer {
public:
    typedef _Pool   pool_type;
    typedef G_Peer  value_type;

    G_PeerContainer(ptr<pool_type> pool) noexcept
    : _cache(pool)
    { }

    G_Peer *probe_peer(Peer *peer) noexcept {
        G_Peer tmp;
        tmp._peer = peer;

        auto r = _peers.emplace(&tmp);
        if (r.second) {
            G_Peer *obj = _cache.construct();
            obj->_peer = peer;
            obj->_close_handler = std::bind(&G_PeerContainer::peer_close, this, _1);
            peer->peer_object = obj;
            const_cast<G_Peer*&>(*r.first) = obj;
        }
        return *r.first;
    }

    void remove_peer(Peer *peer) noexcept {
        G_Peer tmp;
        tmp._peer = peer;
        auto it = _peers.find(&tmp);
        if (it != _peers.end()) {
            G_Peer *peer_obj = *it;
            _peers.erase(it);

            for (auto &obj : peer_obj->_list) {
                remove_object(&obj);
                obj.on_node_peer_close();
            }

            _cache.destroy(peer_obj);
        }
    }

    void add_object(G_PeerObject *obj, Peer *peer) noexcept {
        assert(!obj->_peer);
        G_Peer *peer_obj = probe_peer(peer);
        peer_obj->_list.push_back(obj);
        obj->_peer = peer_obj;
    }

    void remove_object(G_PeerObject *obj) noexcept {
        if (obj->_peer) {
            gx_list(G_PeerObject, _peer_entry)::remove(obj);
            obj->_peer = nullptr;
        }
    }
private:
    void peer_close(G_Peer *peer) {
        remove_peer(peer->_peer);
    }
private:
    struct cmp {
        bool operator()(const G_Peer *lhs, const G_Peer *rhs) const noexcept {
            return lhs->_peer < rhs->_peer;
        }
    };
private:
    std::set<G_Peer*, cmp> _peers;
    object_cache<value_type, pool_type> _cache;
};

/* G_PeerObject */
inline Peer *G_PeerObject::peer() const noexcept {
    if (!_peer) {
        return nullptr;
    }
    return _peer->_peer;
}

#endif

