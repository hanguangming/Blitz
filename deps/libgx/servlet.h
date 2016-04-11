#ifndef __GX_SERVLET_H__
#define __GX_SERVLET_H__

#ifdef __GX_SERVER__

#include <unordered_map>
#include <exception>
#include "platform.h"
#include "singleton.h"
#include "serial.h"
#include "peer.h"
#include "network.h"
#include "context.h"
#include "network.h"
#include "log.h"

GX_NS_BEGIN

class ServletBase : public Object {
    friend class ServletManager;
public:
    ServletBase(unsigned id, const char *name, bool use_coroutine = true) noexcept
    : _id(id), 
      _name(name), 
      _use_coroutine(use_coroutine), 
      _dump_msg(false),
      _short_link(false),
      _linger()
    { }

    unsigned id() const noexcept {
        return _id;
    }
    const char *name() const noexcept {
        return _name;
    }
    bool use_coroutine() const noexcept {
        return _use_coroutine;
    }

    virtual ISerial *create_request(Stream &stream, unsigned size, Obstack *pool) = 0;
    virtual IResponse *create_response(Obstack *pool) = 0;

    virtual int execute(ISerial *req, IResponse *rsp) = 0;

    template <typename _Message>
    typename std::enable_if<
        !std::is_void<typename _Message::response_type>::value,
        int>::type
    call(_Message &msg) {
        return the_context()->network()->call(msg);
    }
    template <typename _Message>
    typename std::enable_if<
        std::is_void<typename _Message::response_type>::value,
        bool>::type
    call(_Message &msg) {
        return the_context()->network()->call(msg);
    }
    void broadcast(INotify *notify) {
        the_context()->network()->broadcast(_id, notify);
    }
    bool send(INotify *notify) {
        Peer *peer = the_context()->peer();
        if (!peer) {
            return false;
        }
        assert(peer->is_ap());
        if (!peer->send(_id, 0, notify)) {
            return false;
        }
        return true;
    }
    bool dump_msg() const noexcept {
        return _dump_msg || the_dump_message;
    }
    void dump_msg(bool value) noexcept {
        _dump_msg = value;
    }
    void short_link(bool value, timeval_t linger) noexcept {
        _short_link = value;
        _linger = linger;
    }
protected:
    static void reg(ptr<ServletBase> servlet) noexcept;
private:
    unsigned _id;
    const char *_name;
    bool _use_coroutine;
    bool _dump_msg;
    bool _short_link;
    timeval_t _linger;
};

template <typename _T, typename _Request = typename _T::request_type, typename _Response = typename _T::response_type>
class Servlet : public ServletBase {
public:
    typedef _T type;
    typedef _Request request_type;
    typedef _Response response_type;
public:
    Servlet() noexcept
    : ServletBase(type::the_message_id, type::the_message_name)
    { }

    ISerial *create_request(Stream &stream, unsigned size, Obstack *pool) override {
        request_type *req = pool->construct<request_type>(pool);
        size_t tmp = stream.size();
        if (!req->unserial(stream, pool)) {
            log_error("unserial protocol %s failed.", request_type::the_message_name);
            return nullptr;
        }
        if ((tmp - stream.size()) != size) {
            return nullptr;
        }
        return req;
    }
    IResponse *create_response(Obstack *pool) override {
        return pool->construct<response_type>(pool);
    }

    int execute(ISerial *req, IResponse *rsp) override {
        return (rsp->rc = execute(static_cast<request_type*>(req), static_cast<response_type*>(rsp)));
    }
    virtual int execute(request_type *req, response_type *rsp) = 0;
};

template <typename _T>
class Servlet<_T, typename _T::request_type, void> : public ServletBase {
public:
    typedef _T type;
    typedef typename _T::request_type request_type;
public:
    Servlet() noexcept
    : ServletBase(type::the_message_id, type::the_message_name)
    { }

    ISerial *create_request(Stream &stream, unsigned size, Obstack *pool) override {
        request_type *req = pool->construct<request_type>(pool);
        size_t tmp = stream.size();
        if (!req->unserial(stream, pool)) {
            log_error("unserial protocol %s failed.", request_type::the_message_name);
            return nullptr;
        }
        if ((tmp - stream.size()) != size) {
            return nullptr;
        }
        return req;
    }
    IResponse *create_response(Obstack *pool) override {
        return nullptr;
    }

    int execute(ISerial *req, IResponse *rsp) override {
        return execute(static_cast<request_type*>(req));
    }
    virtual int execute(request_type *req) = 0;
};

class ServletManager : public Object, public singleton<ServletManager> {
    template <typename> friend class ServletRegister;
public:
    void execute(unsigned servlet_id, unsigned seq, unsigned size, Peer *peer) noexcept;
    void execute(unsigned servlet_id, ISerial *req, IResponse *rsp) noexcept;
    void registerServlet(ptr<ServletBase> servlet, bool use_coroutine, const char *file, size_t line);
private:
    static void routine(void*) noexcept;
    void execute(Context *ctx);
private:
    std::unordered_map<unsigned, ptr<ServletBase>> _map;
};

template <typename _T>
class ServletRegister {
public:
    ServletRegister(bool use_coroutine, const char *file, size_t line) noexcept {
        ServletManager::instance()->registerServlet(object<_T>(), use_coroutine, file, line);
    }
};

GX_NS_END

#define GX_SERVLET_REGISTER(T, USE_CO) \
static __attribute__((constructor)) void __servlet_register_##T##__() { \
    ServletManager::instance()->registerServlet(object<T>(), USE_CO, __FILE__, __LINE__); \
}

//static ServletRegister<T> __servlet_register_##T##__(USE_CO, __FILE__, __LINE__);

#endif
#endif
