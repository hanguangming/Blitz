#include "gamesvr.h"
#include "agentsvr/as_gm.h"
#include "libgame/g_gm.h"

enum {
    TK_RESTART,
    TK_UPDATE,
    TK_PLAYER,
    TK_SET,
    TK_ADD,
    TK_MONEY,
    TK_COIN,
    TK_HONOR,
    TK_RECRUIT,
    TK_SOLDIER,
    TK_HERO,
    TK_ITEM,
    TK_LEVEL,
    TK_VIP,
    TK_EXP,
    TK_TIME,
    TK_STAGE,
    TK_MORDERS,
    TK_FIGHT,
    TK_WITH,
};

#include "token.h"

static std::string __cmd;
static std::vector<std::string> __tokens;
static unsigned __token_index;
static const char *__result;

static const char *get_str() {
    while (1) {
        if (__token_index >= __tokens.size()) {
            return nullptr;
        }
        const char *str = __tokens[__token_index++].c_str();
        if (!*str) {
            continue;
        }
        return str;
    }
}

static int get_token() {
    const char *str = get_str();
    if (!str) {
        return -1;
    }
    token_t *tk = Perfect_Hash::in_word_set(str, strlen(str));
    if (!tk) {
        return -1;
    }
    return tk->id;
}

static unsigned get_int(unsigned def = 0) {
    const char *str = get_str();
    if (!str) {
        return def;
    }
    return strtoul(str, nullptr, 10);
}

static void unknown_cmd() {
    throw the_pool()->printf("1, unknown command '%s'", __cmd.c_str());
}

template <typename _T>
static void result(_T &msg) {
    if (!msg.rsp->rc && msg.rsp->result.empty()) {
        throw "0, OK";
    }
    throw msg.rsp->result.c_str();
}

static void check_end() {
    if (get_str()) {
        unknown_cmd();
    }
}

static void do_restart() {
    check_end();
    shutdown();
    startup();
}

static void do_update_player_add_item(unsigned player) {
    unsigned item = get_int();
    unsigned count = get_int(1);
    check_end();

    GM_AddItem msg;
    msg.req->id(player);
    msg.req->item = item;
    msg.req->count = count;
    the_app->network()->call(msg);
    result(msg);
}

static void do_update_player_set_money(unsigned player) {
    unsigned value = get_int();
    check_end();

    GM_AddMoney msg;
    msg.req->id(player);
    msg.req->type = 0;
    msg.req->value = value;
    the_app->network()->call(msg);
    result(msg);
}

static void do_update_player_set_coin(unsigned player) {
    unsigned value = get_int();
    check_end();

    GM_AddMoney msg;
    msg.req->id(player);
    msg.req->type = 1;
    msg.req->value = value;
    the_app->network()->call(msg);
    result(msg);
}

static void do_update_player_set_honor(unsigned player) {
    unsigned value = get_int();
    check_end();

    GM_AddMoney msg;
    msg.req->id(player);
    msg.req->type = 2;
    msg.req->value = value;
    the_app->network()->call(msg);
    result(msg);
}

static void do_update_player_set_recruit(unsigned player) {
    unsigned value = get_int();
    check_end();

    GM_AddMoney msg;
    msg.req->id(player);
    msg.req->type = 3;
    msg.req->value = value;
    the_app->network()->call(msg);
    result(msg);
}

static void do_update_player_add_hero(unsigned player) {
    unsigned value = get_int();
    check_end();

    GM_AddHero msg;
    msg.req->id(player);
    msg.req->sid = value;
    the_app->network()->call(msg);
    result(msg);
}

static void do_update_player_add_exp(unsigned player) {
    unsigned value = get_int();
    check_end();

    GM_AddExp msg;
    msg.req->id(player);
    msg.req->exp = value;
    the_app->network()->call(msg);
    result(msg);
}

static void do_update_player_add(unsigned player) {
    switch (get_token()) {
    case TK_ITEM:
        do_update_player_add_item(player);
        break;
    case TK_HERO:
        do_update_player_add_hero(player);
        break;
    case TK_EXP:
        do_update_player_add_exp(player);
        break;
    default:
        unknown_cmd();
        break;
    }
}

static void do_update_player_set_soldier_level(unsigned player, unsigned soldier) {
    unsigned value = get_int();
    check_end();

    GM_UpdateSoldierLevel msg;
    msg.req->id(player);
    msg.req->sid = soldier;
    msg.req->level = value;
    the_app->network()->call(msg);
    result(msg);
}

static void do_update_player_set_soldier(unsigned player) {
    unsigned soldier = get_int();
    switch (get_token()) {
    case TK_LEVEL:
        do_update_player_set_soldier_level(player, soldier);
        break;
    default:
        unknown_cmd();
        break;
    }
}

static void do_update_player_set_level(unsigned player) {
    unsigned value = get_int();

    GM_UpdateLevel msg;
    msg.req->id(player);
    msg.req->level = value;
    the_app->network()->call(msg);
    result(msg);
}

static void do_update_player_set_vip(unsigned player) {
    unsigned value = get_int();

    GM_UpdateVip msg;
    msg.req->id(player);
    msg.req->level = value;
    the_app->network()->call(msg);
    result(msg);
}

static void do_update_player_set_stage(unsigned player) {
    unsigned value = get_int();

    GM_UpdateStage msg;
    msg.req->id(player);
    msg.req->stage = value;
    the_app->network()->call(msg);
    result(msg);
}

static void do_update_player_set_morders(unsigned player) {
    unsigned value = get_int();

    GM_UpdateMorders msg;
    msg.req->id(player);
    msg.req->morders = value;
    the_app->network()->call(msg);
    result(msg);
}

static void do_update_player_set(unsigned player) {
    switch (get_token()) {
    case TK_SOLDIER:
        do_update_player_set_soldier(player);
        break;
    case TK_LEVEL:
        do_update_player_set_level(player);
        break;
    case TK_VIP:
        do_update_player_set_vip(player);
        break;
    case TK_STAGE:
        do_update_player_set_stage(player);
        break;
    case TK_MORDERS:
        do_update_player_set_morders(player);
        break;
    case TK_MONEY:
        do_update_player_set_money(player);
        break;
    case TK_COIN:
        do_update_player_set_coin(player);
        break;
    case TK_HONOR:
        do_update_player_set_honor(player);
        break;
    case TK_RECRUIT:
        do_update_player_set_recruit(player);
        break;
    default:
        unknown_cmd();
        break;
    }
}

static void do_update_player() {
    unsigned player = get_int();
    if (!player) {
        unknown_cmd();
    }
    switch (get_token()) {
    case TK_ADD:
        do_update_player_add(player);
        break;
    case TK_SET:
        do_update_player_set(player);
        break;
    default:
        unknown_cmd();
        break;
    }
}

static void do_update_time() {
    unsigned value = get_int();
    check_end();

    GM_UpdateTime msg;
    msg.req->time = value * 60 * 1000;
    the_app->network()->broadcast_all(GM_UpdateTime::the_message_id, msg.req);
}

static void do_update() {
    switch (get_token()) {
    case TK_PLAYER:
        do_update_player();
        break;
    case TK_TIME:
        do_update_time();
        break;
    default:
        unknown_cmd();
        break;
    }
}

static void do_player_fight_with(unsigned id) {
    unsigned value = get_int();

    GM_FightWith msg;
    msg.req->id(id);
    msg.req->target = value;
    the_app->network()->call(msg);
}

static void do_player_fight(unsigned id) {
    switch (get_token()) {
    case TK_WITH:
        do_player_fight_with(id);
        break;
    default:
        unknown_cmd();
        break;
    }
}

static void do_player() {
    unsigned player = get_int();
    if (!player) {
        unknown_cmd();
    }
    switch (get_token()) {
    case TK_FIGHT:
        do_player_fight(player);
        break;
    default:
        unknown_cmd();
        break;
    }
}

static void do_command(const std::string &cmd) {
    __cmd = cmd;
    __tokens = split(cmd, ' ');
    __token_index = 0;
    __result = "0, OK";

    switch (get_token()) {
    case TK_RESTART:
        do_restart();
        break;
    case TK_UPDATE:
        do_update();
        break;
    case TK_PLAYER:
        do_player();
        break;
    default:
        unknown_cmd();
        break;
    }
}

struct GS_CommandServlet : Servlet<GS_Command> {
    virtual int execute(request_type *req, response_type*rsp) {
        try {
            do_command(req->cmd);
            rsp->result = __result;
        } catch (const char *e) {
            rsp->result = e;
        }
        return 0;
    }
};

GX_SERVLET_REGISTER(GS_CommandServlet, true);

