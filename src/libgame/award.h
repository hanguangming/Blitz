#ifndef __LIBGAME_AWARD_H__
#define __LIBGAME_AWARD_H__

#include "object.h"
#include "item.h"
#include "libgame/g_award.h"

class G_Player;
class G_AwardItemInfo : public Object {
    friend class G_AwardMgr;
    friend class G_AwardInfo;
public:
    G_AwardItemInfo() noexcept
    : _info(), _min(), _max()
    { }

    unsigned min() const noexcept {
        return _min;
    }
    unsigned max() const noexcept {
        return _max;
    }
    const G_ItemInfo *info() const noexcept {
        return _info;
    }
private:
    const G_ItemInfo *_info;
    unsigned _min;
    unsigned _max;
};

class G_AwardInfo : public G_ObjectInfo {
    friend class G_AwardMgr;
public:
    G_AwardInfo() noexcept
    : _min(), _max()
    { }

    void exec(G_Player *player, unsigned count = 1, obstack_vector<G_AwardItem> *infos = nullptr) const noexcept;
private:
private:
    unsigned _min;
    unsigned _max;
    ProbContainer<G_AwardItemInfo> _probs;
    std::vector<ptr<G_AwardItemInfo>> _must;
};

class G_AwardMgr : public G_ObjectInfoContainer<G_AwardInfo>, public singleton<G_AwardMgr> {
public:
    using G_ObjectInfoContainer<G_AwardInfo>::get_info;
    bool init();
};

#endif

