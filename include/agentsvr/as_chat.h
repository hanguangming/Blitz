#pragma once
#include "libgame/g_chat.h"


#include "message.h"
struct AS_Chat;
struct AS_ChatReq : INotify {
    static constexpr const char *the_class_name = "AS_ChatReq";
    static constexpr int the_message_id = AS_CHAT;
    static constexpr const char *the_message_name = "AS_CHAT";
    typedef AS_Chat the_message_type;
    G_ChatPlayerInfo player;
    SSCC_UINT8 channel;
    SSCC_UINT32 magic;
    SSCC_STRING msg;
    
    AS_ChatReq(SSCC_ALLOCATOR_PARAM_DECL)
    : INotify(SSCC_ALLOCATOR_PARAM),
      player(SSCC_ALLOCATOR_PARAM),
      channel(),
      magic(),
      msg(SSCC_STRING::allocator_type(SSCC_ALLOCATOR_PARAM))
    { }
    
    bool SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM_DECL) const override {
        if (!INotify::SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        if (!this->player.SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        SSCC_WRITE_UINT8(this->channel);
        SSCC_WRITE_UINT32(this->magic);
        SSCC_WRITE_STRING(this->msg);
        return true;
    }
    
    bool SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM_DECL) override {
        if (!INotify::SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        if (!this->player.SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        SSCC_READ_UINT8(this->channel);
        SSCC_READ_UINT32(this->magic);
        SSCC_READ_STRING(this->msg);
        return true;
    }
    
#ifdef SSCC_USE_DUMP
    void SSCC_DUMP_FUNC(unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override {
        INotify::SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("player = ");
        SSCC_PRINT("{\n");
        ++sscc_indent;
        this->player.SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
        --sscc_indent;
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("}");
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("channel = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->channel, (unsigned)this->channel);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("magic = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->magic, (unsigned)this->magic);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("msg = ");
        SSCC_PRINT("\"%s\"", SSCC_STRING_CSTR(this->msg));
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
        lua_pushlstring(sscc_L, "player", 6);
        lua_createtable(sscc_L, 0, 0);
        this->player.SSCC_TOLUA_FUNC(sscc_L, -1);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "channel", 7);
        lua_pushinteger(sscc_L, (lua_Integer)this->channel);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "magic", 5);
        lua_pushinteger(sscc_L, (lua_Integer)this->magic);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "msg", 3);
        lua_pushlstring(sscc_L, SSCC_STRING_CSTR(this->msg), SSCC_STRING_SIZE(this->msg));
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
        lua_pushlstring(sscc_L, "player", 6);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            if (!this->player.SSCC_FROMLUA_FUNC(sscc_L, -1 SSCC_FROMLUA_PARAM)) {
                goto sscc_exit;
            }
        }
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "channel", 7);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            do {
                int isnum;
                this->channel = lua_tointegerx(sscc_L, -1, &isnum);
                if (!isnum) {
                    goto sscc_exit;
                }
            } while (0);
        }
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "magic", 5);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            do {
                int isnum;
                this->magic = lua_tointegerx(sscc_L, -1, &isnum);
                if (!isnum) {
                    goto sscc_exit;
                }
            } while (0);
        }
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "msg", 3);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            do {
                const char *sscc_str = lua_tostring(sscc_L, -1);
                if (!sscc_str) {
                    goto sscc_exit;
                }
                this->msg = sscc_str;
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
struct AS_Chat {
    static constexpr const char *the_class_name = "AS_Chat";
    static constexpr int the_message_id = AS_CHAT;
    static constexpr const char *the_message_name = "AS_CHAT";
    typedef AS_ChatReq request_type;
    typedef void response_type;
    
    SSCC_POINTER(request_type) req;
    
    AS_Chat(SSCC_MESSAGE_PARAM_DECL) : req(SSCC_CREATE(request_type)) { }
};

