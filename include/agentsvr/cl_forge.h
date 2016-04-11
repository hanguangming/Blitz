#pragma once
#include "libgame/g_forge.h"


#include "message.h"
struct CL_ForgeRefresh;
struct CL_ForgeRefreshReq : INotify {
    static constexpr const char *the_class_name = "CL_ForgeRefreshReq";
    static constexpr int the_message_id = CL_FORGE_REFRESH;
    static constexpr const char *the_message_name = "CL_FORGE_REFRESH";
    typedef CL_ForgeRefresh the_message_type;
    SSCC_UINT8 type;
    
    CL_ForgeRefreshReq(SSCC_ALLOCATOR_PARAM_DECL)
    : INotify(SSCC_ALLOCATOR_PARAM),
      type()
    { }
    
    bool SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM_DECL) const override {
        if (!INotify::SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        SSCC_WRITE_UINT8(this->type);
        return true;
    }
    
    bool SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM_DECL) override {
        if (!INotify::SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        SSCC_READ_UINT8(this->type);
        return true;
    }
    
#ifdef SSCC_USE_DUMP
    void SSCC_DUMP_FUNC(unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override {
        INotify::SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("type = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->type, (unsigned)this->type);
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
        lua_pushlstring(sscc_L, "type", 4);
        lua_pushinteger(sscc_L, (lua_Integer)this->type);
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
        lua_pushlstring(sscc_L, "type", 4);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            do {
                int isnum;
                this->type = lua_tointegerx(sscc_L, -1, &isnum);
                if (!isnum) {
                    goto sscc_exit;
                }
            } while (0);
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
struct CL_ForgeRefreshRsp : SSCC_RESPONSE_BASE {
    static constexpr const char *the_class_name = "CL_ForgeRefreshRsp";
    static constexpr int the_message_id = CL_FORGE_REFRESH;
    static constexpr const char *the_message_name = "CL_FORGE_REFRESH";
    typedef CL_ForgeRefresh the_message_type;
    
    CL_ForgeRefreshRsp(SSCC_ALLOCATOR_PARAM_DECL)
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
struct CL_ForgeRefresh {
    static constexpr const char *the_class_name = "CL_ForgeRefresh";
    static constexpr int the_message_id = CL_FORGE_REFRESH;
    static constexpr const char *the_message_name = "CL_FORGE_REFRESH";
    typedef CL_ForgeRefreshReq request_type;
    typedef CL_ForgeRefreshRsp response_type;
    
    SSCC_POINTER(request_type) req;
    SSCC_POINTER(response_type) rsp;
    
    CL_ForgeRefresh(SSCC_MESSAGE_PARAM_DECL) : req(SSCC_CREATE(request_type)), rsp() { }
};
struct CL_ForgeBuy;
struct CL_ForgeBuyReq : INotify {
    static constexpr const char *the_class_name = "CL_ForgeBuyReq";
    static constexpr int the_message_id = CL_FORGE_BUY;
    static constexpr const char *the_message_name = "CL_FORGE_BUY";
    typedef CL_ForgeBuy the_message_type;
    SSCC_UINT8 index;
    
    CL_ForgeBuyReq(SSCC_ALLOCATOR_PARAM_DECL)
    : INotify(SSCC_ALLOCATOR_PARAM),
      index()
    { }
    
    bool SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM_DECL) const override {
        if (!INotify::SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        SSCC_WRITE_UINT8(this->index);
        return true;
    }
    
    bool SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM_DECL) override {
        if (!INotify::SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        SSCC_READ_UINT8(this->index);
        return true;
    }
    
#ifdef SSCC_USE_DUMP
    void SSCC_DUMP_FUNC(unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override {
        INotify::SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("index = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->index, (unsigned)this->index);
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
        lua_pushlstring(sscc_L, "index", 5);
        lua_pushinteger(sscc_L, (lua_Integer)this->index);
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
        lua_pushlstring(sscc_L, "index", 5);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            do {
                int isnum;
                this->index = lua_tointegerx(sscc_L, -1, &isnum);
                if (!isnum) {
                    goto sscc_exit;
                }
            } while (0);
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
struct CL_ForgeBuyRsp : SSCC_RESPONSE_BASE {
    static constexpr const char *the_class_name = "CL_ForgeBuyRsp";
    static constexpr int the_message_id = CL_FORGE_BUY;
    static constexpr const char *the_message_name = "CL_FORGE_BUY";
    typedef CL_ForgeBuy the_message_type;
    
    CL_ForgeBuyRsp(SSCC_ALLOCATOR_PARAM_DECL)
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
struct CL_ForgeBuy {
    static constexpr const char *the_class_name = "CL_ForgeBuy";
    static constexpr int the_message_id = CL_FORGE_BUY;
    static constexpr const char *the_message_name = "CL_FORGE_BUY";
    typedef CL_ForgeBuyReq request_type;
    typedef CL_ForgeBuyRsp response_type;
    
    SSCC_POINTER(request_type) req;
    SSCC_POINTER(response_type) rsp;
    
    CL_ForgeBuy(SSCC_MESSAGE_PARAM_DECL) : req(SSCC_CREATE(request_type)), rsp() { }
};

