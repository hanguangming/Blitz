#ifndef __LIBGAME_CONTEXT_H__
#define __LIBGAME_CONTEXT_H__

#include <map>

#include "game.h"
#include "bag.h"
#include "cooldown.h"
#include "value.h"
#include "corps.h"
#include "train.h"
#include "formation.h"
#include "tech.h"
#include "task.h"

class G_Player;
class G_PlayerStub;

class G_AgentContextData {
    friend class G_AgentContextBase;
    friend class G_AgentContext;
    friend class G_Player;
    friend class G_Bag;
    friend class G_BagItem;
    friend class G_Cooldown;
    friend class G_ValuesBase;
    friend class G_Corps;
    friend class G_SoldierValues;
    friend class G_Train;
    friend class G_Formation;
    friend class G_Tech;
    friend class G_TechItem;
    friend class G_Task;
    friend class G_TaskItem;
    friend class G_PlayerTmpValues;

public:
    G_AgentContextData(Obstack *pool) noexcept
    : _cooldown_opts(pool),
      _bag_opts(pool),
      _value_opts(pool),
      _tmp_value_opts(pool),
      _soldier_value_opts(pool),
      _soldier_opts(pool),
      _train_opts(pool),
      _formation_opts(pool),
      _tech_opts(pool),
      _task_opts(pool)
    { }
private:
    obstack_vector<G_ExpireOpt> _cooldown_opts;
    obstack_vector<G_BagItemOpt> _bag_opts;
    obstack_vector<G_ValueOpt> _value_opts;
    obstack_vector<G_ValueOpt> _tmp_value_opts;
    obstack_map<unsigned, obstack_vector<G_ValueOpt>> _soldier_value_opts;
    obstack_vector<G_SoldierOpt> _soldier_opts;
    obstack_vector<G_TrainExpireOpt> _train_opts;
    obstack_vector<G_FormationOpt> _formation_opts;
    obstack_vector<G_TechExpireOpt> _tech_opts;
    obstack_vector<G_TaskOpt> _task_opts;
};

class G_AgentContextBase : public Context {
    friend class G_Player;
    friend class G_PlayerStub;
public:
    G_AgentContextBase() noexcept;
    G_PlayerStub *stub() noexcept {
        return _stub;
    }

    bool begin(G_PlayerStub *stub, Network *network, Peer *peer) noexcept;
    bool begin(Network *network, Peer *peer) noexcept override;
    void rollback(bool fail) noexcept override;
    void finish() noexcept override;
protected:
    G_AgentContextData *_data;

private:
    clist_entry _entry;
    clist_entry _load_entry;
    G_PlayerStub *_stub;
    bool _failed;
    int _attached;
};

class G_AgentContext : public G_AgentContextBase {
public:
    bool commit() noexcept override;
    static G_AgentContext *instance() noexcept {
        return static_cast<G_AgentContext*>(the_context());
    }
    G_AgentContextData *data() noexcept {
        return _data;
    }
    const obstack_vector<G_ExpireOpt> &cooldown_opts() const noexcept {
        return _data->_cooldown_opts;
    }
    const obstack_vector<G_BagItemOpt> &bag_opts() const noexcept {
        return _data->_bag_opts;
    }
    const obstack_vector<G_ValueOpt> &value_opts() const noexcept {
        return _data->_value_opts;
    }
    const obstack_map<unsigned, obstack_vector<G_ValueOpt>> &soldier_value_opts() const noexcept {
        return _data->_soldier_value_opts;
    }
    const obstack_vector<G_SoldierOpt> &soldier_opts() const noexcept {
        return _data->_soldier_opts;
    }
    const obstack_vector<G_TrainExpireOpt> &train_opts() const noexcept {
        return _data->_train_opts;
    }
    const obstack_vector<G_FormationOpt> &formation_opts() const noexcept {
        return _data->_formation_opts;
    }
    const obstack_vector<G_TechExpireOpt> &tech_opts() const noexcept {
        return _data->_tech_opts;
    }
    const obstack_vector<G_TaskOpt> &task_opts() const noexcept {
        return _data->_task_opts;
    }

protected:
    void clear() noexcept override;

private:
    template <typename _Notify>
    void send(_Notify &notify) {
        if (the_dump_message) {
            notify.dump(nullptr, 0, pool());
            pool()->grow1('\0');
            log_debug("\n%s", (char*)pool()->finish());
        }

        send(_Notify::the_message_id, &notify);
    }
    void send(unsigned servlet, const INotify *notify) noexcept;
};

inline const obstack_vector<G_BagItemOpt> &the_bag_opts() noexcept {
    return G_AgentContext::instance()->bag_opts();
}

inline const obstack_vector<G_ValueOpt> &the_value_opts() noexcept {
    return G_AgentContext::instance()->value_opts();
}

inline const obstack_vector<G_ExpireOpt> &the_cd_opts() noexcept {
    return G_AgentContext::instance()->cooldown_opts();
}

inline obstack_vector<G_SoldierValueOpt> the_soldier_value_opts() noexcept {
    Obstack *pool = the_pool();
    auto & opts = G_AgentContext::instance()->soldier_value_opts();
    obstack_vector<G_SoldierValueOpt> result(pool);
    for (auto it = opts.begin(); it != opts.end(); ++it) {
        result.emplace_back();
        auto &opt = result.back();
        opt.sid = it->first;
        opt.values = it->second;
    }
    return result;
}

inline const obstack_vector<G_SoldierOpt> &the_soldier_opts() noexcept {
    return G_AgentContext::instance()->soldier_opts();
}

inline const obstack_vector<G_TrainExpireOpt> &the_train_opts() noexcept {
    return G_AgentContext::instance()->train_opts();
}

inline const obstack_vector<G_FormationOpt> &the_formation_opts() noexcept {
    return G_AgentContext::instance()->formation_opts();
}

inline const obstack_vector<G_TechExpireOpt> &the_tech_opts() noexcept {
    return G_AgentContext::instance()->tech_opts();
}

inline const obstack_vector<G_TaskOpt> &the_task_opts() noexcept {
    return G_AgentContext::instance()->task_opts();
}

inline G_AgentContextData *the_data() noexcept {
    return G_AgentContext::instance()->data();
}
#endif

