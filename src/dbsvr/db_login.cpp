#include "dbsvr.h"
#include "libgame/g_defines.h"

class DB_LoadServlet : public DB_Servlet<DB_Load> {
public:
    virtual int execute(request_type *req, response_type *rsp) {
        do {
            auto rs = select(_queryPlayer, req->id());
            if (!rs->fetch()) {
                return GX_ENOTEXISTS;
            }
            rsp->name << rs;
            rsp->side << rs;
            rsp->arena_day << rs;
            rsp->login_time << rs;
            rsp->logout_time << rs;
        } while (0);
        do {
            auto rs = select(_queryBag, req->id());
            while (rs->fetch()) {
                rsp->bag.emplace_back();
                auto &item = rsp->bag.back();
                item.id << rs;
                item.base << rs;
                item.count << rs;
                item.used << rs;
                item.value << rs;
            }
        } while (0);
        do {
            auto rs = select(_queryForge, req->id());
            while (rs->fetch()) {
                rsp->forge.emplace_back();
                auto &item = rsp->forge.back();
                item.index << rs;
                item.id << rs;
                item.used << rs;
            }
        } while (0);

        do {
            auto rs = select(_queryCooldown, req->id());
            while (rs->fetch()) {
                rsp->cd.emplace_back();
                auto &item = rsp->cd.back();
                item.id << rs;
                item.expire << rs;
            }
        } while (0);
        do {
            auto rs = select(_queryValue, req->id());
            while (rs->fetch()) {
                rsp->values.emplace_back();
                auto &value = rsp->values.back();
                value.id << rs;
                value.value << rs;
            }
        } while (0);
        do {
            auto rs = select(_querySoldierValue, req->id());
            std::map<unsigned, G_SoldierValueOpt*> map;
            G_SoldierValueOpt *opt = nullptr;
            while (rs->fetch()) {
                unsigned sid;
                sid << rs;
                if (!opt || opt->sid != sid) {
                    auto r = map.emplace(sid, nullptr);
                    if (r.second) {
                        rsp->soldier_values.emplace_back();
                        opt = std::addressof(rsp->soldier_values.back());
                        opt->sid = sid;
                        r.first->second = opt;
                    }
                    else {
                        opt = r.first->second;
                    }
                }
                opt->values.emplace_back();
                auto &value = opt->values.back();
                value.id << rs;
                value.value << rs;
            }
        } while (0);
        do {
            auto rs = select(_queryTrain, req->id());
            while (rs->fetch()) {
                rsp->trains.emplace_back();
                auto &opt = rsp->trains.back();
                opt.sid << rs;
                opt.expire << rs;
                opt.type << rs;
            }
        } while (0);
        do {
            rsp->formations.resize(G_FORMATION_NUM);
            for (unsigned i = 0; i < G_FORMATION_NUM; ++i) {
                rsp->formations[i].id = i;
            }
            auto rs = select(_queryFormation, req->id());
            unsigned id;
            while (rs->fetch()) {
                id << rs;
                if (id >= G_FORMATION_NUM) {
                    continue;
                }
                auto &form = rsp->formations[id];
                form.items.emplace_back();
                auto &item = form.items.back();
                item.sid << rs;
                item.sid2 << rs;
                item.x << rs;
                item.y << rs;
            }
        } while (0);
        do {
            auto rs = select(_queryTech, req->id());
            while (rs->fetch()) {
                rsp->techs.emplace_back();
                auto &opt = rsp->techs.back();
                opt.type << rs;
                opt.cur << rs;
                opt.research << rs;
                opt.price_num << rs;
                opt.cooldown << rs;
            }
        } while (0);
        do {
            auto rs = select(_queryTask, req->id());
            while (rs->fetch()) {
                rsp->tasks.emplace_back();
                auto &opt = rsp->tasks.back();
                opt.id << rs;
                opt.state << rs;
            }
        } while (0);
        return 0;
    }

    GX_STMT(_queryPlayer, "select name, side, arena_day, login_time, logout_time from player where uid = ?", unsigned);
    GX_STMT(_queryBag, "select id, base, count, used, value from bag where uid = ?", unsigned);
    GX_STMT(_queryForge, "select idx, item, used from forge where uid = ?", unsigned);
    GX_STMT(_queryCooldown, "select id, expire from cooldown where uid = ?", unsigned);
    GX_STMT(_queryValue, "select id, value from value where uid = ?", unsigned);
    GX_STMT(_querySoldierValue, "select sid, id, value from soldier where uid = ?", unsigned);
    GX_STMT(_queryTrain, "select sid, expire, type from train where uid = ?", unsigned);
    GX_STMT(_queryFormation, "select id, sid, sid2, x, y from formation where uid = ?", unsigned);
    GX_STMT(_queryTech, "select id, cur, research, price_num, cooldown from tech where uid = ?", unsigned);
    GX_STMT(_queryTask, "select id, state from task where uid = ?", unsigned);
};

GX_SERVLET_REGISTER(DB_LoadServlet, false);

struct DB_LoginServlet : DB_Servlet<DB_Login> {
    virtual int execute(request_type *req, response_type *rsp) {
        exec(_updatePlayer, req->time, req->id());
        return 0;
    }

    GX_STMT(_updatePlayer, "update player set login_time = ? where uid = ?", uint64_t, unsigned);
};

GX_SERVLET_REGISTER(DB_LoginServlet, false);

