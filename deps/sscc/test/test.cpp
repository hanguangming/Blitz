#include <cstdint>
#include <string>
#include <vector>
#include <cassert>
#include <cstdio>
#include "lua.hpp"

struct ISerial {
    virtual bool serial() const {
        return true;
    }
    virtual bool unserial() {
        return true;
    }
    virtual void dump(unsigned, FILE *) {
    }
    virtual void dump(const char *, unsigned, FILE *) {
    }
    virtual void to_lua(lua_State *sscc_L, int sscc_index) {
    }
    virtual bool from_lua(lua_State *sscc_L, int sscc_index) {
    }
};
#define SSCC_INT8                   std::int8_t
#define SSCC_UINT8                  std::uint8_t
#define SSCC_INT16                  std::int16_t
#define SSCC_UINT16                 std::uint16_t
#define SSCC_INT32                  std::int32_t
#define SSCC_UINT32                 std::uint32_t
#define SSCC_INT64                  std::int64_t
#define SSCC_UINT64                 std::uint64_t
#define SSCC_FLOAT                  float
#define SSCC_DOUBLE                 double
#define SSCC_STRING                 std::string
#define SSCC_VECTOR(x)              std::vector<x>
#define SSCC_VECTOR_SIZE(x)         ((x).size())
#define SSCC_STRING_CSTR(x)         ((x).c_str())
#define SSCC_STRING_SIZE(x)         ((x).size())
#define SSCC_WRITE_INT8(x)          (1)
#define SSCC_WRITE_UINT8(x)         (1)
#define SSCC_WRITE_INT16(x)         (1)
#define SSCC_WRITE_UINT16(x)        (1)
#define SSCC_WRITE_INT32(x)         (1)
#define SSCC_WRITE_UINT32(x)        (1)
#define SSCC_WRITE_INT64(x)         (1)
#define SSCC_WRITE_UINT64(x)        (1)
#define SSCC_WRITE_FLOAT(x)         (1)
#define SSCC_WRITE_DOUBLE(x)        (1)
#define SSCC_WRITE_STRING(x)        (1)
#define SSCC_WRITE_SIZE(x)          (1)

#define SSCC_READ_INT8(x)           (1)
#define SSCC_READ_UINT8(x)          (1)
#define SSCC_READ_INT16(x)          (1)
#define SSCC_READ_UINT16(x)         (1)
#define SSCC_READ_INT32(x)          (1)
#define SSCC_READ_UINT32(x)         (1)
#define SSCC_READ_INT64(x)          (1)
#define SSCC_READ_UINT64(x)         (1)
#define SSCC_READ_FLOAT(x)          (1)
#define SSCC_READ_DOUBLE(x)         (1)
#define SSCC_READ_STRING(x)         (1)
#define SSCC_READ_SIZE(x)           (1)

#define SSCC_POINTER(x)             x*
#define SSCC_POINTER_GET(x)         (x)
#define SSCC_POINTER_SET(x, y)      (x = y)
#define SSCC_CREATE(xxx, ...)       new xxx(__VA_ARGS__)

#define SSCC_SERIAL_PARAM_DECL      
#define SSCC_SERIAL_PARAM
#define SSCC_UNSERIAL_PARAM_DECL        
#define SSCC_UNSERIAL_PARAM

#define SSCC_DUMP_PARAM_DECL        ,FILE *sscc_stream
#define SSCC_DUMP_PARAM             ,sscc_stream

#define SSCC_ASSERT(x)              assert(x)
#define SSCC_USE_DUMP
#define SSCC_PRINT(fmt, ...)        fprintf(sscc_stream, fmt, ##__VA_ARGS__)
#define SSCC_PRINT_INDENT(indent)                \
    for (unsigned i = 0; i < (indent) * 2; ++i){ \
        fputc(' ', sscc_stream);                 \
    }

#define SSCC_USE_LUA
#define SSCC_FROMLUA_PARAM_DECL
#define SSCC_FROMLUA_PARAM

#include "lua.hpp"
#include "test.h"

struct Foo {
    int a;
    int b;
};
struct Foo2 {
    Foo a;
    int b;
};

int main(int argc, char **argv) {
    Foo2 f({{0, 1}/*Foo*/, 2});
    struct_a a;
    a.a2 = A1;
    a.a3 = A3;
    a.a4 = 100;
    a.ptr = new foo2;
    a.fff = new foo;
    a.a1.push_back(1);
    a.a1.push_back(2);
    a.ary.emplace_back();
    a.ary.emplace_back();
    a.dump(nullptr, 0, stdout);
    return 0;
}


