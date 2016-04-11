#ifndef __GX_SOCKET_H__
#define __GX_SOCKET_H__

#include "platform.h"

#include <netdb.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include "object.h"
#include "stream.h"
#include "list.h"
#include "timermanager.h"
#include "memory.h"
#include "io.h"

GX_NS_BEGIN

class Reactor;

/* Address */
class Address {
public:
    static constexpr const socklen_t length = sizeof(sockaddr_in);

    operator const struct sockaddr*() const noexcept {
        return (struct sockaddr*)&_addr;
    }
    operator struct sockaddr*()  noexcept {
        return (struct sockaddr*)&_addr;
    }
    operator const struct sockaddr_in*() const noexcept  {
        return &_addr;
    }
    operator struct sockaddr_in*() noexcept  {
        return &_addr;
    }
    const char *host() const noexcept  {
        return inet_ntoa(_addr.sin_addr);
    }
    unsigned port() const noexcept {
        return ntohs(_addr.sin_port);
    }
    bool resolve(const char *host, unsigned port) noexcept;
private:
    struct sockaddr_in _addr;
};

/* Socket */
class Socket : public WeakableObject, public IO {
    friend class ReactorBase;
    friend class Reactor;
public:
    typedef std::function<bool(Socket&, unsigned flags)> handler_type;
public:
    Socket() noexcept;

    fd_t fd() const noexcept {
        return _fd;
    }
    unsigned flags() const noexcept {
        return _flags;
    }
    void flags(unsigned value) noexcept;
    Reactor *reactor() const noexcept {
        return _reactor;
    }
    handler_type &handler() noexcept {
        return _handler;
    }
    void handler(handler_type handler) noexcept {
        _handler = std::move(handler);
    }
    Stream &input() noexcept {
        return _input;
    }
    Stream &output() noexcept {
        return _output;
    }
    bool shutdown(bool read, bool write) noexcept;
    int load() noexcept;
    int send() noexcept;
    int push() noexcept;
    int read(void *buf, size_t size) noexcept override;
    int write(const char *buf, size_t size) noexcept override;
    static void close_fd(fd_t fd) noexcept;
    void block(bool) noexcept;
    bool block() const noexcept;
    void nodelay(bool) noexcept;
    bool nodelay() const noexcept;
    void close(timeval_t linger) noexcept;
    void close() noexcept override {
        close(0);
    }

protected:
    fd_t _fd;
    unsigned _flags;
    Reactor *_reactor;
    handler_type _handler;
    Stream _input;
    Stream _output;
    weak_ptr<Timer> _timer;
public:
    list_entry _entry;
};

class Connector : public Object {
public:
    typedef std::function<bool(Socket*, unsigned flags)> handler_type;

public:
    Connector(Address &addr, ptr<Reactor> reactor, ptr<TimerManager> timermgr, timeval_t timeout, timeval_t interval, handler_type handler) noexcept;
    ~Connector() noexcept;

    ptr<Reactor> reactor() const noexcept;
    ptr<TimerManager> timer_manager() const noexcept {
        return _timermgr;
    }
    timeval_t timeout() const noexcept {
        return _timeout;
    }
    void timeout(timeval_t value) noexcept {
        _timeout = value;
    }
    timeval_t interval() const noexcept {
        return _interval;
    }
    void interval(timeval_t value) noexcept {
        _interval = value;
    }
    timeval_t connect_time() const noexcept {
        return _conntime;
    }

    bool connect();
    void close();

private:
    void close_timer();
    timeval_t timer_handler(bool inprogress, Timer&, timeval_t);
    timeval_t connect_ready(Timer&, timeval_t);
    bool connect_handler(Socket&, unsigned);
    bool do_connect();
    bool do_emit(int) noexcept;

private:
    weak_ptr<Socket> _socket;
    ptr<Reactor> _reactor;
    ptr<TimerManager> _timermgr;
    Address _addr;
    timeval_t _timeout;
    timeval_t _interval;
    timeval_t _conntime;
    weak_ptr<Timer> _timer;
    bool _emitting;
    handler_type _handler;
};

class Listener : public Object {
public:
    static constexpr const unsigned default_backlog = 128;
    typedef std::function<bool(int, unsigned, const Address&)> handler_type;
public:
    Listener(Address &addr, ptr<Reactor> reactor, handler_type handler) noexcept;
    ~Listener() noexcept;

    const Address &addr() const noexcept {
        return _addr;
    }
    ptr<Reactor> reactor() const noexcept;
    void close() noexcept;
    bool listen() noexcept;
    Socket *socket() noexcept {
        if (!_socket) {
            return nullptr;
        }
        return _socket.get();
    }
private:
    bool accept_handler(Socket&, unsigned type) noexcept;
    bool do_emit(unsigned flags, const Address &addr) noexcept;

private:
    weak_ptr<Socket> _socket;
    Address _addr;
    ptr<Reactor> _reactor;
    handler_type _handler;
    unsigned _backlog;
};

GX_NS_END

#endif

