#include "formation.h"
#include "context.h"
#include "player.h"

/* G_Formation */
bool G_Formation::init(G_Player *player, const obstack_vector<G_FormationItemOpt> &opts, bool igorn_error) noexcept {
    if (opts.size() > player->tech()->soldier_pvp()) {
        return false;
    }
    for (auto &opt : opts) {
        G_Soldier *hero = player->corps()->get(opt.sid);
        if (!hero || !hero->info()->is_hero()) {
            if (!igorn_error) {
                return false;
            }
            continue;
        }

        G_Soldier *soldier = player->corps()->get(opt.sid2);
        if (!soldier || soldier->info()->is_hero()) {
            if (!igorn_error) {
                return false;
            }
            continue;
        }

        G_FormationItem *item = probe_object(opt.sid, hero->info());
        if (item->_soldier) {
            if (!igorn_error) {
                return false;
            }
            continue;
        }
        item->_soldier = soldier->info();
        item->_x = opt.x;
        item->_y = opt.y;
    }
    return true;
}

void G_Formation::change_soldier(const G_SoldierInfo *old_info, const G_SoldierInfo *new_info) noexcept {
    assert(old_info->is_hero() == new_info->is_hero());

    if (old_info->is_hero()) {
        ptr<G_FormationItem> old_item = remove_object(old_info->id());
        if (!old_item) {
            return;
        }
        G_FormationItem *new_item = probe_object(new_info->id(), new_info);
        if (new_item) {
            new_item->_soldier = old_item->_soldier;
            new_item->_x = old_item->_x;
            new_item->_y = old_item->_y;
        }
    }
    else {
        bool found = false;
        for (G_FormationItem *item : objects()) {
            if (item->_soldier == old_info) {
                item->_soldier = new_info;
                found = true;
            }
        }
        if (!found) {
            return;
        }
    }
    the_data()->_formation_opts.emplace_back();
    to_opt(the_data()->_formation_opts.back());
}

void G_Formation::remove_soldier(const G_SoldierInfo *info) noexcept {
    assert(info->is_hero());
    if (remove_object(info->id())) {
        the_data()->_formation_opts.emplace_back();
        to_opt(the_data()->_formation_opts.back());
    }
}

void G_Formation::to_opt(G_FormationOpt &opt) noexcept {
    opt.id = _id;
    for (G_FormationItem *item : objects()) {
        opt.items.emplace_back();
        auto &opt_item = opt.items.back();
        opt_item.sid = item->id();
        opt_item.sid2 = item->_soldier->id();
        opt_item.x = item->_x;
        opt_item.y = item->_y;
    }
}

/* G_Formations */
bool G_Formations::init(G_Player *player, const obstack_vector<G_FormationOpt> &opts, bool igorn_error) noexcept {
    ptr<G_Formation> formations[G_FORMATION_NUM];
    for (auto &opt : opts) {
        unsigned index = opt.id;
        if (index >= G_FORMATION_NUM) {
            if (!igorn_error) {
                return false;
            }
            continue;
        }

        object<G_Formation> form(index);
        if (!form->init(player, opt.items, igorn_error)) {
            if (!igorn_error) {
                return false;
            }
            continue;
        }
        formations[index] = form;
    }

    for (unsigned i = 0; i < G_FORMATION_NUM; ++i) {
        if (formations[i]) {
            _formations[i] = formations[i];
        }
    }
    return true;
}

void G_Formations::change_soldier(const G_SoldierInfo *old_info, const G_SoldierInfo *new_info) noexcept {
    for (unsigned i = 0; i < G_FORMATION_NUM; ++i) {
        if (_formations[i]) {
            _formations[i]->change_soldier(old_info, new_info);
        }
    }
}

void G_Formations::remove_soldier(const G_SoldierInfo *info) noexcept {
    for (unsigned i = 0; i < G_FORMATION_NUM; ++i) {
        if (_formations[i]) {
            _formations[i]->remove_soldier(info);
        }
    }
}

void G_Formations::to_opt(obstack_vector<G_FormationOpt> &opts) noexcept {
    for (unsigned i = 0; i < G_FORMATION_NUM; ++i) {
        G_Formation *form = _formations[i];
        if (!form) {
            continue;
        }
        opts.emplace_back();
        form->to_opt(opts.back());
    }
}


