#ifndef __LIBGAME_MAP_H__
#define __LIBGAME_MAP_H__

#include <vector>
#include "game.h"
#include "libgame/g_defines.h"
#include "libgame/g_map.h"
#include "map_player.h"
#include "map_side.h"
#include "map_city.h"
#include "guid.h"

/* G_GraphicMatrix */
class G_GraphicMatrix : public Object {
public:
    G_GraphicMatrix(unsigned size) noexcept;
    ~G_GraphicMatrix() noexcept;

    unsigned &elem(unsigned i, unsigned j) noexcept {
        assert(i < _size && j < _size);
        return *(_elems + j * _size + i);
    }
private:
    unsigned _size;
    unsigned *_elems;
};

/* G_Map */
class G_Map : public Object, public G_GuidObject, public singleton<G_Map> {
    friend class G_MapCity;
    friend class G_MapSide;
public:
    G_Map() noexcept;
    bool init();

    G_MapSide *get_side(unsigned side) noexcept {
        assert(side < G_SIDE_UNKNOWN);
        return _sides[side];
    }

    void login(unsigned id, const G_MapPlayerInfo &info, uint64_t key) noexcept;
    bool login(G_MapPlayer *player, uint64_t key, Peer *peer) noexcept;
    void logout(G_MapPlayer *player, bool remove = true) noexcept;
    void move(G_MapPlayer *player, obstack_vector<unsigned> &path, unsigned type) noexcept;
    void supplement(G_MapPlayer *player, G_FightCorps *corps) noexcept;
    G_MapPlayer *get_player(unsigned id) const noexcept {
        return _players.get_player(id);
    }
    G_MapCity *get_city(unsigned id) noexcept;
private:
    bool init_side();

    template <typename _T>
    void broadcast(const _T &msg) noexcept {
        broadcast(_T::the_message_id, &msg);
    }
    void broadcast(unsigned servlet_id, const INotify *msg) noexcept;

    G_MapPlayer *probe_player(unsigned id) noexcept;

    G_MapCity *probe_city(unsigned id) noexcept;
    ptr<G_MapPlayer> remove_player(unsigned id) noexcept;
    timeval_t move_timer_handler(G_MapPlayer *player, Timer&, timeval_t);
    timeval_t move_next(G_MapPlayer *player, unsigned type) noexcept;
    bool move(G_MapPlayer *player, G_MapCity *city, unsigned type) noexcept;
    void broadcast_move(const G_MapPlayer *player) noexcept;
    void broadcast_remove(const G_MapPlayer *player) noexcept;

private:
    struct cmp {
        bool operator()(const G_MapCity *lhs, const G_MapCity *rhs) const noexcept {
            return lhs->_id == rhs->_id;
        }
    };
    struct hash {
        size_t operator()(const G_MapCity *city) const noexcept {
            return city->_hash;
        }
    };

private:
    object<Pool> _pool;
    G_PlayerContainer<G_MapPlayer, Pool> _players;
    G_PeerContainer<Pool> _peers;

    G_MapPlayerPeerList _peer_list;
    std::unordered_set<ptr<G_MapCity>, hash, cmp> _cities;
    std::vector<G_MapCity*> _city_list;
    ptr<G_MapSide> _sides[G_SIDE_UNKNOWN];
    Stream _stream;
    Protocol _protocol;
    ptr<G_GraphicMatrix> _path;
};

#endif

