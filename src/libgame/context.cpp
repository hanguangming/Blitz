#include "context.h"
#include "agentsvr/cl_notify.h"
#include "player.h"

/* G_AgentContextBase */
G_AgentContextBase::G_AgentContextBase() noexcept
: _stub()
{ }

bool G_AgentContextBase::begin(Network *network, Peer *peer) noexcept {
    if (!peer) {
        _attached = false;
        return Context::begin(network, peer);
    }
    if (!peer->peer_object) {
        return begin(nullptr, network, peer);
    }
    return begin(static_cast<G_PlayerStub*>(peer->peer_object), network, peer);
}

bool G_AgentContextBase::begin(G_PlayerStub *stub, Network *network, Peer *peer) noexcept {
    assert(!_data);
    assert(!_stub);

    _attached = false;
    _failed = false;

    if (!Context::begin(network, peer)) {
        return false;
    }

    _data = pool()->construct<G_AgentContextData>(pool());

    if (stub) {
        stub->attach(this);
    }
    return true;
}

void G_AgentContextBase::rollback(bool fail) noexcept {
    Context::rollback(fail);
    _failed = fail;
}

void G_AgentContextBase::finish() noexcept {
    Context::finish();
    if (_attached) {
        _stub->detach(this, _failed);
    }
    _attached = false;
    _stub = nullptr;
    _data = nullptr;
}

/* G_AgentContext */
inline void G_AgentContext::send(unsigned servlet, const INotify *notify) noexcept {
    stub()->player()->peer()->send(servlet, 0, notify);
}

bool G_AgentContext::commit() noexcept {
    G_Player *player = the_player();
    if (player && player->state() == G_PLAYER_STATE_ONLINE) {
        Peer *peer = Context::peer();
        if (peer) {
            timeval_t t = logic_time();

            player->update_score_value();
            if (_data->_bag_opts.size()) {
                CL_NotifyItemsReq notify;
                notify.items = std::move(_data->_bag_opts);
                send(notify);
            }

            if (_data->_cooldown_opts.size()) {
                CL_NotifyCooldownReq notify;
                for (auto &cd : the_cd_opts()) {
                    notify.cds.emplace_back();
                    auto &c = notify.cds.back();
                    c.id = cd.id;
                    c.time = cd.expire > t ? cd.expire - t : 0;
                }
                send(notify);
            }
            if (_data->_value_opts.size()) {
                CL_NotifyValuesReq notify;
                notify.values = std::move(_data->_value_opts);
                send(notify);
            }
            if (_data->_tmp_value_opts.size()) {
                CL_NotifyValuesReq notify;
                notify.values = std::move(_data->_tmp_value_opts);
                send(notify);
            }
            for (auto it = _data->_soldier_value_opts.begin(); it != _data->_soldier_value_opts.end(); ++it) {
                CL_NotifySoldierValuesReq notify;
                notify.sid = it->first;
                notify.values = std::move(it->second);
                send(notify);
            }
            if (_data->_train_opts.size()) {
                CL_NotifyTrainReq notify;
                for (auto &opt : _data->_train_opts) {
                    notify.lines.emplace_back();
                    auto &elm = notify.lines.back();
                    elm.sid = opt.sid;
                    elm.time = t >= opt.expire ? 0 : opt.expire - t;
                    elm.type = opt.type;
                }
                send(notify);
            }
            if (_data->_soldier_opts.size()) {
                CL_NotifySoldierReq notify;
                notify.soldiers = std::move(_data->_soldier_opts);
                send(notify);
            }
            if (_data->_formation_opts.size()) {
                CL_NotifyFormationReq notify;
                notify.formations = std::move(_data->_formation_opts);
                send(notify);
            }
            if (_data->_tech_opts.size()) {
                CL_NotifyTechReq notify;
                for (auto &opt : _data->_tech_opts) {
                    notify.techs.emplace_back();
                    auto &opt2 = notify.techs.back();
                    opt2.type = opt.type;
                    opt2.cur = opt.cur;
                    opt2.research = opt.research;
                    opt2.price_num = opt.price_num;
                    opt2.cooldown = opt.cooldown > t ? opt.cooldown - t : 0;
                }
                send(notify);
            }
            if (_data->_task_opts.size()) {
                CL_NotifyTaskReq notify;
                notify.tasks = std::move(_data->_task_opts);
                send(notify);
            }
        }
    }

    G_AgentContextBase::commit();

    return true;
}

void G_AgentContext::clear() noexcept {
    G_AgentContextBase::clear();
    if (_data) {
        _data->_cooldown_opts.clear();
        _data->_bag_opts.clear();
        _data->_value_opts.clear();
        _data->_soldier_value_opts.clear();
        _data->_soldier_opts.clear();
        _data->_train_opts.clear();
        _data->_formation_opts.clear();
        _data->_tech_opts.clear();
        _data->_task_opts.clear();
        _data->_tmp_value_opts.clear();
    }
}

