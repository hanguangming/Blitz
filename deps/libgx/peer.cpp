#include "peer.h"
#include "socket.h"
#include "reactor.h"
#include "servlet.h"
#include "log.h"
#include "timermanager.h"
#include "coroutine.h"

GX_NS_BEGIN

Peer::Peer() noexcept : _is_ap(false), peer_object()
{ }

Peer::Peer(bool is_ap) noexcept : _is_ap(is_ap), peer_object()
{ }

Peer::~Peer() noexcept {
    if (peer_object) {
        peer_object->on_peer_close();
        peer_object = nullptr;
    }
    Context *ctx;
    while ((ctx = _call_list.front())) {
        log_debug("peer close cancal call");
        ctx->call_timedout();
    }

    gx_list(Peer, _entry)::remove(this);
}


void Peer::close(timeval_t linger) noexcept {
    if (_socket) {
        _socket->close(linger);
    }
}

bool Peer::send(unsigned servlet_id, unsigned seq, const IResponse *rsp) noexcept {
    ProtocolInfo info;
    info.servlet = servlet_id;
    info.seq = seq;
    info.message = rsp;
    _protocol.serial(info, _socket->output(), true);
    _socket->send();
    return true;
}

bool Peer::send(unsigned servlet_id, unsigned seq, const INotify *req) noexcept {
    ProtocolInfo info;
    info.servlet = servlet_id;
    info.seq = seq;
    info.message = req;
    _protocol.serial(info, _socket->output(), false);
    _socket->send();
    return true;
}

bool Peer::send(const Stream &stream) noexcept {
    _socket->output().load(stream);
    _socket->send();
    return true;
}

bool Peer::shutdown(bool read, bool write) noexcept {
    _socket->shutdown(read, write);
    return true;
}

GX_NS_END


