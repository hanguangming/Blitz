#include "player.h"
#include "global.h"
#include "dbsvr/db_login.h"
#include "context.h"
#include "level.h"
#include "agentsvr/cl_notify.h"
#include "dbsvr/db_timer.h"
#include "dbsvr/db_logout.h"
#include "dbsvr/db_agent.h"
#include "libgame/g_map.h"
#include "mapsvr/ms_update_info.h"
#include "worldsvr/ws_score_update.h"
#include "param.h"
#include "worldsvr/ws_soldier_update.h"
#include "worldsvr/ws_update_info.h"
#include "agentsvr/as_system_notify.h"
#include "agentsvr/as_chat.h"
#include "mapsvr/ms_login.h"
#include "mapsvr/ms_logout.h"

#define CLIENT_MESSAGE_INTERVAL 200
/* G_PlayerStub */
G_PlayerStub::G_PlayerStub() noexcept 
: _id(), 
  _state(),
  _hash()
{ }

G_Player *G_PlayerStub::check_client(G_AgentContextBase *ctx) noexcept {
    if (!_player) {
        return nullptr;
    }
    if (_player->_cl_ctx) {
        return nullptr;
    }
    timeval_t t = gettimeofday();
    if ((t - _player->_recv_time) < CLIENT_MESSAGE_INTERVAL) {
        return nullptr;
    }
    _player->_recv_time = t;
    _player->_cl_ctx = ctx;
    return _player;
}

bool G_PlayerStub::attach(G_AgentContextBase *ctx) noexcept {
    assert(ctx);

    if (Coroutine::is_main_routine()) {
        ctx->_attached = false;
        ctx->_stub = this;
        return true;
    }

    if (ctx->_attached) {
        return true;
    }
    _ctx_list.push_back(ctx);
    ctx->_attached = true;
    ctx->_stub = this;
    return true;
}

void G_PlayerStub::detach(G_AgentContextBase *ctx, bool fail) noexcept {
    assert(ctx);
    assert(ctx->_attached);
    assert(ctx->_stub == this);

    if (_player && ctx == _player->_cl_ctx) {
        _player->_cl_ctx = nullptr;
    }
    ctx->_stub = nullptr;
    ctx->_attached = false;

    ctx_list_t::remove(ctx);

    if (fail) {
        if (_state != G_PLAYER_STATE_INIT) {
            if (_player && _player->_peer) {
                _player->_peer->close();
            }
            G_PlayerMgr::instance()->update_stub_state(this, G_PLAYER_STATE_INIT);
            while ((ctx = _ctx_list.front())) {
                ctx->call_cancel();
            }
        }
    }
    else if (_player) {
        while ((ctx = _player->_load_list.front())) {
            ctx->call_ok();
        }
    }
}

void G_PlayerStub::on_peer_close() {
    if (_player) {
        _player->logout();
    }
}

/* G_PlayerMgr */
G_PlayerMgr::G_PlayerMgr() noexcept {
    _cache_count = 0;
    _timer_co_running = 0;
    _timer_co = Coroutine::spawn(timer_routine, this);
}

G_PlayerMgr::~G_PlayerMgr() {
    if (_timer) {
        _timer->close();
    }
}

bool G_PlayerMgr::init() {
    for (auto &db_info : the_db_infos) {
        object<MySQL> mysql(
            db_info.host.c_str(), 
            db_info.port, 
            db_info.user.c_str(), 
            db_info.passwd.c_str(), 
            db_info.database.c_str());

        if (!mysql->connect()) {
            log_error("connect to database false, %s.", mysql->errorMsg());
            return false;
        }

        Statement<unsigned> queryPlayer(
            "select uid, lb from player where server = ?");


        if (!queryPlayer.prepare(mysql)) {
            log_error("prepare query player failed.");
            return false;
        }

        do {
            unsigned count = the_app->network()->instance_count(SERVLET_CLIENT);
            auto rs = queryPlayer.query(the_server_id);
            
            if (!rs) {
                log_error("query player failed.");
                return false;
            }
            while (rs->fetch()) {
                unsigned uid;
                unsigned lb;
                uid << rs;
                lb << rs;
                if (lb % count == the_app->id()) {
                    probe_stub(uid);
                }
            }
        } while (0);

        do {
            object<MySQL> mysql(
                the_global_db_info.host.c_str(), 
                the_global_db_info.port, 
                the_global_db_info.user.c_str(), 
                the_global_db_info.passwd.c_str(), 
                the_global_db_info.database.c_str());

            if (!mysql->connect()) {
                log_error("connect to database false, %s.", mysql->errorMsg());
                return false;
            }
            Statement<unsigned, unsigned> queryAgent(
                "select time from agent where server = ? and id = ?");

            if (!queryAgent.prepare(mysql)) {
                log_error("prepare query agent failed.");
                return false;
            }

            auto rs = queryAgent.query(the_server_id, the_app->id());
            if (rs->fetch()) {
                _logout_time << rs;
            }
            else {
                _logout_time = logic_time();
            }
        } while (0);
        break;
    }

    _timer = the_app->timer_manager()->schedule(
        100,
        std::bind(&G_PlayerMgr::timer_handler, this, _1, _2));
    _last_time = gettimeofday();
    _update_agent_time = gettimeofday();
    return true;
}

void G_PlayerMgr::shutdown() noexcept {
    the_app->network()->shutdown_servlets();
    if (_timer) {
        _timer->close();
    }

    G_PlayerStub *stub;
    stub_list_t *list;

    list = _stub_lists + G_PLAYER_STATE_LOGIN_WAIT;
    while ((stub = list->back())) {
        update_stub_state(stub, G_PLAYER_STATE_OFFLINE);
    }


    list = _stub_lists + G_PLAYER_STATE_ONLINE;
    while ((stub = list->back())) {
        if (stub->_player && stub->_player->_peer) {
            stub->_player->_peer->close();
        }
        else {
            update_stub_state(stub, G_PLAYER_STATE_OFFLINE);
        }
    }

    list = _stub_lists + G_PLAYER_STATE_KEEP_SESSION;
    DB_Logout msg;
    while ((stub = list->back())) {
        if (stub->_player) {
            G_AgentContext *ctx = G_AgentContext::instance();
            if (ctx->begin(the_app->network(), nullptr)) {
                try {
                    msg.req->id(stub->_player->id());
                    msg.req->logout_time = stub->_player->_logout_time;
                    the_app->network()->call(msg);
                } catch (ServletException &e) {
                    ctx->rollback(true);
                    break;
                } catch (CallCancelException &e) {
                    ctx->rollback(false);
                    break;
                }
            }
            ctx->finish();
        }
        update_stub_state(stub, G_PLAYER_STATE_OFFLINE);
    }
}

inline uint64_t G_PlayerMgr::make_session_key() noexcept {
    timeval_t t = gettimeofday();
    long r = random();
    return hash_iterative(&t, sizeof(t), hash_iterative(&r, sizeof(r)));
}

G_PlayerStub *G_PlayerMgr::get_stub(unsigned id) const noexcept {
    static G_PlayerStub tmp;
    tmp._id = id;
    tmp._hash = hash_iterative(&id, sizeof(id));
    auto it = _stubs.find(&tmp);
    if (it == _stubs.end()) {
        return nullptr;
    }
    return *it;
}

inline G_PlayerStub *G_PlayerMgr::probe_stub(unsigned id) noexcept {
    static G_PlayerStub tmp;
    tmp._id = id;
    tmp._hash = hash_iterative(&id, sizeof(id));

    auto r = _stubs.emplace(&tmp);
    if (r.second) {
        G_PlayerStub *stub = _pool->construct<G_PlayerStub>();
        stub->_id = id;
        stub->_hash = tmp._hash;
        const_cast<G_PlayerStub*&>(*r.first) = stub;
        _stub_lists[G_PLAYER_STATE_INIT].push_front(stub);
    }
    return *r.first;
}

inline G_Player *G_PlayerMgr::construct_player(G_PlayerStub *stub) noexcept {
    assert(stub->_state == G_PLAYER_STATE_INIT && !stub->_player);
    object<G_Player> player;
    player->_stub = stub;
    stub->_player = player;
    ++_cache_count;
    return player;
}

inline void G_PlayerMgr::destroy_player(G_PlayerStub *stub) noexcept {
    --_cache_count;
    stub->_player = nullptr;
}

inline void G_PlayerMgr::touch_stub(G_PlayerStub *stub) noexcept {
    stub_list_t::remove(stub);
    _stub_lists[stub->_state].push_front(stub);
    if (stub->_player) {
        stub->_player->_touch_time = gettimeofday();
    }
}

inline void G_PlayerMgr::update_stub_state(G_PlayerStub *stub, int state) noexcept {
    assert(state >= 0 && state < G_PLAYER_STATE_UNKNOWN);
    if (state == stub->_state) {
        return;
    }
    stub_list_t::remove(stub);
    stub->_state = state;
    _stub_lists[state].push_front(stub);
    switch (state) {
    case G_PLAYER_STATE_INIT:
        destroy_player(stub);
        break;
    }

    if (stub->_player) {
        stub->_player->_touch_time = gettimeofday();
    }
}

G_Player *G_PlayerMgr::get_player(unsigned id) const noexcept {
    G_PlayerStub *stub = get_stub(id);
    if (!stub) {
        return nullptr;
    }
    return stub->_player;
}

inline G_Player *G_PlayerMgr::load_player(G_PlayerStub *stub) {
    if (stub->_player && !stub->_player->_load_list.empty()) {
        G_AgentContextBase *ctx = static_cast<G_AgentContextBase*>(the_context());
        stub->_player->_load_list.push_back(ctx);
        ctx->call_yield();
        G_Player::load_list_t::remove(ctx);
        return stub->_player;
    }

    switch (stub->_state) {
    case G_PLAYER_STATE_INIT:
        assert(!stub->_player);

        construct_player(stub);
        if (stub->_player->load()) {
            update_stub_state(stub, G_PLAYER_STATE_OFFLINE);
        }
        else {
            destroy_player(stub);
        }
        break;
    case G_PLAYER_STATE_LOGIN_WAIT:
        if (stub->_player->load()) {
            update_stub_state(stub, G_PLAYER_STATE_KEEP_SESSION);
        }
        else {
            update_stub_state(stub, G_PLAYER_STATE_INIT);
        }
        break;
    case G_PLAYER_STATE_ONLINE:
    case G_PLAYER_STATE_KEEP_SESSION:
    case G_PLAYER_STATE_OFFLINE:
        touch_stub(stub);
        break;
    default:
        return nullptr;
    }
    return stub->_player;
}

G_Player *G_PlayerMgr::load_player(unsigned id) {
    G_PlayerStub *stub = get_stub(id);
    if (!stub) {
        return nullptr;
    }
    return load_player(stub);
}

inline void G_PlayerMgr::check_cache(timeval_t time) noexcept {
    G_PlayerStub *stub;
    stub_list_t *list;

    list = _stub_lists + G_PLAYER_STATE_LOGIN_WAIT;
    while ((stub = list->back())) {
        if (time < the_login_wait_time + stub->_player->_touch_time) {
            break;
        }
        update_stub_state(stub, G_PLAYER_STATE_INIT);
    }

    list = _stub_lists + G_PLAYER_STATE_KEEP_SESSION;
    while ((stub = list->back())) {
        if (time < the_session_keep_time + stub->_player->_touch_time) {
            break;
        }
        update_stub_state(stub, G_PLAYER_STATE_OFFLINE);
        G_AgentContext *ctx = G_AgentContext::instance();
        if (ctx->begin(the_app->network(), nullptr) && stub->attach(ctx)) {
            try {
                DB_Logout msg;
                msg.req->id(stub->_player->id());
                msg.req->logout_time = stub->_player->_logout_time;
                the_app->network()->call(msg);
            } catch (ServletException &e) {
                ctx->rollback(true);
            } catch (CallCancelException &e) {
                ctx->rollback(false);
            }
        }
        ctx->finish();
    }

    list = _stub_lists + G_PLAYER_STATE_OFFLINE;
    while (_cache_count > the_cache_player_num) {
        stub = list->back();
        if (!stub) {
            break;
        }
        update_stub_state(stub, G_PLAYER_STATE_INIT);
    }
}

void G_PlayerMgr::timer_rountine_handler() {
    G_PlayerStub *stub;
    G_Player *player;

    if (_last_time < _update_agent_time) {
        _update_agent_time = _last_time;
    }

    if (_last_time - _update_agent_time > (1000 * 60)) {
        G_AgentContext *ctx = G_AgentContext::instance();
        if (ctx->begin(the_app->network(), nullptr)) {
            try {
                DB_Agent msg;
                msg.req->id(the_app->id() + 1);
                msg.req->time = logic_time();
                msg.req->server = the_server_id;
                the_app->network()->call(msg);
            } catch (ServletException &e) {
                ctx->rollback(true);
            } catch (CallCancelException &e) {
                ctx->rollback(false);
            }
        }
        ctx->finish();
        _update_agent_time = _last_time;
    }

    check_cache(_last_time);

    timeval_t logic_now = logic_time();
    date_t date_now = logic_now;

    stub_list_t *list = _stub_lists + G_PLAYER_STATE_ONLINE;
    while ((stub = list->back())) {
        player = stub->_player;
        assert(player && stub->_state == G_PLAYER_STATE_ONLINE);

        if (player->_last_time >= _last_time) {
            break;
        }
        player->_last_time = _last_time;
        stub_list_t::remove(stub);
        list->push_front(stub);

        G_AgentContext *ctx = G_AgentContext::instance();
        if (!stub->busy() && ctx->begin(stub, the_app->network(), player->_peer)) {
            try {
                player->timer_handler(logic_now, date_now);
            } catch (ServletException &e) {
                ctx->rollback(true);
            } catch (CallCancelException &e) {
                ctx->rollback(false);
            }
            ctx->finish();
        }
    }
    _timer_co_running = false;
    _timer_co->yield();
}

void G_PlayerMgr::timer_routine(void *param) noexcept {
    while (1) {
        G_PlayerMgr::instance()->timer_rountine_handler();
    }
}

timeval_t G_PlayerMgr::timer_handler(Timer&, timeval_t time) {
    if (_last_time < time) {
        _last_time = time;
        if (!_timer_co_running) {
            _timer_co_running = true;
            _timer_co->resume();
        }
    }
    return 100;
}

bool G_PlayerMgr::register_player(unsigned id) {
    probe_stub(id);
    return true;
}

G_Player *G_PlayerMgr::prepare_login(unsigned id) {
    G_PlayerStub *stub = get_stub(id);
    if (!stub) {
        return nullptr;
    }

    switch (stub->_state) {
    case G_PLAYER_STATE_INIT:
        assert(!stub->_player);
        construct_player(stub);
        update_stub_state(stub, G_PLAYER_STATE_LOGIN_WAIT);
        break;
    case G_PLAYER_STATE_LOGIN_WAIT:
        assert(stub->_player);
        touch_stub(stub);
        break;
    case G_PLAYER_STATE_ONLINE:
        stub->_player->kick();
        break;
    case G_PLAYER_STATE_KEEP_SESSION:
        touch_stub(stub);
        break;
    case G_PLAYER_STATE_OFFLINE:
        update_stub_state(stub, G_PLAYER_STATE_KEEP_SESSION);
        break;
    default:
        return nullptr;
    }
    stub->_player->_session_key = make_session_key();
    return stub->_player;
}

void G_PlayerMgr::broadcast_world(Stream &stream) noexcept {
    auto &list = _stub_lists[G_PLAYER_STATE_ONLINE];

    for (auto &stub : list) {
        if (stub._player && stub._player->_peer) {
            stub._player->_peer->send(stream);
        }
    }
}

void G_PlayerMgr::broadcast_system_notify(AS_SystemNotifyReq *notify) noexcept {
    CL_NotifySystemReq msg;
    msg.msg_id = notify->msg_id;
    msg.player = notify->player;
    msg.params = notify->params;

    ProtocolInfo info;
    info.servlet = CL_NotifySystem::the_message_id;
    info.seq = 0;
    info.message = &msg;
    _protocol.serial(info, _stream, false);

    broadcast_world(_stream);

    _stream.clear();
}

void G_PlayerMgr::broadcast_chat(AS_ChatReq *msg) noexcept {
    CL_NotifyChatReq notify;
    notify.player = msg->player;
    notify.channel = msg->channel;
    notify.magic = msg->magic;
    notify.msg = std::move(msg->msg);

    ProtocolInfo info;
    info.servlet = CL_NotifySystem::the_message_id;
    info.seq = 0;
    info.message = &notify;
    _protocol.serial(info, _stream, false);

    switch (msg->channel) {
    case G_CHAT_CHANNEL_WORLD:
        broadcast_world(_stream);
        break;
    case G_CHAT_CHANNEL_SIDE:
        if (msg->magic < G_SIDE_OTHER) {
            auto &list = _sides[msg->magic];

            for (auto &player : list) {
                if (player._peer) {
                    player._peer->send(_stream);
                }
            }
        }
        break;
    }

    _stream.clear();
}


/* G_PlayerTmpValues */
void G_PlayerTmpValues::mark_update(unsigned index, unsigned value) noexcept {
    auto &opts = the_data()->_tmp_value_opts;
    opts.emplace_back();
    G_ValueOpt &opt = opts.back();
    opt.id = index + G_TMP_VALUE_BEGIN;
    opt.value = value;
}

/* G_Player */
G_Player::G_Player() 
: _stub(),
  _touch_time(),
  _session_key(),
  _last_time(),
  _recv_time()
{ }

G_Player::~G_Player() {
}

/* login and logout */
bool G_Player::login(G_AgentContext *ctx) {
    if (state() != G_PLAYER_STATE_KEEP_SESSION && state() != G_PLAYER_STATE_LOGIN_WAIT) {
        return false;
    }

    ctx->peer()->peer_object = _stub;
    _peer = ctx->peer();

    _fight_seq = 0;
    _cur_stage = 0;

    if (!G_PlayerMgr::instance()->load_player(_stub)) {
        return false;
    }

    if (state() != G_PLAYER_STATE_KEEP_SESSION) {
        return false;
    }

    if (!_stub->attach(ctx)) {
        return false;
    }

    if (!_login_time) {
        _login_time = logic_time();
    }
    if (!_logout_time) {
        _logout_time = logic_time();
    }
    if (_logout_time < _login_time) {
        _logout_time = G_PlayerMgr::instance()->_logout_time;
    }

    _login_time = logic_time();
    _date = _logout_time;
    timer_handler(logic_time(), _date);

    G_PlayerMgr::instance()->update_stub_state(_stub, G_PLAYER_STATE_ONLINE);
    if (_side < G_SIDE_OTHER) {
        G_PlayerMgr::instance()->_sides[_side].push_front(this);
    }

    do {
        DB_Login msg;
        msg.req->id(id());
        msg.req->time = logic_time();
        the_app->network()->call(msg);
    } while (0);

    do {
        MS_Login msg;
        msg.req->id(id());
        msg.req->key = session_key();
        msg.req->info.name = name();
        msg.req->info.vip = vip()->level();
        msg.req->info.level = level();
        msg.req->info.side = side();
        msg.req->info.speed = tech()->speed();
        msg.req->info.appearance = appearance();
        the_app->network()->call(msg);
    } while (0);

    return true;
}

void G_Player::logout() {
    if (state() != G_PLAYER_STATE_ONLINE) {
        return;
    }
    G_PlayerMgr::instance()->update_stub_state(_stub, G_PLAYER_STATE_KEEP_SESSION);
    _logout_time = logic_time();
    _session_key = 0;
    if (_fight_timer) {
        _fight_timer->close();
    }
    if (_side < G_SIDE_OTHER) {
        G_PlayerMgr::side_list_t::remove(this);
    }
    MS_Logout msg;
    msg.req->id(id());
    the_app->network()->broadcast(msg);
}

void G_Player::kick() noexcept {
    if (state() == G_PLAYER_STATE_ONLINE) {
        if (_peer) {
            CL_NotifyKick msg;
            _peer->send(CL_NotifyKick::the_message_id, 0, msg.req);
            _peer->close(the_linger_time);
        }
        logout();
    }
}

/* logic */
bool G_Player::load() {
    assert(_load_list.empty());

    G_AgentContextBase *ctx = static_cast<G_AgentContextBase*>(the_context());
    _load_list.push_front(ctx);
    DB_Load msg;
    msg.req->id(id());
    ctx->network()->call(msg);
    init(msg.rsp);
    _load_list.pop_front();
    return true;
}

void G_Player::init(DB_LoadRsp *msg) {
    /* init default */
    _task_dirty = false;
    _name_dirty = false;
    _level_dirty = false;
    _vip_dirty = false;
    _speed_dirty = false;
    _side_dirty = false;
    _appearance_dirty = false;
    _soldier_ranking_dirty = false;
    _side = 0;
    _logout_time = 0;
    _login_time = 0;
    _fight_seq = 0;
    _bag = object<G_Bag>();
    _forge = object<G_Forge>();
    _cooldown = object<G_Cooldown>();
    _corps = object<G_Corps>();
    _timer_mgr = object<G_TimerMgr>();
    _hero_train = object<G_Train>();
    _soldier_train = object<G_Train>();
    _tech = object<G_Tech>();
    _formations = object<G_Formations>();
    _task = object<G_Task>();
    _chat_cd = object<G_ChatCooldown>();
    _fight_report = object<G_FightReport>();
    _fight_call_ctx = nullptr;

    /* init data */
    _side = msg->side;
    _name = msg->name;
    _login_time = msg->login_time;
    _logout_time = msg->logout_time;

    if (_side >= G_SIDE_OTHER) {
        _side = 0;
    }
    _bag->init(this, msg);
    _forge->init(this, msg);
    _cooldown->init(this, msg);
    for (auto &value : msg->values) {
        _values.init(value.id, value.value);
    }
    _level = G_LevelMgr::instance()->get_info(_values.get(G_VALUE_LEVEL));
    _vip = G_VipMgr::instance()->get_info(_values.get(G_VALUE_VIP));

    _corps->init(this, msg);

    for (auto &opt : msg->trains) {
        G_Soldier *soldier = _corps->get(opt.sid);
        if (!soldier) {
            continue;
        }
        const G_TrainInfo *info = G_TrainMgr::instance()->get_info(opt.type);
        if (!info) {
            continue;
        }
        if (soldier->info()->is_hero()) {
            _hero_train->init(this, soldier, info, opt.expire);
        }
        else {
            _soldier_train->init(this, soldier, info, opt.expire);
        }
    }

    _tech->init(this, msg);
    _formations->init(this, msg->formations, true);
    _task->init(this, msg);
    build_score();
}

void G_Player::build_score() noexcept {
    _score = 0;
    _score_dirty = false;
    for (auto it = _corps->soldiers().begin(); it != _corps->soldiers().end(); ++it) {
        G_Soldier *soldier = *it;
        _score += soldier->score();
    }

    for (auto it = _bag->items().begin(); it != _bag->items().end(); ++it) {
        G_BagItem *item = *it;
        if (item->used()) {
            _score += item->score();
        }
    }
    _tmp_values.set(G_VALUE_SCORE, _score);
}

void G_Player::update_score(int d) noexcept {
    if (d) {
        _score += d;
        _score_dirty = true;
    }
}

inline void G_Player::timer_handler(timeval_t now, date_t &date) {
    int result = 0;
    if (_date.second != date.second) {
        if (_date.second < date.second) {
            result |= second_timer(_date.second, date.second);
            if (_date.minute != date.minute) {
                if (_date.minute < date.minute) {
                    result |= minute_timer(_date.minute, date.minute);
                    if (_date.hour != date.hour) {
                        if (_date.hour < date.hour) {
                            result |= hour_timer(_date.hour, date.hour);
                            if (_date.day != date.day) {
                                if (_date.day < date.day) {
                                    result |= day_timer(_date.day, date.day);
                                    if (_date.week != date.week) {
                                        if (_date.week < date.week) {
                                            result |= week_timer(_date.week, date.week);
                                        }
                                        _date.week = date.week;
                                    }
                                }
                                _date.day = date.day;
                            }
                        }
                        _date.hour = date.hour;
                    }
                }
                _date.minute = date.minute;
            }
        }
        _date.second = date.second;
    }

    if (result) {
        DB_AgentTimer msg;
        msg.req->id(id());
        msg.req->value_opts = the_value_opts();
        the_context()->network()->call(msg);
        the_context()->commit();
    }

    _timer_mgr->loop(now);

    if (_task_dirty) {
        _task_dirty = false;
        _task->check(this);
    }

    _logout_time = now;
}

void G_Player::build_info(G_PlayerInfo &info) noexcept {
    info.name = _name;
    info.level = _level->level();
    info.vip = _vip->level();
    info.side = _side;
    info.speed = _tech->speed();
    info.appearance = appearance();
}

inline int G_Player::second_timer(timeval_t last, timeval_t cur) {
    if (_score_dirty) {
        _score_dirty = false;
        WS_ScoreUpdate msg;
        msg.req->uid = id();
        msg.req->score = _score;
        the_app->network()->broadcast(msg);
    }
    if (_soldier_ranking_dirty) {
        _soldier_ranking_dirty = false;
        WS_SoldierUpdate msg;
        msg.req->uid = id();
        for (unsigned i = G_QUALITY_RANKING_BEGIN; i < G_QUALITY_UNKNOWN; ++i) {
            msg.req->soldiers.push_back(_corps->quality_list(i).count());
        }
        the_app->network()->broadcast(msg);
    }
    if (_name_dirty) {
        _name_dirty = false;
    }

    if (_level_dirty) {
        _level_dirty = false;
        do {
            WS_UpdateLevel msg;
            msg.req->uid = id();
            msg.req->level = level();
            the_app->network()->broadcast(msg);
        } while (0);
        do {
            MS_UpdateLevel msg;
            msg.req->uid = id();
            msg.req->level = level();
            the_app->network()->broadcast(msg);
        } while (0);
    }
    if (_vip_dirty) {
        _vip_dirty = false;
        do {
            WS_UpdateVip msg;
            msg.req->uid = id();
            msg.req->vip = _vip->level();
            the_app->network()->broadcast(msg);
        } while (0);
        do {
            MS_UpdateVip msg;
            msg.req->uid = id();
            msg.req->vip = _vip->level();
            the_app->network()->broadcast(msg);
        } while (0);
    }
    if (_speed_dirty) {
        _speed_dirty = false;
        do {
            MS_UpdateSpeed msg;
            msg.req->uid = id();
            msg.req->speed = _tech->speed();
            the_app->network()->broadcast(msg);
        } while (0);
    }
    if (_side_dirty) {
        _side_dirty = false;
        do {
            WS_UpdateSide msg;
            msg.req->uid = id();
            msg.req->side = _side;
            the_app->network()->broadcast(msg);
        } while (0);
        do {
            MS_UpdateSide msg;
            msg.req->uid = id();
            msg.req->side = _side;
            the_app->network()->broadcast(msg);
        } while (0);
    }
    if (_appearance_dirty) {
        _appearance_dirty = false;
        do {
            WS_UpdateAppearance msg;
            msg.req->uid = id();
            msg.req->appearance = appearance();
            the_app->network()->broadcast(msg);
        } while (0);
        do {
            MS_UpdateAppearance msg;
            msg.req->uid = id();
            msg.req->appearance = appearance();
            the_app->network()->broadcast(msg);
        } while (0);
    }

    return 0;
}

inline int G_Player::minute_timer(timeval_t last, timeval_t cur) {
    return 0;
}

inline int G_Player::hour_timer(timeval_t last, timeval_t cur) {
    unsigned n = cur - last;
    unsigned old = _values.get(G_VALUE_MORDERS);
    unsigned limit = _vip->morders_limit();
    if (old < limit) {
        n += old;
        if (n > limit) {
            n = limit;
        }
        _values.set(G_VALUE_MORDERS, n);
        return 1;
    }
    return 0;
}

inline int G_Player::day_timer(timeval_t last, timeval_t cur) {
    int r = 0;
    unsigned n;
    if (_values.get(G_VALUE_TIGER_USE_TIMES)) {
        _values.set(G_VALUE_TIGER_USE_TIMES, 0);
        r = 1;
    }
    n = G_ParamMgr::instance()->free_supplement_num();
    if (_values.get(G_VALUE_SUPPLEMENT) != n) {
        _values.set(G_VALUE_SUPPLEMENT, n);
        r = 1;
    }
    if (_values.get(G_VALUE_SHADOW)) {
        _values.set(G_VALUE_SHADOW, 0);
        r = 1;
    }
    if (_values.get(G_VALUE_MEXP)) {
        _values.set(G_VALUE_MEXP, 0);
        r = 1;
    }
    n = G_ParamMgr::instance()->challenge_times();
    if (_values.get(G_VALUE_CHALLENGE) != n) {
        _values.set(G_VALUE_CHALLENGE, n);
        r = 1;
    }
    return r;
}

inline int G_Player::week_timer(timeval_t last, timeval_t cur) {
    return 0;
}

void G_Player::use_money(const G_Money &money) {
    _values.sub(G_VALUE_MONEY, money.money);
    _values.sub(G_VALUE_COIN, money.coin);
    _values.sub(G_VALUE_HONOR, money.honor);
    _values.sub(G_VALUE_RECRUIT, money.recruit);
}

void G_Player::set_money(const G_Money &money) {
    _values.set(G_VALUE_MONEY, money.money);
    _values.set(G_VALUE_COIN, money.coin);
    _values.set(G_VALUE_HONOR, money.honor);
    _values.set(G_VALUE_RECRUIT, money.recruit);
}

void G_Player::add_money(const G_Money &money) {
    _values.add(G_VALUE_MONEY, money.money);
    _values.add(G_VALUE_COIN, money.coin);
    _values.add(G_VALUE_HONOR, money.honor);
    _values.add(G_VALUE_RECRUIT, money.recruit);
}

bool G_Player::has_money(const G_Money &money) {
    return _values.get(G_VALUE_MONEY) >= money.money &&
        _values.get(G_VALUE_COIN) >= money.coin &&
        _values.get(G_VALUE_HONOR) >= money.honor &&
        _values.get(G_VALUE_RECRUIT) >= money.recruit;
}

G_Money G_Player::get_money() const {
    G_Money money;
    money.money = _values.get(G_VALUE_MONEY);
    money.coin = _values.get(G_VALUE_COIN);
    money.honor = _values.get(G_VALUE_HONOR);
    money.recruit = _values.get(G_VALUE_RECRUIT);
    return money;
}

void G_Player::add_exp(unsigned value) noexcept {
    unsigned exp = _values.get(G_VALUE_EXP) + value;
    const G_LevelInfo *level = _level;
    while (1) {
        if (exp < level->exp()) {
            break;
        }
        if (!level->next_level()) {
            exp = level->exp();
            break;
        }
        exp -= level->exp();
        level = level->next_level();
        mark_task_dirty();
        mark_level_dirty();
    }

    _values.set(G_VALUE_EXP, exp);
    _values.set(G_VALUE_LEVEL, level->level());
    _level = level;
}

void G_Player::gm_update_level(const G_LevelInfo *info) noexcept {
    _values.set(G_VALUE_LEVEL, info->level());
    _level = info;
    mark_task_dirty();
    mark_level_dirty();
}

void G_Player::gm_update_morders(unsigned value) noexcept {
    _values.set(G_VALUE_MORDERS, value);
}

void G_Player::stage(unsigned value) noexcept {
    if (value > _values.get(G_VALUE_STAGE)) {
        _values.set(G_VALUE_STAGE, value);
        mark_task_dirty();
    }
}

void G_Player::recharge(const G_RechargeInfo *info) noexcept {
    if (!info) {
        return;
    }

    unsigned exp = info->exp();

    exp += _values.get(G_VALUE_RECHARGE);

    
    while (1) {
        const G_VipInfo *vip = _vip->next();
        if (!vip) {
            break;
        }

        if (exp < vip->exp()) {
            break;
        }
        _vip = vip;
        mark_vip_dirty();
    }
    _values.set(G_VALUE_RECHARGE, exp);
    _values.set(G_VALUE_VIP, _vip->level());
    _values.add(G_VALUE_MONEY, info->game_money());
}

void G_Player::gm_update_vip(const G_VipInfo *info) noexcept {
    _vip = info;
    _values.set(G_VALUE_VIP, _vip->level());
    mark_task_dirty();
    mark_level_dirty();
}

void G_Player::gm_update_stage(unsigned id) noexcept {
    _values.set(G_VALUE_STAGE, id);
    mark_task_dirty();
}

bool G_Player::use_formation(int type, unsigned index) noexcept {
    unsigned n;

    if (index >= G_FORMATION_NUM) {
        return false;
    }
    switch (type) {
    case G_FORMATION_PVE:
        n = G_VALUE_FORMATION_PVE;
        break;
    case G_FORMATION_PVP:
        n = G_VALUE_FORMATION_PVP;
        break;
    case G_FORMATION_ARENA:
        n = G_VALUE_FORMATION_ARENA;
        break;
    default:
        return false;
    }
    _values.set(n, index);
    return true;
}

void G_Player::get_mapinfo(G_MapPlayerInfo *info) noexcept {
    info->name = _name.c_str();
    info->vip = _vip->level();
    info->level = level();
    info->side = _side;
    info->speed = _tech->speed();
}

bool G_Player::fight_call(G_FightInfo &info, bool self) noexcept {
    if (state() != G_PLAYER_STATE_ONLINE) {
        return false;
    }
    if (!_peer) {
        return false;
    }

    if (self) {
        if (_fight_call_ctx) {
            return false;
        }

        CL_NotifyFightReq notify;
        notify.seq = 0;
        notify.info = info;
        _peer->send(CL_NotifyFightReq::the_message_id, &notify);

        Context *ctx = the_context();
        if (the_dump_message) {
            notify.dump(nullptr, 0, ctx->pool());
            ctx->pool()->grow1('\0');
            log_debug("\n%s", (char*)ctx->pool()->finish());
        }

        weak_ptr<Timer> timer;
        timer = the_app->timer_manager()->schedule(the_fight_response_time, [=](Timer&, timeval_t) {
            ctx->call_timedout();
            return 0;
        });

        _fight_call_ctx = ctx;
        if (!Coroutine::yield()) {
            _fight_call_ctx = nullptr;
            timer->close();
            return false;
        }

        _fight_call_ctx = nullptr;
        if (timer) {
            timer->close();
        }

        if (ctx->call_result() != GX_CALL_OK) {
            return false;
        }
        if (!_fight_info) {
            return false;
        }
        info = *_fight_info;
        _fight_info = nullptr;
    }

    return true;
}

void G_Player::fight_response(unsigned seq, G_FightInfo &info) noexcept {
    if (!seq) {
        if (_fight_call_ctx) {
            _fight_info = object<G_FightInfo>(info);
            _fight_call_ctx->call_ok();
        }
    }
    else if (seq == _fight_seq) {
        /*
        FD_FightResult msg;
        msg.req->player = id();
        msg.req->seq = _fight_seq;
        msg.req->info = info;
        the_context()->network()->broadcast(msg);
        if (_fight_timer) {
            _fight_timer->close();
        }
        _fight_seq = 0;*/
    }
}

timeval_t G_Player::fight_timer_handler(Timer&, timeval_t) {
    /*
    _fight_seq = 0;

    FD_FightFail msg;
    msg.req->player = id();
    the_context()->network()->broadcast(msg);*/
    return 0;
}

bool G_Player::post_fight(unsigned seq, G_FightInfo &info) noexcept {
    if (state() != G_PLAYER_STATE_ONLINE) {
        return false;
    }
    if (!_peer) {
        return false;
    }
    if (_fight_call_ctx) {
        return false;
    }
    if (_fight_seq) {
        return false;
    }

    CL_NotifyFightReq notify;
    notify.seq = seq;
    notify.info = info;
    _peer->send(CL_NotifyFightReq::the_message_id, &notify);

    _fight_timer = the_app->timer_manager()->schedule(
        the_fight_response_time, 
        std::bind(&G_Player::fight_timer_handler, this, _1, _2));

    return true;
}

void G_Player::appearance(unsigned id) noexcept {
    if (id == appearance()) {
        return;
    }
    mark_appearance_dirty();
    _values.set(G_VALUE_APPEARANCE, id);
}

void G_Player::make_chat_info(G_ChatPlayerInfo &info) noexcept {
    info.uid = id();
    info.name = _name;
    info.vip = _vip->level();
    info.appearance = appearance();
}

