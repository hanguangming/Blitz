#include "socket.h"
#include "rc.h"
#include "reactor.h"
#include "log.h"

#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <netinet/tcp.h>
#include <cstdio>

GX_NS_BEGIN

/* Address */
bool Address::resolve(const char *host, unsigned port) noexcept {
    struct ::addrinfo hints, *ai;
    int error;

    char buf[128];
    sprintf(buf, "%u", port);

    if (host && !*host) {
        host = nullptr;
    }

    memset(&hints, 0, sizeof(struct ::addrinfo));
    hints.ai_family = AF_INET;
    hints.ai_socktype = 0;
    hints.ai_flags = AI_PASSIVE;
    hints.ai_protocol = IPPROTO_TCP;

    error = ::getaddrinfo(host, buf, &hints, &ai);
    if (error != 0) {
        return false;
    }

    if (!ai) {
        return false;
    }

    memcpy(&_addr, ai->ai_addr, sizeof(struct sockaddr_in));
    freeaddrinfo(ai);

    return true;
}

/* Socket */
Socket::Socket() noexcept : _fd(GX_FD_INVALID_VALUE), _flags(), _reactor()
{ }

int Socket::read(void *buf, size_t size) noexcept {
    char *p = (char *)buf;
    int n = 0;

    while (1) {
        n = ::read(_fd, p, size);
        //log_debug("socket %d read %d bytes.", _fd, n);
        if (gx_likely(n > 0)) {
            break;
        }
        else if (gx_likely(n < 0)) {
            if (gx_likely(errno == EAGAIN)) {
                return 0;
            }
            else if (gx_likely(errno == EINTR)) {
                continue;
            }
            else {
                return -errno;
            }
        }
        else {
            return -GX_ECLOSED;
        }
    }
#if 0
    p = (char*)buf;
    for (int i = 0; i < count; ++i) {
        fprintf(stderr, "%02x ", *p++);
    }
#endif
    return n;
}

bool Socket::shutdown(bool read, bool write) noexcept {
    int value = _flags;
    if (read) {
        value &= ~Reactor::poll_in;
    }
    if (write) {
        value &= ~Reactor::poll_out;
    }
    if (_reactor) {
        flags(value);
    }
    return true;
}

int Socket::write(const char *buf, size_t size) noexcept {
    const char *p = (const char *)buf;
    int n = 0;
    while (1) {
        n = ::write(_fd, p, size);
        //log_debug("socket %d write %d bytes.", _fd, n);
        if (gx_likely(n > 0)) {
            break;
        }
        else if (gx_likely(n < 0)) {
            if (gx_likely(errno == EAGAIN)) {
                return 0;
            }
            else if (gx_likely(errno == EINTR)) {
                continue;
            }
            else {
                return -errno;
            }
        }
        else {
            return -GX_ECLOSED;
        }
    }
    return n;
}

void Socket::close(timeval_t linger) noexcept {
    if (_reactor && fd_valid(_fd)) {
        _reactor->close(_fd, linger);
    }
}

void Socket::close_fd(fd_t fd) noexcept {
    if (!fd_valid(fd)) {
        return;
    }
    while (1) {
        if (gx_likely(!::close(fd))) {
            return;
        }
        if (errno == EINTR) {
            continue;
        }
        return;
    }
}

void Socket::block(bool value) noexcept {
    int n;
    n = ::fcntl(_fd, F_GETFL);
    if (n < 0) {
        return;
    }

    if (value) {
        n &= ~O_NONBLOCK;
    } else {
        n |= O_NONBLOCK;
    }

    ::fcntl(_fd, F_SETFL, n);
}

bool Socket::block() const noexcept {
    int n = ::fcntl(_fd, F_GETFL);
    if (n < 0) {
        return n;
    }
    return !(n & O_NONBLOCK);
}

void Socket::nodelay(bool value) noexcept {
    int nodelay = value ? 1 : 0;
    setsockopt(_fd, IPPROTO_TCP, TCP_NODELAY, &nodelay, sizeof(nodelay));
}

bool Socket::nodelay() const noexcept {
    int nodelay = 0;
    socklen_t len = sizeof(nodelay);
    getsockopt(_fd, IPPROTO_TCP, TCP_NODELAY, &nodelay, &len);
    return nodelay;
}

int Socket::load() noexcept {
    int n = _input.load(*this);
    if (n < 0) {
        return n;
    }
    return _input.size();
}

int Socket::send() noexcept {
    if (_reactor) {
        _reactor->send(this);
    }
    return 0;
}

int Socket::push() noexcept {
    return _output.save(*this);
}

void Socket::flags(unsigned value) noexcept {
    if (_flags != value) {
        _flags = value;
        if (_reactor) {
            _reactor->modify(this);
        }
    }
}

/* Connector */
Connector::Connector(Address &addr, ptr<Reactor> reactor, ptr<TimerManager> timermgr, timeval_t timeout, timeval_t interval, handler_type handler) noexcept
: _handler(std::move(handler))
{
    _addr = addr;
    _timeout = timeout;
    _interval = interval;
    _timermgr = timermgr;
    _reactor = reactor;
    _emitting = false;
}

Connector::~Connector() noexcept {
    close();
}

inline bool Connector::do_emit(int type) noexcept {
    return _handler(_socket, type);
}

timeval_t Connector::timer_handler(bool inprogress, Timer&, timeval_t) {
    if (inprogress) {
        if (!do_emit(Reactor::poll_err)) {
            close();
            return 0;
        }
    }
    do_connect();
    return 0;
}

timeval_t Connector::connect_ready(Timer&, timeval_t) {
    do_emit(Reactor::poll_out);
    _socket = nullptr;
    close();
    return 0;
}

bool Connector::connect_handler(Socket &socket, unsigned type) {
    int n;
    socklen_t len;

    if (type & (Reactor::poll_out | Reactor::poll_err)) {
        if (_timer) {
            _timer->close();
        }

        len = sizeof(int);
        if (getsockopt(_socket->fd(), SOL_SOCKET, SO_ERROR, &n, &len) >= 0) {
            if (n || (type & Reactor::poll_err)) {
                if (do_emit(Reactor::poll_err)) {
                    if (_interval) {
                        _timer = _timermgr->schedule_abs(_conntime + _interval, std::bind(&Connector::timer_handler, this, false, _1, _2));
                    }
                }
            } else {
                _timer = _timermgr->schedule_abs(_conntime, std::bind(&Connector::connect_ready, this, _1, _2));
                return true;
            }
        }
        return false;
    }
    if (type & Reactor::poll_close) {
        Socket::close_fd(socket.fd());
    }
    return true;
}

bool Connector::do_connect() {
    int n;
    close();
    _conntime = gettimeofday();

    int fd;
    if (!fd_valid(fd = ::socket(AF_INET, SOCK_STREAM, 0))) {
        return false;
    }

    if (!(_socket = _reactor->open(fd, Reactor::poll_out | Reactor::poll_err, std::bind(&Connector::connect_handler, this, _1, _2)))) {
        return false;
    }

    if (!do_emit(Reactor::poll_open)) {
        close();
        return false;
    }

again:
    n = ::connect(_socket->fd(), _addr, Address::length);
    if (n < 0) {
        switch (errno) {
        case EINTR:
            goto again;
        case ECONNREFUSED:
            if (!do_emit(Reactor::poll_err)) {
                close();
                return false;
            }
            close();
            if (_interval) {
                _timer = _timermgr->schedule_abs(_conntime + _interval, std::bind(&Connector::timer_handler, this, false, _1, _2));
                return true;
            }
            return false;
        case EINPROGRESS:
            if (_timeout) {
                _timer = _timermgr->schedule_abs(_conntime + _timeout, std::bind(&Connector::timer_handler, this, true, _1, _2));
            }
            return true;
        default:
            close();
            return false;
        }
    }

    return true;
}

bool Connector::connect() {
    if (_timer || _socket) {
        return true;
    }
    return do_connect();
}

void Connector::close() {
    if (_socket) {
        _socket->close();
    }
    if (_timer) {
        _timer->close();
    }
}

ptr<Reactor> Connector::reactor() const noexcept {
    return _reactor;
}

/* Listener */
Listener::Listener(Address &addr, ptr<Reactor> reactor, handler_type handler) noexcept
: _socket(), _handler(std::move(handler))
{
    _addr = addr;
    _reactor = reactor;
    _backlog = default_backlog;
}

Listener::~Listener() noexcept {
    close();
}

bool Listener::accept_handler(Socket&, unsigned type) noexcept {
    if (type & Reactor::poll_err) {
        _handler(_socket->fd(), Reactor::poll_err, _addr);
        return false;
    }

    if (type & Reactor::poll_in) {
        Address addr;
        while (1) {
            socklen_t len = Address::length;
            int fd = ::accept(_socket->fd(), addr, &len);
            if (fd < 0) {
                switch (errno) {
                case EAGAIN:
                    return true;
                case EINTR:
                    continue;
                default:
                    _handler(_socket->fd(), Reactor::poll_err, _addr);
                    return false;
                }
            }
            if (!_handler(fd, Reactor::poll_in, addr)) {
                return false;
            }
        }
    }
    return true;
}

bool Listener::listen() noexcept {
    if (_socket) {
        return true;
    }

    fd_t fd = ::socket(AF_INET, SOCK_STREAM, 0);
    if (!fd_valid(fd)) {
        return false;
    }
    int n = 1;
    if (::setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &n, sizeof(int))) {
        Socket::close_fd(fd);
        return false;
    }
    if (::bind(fd, _addr, Address::length)) {
        Socket::close_fd(fd);
        return false;
    }

    if (::listen(fd, _backlog)) {
        Socket::close_fd(fd);
        return false;
    }
    if (!(_socket = _reactor->open(fd, Reactor::poll_in | Reactor::poll_err, std::bind(&Listener::accept_handler, this, _1, _2)))) {
        return false;
    }
    if (!_handler(fd, Reactor::poll_open, _addr)) {
        close();
        return false;
    }

    return true;
}

void Listener::close() noexcept {
    if (_socket) {
        _socket->close();
    }
}

ptr<Reactor> Listener::reactor() const noexcept {
    return _reactor;
}

GX_NS_END



