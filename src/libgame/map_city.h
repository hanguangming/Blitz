#ifndef __LIBGAME_MAP_CITY_H__
#define __LIBGAME_MAP_CITY_H__

#include <list>

#include "game.h"
#include "map_player.h"
#include "map_side.h"
#include "map_unit.h"
#include "npc.h"
#include "agentsvr/cl_notify.h"
#include "libgame/g_defines.h"

/* G_MapFightItem */
class G_MapFightItem : public Object {
    friend class G_MapCity;

    G_MapUnit *_winner;
    G_MapUnit *_loser;
    unsigned _winner_kill_people;
    unsigned _loser_kill_people;
    G_ManagedFightInfo _info;
    timeval_t _time;
    timeval_t _use_time;
    weak_ptr<Timer> _timer;
};

/* G_MapCity */
class G_MapCity : public Object {
    friend class G_Map;
public:
    G_MapCity() noexcept;

    bool enter_check(G_MapUnit *unit) noexcept;
    void enter(G_MapPlayer *player) noexcept;
    bool leave(G_MapPlayer *player, unsigned type, G_MapCity *target = nullptr) noexcept;

    void to_presend(G_MapCityPresend &persend) noexcept {
        persend.id = _id;
        persend.side = _side->id();
        persend.state = _state;
    }

    bool fightable() const noexcept {
        return this != _side->_revive;
    }
    bool fighting() const noexcept {
        return _state == G_CITY_FIGHT;
    }
    bool subscribe(G_MapPlayer *player, bool sub) noexcept;
    void broadcast(unsigned servlet_id, INotify *msg) noexcept;
    template <typename _T>
    void broadcast(_T &msg) noexcept {
        broadcast(_T::the_message_id, &msg);
    }
    void broadcast() noexcept;
    void clear_broadcast() noexcept;
    unsigned id() const noexcept {
        return _id;
    }
    void init();
    void shadow(G_MapPlayer *player, G_FightCorps &corps) noexcept;
    void pvp(G_MapPlayer *player) noexcept;
private:
    void update_state(unsigned new_state) noexcept;
    void update_side(G_MapSide *side) noexcept;
    void update_unit_state(G_MapUnit *unit, unsigned new_state) noexcept;
    void unit_enter(G_MapUnit *unit) noexcept;
    bool unit_leave(G_MapUnit *unit) noexcept;
    G_MapUnit *refresh_unit(unsigned type) noexcept;
    void refresh_defenders() noexcept;
    void fight_start() noexcept;
    void fight_finish() noexcept;

    void push_unit_state_msg(G_MapUnit *unit) noexcept;
    void push_unit_presend_msg(G_MapUnit *unit) noexcept;
    void push_city_state_msg() noexcept;
    void push_fight_msg(G_FightInfo &info, unsigned time = 0) noexcept;
    void push_fight_msg(G_ManagedFightInfo &info, unsigned time = 0) noexcept;

    bool fight_routine(Context *ctx, G_MapUnit *attacker, G_MapUnit *defender) noexcept;
    static void fight_routine(void*) noexcept;

    void clear_subscribe() noexcept;

    void update_fight_list(bool attacker ,bool all) noexcept;
    void add_player_mexp(G_MapPlayer *player, unsigned mexp) noexcept;
private:
    unsigned _id;
    unsigned _index;
    unsigned _hash;
    unsigned _coin;
    G_MapSide *_origin;
    G_MapSide *_side;
    unsigned _state;
    weak_ptr<Timer> _timer;
    std::map<unsigned, G_MapCity*> _joins;

    G_MapUnitList _defend_list;
    G_MapUnitList _attack_list;
    G_MapPlayerSubscribeList _subscribe_list;

    CL_NotifyMapUnitPresendReq *_unit_msg;
    CL_NotifyMapUnitStatePresendReq *_state_msg;
    CL_NotifyCityPresendReq *_city_msg;
    CL_NotifyMapFightInfoReq *_fight_msg;
    
    std::map<unsigned, ptr<G_MapNpc>> _npcs;
    Coroutine *_co;
    bool _co_running;
    object<Obstack> _pool;

    int _defender_count;
    G_MapPlayer *_mexp_list;

    G_FightInfo *_cur_fight;
    timeval_t _cur_time;
};



#endif

