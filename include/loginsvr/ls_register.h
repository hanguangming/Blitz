#pragma once

#include "message.h"
struct LS_Register;
struct LS_RegisterReq : ISerial {
    static constexpr const char *the_class_name = "LS_RegisterReq";
    static constexpr int the_message_id = LS_REGISTER;
    static constexpr const char *the_message_name = "LS_REGISTER";
    typedef LS_Register the_message_type;
    SSCC_STRING user;
    SSCC_STRING passwd;
    SSCC_UINT32 platform;
    SSCC_STRING nickname;
    SSCC_UINT8 side;
    
    LS_RegisterReq(SSCC_ALLOCATOR_PARAM_DECL)
    : ISerial(SSCC_ALLOCATOR_PARAM),
      user(SSCC_STRING::allocator_type(SSCC_ALLOCATOR_PARAM)),
      passwd(SSCC_STRING::allocator_type(SSCC_ALLOCATOR_PARAM)),
      platform(),
      nickname(SSCC_STRING::allocator_type(SSCC_ALLOCATOR_PARAM)),
      side()
    { }
    
    bool SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM_DECL) const override {
        if (!ISerial::SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        SSCC_WRITE_STRING(this->user);
        SSCC_WRITE_STRING(this->passwd);
        SSCC_WRITE_UINT32(this->platform);
        SSCC_WRITE_STRING(this->nickname);
        SSCC_WRITE_UINT8(this->side);
        return true;
    }
    
    bool SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM_DECL) override {
        if (!ISerial::SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        SSCC_READ_STRING(this->user);
        SSCC_READ_STRING(this->passwd);
        SSCC_READ_UINT32(this->platform);
        SSCC_READ_STRING(this->nickname);
        SSCC_READ_UINT8(this->side);
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
        SSCC_PRINT("passwd = ");
        SSCC_PRINT("\"%s\"", SSCC_STRING_CSTR(this->passwd));
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("platform = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->platform, (unsigned)this->platform);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("nickname = ");
        SSCC_PRINT("\"%s\"", SSCC_STRING_CSTR(this->nickname));
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("side = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->side, (unsigned)this->side);
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
        lua_pushlstring(sscc_L, "passwd", 6);
        lua_pushlstring(sscc_L, SSCC_STRING_CSTR(this->passwd), SSCC_STRING_SIZE(this->passwd));
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "platform", 8);
        lua_pushinteger(sscc_L, (lua_Integer)this->platform);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "nickname", 8);
        lua_pushlstring(sscc_L, SSCC_STRING_CSTR(this->nickname), SSCC_STRING_SIZE(this->nickname));
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "side", 4);
        lua_pushinteger(sscc_L, (lua_Integer)this->side);
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
        lua_pushlstring(sscc_L, "passwd", 6);
        lua_gettable(sscc_L, sscc_index);
        do {
            const char *sscc_str = lua_tostring(sscc_L, -1);
            if (!sscc_str) {
                goto sscc_exit;
            }
            this->passwd = sscc_str;
        } while (0);
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "platform", 8);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->platform = lua_tointegerx(sscc_L, -1, &isnum);
            if (!isnum) {
                goto sscc_exit;
            }
        } while (0);
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "nickname", 8);
        lua_gettable(sscc_L, sscc_index);
        do {
            const char *sscc_str = lua_tostring(sscc_L, -1);
            if (!sscc_str) {
                goto sscc_exit;
            }
            this->nickname = sscc_str;
        } while (0);
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "side", 4);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->side = lua_tointegerx(sscc_L, -1, &isnum);
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
struct LS_RegisterRsp : SSCC_RESPONSE_BASE {
    static constexpr const char *the_class_name = "LS_RegisterRsp";
    static constexpr int the_message_id = LS_REGISTER;
    static constexpr const char *the_message_name = "LS_REGISTER";
    typedef LS_Register the_message_type;
    
    LS_RegisterRsp(SSCC_ALLOCATOR_PARAM_DECL)
    : SSCC_RESPONSE_BASE(SSCC_ALLOCATOR_PARAM)
    { }
    
    bool SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM_DECL) const override {
        if (!SSCC_RESPONSE_BASE::SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        return true;
    }
    
    bool SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM_DECL) override {
        if (!SSCC_RESPONSE_BASE::SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        return true;
    }
    
#ifdef SSCC_USE_DUMP
    void SSCC_DUMP_FUNC(unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override {
        SSCC_RESPONSE_BASE::SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
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
struct LS_Register {
    static constexpr const char *the_class_name = "LS_Register";
    static constexpr int the_message_id = LS_REGISTER;
    static constexpr const char *the_message_name = "LS_REGISTER";
    typedef LS_RegisterReq request_type;
    typedef LS_RegisterRsp response_type;
    
    SSCC_POINTER(request_type) req;
    SSCC_POINTER(response_type) rsp;
    
    LS_Register(SSCC_MESSAGE_PARAM_DECL) : req(SSCC_CREATE(request_type)), rsp() { }
};

