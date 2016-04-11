#include "fight.h"
#include "fightsvr/fs_fight.h"
#include "libgame/g_defines.h"
#include "param.h"
#include "soldier.h"

/* G_ManagedFightCorps */
unsigned G_ManagedFightCorps::people() const noexcept {
    unsigned result = 0;
    unsigned tp = G_ParamMgr::instance()->team_hero_people();
    for (G_ManagedFightTeam *team : teams) {
        if (team->hero_hp) {
            result += tp;
        }
        if (team->soldier_num) {
            const G_SoldierInfo *soldier = G_SoldierMgr::instance()->get_info(team->soldier_id);
            if (soldier) {
                result += (soldier->people() * team->soldier_num);
            }
        }
    }
    return result;
}

unsigned the_fight_people(G_ManagedFightCorps &corps) noexcept {
    return corps.people();
}

unsigned the_fight_people(G_FightCorps &corps) noexcept {
    unsigned result = 0;
    unsigned tp = G_ParamMgr::instance()->team_hero_people();
    for (auto &team : corps.teams) {
        if (team.hero_hp) {
            result += tp;
        }
        if (team.soldier_num) {
            const G_SoldierInfo *soldier = G_SoldierMgr::instance()->get_info(team.soldier_id);
            if (soldier) {
                result += (soldier->people() * team.soldier_num);
            }
        }
    }
    return result;
}

/* G_FightReport */
void G_FightReport::add(const G_FightInfo &info) noexcept {
    object<G_ManagedFightInfo> fight_info;
    *fight_info = info;
    _list.push_back(fight_info);
    if (_list.size() > G_FIGHT_REPORT_MAX) {
        _list.pop_front();
    }
}

void G_FightReport::to_opt(obstack_vector<G_FightInfo> &opts) noexcept {
    for (G_ManagedFightInfo *info : _list) {
        opts.emplace_back();
        info->to_unmanaged(opts.back());
    }
    _list.clear();
}

/* G_FightCalcMgr */
bool G_FightCalcMgr::init() {
    return true;
}

bool G_FightCalcMgr::call(G_FightInfo &info, G_FightInfo &result) noexcept {
    timeval_t t1 = std::chrono::duration_cast<std::chrono::milliseconds>(
        std::chrono::system_clock::now().time_since_epoch()
    ).count();

    Script *lua = the_app->script();
    lua_getglobal(*lua, "__fight_calc__");
    lua_createtable(*lua, 0, 0);
    info.to_lua(*lua, -1);
    if (lua_pcall(*lua, 1, 1, 0)) {
        const char *error = lua_tostring(*lua, -1);
        log_error("fight calc failed, %s", error);
        lua_pop(*lua, 1);

        return false;
    }

    bool ret = result.from_lua(*lua, -1);
    lua_pop(*lua, 1);

    timeval_t t2 = std::chrono::duration_cast<std::chrono::milliseconds>(
        std::chrono::system_clock::now().time_since_epoch()
    ).count();

    log_debug("fight use time %lu\n", t2 - t1);
    return ret;
}

