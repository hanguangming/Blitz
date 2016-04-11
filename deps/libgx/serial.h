#ifndef __GX_SERIAL_H__
#define __GX_SERIAL_H__

#include <vector>
#include <string>
#include "platform.h"
#include "script.h"
#include "stream.h"
#include "obstack.h"
#include "allocator.h"
#include "context.h"
#include "log.h"

GX_NS_BEGIN

extern bool the_dump_message;

#define SSCC_VECTOR(x)              gx::obstack_vector<x>
#define SSCC_VECTOR_SIZE(x)         ((x).size())
#define SSCC_VECTOR_EMPLACE_BACK(x) x.emplace_back()
#define SSCC_VECTOR_BACK(x)         (x.back())
#define SSCC_STRING_CSTR(x)         ((x).c_str())
#define SSCC_STRING_SIZE(x)         ((x).size())

#define SSCC_ALLOCATOR_PARAM_DECL   gx::Obstack *sscc_pool = the_pool()
#define SSCC_ALLOCATOR_PARAM        sscc_pool
#define SSCC_ALLOCATOR              gx::obstack_allocator
#define SSCC_MESSAGE_PARAM_DECL     gx::Obstack *sscc_pool = the_pool()
#define SSCC_CREATE(x, ...)         sscc_pool->construct<x>(sscc_pool)
#define SSCC_POINTER(x)             x*
#define SSCC_POINTER_GET(x)         (x)
#define SSCC_POINTER_SET(x, y)      (x = y)
#define SSCC_SERIAL_PARAM_DECL      gx::Stream &sscc_stream
#define SSCC_SERIAL_PARAM           sscc_stream
#define SSCC_UNSERIAL_PARAM_DECL    gx::Stream &sscc_stream, Obstack *sscc_pool
#define SSCC_UNSERIAL_PARAM         sscc_stream, sscc_pool
#define SSCC_DUMP_PARAM_DECL        , Obstack *sscc_stream
#define SSCC_DUMP_PARAM             , sscc_stream

#define SSCC_INT8                   std::int32_t
#define SSCC_UINT8                  std::uint32_t
#define SSCC_INT16                  std::int32_t
#define SSCC_UINT16                 std::uint32_t
#define SSCC_INT32                  std::int32_t
#define SSCC_UINT32                 std::uint32_t
#define SSCC_INT64                  std::int64_t
#define SSCC_UINT64                 std::uint64_t
#define SSCC_FLOAT                  float
#define SSCC_DOUBLE                 double
#define SSCC_STRING                 gx::obstack_string
#define SSCC_WRITE_INT8(x)          (sscc_stream.write((int8_t)x))
#define SSCC_WRITE_UINT8(x)         (sscc_stream.write((uint8_t)x))
#define SSCC_WRITE_INT16(x)         (sscc_stream.write((int16_t)x))
#define SSCC_WRITE_UINT16(x)        (sscc_stream.write((uint16_t)x))
#define SSCC_WRITE_INT32(x)         (sscc_stream.write((int32_t)x))
#define SSCC_WRITE_UINT32(x)        (sscc_stream.write((uint32_t)x))
#define SSCC_WRITE_INT64(x)         (sscc_stream.write((int64_t)x))
#define SSCC_WRITE_UINT64(x)        (sscc_stream.write((uint64_t)x))
#define SSCC_WRITE_FLOAT(x)         (sscc_stream.write((float)x))
#define SSCC_WRITE_DOUBLE(x)        (sscc_stream.write((double)x))
//#define SSCC_WRITE_SIZE(x)          (sscc_stream.write_size(x))
#define SSCC_WRITE_SIZE(x)          ({SSCC_WRITE_UINT32(x), true;})
#define SSCC_WRITE_STRING(x)                         \
    do {                                             \
        size_t sscc_size = SSCC_STRING_SIZE(x);      \
        SSCC_WRITE_SIZE(sscc_size);                  \
        if (sscc_size) {                             \
            sscc_stream.write(                       \
                SSCC_STRING_CSTR(x),                 \
                sscc_size);                          \
        }                                            \
    } while (0)

#define SSCC_READ_VAR(x, s)                          \
    do {                                             \
        x = 0;                                       \
        if (sscc_stream.size() < s) {                \
            return false;                            \
        }                                            \
        sscc_stream.read(&(x), s);                   \
    } while (0)

#define SSCC_READ_INT8(x)           SSCC_READ_VAR(x, 1)
#define SSCC_READ_UINT8(x)          SSCC_READ_VAR(x, 1)
#define SSCC_READ_INT16(x)          SSCC_READ_VAR(x, 2)
#define SSCC_READ_UINT16(x)         SSCC_READ_VAR(x, 2)
#define SSCC_READ_INT32(x)          SSCC_READ_VAR(x, 4)
#define SSCC_READ_UINT32(x)         SSCC_READ_VAR(x, 4)
#define SSCC_READ_INT64(x)          SSCC_READ_VAR(x, 8)
#define SSCC_READ_UINT64(x)         SSCC_READ_VAR(x, 8)
#define SSCC_READ_FLOAT(x)          SSCC_READ_VAR(x, sizeof(float))
#define SSCC_READ_DOUBLE(x)         SSCC_READ_VAR(x, sizeof(double))
#define SSCC_READ_SIZE(x)           SSCC_READ_UINT32(x)

#define SSCC_READ_STRING(x)                          \
    do {                                             \
        size_t sscc_size;                            \
        SSCC_READ_SIZE(sscc_size);                   \
        if (sscc_size) {                             \
            if (sscc_stream.size() < sscc_size) {    \
                return false;                        \
            }                                        \
            (x).resize(sscc_size);                   \
            sscc_stream.read(                        \
                (void*)((x).data()),                 \
                sscc_size);                          \
        }                                            \
        else {                                       \
            (x).clear();                             \
        }                                            \
    } while (0)


#define SSCC_ASSERT(x)              assert(x)
#define SSCC_USE_DUMP
#define SSCC_PRINT(fmt, ...)        sscc_stream->print(fmt, ##__VA_ARGS__)
#define SSCC_PRINT_INDENT(indent)                    \
    do {                                             \
        for (unsigned i = 0; i < (indent) * 2; ++i){ \
            sscc_stream->grow1(' ');                 \
        }                                            \
    }                                                \
    while (0)

#define SSCC_USE_LUA
#define SSCC_FROMLUA_PARAM_DECL
#define SSCC_FROMLUA_PARAM

#define SSCC_DEFAULT_BASE           gx::ISerial
#define SSCC_REQUEST_BASE           gx::IRequest
#define SSCC_RESPONSE_BASE          gx::IResponse
#define SSCC_SERIAL_FUNC            serial
#define SSCC_UNSERIAL_FUNC          unserial
#define SSCC_DUMP_FUNC              dump
#define SSCC_TOLUA_FUNC             to_lua
#define SSCC_FROMLUA_FUNC           from_lua

struct ISerial : Object {
    ISerial(Obstack *pool) noexcept { }
    virtual bool serial(Stream &sscc_stream) const {
        return true;
    }
    virtual bool unserial(Stream &sscc_stream, Obstack *sscc_pool) {
        return true;
    }
    virtual void dump(unsigned, Obstack *sscc_stream) {
    }
    virtual void dump(const char *, unsigned, Obstack *sscc_stream) {
    }
    virtual void to_lua(lua_State *sscc_L, int sscc_index) {
    }
    virtual bool from_lua(lua_State *sscc_L, int sscc_index) {
        return true;
    }
};

struct INotify : ISerial {
    INotify(Obstack *pool) noexcept : ISerial(pool) { }
};

struct IRequest : INotify {
    IRequest(Obstack *pool) noexcept : INotify(pool) { }
    uint32_t id() const noexcept {
        return __id__;
    }
    void id(uint32_t value) noexcept {
        __id__ = value;
    }
    bool serial(Stream &sscc_stream) const override {
        SSCC_WRITE_INT32((SSCC_INT32)__id__);
        return true;
    }
    bool unserial(Stream &sscc_stream, Obstack *sscc_pool) override {
        SSCC_READ_INT32(__id__);
        return true;
    }
    void dump(unsigned sscc_indent, Obstack *sscc_stream) override {
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("id = %d(%x),\n", __id__, __id__);
    }
    uint32_t __id__;
};

struct IResponse : ISerial {
    IResponse(Obstack *pool) noexcept : ISerial(pool) { }
    bool read_rc(Stream &sscc_stream) {
        rc = 0;
        SSCC_READ_INT32(rc);
        return true;
    }

    bool serial(Stream &sscc_stream) const override {
        SSCC_WRITE_INT32((SSCC_INT32)rc);
        return true;
    }
    bool unserial(Stream &sscc_stream, Obstack *sscc_pool) override {
        return true;
    }
    void dump(unsigned sscc_indent, Obstack *sscc_stream) override {
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("rc = %d(%x),\n", rc, rc);
    }
    void dump(const char *, unsigned, Obstack *sscc_stream) override {
    }
    virtual void to_lua(lua_State *sscc_L, int sscc_index) {
        lua_pushlstring(sscc_L, "rc", 2);
        lua_pushinteger(sscc_L, rc);
        lua_settable(sscc_L, sscc_index);
    }
    virtual bool from_lua(lua_State *sscc_L, int sscc_index) {
        lua_pushlstring(sscc_L, "rc", 2);
        lua_gettable(sscc_L, sscc_index);
        int isnum;
        rc = lua_tointegerx(sscc_L, -1, &isnum);
        lua_pop(sscc_L, 1);
        if (!isnum) {
            return false;
        }
        return true;
    }

    int rc;
};

inline void dump_message(ISerial &msg, Obstack *pool) noexcept {
    if (the_dump_message) {
        msg.dump(nullptr, 0, pool);
        pool->grow1('\0');
        log_debug("\n%s", (char*)pool->finish());
    }
}

GX_NS_END

#endif

