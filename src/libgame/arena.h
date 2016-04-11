#ifndef __LIBGAME_ARENA_H__
#define __LIBGAME_ARENA_H__


#include "world_player.h"

#define G_ARENA_SLICE_SIZE (PageAllocator::sys_page_size / sizeof(void*))

class G_Arena : public Object {
    friend class G_World;
public:
    G_Arena() noexcept;
    ~G_Arena() noexcept;
    G_WorldPlayer *get_player(unsigned index) const noexcept {
        G_WorldPlayer** p = get_player_p(index);
        if (!p) {
            return nullptr;
        }
        return *p;
    }
    unsigned size() const noexcept {
        return (_slices.size() - 1) * G_ARENA_SLICE_SIZE + _slice_index;
    }
    unsigned add_player(G_WorldPlayer *player) noexcept;
    bool swap(G_WorldPlayer *attacker, G_WorldPlayer *defender) noexcept;
private:
    G_WorldPlayer **get_player_p(unsigned index) const noexcept {
        unsigned slice = index / G_ARENA_SLICE_SIZE;
        if (slice >= _slices.size()) {
            return nullptr;
        }
        index %= G_ARENA_SLICE_SIZE;
        if (index >= _slice_index) {
            return nullptr;
        }
        return ((G_WorldPlayer**)_slices[slice]->firstp) + index;
    }
    void grow_slice() noexcept;
    void set_player(unsigned index, G_WorldPlayer *player, unsigned arena2, unsigned arena_day) noexcept;
private:
    std::vector<Page*> _slices;
    unsigned _slice_index;
};

#endif

