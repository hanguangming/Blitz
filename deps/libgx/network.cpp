#include "network.h"
#include "peer.h"
#include "log.h"
#include "hash.h"
#include "coroutine.h"
#include "servlet.h"
#include "rc.h"

#include <unistd.h>

#ifdef __GX_SERVER__
#include "script.h"

GX_NS_BEGIN

/* NetworkInstance */
NetworkInstance::NetworkInstance(
    Network *network,
    const std::string &host,
    unsigned port,
    timeval_t timeout,
    timeval_t interval,
    std::string &ap,
    int id,
    const std::string &name) noexcept
: _host(host),
  _port(port),
  _timeout(timeout),
  _interval(interval),
  _ap(ap),
  _network(network),
  _id(id),
  _name(name),
  _is_local(false)
{ }

bool NetworkInstance::listen(ptr<Reactor> reactor) noexcept {
    if (_listener) {
        return true;
    }
    Address addr;
    if (!addr.resolve(_host.c_str(), _port)) {
        return false;
    }
    _listener = object<Listener>(addr, reactor, std::bind(&NetworkInstance::on_accept, this, _1, _2, _3));
    return _listener->listen();
}

bool NetworkInstance::connect() noexcept {
    if (!_connector) {
        if (!_conn_addr.resolve(_host.c_str(), _port)) {
            return false;
        }
        _connector = object<Connector>(
            _conn_addr, _network->_reactor, _network->_timermgr,
            _timeout, _interval,
            std::bind(&NetworkInstance::on_connection, this, _1, _2));
    }

    log_debug("connect to %s[%d] = %s:%d.", _name.c_str(), _id, _conn_addr.host(), _conn_addr.port());
    return _connector->connect();
}

bool NetworkInstance::on_connection(Socket *socket, int flags) noexcept {
    if (flags & (Reactor::poll_in | Reactor::poll_out)) {
        socket->flags(-1);
        assert(!_peer);
        ptr<Peer> peer = object<Peer>(false);
        peer->_socket = socket;
        socket->handler(std::bind(&NetworkInstance::on_data, this, peer, _1, _2));
        socket->flags(-1);
        assert(!_peer);
        _peer = peer.get();
        _network->_connect_list.push_front(peer);
        log_debug("connect %s[%d] = %s:%d successed, at socket %d.", _name.c_str(), _id, _conn_addr.host(), _conn_addr.port(), socket->fd());
    }
    return true;
}

bool NetworkInstance::on_accept(int fd, unsigned flags, const Address &addr) noexcept {
    if (flags & Reactor::poll_open) {
        log_debug("listen %s[%d] = %s:%d at socket %d.", _name.c_str(), _id, addr.host(), addr.port(), fd);
    }

    if (flags & Reactor::poll_in) {
        log_debug("accept %s:%d at socket %d.", addr.host(), addr.port(), fd);
        ptr<Peer> peer = object<Peer>(is_ap());
        Socket *socket = _listener->reactor()->open(fd, -1, std::bind(&NetworkInstance::on_data, this, peer, _1, _2));
        peer->_socket = socket;
        peer->_network = _network;
        _network->_accept_list.push_front(peer);
    }

    return true;
}

bool NetworkInstance::on_data(ptr<Peer> peer, Socket &socket, int flags) noexcept {
    int n;
    if (flags & Reactor::poll_close) {
        int fd = socket.fd();
        Socket::close_fd(fd);
        log_debug("socket %d closed.", fd);
        if (peer.get() == _peer) {
            log_warning("connection %s[%d] = %s:%d closed, at socket %d.", _name.c_str(), _id, _conn_addr.host(), _conn_addr.port(), fd);
            _network->_timermgr->schedule_abs(0, [this](Timer&, timeval_t) {
                connect();
                return 0;
            });
        }
        return false;
    }

    if (flags & Reactor::poll_err) {
        return false;
    }
    if (flags & Reactor::poll_out) {
        socket.send();
    }
    if (flags & Reactor::poll_in) {
        n = socket.load();
        if (n < 0) {
            log_debug("socket %d load failed %d.", socket.fd(), n);
            return false;
        }
        while (peer->_socket && socket.input().size() > 0) {
            ProtocolInfo info;
            n = peer->unserial(info, socket.input());
            if (!n) {
                break;
            }
            else if (n > 0) {
                if (peer.get() != _peer) {
                    _network->request_handler(info, peer, socket.input());
                }
                else {
                    _network->response_handler(info, peer, socket.input());
                }
            }
            else {
                return false;
            }
        }
    }
    return true;
}

bool Network::init(Script *script, ptr<TimerManager> timermgr, ptr<Reactor> reactor) noexcept {
    auto tab = script->read_table("the_network");
    if (tab->is_nil()) {
        return false;
    }
    _rpc_timeout = (timeval_t)tab->read_integer("rpc_timeout", 3000);
    tab = tab->read_table("nodes");
    if (tab->is_nil()) {
        return false;
    }

    for (auto n : *tab) {
        if (!n.name->is_string()) {
            return false;
        }
        if (!n.value->is_table()) {
            return false;
        }
        auto node_name = n.name->string();
        auto node_group = n.value->table();
        auto node_id = node_group->read_integer("id");
        if (node_id < 0 || node_id > 1024) {
            return false;
        }

        if ((unsigned)node_id >= _nodes.size()) {
            _nodes.resize(node_id + 1);
        }
        _nodes[node_id] = object<NetworkNode>(node_id, node_name);
        auto &node = _nodes[node_id];

        unsigned instance_index = 0;
        bool first = true;
        while (true) {
            auto instance = node_group->read_table(instance_index + 1);
            if (instance->is_nil()) {
                break;
            }
            unsigned index = instance_index++;

            auto servlets = instance->read_table("servlets");
            if (servlets->is_nil()) {
                continue;
            }
            for (auto s : *servlets) {
                if (!s.name->is_string()) {
                    return false;
                }
                if (!s.value->is_table()) {
                    return false;
                }
                auto servlet_name = s.name->string();
                auto servlet = s.value->table();
                auto servlet_id = servlet->read_integer("id");
                if (servlet_id < 0 || servlet_id > 1024) {
                    return false;
                }
                if ((unsigned)servlet_id >= _servlets.size()) {
                    _servlets.resize(servlet_id + 1);
                }

                auto host = servlet->read_string("host");
                auto port = servlet->read_integer("port");
                timeval_t timeout = servlet->read_integer("timeout", 3000);
                timeval_t interval = servlet->read_integer("interval", 1000);
                std::string ap = servlet->read_string("ap");
                std::string name = servlet->read_string("name");
                _servlets[servlet_id].emplace_back(this, host, port, timeout, interval, ap, index, name);
                if (first) {
                    node->_servlets.emplace_back(servlet_id);
                }
            }
            first = false;
        }
        node->_instance_count = instance_index;
    }
    _seq = 1;
    _timermgr = timermgr;
    _reactor = reactor;
    _call_count = 0;
    return true;
}

bool Network::startup(int type, unsigned id) noexcept {
    _type = type;
    _id = id;
    assert(_type >= 0 && (unsigned)_type < _nodes.size());
    NetworkNode *node = _nodes[_type];
    for (auto servlet : node->_servlets) {
        auto &instances = _servlets[servlet];
        if (id >= instances.size()) {
            return false;
        }
        auto &instance = instances[id];
        instance._is_local = true;
        instance.listen(_reactor);
    }

    for (auto &instances : _servlets) {
        for (auto &instance : instances) {
            if (!instance.is_ap()) {
                instance.connect();
            }
        }
    }

    return true;
}

void Network::shutdown_servlets() noexcept {
    NetworkNode *node = _nodes[_type];
    for (auto servlet : node->_servlets) {
        auto &instances = _servlets[servlet];
        auto &instance = instances[_id];
        if (instance._listener) {
            instance._listener->close();
        }
    }
    Peer *peer;
    while ((peer = _accept_list.pop_front())) {
        peer->close();
    }
}

inline NetworkInstance *Network::get_class_instance_n(unsigned id, unsigned class_index) noexcept {
    if (class_index >= _servlets.size()) {
        return nullptr;
    }
    auto &instances = _servlets[class_index];
    if (instances.empty()) {
        return nullptr;
    }
    return &instances[hash_iterative(&id, sizeof(id)) % instances.size()];
}

NetworkInstance *Network::get_class_instance(unsigned id, unsigned class_index) noexcept {
    return get_class_instance_n(id, class_index);
}

NetworkInstance *Network::get_instance(unsigned id, unsigned servlet) noexcept {
    unsigned servlet_index = (servlet >> 16);
    return get_class_instance_n(id, servlet_index);
}

Peer *Network::send(unsigned id, unsigned servlet, const INotify *req, unsigned *seq_r, NetworkInstance *instance) noexcept {
    assert(id);

    if (!instance) {
        instance = get_instance(id, servlet);
        if (!instance) {
            return nullptr;
        }
        if (!instance->_peer) {
            return nullptr;
        }
    }

    unsigned seq = _seq++;
    if (!seq) {
        seq = _seq = 1;
    }

    if (seq_r) {
        *seq_r = seq;
    }

    if (instance->_peer->send(servlet, seq, req)) {
        return instance->_peer;
    }
    return nullptr;
}

void Network::broadcast(unsigned servlet, const INotify *req) noexcept {
    unsigned servlet_index = (servlet >> 16);

    if (servlet_index >= _servlets.size()) {
        return;
    }
    auto &instances = _servlets[servlet_index];
    if (instances.empty()) {
        return;
    }

    unsigned seq = _seq++;
    if (!seq) {
        seq = _seq = 1;
    }

    for (auto &instance : instances) {
        if (instance._peer) {
            instance._peer->send(servlet, seq, req);
        }
    }
}

void Network::broadcast_all(unsigned servlet, const INotify *req) noexcept {
    unsigned seq = _seq++;
    if (!seq) {
        seq = _seq = 1;
    }
    for (auto &instances : _servlets) {
        for (auto &instance : instances) {
            if (instance._peer) {
                instance._peer->send(servlet, seq, req);
            }
        }
    }
}

void Network::call(uint64_t id, unsigned servlet, IRequest *req, IResponse *rsp) {
    unsigned seq;

    assert(!Coroutine::is_main_routine());

    NetworkInstance *instance = get_instance(id, servlet);
    if (!instance) {
        log_debug("send call failed, servlet = %x, seq = %d.", servlet, seq);
        throw ServletException(GX_EBUSY);
    }

    /*
    if (instance->_is_local) {
        ServletManager::instance()->execute(servlet, req, rsp);
        return;
    }*/

    Peer *peer = send(id, servlet, req, &seq);
    if (!peer) {
        log_debug("send call failed, servlet = %x, seq = %d.", servlet, seq);
        throw ServletException(GX_EBUSY);
    }

    Context *ctx = the_context();
    auto r = _call_map.emplace(seq, ctx);
    if (!r.second) {
        log_debug("dup call seq, servlet = %x, seq = %d.", servlet, seq);
        throw ServletException(GX_EBUSY);
    }

    log_debug("send call, servlet = %x, seq = %d.", servlet, seq);

    ctx->_call_result = GX_CALL_UNKNOWN;
    ctx->_timer = _timermgr->schedule(_rpc_timeout, std::bind(&Network::call_timeout_handler, this, ctx, _1, _2));

    peer->_call_list.push_front(ctx);
    ++_call_count;
    if (!Coroutine::yield()) {
        ctx->_timer->close();
        _call_map.erase(seq);
        log_debug("send call yield failed.");
        throw ServletException(GX_EBUSY);
    }
    --_call_count;
    Peer::ctx_list_t::remove(ctx);

    _call_map.erase(r.first);
    if (ctx->_timer) {
        ctx->_timer->close();
    }

    switch (ctx->_call_result) {
    case GX_CALL_OK:
        log_debug("recv response, servlet = %x, seq = %d.", servlet, seq);
        if (rsp->read_rc(peer->input())) {
            if (rsp->rc) {
                return;
            }
            if (rsp->unserial(peer->input(), ctx->pool())) {
                return;
            }
            else {
                log_error("read response failed, input size = %lu", peer->input().size());
            }
        }
        else {
            log_error("read response rc failed, input size = %lu", peer->input().size());
        }
        peer->close();
        throw CallCancelException();
    case GX_CALL_TIMEDOUT:
        log_debug("call '%d' timedout.", seq);
        throw ServletException(GX_ETIMEOUT);
    case GX_CALL_CANCEL:
        log_debug("call '%d' cancelled.", seq);
        throw CallCancelException();
    default:
        log_debug("call unknown error");
        assert(0);
        return;
    }
}

timeval_t Network::call_timeout_handler(Context *ctx, Timer&, timeval_t) noexcept {
    log_debug("call timedout.");
    ctx->call_timedout();
    return 0;
}

inline void Network::request_handler(ProtocolInfo &info, Peer *peer, Stream&) noexcept {
    ServletManager::instance()->execute(info.servlet, info.seq, info.size, peer);
}

inline void Network::response_handler(ProtocolInfo &info, Peer *peer, Stream &stream) noexcept {
    auto it = _call_map.find(info.seq);
    if (it == _call_map.end()) {
        log_debug("can't find call seq '%d'.", info.seq);
        stream.read(nullptr, info.size);
        return;
    }
    log_debug("on response servlet = %x, seq = %d, size = %d", info.servlet, info.seq, info.size);
    Context *ctx = it->second;
    assert(ctx);
    ctx->call_ok();
}

const NetworkInstance &Network::instance(unsigned type, unsigned index) const noexcept {
    auto &instances = _servlets[type];
    return instances[index];
}


unsigned Network::instance_count(unsigned type) const noexcept {
    auto &instances = _servlets[type];
    return instances.size();
}

bool Network::ready() noexcept {
    for (auto &instances : _servlets) {
        for (auto &instance : instances) {
            if (!instance.is_ap()) {
                if (!instance._peer) {
                    return false;
                }
            }
        }
    }
    return true;
}

GX_NS_END

#else

#endif


