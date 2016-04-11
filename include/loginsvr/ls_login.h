#pragma once

#include "message.h"
struct LS_LoginAccount;
struct LS_LoginAccountReq : ISerial {
    static constexpr const char *the_class_name = "LS_LoginAccountReq";
    static constexpr int the_message_id = LS_LOGIN_ACCOUNT;
    static constexpr const char *the_message_name = "LS_LOGIN_ACCOUNT";
    typedef LS_LoginAccount the_message_type;
    SSCC_STRING user;
    SSCC_STRING pwd;
    
    LS_LoginAccountReq(SSCC_ALLOCATOR_PARAM_DECL)
    : ISerial(SSCC_ALLOCATOR_PARAM),
      user(SSCC_STRING::allocator_type(SSCC_ALLOCATOR_PARAM)),
      pwd(SSCC_STRING::allocator_type(SSCC_ALLOCATOR_PARAM))
    { }
    
    bool SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM_DECL) const override {
        if (!ISerial::SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        SSCC_WRITE_STRING(this->user);
        SSCC_WRITE_STRING(this->pwd);
        return true;
    }
    
    bool SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM_DECL) override {
        if (!ISerial::SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        SSCC_READ_STRING(this->user);
        SSCC_READ_STRING(this->pwd);
        return true;
    }
    
#ifdef SSCC_USE_DUMP
    void SSCC_DUMP_FUNC(unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override {
        ISerial::SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("user = ");
        SSCC_PRINT("\"%s\"", SSCC_STRING_CSTR(this->user));
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("pwd = ");
        SSCC_PRINT("\"%s\"", SSCC_STRING_CSTR(this->pwd));
        SSCC_PRINT(",\n");
    }
    void SSCC_DUMP_FUNC(const char *sscc_name, unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override {
        if (!sscc_name) {
            sscc_name = the_class_name;
        }
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("%s = {\n", sscc_name);
        SSCC_DUMP_FUNC(sscc_indent + 1 SSCC_DUMP_PARAM);
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("}\n");
    }
#endif
    
#ifdef SSCC_USE_LUA
    void SSCC_TOLUA_FUNC(lua_State *sscc_L, int sscc_index) override {
        int sscc_top = lua_gettop(sscc_L);
        if (sscc_index < 0) {
            sscc_index = sscc_top + sscc_index + 1;
        }
        ISerial::SSCC_TOLUA_FUNC(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "user", 4);
        lua_pushlstring(sscc_L, SSCC_STRING_CSTR(this->user), SSCC_STRING_SIZE(this->user));
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "pwd", 3);
        lua_pushlstring(sscc_L, SSCC_STRING_CSTR(this->pwd), SSCC_STRING_SIZE(this->pwd));
        lua_settable(sscc_L, sscc_index);
        SSCC_ASSERT(sscc_top == lua_gettop(sscc_L));
    }
    
    bool SSCC_FROMLUA_FUNC(lua_State *sscc_L, int sscc_index SSCC_FROMLUA_PARAM_DECL) override {
        if (!lua_istable(sscc_L, sscc_index)) {
            return false;
        }
        int sscc_top = lua_gettop(sscc_L);
        if (sscc_index < 0) {
            sscc_index = sscc_top + sscc_index + 1;
        }
        if (!ISerial::SSCC_FROMLUA_FUNC(sscc_L, sscc_index SSCC_FROMLUA_PARAM)) {
            goto sscc_exit;
        }
        lua_pushlstring(sscc_L, "user", 4);
        lua_gettable(sscc_L, sscc_index);
        do {
            const char *sscc_str = lua_tostring(sscc_L, -1);
            if (!sscc_str) {
                goto sscc_exit;
            }
            this->user = sscc_str;
        } while (0);
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "pwd", 3);
        lua_gettable(sscc_L, sscc_index);
        do {
            const char *sscc_str = lua_tostring(sscc_L, -1);
            if (!sscc_str) {
                goto sscc_exit;
            }
            this->pwd = sscc_str;
        } while (0);
        lua_pop(sscc_L, 1);
        SSCC_ASSERT(sscc_top == lua_gettop(sscc_L));
        return true;
sscc_exit:
        sscc_index = lua_gettop(sscc_L);
        SSCC_ASSERT(sscc_index >= sscc_top);
        sscc_index -= sscc_top;
        if (sscc_index > 0) {
            lua_pop(sscc_L, sscc_index);
        }
        return false;
    }
#endif
};
struct LS_LoginAccountRsp : SSCC_RESPONSE_BASE {
    static constexpr const char *the_class_name = "LS_LoginAccountRsp";
    static constexpr int the_message_id = LS_LOGIN_ACCOUNT;
    static constexpr const char *the_message_name = "LS_LOGIN_ACCOUNT";
    typedef LS_LoginAccount the_message_type;
    SSCC_UINT32 uid;
    SSCC_UINT64 key;
    SSCC_STRING host;
    SSCC_UINT16 port;
    
    LS_LoginAccountRsp(SSCC_ALLOCATOR_PARAM_DECL)
    : SSCC_RESPONSE_BASE(SSCC_ALLOCATOR_PARAM),
      uid(),
      key(),
      host(SSCC_STRING::allocator_type(SSCC_ALLOCATOR_PARAM)),
      port()
    { }
    
    bool SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM_DECL) const override {
        if (!SSCC_RESPONSE_BASE::SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        SSCC_WRITE_UINT32(this->uid);
        SSCC_WRITE_UINT64(this->key);
        SSCC_WRITE_STRING(this->host);
        SSCC_WRITE_UINT16(this->port);
        return true;
    }
    
    bool SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM_DECL) override {
        if (!SSCC_RESPONSE_BASE::SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        SSCC_READ_UINT32(this->uid);
        SSCC_READ_UINT64(this->key);
        SSCC_READ_STRING(this->host);
        SSCC_READ_UINT16(this->port);
        return true;
    }
    
#ifdef SSCC_USE_DUMP
    void SSCC_DUMP_FUNC(unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override {
        SSCC_RESPONSE_BASE::SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("uid = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->uid, (unsigned)this->uid);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("key = ");
        SSCC_PRINT("%lu(0x%lx)", this->key, this->key);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("host = ");
        SSCC_PRINT("\"%s\"", SSCC_STRING_CSTR(this->host));
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("port = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->port, (unsigned)this->port);
        SSCC_PRINT(",\n");
    }
    void SSCC_DUMP_FUNC(const char *sscc_name, unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override {
        if (!sscc_name) {
            sscc_name = the_class_name;
        }
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("%s = {\n", sscc_name);
        SSCC_DUMP_FUNC(sscc_indent + 1 SSCC_DUMP_PARAM);
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("}\n");
    }
#endif
    
#ifdef SSCC_USE_LUA
    void SSCC_TOLUA_FUNC(lua_State *sscc_L, int sscc_index) override {
        int sscc_top = lua_gettop(sscc_L);
        if (sscc_index < 0) {
            sscc_index = sscc_top + sscc_index + 1;
        }
        SSCC_RESPONSE_BASE::SSCC_TOLUA_FUNC(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "uid", 3);
        lua_pushinteger(sscc_L, (lua_Integer)this->uid);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "key", 3);
        lua_pushinteger(sscc_L, (lua_Integer)this->key);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "host", 4);
        lua_pushlstring(sscc_L, SSCC_STRING_CSTR(this->host), SSCC_STRING_SIZE(this->host));
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "port", 4);
        lua_pushinteger(sscc_L, (lua_Integer)this->port);
        lua_settable(sscc_L, sscc_index);
        SSCC_ASSERT(sscc_top == lua_gettop(sscc_L));
    }
    
    bool SSCC_FROMLUA_FUNC(lua_State *sscc_L, int sscc_index SSCC_FROMLUA_PARAM_DECL) override {
        if (!lua_istable(sscc_L, sscc_index)) {
            return false;
        }
        int sscc_top = lua_gettop(sscc_L);
        if (sscc_index < 0) {
            sscc_index = sscc_top + sscc_index + 1;
        }
        if (!SSCC_RESPONSE_BASE::SSCC_FROMLUA_FUNC(sscc_L, sscc_index SSCC_FROMLUA_PARAM)) {
            goto sscc_exit;
        }
        lua_pushlstring(sscc_L, "uid", 3);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->uid = lua_tointegerx(sscc_L, -1, &isnum);
            if (!isnum) {
                goto sscc_exit;
            }
        } while (0);
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "key", 3);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->key = lua_tointegerx(sscc_L, -1, &isnum);
            if (!isnum) {
                goto sscc_exit;
            }
        } while (0);
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "host", 4);
        lua_gettable(sscc_L, sscc_index);
        do {
            const char *sscc_str = lua_tostring(sscc_L, -1);
            if (!sscc_str) {
                goto sscc_exit;
            }
            this->host = sscc_str;
        } while (0);
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "port", 4);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->port = lua_tointegerx(sscc_L, -1, &isnum);
            if (!isnum) {
                goto sscc_exit;
            }
        } while (0);
        lua_pop(sscc_L, 1);
        SSCC_ASSERT(sscc_top == lua_gettop(sscc_L));
        return true;
sscc_exit:
        sscc_index = lua_gettop(sscc_L);
        SSCC_ASSERT(sscc_index >= sscc_top);
        sscc_index -= sscc_top;
        if (sscc_index > 0) {
            lua_pop(sscc_L, sscc_index);
        }
        return false;
    }
#endif
};
struct LS_LoginAccount {
    static constexpr const char *the_class_name = "LS_LoginAccount";
    static constexpr int the_message_id = LS_LOGIN_ACCOUNT;
    static constexpr const char *the_message_name = "LS_LOGIN_ACCOUNT";
    typedef LS_LoginAccountReq request_type;
    typedef LS_LoginAccountRsp response_type;
    
    SSCC_POINTER(request_type) req;
    SSCC_POINTER(response_type) rsp;
    
    LS_LoginAccount(SSCC_MESSAGE_PARAM_DECL) : req(SSCC_CREATE(request_type)), rsp() { }
};
struct LS_LoginSession;
struct LS_LoginSessionReq : SSCC_REQUEST_BASE {
    static constexpr const char *the_class_name = "LS_LoginSessionReq";
    static constexpr int the_message_id = LS_LOGIN_SESSION;
    static constexpr const char *the_message_name = "LS_LOGIN_SESSION";
    typedef LS_LoginSession the_message_type;
    SSCC_UINT32 uid;
    SSCC_UINT64 key;
    
    LS_LoginSessionReq(SSCC_ALLOCATOR_PARAM_DECL)
    : SSCC_REQUEST_BASE(SSCC_ALLOCATOR_PARAM),
      uid(),
      key()
    { }
    
    bool SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM_DECL) const override {
        if (!SSCC_REQUEST_BASE::SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        SSCC_WRITE_UINT32(this->uid);
        SSCC_WRITE_UINT64(this->key);
        return true;
    }
    
    bool SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM_DECL) override {
        if (!SSCC_REQUEST_BASE::SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        SSCC_READ_UINT32(this->uid);
        SSCC_READ_UINT64(this->key);
        return true;
    }
    
#ifdef SSCC_USE_DUMP
    void SSCC_DUMP_FUNC(unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override {
        SSCC_REQUEST_BASE::SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("uid = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->uid, (unsigned)this->uid);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("key = ");
        SSCC_PRINT("%lu(0x%lx)", this->key, this->key);
        SSCC_PRINT(",\n");
    }
    void SSCC_DUMP_FUNC(const char *sscc_name, unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override {
        if (!sscc_name) {
            sscc_name = the_class_name;
        }
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("%s = {\n", sscc_name);
        SSCC_DUMP_FUNC(sscc_indent + 1 SSCC_DUMP_PARAM);
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("}\n");
    }
#endif
    
#ifdef SSCC_USE_LUA
    void SSCC_TOLUA_FUNC(lua_State *sscc_L, int sscc_index) override {
        int sscc_top = lua_gettop(sscc_L);
        if (sscc_index < 0) {
            sscc_index = sscc_top + sscc_index + 1;
        }
        SSCC_REQUEST_BASE::SSCC_TOLUA_FUNC(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "uid", 3);
        lua_pushinteger(sscc_L, (lua_Integer)this->uid);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "key", 3);
        lua_pushinteger(sscc_L, (lua_Integer)this->key);
        lua_settable(sscc_L, sscc_index);
        SSCC_ASSERT(sscc_top == lua_gettop(sscc_L));
    }
    
    bool SSCC_FROMLUA_FUNC(lua_State *sscc_L, int sscc_index SSCC_FROMLUA_PARAM_DECL) override {
        if (!lua_istable(sscc_L, sscc_index)) {
            return false;
        }
        int sscc_top = lua_gettop(sscc_L);
        if (sscc_index < 0) {
            sscc_index = sscc_top + sscc_index + 1;
        }
        if (!SSCC_REQUEST_BASE::SSCC_FROMLUA_FUNC(sscc_L, sscc_index SSCC_FROMLUA_PARAM)) {
            goto sscc_exit;
        }
        lua_pushlstring(sscc_L, "uid", 3);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->uid = lua_tointegerx(sscc_L, -1, &isnum);
            if (!isnum) {
                goto sscc_exit;
            }
        } while (0);
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "key", 3);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->key = lua_tointegerx(sscc_L, -1, &isnum);
            if (!isnum) {
                goto sscc_exit;
            }
        } while (0);
        lua_pop(sscc_L, 1);
        SSCC_ASSERT(sscc_top == lua_gettop(sscc_L));
        return true;
sscc_exit:
        sscc_index = lua_gettop(sscc_L);
        SSCC_ASSERT(sscc_index >= sscc_top);
        sscc_index -= sscc_top;
        if (sscc_index > 0) {
            lua_pop(sscc_L, sscc_index);
        }
        return false;
    }
#endif
};
struct LS_LoginSessionRsp : SSCC_RESPONSE_BASE {
    static constexpr const char *the_class_name = "LS_LoginSessionRsp";
    static constexpr int the_message_id = LS_LOGIN_SESSION;
    static constexpr const char *the_message_name = "LS_LOGIN_SESSION";
    typedef LS_LoginSession the_message_type;
    SSCC_UINT64 key;
    
    LS_LoginSessionRsp(SSCC_ALLOCATOR_PARAM_DECL)
    : SSCC_RESPONSE_BASE(SSCC_ALLOCATOR_PARAM),
      key()
    { }
    
    bool SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM_DECL) const override {
        if (!SSCC_RESPONSE_BASE::SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        SSCC_WRITE_UINT64(this->key);
        return true;
    }
    
    bool SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM_DECL) override {
        if (!SSCC_RESPONSE_BASE::SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        SSCC_READ_UINT64(this->key);
        return true;
    }
    
#ifdef SSCC_USE_DUMP
    void SSCC_DUMP_FUNC(unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override {
        SSCC_RESPONSE_BASE::SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("key = ");
        SSCC_PRINT("%lu(0x%lx)", this->key, this->key);
        SSCC_PRINT(",\n");
    }
    void SSCC_DUMP_FUNC(const char *sscc_name, unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override {
        if (!sscc_name) {
            sscc_name = the_class_name;
        }
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("%s = {\n", sscc_name);
        SSCC_DUMP_FUNC(sscc_indent + 1 SSCC_DUMP_PARAM);
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("}\n");
    }
#endif
    
#ifdef SSCC_USE_LUA
    void SSCC_TOLUA_FUNC(lua_State *sscc_L, int sscc_index) override {
        int sscc_top = lua_gettop(sscc_L);
        if (sscc_index < 0) {
            sscc_index = sscc_top + sscc_index + 1;
        }
        SSCC_RESPONSE_BASE::SSCC_TOLUA_FUNC(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "key", 3);
        lua_pushinteger(sscc_L, (lua_Integer)this->key);
        lua_settable(sscc_L, sscc_index);
        SSCC_ASSERT(sscc_top == lua_gettop(sscc_L));
    }
    
    bool SSCC_FROMLUA_FUNC(lua_State *sscc_L, int sscc_index SSCC_FROMLUA_PARAM_DECL) override {
        if (!lua_istable(sscc_L, sscc_index)) {
            return false;
        }
        int sscc_top = lua_gettop(sscc_L);
        if (sscc_index < 0) {
            sscc_index = sscc_top + sscc_index + 1;
        }
        if (!SSCC_RESPONSE_BASE::SSCC_FROMLUA_FUNC(sscc_L, sscc_index SSCC_FROMLUA_PARAM)) {
            goto sscc_exit;
        }
        lua_pushlstring(sscc_L, "key", 3);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->key = lua_tointegerx(sscc_L, -1, &isnum);
            if (!isnum) {
                goto sscc_exit;
            }
        } while (0);
        lua_pop(sscc_L, 1);
        SSCC_ASSERT(sscc_top == lua_gettop(sscc_L));
        return true;
sscc_exit:
        sscc_index = lua_gettop(sscc_L);
        SSCC_ASSERT(sscc_index >= sscc_top);
        sscc_index -= sscc_top;
        if (sscc_index > 0) {
            lua_pop(sscc_L, sscc_index);
        }
        return false;
    }
#endif
};
struct LS_LoginSession {
    static constexpr const char *the_class_name = "LS_LoginSession";
    static constexpr int the_message_id = LS_LOGIN_SESSION;
    static constexpr const char *the_message_name = "LS_LOGIN_SESSION";
    typedef LS_LoginSessionReq request_type;
    typedef LS_LoginSessionRsp response_type;
    
    SSCC_POINTER(request_type) req;
    SSCC_POINTER(response_type) rsp;
    
    LS_LoginSession(SSCC_MESSAGE_PARAM_DECL) : req(SSCC_CREATE(request_type)), rsp() { }
};

