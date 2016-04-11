#include "dbsvr.h"
#include "libgame/g_defines.h"
#include "libgame/player_init.h"

struct DB_AccountQueryServlet : DB_Servlet<DB_AccountQuery> {
public:
    int execute(request_type *req, response_type *rsp) override {
        auto rs = select(_queryAccount, req->user.c_str());
        if (rs->fetch()) {
            unsigned id;
            id << rs;
            rsp->passwd << rs;
            auto player_rs = select(_queryPlayer, id, req->server);
            if (player_rs->fetch()) {
                rsp->uid << player_rs;
                return 0;
            }
        }
        return GX_ENOTEXISTS;
    }

    GX_STMT(_queryAccount, 
            "select id, passwd from account where user = ?", 
            const char*);

    GX_STMT(_queryPlayer, 
            "select uid from player where account = ? and server = ?", 
            unsigned, unsigned);
};

GX_SERVLET_REGISTER(DB_AccountQueryServlet, false);


struct DB_AccountRegisterServlet : DB_Servlet<DB_AccountRegister> {
public:
    int execute(request_type *req, response_type *rsp) override {
        unsigned id = 0;

        auto account_rs = select(_queryAccount, req->user.c_str());
        if (account_rs->fetch()) {
            std::string passwd;
            id << account_rs;
            passwd << account_rs;
            if (passwd != req->passwd) {
                return GX_ENOTEXISTS;
            }
        }
        else {
            if (exec(_sqlInsertAccount, req->user.c_str(), req->passwd.c_str()) == -GX_EDUP) {
                return GX_EEXISTS;
            }
            auto id_rs = select(_queryId);
            id_rs->fetch();
            id << id_rs;
        }

        if (exec(_insertPlayers, id, req->server, req->id(), req->nickname.c_str(), req->lb, req->side, req->arena) == -GX_EDUP) {
            return GX_EEXISTS;
        }

        unsigned value = G_PlayerInitMgr::instance()->money;
        if (value) {
            exec(_insertValue, req->id(), G_VALUE_MONEY, value);
        }
        value = G_PlayerInitMgr::instance()->coin;
        if (value) {
            exec(_insertValue, req->id(), G_VALUE_COIN, value);
        }
        exec(_insertValue, req->id(), G_VALUE_LEVEL, 1);

        for (auto value : G_PlayerInitMgr::instance()->soldiers) {
            exec(_insertSoldier, req->id(), value, G_SOLDIER_LEVEL, 1);
        }

        unsigned n = 1;
        for (auto value : G_PlayerInitMgr::instance()->items) {
            exec(_insertBag, req->id(), n++, value, 1, 0, 1);
        }
        return 0;
    }

    GX_STMT(
        _queryAccount, 
        "select id, passwd from account where user = ?", 
        const char*);

    GX_STMT(
        _sqlInsertAccount, 
        "insert into account (user, passwd) values (?, ?)", 
        const char*, const char*);

    GX_STMT(
        _queryId, 
        "select last_insert_id()");

    GX_STMT(
        _insertPlayers,
        "insert into player (account, server, uid, name, lb, side, arena) values (?, ?, ?, ?, ?, ?, ?)",
        unsigned, unsigned, unsigned, const char*, unsigned, unsigned, unsigned);

    GX_STMT(
        _insertValue,
        "insert into value (uid, id, value) values (?, ?, ?)",
        unsigned, unsigned, uint64_t);

    GX_STMT(
        _insertSoldier,
        "insert into soldier (uid, sid, id, value) values (?, ?, ?, ?)",
        unsigned, unsigned, unsigned, unsigned);
    GX_STMT(
        _insertBag,
        "insert into bag (uid, id, base, count, used, value) values (?, ?, ?, ?, ?, ?)",
        unsigned, unsigned, unsigned, unsigned, unsigned, unsigned);
};

GX_SERVLET_REGISTER(DB_AccountRegisterServlet, false);

