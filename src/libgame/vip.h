#ifndef __LIBGAME_VIP_H__
#define __LIBGAME_VIP_H__

#include "object.h"

class G_VipInfo : public G_ObjectInfo {
    friend class G_VipMgr;
public:
    G_VipInfo() noexcept 
    : _next(nullptr), _exp()
    { }
    const G_VipInfo *next() const noexcept {
        return _next;
    }
    unsigned exp() const noexcept {
        return _exp;
    }
    unsigned level() const noexcept {
        return _level;
    }
    bool forge_high() const noexcept {
        return _forge_high;
    }
    unsigned hero_limit() const noexcept {
        return _hero_limit;
    }
    unsigned train_limit() const noexcept {
        return _train_limit;
    }
    bool recruit_high() const noexcept {
        return _recruit_high;
    }
    bool train_high() const noexcept {
        return _train_high;
    }
    unsigned morders_limit() const noexcept {
        return _morders_limit;
    }
    unsigned stage_batch() const noexcept {
        return _stage_batch;
    }
private:
    const G_VipInfo *_next;
    unsigned _exp;
    unsigned _level;
    bool _forge_high;
    unsigned _hero_limit;
    unsigned _train_limit;
    unsigned _recruit_high;
    unsigned _train_high;
    unsigned _morders_limit;
    unsigned _stage_batch;
};

class G_VipMgr : public G_ObjectInfoContainer<G_VipInfo>, public singleton<G_VipMgr> {
public:
    bool init();

    const G_VipInfo *get_info(unsigned level) const noexcept {
        const G_VipInfo *info = G_ObjectInfoContainer<G_VipInfo>::get_info(level);
        if (!info) {
            info = _max_level;
        }
        return info;
    }

private:
    G_VipInfo *_max_level;
};
#endif

