#pragma once

struct G_ArenaItem : SSCC_DEFAULT_BASE {
    static constexpr const char *the_class_name = "G_ArenaItem";
    SSCC_UINT32 id;
    SSCC_UINT32 index;
    SSCC_UINT8 side;
    SSCC_UINT8 vip;
    SSCC_UINT32 appearance;
    SSCC_STRING name;
    
    G_ArenaItem(SSCC_ALLOCATOR_PARAM_DECL)
    : SSCC_DEFAULT_BASE(SSCC_ALLOCATOR_PARAM),
      id(),
      index(),
      side(),
      vip(),
      appearance(),
      name(SSCC_STRING::allocator_type(SSCC_ALLOCATOR_PARAM))
    { }
    
    bool SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM_DECL) const override {
        if (!SSCC_DEFAULT_BASE::SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        SSCC_WRITE_UINT32(this->id);
        SSCC_WRITE_UINT32(this->index);
        SSCC_WRITE_UINT8(this->side);
        SSCC_WRITE_UINT8(this->vip);
        SSCC_WRITE_UINT32(this->appearance);
        SSCC_WRITE_STRING(this->name);
        return true;
    }
    
    bool SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM_DECL) override {
        if (!SSCC_DEFAULT_BASE::SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        SSCC_READ_UINT32(this->id);
        SSCC_READ_UINT32(this->index);
        SSCC_READ_UINT8(this->side);
        SSCC_READ_UINT8(this->vip);
        SSCC_READ_UINT32(this->appearance);
        SSCC_READ_STRING(this->name);
        return true;
    }
    
#ifdef SSCC_USE_DUMP
    void SSCC_DUMP_FUNC(unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override {
        SSCC_DEFAULT_BASE::SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("id = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->id, (unsigned)this->id);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("index = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->index, (unsigned)this->index);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("side = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->side, (unsigned)this->side);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("vip = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->vip, (unsigned)this->vip);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("appearance = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->appearance, (unsigned)this->appearance);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("name = ");
        SSCC_PRINT("\"%s\"", SSCC_STRING_CSTR(this->name));
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
        lua_pushlstring(sscc_L, "id", 2);
        lua_pushinteger(sscc_L, (lua_Integer)this->id);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "index", 5);
        lua_pushinteger(sscc_L, (lua_Integer)this->index);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "side", 4);
        lua_pushinteger(sscc_L, (lua_Integer)this->side);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "vip", 3);
        lua_pushinteger(sscc_L, (lua_Integer)this->vip);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "appearance", 10);
        lua_pushinteger(sscc_L, (lua_Integer)this->appearance);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "name", 4);
        lua_pushlstring(sscc_L, SSCC_STRING_CSTR(this->name), SSCC_STRING_SIZE(this->name));
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
        lua_pushlstring(sscc_L, "id", 2);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->id = lua_tointegerx(sscc_L, -1, &isnum);
            if (!isnum) {
                goto sscc_exit;
            }
        } while (0);
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "index", 5);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->index = lua_tointegerx(sscc_L, -1, &isnum);
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
struct G_SoldierRankingItem : SSCC_DEFAULT_BASE {
    static constexpr const char *the_class_name = "G_SoldierRankingItem";
    SSCC_UINT32 id;
    SSCC_UINT8 side;
    SSCC_UINT8 vip;
    SSCC_UINT32 appearance;
    SSCC_STRING name;
    SSCC_VECTOR(SSCC_UINT16) soldiers;
    
    G_SoldierRankingItem(SSCC_ALLOCATOR_PARAM_DECL)
    : SSCC_DEFAULT_BASE(SSCC_ALLOCATOR_PARAM),
      id(),
      side(),
      vip(),
      appearance(),
      name(SSCC_STRING::allocator_type(SSCC_ALLOCATOR_PARAM)),
      soldiers(SSCC_VECTOR(SSCC_UINT16)::allocator_type(SSCC_ALLOCATOR_PARAM))
    { }
    
    bool SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM_DECL) const override {
        if (!SSCC_DEFAULT_BASE::SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        SSCC_WRITE_UINT32(this->id);
        SSCC_WRITE_UINT8(this->side);
        SSCC_WRITE_UINT8(this->vip);
        SSCC_WRITE_UINT32(this->appearance);
        SSCC_WRITE_STRING(this->name);
        if (!SSCC_WRITE_SIZE(SSCC_VECTOR_SIZE(this->soldiers))) {
            return false;
        }
        for (auto &sscc_i : this->soldiers) {
            SSCC_WRITE_UINT16(sscc_i);
        }
        return true;
    }
    
    bool SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM_DECL) override {
        if (!SSCC_DEFAULT_BASE::SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        SSCC_READ_UINT32(this->id);
        SSCC_READ_UINT8(this->side);
        SSCC_READ_UINT8(this->vip);
        SSCC_READ_UINT32(this->appearance);
        SSCC_READ_STRING(this->name);
        do {
            size_t sscc_size;
            SSCC_READ_SIZE(sscc_size);
            for (size_t sscc_i = 0 ; sscc_i < sscc_size; ++sscc_i) {
                SSCC_VECTOR_EMPLACE_BACK(this->soldiers);
                SSCC_READ_UINT16(SSCC_VECTOR_BACK(this->soldiers));
            }
        } while (0);
        return true;
    }
    
#ifdef SSCC_USE_DUMP
    void SSCC_DUMP_FUNC(unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override {
        SSCC_DEFAULT_BASE::SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("id = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->id, (unsigned)this->id);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("side = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->side, (unsigned)this->side);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("vip = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->vip, (unsigned)this->vip);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("appearance = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->appearance, (unsigned)this->appearance);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("name = ");
        SSCC_PRINT("\"%s\"", SSCC_STRING_CSTR(this->name));
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("soldiers = ");
        SSCC_PRINT("{\n");
        ++sscc_indent;
        do {
            size_t sscc_i = 0;
            for (auto &sscc_obj : this->soldiers) {
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
        SSCC_DEFAULT_BASE::SSCC_TOLUA_FUNC(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "id", 2);
        lua_pushinteger(sscc_L, (lua_Integer)this->id);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "side", 4);
        lua_pushinteger(sscc_L, (lua_Integer)this->side);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "vip", 3);
        lua_pushinteger(sscc_L, (lua_Integer)this->vip);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "appearance", 10);
        lua_pushinteger(sscc_L, (lua_Integer)this->appearance);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "name", 4);
        lua_pushlstring(sscc_L, SSCC_STRING_CSTR(this->name), SSCC_STRING_SIZE(this->name));
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "soldiers", 8);
        lua_createtable(sscc_L, SSCC_VECTOR_SIZE(this->soldiers), 0);
        do {
            lua_Integer sscc_i = 0;
            for (auto &sscc_obj : this->soldiers) {
                lua_pushinteger(sscc_L, ++sscc_i);
                SSCC_VECTOR_BACK(this->soldiers);
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
        if (!SSCC_DEFAULT_BASE::SSCC_FROMLUA_FUNC(sscc_L, sscc_index SSCC_FROMLUA_PARAM)) {
            goto sscc_exit;
        }
        lua_pushlstring(sscc_L, "id", 2);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->id = lua_tointegerx(sscc_L, -1, &isnum);
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
        lua_pushlstring(sscc_L, "soldiers", 8);
        lua_gettable(sscc_L, sscc_index);
        for (size_t sscc_i = 1; ; ++sscc_i) {
            lua_pushinteger(sscc_L, sscc_i);
            lua_gettable(sscc_L, -2);
            if (lua_isnil(sscc_L, -1)) {
                lua_pop(sscc_L, 1);
                break;
            }
            SSCC_VECTOR_EMPLACE_BACK(this->soldiers);
            do {
                int isnum;
                SSCC_VECTOR_BACK(this->soldiers) = lua_tointegerx(sscc_L, -1, &isnum);
                if (!isnum) {
                    goto sscc_exit;
                }
            } while (0);
            lua_pop(sscc_L, 1);
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
struct G_ScoreRankingItem : SSCC_DEFAULT_BASE {
    static constexpr const char *the_class_name = "G_ScoreRankingItem";
    SSCC_UINT32 id;
    SSCC_UINT8 side;
    SSCC_UINT8 vip;
    SSCC_UINT32 appearance;
    SSCC_STRING name;
    SSCC_UINT32 score;
    
    G_ScoreRankingItem(SSCC_ALLOCATOR_PARAM_DECL)
    : SSCC_DEFAULT_BASE(SSCC_ALLOCATOR_PARAM),
      id(),
      side(),
      vip(),
      appearance(),
      name(SSCC_STRING::allocator_type(SSCC_ALLOCATOR_PARAM)),
      score()
    { }
    
    bool SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM_DECL) const override {
        if (!SSCC_DEFAULT_BASE::SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        SSCC_WRITE_UINT32(this->id);
        SSCC_WRITE_UINT8(this->side);
        SSCC_WRITE_UINT8(this->vip);
        SSCC_WRITE_UINT32(this->appearance);
        SSCC_WRITE_STRING(this->name);
        SSCC_WRITE_UINT32(this->score);
        return true;
    }
    
    bool SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM_DECL) override {
        if (!SSCC_DEFAULT_BASE::SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        SSCC_READ_UINT32(this->id);
        SSCC_READ_UINT8(this->side);
        SSCC_READ_UINT8(this->vip);
        SSCC_READ_UINT32(this->appearance);
        SSCC_READ_STRING(this->name);
        SSCC_READ_UINT32(this->score);
        return true;
    }
    
#ifdef SSCC_USE_DUMP
    void SSCC_DUMP_FUNC(unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override {
        SSCC_DEFAULT_BASE::SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("id = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->id, (unsigned)this->id);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("side = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->side, (unsigned)this->side);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("vip = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->vip, (unsigned)this->vip);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("appearance = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->appearance, (unsigned)this->appearance);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("name = ");
        SSCC_PRINT("\"%s\"", SSCC_STRING_CSTR(this->name));
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("score = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->score, (unsigned)this->score);
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
        lua_pushlstring(sscc_L, "id", 2);
        lua_pushinteger(sscc_L, (lua_Integer)this->id);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "side", 4);
        lua_pushinteger(sscc_L, (lua_Integer)this->side);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "vip", 3);
        lua_pushinteger(sscc_L, (lua_Integer)this->vip);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "appearance", 10);
        lua_pushinteger(sscc_L, (lua_Integer)this->appearance);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "name", 4);
        lua_pushlstring(sscc_L, SSCC_STRING_CSTR(this->name), SSCC_STRING_SIZE(this->name));
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "score", 5);
        lua_pushinteger(sscc_L, (lua_Integer)this->score);
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
        lua_pushlstring(sscc_L, "id", 2);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->id = lua_tointegerx(sscc_L, -1, &isnum);
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
        lua_pushlstring(sscc_L, "score", 5);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->score = lua_tointegerx(sscc_L, -1, &isnum);
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
struct G_ArenaRankingItem : SSCC_DEFAULT_BASE {
    static constexpr const char *the_class_name = "G_ArenaRankingItem";
    SSCC_UINT32 id;
    SSCC_UINT32 index;
    SSCC_UINT8 side;
    SSCC_UINT8 vip;
    SSCC_UINT32 appearance;
    SSCC_UINT16 level;
    SSCC_STRING name;
    SSCC_UINT32 score;
    
    G_ArenaRankingItem(SSCC_ALLOCATOR_PARAM_DECL)
    : SSCC_DEFAULT_BASE(SSCC_ALLOCATOR_PARAM),
      id(),
      index(),
      side(),
      vip(),
      appearance(),
      level(),
      name(SSCC_STRING::allocator_type(SSCC_ALLOCATOR_PARAM)),
      score()
    { }
    
    bool SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM_DECL) const override {
        if (!SSCC_DEFAULT_BASE::SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        SSCC_WRITE_UINT32(this->id);
        SSCC_WRITE_UINT32(this->index);
        SSCC_WRITE_UINT8(this->side);
        SSCC_WRITE_UINT8(this->vip);
        SSCC_WRITE_UINT32(this->appearance);
        SSCC_WRITE_UINT16(this->level);
        SSCC_WRITE_STRING(this->name);
        SSCC_WRITE_UINT32(this->score);
        return true;
    }
    
    bool SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM_DECL) override {
        if (!SSCC_DEFAULT_BASE::SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        SSCC_READ_UINT32(this->id);
        SSCC_READ_UINT32(this->index);
        SSCC_READ_UINT8(this->side);
        SSCC_READ_UINT8(this->vip);
        SSCC_READ_UINT32(this->appearance);
        SSCC_READ_UINT16(this->level);
        SSCC_READ_STRING(this->name);
        SSCC_READ_UINT32(this->score);
        return true;
    }
    
#ifdef SSCC_USE_DUMP
    void SSCC_DUMP_FUNC(unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override {
        SSCC_DEFAULT_BASE::SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("id = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->id, (unsigned)this->id);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("index = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->index, (unsigned)this->index);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("side = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->side, (unsigned)this->side);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("vip = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->vip, (unsigned)this->vip);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("appearance = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->appearance, (unsigned)this->appearance);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("level = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->level, (unsigned)this->level);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("name = ");
        SSCC_PRINT("\"%s\"", SSCC_STRING_CSTR(this->name));
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("score = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->score, (unsigned)this->score);
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
        lua_pushlstring(sscc_L, "id", 2);
        lua_pushinteger(sscc_L, (lua_Integer)this->id);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "index", 5);
        lua_pushinteger(sscc_L, (lua_Integer)this->index);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "side", 4);
        lua_pushinteger(sscc_L, (lua_Integer)this->side);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "vip", 3);
        lua_pushinteger(sscc_L, (lua_Integer)this->vip);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "appearance", 10);
        lua_pushinteger(sscc_L, (lua_Integer)this->appearance);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "level", 5);
        lua_pushinteger(sscc_L, (lua_Integer)this->level);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "name", 4);
        lua_pushlstring(sscc_L, SSCC_STRING_CSTR(this->name), SSCC_STRING_SIZE(this->name));
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "score", 5);
        lua_pushinteger(sscc_L, (lua_Integer)this->score);
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
        lua_pushlstring(sscc_L, "id", 2);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->id = lua_tointegerx(sscc_L, -1, &isnum);
            if (!isnum) {
                goto sscc_exit;
            }
        } while (0);
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "index", 5);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->index = lua_tointegerx(sscc_L, -1, &isnum);
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
        lua_pushlstring(sscc_L, "score", 5);
        lua_gettable(sscc_L, sscc_index);
        do {
            int isnum;
            this->score = lua_tointegerx(sscc_L, -1, &isnum);
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

