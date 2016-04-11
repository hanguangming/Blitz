#ifndef __GX_REACTOR_H__
#define __GX_REACTOR_H__

#include <vector>
#include <map>
#include "object.h"
#include "socket.h"
#include "timeval.h"
#include "timermanager.h"

struct epoll_event;
#include <sys/select.h>

GX_NS_BEGIN

class Reactor : public Object {
    friend class Socket;
public:
    static constexpr const unsigned poll_in           = (1 << 0);
    static constexpr const unsigned poll_out          = (1 << 1);
    static constexpr const unsigned poll_err          = (1 << 2);
    static constexpr const unsigned poll_open         = (1 << 3);
    static constexpr const unsigned poll_close        = (1 << 4);

public:
    Reactor(ptr<TimerManager> timermgr, unsigned maxfds = 65536, unsigned maxevents = 128) noexcept;
    ~Reactor() noexcept;

    int loop(timeval_t tv);
    Socket *open(int fd, unsigned flags, Socket::handler_type handler) noexcept;

    unsigned maxfds() const noexcept {
        return _maxfds;
    }
private:
    bool modify(Socket *io) noexcept;
    void push() noexcept;
    void close(int fd, timeval_t linger = 0) noexcept;
    void send(Socket *socket);

    static timeval_t on_linger_timer(Socket *socket, Timer&, timeval_t) noexcept;
    static bool on_linger_data(Socket &socket, unsigned flags) noexcept;

private:
    typedef gx_list(Socket, _entry) SocketList;

    int _fd;
    unsigned _maxfds;
    unsigned _maxevents;
    struct ::epoll_event *_events;
    std::vector<ptr<Socket>> _fds;
    SocketList _sock_list;
    SocketList _send_list;
    ptr<TimerManager> _timermgr;
};

GX_NS_END

#endif



