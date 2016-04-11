#ifndef __LIBGAME_TASK_H__
#define __LIBGAME_TASK_H__

#include "object.h"
#include "level.h"
#include "award.h"
#include "libgame/g_task.h"
#include "tech.h"
#include "item.h"

class G_Player;
class DB_LoadRsp;

class G_TaskInfo : public G_ObjectInfo {
    friend class G_TaskMgr;
public:
    G_TaskInfo() noexcept;
    const G_TaskInfo *next() const noexcept {
        return _next;
    }
    const G_LevelInfo *level_limit() const noexcept {
        return _level_limit;
    }
    const G_AwardInfo *award() const noexcept {
        return _award;
    }
    unsigned type() const noexcept {
        return _type;
    }
    unsigned vip_limit() const noexcept {
        return _vip_limit;
    }
    unsigned finish_type() const noexcept {
        return _finish_type;
    }
    unsigned finish_value() const noexcept {
        return _finish_value;
    }
    const G_TechInfo *tech_value() const noexcept {
        return _tech_value;
    }
    const G_ItemInfo *item_value() const noexcept {
        return _item_value;
    }
private:
    const G_TaskInfo *_next;
    const G_LevelInfo *_level_limit;
    unsigned _type;
    unsigned _finish_type;
    unsigned _finish_value;
    unsigned _vip_limit;
    const G_AwardInfo *_award;
    const G_TechInfo *_tech_value;
    const G_ItemInfo *_item_value;
};

class G_TaskMgr : public G_ObjectInfoContainer<G_TaskInfo>, public singleton<G_TaskMgr> {
public:
    G_TaskMgr() noexcept;
    bool init();

    using G_ObjectInfoContainer<G_TaskInfo>::get_info;
    const G_TaskInfo *get_first(unsigned type) const noexcept {
        assert(type < G_TASK_UNKNOWN);
        return _tasks[type];
    }
private:
    const G_TaskInfo *_tasks[G_TASK_UNKNOWN];
};

class G_TaskItem : public Object {
    friend class G_Task;
public:
    G_TaskItem() noexcept;
private:
    bool check_accept(G_Player *player) noexcept;
    bool check_finish(G_Player *player) noexcept;
    void to_opt(G_TaskOpt &opt) noexcept;
    void to_opt(obstack_vector<G_TaskOpt> &opts) noexcept;
    void to_opt() noexcept;
    bool check(G_Player *player) noexcept;
private:
    const G_TaskInfo *_info;
    unsigned _state;
};

class G_Task : public Object {
public:
    G_Task() noexcept;
    void init(G_Player *player, DB_LoadRsp *msg) noexcept;
    void check(G_Player *player) noexcept;
    bool finish(G_Player *player, const G_TaskInfo *info) noexcept;
    void to_opt(obstack_vector<G_TaskOpt> &opts) noexcept;
private:
    ptr<G_TaskItem> _tasks[G_TASK_UNKNOWN];
};

#endif

