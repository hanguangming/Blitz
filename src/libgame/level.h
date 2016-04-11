#ifndef __LIBGAME_LEVEL_H__
#define __LIBGAME_LEVEL_H__

#include "game.h"
#include "object.h"
#include "money.h"

class G_LevelInfo : public G_ObjectInfo {
    friend class G_LevelMgr;
public:
    G_LevelInfo() : _next_level() { }

    unsigned exp() const noexcept {
        return _player_exp;
    }

    unsigned soldier_exp() const noexcept {
        return _soldier_exp;
    }

    const G_LevelInfo *next_level() const noexcept {
        return _next_level;
    }

    unsigned level() const noexcept {
        return _level;
    }

    const G_Money &train_low_price() const noexcept {
        return _train_low_price;
    }
    const G_Money &train_middle_price() const noexcept {
        return _train_middle_price;
    }
    unsigned train_low_exp() const noexcept {
        return _train_low_exp;
    }
    unsigned train_middle_exp() const noexcept {
        return _train_middle_exp;
    }
    unsigned train_high_exp() const noexcept {
        return _train_high_exp;
    }
    unsigned train_speedup_exp() const noexcept {
        return _speedup_exp;
    }
    
private:
    unsigned _level;
    unsigned _player_exp;
    const G_LevelInfo *_next_level;

    G_Money _train_low_price;
    G_Money _train_middle_price;
    unsigned _train_low_exp;
    unsigned _train_middle_exp;
    unsigned _train_high_exp;
    unsigned _soldier_exp;
    unsigned _speedup_exp;
};

class G_LevelMgr : public G_ObjectInfoContainer<G_LevelInfo>, public singleton<G_LevelMgr> {
    typedef G_ObjectInfoContainer<G_LevelInfo> base_type;

public:
    bool init();

    const G_LevelInfo *get_info(unsigned level) const noexcept {
        const G_LevelInfo *info = base_type::get_info(level);
        if (!info) {
            info = _max_level;
        }
        return info;
    }
private:
    G_LevelInfo *_max_level;
};

#endif

