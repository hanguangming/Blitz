#ifndef __GX_PROTOCOL_H__
#define __GX_PROTOCOL_H__

#include <unordered_map>
#include "platform.h"
#include "object.h"
#include "stream.h"
#include "serial.h"

GX_NS_BEGIN

struct ProtocolInfo {
    unsigned servlet;
    unsigned seq;
    unsigned size;
    const ISerial *message;
};

class Protocol : public Object {
public:
    Protocol() noexcept;
    void serial(ProtocolInfo &info, Stream &stream, bool is_response) noexcept;
    int unserial(ProtocolInfo &info, Stream &stream, bool is_ap) noexcept;

private:
    unsigned _state;
    unsigned _servlet;
    unsigned _seq;
    unsigned _size;
};

#ifndef __GX_SERVER_H__

class ProtoBase : public Object {
public:
    ProtoBase(unsigned id, const char *name) noexcept
    : _id(id), _name(name)
    { }

    virtual ptr<ISerial> create_resquest() noexcept = 0;
    virtual ptr<ISerial> create_response() noexcept = 0;

    unsigned id() const noexcept {
        return _id;
    }
    const char *name() const noexcept {
        return _name;
    }
private:
    unsigned _id;
    const char *_name;
};

template <typename _T, typename _Request = typename _T::request_type, typename _Response = typename _T::response_type>
class ProtoMsg : public ProtoBase {
public:
    typedef _T type;
    typedef _Request request_type;
    typedef _Response response_type;
public:
    ProtoMsg() noexcept
    : ProtoBase(type::the_message_id, type::the_message_name)
    { }

    ptr<ISerial> create_resquest() noexcept override {
        return object<request_type>();
    }
    ptr<ISerial> create_response() noexcept override {
        return object<response_type>();
    }
};

template <typename _T>
class ProtoMsg<_T, typename _T::request_type, void> : public ProtoBase {
public:
    typedef _T type;
    typedef typename _T::request_type request_type;
public:
    ProtoMsg() noexcept
    : ProtoBase(type::the_message_id, type::the_message_name)
    { }

    ptr<ISerial> create_resquest() noexcept override {
        return object<request_type>();
    }
    ptr<ISerial> create_response() noexcept override {
        return nullptr;
    }
};

class ProtoMgr : public Object, public singleton<ProtoMgr> {
    template <typename> friend class ProtoRegister;
public:
    ptr<ProtoBase> protocol(unsigned id);
private:
    void registerProto(ptr<ProtoBase> proto);
private:
    std::unordered_map<unsigned, ptr<ProtoBase>> _map;
};

template <typename _T>
class ProtoRegister {
public:
    ProtoRegister() noexcept {
        ProtoMgr::instance()->registerProto(object<ProtoMsg<_T>>());
    }
};

#define GX_PROTO_REGISTER(T) ProtoRegister<T> __proto_register_##T__()

#endif

GX_NS_END

#endif

