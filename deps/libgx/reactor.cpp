#include "reactor.h"
#include "log.h"

#include <time.h>
#include <sys/epoll.h>
#include <sys/socket.h>
#include <errno.h>
#include <netinet/tcp.h>
#include <fcntl.h>
#include <sys/types.h>
#include <unistd.h>

GX_NS_BEGIN

/* Reactor */
Reactor::Reactor(ptr<TimerManager> timermgr, unsigned maxfds, unsigned maxevents) noexcept
: _maxfds(maxfds), _maxevents(maxevents), _timermgr(timermgr)
{
    _fds.resize(maxfds);
    _events = (struct ::epoll_event *)std::malloc(sizeof(struct ::epoll_event) * _maxevents);
    if ((_fd = epoll_create(maxfds)) < 0) {
        log_die("epoll create failed");
    }
}

Reactor::~Reactor() noexcept {
    if (fd_valid(_fd)) {
        Socket::close_fd(_fd);
    }
    if (_events) {
        std::free(_events);
    }
}

void Reactor::push() noexcept {
    weak_ptr<Socket> socket;
    while ((socket = _send_list.pop_front())) {
        if (socket->push() < 0) {
            if (socket->_handler(*socket, poll_err) < 0) {
                if (socket) {
                    close(socket->fd());
                    continue;
                }
            }
        }
        _sock_list.push_front(socket);
        if (socket->_timer && !socket->_output.size()) {
            shutdown(socket->fd(), SHUT_WR);
        }
    }
}

void Reactor::send(Socket *socket) {
    if (socket->_reactor == this) {
        SocketList::remove(socket);
        _send_list.push_front(socket);
    }
}

Socket *Reactor::open(int fd, unsigned flags, Socket::handler_type handler) noexcept {
    if (!fd_valid(fd) || (unsigned)fd >= maxfds()) {
        return nullptr;
    }

    if (_fds[fd]) {
        return nullptr;
    }

    int n;
    n = ::fcntl(_fd, F_GETFL);
    if (n < 0) {
        return nullptr;
    }
    n |= O_NONBLOCK;
    ::fcntl(fd, F_SETFL, n);

    n = 1;
    setsockopt(fd, IPPROTO_TCP, TCP_NODELAY, &n, sizeof(n));

    struct epoll_event event;
    event.data.fd = fd;
    event.events = EPOLLET | EPOLLHUP | EPOLLRDHUP;

    if (flags & poll_in) {
        event.events |= EPOLLIN;
    }

    if (flags & poll_out) {
        event.events |= EPOLLOUT;
    }

    if (flags & poll_err) {
        event.events |= EPOLLERR;
    }

    if (epoll_ctl(_fd, EPOLL_CTL_ADD, fd, &event) < 0) {
        return nullptr;
    }

    object<Socket> socket;
    socket->_fd = fd;
    socket->_handler = handler;
    socket->_flags = flags;
    socket->_reactor = this;
    _fds[socket->fd()] = socket;
    _sock_list.push_front(socket);
    return socket;
}

bool Reactor::on_linger_data(Socket &socket, unsigned flags) noexcept {
    if (flags & Reactor::poll_close) {
        Socket::close_fd(socket.fd());
        if (socket._timer) {
            socket._timer->close();
        }
        return false;
    }
    if (flags & Reactor::poll_err) {
        return false;
    }
    if (flags & Reactor::poll_in) {
        char buf[8192];
        while (1) {
            int n = ::read(socket.fd(), buf, sizeof(buf));
            if (gx_likely(n > 0)) {
                continue;
            }
            else if (gx_likely(n < 0)) {
                if (gx_likely(errno == EAGAIN)) {
                    break;
                }
                else if (gx_likely(errno == EINTR)) {
                    continue;
                }
                else {
                    return false;
                }
            }
            else {
                return false;
            }
        }
    }
    return true;
}

timeval_t Reactor::on_linger_timer(Socket *socket, Timer&, timeval_t) noexcept {
    socket->_timer = nullptr;
    socket->close();
    return 0;
}

void Reactor::close(int fd, timeval_t linger) noexcept {
    if (!fd_valid(fd) || (unsigned)fd >= maxfds()) {
        return;
    }

    Socket *socket = _fds[fd];
    if (!socket) {
        return;
    }
    if (!linger) {
        socket->_reactor = nullptr;
        epoll_ctl(_fd, EPOLL_CTL_DEL, fd, nullptr);
        socket->_handler(*socket, poll_close);
        SocketList::remove(socket);
        _fds[fd] = nullptr;
        return;
    }
    socket->_timer = _timermgr->schedule(linger, std::bind(on_linger_timer, socket, _1, _2));
    socket->handler(std::bind(on_linger_data, _1, _2));
    socket->flags(-1);
}

bool Reactor::modify(Socket *socket) noexcept {
    if (!fd_valid(socket->fd()) || (unsigned)socket->fd() >= maxfds()) {
        return false;
    }
    if (socket->_reactor != this) {
        return false;
    }
    if (socket != _fds[socket->fd()]) {
        return false;
    }

    unsigned flags = socket->flags();
    struct epoll_event event;
    event.data.fd = socket->fd();
    event.events = EPOLLET | EPOLLHUP | EPOLLRDHUP;

    if (flags & poll_in) {
        event.events |= EPOLLIN;
    }

    if (flags & poll_out) {
        event.events |= EPOLLOUT;
    }

    if (flags & poll_err) {
        event.events |= EPOLLERR;
    }

    if (epoll_ctl(_fd, EPOLL_CTL_MOD, socket->fd(), &event) < 0) {
        return false;
    }
    return true;
}

int Reactor::loop(timeval_t timeout) {
    int nfds, flags;
    struct epoll_event *event;
    weak_ptr<Socket> socket;

    push();
    timeval_t cur = adjust_time();
    if (timeout <= cur) {
        return 0;
    }

again:
    nfds = epoll_wait(_fd, _events, _maxevents, timeout - cur);
    if (gx_unlikely(nfds == -1)) {
        if (gx_likely(errno == EINTR)) {
            goto again;
        }
        return -errno;
    } else if (gx_likely(nfds > 0)) {
        adjust_time();
        for (event = _events; nfds--; event++) {
            socket = _fds[event->data.fd].get();
            flags = 0;
            if (event->events & (EPOLLIN | EPOLLRDHUP | EPOLLRDHUP)) {
                flags |= poll_in;
            }
            if (event->events & EPOLLOUT) {
                flags |= poll_out;
            }
            if (event->events & EPOLLERR) {
                flags |= poll_err;
            }
            if (!socket->_handler(*socket, flags)) {
                if (socket) {
                    close(socket->fd());
                }
            }
        }
    }
    return 0;
}

GX_NS_END

