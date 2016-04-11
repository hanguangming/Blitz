#ifndef __LIBGAME_STAGE_H__
#define __LIBGAME_STAGE_H__

#include "object.h"
#include "award.h"
class G_StageInfo : public G_ObjectInfo {
    friend class G_StageMgr;
public:
    G_StageInfo() noexcept;
    unsigned morders() const noexcept {
        return _morders;
    }
    const G_AwardInfo *win_award() const noexcept {
        return _win_award;
    }
    const G_AwardInfo *lose_award() const noexcept {
        return _lose_award;
    }
private:
    unsigned _morders;
    const G_AwardInfo *_win_award;
    const G_AwardInfo *_lose_award;
};

class G_StageMgr : public G_ObjectInfoContainer<G_StageInfo>, public singleton<G_StageMgr> {
public:
    using G_ObjectInfoContainer<G_StageInfo>::get_info;
    bool init();

    const G_StageInfo *first() const noexcept {
        return _first;
    }
private:
    const G_StageInfo *_first;
};

#endif

