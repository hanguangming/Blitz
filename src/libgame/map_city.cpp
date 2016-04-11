#include "map_city.h"
#include "map.h"
#include "fightsvr/fs_fight.h"
#include "agentsvr/cl_notify.h"
#include "agentsvr/as_mexp.h"
#include "libgame/g_defines.h"

G_MapCity::G_MapCity() noexcept
: _id(),
  _index(),
  _hash(),
  _coin(),
  _origin(),
  _side(),
  _state(),
  _unit_msg(),
  _state_msg(),
  _city_msg(),
  _fight_msg(),
  _co_running(),
  _defender_count(),
  _mexp_list()
{
    _co = Coroutine::spawn(fight_routine, this);
}

void G_MapCity::fight_routine(void *param) noexcept {
    G_MapCity *city = static_cast<G_MapCity*>(param);
    Context *ctx = the_context();
    while (1) {
        while (1) {
            G_MapUnit *attacker = city->_attack_list.front();
            G_MapUnit *defender = city->_defend_list.front();
            if (!attacker || !defender) {
                break;
            }
            if (ctx->begin(the_app->network(), nullptr)) {
                try {
                    if (city->fight_routine(ctx, attacker, defender)) {
                        goto next;
                    }
                } catch (ServletException &e) {
                    ctx->rollback(true);
                } catch (CallCancelException &e) {
                    ctx->rollback(false);
                }
            }
            ctx->sleep(500);
next:
            ctx->finish();
        }
        city->_co_running = false;
        Coroutine::yield();
    }
}

bool G_MapCity::fight_routine(Context *ctx, G_MapUnit *attacker, G_MapUnit *defender) noexcept {
    FS_Fight msg;
    msg.req->id(attacker->unit_id() + defender->unit_id());
    attacker->get_corps(&msg.req->info.attacker);
    defender->get_corps(&msg.req->info.defender);
    msg.req->info.seed = rand();
    the_app->network()->call(msg);
    if (msg.rsp->rc) {
        return false;
    }

    G_MapUnit *winner, *loser;
    unsigned winner_kill_people, loser_kill_people;

    if (msg.rsp->info.result == G_FIGHT_ATTACKER_WIN) {
        winner = attacker;
        loser = defender;
        winner_kill_people = the_fight_people(msg.req->info.defender);
        loser_kill_people = the_fight_people(msg.req->info.attacker) - the_fight_people(msg.rsp->info.attacker);
        attacker->set_corps(&msg.rsp->info.attacker);
        defender->set_corps(nullptr);
    }
    else {
        winner = defender;
        loser = attacker;
        winner_kill_people = the_fight_people(msg.req->info.attacker);
        loser_kill_people = the_fight_people(msg.req->info.defender) - the_fight_people(msg.rsp->info.defender);
        defender->set_corps(&msg.rsp->info.defender);
        attacker->set_corps(nullptr);
    }

    push_fight_msg(msg.req->info);
    broadcast();
    _cur_fight = &msg.req->info;
    _cur_time = gettimeofday();
    ctx->sleep(msg.rsp->info.time);
    _cur_fight = nullptr;

    winner->fight_finish();
    loser->fight_finish();

    if (winner->unit_type() == G_MAP_UNIT_PLAYER) {
        G_MapPlayer *player = static_cast<G_MapPlayer*>(winner);
        if (player->_peer) {
            CL_NotifyPeopleReq msg(_pool);
            msg.people = player->people();
            msg.people_all = player->people_all();
            player->_peer->send(CL_NotifyPeopleReq::the_message_id, &msg);
        }
        add_player_mexp(player, G_MEXP_PER_PEOPLE * winner_kill_people);
    }
    if (loser->unit_type() == G_MAP_UNIT_PLAYER) {
        G_MapPlayer *player = static_cast<G_MapPlayer*>(loser);
        if (player->_peer) {
            CL_NotifyPeopleReq msg(_pool);
            msg.people = player->people();
            msg.people_all = player->people_all();
            player->_peer->send(CL_NotifyPeopleReq::the_message_id, &msg);
        }
        add_player_mexp(player, G_MEXP_PER_PEOPLE * loser_kill_people);
        leave(player, G_MOVE_NORMAL, nullptr);
        player->_side->_revive->enter(player);
    }
    else {
        unit_leave(loser);
    }

    fight_finish();
    return true;
}

void G_MapCity::enter(G_MapPlayer *player) noexcept {
    unit_enter(player);

    player->_city = this;
    if (player->_peer) {
        CL_NotifyMapCityEnterReq msg(_pool);
        msg.city = _id;
        player->_peer->send(CL_NotifyMapCityEnterReq::the_message_id, &msg);
    }
}

bool G_MapCity::leave(G_MapPlayer *player, unsigned type, G_MapCity *target) noexcept {
    if (this == _side->_revive) {
        if (!player->corps()) {
            return false;
        }
    }
    switch (type) {
    case G_MOVE_NORMAL:
        if (target && fighting()) {
            return false;
        }
        break;
    case G_MOVE_DART:
        if (!fighting()) {
            return false;
        }
        if (!target) {
            return false;
        }
        if (player->_state != G_MAP_UNIT_STATE_WAIT) {
            return false;
        }

        if (player->_side == _side) {
            if (_attack_list.count() < _defend_list.count()) {
                return false;
            }
        }
        else {
            if (_attack_list.count() > _defend_list.count()) {
                return false;
            }
        }
        if (!target->fighting() && target->_side == player->_side) {
            return false;
        }
        break;
    case G_MOVE_RETREAT:
        if (!fighting()) {
            return false;
        }
        if (!target) {
            return false;
        }
        if (player->_state != G_MAP_UNIT_STATE_WAIT) {
            return false;
        }
        if (target->fighting() || target->_side != player->_side) {
            return false;
        }
        break;
    default:
        return false;
    }

    if (!unit_leave(player)) {
        return false;
    }

    if (player->_peer) {
        CL_NotifyMapCityLeaveReq msg(_pool);
        msg.city = _id;
        player->_peer->send(CL_NotifyMapCityLeaveReq::the_message_id, &msg);
    }
    player->subscribe(nullptr);

    return true;
}

bool G_MapCity::enter_check(G_MapUnit *unit) noexcept {
    return fightable();
}

void G_MapCity::unit_enter(G_MapUnit *unit) noexcept {
    unit->_state = G_MAP_UNIT_STATE_WAIT;
    bool start = false;
    if (unit->side() != _side) {
        _attack_list.push_back(unit);
        if (!fighting()) {
            refresh_defenders();
            update_state(G_CITY_FIGHT);
            update_fight_list(false, true);
            start = true;
        }
        update_fight_list(true, false);
    }
    else {
        _defend_list.push_back(unit);
        if (fighting()) {
            update_fight_list(false, false);
        }
    }

    push_unit_presend_msg(unit);
    broadcast();

    if (start) {
        fight_start();
    }
}

bool G_MapCity::unit_leave(G_MapUnit *unit) noexcept {
    if (unit->side() != _side) {
        _attack_list.remove(unit);
    }
    else {
        _defend_list.remove(unit);
    }
    update_unit_state(unit, G_MAP_UNIT_STATE_REMOVED);

    switch (unit->unit_type()) {
    case G_MAP_UNIT_PLAYER: {
        break;
    }
    case G_MAP_UNIT_DEFENDER:
        --_defender_count;
        assert(_defender_count >= 0);
        _npcs.erase(unit->unit_id());
        break;
    case G_MAP_UNIT_SHADOW:
        _npcs.erase(unit->unit_id());
        break;
    default:
        assert(0);
        break;
    }
    broadcast();
    return true;
}

void G_MapCity::fight_start() noexcept {
    if (fighting() && !_co_running) {
        _co_running = true;
        _co->resume();
    }
}

void G_MapCity::fight_finish() noexcept {
    if (_attack_list.empty()) {
        update_state(G_CITY_PEACE);
        for (auto &unit : _defend_list) {
            if (unit.unit_type() == G_MAP_UNIT_PLAYER) {
                add_player_mexp(static_cast<G_MapPlayer*>(&unit), G_MEXP_DEFEND);
            }
        }
    }
    else if (_defend_list.empty()) {
        update_side(_attack_list.front()->_side);
        G_MapUnit *first = nullptr;
        for (auto it = _attack_list.begin(); it != _attack_list.end();) {
            G_MapUnit &unit = *it;
            if (!first) {
                first = &unit;
            }
            if (unit.unit_type() == G_MAP_UNIT_PLAYER) {
                add_player_mexp(static_cast<G_MapPlayer*>(&unit), G_MEXP_ATTACK);
            }

            ++it;
            if (unit._side == _side) {
                _attack_list.remove(&unit);
                _defend_list.push_back(&unit);
            }
        }

        if (first && first->unit_type() == G_MAP_UNIT_PLAYER) {
            G_MapPlayer *player = static_cast<G_MapPlayer*>(first);
            if (_side->id() >= G_SIDE_OTHER || _origin == player->_side) {
                add_player_mexp(player, G_MEXP_FCM1);
            }
            else {
                add_player_mexp(player, G_MEXP_FCM2);
            }
        }

        if (_attack_list.empty()) {
            update_state(G_CITY_PEACE);
        }
        else {
            update_fight_list(true, true);
            update_fight_list(false, true);
        }
    }
    else {
        update_fight_list(true, false);
        update_fight_list(false, false);
    }
    broadcast();
}

void G_MapCity::update_fight_list(bool attacker, bool all) noexcept {
    unsigned i;
    G_MapUnitList &list = attacker ? _attack_list : _defend_list;
    if (all) {
        i = 0;
        for (G_MapUnit &unit : list) {
            if (i++ >= G_FIGHT_QUEUE_SIZE) {
                update_unit_state(&unit, G_MAP_UNIT_STATE_WAIT);
            }
            else {
                update_unit_state(&unit, G_MAP_UNIT_STATE_FIGHT);
            }
        }
    }
    else {
        i = 0;
        for (G_MapUnit &unit : list) {
            if (i++ >= G_FIGHT_QUEUE_SIZE) {
                break;
            }
            update_unit_state(&unit, G_MAP_UNIT_STATE_FIGHT);
        }
    }
}

G_MapUnit *G_MapCity::refresh_unit(unsigned type) noexcept {
    ptr<G_MapNpc> unit;

    switch (type) {
    case G_MAP_UNIT_DEFENDER:
        unit = object<G_NpcDefender>(_side);
        break;
    default:
        return nullptr;
    }
    _npcs[unit->unit_id()] = unit;
    return unit;
}

void G_MapCity::refresh_defenders() noexcept {
    int n;
    if (_side == _origin) {
        n = _origin->_aborigine_defender_num;
    }
    else {
        n = _origin->_occupy_defender_num;
    }
    if (_defender_count < n) {
        n -= _defender_count;
        _defender_count += n;
        for (int i = 0; i < n; ++i) {
            unit_enter(refresh_unit(G_MAP_UNIT_DEFENDER));
        }
    }
    clear_broadcast();
}

void G_MapCity::init() {
    _state = G_CITY_PEACE;
}

bool G_MapCity::subscribe(G_MapPlayer *player, bool sub) noexcept {
    if (sub) {
        if (!fighting()) {
            return false;
        }
        if (player->_subscribe) {
            return false;
        }
        if (!player->_peer) {
            return false;
        }
        _subscribe_list.push_front(player);

        CL_NotifyMapUnitPresendReq req;
        for (G_MapUnit &unit : _defend_list) {
            req.defends.emplace_back();
            auto &item = req.defends.back();
            item.type = unit.unit_type();
            item.name = unit.name();
            item.id = unit.unit_id();
            item.vip = unit.vip();
            item.side = unit.side()->id();
            item.state = unit.state();
        }
        for (G_MapUnit &unit : _attack_list) {
            req.attacks.emplace_back();
            auto &item = req.attacks.back();
            item.type = unit.unit_type();
            item.name = unit.name();
            item.id = unit.unit_id();
            item.vip = unit.vip();
            item.side = unit.side()->id();
            item.state = unit.state();
        }
        dump_message(req, _pool);
        player->_peer->send(CL_NotifyMapUnitPresendReq::the_message_id, &req);

        if (_cur_fight) {
            CL_NotifyMapFightInfoReq msg;
            msg.info = *_cur_fight;
            msg.info.time = gettimeofday() - _cur_time;
            player->_peer->send(CL_NotifyMapFightInfoReq::the_message_id, &msg);
        }
    }
    else {
        G_MapPlayerSubscribeList::remove(player);
    }
    return true;
}

void G_MapCity::clear_subscribe() noexcept {
    G_MapPlayer *player;
    while ((player = _subscribe_list.pop_front())) {
        player->_subscribe = nullptr;
    }
}

void G_MapCity::broadcast(unsigned servlet_id, INotify *msg) noexcept {
    ProtocolInfo info;
    info.servlet = servlet_id;
    info.seq = 0;
    info.message = msg;
    G_Map *map = G_Map::instance();
    map->_protocol.serial(info, map->_stream, false);

    for (G_MapPlayer &player : _subscribe_list) {
        assert(player._peer);
        player._peer->send(map->_stream);
    }

    map->_stream.clear();

    if (!_subscribe_list.empty()) {
        dump_message(*msg, _pool);
    }
}

void G_MapCity::broadcast() noexcept {
    if (_unit_msg) {
        broadcast(*_unit_msg);
        dump_message(*_unit_msg, _pool);
        _unit_msg = nullptr;
    }
    if (_state_msg) {
        broadcast(*_state_msg);
        dump_message(*_state_msg, _pool);
        _state_msg = nullptr;
    }
    if (_fight_msg) {
        broadcast(*_fight_msg);
        dump_message(*_fight_msg, _pool);
        _fight_msg = nullptr;
    }
    if (_city_msg) {
        G_Map::instance()->broadcast(*_city_msg);
        dump_message(*_city_msg, _pool);
        _city_msg = nullptr;
    }

    G_MapPlayer *player = _mexp_list;
    if (player) {
        AS_MExp msg(_pool);
        while (player) {
            msg.req->id(player->id());
            msg.req->mexp = player->_mexp;
            player->_mexp = 0;
            the_app->network()->send(msg);
            player = player->_mexp_next;
        }
        _mexp_list = nullptr;
    }
    _pool->clear();
}

void G_MapCity::clear_broadcast() noexcept {
    _unit_msg = nullptr;
    _state_msg = nullptr;
    _city_msg = nullptr;
    _fight_msg = nullptr;
    _pool->clear();
}

void G_MapCity::update_state(unsigned new_state) noexcept {
    if (_state == new_state) {
        return;
    }
    _state = new_state;
    push_city_state_msg();

    if (_state == G_CITY_PEACE) {
        clear_subscribe();
    }
}

void G_MapCity::update_side(G_MapSide *new_side) noexcept {
    if (_side == new_side) {
        return;
    }
    _side = new_side;
    push_city_state_msg();
}

void G_MapCity::update_unit_state(G_MapUnit *unit, unsigned new_state) noexcept {
    if (unit->_state == new_state) {
        return;
    }
    unit->_state = new_state;
    push_unit_state_msg(unit);
}

void G_MapCity::push_unit_state_msg(G_MapUnit *unit) noexcept {
    if (!fighting()) {
        return;
    }
    if (!_state_msg) {
        _state_msg = _pool->construct<CL_NotifyMapUnitStatePresendReq>(_pool);
    }
    _state_msg->presends.emplace_back();
    auto &item = _state_msg->presends.back();
    item.type = unit->_unit_type;
    item.state = unit->_state;
    item.id = unit->unit_id();
}

void G_MapCity::push_city_state_msg() noexcept {
    if (!_city_msg) {
        _city_msg = _pool->construct<CL_NotifyCityPresendReq>(_pool);
    }
    if (_city_msg->cities.empty()) {
        _city_msg->cities.emplace_back();
    }
    to_presend(_city_msg->cities.back());
}

void G_MapCity::push_unit_presend_msg(G_MapUnit *unit) noexcept {
    if (!fighting()) {
        return;
    }
    if (!_unit_msg) {
        _unit_msg = _pool->construct<CL_NotifyMapUnitPresendReq>(_pool);
    }
    obstack_vector<G_MapUnitPresend> *list;
    if (unit->side() != _side) {
        list = &_unit_msg->attacks;
    }
    else {
        list = &_unit_msg->defends;
    }
    list->emplace_back();
    auto &item = list->back();
    item.type = unit->unit_type();
    item.name = unit->name();
    item.id = unit->unit_id();
    item.vip = unit->vip();
    item.side = unit->side()->id();
    item.state = unit->state();
}

void G_MapCity::push_fight_msg(G_FightInfo &info, unsigned time) noexcept {
    if (!fighting()) {
        return;
    }
    _fight_msg = _pool->construct<CL_NotifyMapFightInfoReq>(_pool);
    _fight_msg->info = info;
    _fight_msg->info.time = time;
}

void G_MapCity::push_fight_msg(G_ManagedFightInfo &info, unsigned time) noexcept {
    if (!fighting()) {
        return;
    }
    _fight_msg = _pool->construct<CL_NotifyMapFightInfoReq>(_pool);
    info.to_unmanaged(_fight_msg->info);
    _fight_msg->info.time = time;
}

void G_MapCity::add_player_mexp(G_MapPlayer *player, unsigned mexp) noexcept {
    if (!mexp) {
        return;
    }
    if (!player->_mexp) {
        player->_mexp_next = _mexp_list;
        _mexp_list = player;
    }
    player->_mexp += mexp;
}

void G_MapCity::shadow(G_MapPlayer *player, G_FightCorps &corps) noexcept {
    object<G_NpcShadow> unit(player, corps);
    _npcs[unit->unit_id()] = unit;
    unit_enter(unit);
}

void G_MapCity::pvp(G_MapPlayer *player) noexcept {
    return;
    if (!fighting()) {
        return;
    }
    if (player->_state != G_MAP_UNIT_STATE_WAIT) {
        return;
    }
    if (player->_city != player->_subscribe) {
        return;
    }

    G_MapUnitList *list;
    if (player->_side != _side) {
        list = &_defend_list;
    }
    else {
        list = &_attack_list;
    }

    G_MapUnit *target = nullptr;
    for (G_MapUnit &unit : *list) {
        if (unit._state == G_MAP_UNIT_STATE_WAIT) {
            target = &unit;
            break;
        }
    }
    if (!target) {
        return;
    }

    unit_leave(player);
    unit_leave(target);



}

