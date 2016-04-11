#include "npc.h"
#include "map.h"

G_NpcTeam::G_NpcTeam() noexcept 
: _hero(),
  _soldier(),
  _soldier_num(),
  _x(),
  _y()
{ }

G_NpcInfo::G_NpcInfo() noexcept
: _appearance(),
  _type()
{ }

bool G_NpcMgr::init() {
    G_NpcInfo *info = nullptr;

    auto tab_info = the_app->script()->read_table("the_npc_info");
    if (tab_info->is_nil()) {
        return false;
    }
    for (unsigned i = 1; ; ++i) {
        auto tab_item = tab_info->read_table(i);
        if (tab_item->is_nil()) {
            break;
        }

        int id = tab_item->read_integer("ID", -1);
        int type = tab_item->read_integer("type", -1);
        if (id < 0) {
            continue;
        }

        if (id > 0) {
            info = probe_info(id);
            info->_type = type;
            info->_appearance = tab_item->read_integer("heroid1", -1);

            switch (type) {
            case 1:
                _defender = info;
                break;
            }
        }
        else {
            if (!info) {
                log_error("bad npc config.");
                return false;
            }
            unsigned hero_id = tab_item->read_integer("heroid", 0);
            unsigned soldier_id = tab_item->read_integer("soldierid", 0);
            info->_teams.emplace_back();
            auto &team = info->_teams.back();

            team._hero = G_SoldierMgr::instance()->get_info(hero_id);
            if (!team._hero) {
                log_error("unknown hero id '%d'.", hero_id);
                return false;
            }

            team._soldier = G_SoldierMgr::instance()->get_info(soldier_id);
            if (!team._soldier) {
                log_error("unknown soldier id '%d'.", soldier_id);
                return false;
            }


            team._soldier_num = tab_item->read_integer("soldiernum", 0);
            team._x = tab_item->read_integer("x", 0);
            team._y = tab_item->read_integer("y", 0);

        }
    }

    if (!_defender) {
        log_error("no defender.");
        return false;
    }
    return true;
}


/* G_Npc */
G_MapNpc::G_MapNpc(unsigned type, const G_NpcInfo *info, G_MapSide *side) noexcept
: G_MapUnit(type),
  _info(info)
{ 
    _id = G_Map::instance()->make_guid();
    _side = side;
}

/* G_NpcDefender */
void G_NpcDefender::get_corps(G_FightCorps *corps) noexcept {
    corps->uid = unit_id();

    G_FightAttr attr;
    for (auto &team_info : _info->teams()) {
        corps->teams.emplace_back();
        auto &team = corps->teams.back();

        team_info.hero()->build_fight_info(1, attr);
        team.hero_id = team_info.hero()->id();
        team.hero_attack = attr.attack;
        team.hero_attack_speed = attr.attack_speed;
        team.hero_hp = attr.hp;

        team_info.soldier()->build_fight_info(1, attr);
        team.soldier_id = team_info.soldier()->id();
        team.soldier_attack = attr.attack;
        team.soldier_attack_speed = attr.attack_speed;
        team.soldier_hp = attr.hp;
        team.soldier_num = team_info.soldier_num();

        team.x = team_info.x();
        team.y = team_info.y();
    }
}

void G_NpcDefender::set_corps(const G_FightCorps *corps) noexcept {
}

void G_NpcDefender::fight_finish() noexcept {
}


/* G_NpcShadow */
G_NpcShadow::G_NpcShadow(G_MapPlayer *player, G_FightCorps &corps) noexcept 
: G_MapNpc(G_MAP_UNIT_SHADOW, nullptr, player->side()) {
    _vip = player->vip();
    _level = player->level();
    _appearance = player->appearance();
    _name = player->name();
    _corps = object<G_ManagedFightCorps>();
    *_corps = corps;
}

void G_NpcShadow::get_corps(G_FightCorps *corps) noexcept {
    if (_corps) {
        _corps->to_unmanaged(*corps);
    }
}

void G_NpcShadow::set_corps(const G_FightCorps *corps) noexcept {
    if (!corps) {
        _corps = nullptr;
        return;
    }
    _corps = object<G_ManagedFightCorps>();
    *_corps = *corps;
}

void G_NpcShadow::fight_finish() noexcept {
}

