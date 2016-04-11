#ifndef __LIBGAME_PLAYER_H__
#define __LIBGAME_PLAYER_H__

#include <unordered_set>
#include "game.h"
#include "bag.h"
#include "guid.h"
#include "money.h"
#include "forge.h"
#include "cooldown.h"
#include "level.h"
#include "value.h"
#include "vip.h"
#include "libgame/g_defines.h"
#include "libgame/g_fight.h"
#include "libgame/g_player.h"
#include "libgame/g_chat.h"
#include "corps.h"
#include "timer.h"
#include "train.h"
#include "context.h"
#include "formation.h"
#include "tech.h"
#include "recharge.h"
#include "chat.h"
#include "fight.h"

struct DB_LoadRsp;
class G_PlayerMgr;
class G_Player;
class G_MapPlayerInfo;
class AS_SystemNotifyReq;
class AS_ChatReq;

enum {
    G_PLAYER_STATE_INIT,
    G_PLAYER_STATE_LOGIN_WAIT,
    G_PLAYER_STATE_ONLINE,
    G_PLAYER_STATE_KEEP_SESSION,
    G_PLAYER_STATE_OFFLINE,
    G_PLAYER_STATE_UNKNOWN,
};

enum {
    G_PLAYER_UPDATE_MONEY,
    G_PLAYER_UPDATE_LEVEL,
    G_PLAYER_UPDATE_EXP,
};

class G_PlayerStub;

class G_PlayerTmpValues : public G_Values<G_TMP_VALUE_UNKNOWN> {
public:
    G_PlayerTmpValues() noexcept : G_Values<G_TMP_VALUE_UNKNOWN>() 
    { }

protected:
    void mark_update(unsigned index, unsigned value) noexcept override;
};

class G_Player : public Object, public G_GuidObject {
    friend class G_PlayerMgr;
    friend class G_RecruitMgr;
    friend class CL_LoginServlet;
    friend class G_Corps;
    friend class G_PlayerStub;
public:
    G_Player();
    ~G_Player();

    unsigned id() const noexcept;
    int state() const noexcept;

    const std::string &name() const noexcept {
        return _name;
    }

    unsigned side() const noexcept {
        return _side;
    }

    uint64_t session_key() const noexcept {
        return _session_key;
    }

    G_Bag *bag() noexcept {
        return _bag;
    }

    G_Cooldown *cooldown() noexcept {
        return _cooldown;
    }

    G_Forge *forge() noexcept {
        return _forge;
    }

    unsigned level() const noexcept {
        return _values.get(G_VALUE_LEVEL);
    }
    const G_VipInfo *vip() const noexcept {
        return _vip;
    }
    unsigned hero_limit() const noexcept {
        return _vip->hero_limit();
    }

    unsigned exp() const noexcept {
        return _values.get(G_VALUE_EXP);
    }
    void add_exp(unsigned value) noexcept;
    G_TimerMgr *timer_mgr() noexcept {
        return _timer_mgr;
    }
    const G_Values<G_VALUE_UNKNOWN> &values() const noexcept {
        return _values;
    }
    const G_Values<G_TMP_VALUE_UNKNOWN> &values2() const noexcept {
        return _tmp_values;
    }
    G_Corps *corps() noexcept {
        return _corps;
    }
    G_Train *hero_train() noexcept {
        return _hero_train;
    }
    G_Train *soldier_train() noexcept {
        return _soldier_train;
    }
    G_Formations *formations() noexcept {
        return _formations;
    }
    G_Tech *tech() noexcept {
        return _tech;
    }
    G_Task *task() noexcept {
        return _task;
    }
    G_ChatCooldown *chat_cd() noexcept {
        return _chat_cd;
    }
    G_FightReport *fight_report() noexcept {
        return _fight_report;
    }

    unsigned stage() const noexcept {
        return _values.get(G_VALUE_STAGE);
    }
    void stage(unsigned value) noexcept;

    unsigned cur_stage() const noexcept {
        return _cur_stage;
    }
    void cur_stage(unsigned value) noexcept {
        _cur_stage = value;
    }

    bool has_moders(unsigned value) const noexcept {
        return value <= _values.get(G_VALUE_MORDERS);
    }
    void add_morders(unsigned value) noexcept {
        _values.add(G_VALUE_MORDERS, value);
    }
    void sub_morders(unsigned value) noexcept {
        _values.sub(G_VALUE_MORDERS, value);
    }
    unsigned add_shadow() noexcept {
        return _values.add(G_VALUE_SHADOW, 1);
    }
    unsigned sub_challenge() noexcept {
        return _values.sub(G_VALUE_CHALLENGE, 1);
    }
    unsigned appearance() const noexcept {
        return _values.get(G_VALUE_APPEARANCE);
    }
    void appearance(unsigned id) noexcept;

    unsigned use_tiger_times() const noexcept {
        return _values.get(G_VALUE_TIGER_USE_TIMES);
    }
    void use_tiger_times(unsigned value) noexcept {
        _values.set(G_VALUE_TIGER_USE_TIMES, value);
    }
    void mexp(unsigned mexp) noexcept {
        _values.set(G_VALUE_MEXP, mexp);
    }
    unsigned mexp() const noexcept {
        return _values.get(G_VALUE_MEXP);
    }

    void mark_task_dirty() noexcept {
        _task_dirty = true;
    }

    void mark_name_dirty() noexcept {
        _name_dirty = true;
    }
    void mark_level_dirty() noexcept {
        _level_dirty = true;
    }
    void mark_vip_dirty() noexcept {
        _vip_dirty = true;
    }
    void mark_speed_dirty() noexcept {
        _speed_dirty = true;
    }
    void mark_side_dirty() noexcept {
        _side_dirty = true;
    }
    void mark_appearance_dirty() noexcept {
        _appearance_dirty = true;
    }

    void mark_soldier_ranking_dirty() noexcept {
        _soldier_ranking_dirty = true;
    }
    void get_mapinfo(G_MapPlayerInfo *info) noexcept;
    void recharge(const G_RechargeInfo *info) noexcept;

    void make_chat_info(G_ChatPlayerInfo &info) noexcept;

    bool use_formation(int type, unsigned index) noexcept;
    void use_money(const G_Money &money);
    void add_money(const G_Money &money);
    void set_money(const G_Money &money);
    bool has_money(const G_Money &money);
    G_Money get_money() const;

    void update_score(int d) noexcept;
    void update_score_value() noexcept {
        if (_score_dirty) {
            _tmp_values.set(G_VALUE_SCORE, _score);
        }
    }

    void gm_update_level(const G_LevelInfo *info) noexcept;
    void gm_update_vip(const G_VipInfo *info) noexcept;
    void gm_update_stage(unsigned id) noexcept;
    void gm_update_morders(unsigned value) noexcept;

    unsigned rand() const noexcept {
        return (unsigned)random() % G_RAND_MAX + 1;
    }
    unsigned rand(unsigned n) const noexcept {
        assert(n);
        return (unsigned)random() % n;
    }
    unsigned rand(unsigned min, unsigned max) const noexcept {
        if (min == max) {
            return min;
        }
        if (min > max) {
            return max + rand(min - max);
        }
        else {
            return min + rand(max - min);
        }
    }
    Peer *peer() const noexcept {
        return _peer;
    }
    void init(DB_LoadRsp *msg);
    bool login(G_AgentContext *ctx);
    void logout();

    bool fight_call(G_FightInfo &info, bool self) noexcept;
    void fight_response(unsigned seq, G_FightInfo &info) noexcept;
    bool post_fight(unsigned seq, G_FightInfo &info) noexcept;
    timeval_t fight_timer_handler(Timer&, timeval_t);

    template <typename _Notify>
    typename std::enable_if<
        std::is_base_of<ISerial, _Notify>::value,
        void>::type
    send(_Notify &notify) {
        if (_peer) {
            if (the_dump_message) {
                notify.dump(nullptr, 0, the_context()->pool());
                the_context()->pool()->grow1('\0');
                log_debug("\n%s", (char*)the_context()->pool()->finish());
            }
            _peer->send(_Notify::the_message_id, &notify);
        }
    }
    template <typename _Message>
    typename std::enable_if<
        !std::is_base_of<ISerial, _Message>::value,
        void>::type
    send(_Message &msg) {
        send(*msg.req);
    }

private:
    void timer_handler(timeval_t now, date_t &date);
    int second_timer(timeval_t last, timeval_t cur);
    int minute_timer(timeval_t last, timeval_t cur);
    int hour_timer(timeval_t last, timeval_t cur);
    int day_timer(timeval_t last, timeval_t cur);
    int week_timer(timeval_t last, timeval_t cur);

    bool load();
    void kick() noexcept;
    void do_kick() noexcept;
    void build_info(G_PlayerInfo &info) noexcept;
    void build_score() noexcept;
private:
    typedef gx_list(G_AgentContextBase, _load_entry) load_list_t;
    // construct phase
    G_PlayerStub       *_stub;
    timeval_t           _touch_time;
    uint64_t            _session_key;
    timeval_t           _last_time;
    timeval_t           _recv_time;
    G_AgentContextBase *_cl_ctx;
    // init phase
    std::string         _name;
    unsigned            _side;
    const G_LevelInfo  *_level;
    const G_VipInfo    *_vip;
    ptr<G_Bag>          _bag;
    ptr<G_Forge>        _forge;
    ptr<G_Cooldown>     _cooldown;
    G_Values<G_VALUE_UNKNOWN> _values;
    G_PlayerTmpValues   _tmp_values;
    ptr<G_Corps>        _corps;
    ptr<G_TimerMgr>     _timer_mgr;
    weak_ptr<Peer>      _peer;
    ptr<G_Train>        _hero_train;
    ptr<G_Train>        _soldier_train;
    ptr<G_Formations>   _formations;
    ptr<G_Tech>         _tech;
    ptr<G_Task>         _task;
    ptr<G_ChatCooldown> _chat_cd;
    ptr<G_FightReport>  _fight_report;

    bool                _task_dirty;
    bool                _soldier_ranking_dirty;
    bool                _score_dirty;

    bool                _name_dirty;
    bool                _level_dirty;
    bool                _vip_dirty;
    bool                _speed_dirty;
    bool                _side_dirty;
    bool                _appearance_dirty;

    unsigned            _challenge_id;
    timeval_t           _login_time;
    timeval_t           _logout_time;
    unsigned            _score;

    unsigned            _fight_seq;
    ptr<G_FightInfo>    _fight_info;
    Context            *_fight_call_ctx;
    weak_ptr<Timer>     _fight_timer;

    unsigned            _cur_stage;

    date_t              _date;
    list_entry          _side_entry;
    load_list_t         _load_list;
};

class G_PlayerStub : public PeerObject {
    friend class G_PlayerMgr;
    friend class G_Player;
    friend class G_AgentContextBase;
public:
    G_PlayerStub() noexcept;

    bool attach(G_AgentContextBase *ctx) noexcept;
    G_Player *check_client(G_AgentContextBase *ctx) noexcept;
    bool busy() const noexcept {
        return !_ctx_list.empty();
    }
    G_Player *player() const noexcept {
        return _player;
    }
protected:
    void on_peer_close();
    void detach(G_AgentContextBase *ctx, bool failed) noexcept;
private:
    typedef gx_list(G_AgentContextBase, _entry) ctx_list_t;

    unsigned        _id;
    int             _state;
    size_t          _hash;
    ptr<G_Player>   _player;
    clist_entry     _entry;
    ctx_list_t      _ctx_list;
};

class G_PlayerMgr : public Object, public singleton<G_PlayerMgr> {
    friend class G_Player;
    friend class G_PlayerStub;
public:
    G_PlayerMgr() noexcept;
    ~G_PlayerMgr();

    G_Player *prepare_login(unsigned id);
    G_Player *get_player(unsigned id) const noexcept;
    G_Player *load_player(unsigned id);
    bool init();

    bool register_player(unsigned id);
    void broadcast_system_notify(AS_SystemNotifyReq *notify) noexcept;
    void broadcast_chat(AS_ChatReq *msg) noexcept;
    void shutdown() noexcept;
    G_PlayerStub *get_stub(unsigned id) const noexcept;
private:
    G_PlayerStub *probe_stub(unsigned id) noexcept;
    void update_stub_state(G_PlayerStub *stub, int state) noexcept;
    void touch_stub(G_PlayerStub *stub) noexcept;
    G_Player *construct_player(G_PlayerStub *stub) noexcept;
    void destroy_player(G_PlayerStub *stub) noexcept;
    G_Player *load_player(G_PlayerStub *stub);

    uint64_t make_session_key() noexcept;
    void check_cache(timeval_t time) noexcept;
    timeval_t timer_handler(Timer&, timeval_t);
    static void timer_routine(void *param) noexcept;
    void timer_rountine_handler();
    void broadcast_world(Stream &stream) noexcept;
private:
    typedef gx_list(G_PlayerStub, _entry) stub_list_t;
    typedef gx_list(G_Player, _side_entry) side_list_t;
    struct equal {
        bool operator()(const G_PlayerStub *lhs, const G_PlayerStub *rhs) const noexcept {
            return lhs->_id == rhs->_id;
        }
    };
    struct hash {
        size_t operator()(const G_PlayerStub *stub) const noexcept {
            return stub->_hash;
        }
    };
private:
    std::unordered_set<G_PlayerStub*, hash, equal> _stubs;
    stub_list_t _stub_lists[G_PLAYER_STATE_UNKNOWN];
    weak_ptr<Timer> _timer;
    Coroutine *_timer_co;
    bool _timer_co_running;
    timeval_t _last_time;
    object<Obstack> _pool;
    unsigned _cache_count;
    Stream _stream;
    Protocol _protocol;
    side_list_t _sides[G_SIDE_OTHER];
    timeval_t _logout_time;
    timeval_t _update_agent_time;
};

inline unsigned G_Player::id() const noexcept {
    return _stub->_id;
}

inline int G_Player::state() const noexcept {
    return _stub->_state;
}

inline G_Player *the_player() noexcept {
    G_PlayerStub *stub = G_AgentContext::instance()->stub();
    if (!stub) {
        return nullptr;
    }
    return stub->player();
}

#endif

