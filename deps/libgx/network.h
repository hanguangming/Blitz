#ifndef __GX_NETWORK_H__
#define __GX_NETWORK_H__


#ifdef __GX_SERVER__

#include <vector>
#include <unordered_map>
#include "platform.h"
#include "singleton.h"
#include "reactor.h"
#include "socket.h"
#include "peer.h"
#include "timermanager.h"
#include "reactor.h"
#include "rc.h"

GX_NS_BEGIN

class Script;
class Network;
class Context;

struct ServletException : std::exception {
    ServletException(int code) noexcept : rc(code) { }
    int rc;
};

struct CallCancelException : std::exception {
};

class NetworkInstance : public Object {
    friend class Network;
public:
    NetworkInstance(
        Network *network, const std::string &host, unsigned port,
        timeval_t timeout, timeval_t interval, std::string &ap,
        int id, const std::string &name) noexcept;

    const char *host() const noexcept {
        return _host.c_str();
    }
    unsigned port() const noexcept {
        return _port;
    }
    bool is_ap() const noexcept {
        return !_ap.empty();
    }
    const std::string &ap() const noexcept {
        return _ap;
    }
private:
    bool listen(ptr<Reactor> reactor) noexcept;
    bool connect() noexcept;
    bool on_connection(Socket *socket, int flags) noexcept;
    bool on_accept(int, unsigned, const Address&) noexcept;
    bool on_data(ptr<Peer>, Socket&, int flags) noexcept;
private:
    std::string _host;
    unsigned _port;
    timeval_t _timeout;
    timeval_t _interval;
    ptr<Connector> _connector;
    ptr<Listener> _listener;
    std::string _ap;
    weak_ptr<Peer> _peer;
    Network *_network;
    int _id;
    std::string _name;
    Address _conn_addr;
    bool _is_local;
};

class NetworkNode : public Object {
    friend class Network;
public:
    NetworkNode(unsigned id, const std::string &name) noexcept
    : _id(id), _name(name)
    { }

    unsigned id() const noexcept {
        return _id;
    }
    const char *name() const noexcept {
        return _name.c_str();
    }
    unsigned instance_count() const noexcept {
        return _instance_count;
    }
private:
    unsigned _id;
    std::string _name;
    std::vector<unsigned> _servlets;
    unsigned _instance_count;
};

class Network : public Object {
    friend class NetworkInstance;
public:
    bool init(Script *script, ptr<TimerManager> timermgr, ptr<Reactor> reactor) noexcept;
    const std::vector<ptr<NetworkNode>> &nodes() const noexcept {
        return _nodes;
    }
    int type() const noexcept {
        return _type;
    }
    unsigned id() const noexcept {
        return _id;
    }
    ptr<TimerManager> timer_manager() const noexcept {
        return _timermgr;
    }
    unsigned call_count() const noexcept {
        return _call_count;
    }
    const NetworkInstance &instance(unsigned type, unsigned index) const noexcept;
    unsigned instance_count(unsigned type) const noexcept;
    bool startup(int type, unsigned id) noexcept;
    void shutdown_servlets() noexcept;
    Peer *send(unsigned id, unsigned servlet, const INotify *req, 
               unsigned *seq = nullptr, 
               NetworkInstance *instance = nullptr) noexcept;
    void broadcast(unsigned servlet, const INotify *req) noexcept;
    void broadcast_all(unsigned servlet, const INotify *req) noexcept;
    void call(uint64_t id, unsigned servlet, IRequest *req, IResponse *rsp);
    NetworkInstance *get_instance(unsigned id, unsigned servlet) noexcept;
    NetworkInstance *get_class_instance(unsigned id, unsigned servlet) noexcept;
    bool ready() noexcept;

    bool is_local(unsigned id, unsigned servlet) noexcept {
        NetworkInstance *inst = get_instance(id, servlet);
        if (!inst) {
            return false;
        }
        return inst->_is_local;
    }
    template <typename _Message>
    typename std::enable_if<
        !std::is_void<typename _Message::response_type>::value,
        int>::type
    call(_Message &msg) {
        assert(msg.req->id());

        Obstack *pool = the_pool();
        msg.rsp = pool->construct<typename _Message::response_type>(pool);
        call(msg.req->id(), _Message::the_message_id, msg.req, msg.rsp);
        if (msg.rsp->rc >= GX_ESYS_RC && msg.rsp->rc < GX_ESYS_END) {
            throw ServletException(msg.rsp->rc);
        }
        return msg.rsp->rc;
    }
    template <typename _Message>
    typename std::enable_if<
        std::is_void<typename _Message::response_type>::value,
        bool>::type
    call(_Message &msg) {
        assert(msg.req->id());
        return send(msg.req->id(), _Message::the_message_id, msg.req);
    }

    template <typename _Message>
    void broadcast(_Message &msg) {
        broadcast(_Message::the_message_id, msg.req);
    }

    template <typename _Message>
    void send(_Message &msg) {
        send(msg.req->id(), _Message::the_message_id, msg.req);
    }

private:
    timeval_t call_timeout_handler(Context *ctx, Timer&, timeval_t) noexcept;
    void request_handler(ProtocolInfo &info, Peer *peer, Stream&) noexcept;
    void response_handler(ProtocolInfo &info, Peer *peer, Stream&) noexcept;
    NetworkInstance *get_class_instance_n(unsigned id, unsigned servlet) noexcept;

private:
    int _type;
    unsigned _id;
    unsigned _seq;
    timeval_t _rpc_timeout;
    std::vector<ptr<NetworkNode>> _nodes;
    std::vector<std::vector<NetworkInstance>> _servlets;
    std::unordered_map<unsigned, Context*> _call_map;
    ptr<TimerManager> _timermgr;
    ptr<Reactor> _reactor;
    gx_list(Peer, _entry) _connect_list;
    gx_list(Peer, _entry) _accept_list;
    unsigned _call_count;
};

GX_NS_END

#else

#endif


#endif


