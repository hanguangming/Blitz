#include "libfight.h"
#include "stage.h"

#ifdef __GNUC__
#define VAR_UNUSED __attribute__((unused))
#else 
#define VAR_UNUSED
#endif

#define SCRIPT_BEGIN()                              \
    unsigned __top VAR_UNUSED = lua_gettop(L);      \
    unsigned __param_index VAR_UNUSED = 1;          \
    unsigned __result VAR_UNUSED = 0

#define SCRIPT_END()                                \
    return __result

#define INT_PARAM(name, default_value)              \
int name;                                           \
do {                                                \
    if (__param_index > __top) {                    \
        name = default_value;                       \
    }                                               \
    else {                                          \
        name = luaL_checkinteger(L, __param_index++);\
    }                                               \
} while (0)

#define INT_PARAM_EXPLICIT(name)                    \
int name = 0;                                       \
do {                                                \
    if (__param_index > __top) {                    \
        luaL_error(L, "no param " #name);           \
    }                                               \
    else {                                          \
        name = luaL_checkinteger(L, __param_index++);\
    }                                               \
} while (0)

#define BOOL_PARAM(name, value)                     \
bool name = value;                                  \
do {                                                \
    if (__param_index <= __top) {                   \
        if (!lua_isboolean(L, __param_index)) {     \
            luaL_error(L, "not is bool param " #name);\
        }                                           \
        name = lua_toboolean(L, __param_index++);   \
    }                                               \
} while (0)

#define BOOL_PARAM_EXPLICIT(name)                   \
bool name = false;                                  \
do {                                                \
    if (__param_index > __top) {                    \
        luaL_error(L, "no param " #name);           \
    }                                               \
    else if (!lua_isboolean(L, __param_index)) {    \
        luaL_error(L, "not is bool param " #name);  \
    }                                               \
    name = lua_toboolean(L, __param_index++);       \
} while (0)

#define NUM_PARAM(name, default_value)              \
double name;                                        \
do {                                                \
    if (__param_index > __top) {                    \
        name = default_value;                       \
    }                                               \
    else {                                          \
        name = luaL_optnumber(L, __param_index++, default_value);\
    }                                               \
} while (0)

#define NUM_PARAM_EXPLICIT(name)                    \
double name = 0;                                    \
do {                                                \
    if (__param_index > __top) {                    \
        luaL_error(L, "no param " #name);           \
    }                                               \
    else {                                          \
        name = luaL_checknumber(L, __param_index++);\
    }                                               \
} while (0)

#define OBJ_PARAM(type, name)                       \
type* name;                                         \
do {                                                \
    if (__param_index > __top) {                    \
        luaL_error(L, "object is nullptr.");        \
    }                                               \
    void *p = lua_touserdata(L, __param_index++);   \
    if (!p) {                                       \
        luaL_error(L, "object is nullptr.");        \
    }                                               \
    name = static_cast<type*>(p);                   \
} while (0)

#define FUNC_PARAM(name)                            \
int name;                                           \
do {                                                \
    if (__param_index > __top) {                    \
        luaL_error(L, "function is nil.");          \
    }                                               \
    if (!lua_isfunction(L, __param_index)) {        \
        luaL_error(L, "param is not a function.");  \
    }                                               \
    lua_pushvalue(L, __param_index);                \
    name = luaL_ref(L, LUA_REGISTRYINDEX);          \
    lua_pop(L, 1);                                  \
} while (0)

#define UNIT_PARAM(name)                            \
Unit *name = nullptr;                               \
do {                                                \
    unsigned uid;                                   \
    if (__param_index > __top) {                    \
        luaL_error(L, "no unit");                   \
    }                                               \
    if (lua_islightuserdata(L, __param_index)) {    \
        void *p = lua_touserdata(                   \
            L, __param_index);                      \
        if (!p) {                                   \
            luaL_error(L, "no unit");               \
        }                                           \
        name = static_cast<Unit*>(p);               \
    }                                               \
    else {                                          \
        uid = luaL_optint(L, __param_index, 0);     \
        if (!uid) {                                 \
            luaL_error(L, "no unit");               \
            name = Stage::cur()->get_unit(uid);     \
            if (!name) {                            \
                luaL_error(L, "no unit");           \
            }                                       \
        }                                           \
    }                                               \
    ++__param_index;                                \
} while (0)

#define RETURN_INT(value)                           \
do {                                                \
    lua_pushinteger(L, value);                      \
    ++__result;                                     \
} while (0)

#define RETURN_NUM(value)                           \
do {                                                \
    lua_pushnumber(L, value);                       \
    ++__result;                                     \
} while (0)

#define RETURN_OBJ(value)                           \
do {                                                \
    lua_pushlightuserdata(L, value);                \
    ++__result;                                     \
} while (0)

/* libfight_init(pixel_w, pixel_h, cell_size, grid_w, grid_h) */
static int __libfight_init(lua_State *L) {
   SCRIPT_BEGIN();
   INT_PARAM_EXPLICIT(pw);
   INT_PARAM_EXPLICIT(ph);
   INT_PARAM_EXPLICIT(cs);
   INT_PARAM_EXPLICIT(gw);
   INT_PARAM_EXPLICIT(gh);

   Cells::init(pw, ph, cs, gw, gh);
   SCRIPT_END();
}

/* local stage = stage_create(pixel_width, pixel_height, seed) */
static int __stage_create(lua_State *L) {
    SCRIPT_BEGIN();
    INT_PARAM_EXPLICIT(width);
    INT_PARAM_EXPLICIT(height);
    INT_PARAM_EXPLICIT(seed);

    Stage *stage = new Stage(L, width, height, seed);

    RETURN_OBJ(stage);
    SCRIPT_END();
}

/* stage_destroy() */
static int __stage_destroy(lua_State *L) {
    SCRIPT_BEGIN();
    delete Stage::cur();
    SCRIPT_END();
}

/* local frames = stage_frames() */
static int __stage_frames(lua_State *L) {
    SCRIPT_BEGIN();
    RETURN_INT(Stage::cur()->frames());
    SCRIPT_END();
}
/* local unit = add_unit(attacker, hero, type, x, y) */
static int __add_unit(lua_State *L) {
    SCRIPT_BEGIN();
    INT_PARAM_EXPLICIT(is_attacker);
    INT_PARAM_EXPLICIT(is_hero);
    INT_PARAM_EXPLICIT(type);
    INT_PARAM_EXPLICIT(x);
    INT_PARAM_EXPLICIT(y);

    Unit *unit = Stage::cur()->add_unit(is_attacker, is_hero, type, x, y);

    RETURN_OBJ(unit);
    SCRIPT_END();
}

/* unit_update_callback(func) */
static int __unit_update_callback(lua_State *L) {
    SCRIPT_BEGIN();
    FUNC_PARAM(callback);
    Stage::cur()->unit_update_callback(callback);
    SCRIPT_END();
}

/* stage_loop() */
static int __stage_loop(lua_State *L) {
    SCRIPT_BEGIN();
    BOOL_PARAM(render, false);
    RETURN_INT(Stage::cur()->loop(render));
    SCRIPT_END();
}

/* local id = unit_id(unit) */
static int __unit_id(lua_State *L) {
    SCRIPT_BEGIN();
    UNIT_PARAM(unit);
    RETURN_INT(unit->id());
    SCRIPT_END();
}

/* local target = unit_target(unit) */
static int __unit_target(lua_State *L) {
    SCRIPT_BEGIN();
    UNIT_PARAM(unit);
    RETURN_OBJ(unit->target());
    SCRIPT_END();
}

/* local side = unit_side(unit) */
static int __unit_side(lua_State *L) {
    SCRIPT_BEGIN();
    UNIT_PARAM(unit);
    RETURN_INT(unit->side() ? 1 : 0);
    SCRIPT_END();
}

/* local dir = unit_dir(unit) */
static int __unit_dir(lua_State *L) {
    SCRIPT_BEGIN();
    UNIT_PARAM(unit);
    RETURN_INT(unit->dir());
    SCRIPT_END();
}

/* unit_attack_info(unit, max_w, max_h, min_w, min_h, interval) */
static int __unit_attack_info(lua_State *L) {
    SCRIPT_BEGIN();
    UNIT_PARAM(unit);
    NUM_PARAM_EXPLICIT(attack_max_width);
    NUM_PARAM_EXPLICIT(attack_max_height);
    NUM_PARAM_EXPLICIT(attack_min_width);
    NUM_PARAM_EXPLICIT(attack_min_height);
    INT_PARAM_EXPLICIT(interval);

    unit->set_attack_info(
        attack_min_width, attack_min_height,
        attack_max_width, attack_max_height,
        interval);
    SCRIPT_END();
}

/* unit_body_info(unit, w, h, speed) */
static int __unit_body_info(lua_State *L) {
    SCRIPT_BEGIN();
    UNIT_PARAM(unit);
    NUM_PARAM_EXPLICIT(w);
    NUM_PARAM_EXPLICIT(h);
    NUM_PARAM_EXPLICIT(speed);
    unit->set_body_info(w, h, speed * Cells::cell_size());
    SCRIPT_END();
}

/* unit_search_info(unit, w, h, interval) */
static int __unit_search_info(lua_State *L) {
    SCRIPT_BEGIN();
    UNIT_PARAM(unit);
    NUM_PARAM_EXPLICIT(w);
    NUM_PARAM_EXPLICIT(h);
    NUM_PARAM_EXPLICIT(interval);
    unit->set_search_info(w, h, (unsigned)interval);
    SCRIPT_END();
}

/* state = unit_state(unit, state) */
static int __unit_state(lua_State *L) {
    SCRIPT_BEGIN();
    UNIT_PARAM(unit);
    INT_PARAM_EXPLICIT(state);

    Stage::cur()->unit_state(unit, state);

    RETURN_INT(unit->state());
    SCRIPT_END();
}

/* unit_destroy(unit) */
static int __unit_destroy(lua_State *L) {
    SCRIPT_BEGIN();
    UNIT_PARAM(unit);

    Stage::cur()->destroy_unit(unit);

    SCRIPT_END();
}

/* effect_range(attacker, min_x, min_y, max_x, max_y, func) */
static int __effect_range(lua_State *L) {
    SCRIPT_BEGIN();
    BOOL_PARAM_EXPLICIT(attacker);
    NUM_PARAM_EXPLICIT(min_x);
    NUM_PARAM_EXPLICIT(min_y);
    NUM_PARAM_EXPLICIT(max_x);
    NUM_PARAM_EXPLICIT(max_y);

    Stage::cur()->effect_range(attacker, min_x, min_y, max_x, max_y, 6);

    SCRIPT_END();
}

/* effect_all(attacker, func)
 
 
   function foo(unit)
        unit_state(UNIT_STATE_WALK);
   end
 
   effect_all(true, foo);
   effect_all(false, foo);
*/
static int __effect_all(lua_State *L) {
    SCRIPT_BEGIN();
    INT_PARAM_EXPLICIT(attacker);

    Stage::cur()->effect_all(attacker, 2);

    SCRIPT_END();
}

/* x, y, dir = unit_pos(unit) */
static int __unit_pos(lua_State *L) {
    SCRIPT_BEGIN();
    UNIT_PARAM(unit);

    auto &pos = unit->pos();
    RETURN_NUM(pos.x());
    RETURN_NUM(pos.y());
    RETURN_NUM(unit->dir());
    SCRIPT_END();
}


static int __unit_cpos(lua_State *L) {
    SCRIPT_BEGIN();
    UNIT_PARAM(unit);
    RETURN_NUM(unit->cell()->pos.x());
    RETURN_NUM(unit->cell()->pos.y());
    SCRIPT_END();
}

static int __get_value(lua_State *L) {
    SCRIPT_BEGIN();
    UNIT_PARAM(unit);
    while (1) {
        INT_PARAM(index, 0);
        if (!index) {
            break;
        }
        RETURN_NUM(unit->get_value(index));
    }
    SCRIPT_END();
}

static int __rand(lua_State *L) {
    SCRIPT_BEGIN();
    RETURN_INT(Stage::cur()->rand() & ~(1 << 31));
    SCRIPT_END();
}

#define VALUE_DEF(N)                        \
static int __set_value_##N(lua_State *L) {  \
    SCRIPT_BEGIN();                         \
    UNIT_PARAM(unit);                       \
    NUM_PARAM(value, 0);                    \
    unit->set_value((N - 1), value);        \
    SCRIPT_END();                           \
}                                           \
                                            \
static int __get_value_##N(lua_State *L) {  \
    SCRIPT_BEGIN();                         \
    UNIT_PARAM(unit);                       \
    RETURN_NUM(unit->get_value(N - 1));     \
    SCRIPT_END();                           \
}

VALUE_DEF(1)
VALUE_DEF(2)
VALUE_DEF(3)
VALUE_DEF(4)
VALUE_DEF(5)
VALUE_DEF(6)
VALUE_DEF(7)
VALUE_DEF(8)
VALUE_DEF(9)
VALUE_DEF(10)
VALUE_DEF(11)
VALUE_DEF(12)
VALUE_DEF(13)
VALUE_DEF(14)
VALUE_DEF(15)
VALUE_DEF(16)

#undef VALUE_DEF
#define VALUE_DEF(N)                                \
lua_register(L, "set_value_" #N, __set_value_##N);  \
lua_register(L, "get_value_" #N, __get_value_##N);

void libfight_init(lua_State *L) {
    lua_register(L, "libfight_init",            __libfight_init);
    lua_register(L, "stage_create",             __stage_create);
    lua_register(L, "stage_destroy",            __stage_destroy);
    lua_register(L, "add_unit",                 __add_unit);
    lua_register(L, "unit_update_callback",     __unit_update_callback);
    lua_register(L, "stage_loop",               __stage_loop);
    lua_register(L, "unit_id",                  __unit_id);
    lua_register(L, "unit_attack_info",         __unit_attack_info);
    lua_register(L, "unit_search_info",         __unit_search_info);
    lua_register(L, "unit_body_info",           __unit_body_info);
    lua_register(L, "unit_state",               __unit_state);
    lua_register(L, "unit_destroy",             __unit_destroy);
    lua_register(L, "effect_range",             __effect_range);
    lua_register(L, "effect_all",               __effect_all);
    lua_register(L, "unit_pos",                 __unit_pos);
    lua_register(L, "unit_cpos",                __unit_cpos);
    lua_register(L, "get_value",                __get_value);
    lua_register(L, "stage_frames",             __stage_frames);
    lua_register(L, "unit_target",              __unit_target);
    lua_register(L, "unit_side",                __unit_side);
    lua_register(L, "unit_dir",                 __unit_dir);
    lua_register(L, "rand",                     __rand);

    VALUE_DEF(1)
    VALUE_DEF(2)
    VALUE_DEF(3)
    VALUE_DEF(4)
    VALUE_DEF(5)
    VALUE_DEF(6)
    VALUE_DEF(7)
    VALUE_DEF(8)
    VALUE_DEF(9)
    VALUE_DEF(10)
    VALUE_DEF(11)
    VALUE_DEF(12)
    VALUE_DEF(13)
    VALUE_DEF(14)
    VALUE_DEF(15)
    VALUE_DEF(16)
}

