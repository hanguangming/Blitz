#ifndef __GX_PEER_H__
#define __GX_PEER_H__

#include "object.h"
#include "memory.h"
#include "stream.h"
#include "serial.h"
#include "protocol.h"
#include "socket.h"
#include "context.h"
#include "list.h"
#include "log.h"

GX_NS_BEGIN

class Network;

struct PeerObject {
    friend class Peer;
protected:
    virtual void on_peer_close() = 0;
};

class Peer : public WeakableObject {
    friend class NetworkInstance;
    friend class Network;
public:
    Peer() noexcept;
    Peer(bool is_ap) noexcept;
    ~Peer() noexcept;
    bool on_data(Stream &stream) noexcept;
    int unserial(Stream &stream, IResponse *rsp) noexcept;
    void close(timeval_t linger = 0) noexcept;
    Stream &input() noexcept {
        return _socket->input();
    }
    Stream &output() noexcept {
        return _socket->output();
    }
    Network *network() const noexcept {
        return _network;
    }
    int unserial(ProtocolInfo &info, Stream &stream) noexcept {
        return _protocol.unserial(info, stream, _is_ap);
    }
    bool is_ap() const noexcept {
        return _is_ap;
    }
    bool send(unsigned servlet_id, unsigned seq, const IResponse *rsp) noexcept;
    bool send(unsigned servlet_id, unsigned seq, const INotify *req) noexcept;
    bool send(unsigned servlet_id, const INotify *req) noexcept {
        return send(servlet_id, 0, req);
    }
    bool send(const Stream &stream) noexcept;
    bool shutdown(bool read, bool write) noexcept;
private:
    typedef gx_list(Context, _entry) ctx_list_t;
private:
    ctx_list_t _call_list;
    weak_ptr<Socket> _socket;
    Network *_network;
    Protocol _protocol;
    bool _is_ap;
    list_entry _entry;
public:
    PeerObject *peer_object;

};

GX_NS_END

#endif

