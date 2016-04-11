#include "arena.h"

G_Arena::G_Arena() noexcept {
    grow_slice();
    _slice_index = 1;
}

G_Arena::~G_Arena() noexcept {
    for (Page *page : _slices) {
        PageAllocator::instance()->free(page);
    }
}

unsigned G_Arena::add_player(G_WorldPlayer *player) noexcept {
    if (_slice_index >= G_ARENA_SLICE_SIZE) {
        grow_slice();
    }

    Page *page = _slices.back();
    G_WorldPlayer **p = (G_WorldPlayer**)page->firstp;
    *(p + _slice_index) = player;

    unsigned r = (_slices.size() - 1) * G_ARENA_SLICE_SIZE + _slice_index;
    player->_arena = player->_arena2 = r;
    _slice_index++;

    return r;
}

void G_Arena::grow_slice() noexcept {
    Page *page = PageAllocator::instance()->alloc();
    memset(page->firstp, 0, G_ARENA_SLICE_SIZE * sizeof(void*));
    _slices.push_back(page);
    _slice_index = 0;
}

void G_Arena::set_player(unsigned index, G_WorldPlayer *player, unsigned arena2, unsigned arena_day) noexcept {
    unsigned slice = index / G_ARENA_SLICE_SIZE;
    while (slice >= _slices.size()) {
        grow_slice();
    }

    player->_arena = index;
    player->_arena_day = arena_day;
    player->_arena2 = arena2;

    index %= G_ARENA_SLICE_SIZE;
    *(((G_WorldPlayer**)_slices[slice]->firstp) + index) = player;
    index++;
    if (_slice_index < index) {
        _slice_index = index;
    }
}

bool G_Arena::swap(G_WorldPlayer *attacker, G_WorldPlayer *defender) noexcept {
    G_WorldPlayer **p1 = get_player_p(attacker->arena());
    G_WorldPlayer **p2 = get_player_p(defender->arena());
    if (!p1 || !p2) {
        return false;
    }

    *p2 = attacker;
    *p1 = defender;

    unsigned n = attacker->arena();
    attacker->arena(defender->arena());
    defender->arena(n);
    return true;
}

