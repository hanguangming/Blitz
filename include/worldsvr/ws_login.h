#pragma once
#include "libgame/g_player.h"

#include "message.h"
struct WS_Login;
struct WS_LoginReq : INotify {
    static constexpr const char *the_class_name = "WS_LoginReq";
    static constexpr int the_message_id = WS_LOGIN;
    static constexpr const char *the_message_name = "WS_LOGIN";
    typedef WS_Login the_message_type;
    SSCC_UINT32 uid;
    G_PlayerInfo info;
    
    WS_LoginReq(SSCC_ALLOCATOR_PARAM_DECL)
    : INotify(SSCC_ALLOCATOR_PARAM),
      uid(),
      info(SSCC_ALLOCATOR_PARAM)
    { }
    
    bool SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM_DECL) const override {
        if (!INotify::SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        SSCC_WRITE_UINT32(this->uid);
        if (!this->info.SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        return true;
    }
    
    bool SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM_DECL) override {
        if (!INotify::SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        SSCC_READ_UINT32(this->uid);
        if (!this->info.SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        return true;
    }
    
#ifdef SSCC_USE_DUMP
    void SSCC_DUMP_FUNC(unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override {
        INotify::SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("uid = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->uid, (unsigned)this->uid);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("info = ");
        SSCC_PRINT("{\n");
        ++sscc_indent;
        this->info.SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
        --sscc_indent;
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("}");
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
        INotify::SSCC_TOLUA_FUNC(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "uid", 3);
        lua_pushinteger(sscc_L, (lua_Integer)this->uid);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "info", 4);
        lua_createtable(sscc_L, 0, 0);
        this->info.SSCC_TOLUA_FUNC(sscc_L, -1);
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
        if (!INotify::SSCC_FROMLUA_FUNC(sscc_L, sscc_index SSCC_FROMLUA_PARAM)) {
            goto sscc_exit;
        }
        lua_pushlstring(sscc_L, "uid", 3);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            do {
                int isnum;
                this->uid = lua_tointegerx(sscc_L, -1, &isnum);
                if (!isnum) {
                    goto sscc_exit;
                }
            } while (0);
        }
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "info", 4);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            if (!this->info.SSCC_FROMLUA_FUNC(sscc_L, -1 SSCC_FROMLUA_PARAM)) {
                goto sscc_exit;
            }
        }
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
struct WS_Login {
    static constexpr const char *the_class_name = "WS_Login";
    static constexpr int the_message_id = WS_LOGIN;
    static constexpr const char *the_message_name = "WS_LOGIN";
    typedef WS_LoginReq request_type;
    typedef void response_type;
    
    SSCC_POINTER(request_type) req;
    
    WS_Login(SSCC_MESSAGE_PARAM_DECL) : req(SSCC_CREATE(request_type)) { }
};

