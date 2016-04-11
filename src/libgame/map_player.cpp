#include "map_player.h"
#include "libgame/g_defines.h"
#include "map.h"

G_MapPlayer::G_MapPlayer() noexcept
: G_MapUnit(G_MAP_UNIT_PLAYER),
  _key(),
  _city(),
  _speed(),
  _path_index(),
  _subscribe(),
  _people(),
  _people_all(),
  _mexp(),
  _mexp_next()
{ }

G_MapPlayer::~G_MapPlayer() noexcept {
    if (_move_timer) {
        _move_timer->close();
    }
}

void G_MapPlayer::on_peer_close() {
    logout();
}

void G_MapPlayer::to_presend(G_MapPresend &presend) const noexcept {
    presend.id = id();
    presend.name = _name;
    presend.vip = _vip;
    presend.side = _side->id();
    presend.speed = _speed;
    presend.from = _from->id();
    presend.to = _city->id();
    presend.appearance = _appearance;
}

void G_MapPlayer::supplement(G_FightCorps *corps) noexcept {
    if (!_city || _city->fighting()) {
        return;
    }

    _corps = object<G_ManagedFightCorps>();
    *_corps = *corps;
    _people = _people_all = _corps->people();
}

void G_MapPlayer::logout() noexcept {
    G_Map::instance()->logout(this);
}

void G_MapPlayer::subscribe(G_MapCity *city) noexcept {
    if (city == _subscribe) {
        return;
    }

    if (_subscribe) {
        _subscribe->subscribe(this, false);
        _subscribe = nullptr;
    }

    if (!city) {
        return;
    }

    if (city->subscribe(this, true)) {
        _subscribe = city;
    }
}

void G_MapPlayer::get_corps(G_FightCorps *corps) noexcept {
    if (_corps) {
        _corps->to_unmanaged(*corps);
    }
}

void G_MapPlayer::set_corps(const G_FightCorps *corps) noexcept {
    if (!corps) {
        _corps = nullptr;
        _people = 0;
        return;
    }
    _corps = object<G_ManagedFightCorps>();
    *_corps = *corps;
    _people = _corps->people();
}

void G_MapPlayer::fight_finish() noexcept {
}

bool G_MapPlayer::shadow(G_FightCorps &corps) noexcept {
    if (_city != _subscribe) {
        return false;
    }

    _city->shadow(this, corps);
    return true;
}

void G_MapPlayer::pvp() noexcept {
    _city->pvp(this);
}

