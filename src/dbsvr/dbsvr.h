#ifndef __DBSVR_H__
#define __DBSVR_H__

#include "libgx/gx.h"
GX_NS_USING;

#include "dbsvr_msg.h"
#include "libgame/g_defines.h"

struct DB_ServletSQL {
    GX_STMT(_updateItem, 
            "replace into bag (uid, id, base, count, used, value) values (?, ?, ?, ?, ?, ?)",
            unsigned, unsigned, unsigned, unsigned, unsigned, unsigned);

    GX_STMT(_deleteItem,
            "delete from bag where uid = ? and id = ?",
            unsigned, unsigned);

    GX_STMT(_updateValue,
            "replace into value (uid, id, value) values (?, ?, ?)",
            unsigned, unsigned, uint64_t);

    GX_STMT(_updateCooldown,
            "replace into cooldown (uid, id, expire) values (?, ?, ?)",
            unsigned, unsigned, int64_t);

    GX_STMT(_updateSoldierValue,
            "replace into soldier (uid, sid, id, value) values (?, ?, ?, ?)",
            unsigned, unsigned, unsigned, uint64_t);
    GX_STMT(_deleteSoldierValue,
            "delete from soldier where uid = ? and sid = ? and id = ?",
            unsigned, unsigned, unsigned);
    GX_STMT(_deleteSoldier,
            "delete from soldier where uid = ? and sid = ?",
            unsigned, unsigned);
    GX_STMT(_updateTrain,
            "replace into train (uid, sid, expire, type) values (?, ?, ?, ?)",
            unsigned, unsigned, uint64_t, unsigned);
    GX_STMT(_deleteTrain,
            "delete from train where uid = ? and sid = ?",
            unsigned, unsigned);
    GX_STMT(_deleteFormation,
            "delete from formation where uid = ? and id = ?",
            unsigned, unsigned);
    GX_STMT(_insertFormation,
            "insert into formation (uid, id, sid, sid2, x, y) values (?, ?, ?, ?, ?, ?)",
            unsigned, unsigned, unsigned, unsigned, int, int);
    GX_STMT(_updateTask,
            "replace into task (uid, id, state) values (?, ?, ?)",
            unsigned, unsigned, unsigned);
    GX_STMT(_deleteTask,
            "delete from task where uid = ? and id = ?",
            unsigned, unsigned);
};

extern DB_ServletSQL the_sqls;

template <typename _T>
class DB_Servlet : public Servlet<_T> {
public:
    template <typename _Stmt, typename ..._Args>
    ptr<gx::ResultSet> select(_Stmt &stmt, _Args...args) {
        return stmt.query(std::forward<_Args>(args)...);
    }
    template <typename _Stmt, typename ..._Args>
    int exec(_Stmt &stmt, _Args...args) {
        return stmt.exec(std::forward<_Args>(args)...);
    }

    void apply_item_opts(unsigned uid, const obstack_vector<G_BagItemOpt> &opts) {
        for (auto &opt : opts) {
            if (opt.count) {
                exec(the_sqls._updateItem, uid, opt.id, opt.base, opt.count, opt.used, opt.value);
            }
            else {
                exec(the_sqls._deleteItem, uid, opt.id);
            }
        }
    }

    void apply_value_opts(unsigned uid, const obstack_vector<G_ValueOpt> &opts) {
        for (auto &opt : opts) {
            exec(the_sqls._updateValue, uid, opt.id, opt.value);
        }
    }

    void apply_cooldown_opts(unsigned uid, const obstack_vector<G_ExpireOpt> &opts) {
        for (auto &opt : opts) {
            exec(the_sqls._updateCooldown, uid, opt.id, opt.expire);
        }
    }

    void apply_soldier_value_opts(unsigned uid, const obstack_vector<G_SoldierValueOpt> &opts) {
        for (auto &opt : opts) {
            for (auto &value : opt.values) {
                if (value.value) {
                    exec(the_sqls._updateSoldierValue, uid, opt.sid, value.id, value.value);
                }
                else {
                    exec(the_sqls._deleteSoldierValue, uid, opt.sid, value.id);
                }
            }
        }
    }
    void apply_soldier_opts(unsigned uid, const obstack_vector<G_SoldierOpt> &opts) {
        for (auto &opt : opts) {
            exec(the_sqls._deleteSoldier, uid, opt.sid);
            exec(the_sqls._deleteTrain, uid, opt.sid);
        }
    }
    void apply_train_opts(unsigned uid, const obstack_vector<G_TrainExpireOpt> &opts) {
        for (auto &opt : opts) {
            if (opt.expire) {
                exec(the_sqls._updateTrain, uid, opt.sid, opt.expire, opt.type);
            }
            else {
                exec(the_sqls._deleteTrain, uid, opt.sid);
            }
        }
    }
    void apply_formation_opts(unsigned uid, const obstack_vector<G_FormationOpt> &opts) {
        for (auto &opt : opts) {
            exec(the_sqls._deleteFormation, uid, opt.id);

            for (auto &item : opt.items) {
                exec(the_sqls._insertFormation, uid, opt.id, item.sid, item.sid2, item.x, item.y);
            }
        }
    }
    void apply_task_opts(unsigned uid, const obstack_vector<G_TaskOpt> &opts) {
        for (auto &opt : opts) {
            if (opt.state == G_TASK_STATE_REMOVED) {
                exec(the_sqls._deleteTask, uid, opt.id);
            }
            else {
                exec(the_sqls._updateTask, uid, opt.id, opt.state);
            }
        }
    }
};

#endif


