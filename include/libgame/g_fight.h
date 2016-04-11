#pragma once

struct G_FightTeam : SSCC_DEFAULT_BASE {
    static constexpr const char *the_class_name = "G_FightTeam";
    SSCC_UINT32 hero_id;
    SSCC_UINT32 hero_attack;
    SSCC_UINT32 hero_attack_speed;
    SSCC_UINT32 hero_hp_max;
    SSCC_UINT32 hero_hp;
    SSCC_UINT32 soldier_id;
    SSCC_UINT32 soldier_attack;
    SSCC_UINT32 soldier_attack_speed;
    SSCC_UINT32 soldier_hp;
    SSCC_UINT8 soldier_num;
    SSCC_INT32 x;
    SSCC_INT32 y;
    
    G_FightTeam(SSCC_ALLOCATOR_PARAM_DECL)
    : SSCC_DEFAULT_BASE(SSCC_ALLOCATOR_PARAM),
      hero_id(),
      hero_attack(),
      hero_attack_speed(),
      hero_hp_max(),
      hero_hp(),
      soldier_id(),
      soldier_attack(),
      soldier_attack_speed(),
      soldier_hp(),
      soldier_num(),
      x(),
      y()
    { }
    
    bool SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM_DECL) const override {
        if (!SSCC_DEFAULT_BASE::SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        SSCC_WRITE_UINT32(this->hero_id);
        SSCC_WRITE_UINT32(this->hero_attack);
        SSCC_WRITE_UINT32(this->hero_attack_speed);
        SSCC_WRITE_UINT32(this->hero_hp_max);
        SSCC_WRITE_UINT32(this->hero_hp);
        SSCC_WRITE_UINT32(this->soldier_id);
        SSCC_WRITE_UINT32(this->soldier_attack);
        SSCC_WRITE_UINT32(this->soldier_attack_speed);
        SSCC_WRITE_UINT32(this->soldier_hp);
        SSCC_WRITE_UINT8(this->soldier_num);
        SSCC_WRITE_INT32(this->x);
        SSCC_WRITE_INT32(this->y);
        return true;
    }
    
    bool SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM_DECL) override {
        if (!SSCC_DEFAULT_BASE::SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        SSCC_READ_UINT32(this->hero_id);
        SSCC_READ_UINT32(this->hero_attack);
        SSCC_READ_UINT32(this->hero_attack_speed);
        SSCC_READ_UINT32(this->hero_hp_max);
        SSCC_READ_UINT32(this->hero_hp);
        SSCC_READ_UINT32(this->soldier_id);
        SSCC_READ_UINT32(this->soldier_attack);
        SSCC_READ_UINT32(this->soldier_attack_speed);
        SSCC_READ_UINT32(this->soldier_hp);
        SSCC_READ_UINT8(this->soldier_num);
        SSCC_READ_INT32(this->x);
        SSCC_READ_INT32(this->y);
        return true;
    }
    
#ifdef SSCC_USE_DUMP
    void SSCC_DUMP_FUNC(unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override {
        SSCC_DEFAULT_BASE::SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("hero_id = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->hero_id, (unsigned)this->hero_id);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("hero_attack = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->hero_attack, (unsigned)this->hero_attack);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("hero_attack_speed = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->hero_attack_speed, (unsigned)this->hero_attack_speed);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("hero_hp_max = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->hero_hp_max, (unsigned)this->hero_hp_max);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("hero_hp = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->hero_hp, (unsigned)this->hero_hp);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("soldier_id = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->soldier_id, (unsigned)this->soldier_id);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("soldier_attack = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->soldier_attack, (unsigned)this->soldier_attack);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("soldier_attack_speed = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->soldier_attack_speed, (unsigned)this->soldier_attack_speed);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("soldier_hp = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->soldier_hp, (unsigned)this->soldier_hp);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("soldier_num = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->soldier_num, (unsigned)this->soldier_num);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("x = ");
        SSCC_PRINT("%d(0x%x)", (int)this->x, (unsigned)this->x);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("y = ");
        SSCC_PRINT("%d(0x%x)", (int)this->y, (unsigned)this->y);
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
        lua_pushlstring(sscc_L, "hero_id", 7);
        lua_pushinteger(sscc_L, (lua_Integer)this->hero_id);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "hero_attack", 11);
        lua_pushinteger(sscc_L, (lua_Integer)this->hero_attack);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "hero_attack_speed", 17);
        lua_pushinteger(sscc_L, (lua_Integer)this->hero_attack_speed);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "hero_hp_max", 11);
        lua_pushinteger(sscc_L, (lua_Integer)this->hero_hp_max);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "hero_hp", 7);
        lua_pushinteger(sscc_L, (lua_Integer)this->hero_hp);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "soldier_id", 10);
        lua_pushinteger(sscc_L, (lua_Integer)this->soldier_id);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "soldier_attack", 14);
        lua_pushinteger(sscc_L, (lua_Integer)this->soldier_attack);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "soldier_attack_speed", 20);
        lua_pushinteger(sscc_L, (lua_Integer)this->soldier_attack_speed);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "soldier_hp", 10);
        lua_pushinteger(sscc_L, (lua_Integer)this->soldier_hp);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "soldier_num", 11);
        lua_pushinteger(sscc_L, (lua_Integer)this->soldier_num);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "x", 1);
        lua_pushinteger(sscc_L, (lua_Integer)this->x);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "y", 1);
        lua_pushinteger(sscc_L, (lua_Integer)this->y);
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
        lua_pushlstring(sscc_L, "hero_id", 7);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            do {
                int isnum;
                this->hero_id = lua_tointegerx(sscc_L, -1, &isnum);
                if (!isnum) {
                    goto sscc_exit;
                }
            } while (0);
        }
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "hero_attack", 11);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            do {
                int isnum;
                this->hero_attack = lua_tointegerx(sscc_L, -1, &isnum);
                if (!isnum) {
                    goto sscc_exit;
                }
            } while (0);
        }
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "hero_attack_speed", 17);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            do {
                int isnum;
                this->hero_attack_speed = lua_tointegerx(sscc_L, -1, &isnum);
                if (!isnum) {
                    goto sscc_exit;
                }
            } while (0);
        }
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "hero_hp_max", 11);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            do {
                int isnum;
                this->hero_hp_max = lua_tointegerx(sscc_L, -1, &isnum);
                if (!isnum) {
                    goto sscc_exit;
                }
            } while (0);
        }
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "hero_hp", 7);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            do {
                int isnum;
                this->hero_hp = lua_tointegerx(sscc_L, -1, &isnum);
                if (!isnum) {
                    goto sscc_exit;
                }
            } while (0);
        }
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "soldier_id", 10);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            do {
                int isnum;
                this->soldier_id = lua_tointegerx(sscc_L, -1, &isnum);
                if (!isnum) {
                    goto sscc_exit;
                }
            } while (0);
        }
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "soldier_attack", 14);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            do {
                int isnum;
                this->soldier_attack = lua_tointegerx(sscc_L, -1, &isnum);
                if (!isnum) {
                    goto sscc_exit;
                }
            } while (0);
        }
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "soldier_attack_speed", 20);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            do {
                int isnum;
                this->soldier_attack_speed = lua_tointegerx(sscc_L, -1, &isnum);
                if (!isnum) {
                    goto sscc_exit;
                }
            } while (0);
        }
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "soldier_hp", 10);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            do {
                int isnum;
                this->soldier_hp = lua_tointegerx(sscc_L, -1, &isnum);
                if (!isnum) {
                    goto sscc_exit;
                }
            } while (0);
        }
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "soldier_num", 11);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            do {
                int isnum;
                this->soldier_num = lua_tointegerx(sscc_L, -1, &isnum);
                if (!isnum) {
                    goto sscc_exit;
                }
            } while (0);
        }
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "x", 1);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            do {
                int isnum;
                this->x = lua_tointegerx(sscc_L, -1, &isnum);
                if (!isnum) {
                    goto sscc_exit;
                }
            } while (0);
        }
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "y", 1);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            do {
                int isnum;
                this->y = lua_tointegerx(sscc_L, -1, &isnum);
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
struct G_FightCorps : SSCC_DEFAULT_BASE {
    static constexpr const char *the_class_name = "G_FightCorps";
    SSCC_UINT32 uid;
    SSCC_UINT32 vip;
    SSCC_STRING name;
    SSCC_VECTOR(G_FightTeam) teams;
    
    G_FightCorps(SSCC_ALLOCATOR_PARAM_DECL)
    : SSCC_DEFAULT_BASE(SSCC_ALLOCATOR_PARAM),
      uid(),
      vip(),
      name(SSCC_STRING::allocator_type(SSCC_ALLOCATOR_PARAM)),
      teams(SSCC_VECTOR(G_FightTeam)::allocator_type(SSCC_ALLOCATOR_PARAM))
    { }
    
    bool SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM_DECL) const override {
        if (!SSCC_DEFAULT_BASE::SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        SSCC_WRITE_UINT32(this->uid);
        SSCC_WRITE_UINT32(this->vip);
        SSCC_WRITE_STRING(this->name);
        if (!SSCC_WRITE_SIZE(SSCC_VECTOR_SIZE(this->teams))) {
            return false;
        }
        for (auto &sscc_i : this->teams) {
            if (!sscc_i.SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
                return false;
            }
        }
        return true;
    }
    
    bool SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM_DECL) override {
        if (!SSCC_DEFAULT_BASE::SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        SSCC_READ_UINT32(this->uid);
        SSCC_READ_UINT32(this->vip);
        SSCC_READ_STRING(this->name);
        do {
            size_t sscc_size;
            SSCC_READ_SIZE(sscc_size);
            for (size_t sscc_i = 0 ; sscc_i < sscc_size; ++sscc_i) {
                SSCC_VECTOR_EMPLACE_BACK(this->teams);
                if (!SSCC_VECTOR_BACK(this->teams).SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
                    return false;
                }
            }
        } while (0);
        return true;
    }
    
#ifdef SSCC_USE_DUMP
    void SSCC_DUMP_FUNC(unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override {
        SSCC_DEFAULT_BASE::SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("uid = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->uid, (unsigned)this->uid);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("vip = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->vip, (unsigned)this->vip);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("name = ");
        SSCC_PRINT("\"%s\"", SSCC_STRING_CSTR(this->name));
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("teams = ");
        SSCC_PRINT("{\n");
        ++sscc_indent;
        do {
            size_t sscc_i = 0;
            for (auto &sscc_obj : this->teams) {
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
        SSCC_DEFAULT_BASE::SSCC_TOLUA_FUNC(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "uid", 3);
        lua_pushinteger(sscc_L, (lua_Integer)this->uid);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "vip", 3);
        lua_pushinteger(sscc_L, (lua_Integer)this->vip);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "name", 4);
        lua_pushlstring(sscc_L, SSCC_STRING_CSTR(this->name), SSCC_STRING_SIZE(this->name));
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "teams", 5);
        lua_createtable(sscc_L, SSCC_VECTOR_SIZE(this->teams), 0);
        do {
            lua_Integer sscc_i = 0;
            for (auto &sscc_obj : this->teams) {
                lua_pushinteger(sscc_L, ++sscc_i);
                SSCC_VECTOR_BACK(this->teams);
                lua_createtable(sscc_L, 0, 12);
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
        if (!SSCC_DEFAULT_BASE::SSCC_FROMLUA_FUNC(sscc_L, sscc_index SSCC_FROMLUA_PARAM)) {
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
        lua_pushlstring(sscc_L, "vip", 3);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            do {
                int isnum;
                this->vip = lua_tointegerx(sscc_L, -1, &isnum);
                if (!isnum) {
                    goto sscc_exit;
                }
            } while (0);
        }
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "name", 4);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            do {
                const char *sscc_str = lua_tostring(sscc_L, -1);
                if (!sscc_str) {
                    goto sscc_exit;
                }
                this->name = sscc_str;
            } while (0);
        }
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "teams", 5);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            for (size_t sscc_i = 1; ; ++sscc_i) {
                lua_pushinteger(sscc_L, sscc_i);
                lua_gettable(sscc_L, -2);
                if (lua_isnil(sscc_L, -1)) {
                    lua_pop(sscc_L, 1);
                    break;
                }
                SSCC_VECTOR_EMPLACE_BACK(this->teams);
                if (!SSCC_VECTOR_BACK(this->teams).SSCC_FROMLUA_FUNC(sscc_L, -1 SSCC_FROMLUA_PARAM)) {
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
struct G_FightInfo : SSCC_DEFAULT_BASE {
    static constexpr const char *the_class_name = "G_FightInfo";
    G_FightCorps attacker;
    G_FightCorps defender;
    SSCC_UINT8 result;
    SSCC_UINT32 frames;
    SSCC_UINT32 time;
    SSCC_UINT32 seed;
    
    G_FightInfo(SSCC_ALLOCATOR_PARAM_DECL)
    : SSCC_DEFAULT_BASE(SSCC_ALLOCATOR_PARAM),
      attacker(SSCC_ALLOCATOR_PARAM),
      defender(SSCC_ALLOCATOR_PARAM),
      result(),
      frames(),
      time(),
      seed()
    { }
    
    bool SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM_DECL) const override {
        if (!SSCC_DEFAULT_BASE::SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        if (!this->attacker.SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        if (!this->defender.SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)) {
            return false;
        }
        SSCC_WRITE_UINT8(this->result);
        SSCC_WRITE_UINT32(this->frames);
        SSCC_WRITE_UINT32(this->time);
        SSCC_WRITE_UINT32(this->seed);
        return true;
    }
    
    bool SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM_DECL) override {
        if (!SSCC_DEFAULT_BASE::SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        if (!this->attacker.SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        if (!this->defender.SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)) {
            return false;
        }
        SSCC_READ_UINT8(this->result);
        SSCC_READ_UINT32(this->frames);
        SSCC_READ_UINT32(this->time);
        SSCC_READ_UINT32(this->seed);
        return true;
    }
    
#ifdef SSCC_USE_DUMP
    void SSCC_DUMP_FUNC(unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override {
        SSCC_DEFAULT_BASE::SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("attacker = ");
        SSCC_PRINT("{\n");
        ++sscc_indent;
        this->attacker.SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
        --sscc_indent;
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("}");
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("defender = ");
        SSCC_PRINT("{\n");
        ++sscc_indent;
        this->defender.SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM);
        --sscc_indent;
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("}");
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("result = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->result, (unsigned)this->result);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("frames = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->frames, (unsigned)this->frames);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("time = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->time, (unsigned)this->time);
        SSCC_PRINT(",\n");
        SSCC_PRINT_INDENT(sscc_indent);
        SSCC_PRINT("seed = ");
        SSCC_PRINT("%u(0x%x)", (unsigned)this->seed, (unsigned)this->seed);
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
        lua_pushlstring(sscc_L, "attacker", 8);
        lua_createtable(sscc_L, 0, 4);
        this->attacker.SSCC_TOLUA_FUNC(sscc_L, -1);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "defender", 8);
        lua_createtable(sscc_L, 0, 4);
        this->defender.SSCC_TOLUA_FUNC(sscc_L, -1);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "result", 6);
        lua_pushinteger(sscc_L, (lua_Integer)this->result);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "frames", 6);
        lua_pushinteger(sscc_L, (lua_Integer)this->frames);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "time", 4);
        lua_pushinteger(sscc_L, (lua_Integer)this->time);
        lua_settable(sscc_L, sscc_index);
        lua_pushlstring(sscc_L, "seed", 4);
        lua_pushinteger(sscc_L, (lua_Integer)this->seed);
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
        lua_pushlstring(sscc_L, "attacker", 8);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            if (!this->attacker.SSCC_FROMLUA_FUNC(sscc_L, -1 SSCC_FROMLUA_PARAM)) {
                goto sscc_exit;
            }
        }
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "defender", 8);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            if (!this->defender.SSCC_FROMLUA_FUNC(sscc_L, -1 SSCC_FROMLUA_PARAM)) {
                goto sscc_exit;
            }
        }
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "result", 6);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            do {
                int isnum;
                this->result = lua_tointegerx(sscc_L, -1, &isnum);
                if (!isnum) {
                    goto sscc_exit;
                }
            } while (0);
        }
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "frames", 6);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            do {
                int isnum;
                this->frames = lua_tointegerx(sscc_L, -1, &isnum);
                if (!isnum) {
                    goto sscc_exit;
                }
            } while (0);
        }
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "time", 4);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            do {
                int isnum;
                this->time = lua_tointegerx(sscc_L, -1, &isnum);
                if (!isnum) {
                    goto sscc_exit;
                }
            } while (0);
        }
        lua_pop(sscc_L, 1);
        lua_pushlstring(sscc_L, "seed", 4);
        lua_gettable(sscc_L, sscc_index);
        if (!lua_isnil(sscc_L, -1)) {
            do {
                int isnum;
                this->seed = lua_tointegerx(sscc_L, -1, &isnum);
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

