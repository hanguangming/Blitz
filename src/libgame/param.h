#ifndef __LIBGAME_PARAM_H__
#define __LIBGAME_PARAM_H__

#include "game.h"
#include "item.h"
#include "money.h"
#include "award.h"

class G_ParamMgr : public Object, public singleton<G_ParamMgr> {
public:
    G_ParamMgr();
    bool init();

    const G_ItemInfo *train_item() const noexcept {
        return _train_item;
    }
    const G_ItemInfo *expup_item() const noexcept {
        return _expup_item;
    }
    unsigned expup_value() const noexcept {
        return _expup_value;
    }
    unsigned fire_hero_limit() const noexcept {
        return _fire_hero_limit;
    }
    timeval_t tech_acc_time() const noexcept {
        return _tech_acc_time;
    }
    const G_Money &tech_acc_price() const noexcept {
        return _tech_acc_price;
    }
    const G_ItemInfo *tiger_item() const noexcept {
        return _tiger_item;
    }
    unsigned tiger_times() const noexcept {
        return _tiger_times;
    }
    unsigned tiger_grow() const noexcept {
        return _tiger_grow;
    }
    unsigned team_hero_people() const noexcept {
        return _team_hero_people;
    }
    unsigned team_soldier_people() const noexcept {
        return _team_soldier_people;
    }
    unsigned free_supplement_num() const noexcept {
        return _free_supplement_num;
    }
    const G_ItemInfo *supplement_item() const noexcept {
        return _supplement_item;
    }
    unsigned free_shadow_num() const noexcept {
        return _free_shadow_num;
    }
    const G_Money &shadow_define_price() const noexcept {
        return _shadow_define_price;
    }
    unsigned shadow_grow_times() const noexcept {
        return _shadow_grow_times;
    }
    const G_Money &shadow_grow_price() const noexcept {
        return _shadow_grow_price;
    }
    unsigned challenge_times() const noexcept {
        return _challenge_times;
    }
    const G_ItemInfo *challenge_item() const noexcept {
        return _challenge_item;
    }
    const G_AwardInfo *challenge_win_award() const noexcept {
        return _challenge_win_award;
    }
    const G_AwardInfo *challenge_lose_award() const noexcept {
        return _challenge_lose_award;
    }
    timeval_t train_acc_time() const noexcept {
        return _train_acc_time;
    }
    const G_Money &train_acc_price() const noexcept {
        return _train_acc_price;
    }
    unsigned stage_batch_stage_limit() const noexcept {
        return _stage_batch_stage_limit;
    }
    unsigned stage_batch_times_limit() const noexcept {
        return _stage_batch_times_limit;
    }
private:
    const G_ItemInfo *_train_item;
    const G_ItemInfo *_expup_item;
    unsigned _fire_hero_limit;
    unsigned _expup_value;
    timeval_t _tech_acc_time;
    G_Money _tech_acc_price;
    const G_ItemInfo *_tiger_item;
    unsigned _tiger_times;
    unsigned _tiger_grow;
    unsigned _team_hero_people;
    unsigned _team_soldier_people;
    unsigned _free_supplement_num;
    const G_ItemInfo *_supplement_item;
    unsigned _free_shadow_num;
    G_Money _shadow_define_price;
    unsigned _shadow_grow_times;
    G_Money _shadow_grow_price;
    unsigned _challenge_times;
    const G_ItemInfo *_challenge_item;
    const G_AwardInfo *_challenge_win_award;
    const G_AwardInfo *_challenge_lose_award;
    timeval_t _train_acc_time;
    G_Money _train_acc_price;
    unsigned _stage_batch_stage_limit;
    unsigned _stage_batch_times_limit;
};

#endif

