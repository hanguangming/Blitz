#pragma once
#include "libgame/g_formation.h"


#include "message.h"
struct CL_FormationSave;
struct CL_FormationSaveReq : INotify {
    static constexpr const char *the_class_name = "CL_FormationSaveReq";
    static constexpr int the_message_id = CL_FORMATION_SAVE;
    static constexpr const char *the_message_name = "CL_FORMATION_SAVE";
    typedef CL_FormationSave the_message_type;
    SSCC_VECTOR(G_FormationOpt) formations;
    
    CL_FormationSaveReq(SSCC_ALLOCATOR_PARAM_DECL)
    : INotify(SSCC_ALLOCATOR_PARAM),
      formations(SSCC_VECTOR(G_FormationOpt)::allocator_type(SSCC_ALLOCATOR_PARAM))
    { }
    
    bool SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM_DECL) const override {
        if (!INotify::SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        if (!SSCC_WRITE_SIZE(SSCC_VECTOR_SIZE(this->formations))) {
            return false;
        }
        for (auto &sscc_i : this->formations) {
            if (!sscc_i.SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
                return false;
            }
        }
        return true;
    }
    
    bool SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM_DECL) override {
        if (!INotify::SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        do {
            size_t sscc_size;
            SSCC_READ_SIZE(sscc_size);
            for (size_t sscc_i = 0 ; sscc_i < sscc_size; ++sscc_i) {
                SSCC_VECTOR_EMPLACE_BACK(this->formations);
                if (!SSCC_VECTOR_BACK(this->formations).SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
                    return false;
                }
            }
        } while (0);
        return true;
    }
    
#ifdef SSCC_USE_DUMP
    void SSCC_DUMP_FUNC(unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override {
        INotify::SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("formations = ");
        SSCC_PRINT("{\n");
        ++sscc_indent;
        do {
            size_t sscc_i = 0;
            for (auto &sscc_obj : this->formations) {
                SSCC_PRINT_INDENT(sscc_indent);
                SSCC_PRINT("[%lu] = ", sscc_i++);
                SSCC_PRINT("{\n");
                ++sscc_indent;
                sscc_obj.SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
                --sscc_indent;
                SSCC_PRINT_INDENT(sscc_indent);
                SSCC_PRINT("}");
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
        lua_pushlstring(sscc_L, "formations", 10);
        lua_createtable(sscc_L, SSCC_VECTOR_SIZE(this->formations), 0);
        do {
            lua_Integer sscc_i = 0;
            for (auto &sscc_obj : this->formations) {
                lua_pushinteger(sscc_L, ++sscc_i);
                SSCC_VECTOR_BACK(this->formations);
                lua_createtable(sscc_L, 0, 0);
                sscc_obj.SSCC_TOLUA_FUNC(sscc_L, -1);
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
        lua_pushlstring(sscc_L, "formations", 10);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            for (size_t sscc_i = 1; ; ++sscc_i) {
                lua_pushinteger(sscc_L, sscc_i);
                lua_gettable(sscc_L, -2);
                if (lua_isnil(sscc_L, -1)) {
                    lua_pop(sscc_L, 1);
                    break;
                }
                SSCC_VECTOR_EMPLACE_BACK(this->formations);
                if (!SSCC_VECTOR_BACK(this->formations).SSCC_FROMLUA_FUNC(sscc_L, -1 SSCC_FROMLUA_PARAM)) {
                    goto sscc_exit;
                }
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
struct CL_FormationSaveRsp : SSCC_RESPONSE_BASE {
    static constexpr const char *the_class_name = "CL_FormationSaveRsp";
    static constexpr int the_message_id = CL_FORMATION_SAVE;
    static constexpr const char *the_message_name = "CL_FORMATION_SAVE";
    typedef CL_FormationSave the_message_type;
    
    CL_FormationSaveRsp(SSCC_ALLOCATOR_PARAM_DECL)
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
struct CL_FormationSave {
    static constexpr const char *the_class_name = "CL_FormationSave";
    static constexpr int the_message_id = CL_FORMATION_SAVE;
    static constexpr const char *the_message_name = "CL_FORMATION_SAVE";
    typedef CL_FormationSaveReq request_type;
    typedef CL_FormationSaveRsp response_type;
    
    SSCC_POINTER(request_type) req;
    SSCC_POINTER(response_type) rsp;
    
    CL_FormationSave(SSCC_MESSAGE_PARAM_DECL) : req(SSCC_CREATE(request_type)), rsp() { }
};
struct CL_FormationUse;
struct CL_FormationUseReq : INotify {
    static constexpr const char *the_class_name = "CL_FormationUseReq";
    static constexpr int the_message_id = CL_FORMATION_USE;
    static constexpr const char *the_message_name = "CL_FORMATION_USE";
    typedef CL_FormationUse the_message_type;
    SSCC_UINT8 type;
    SSCC_UINT8 index;
    
    CL_FormationUseReq(SSCC_ALLOCATOR_PARAM_DECL)
    : INotify(SSCC_ALLOCATOR_PARAM),
      type(),
      index()
    { }
    
    bool SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM_DECL) const override {
        if (!INotify::SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        SSCC_WRITE_UINT8(this->type);
        SSCC_WRITE_UINT8(this->index);
        return true;
    }
    
    bool SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM_DECL) override {
        if (!INotify::SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        SSCC_READ_UINT8(this->type);
        SSCC_READ_UINT8(this->index);
        return true;
    }
    
#ifdef SSCC_USE_DUMP
    void SSCC_DUMP_FUNC(unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override {
        INotify::SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("type = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->type, (unsigned)this->type);
        SSCC_PRINT(",\n");
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
        lua_pushlstring(sscc_L, "type", 4);
        lua_pushinteger(sscc_L, (lua_Integer)this->type);
        lua_settable(sscc_L, sscc_index);
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
struct CL_FormationUseRsp : SSCC_RESPONSE_BASE {
    static constexpr const char *the_class_name = "CL_FormationUseRsp";
    static constexpr int the_message_id = CL_FORMATION_USE;
    static constexpr const char *the_message_name = "CL_FORMATION_USE";
    typedef CL_FormationUse the_message_type;
    
    CL_FormationUseRsp(SSCC_ALLOCATOR_PARAM_DECL)
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
struct CL_FormationUse {
    static constexpr const char *the_class_name = "CL_FormationUse";
    static constexpr int the_message_id = CL_FORMATION_USE;
    static constexpr const char *the_message_name = "CL_FORMATION_USE";
    typedef CL_FormationUseReq request_type;
    typedef CL_FormationUseRsp response_type;
    
    SSCC_POINTER(request_type) req;
    SSCC_POINTER(response_type) rsp;
    
    CL_FormationUse(SSCC_MESSAGE_PARAM_DECL) : req(SSCC_CREATE(request_type)), rsp() { }
};

