#ifndef __LIBGAME_MAP_PLAYER_H__
#define __LIBGAME_MAP_PLAYER_H__

#include "map_unit.h"
#include "libgame/g_map.h"
#include "libgame/g_fight.h"
#include "player_object.h"
#include "fight.h"

class G_MapSide;
class G_MapCity;

class G_MapPlayer : public G_PeerObject, public PeerObject, public G_MapUnit {
    friend class G_Map;
    friend class G_MapCity;
public:
    G_MapPlayer() noexcept;
    ~G_MapPlayer() noexcept;

    Peer *peer() noexcept {
        return _peer;
    }
    void to_presend(G_MapPresend &presend) const noexcept;
    void supplement(G_FightCorps *corps) noexcept;
    void subscribe(G_MapCity *city) noexcept;
    void get_corps(G_FightCorps *corps) noexcept override;
    void set_corps(const G_FightCorps *corps) noexcept override;
    void fight_finish() noexcept override;

    G_ManagedFightCorps *corps() const noexcept {
        return _corps;
    }
    virtual unsigned unit_id() const noexcept {
        return id();
    }
    virtual const std::string &name() const noexcept {
        return _name;
    }
    virtual unsigned vip() const noexcept {
        return _vip;
    }
    virtual unsigned level() const noexcept {
        return _level;
    }
    G_MapCity *city() const noexcept {
        return _city;
    }

    void name(const obstack_string &value) noexcept {
        _name = value;
    }
    void vip(unsigned value) noexcept {
        _vip = value;
    }
    void level(unsigned value) noexcept {
        _level = value;
    }
    void speed(unsigned value) noexcept {
        _speed = value;
    }
    void side(G_MapSide *value) noexcept {
        _side = value;
    }
    G_MapSide *side() const noexcept {
        return _side;
    }
    void appearance(unsigned value) noexcept {
        _appearance = value;
    }
    unsigned appearance() const noexcept {
        return _appearance;
    }
    unsigned people_all() const noexcept {
        return _people_all;
    }
    unsigned people() const noexcept {
        return _people;
    }

    void logout() noexcept override;
    bool shadow(G_FightCorps &corps) noexcept;
    void pvp() noexcept;
protected:
    void on_peer_close() override;

private:
    uint64_t                _key;
    G_MapCity              *_city;
    G_MapCity              *_from;
    timeval_t               _speed;
    weak_ptr<Timer>         _move_timer;
    std::vector<unsigned>   _path;
    unsigned                _path_index;
    weak_ptr<Peer>          _peer;
    G_MapCity              *_subscribe;
    ptr<G_ManagedFightCorps>_corps;
    unsigned                _vip;
    unsigned                _level;
    std::string             _name;
    unsigned                _appearance;
    unsigned                _people;
    unsigned                _people_all;
    unsigned                _mexp;
    G_MapPlayer            *_mexp_next;
public:
    list_entry              _peer_entry;
    list_entry              _side_entry;
    list_entry              _subscribe_entry;
};

typedef gx_list(G_MapPlayer, _peer_entry)       G_MapPlayerPeerList;
typedef gx_list(G_MapPlayer, _side_entry)       G_MapPlayerSideList;
typedef gx_list(G_MapPlayer, _subscribe_entry)  G_MapPlayerSubscribeList;

#endif

