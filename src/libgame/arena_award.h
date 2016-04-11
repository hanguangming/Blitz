#ifndef __LIBGAME_ARENA_AWARD_H__
#define __LIBGAME_ARENA_AWARD_H__

#include "object.h"
#include "award.h"

class G_ArenaAwardInfo : public G_ObjectInfo {
    friend class G_ArenaAwardMgr;
public:
    G_ArenaAwardInfo() noexcept;

    const G_AwardInfo *award() const noexcept {
        return _award;
    }
private:
    const G_AwardInfo *_award;
};


class G_ArenaAwardMgr : public G_ObjectInfoContainer<G_ArenaAwardInfo>, public singleton<G_ArenaAwardMgr> {
public:
    bool init();
    const G_ArenaAwardInfo *get_info(unsigned rank) const noexcept {
        auto it = _infos.lower_bound(rank);
        if (it == _infos.end()) {
            return nullptr;
        }
        return it->second;
    }
};
#endif

