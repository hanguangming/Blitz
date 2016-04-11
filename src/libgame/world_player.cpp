#include "world_player.h"
#include "world.h"

G_WorldPlayer::G_WorldPlayer() noexcept
: _id(),
  _hash(),
  _vip(),
  _appearance(),
  _level(),
  _side(),
  _name_hash(),
  _arena(),
  _arena2(),
  _arena_day(),
  _score(),
  _soldier_rank(),
  _score_rank()
{
    memset(_soldier_qualities, 0, sizeof(_soldier_qualities));
}

void G_WorldPlayer::arena(unsigned rank) noexcept {
    unsigned day = the_day();
    if (!_arena_day) {
        _arena_day = day;
    }
    if (_arena_day == day) {
        _arena = _arena2 = rank;
    }
    else if (_arena_day == day - 1) {
        _arena = rank;
    }
    else {
        _arena_day = day - 1;
        _arena2 = _arena;
        _arena = rank;
    }
}

unsigned G_WorldPlayer::arena_get_award() noexcept {
    unsigned day = the_day();
    unsigned rank;
    if (_arena_day == day) {
        rank = 0;
    }
    else if (_arena_day == day - 1) {
        rank = _arena2;
    }
    else {
        rank = _arena;
    }
    _arena2 = _arena;
    _arena_day = day;
    return rank;
}

void G_WorldPlayer::score(unsigned value) noexcept {
    G_World::instance()->score_ranking_list()->update(this, value);
}

void G_WorldPlayer::soldiers(unsigned *p) noexcept {
    G_World::instance()->soldier_ranking_list()->update(this, p);
}

