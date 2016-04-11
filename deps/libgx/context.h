#ifndef __GX_CONTEXT_H__
#define __GX_CONTEXT_H__

#include "object.h"
#include "memory.h"
#include "transaction.h"
#include "timermanager.h"
#include "serial.h"
#include "list.h"
#include "obstack.h"

GX_NS_BEGIN

class Coroutine;
class ServletBase;
class Peer;
class Network;

enum {
    GX_CALL_OK,
    GX_CALL_TIMEDOUT,
    GX_CALL_CANCEL,
    GX_CALL_UNKNOWN,
};

class ContextBase : public Object {
    friend class CoManager;
public:
    bool running() const noexcept;
protected:
    Coroutine *co() const noexcept {
        return _co;
    }
private:
    Coroutine *_co;
};

class Context : public ContextBase {
    friend class Peer;
    friend class Network;
    friend class ServletManager;
public:
    Context() noexcept;
    ~Context() noexcept;

    Network *network() const noexcept {
        return _network;
    }
    const weak_ptr<Peer> &peer() const noexcept {
        return _peer;
    }
    ServletBase *servlet() const noexcept {
        return _servlet;
    }
    unsigned seq() const noexcept {
        return _seq;
    }
    Obstack *pool() noexcept {
        if (!_pool) {
            _pool = object<Obstack>();
        }
        return _pool;
    }
    virtual bool begin(Network *network, Peer *peer) noexcept;
    virtual bool commit() noexcept;
    virtual void rollback(bool fail) noexcept;
    virtual void finish() noexcept;
    static std::function<ptr<Context>()> factory;

    void call_ok() noexcept;
    void call_cancel() noexcept;
    void call_timedout() noexcept;
    void call_yield() noexcept;
    int call_result() const noexcept {
        return _call_result;
    }
    void sleep(timeval_t time) noexcept;
protected:
    virtual void clear() noexcept;
private:
    list_entry _entry;
    Network *_network;
    weak_ptr<Peer> _peer;
    ServletBase *_servlet;
    unsigned _seq;
    size_t _size;
    weak_ptr<Timer> _timer;
    int _call_result;
    ptr<Obstack> _pool;
};

Context *the_context() noexcept;
inline Obstack *the_pool() noexcept {
    return the_context()->pool();
}

GX_NS_END

#endif

