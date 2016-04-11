#include "task.h"
#include "player.h"
#include "dbsvr/db_login.h"
#include "dbsvr/db_task.h"

/* G_TaskInfo */
G_TaskInfo::G_TaskInfo() noexcept 
: _next(), 
  _level_limit(),
  _type(),
  _finish_type(),
  _finish_value(),
  _vip_limit(),
  _award(),
  _tech_value(),
  _item_value()
{ }

/* G_TaskMgr */
G_TaskMgr::G_TaskMgr() noexcept {
    memset(_tasks, 0, sizeof(_tasks));
}

bool G_TaskMgr::init() {
    auto tab_info = the_app->script()->read_table("the_task_info");
    if (tab_info->is_nil()) {
        return false;
    }
    for (unsigned i = 1; ; ++i) {
        auto tab_item = tab_info->read_table(i);
        if (tab_item->is_nil()) {
            break;
        }

        int id = tab_item->read_integer("id", -1);
        if (id < 0) {
            continue;
        }
        G_TaskInfo *info = probe_info(id);
        unsigned pretask_id = tab_item->read_integer("perid", 0);
        unsigned type = tab_item->read_integer("type", 0);
        type--;
        if (type >= G_TASK_UNKNOWN) {
            log_error("unknown task type '%d'.", type);
            return false;
        }
        info->_type = type;
        if (!pretask_id) {
            if (_tasks[type]) {
                log_error("task type '%d' already has first task '%d'.", type, (int)_tasks[type]->id());
                return false;
            }
            _tasks[type] = info;
        }
        else {
            const G_TaskInfo *pretask = get_info(pretask_id);
            if (!pretask) {
                log_error("unknown pretask id '%d'.", pretask_id);
                return false;
            }
            if (pretask->_type != info->_type) {
                log_error("task '%d' with pretask '%d' type is not equal.", (int)info->id(), (int)pretask->id());
                return false;
            }
            const_cast<G_TaskInfo*>(pretask)->_next = info;
        }

        info->_vip_limit = tab_item->read_integer("viplv", 0);
        info->_finish_type = tab_item->read_integer("tasktype", 0);
        info->_finish_value = tab_item->read_integer("taskvalue", 0);
        unsigned award_id = tab_item->read_integer("rewardid", 0);
        info->_award = G_AwardMgr::instance()->get_info(award_id);
        if (!info->_award) {
            log_error("unknown award id '%d'.", award_id);
            return false;
        }
        unsigned level = tab_item->read_integer("lv", 0);
        info->_level_limit = G_LevelMgr::instance()->get_info(level);
        if (!info->_level_limit) {
            log_error("unknown level limit '%d'.", level);
            return false;
        }
        switch (info->_finish_type) {
        case G_TASK_COND_TECH:
            info->_tech_value = G_TechMgr::instance()->get_info(info->_finish_value);
            if (!info->_tech_value) {
                log_error("unknown tech id '%d'.", info->_finish_value);
                return false;
            }
            break;
        case G_TASK_COND_BUY_ITEM:
            info->_item_value = G_ItemMgr::instance()->get_info(info->_finish_value);
            if (!info->_item_value) {
                log_error("unknown item id '%d'.", info->_finish_value);
                return false;
            }
        }
    }
    return true;
}

/* G_TaskItem */
G_TaskItem::G_TaskItem() noexcept
: _info(), _state()
{ }

inline void G_TaskItem::to_opt(G_TaskOpt &opt) noexcept {
    opt.id = _info->id();
    opt.state = _state;
}

void G_TaskItem::to_opt(obstack_vector<G_TaskOpt> &opts) noexcept {
    if (!opts.empty()) {
        auto &opt = opts.back();
        if (opt.id == _info->id() && opt.state < G_TASK_STATE_REMOVED) {
            opt.state = _state;
            return;
        }
    }
    opts.emplace_back();
    to_opt(opts.back());
}

void G_TaskItem::to_opt() noexcept {
    to_opt(the_data()->_task_opts);
}

inline bool G_TaskItem::check_accept(G_Player *player) noexcept {
    if (player->level() < _info->level_limit()->level()) {
        return false;
    }
    if (player->vip()->level() < _info->vip_limit()) {
        return false;
    }
    return true;
}

inline bool G_TaskItem::check_finish(G_Player *player) noexcept {
    unsigned value = _info->finish_value();

    switch (_info->finish_type()) {
    case G_TASK_COND_STAGE:
        return player->stage() >= value;
    case G_TASK_COND_LEVEL:
        return player->level() >= value;
    case G_TASK_COND_BUY_ITEM:
        return player->bag()->has_item(_info->item_value(), 1);
    case G_TASK_COND_TECH:
        do {
            const G_TechItem *tech = player->tech()->get_tech(_info->tech_value()->type());
            if (tech && tech->info()) {
                return tech->info()->id() >= _info->tech_value()->id();
            }
            return false;
        } while (0);
    default:
        return false;
    }
}

inline bool G_TaskItem::check(G_Player *player) noexcept {
    bool r = false;
again:
    switch (_state) {
    case G_TASK_STATE_NOREADY:
        if (!check_accept(player)) {
            break;
        }
        _state = G_TASK_STATE_ACCEPTED;
        to_opt();
        r = true;
    case G_TASK_STATE_ACCEPTED:
        if (!check_finish(player)) {
            break;
        }
        _state = G_TASK_STATE_FINISHED;
        to_opt();
        r = true;
        break;
    case G_TASK_STATE_END:
        if (_info->next()) {
            _state = G_TASK_STATE_REMOVED;
            to_opt();

            _info = _info->next();
            _state = G_TASK_STATE_NOREADY;
            to_opt();
            r = true;
            goto again;
        }
        break;
    }
    return r;
}

/* G_Task */
G_Task::G_Task() noexcept {
}

void G_Task::check(G_Player *player) noexcept {
    bool r = false;
    for (unsigned i = 0; i < G_TASK_UNKNOWN; ++i) {
        G_TaskItem *task = _tasks[i];
        if (!task) {
            continue;
        }
        r = r || task->check(player);
    }

    if (r) {
        DB_TaskUpdate msg;
        msg.req->id(player->id());
        msg.req->task_opts = the_task_opts();
        the_context()->network()->call(msg);
        the_context()->commit();
    }
}

void G_Task::to_opt(obstack_vector<G_TaskOpt> &opts) noexcept {
    for (unsigned i = 0; i < G_TASK_UNKNOWN; ++i) {
        G_TaskItem *task = _tasks[i];
        if (task && task->_state < G_TASK_STATE_REMOVED) {
            task->to_opt(opts);
        }
    }
}

void G_Task::init(G_Player *player, DB_LoadRsp *msg) noexcept {
    for (auto &opt : msg->tasks) {
        if (opt.state == G_TASK_STATE_REMOVED) {
            continue;
        }
        const G_TaskInfo *info = G_TaskMgr::instance()->get_info(opt.id);
        if (!info) {
            continue;
        }
        if (info->type() >= G_TASK_UNKNOWN) {
            continue;
        }
        if (_tasks[info->type()]) {
            continue;
        }
        object<G_TaskItem> task;
        _tasks[info->type()] = task;
        task->_info = info;
        task->_state = opt.state;
    }
    for (unsigned i = 0; i < G_TASK_UNKNOWN; ++i) {
        if (!_tasks[i]) {
            const G_TaskInfo *info = G_TaskMgr::instance()->get_first(i);
            if (info) {
                object<G_TaskItem> task;
                task->_info = info;
                task->_state = G_TASK_STATE_NOREADY;
                _tasks[i] = task;
            }
        }
    }
    player->mark_task_dirty();
}

bool G_Task::finish(G_Player *player, const G_TaskInfo *info) noexcept {
    if (info->type() >= G_TASK_UNKNOWN) {
        return false;
    }

    G_TaskItem *task = _tasks[info->type()];
    if (!task) {
        return false;
    }

    if (task->_info != info) {
        return false;
    }

    if (task->_state != G_TASK_STATE_FINISHED) {
        return false;
    }

    if (info->next()) {
        task->_state = G_TASK_STATE_REMOVED;
        task->to_opt();

        task->_state = G_TASK_STATE_NOREADY;
        task->_info = info->next();
        task->check(player);
    }
    else {
        task->_state = G_TASK_STATE_END;
        the_data()->_task_opts.emplace_back();
        task->to_opt(the_data()->_task_opts.back());
    }
    return true;
}

