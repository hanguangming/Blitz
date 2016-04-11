#pragma once
#include "libgame/g_chat.h"


#include "message.h"
struct AS_SystemNotify;
struct AS_SystemNotifyReq : INotify {
    static constexpr const char *the_class_name = "AS_SystemNotifyReq";
    static constexpr int the_message_id = AS_SYSTEM_NOTIFY;
    static constexpr const char *the_message_name = "AS_SYSTEM_NOTIFY";
    typedef AS_SystemNotify the_message_type;
    SSCC_UINT32 msg_id;
    G_ChatPlayerInfo player;
    SSCC_VECTOR(SSCC_UINT32) params;
    
    AS_SystemNotifyReq(SSCC_ALLOCATOR_PARAM_DECL)
    : INotify(SSCC_ALLOCATOR_PARAM),
      msg_id(),
      player(SSCC_ALLOCATOR_PARAM),
      params(SSCC_VECTOR(SSCC_UINT32)::allocator_type(SSCC_ALLOCATOR_PARAM))
    { }
    
    bool SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM_DECL) const override {
        if (!INotify::SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        SSCC_WRITE_UINT32(this->msg_id);
        if (!this->player.SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        if (!SSCC_WRITE_SIZE(SSCC_VECTOR_SIZE(this->params))) {
            return false;
        }
        for (auto &sscc_i : this->params) {
            SSCC_WRITE_UINT32(sscc_i);
        }
        return true;
    }
    
    bool SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM_DECL) override {
        if (!INotify::SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        SSCC_READ_UINT32(this->msg_id);
        if (!this->player.SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        do {
            size_t sscc_size;
            SSCC_READ_SIZE(sscc_size);
            for (size_t sscc_i = 0 ; sscc_i < sscc_size; ++sscc_i) {
                SSCC_VECTOR_EMPLACE_BACK(this->params);
                SSCC_READ_UINT32(SSCC_VECTOR_BACK(this->params));
            }
        } while (0);
        return true;
    }
    
#ifdef SSCC_USE_DUMP
    void SSCC_DUMP_FUNC(unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override {
        INotify::SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("msg_id = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->msg_id, (unsigned)this->msg_id);
        SSCC_PRINT(",\n");
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
        SSCC_PRINT("params = ");
        SSCC_PRINT("{\n");
        ++sscc_indent;
        do {
            size_t sscc_i = 0;
            for (auto &sscc_obj : this->params) {
                SSCC_PRINT_INDENT(sscc_indent);
                SSCC_PRINT("[%lu] = ", sscc_i++);
                SSCC_PRINT("%u(0x%x)", (unsigned)sscc_obj, (unsigned)sscc_obj);
                SSCC_PRINT(",\n");
            }
        } while (0);
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
        lua_pushlstring(sscc_L, "msg_id", 6);
        lua_pushinteger(sscc_L, (lua_Integer)this->msg_id);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "player", 6);
        lua_createtable(sscc_L, 0, 0);
        this->player.SSCC_TOLUA_FUNC(sscc_L, -1);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "params", 6);
        lua_createtable(sscc_L, SSCC_VECTOR_SIZE(this->params), 0);
        do {
            lua_Integer sscc_i = 0;
            for (auto &sscc_obj : this->params) {
                lua_pushinteger(sscc_L, ++sscc_i);
                SSCC_VECTOR_BACK(this->params);
                lua_pushinteger(sscc_L, (lua_Integer)sscc_obj);
                lua_settable(sscc_L, -3);
            }
        } while (0);
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
        lua_pushlstring(sscc_L, "msg_id", 6);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            do {
                int isnum;
                this->msg_id = lua_tointegerx(sscc_L, -1, &isnum);
                if (!isnum) {
                    goto sscc_exit;
                }
            } while (0);
        }
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "player", 6);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            if (!this->player.SSCC_FROMLUA_FUNC(sscc_L, -1 SSCC_FROMLUA_PARAM)) {
                goto sscc_exit;
            }
        }
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "params", 6);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            for (size_t sscc_i = 1; ; ++sscc_i) {
                lua_pushinteger(sscc_L, sscc_i);
                lua_gettable(sscc_L, -2);
                if (lua_isnil(sscc_L, -1)) {
                    lua_pop(sscc_L, 1);
                    break;
                }
                SSCC_VECTOR_EMPLACE_BACK(this->params);
                do {
                    int isnum;
                    SSCC_VECTOR_BACK(this->params) = lua_tointegerx(sscc_L, -1, &isnum);
                    if (!isnum) {
                        goto sscc_exit;
                    }
                } while (0);
                lua_pop(sscc_L, 1);
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
struct AS_SystemNotify {
    static constexpr const char *the_class_name = "AS_SystemNotify";
    static constexpr int the_message_id = AS_SYSTEM_NOTIFY;
    static constexpr const char *the_message_name = "AS_SYSTEM_NOTIFY";
    typedef AS_SystemNotifyReq request_type;
    typedef void response_type;
    
    SSCC_POINTER(request_type) req;
    
    AS_SystemNotify(SSCC_MESSAGE_PARAM_DECL) : req(SSCC_CREATE(request_type)) { }
};

