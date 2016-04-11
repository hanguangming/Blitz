#ifndef SSCC_MESSAGE_OPT
#ifndef __1442547339255_h__
#define __1442547339255_h__

#include "message.h"
struct AS_ItemOpt : SSCC_DEFAULT_BASE {
    static constexpr const char *the_class_name = "AS_ItemOpt";
    SSCC_UINT32 item_id;
    SSCC_INT32 item_type;
    SSCC_UINT32 count;
    SSCC_INT8 used;
    
    AS_ItemOpt()
    : SSCC_DEFAULT_BASE(),
      item_id(),
      item_type(),
      count(),
      used()
    { }
    
    bool SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM_DECL) const override {
        if (!SSCC_DEFAULT_BASE::SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        SSCC_WRITE_UINT32(this->item_id);
        SSCC_WRITE_INT32(this->item_type);
        SSCC_WRITE_UINT32(this->count);
        SSCC_WRITE_INT8(this->used);
        return true;
    }
    
    bool SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM_DECL) override {
        if (!SSCC_DEFAULT_BASE::SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        SSCC_READ_UINT32(this->item_id);
        SSCC_READ_INT32(this->item_type);
        SSCC_READ_UINT32(this->count);
        SSCC_READ_INT8(this->used);
        return true;
    }
    
#ifdef SSCC_USE_DUMP
    void SSCC_DUMP_FUNC(unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override {
        SSCC_DEFAULT_BASE::SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("item_id = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->item_id, (unsigned)this->item_id);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("item_type = ");
        SSCC_PRINT("%d(0x%x)", (int)this->item_type, (unsigned)this->item_type);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("count = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->count, (unsigned)this->count);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("used = ");
        SSCC_PRINT("%d(0x%x)", (int)this->used, (unsigned)this->used);
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
        SSCC_DEFAULT_BASE::SSCC_TOLUA_FUNC(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "item_id", 7);
        lua_pushinteger(sscc_L, (lua_Integer)this->item_id);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "item_type", 9);
        lua_pushinteger(sscc_L, (lua_Integer)this->item_type);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "count", 5);
        lua_pushinteger(sscc_L, (lua_Integer)this->count);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "used", 4);
        lua_pushinteger(sscc_L, (lua_Integer)this->used);
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
        if (!SSCC_DEFAULT_BASE::SSCC_FROMLUA_FUNC(sscc_L, sscc_index SSCC_FROMLUA_PARAM)) {
            goto sscc_exit;
        }
        lua_pushlstring(sscc_L, "item_id", 7);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->item_id = lua_tointegerx(sscc_L, -1, &isnum);
            if (!isnum) {
                goto sscc_exit;
            }
        } while (0);
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "item_type", 9);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->item_type = lua_tointegerx(sscc_L, -1, &isnum);
            if (!isnum) {
                goto sscc_exit;
            }
        } while (0);
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "count", 5);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->count = lua_tointegerx(sscc_L, -1, &isnum);
            if (!isnum) {
                goto sscc_exit;
            }
        } while (0);
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "used", 4);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->used = lua_tointegerx(sscc_L, -1, &isnum);
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
struct AS_Money : SSCC_DEFAULT_BASE {
    static constexpr const char *the_class_name = "AS_Money";
    SSCC_UINT64 money;
    SSCC_UINT64 coin;
    SSCC_UINT64 honor;
    SSCC_UINT64 soul;
    
    AS_Money()
    : SSCC_DEFAULT_BASE(),
      money(),
      coin(),
      honor(),
      soul()
    { }
    
    bool SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM_DECL) const override {
        if (!SSCC_DEFAULT_BASE::SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        SSCC_WRITE_UINT64(this->money);
        SSCC_WRITE_UINT64(this->coin);
        SSCC_WRITE_UINT64(this->honor);
        SSCC_WRITE_UINT64(this->soul);
        return true;
    }
    
    bool SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM_DECL) override {
        if (!SSCC_DEFAULT_BASE::SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        SSCC_READ_UINT64(this->money);
        SSCC_READ_UINT64(this->coin);
        SSCC_READ_UINT64(this->honor);
        SSCC_READ_UINT64(this->soul);
        return true;
    }
    
#ifdef SSCC_USE_DUMP
    void SSCC_DUMP_FUNC(unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override {
        SSCC_DEFAULT_BASE::SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("money = ");
        SSCC_PRINT("%lu(0x%lx)", this->money, this->money);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("coin = ");
        SSCC_PRINT("%lu(0x%lx)", this->coin, this->coin);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("honor = ");
        SSCC_PRINT("%lu(0x%lx)", this->honor, this->honor);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("soul = ");
        SSCC_PRINT("%lu(0x%lx)", this->soul, this->soul);
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
        SSCC_DEFAULT_BASE::SSCC_TOLUA_FUNC(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "money", 5);
        lua_pushinteger(sscc_L, (lua_Integer)this->money);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "coin", 4);
        lua_pushinteger(sscc_L, (lua_Integer)this->coin);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "honor", 5);
        lua_pushinteger(sscc_L, (lua_Integer)this->honor);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "soul", 4);
        lua_pushinteger(sscc_L, (lua_Integer)this->soul);
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
        if (!SSCC_DEFAULT_BASE::SSCC_FROMLUA_FUNC(sscc_L, sscc_index SSCC_FROMLUA_PARAM)) {
            goto sscc_exit;
        }
        lua_pushlstring(sscc_L, "money", 5);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->money = lua_tointegerx(sscc_L, -1, &isnum);
            if (!isnum) {
                goto sscc_exit;
            }
        } while (0);
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "coin", 4);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->coin = lua_tointegerx(sscc_L, -1, &isnum);
            if (!isnum) {
                goto sscc_exit;
            }
        } while (0);
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "honor", 5);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->honor = lua_tointegerx(sscc_L, -1, &isnum);
            if (!isnum) {
                goto sscc_exit;
            }
        } while (0);
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "soul", 4);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->soul = lua_tointegerx(sscc_L, -1, &isnum);
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

#endif
#else
#endif
