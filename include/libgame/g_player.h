#pragma once

struct G_PlayerInfo : SSCC_DEFAULT_BASE {
    static constexpr const char *the_class_name = "G_PlayerInfo";
    SSCC_STRING name;
    SSCC_UINT16 level;
    SSCC_UINT8 vip;
    SSCC_UINT8 speed;
    SSCC_UINT8 side;
    SSCC_UINT32 appearance;
    
    G_PlayerInfo(SSCC_ALLOCATOR_PARAM_DECL)
    : SSCC_DEFAULT_BASE(SSCC_ALLOCATOR_PARAM),
      name(SSCC_STRING::allocator_type(SSCC_ALLOCATOR_PARAM)),
      level(),
      vip(),
      speed(),
      side(),
      appearance()
    { }
    
    bool SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM_DECL) const override {
        if (!SSCC_DEFAULT_BASE::SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        SSCC_WRITE_STRING(this->name);
        SSCC_WRITE_UINT16(this->level);
        SSCC_WRITE_UINT8(this->vip);
        SSCC_WRITE_UINT8(this->speed);
        SSCC_WRITE_UINT8(this->side);
        SSCC_WRITE_UINT32(this->appearance);
        return true;
    }
    
    bool SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM_DECL) override {
        if (!SSCC_DEFAULT_BASE::SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        SSCC_READ_STRING(this->name);
        SSCC_READ_UINT16(this->level);
        SSCC_READ_UINT8(this->vip);
        SSCC_READ_UINT8(this->speed);
        SSCC_READ_UINT8(this->side);
        SSCC_READ_UINT32(this->appearance);
        return true;
    }
    
#ifdef SSCC_USE_DUMP
    void SSCC_DUMP_FUNC(unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override {
        SSCC_DEFAULT_BASE::SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("name = ");
        SSCC_PRINT("\"%s\"", SSCC_STRING_CSTR(this->name));
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("level = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->level, (unsigned)this->level);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("vip = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->vip, (unsigned)this->vip);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("speed = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->speed, (unsigned)this->speed);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("side = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->side, (unsigned)this->side);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("appearance = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->appearance, (unsigned)this->appearance);
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
        lua_pushlstring(sscc_L, "name", 4);
        lua_pushlstring(sscc_L, SSCC_STRING_CSTR(this->name), SSCC_STRING_SIZE(this->name));
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "level", 5);
        lua_pushinteger(sscc_L, (lua_Integer)this->level);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "vip", 3);
        lua_pushinteger(sscc_L, (lua_Integer)this->vip);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "speed", 5);
        lua_pushinteger(sscc_L, (lua_Integer)this->speed);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "side", 4);
        lua_pushinteger(sscc_L, (lua_Integer)this->side);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "appearance", 10);
        lua_pushinteger(sscc_L, (lua_Integer)this->appearance);
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
        lua_pushlstring(sscc_L, "name", 4);
        lua_gettable(sscc_L, sscc_index);
        do {
            const char *sscc_str = lua_tostring(sscc_L, -1);
            if (!sscc_str) {
                goto sscc_exit;
            }
            this->name = sscc_str;
        } while (0);
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "level", 5);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->level = lua_tointegerx(sscc_L, -1, &isnum);
            if (!isnum) {
                goto sscc_exit;
            }
        } while (0);
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "vip", 3);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->vip = lua_tointegerx(sscc_L, -1, &isnum);
            if (!isnum) {
                goto sscc_exit;
            }
        } while (0);
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "speed", 5);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->speed = lua_tointegerx(sscc_L, -1, &isnum);
            if (!isnum) {
                goto sscc_exit;
            }
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
        lua_pushlstring(sscc_L, "appearance", 10);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->appearance = lua_tointegerx(sscc_L, -1, &isnum);
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

