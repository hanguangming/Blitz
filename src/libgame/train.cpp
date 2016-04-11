#include "train.h"
#include "player.h"
#include "context.h"
#include "dbsvr/db_train.h"
#include "corps.h"
#include "param.h"

/* G_TrainMgr */
bool G_TrainMgr::init() {
    auto tab_info = the_app->script()->read_table("the_train_info");
    if (tab_info->is_nil()) {
        return false;
    }
    for (unsigned i = 1; ; ++i) {
        auto tab_item = tab_info->read_table(i);
        if (tab_item->is_nil()) {
            break;
        }

        int train_id = tab_item->read_integer("traintype", -1);
        if (train_id < 0) {
            continue;
        }
        switch (train_id) {
        case G_TRAIN_LOW:
        case G_TRAIN_MIDDLE:
        case G_TRAIN_HIGH:
            break;
        default:
            log_error("unknown train id '%d'.", train_id);
            return false;
        }

        G_TrainInfo *info = probe_info(train_id);
        info->_time = tab_item->read_integer("time", 0) * 1000;
    }
    return true;
}

/* G_TrainLine */
timeval_t G_TrainLine::timer_handler(timeval_t now) {
    _train->cancel(id());

    G_Player *player = the_player();
    DB_TrainCancel msg;
    msg.req->id(player->id());
    msg.req->value_opts = the_value_opts();
    msg.req->train_opts = the_train_opts();
    the_context()->network()->call(msg);
    the_context()->commit();
    return 0;
}

/* G_Train */
bool G_Train::add(unsigned soldier_id, const G_TrainInfo *info) {
    G_TrainLine *line = get_object(soldier_id);
    if (line) {
        return false;
    }
    line = probe_object(soldier_id, info);
    if (line->_train) {
        return false;
    }

    G_Player *player = the_player();
    G_Soldier *soldier = player->corps()->get(soldier_id);

    unsigned exp;
    switch (info->id()) {
    case G_TRAIN_LOW:
        exp = soldier->level()->train_low_exp();
        break;
    case G_TRAIN_MIDDLE:
        exp = soldier->level()->train_middle_exp();
        break;
    case G_TRAIN_HIGH:
        exp = soldier->level()->train_high_exp();
        break;
    default:
        return false;
    }

    soldier->add_exp(exp);

    line->_train = this;
    player->timer_mgr()->schedule(line, logic_time() + info->_time);

    the_data()->_train_opts.emplace_back();
    auto &opt = the_data()->_train_opts.back();
    opt.sid = soldier_id;
    opt.expire = line->expire();
    opt.type = line->info()->id();
    return true;
}

ptr<G_TrainLine> G_Train::cancel(unsigned soldier_id) {
    ptr<G_TrainLine> line = get_object(soldier_id);
    if (line) {
        if (line->expire() > logic_time()) {
            timeval_t dt = line->expire() - logic_time();
            unsigned n = dt / G_ParamMgr::instance()->train_acc_time();
            if (dt % G_ParamMgr::instance()->train_acc_time()) {
                n++;
            }
            G_Money money = G_ParamMgr::instance()->train_acc_price() * n;
            G_Player *player = the_player();
            if (!player->has_money(money)) {
                return nullptr;
            }
            player->use_money(money);
        }
        remove(soldier_id);
    }
    return line;
}

ptr<G_TrainLine> G_Train::remove(unsigned soldier_id) {
    ptr<G_TrainLine> line = remove_object(soldier_id);
    if (line) {
        the_data()->_train_opts.emplace_back();
        auto &opt = the_data()->_train_opts.back();
        opt.sid = soldier_id;
        opt.expire = 0;
        opt.type = line->info()->id();
    }
    return line;
}

void G_Train::init(G_Player *player, G_Soldier *soldier, const G_TrainInfo *info, timeval_t expire) noexcept {
    G_TrainLine *line = probe_object(soldier->id(), info);
    if (line->_train) {
        return;
    }
    line->_train = this;
    player->timer_mgr()->schedule(line, expire);
}

