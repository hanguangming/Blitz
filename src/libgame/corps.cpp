#include "corps.h"
#include "context.h"
#include "player.h"
#include "param.h"
#include "equip.h"
#include "dbsvr/db_login.h"
#include "formation.h"
#include "libgame/g_fight.h"
#include "agentsvr/as_system_notify.h"

/* G_SoldierValues */
void G_SoldierValues::mark_update(unsigned index, unsigned value) noexcept {
    Obstack *pool = the_pool();
    auto r = the_data()->_soldier_value_opts.emplace(_soldier->id(), obstack_vector<G_ValueOpt>(pool));
    r.first->second.emplace_back();
    auto &opt = r.first->second.back();
    opt.id = index;
    opt.value = value;
}

/* G_Soldier */
G_Soldier::G_Soldier() noexcept
: _level(), _values(this), _fight_info_dirty(true)
{ }

void G_Soldier::add_exp(unsigned value) noexcept {
    G_Player *player = the_player();
    unsigned exp = _values.get(G_SOLDIER_EXP) + value;
    const G_LevelInfo *level = _level;
    while (1) {
        if (exp < level->soldier_exp()) {
            break;
        }
        if (!level->next_level() || level->level() >= player->level()) {
            exp = level->soldier_exp();
            break;
        }
        exp -= level->soldier_exp();
        level = level->next_level();
        mark_fight_info_dirty();
    }

    _values.set(G_SOLDIER_EXP, exp);
    _values.set(G_SOLDIER_LEVEL, level->level());
    if (_level != level) {
        player->update_score(-score());
        _level = level;
        player->update_score(score());
    }
}

void G_Soldier::gm_set_level(unsigned value) noexcept {
    _level = G_LevelMgr::instance()->get_info(value);
    _values.set(G_SOLDIER_LEVEL, _level->level());
}

void G_Soldier::copy(G_Soldier *other) noexcept {
    G_Player *player = the_player();
    for (unsigned i = 0; i < G_SOLDIER_UNKNOWN; ++i) {
        unsigned value = other->_values.get(i);
        switch (i) {
        case G_SOLDIER_USED:
            if (value) {
                other->_values.init(i, 0);
            }
            break;
        case G_SOLDIER_EQUIP_BEGIN...G_SOLDIER_EQUIP_END:
            if (value) {
                other->_values.init(i, 0);
                G_BagItem *item = player->bag()->get_item(value);
                if (item) {
                    item->init_owner(this);
                }
            }
            break;
        }
        _values.set(i, value);
    }
    _level = other->_level;
    mark_fight_info_dirty();
}

bool G_Soldier::use_equip(G_BagItem *item) noexcept {
    const G_ItemInfo *item_info = item->info();
    if (!item_info->is_equip()) {
        return false;
    }
    unsigned index = item_info->type() - G_ITYPE_EQUIP_BEGIN + G_SOLDIER_EQUIP_BEGIN;
    unsigned old_id = _values.get(index);
    G_Player *player = the_player();

    if (item->used()) {
        if (item->id() != old_id) {
            return false;
        }
        item->used(nullptr);
        _values.set(index, 0);
    }
    else {
        if (old_id) {
            G_BagItem *old_item = player->bag()->get_item(old_id);
            if (old_item && old_item != item) {
                old_item->used(nullptr);
            }
        }
        item->used(this);
        _values.set(index, item->id());
    }
    return true;
}

bool G_Soldier::use_expup(unsigned count) noexcept {
    if (!count) {
        return false;
    }

    G_Player *player = the_player();
    if (!player->bag()->has_item(G_ParamMgr::instance()->expup_item(), count)) {
        return false;
    }

    player->bag()->remove_item(G_ParamMgr::instance()->expup_item(), count);
    add_exp(G_ParamMgr::instance()->expup_value() * count);
    return true;
}

void G_Soldier::get_off_all() noexcept {
    G_Player *player = the_player();
    for (unsigned i = G_SOLDIER_EQUIP_BEGIN; i <= G_SOLDIER_EQUIP_END; ++i) {
        unsigned equip = _values.get(i);
        if (equip) {
            G_BagItem *item = player->bag()->get_item(equip);
            if (item) {
                item->used(nullptr);
            }
        }
    }
}

inline void G_Soldier::rebuild_fight_info() noexcept {
    if (!_fight_info_dirty) {
        return;
    }
    _fight_info_dirty = false;

    G_Player *player = the_player();
    unsigned level = _level->level();
    if (level < 1) {
        level = 1;
    }

    _info->build_fight_info(level, _attr);

    unsigned star_num = 0;
    for (unsigned i = G_SOLDIER_EQUIP_BEGIN; i <= G_SOLDIER_EQUIP_END; ++i) {
        unsigned equip_id = _values.get(i);
        G_BagItem *item = player->bag()->get_item(equip_id);
        if (!item) {
            continue;
        }
        const G_ItemInfo *item_info = item->info();
        level = item->value();
        if (level < 1) {
            level = 1;
        }
        const G_EquipInfo *equip_info = G_EquipMgr::instance()->get_info(item_info, level);
        if (!equip_info) {
            continue;
        }

        star_num += item_info->star();
        _attr.attack += equip_info->attack();
        _attr.attack_speed += equip_info->attack_speed();
        _attr.hp += equip_info->hp();
    }

    const G_EquipSuitInfo *suit_info = G_EquipSuitMgr::instance()->get_info(star_num);
    if (suit_info) {
        _attr.attack = ((100 + suit_info->attack()) * _attr.attack) / 100;
        _attr.attack_speed += suit_info->attack_speed();
        _attr.hp += ((100 + suit_info->hp()) * _attr.hp) / 100;
    }
}

/* G_Corps */
G_Corps::G_Corps() noexcept 
: _hero_count(),
  _hero_used()
{ }

G_Soldier *G_Corps::add(const G_SoldierInfo *info, G_Soldier *other) noexcept {
    G_Soldier *s = probe_object(info->id(), info);
    if (s->_level) {
        return nullptr;
    }
    if (other) {
        s->copy(other);
    }
    else {
        s->_level = G_LevelMgr::instance()->get_info(1);
        s->_values.set(G_SOLDIER_LEVEL, 1);
    }
    if (info->is_hero()) {
        _hero_count++;
    }
    if (info->quality() < G_QUALITY_UNKNOWN) {
        _qualities[info->quality()].add(s);
        if (info->quality() >= G_QUALITY_RANKING_BEGIN) {
            the_player()->mark_soldier_ranking_dirty();
        }
    }
    the_player()->update_score(s->score());
    return s;
}

ptr<G_Soldier> G_Corps::remove(unsigned id) noexcept {
    ptr<G_Soldier> soldier = remove_object(id);
    if (soldier) {
        G_Player *player = the_player();
        the_data()->_soldier_opts.emplace_back();
        auto &opt = the_data()->_soldier_opts.back();
        opt.sid = id;
        if (soldier->info()->is_hero()) {
            _hero_count--;

            if (soldier->_values.get(G_SOLDIER_USED)) {
                _hero_used--;
            }
            player->hero_train()->remove(id);
            soldier->get_off_all();
            player->formations()->remove_soldier(soldier->info());
        }
        else {
            player->soldier_train()->remove(id);
        }

        unsigned quality = soldier->info()->quality();
        if (quality < G_QUALITY_UNKNOWN) {
            _qualities[quality].remove(soldier);
            if (quality >= G_QUALITY_RANKING_BEGIN) {
                the_player()->mark_soldier_ranking_dirty();
            }
        }
        the_player()->update_score(-soldier->score());
    }
    return soldier;
}

void G_Corps::init(G_Player *player, DB_LoadRsp *msg) noexcept {
    for (auto &value : msg->soldier_values) {
        const G_SoldierInfo *info = G_SoldierMgr::instance()->get_info(value.sid);
        if (!info) {
            continue;
        }
        G_Soldier *soldier = probe_object(value.sid, info);

        for (auto &v : value.values) {
            soldier->_values.init(v.id, v.value);
            if (v.id >= G_SOLDIER_EQUIP_BEGIN && v.id <= G_SOLDIER_EQUIP_END) {
                G_BagItem *item = player->bag()->get_item(v.value);
                if (item) {
                    item->init_owner(soldier);
                }
            }
        }

        if (info->is_hero()) {
            _hero_count++;
            if (soldier->_values.get(G_SOLDIER_USED)) {
                _hero_used++;
            }

        }
        soldier->_level = G_LevelMgr::instance()->get_info(soldier->_values.get(G_SOLDIER_LEVEL));

        unsigned quality = info->quality();
        if (quality < G_QUALITY_UNKNOWN) {
            _qualities[quality].add(soldier);
        }
    }
}

const G_SoldierInfo *G_Corps::employ(unsigned sid) noexcept {
    if (!sid) {
        return nullptr;
    }

    G_Player *player = the_player();
    if (_hero_count >= player->vip()->hero_limit()) {
        return nullptr;
    }

    const G_SoldierInfo *info = G_SoldierMgr::instance()->get_info(sid);
    if (!info) {
        return nullptr;
    }
    if (!info->is_hero()) {
        return nullptr;
    }

    unsigned i;
    for (i = G_VALUE_RECRUIT_BEGIN; i <= G_VALUE_RECRUIT_END; ++i) {
        if (player->_values.get(i) == sid) {
            break;
        }
    }
    if (i > G_VALUE_RECRUIT_END) {
        return nullptr;
    }

    if (!add(info)) {
        return nullptr;
    }
    player->_values.set(i, 0);

    return info;
}

bool G_Corps::use_hero(unsigned sid, bool use) noexcept {
    G_Soldier *soldier = get(sid);
    if (!soldier) {
        return false;
    }

    bool used = (soldier->_values.get(G_SOLDIER_USED) != 0);
    if (use == used) {
        return false;
    }

    if (use) {
        if (the_player()->tech()->soldier_pve() <= _hero_used) {
            return false;
        }
        _hero_used++;
    }
    else {
        _hero_used--;
    }
    soldier->_values.set(G_SOLDIER_USED, use);
    return true;
}


bool G_Corps::supplement_soldier(G_Formation *form, G_FightCorps &corps) noexcept {
    G_Player *player = the_player();
    if (!player->_values.get(G_VALUE_SUPPLEMENT)) {
        if (!player->bag()->has_item(G_ParamMgr::instance()->supplement_item(), 1)) {
            return false;
        }
        player->bag()->remove_item(G_ParamMgr::instance()->supplement_item(), 1);
    }
    else {
        player->_values.sub(G_VALUE_SUPPLEMENT, 1);
    }

    return get_fight_info(form, corps);
}

bool G_Corps::get_fight_info(G_Formation *form, G_FightCorps &corps) noexcept {
    G_Player *player = the_player();
    if (form) {
        for (G_FormationItem *item : form->objects()) {
            const G_SoldierInfo *hero_info = item->info();
            G_Soldier *hero = get(hero_info);
            if (!hero) {
                continue;
            }
            const G_SoldierInfo *soldier_info = item->soldier();
            if (!soldier_info) {
                continue;
            }
            G_Soldier *soldier = get(soldier_info);
            if (!soldier) {
                continue;
            }

            corps.teams.emplace_back();
            auto &team = corps.teams.back();

            hero->rebuild_fight_info();
            team.hero_id = hero_info->id();
            team.hero_attack = hero->_attr.attack;
            team.hero_hp_max = team.hero_hp = hero->_attr.hp;
            team.hero_attack_speed = hero->_attr.attack_speed;

            soldier->rebuild_fight_info();
            team.soldier_id = soldier_info->id();
            team.soldier_attack = soldier->_attr.attack;
            team.soldier_hp = soldier->_attr.hp;
            team.soldier_attack_speed = soldier->_attr.attack_speed;

            unsigned n = soldier_info->people();
            if (!n) {
                n = 1;
            }
            team.soldier_num = G_ParamMgr::instance()->team_soldier_people() / n;
            team.x = item->x();
            team.y = item->y();
        }
    }
    corps.uid = player->id();
    corps.vip = player->vip()->level();
    corps.name = player->name();

    return true;
}

