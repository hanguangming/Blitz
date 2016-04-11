#pragma once
#include "libgame/g_bag.h"
#include "libgame/g_train.h"
#include "libgame/g_value.h"
#include "libgame/g_soldier.h"


#include "message.h"
struct DB_Train;
struct DB_TrainReq : SSCC_REQUEST_BASE {
    static constexpr const char *the_class_name = "DB_TrainReq";
    static constexpr int the_message_id = DB_TRAIN;
    static constexpr const char *the_message_name = "DB_TRAIN";
    typedef DB_Train the_message_type;
    SSCC_VECTOR(G_ValueOpt) value_opts;
    SSCC_VECTOR(G_BagItemOpt) item_opts;
    SSCC_VECTOR(G_TrainExpireOpt) train_opts;
    SSCC_VECTOR(G_SoldierValueOpt) soldier_value_opts;
    
    DB_TrainReq(SSCC_ALLOCATOR_PARAM_DECL)
    : SSCC_REQUEST_BASE(SSCC_ALLOCATOR_PARAM),
      value_opts(SSCC_VECTOR(G_ValueOpt)::allocator_type(SSCC_ALLOCATOR_PARAM)),
      item_opts(SSCC_VECTOR(G_BagItemOpt)::allocator_type(SSCC_ALLOCATOR_PARAM)),
      train_opts(SSCC_VECTOR(G_TrainExpireOpt)::allocator_type(SSCC_ALLOCATOR_PARAM)),
      soldier_value_opts(SSCC_VECTOR(G_SoldierValueOpt)::allocator_type(SSCC_ALLOCATOR_PARAM))
    { }
    
    bool SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM_DECL) const override {
        if (!SSCC_REQUEST_BASE::SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        if (!SSCC_WRITE_SIZE(SSCC_VECTOR_SIZE(this->value_opts))) {
            return false;
        }
        for (auto &sscc_i : this->value_opts) {
            if (!sscc_i.SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
                return false;
            }
        }
        if (!SSCC_WRITE_SIZE(SSCC_VECTOR_SIZE(this->item_opts))) {
            return false;
        }
        for (auto &sscc_i : this->item_opts) {
            if (!sscc_i.SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
                return false;
            }
        }
        if (!SSCC_WRITE_SIZE(SSCC_VECTOR_SIZE(this->train_opts))) {
            return false;
        }
        for (auto &sscc_i : this->train_opts) {
            if (!sscc_i.SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
                return false;
            }
        }
        if (!SSCC_WRITE_SIZE(SSCC_VECTOR_SIZE(this->soldier_value_opts))) {
            return false;
        }
        for (auto &sscc_i : this->soldier_value_opts) {
            if (!sscc_i.SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
                return false;
            }
        }
        return true;
    }
    
    bool SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM_DECL) override {
        if (!SSCC_REQUEST_BASE::SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        do {
            size_t sscc_size;
            SSCC_READ_SIZE(sscc_size);
            for (size_t sscc_i = 0 ; sscc_i < sscc_size; ++sscc_i) {
                SSCC_VECTOR_EMPLACE_BACK(this->value_opts);
                if (!SSCC_VECTOR_BACK(this->value_opts).SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
                    return false;
                }
            }
        } while (0);
        do {
            size_t sscc_size;
            SSCC_READ_SIZE(sscc_size);
            for (size_t sscc_i = 0 ; sscc_i < sscc_size; ++sscc_i) {
                SSCC_VECTOR_EMPLACE_BACK(this->item_opts);
                if (!SSCC_VECTOR_BACK(this->item_opts).SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
                    return false;
                }
            }
        } while (0);
        do {
            size_t sscc_size;
            SSCC_READ_SIZE(sscc_size);
            for (size_t sscc_i = 0 ; sscc_i < sscc_size; ++sscc_i) {
                SSCC_VECTOR_EMPLACE_BACK(this->train_opts);
                if (!SSCC_VECTOR_BACK(this->train_opts).SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
                    return false;
                }
            }
        } while (0);
        do {
            size_t sscc_size;
            SSCC_READ_SIZE(sscc_size);
            for (size_t sscc_i = 0 ; sscc_i < sscc_size; ++sscc_i) {
                SSCC_VECTOR_EMPLACE_BACK(this->soldier_value_opts);
                if (!SSCC_VECTOR_BACK(this->soldier_value_opts).SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
                    return false;
                }
            }
        } while (0);
        return true;
    }
    
#ifdef SSCC_USE_DUMP
    void SSCC_DUMP_FUNC(unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override {
        SSCC_REQUEST_BASE::SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("value_opts = ");
        SSCC_PRINT("{\n");
        ++sscc_indent;
        do {
            size_t sscc_i = 0;
            for (auto &sscc_obj : this->value_opts) {
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
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("item_opts = ");
        SSCC_PRINT("{\n");
        ++sscc_indent;
        do {
            size_t sscc_i = 0;
            for (auto &sscc_obj : this->item_opts) {
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
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("train_opts = ");
        SSCC_PRINT("{\n");
        ++sscc_indent;
        do {
            size_t sscc_i = 0;
            for (auto &sscc_obj : this->train_opts) {
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
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("soldier_value_opts = ");
        SSCC_PRINT("{\n");
        ++sscc_indent;
        do {
            size_t sscc_i = 0;
            for (auto &sscc_obj : this->soldier_value_opts) {
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
        SSCC_REQUEST_BASE::SSCC_TOLUA_FUNC(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "value_opts", 10);
        lua_createtable(sscc_L, SSCC_VECTOR_SIZE(this->value_opts), 0);
        do {
            lua_Integer sscc_i = 0;
            for (auto &sscc_obj : this->value_opts) {
                lua_pushinteger(sscc_L, ++sscc_i);
                SSCC_VECTOR_BACK(this->value_opts);
                lua_createtable(sscc_L, 0, 0);
                sscc_obj.SSCC_TOLUA_FUNC(sscc_L, -1);
                lua_settable(sscc_L, -3);
            }
        } while (0);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "item_opts", 9);
        lua_createtable(sscc_L, SSCC_VECTOR_SIZE(this->item_opts), 0);
        do {
            lua_Integer sscc_i = 0;
            for (auto &sscc_obj : this->item_opts) {
                lua_pushinteger(sscc_L, ++sscc_i);
                SSCC_VECTOR_BACK(this->item_opts);
                lua_createtable(sscc_L, 0, 0);
                sscc_obj.SSCC_TOLUA_FUNC(sscc_L, -1);
                lua_settable(sscc_L, -3);
            }
        } while (0);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "train_opts", 10);
        lua_createtable(sscc_L, SSCC_VECTOR_SIZE(this->train_opts), 0);
        do {
            lua_Integer sscc_i = 0;
            for (auto &sscc_obj : this->train_opts) {
                lua_pushinteger(sscc_L, ++sscc_i);
                SSCC_VECTOR_BACK(this->train_opts);
                lua_createtable(sscc_L, 0, 0);
                sscc_obj.SSCC_TOLUA_FUNC(sscc_L, -1);
                lua_settable(sscc_L, -3);
            }
        } while (0);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "soldier_value_opts", 18);
        lua_createtable(sscc_L, SSCC_VECTOR_SIZE(this->soldier_value_opts), 0);
        do {
            lua_Integer sscc_i = 0;
            for (auto &sscc_obj : this->soldier_value_opts) {
                lua_pushinteger(sscc_L, ++sscc_i);
                SSCC_VECTOR_BACK(this->soldier_value_opts);
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
        if (!SSCC_REQUEST_BASE::SSCC_FROMLUA_FUNC(sscc_L, sscc_index SSCC_FROMLUA_PARAM)) {
            goto sscc_exit;
        }
        lua_pushlstring(sscc_L, "value_opts", 10);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            for (size_t sscc_i = 1; ; ++sscc_i) {
                lua_pushinteger(sscc_L, sscc_i);
                lua_gettable(sscc_L, -2);
                if (lua_isnil(sscc_L, -1)) {
                    lua_pop(sscc_L, 1);
                    break;
                }
                SSCC_VECTOR_EMPLACE_BACK(this->value_opts);
                if (!SSCC_VECTOR_BACK(this->value_opts).SSCC_FROMLUA_FUNC(sscc_L, -1 SSCC_FROMLUA_PARAM)) {
                    goto sscc_exit;
                }
                lua_pop(sscc_L, 1);
            }
        }
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "item_opts", 9);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            for (size_t sscc_i = 1; ; ++sscc_i) {
                lua_pushinteger(sscc_L, sscc_i);
                lua_gettable(sscc_L, -2);
                if (lua_isnil(sscc_L, -1)) {
                    lua_pop(sscc_L, 1);
                    break;
                }
                SSCC_VECTOR_EMPLACE_BACK(this->item_opts);
                if (!SSCC_VECTOR_BACK(this->item_opts).SSCC_FROMLUA_FUNC(sscc_L, -1 SSCC_FROMLUA_PARAM)) {
                    goto sscc_exit;
                }
                lua_pop(sscc_L, 1);
            }
        }
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "train_opts", 10);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            for (size_t sscc_i = 1; ; ++sscc_i) {
                lua_pushinteger(sscc_L, sscc_i);
                lua_gettable(sscc_L, -2);
                if (lua_isnil(sscc_L, -1)) {
                    lua_pop(sscc_L, 1);
                    break;
                }
                SSCC_VECTOR_EMPLACE_BACK(this->train_opts);
                if (!SSCC_VECTOR_BACK(this->train_opts).SSCC_FROMLUA_FUNC(sscc_L, -1 SSCC_FROMLUA_PARAM)) {
                    goto sscc_exit;
                }
                lua_pop(sscc_L, 1);
            }
        }
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "soldier_value_opts", 18);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            for (size_t sscc_i = 1; ; ++sscc_i) {
                lua_pushinteger(sscc_L, sscc_i);
                lua_gettable(sscc_L, -2);
                if (lua_isnil(sscc_L, -1)) {
                    lua_pop(sscc_L, 1);
                    break;
                }
                SSCC_VECTOR_EMPLACE_BACK(this->soldier_value_opts);
                if (!SSCC_VECTOR_BACK(this->soldier_value_opts).SSCC_FROMLUA_FUNC(sscc_L, -1 SSCC_FROMLUA_PARAM)) {
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
struct DB_TrainRsp : SSCC_RESPONSE_BASE {
    static constexpr const char *the_class_name = "DB_TrainRsp";
    static constexpr int the_message_id = DB_TRAIN;
    static constexpr const char *the_message_name = "DB_TRAIN";
    typedef DB_Train the_message_type;
    
    DB_TrainRsp(SSCC_ALLOCATOR_PARAM_DECL)
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
struct DB_Train {
    static constexpr const char *the_class_name = "DB_Train";
    static constexpr int the_message_id = DB_TRAIN;
    static constexpr const char *the_message_name = "DB_TRAIN";
    typedef DB_TrainReq request_type;
    typedef DB_TrainRsp response_type;
    
    SSCC_POINTER(request_type) req;
    SSCC_POINTER(response_type) rsp;
    
    DB_Train(SSCC_MESSAGE_PARAM_DECL) : req(SSCC_CREATE(request_type)), rsp() { }
};
struct DB_TrainCancel;
struct DB_TrainCancelReq : SSCC_REQUEST_BASE {
    static constexpr const char *the_class_name = "DB_TrainCancelReq";
    static constexpr int the_message_id = DB_TRAIN_CANCEL;
    static constexpr const char *the_message_name = "DB_TRAIN_CANCEL";
    typedef DB_TrainCancel the_message_type;
    SSCC_VECTOR(G_ValueOpt) value_opts;
    SSCC_VECTOR(G_TrainExpireOpt) train_opts;
    
    DB_TrainCancelReq(SSCC_ALLOCATOR_PARAM_DECL)
    : SSCC_REQUEST_BASE(SSCC_ALLOCATOR_PARAM),
      value_opts(SSCC_VECTOR(G_ValueOpt)::allocator_type(SSCC_ALLOCATOR_PARAM)),
      train_opts(SSCC_VECTOR(G_TrainExpireOpt)::allocator_type(SSCC_ALLOCATOR_PARAM))
    { }
    
    bool SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM_DECL) const override {
        if (!SSCC_REQUEST_BASE::SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        if (!SSCC_WRITE_SIZE(SSCC_VECTOR_SIZE(this->value_opts))) {
            return false;
        }
        for (auto &sscc_i : this->value_opts) {
            if (!sscc_i.SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
                return false;
            }
        }
        if (!SSCC_WRITE_SIZE(SSCC_VECTOR_SIZE(this->train_opts))) {
            return false;
        }
        for (auto &sscc_i : this->train_opts) {
            if (!sscc_i.SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
                return false;
            }
        }
        return true;
    }
    
    bool SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM_DECL) override {
        if (!SSCC_REQUEST_BASE::SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        do {
            size_t sscc_size;
            SSCC_READ_SIZE(sscc_size);
            for (size_t sscc_i = 0 ; sscc_i < sscc_size; ++sscc_i) {
                SSCC_VECTOR_EMPLACE_BACK(this->value_opts);
                if (!SSCC_VECTOR_BACK(this->value_opts).SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
                    return false;
                }
            }
        } while (0);
        do {
            size_t sscc_size;
            SSCC_READ_SIZE(sscc_size);
            for (size_t sscc_i = 0 ; sscc_i < sscc_size; ++sscc_i) {
                SSCC_VECTOR_EMPLACE_BACK(this->train_opts);
                if (!SSCC_VECTOR_BACK(this->train_opts).SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
                    return false;
                }
            }
        } while (0);
        return true;
    }
    
#ifdef SSCC_USE_DUMP
    void SSCC_DUMP_FUNC(unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override {
        SSCC_REQUEST_BASE::SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("value_opts = ");
        SSCC_PRINT("{\n");
        ++sscc_indent;
        do {
            size_t sscc_i = 0;
            for (auto &sscc_obj : this->value_opts) {
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
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("train_opts = ");
        SSCC_PRINT("{\n");
        ++sscc_indent;
        do {
            size_t sscc_i = 0;
            for (auto &sscc_obj : this->train_opts) {
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
        SSCC_REQUEST_BASE::SSCC_TOLUA_FUNC(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "value_opts", 10);
        lua_createtable(sscc_L, SSCC_VECTOR_SIZE(this->value_opts), 0);
        do {
            lua_Integer sscc_i = 0;
            for (auto &sscc_obj : this->value_opts) {
                lua_pushinteger(sscc_L, ++sscc_i);
                SSCC_VECTOR_BACK(this->value_opts);
                lua_createtable(sscc_L, 0, 0);
                sscc_obj.SSCC_TOLUA_FUNC(sscc_L, -1);
                lua_settable(sscc_L, -3);
            }
        } while (0);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "train_opts", 10);
        lua_createtable(sscc_L, SSCC_VECTOR_SIZE(this->train_opts), 0);
        do {
            lua_Integer sscc_i = 0;
            for (auto &sscc_obj : this->train_opts) {
                lua_pushinteger(sscc_L, ++sscc_i);
                SSCC_VECTOR_BACK(this->train_opts);
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
        if (!SSCC_REQUEST_BASE::SSCC_FROMLUA_FUNC(sscc_L, sscc_index SSCC_FROMLUA_PARAM)) {
            goto sscc_exit;
        }
        lua_pushlstring(sscc_L, "value_opts", 10);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            for (size_t sscc_i = 1; ; ++sscc_i) {
                lua_pushinteger(sscc_L, sscc_i);
                lua_gettable(sscc_L, -2);
                if (lua_isnil(sscc_L, -1)) {
                    lua_pop(sscc_L, 1);
                    break;
                }
                SSCC_VECTOR_EMPLACE_BACK(this->value_opts);
                if (!SSCC_VECTOR_BACK(this->value_opts).SSCC_FROMLUA_FUNC(sscc_L, -1 SSCC_FROMLUA_PARAM)) {
                    goto sscc_exit;
                }
                lua_pop(sscc_L, 1);
            }
        }
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "train_opts", 10);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            for (size_t sscc_i = 1; ; ++sscc_i) {
                lua_pushinteger(sscc_L, sscc_i);
                lua_gettable(sscc_L, -2);
                if (lua_isnil(sscc_L, -1)) {
                    lua_pop(sscc_L, 1);
                    break;
                }
                SSCC_VECTOR_EMPLACE_BACK(this->train_opts);
                if (!SSCC_VECTOR_BACK(this->train_opts).SSCC_FROMLUA_FUNC(sscc_L, -1 SSCC_FROMLUA_PARAM)) {
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
struct DB_TrainCancelRsp : SSCC_RESPONSE_BASE {
    static constexpr const char *the_class_name = "DB_TrainCancelRsp";
    static constexpr int the_message_id = DB_TRAIN_CANCEL;
    static constexpr const char *the_message_name = "DB_TRAIN_CANCEL";
    typedef DB_TrainCancel the_message_type;
    
    DB_TrainCancelRsp(SSCC_ALLOCATOR_PARAM_DECL)
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
struct DB_TrainCancel {
    static constexpr const char *the_class_name = "DB_TrainCancel";
    static constexpr int the_message_id = DB_TRAIN_CANCEL;
    static constexpr const char *the_message_name = "DB_TRAIN_CANCEL";
    typedef DB_TrainCancelReq request_type;
    typedef DB_TrainCancelRsp response_type;
    
    SSCC_POINTER(request_type) req;
    SSCC_POINTER(response_type) rsp;
    
    DB_TrainCancel(SSCC_MESSAGE_PARAM_DECL) : req(SSCC_CREATE(request_type)), rsp() { }
};

