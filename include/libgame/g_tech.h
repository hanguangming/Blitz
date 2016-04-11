#pragma once

struct G_TechExpireOpt : SSCC_DEFAULT_BASE {
    static constexpr const char *the_class_name = "G_TechExpireOpt";
    SSCC_UINT8 type;
    SSCC_UINT32 cur;
    SSCC_UINT32 research;
    SSCC_UINT8 price_num;
    SSCC_UINT64 cooldown;
    
    G_TechExpireOpt(SSCC_ALLOCATOR_PARAM_DECL)
    : SSCC_DEFAULT_BASE(SSCC_ALLOCATOR_PARAM),
      type(),
      cur(),
      research(),
      price_num(),
      cooldown()
    { }
    
    bool SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM_DECL) const override {
        if (!SSCC_DEFAULT_BASE::SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        SSCC_WRITE_UINT8(this->type);
        SSCC_WRITE_UINT32(this->cur);
        SSCC_WRITE_UINT32(this->research);
        SSCC_WRITE_UINT8(this->price_num);
        SSCC_WRITE_UINT64(this->cooldown);
        return true;
    }
    
    bool SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM_DECL) override {
        if (!SSCC_DEFAULT_BASE::SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        SSCC_READ_UINT8(this->type);
        SSCC_READ_UINT32(this->cur);
        SSCC_READ_UINT32(this->research);
        SSCC_READ_UINT8(this->price_num);
        SSCC_READ_UINT64(this->cooldown);
        return true;
    }
    
#ifdef SSCC_USE_DUMP
    void SSCC_DUMP_FUNC(unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override {
        SSCC_DEFAULT_BASE::SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("type = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->type, (unsigned)this->type);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("cur = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->cur, (unsigned)this->cur);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("research = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->research, (unsigned)this->research);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("price_num = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->price_num, (unsigned)this->price_num);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("cooldown = ");
        SSCC_PRINT("%lu(0x%lx)", this->cooldown, this->cooldown);
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
        lua_pushlstring(sscc_L, "type", 4);
        lua_pushinteger(sscc_L, (lua_Integer)this->type);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "cur", 3);
        lua_pushinteger(sscc_L, (lua_Integer)this->cur);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "research", 8);
        lua_pushinteger(sscc_L, (lua_Integer)this->research);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "price_num", 9);
        lua_pushinteger(sscc_L, (lua_Integer)this->price_num);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "cooldown", 8);
        lua_pushinteger(sscc_L, (lua_Integer)this->cooldown);
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
        lua_pushlstring(sscc_L, "type", 4);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->type = lua_tointegerx(sscc_L, -1, &isnum);
            if (!isnum) {
                goto sscc_exit;
            }
        } while (0);
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "cur", 3);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->cur = lua_tointegerx(sscc_L, -1, &isnum);
            if (!isnum) {
                goto sscc_exit;
            }
        } while (0);
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "research", 8);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->research = lua_tointegerx(sscc_L, -1, &isnum);
            if (!isnum) {
                goto sscc_exit;
            }
        } while (0);
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "price_num", 9);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->price_num = lua_tointegerx(sscc_L, -1, &isnum);
            if (!isnum) {
                goto sscc_exit;
            }
        } while (0);
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "cooldown", 8);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->cooldown = lua_tointegerx(sscc_L, -1, &isnum);
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
struct G_TechOpt : SSCC_DEFAULT_BASE {
    static constexpr const char *the_class_name = "G_TechOpt";
    SSCC_UINT8 type;
    SSCC_UINT32 cur;
    SSCC_UINT32 research;
    SSCC_UINT8 price_num;
    SSCC_UINT32 cooldown;
    
    G_TechOpt(SSCC_ALLOCATOR_PARAM_DECL)
    : SSCC_DEFAULT_BASE(SSCC_ALLOCATOR_PARAM),
      type(),
      cur(),
      research(),
      price_num(),
      cooldown()
    { }
    
    bool SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM_DECL) const override {
        if (!SSCC_DEFAULT_BASE::SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        SSCC_WRITE_UINT8(this->type);
        SSCC_WRITE_UINT32(this->cur);
        SSCC_WRITE_UINT32(this->research);
        SSCC_WRITE_UINT8(this->price_num);
        SSCC_WRITE_UINT32(this->cooldown);
        return true;
    }
    
    bool SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM_DECL) override {
        if (!SSCC_DEFAULT_BASE::SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        SSCC_READ_UINT8(this->type);
        SSCC_READ_UINT32(this->cur);
        SSCC_READ_UINT32(this->research);
        SSCC_READ_UINT8(this->price_num);
        SSCC_READ_UINT32(this->cooldown);
        return true;
    }
    
#ifdef SSCC_USE_DUMP
    void SSCC_DUMP_FUNC(unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override {
        SSCC_DEFAULT_BASE::SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("type = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->type, (unsigned)this->type);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("cur = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->cur, (unsigned)this->cur);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("research = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->research, (unsigned)this->research);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("price_num = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->price_num, (unsigned)this->price_num);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("cooldown = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->cooldown, (unsigned)this->cooldown);
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
        lua_pushlstring(sscc_L, "type", 4);
        lua_pushinteger(sscc_L, (lua_Integer)this->type);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "cur", 3);
        lua_pushinteger(sscc_L, (lua_Integer)this->cur);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "research", 8);
        lua_pushinteger(sscc_L, (lua_Integer)this->research);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "price_num", 9);
        lua_pushinteger(sscc_L, (lua_Integer)this->price_num);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "cooldown", 8);
        lua_pushinteger(sscc_L, (lua_Integer)this->cooldown);
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
        lua_pushlstring(sscc_L, "type", 4);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->type = lua_tointegerx(sscc_L, -1, &isnum);
            if (!isnum) {
                goto sscc_exit;
            }
        } while (0);
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "cur", 3);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->cur = lua_tointegerx(sscc_L, -1, &isnum);
            if (!isnum) {
                goto sscc_exit;
            }
        } while (0);
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "research", 8);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->research = lua_tointegerx(sscc_L, -1, &isnum);
            if (!isnum) {
                goto sscc_exit;
            }
        } while (0);
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "price_num", 9);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->price_num = lua_tointegerx(sscc_L, -1, &isnum);
            if (!isnum) {
                goto sscc_exit;
            }
        } while (0);
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "cooldown", 8);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->cooldown = lua_tointegerx(sscc_L, -1, &isnum);
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

