#ifndef __LIBGAME_FIGHT_H__
#define __LIBGAME_FIGHT_H__

#include <list>

#include "game.h"
#include "libgame/g_fight.h"
#include "player_object.h"

struct G_FightAttr {
    G_FightAttr() noexcept 
    : attack(),
      attack_speed(),
      hp()
    { }

    G_FightAttr operator+(const G_FightAttr &rhs) noexcept {
        G_FightAttr attr;
        attr.attack = attack + rhs.attack;
        attr.attack_speed = attack_speed + rhs.attack_speed;
        attr.hp = hp + rhs.hp;
        return attr;
    }
    G_FightAttr operator+=(const G_FightAttr &rhs) noexcept {
        attack += rhs.attack;
        attack_speed += rhs.attack_speed;
        hp += rhs.hp;
        return *this;
    }

    unsigned attack;
    unsigned attack_speed;
    unsigned hp;
};

struct G_ManagedFightTeam : Object {
    void operator=(const G_FightTeam &team) noexcept {
        hero_id             = team.hero_id;
        hero_attack         = team.hero_attack;
        hero_attack_speed   = team.hero_attack_speed;
        hero_hp_max         = team.hero_hp_max;
        hero_hp             = team.hero_hp;

        soldier_id          = team.soldier_id;
        soldier_attack      = team.soldier_attack;
        soldier_attack_speed = team.soldier_attack_speed;
        soldier_hp          = team.soldier_hp;
        soldier_num         = team.soldier_num;

        x = team.x;
        y = team.y;
    }

    void to_unmanaged(G_FightTeam &target) noexcept {
        target.hero_id              = hero_id;
        target.hero_attack          = hero_attack;
        target.hero_attack_speed    = hero_attack_speed;
        target.hero_hp_max          = hero_hp_max;
        target.hero_hp              = hero_hp;

        target.soldier_id           = soldier_id;
        target.soldier_attack       = soldier_attack;
        target.soldier_attack_speed = soldier_attack_speed;
        target.soldier_hp           = soldier_hp;
        target.soldier_num          = soldier_num;

        target.x = x;
        target.y = y;
    }

    unsigned hero_id;
    unsigned hero_attack;
    unsigned hero_attack_speed;
    unsigned hero_hp_max;
    unsigned hero_hp;

    unsigned soldier_id;
    unsigned soldier_attack;
    unsigned soldier_attack_speed;
    unsigned soldier_hp;
    unsigned soldier_num;

    unsigned x;
    unsigned y;
};

struct G_ManagedFightCorps : Object {
    G_ManagedFightCorps() noexcept
    : uid(), vip()
    { }

    ~G_ManagedFightCorps() noexcept {
        teams.clear();
    }

    void operator=(const G_FightCorps &corps) noexcept {
        teams.resize(0);

        uid = corps.uid;
        vip = corps.vip;
        name = corps.name;
        for (auto &team : corps.teams) {
            if (team.hero_hp || team.soldier_num) {
                object<G_ManagedFightTeam> managed_team;
                *managed_team = team;
                teams.push_back(managed_team);
            }
        }
    }

    void to_unmanaged(G_FightCorps &target) noexcept {
        target.uid = uid;
        target.vip = vip;
        target.name = name;
        target.teams.resize(0);
        for (G_ManagedFightTeam *team : teams) {
            if (team->hero_hp || team->soldier_num) {
                target.teams.emplace_back();
                team->to_unmanaged(target.teams.back());
            }
        }
    }

    unsigned people() const noexcept;

    unsigned uid;
    unsigned vip;
    std::string name;
    std::vector<ptr<G_ManagedFightTeam>> teams;

};

unsigned the_fight_people(G_ManagedFightCorps &corps) noexcept;
unsigned the_fight_people(G_FightCorps &corps) noexcept;

struct G_ManagedFightInfo : Object {
    G_ManagedFightInfo() noexcept
    : result(), frames()
    { }

    void operator=(const G_FightInfo &info) noexcept {
        attacker = info.attacker;
        defender = info.defender;
        result = info.result;
        frames = info.frames;
    }

    void to_unmanaged(G_FightInfo &target) noexcept {
        attacker.to_unmanaged(target.attacker);
        defender.to_unmanaged(target.defender);
        target.result = result;
        target.frames = frames;
    }

    G_ManagedFightCorps attacker;
    G_ManagedFightCorps defender;
    unsigned result;
    unsigned frames;
};

class G_FightReport : public Object {
public:
    void add(const G_FightInfo &info) noexcept;
    void to_opt(obstack_vector<G_FightInfo> &opts) noexcept;
private:
    std::list<ptr<G_ManagedFightInfo>> _list;
};

class G_FightCalcMgr : public Object, public singleton<G_FightCalcMgr> {
public:
    bool init();
    bool call(G_FightInfo &info, G_FightInfo &result) noexcept;
};

#endif

