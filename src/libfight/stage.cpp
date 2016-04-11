#include <cstdlib>
#include <cstring>
#include "stage.h"

/* Stage */
Stage::stage_list_t Stage::_stage_list = LIST_HEAD_INITIALIZER(_stage_list);

Stage::Stage(lua_State *L, unsigned width, unsigned height, unsigned seed) 
: _lua(L),
  _cells(width, height),
  _num(),
  _frames(),
  _unit_update_cb(LUA_NOREF)
{
    LIST_INSERT_HEAD(&_stage_list, this, _entry);

    for (unsigned i = 0; i < UNIT_STATE_UNKNOWN; ++i) {
        LIST_INIT(_unit_state_lists + i);
    }
    LIST_INIT(&_die_list);
    LIST_INIT(&_move_list);
    _order = true;
    _seed = seed;
}

Stage::~Stage() {
    for (auto it = _units.begin(); it != _units.end();) {
        Unit *unit = *it;
        ++it;
        free(unit);
    }
    LIST_REMOVE(this, _entry);
    if (_unit_update_cb != LUA_NOREF) {
        luaL_unref(_lua, LUA_REGISTRYINDEX, _unit_update_cb);
    }
}

void Stage::use() {
    LIST_REMOVE(this, _entry);
    LIST_INSERT_HEAD(&_stage_list, this, _entry);
}

void Stage::unit_state(Unit *unit, unsigned state) {
    if (state == UNIT_STATE_DIE) {
        unit_die(unit);
        return;
    }
    update_unit_state(unit, state);
}

Unit *Stage::add_unit(bool is_attacker, bool is_hero, int type, int x, int y) {

    Unit *unit = (Unit*)std::malloc(sizeof(Unit));
    std::memset(unit, 0, sizeof(Unit));

    unit->_id = ++_num;
    unit->_hash = hash_iterative(&unit->_id, sizeof(unit->_id));
    _units.emplace(unit);
    unit->_type = type;
    unit->_stage = this;
    unit->_attacker = is_attacker;
    unit->_state = UNIT_STATE_INIT;
    unit->_hero = is_hero;

    if (x < 0) {
        x = 0;
    }
    else if (x >= _cells.cw()) {
        x = _cells.cw() - 1;
    }
    if (y < 0) {
        y = 0;
    }
    else if (y >= _cells.ch()) {
        y = _cells.ch() - 1;
    }
    unit->_cell = _cells.get_cell(x, y);
    unit->_cell2 = unit->_cell;
    unit->_pos = unit->_cell->center();

    LIST_INSERT_HEAD(_unit_lists.list(is_attacker), unit, _side_entry);
    LIST_INSERT_HEAD(unit->_cell->grid->lists.list(is_attacker), unit, _grid_entry);
    LIST_INSERT_HEAD(unit->_cell->lists.list(is_attacker), unit, _cell_entry);
    LIST_INSERT_HEAD(_unit_state_lists + unit->_state, unit, _state_entry);
    return unit;
}

void Stage::destroy_unit(Unit *unit) {
    if (unit->_state != UNIT_STATE_DIE) {
        return;
    }
    if (unit->_destroy) {
        return;
    }
    unit->_destroy = true;
    LIST_REMOVE(unit, _state_entry);
}

inline void Stage::update_unit_state(Unit *unit, unsigned new_state) {
    if (unit->_state == new_state) {
        return;
    }
    if (new_state >= UNIT_STATE_UNKNOWN) {
        return;
    }
    if (new_state == UNIT_STATE_INIT) {
        return;
    }
    switch (unit->_state) {
    case UNIT_STATE_INIT:
        update_unit_box(unit);
        break;
    case UNIT_STATE_DIE:
        return;
    }

    unit->_state = new_state;
    LIST_REMOVE(unit, _state_entry);
    LIST_INSERT_HEAD(_unit_state_lists + new_state, unit, _state_entry);

    switch (new_state) {
    case UNIT_STATE_DIE: {
        unit_die(unit);
        unit->target(nullptr);
        LIST_REMOVE(unit, _side_entry);
        LIST_REMOVE(unit, _cell_entry);
        LIST_REMOVE(unit, _grid_entry);
        break;
    }
    default:
        update_unit_dir(unit);
        break;
    }
}

void Stage::unit_update_callback(int cb) {
    if (_unit_update_cb != LUA_NOREF) {
        luaL_unref(_lua, LUA_REGISTRYINDEX, _unit_update_cb);
    }
    _unit_update_cb = cb;
}

inline bool Stage::unit_call_update(Unit *unit, bool render) {
    if (!render) {
        if (unit->_state != UNIT_STATE_ATTACK) {
            return true;
        }
    }
    if (_unit_update_cb != LUA_NOREF) {
        lua_rawgeti(_lua, LUA_REGISTRYINDEX, _unit_update_cb);
        int top = lua_gettop(_lua);
        lua_pushlightuserdata(_lua, unit);            // unit
        lua_pushinteger(_lua, unit->_id);             // id
        lua_pushinteger(_lua, unit->_attacker);       // attacker
        lua_pushinteger(_lua, _frames);               // frames
        lua_pushinteger(_lua, unit->_state);          // state
        lua_pushlightuserdata(_lua, unit->_target);   // target
        if (render) {
            lua_pushnumber(_lua, unit->_pos.x());     // x
            lua_pushnumber(_lua, unit->_pos.y());     // y
            lua_pushnumber(_lua, unit->_dir.x());     // dir
        }
        if (lua_pcall(_lua, lua_gettop(_lua) - top, 0, 0)) {
            const char *error = lua_tostring(_lua, -1);
            fprintf(stderr, "unit_update: %s\n", error);
            lua_pop(_lua, 1);
            return false;
        }
        return true;
    }
    return false;
}

inline void Stage::update_unit_box(Unit *unit) {
    unit->_attack_max_box = unit->_origin_attack_max_box;
    unit->_attack_max_box.translate(unit->_cell->pos);
    unit->_attack_min_box = unit->_origin_attack_min_box;
    unit->_attack_min_box.translate(unit->_cell->pos);
    unit->_body_box = unit->_origin_body_box;
    unit->_body_box.translate(unit->_cell->pos);
    unit->_search_box = unit->_origin_search_box;
    unit->_search_box.translate(unit->_cell->pos);
}

inline void Stage::update_unit_pos(Unit *unit, const Vector2f &pos) {
    int x = pos.x() / Cells::_cell_size;
    int y = pos.y() / Cells::_cell_size;

    if (x < 0) {
        x = 0;
    }
    else if (x >= _cells.cw()) {
        x = _cells.cw() - 1;
    }

    if (y < 0) {
        y = 0;
    }
    else if (y >= _cells.ch()) {
        y = _cells.ch() - 1;
    }

    unit->_pos = pos;
    Cell *cell = _cells.get_cell(x, y);

    if (cell != unit->_cell) {
        unit->_cell2 = cell;
        LIST_INSERT_HEAD(&_move_list, unit, _move_entry);
    }
}

void Stage::unit_search(Unit *unit) {
    if (unit->_died) {
        return;
    }
    AlignedBox2f box;

    Unit *target = LIST_FIRST(&unit->_target_list);
    
    if (target && target->_died) {
        target = nullptr;
    }
    float d = 100000;
    if (target || unit->_target) {

        if (target) {
            d = unit_distance(unit, target);
        }
        if (unit->_target) {
            float d2 = unit_distance(unit, unit->_target);
            if (d2 < d) {
                d = d2;
            }
        }

        box.min() = Vector2f(-d, -d);
        box.max() = Vector2f(d, d);
        box.translate(unit->_cell->pos);
        box = box.intersection(unit->_search_box);
    }
    else {
        box = unit->_search_box;
    }

    Range range;
    _cells.get_range(!unit->_attacker, box, &range);

    Unit *u, *atarget = nullptr;
    target = nullptr;
    float d_max = 1000000, d_amax = 1000000;
    while ((u = range.next())) {
        d = unit_distance(unit, u);
        if (unit_attack_distance_check(unit, u)) {
            if (d < d_max) {
                d_max = d;
                target = u;
            }
        }
        else {
            if (d < d_amax) {
                d_amax = d;
                atarget = u;
            }
        }
    }

    if (atarget) {
        target = atarget;
    }
    if (target) {
        unit->target(target);
    }
    else {
        if (unit->_target && unit->_target->_died) {
            unit->target(nullptr);
        }
    }
}

void Stage::unit_die(Unit *unit) {
    if (unit->_died) {
        return;
    }
    unit->_died = true;
    LIST_INSERT_HEAD(&_die_list, unit, _die_entry);
    Unit *u;
    while ((u = LIST_FIRST(&unit->_target_list))) {
        assert(u->_target == unit);
        u->target(nullptr);
    }
}

inline void Stage::unit_try_search(Unit *unit) {
    unit->_search_interval = 30;
    if (!unit->_search_frames || (_frames - unit->_search_frames) >= unit->_search_interval) {
        unit->_search_frames = _frames;
        unit_search(unit);
    }
}

inline void Stage::update_unit_dir(Unit *unit) {
    if (unit->_target) {
        unit->_dir = unit->_target->_pos - unit->_pos;
        unit->_dir.normalize();
        unit->_dir *= unit->_speed;
    }
    else {
        if (unit->_attacker) {
            unit->_dir.x() = unit->_speed;
            unit->_dir.y() = 0;
        }
        else {
            unit->_dir.x() = -unit->_speed;
            unit->_dir.y() = 0;
        }
    }
}

inline void Stage::unit_move(Unit *unit) {
    if (unit->_died) {
        return;
    }
    if (unit->_state != UNIT_STATE_ATTACK_WALK) {
        update_unit_dir(unit);
    }
    update_unit_pos(unit, unit->_pos + unit->_dir);
}

inline int Stage::unit_attack_distance_check(Unit *unit, Unit *target) {
    if (!unit->_attack_max_box.intersects(target->_body_box)) {
        return 1;
    }
    return 0;
}

inline bool Stage::unit_attack_pos_check(Unit *unit) {
    if (unit->_died) {
        return true;
    }

    Unit *u;
    if (unit->_hero) {
        return true;
    }
    unsigned count = 0;
    unit_list_t *list = unit->_cell->lists.list(unit->_attacker);
    LIST_FOREACH(u, list, _cell_entry) {
        if (u != unit && ((u->_state == UNIT_STATE_ATTACK) || (u->_state == UNIT_STATE_ATTACK_INTERVAL))) {
            ++count;
            if (count >= 3) {
                return false;
            }
        }
    }
    return true;
}

inline bool Stage::unit_attack_time_check(Unit *unit) {
    return !unit->_attack_frames || _frames - unit->_attack_frames >= unit->_attack_interval;
}

inline bool Stage::unit_update(Unit *unit, bool render) {
    switch (unit->_state) {
    case UNIT_STATE_INIT:
        return true;
    case UNIT_STATE_STAY:
        break;
    case UNIT_STATE_WALK:
        unit_try_search(unit);
        if (unit->_target) {
            if (!unit_attack_distance_check(unit, unit->_target)) {
                if (unit_attack_pos_check(unit)) {
                    if (unit_attack_time_check(unit)) {
                        update_unit_state(unit, UNIT_STATE_ATTACK);
                        unit->_attack_frames = _frames;
                    }
                    else {
                        update_unit_state(unit, UNIT_STATE_ATTACK_INTERVAL);
                    }
                }
                else {
                    update_unit_state(unit, UNIT_STATE_ATTACK_WALK);
                }
                break;
            }
        }
        unit_move(unit);
        break;
    case UNIT_STATE_ATTACK_WALK:
        unit_try_search(unit);
        if (unit->_target) {
            if (!unit_attack_distance_check(unit, unit->_target)) {
                if (unit_attack_pos_check(unit)) {
                    if (unit_attack_time_check(unit)) {
                        update_unit_state(unit, UNIT_STATE_ATTACK);
                        unit->_attack_frames = _frames;
                    }
                    else {
                        update_unit_state(unit, UNIT_STATE_ATTACK_INTERVAL);
                    }
                }
                else {
                    unit_move(unit);
                }
                break;
            }
        }
        update_unit_state(unit, UNIT_STATE_WALK);
        break;
    case UNIT_STATE_ATTACK:
        update_unit_state(unit, UNIT_STATE_ATTACK_INTERVAL);
    case UNIT_STATE_ATTACK_INTERVAL:
        unit_try_search(unit);
        if (unit->_target) {
            if (0 && unit->_died) {
                if (!unit->_attack_frames || (_frames - unit->_attack_frames) >= (unit->_attack_interval * 3 / 4)) {
                    update_unit_state(unit, UNIT_STATE_ATTACK);
                }
            }
            else if (!unit_attack_distance_check(unit, unit->_target)) {
                if (unit_attack_pos_check(unit)) {
                    if (unit_attack_time_check(unit)) {
                        update_unit_state(unit, UNIT_STATE_ATTACK);
                        unit->_attack_frames = _frames;
                    }
                }
                break;
            }
        }
        update_unit_state(unit, UNIT_STATE_WALK);
        break;
    case UNIT_STATE_DIE:
        return true;
    default:
        return false;
    }

    unit_call_update(unit, render);

    return true;
}

unsigned Stage::loop(bool render) {
    Unit *unit, *unit1, *unit2, *tmp;
    unit_list_t *list;

    unit1 = LIST_FIRST(_unit_lists.list(true));
    unit2 = LIST_FIRST(_unit_lists.list(false));

    if (!unit1 || !unit2) {
        if (unit2) {
            return 2;
        }
        else {
            return 1;
        }
    }

    ++_frames;
    while (unit1 || unit2) {
        if (_order && unit1) {
            if (!unit_update(unit1, render)) {
                return 3;
            }
            unit1 = LIST_NEXT(unit1, _side_entry);
        }
        else if (unit2) {
            if (!unit_update(unit2, render)) {
                return 3;
            }
            unit2 = LIST_NEXT(unit2, _side_entry);
        }
        _order = !_order;
    }

    unit = LIST_FIRST(&_move_list);
    while (unit) {
        tmp = LIST_NEXT(unit, _move_entry);
        LIST_REMOVE(unit, _move_entry);
        if (unit->_cell != unit->_cell2) {
            if (unit->_cell->grid != unit->_cell2->grid) {
                LIST_REMOVE(unit, _grid_entry);
                LIST_INSERT_HEAD(unit->_cell2->grid->lists.list(unit->_attacker), unit, _grid_entry);
            }

            LIST_REMOVE(unit, _cell_entry);
            LIST_INSERT_HEAD(unit->_cell2->lists.list(unit->_attacker), unit, _cell_entry);
            unit->_cell = unit->_cell2;
            update_unit_box(unit);
        }
        unit = tmp;
    }

    while ((unit = LIST_FIRST(&_die_list))) {
        LIST_REMOVE(unit, _die_entry);
        update_unit_state(unit, UNIT_STATE_DIE);
    }

    list = _unit_state_lists + UNIT_STATE_DIE;
    LIST_FOREACH_SAFE(unit, list, _state_entry, tmp) {
        if (!unit_call_update(unit, render)) {
            return 3;
        }
    }

    return 0;
}

void Stage::effect_range(bool attacker, int min_x, int min_y, int max_x, int max_y, int func) {
    Range range;
    AlignedBox2f box(Vector2f(min_x, min_y), Vector2f(max_x, max_y));
    _cells.get_range(attacker, box, &range);
    Unit *unit;
    while ((unit = range.next())) {
        lua_pushvalue(_lua, func);
        lua_pushlightuserdata(_lua, unit);
        if (lua_pcall(_lua, 1, 0, 0)) {
            const char *error = lua_tostring(_lua, -1);
            fprintf(stderr, "effect_range: %s\n", error);
            lua_pop(_lua, 1);
            return;
        }
    }

}

void Stage::effect_all(bool attacker, int func) {
    unit_list_t *list = _unit_lists.list(attacker);
    Unit *unit, *tmp;
    LIST_FOREACH_SAFE(unit, list, _side_entry, tmp) {
        lua_pushvalue(_lua, func);
        lua_pushlightuserdata(_lua, unit);
        if (lua_pcall(_lua, 1, 1, 0)) {
            const char *error = lua_tostring(_lua, -1);
            fprintf(stderr, "effect_all: %s\n", error);
            lua_pop(_lua, 1);
            return;
        }
        int n;
        if (lua_isnil(_lua, -1)) {
            n = 1;
        }
        else {
            assert(lua_isboolean(_lua, -1));
            n = lua_toboolean(_lua, -1);
            lua_pop(_lua, 1);
        }
        if (!n) {
            break;
        }
    }
}

unsigned Stage::rand() {
    unsigned int next = _seed;
    int result;

    next *= 1103515245;
    next += 12345;
    result = (unsigned int) (next / 65536) % 2048;

    next *= 1103515245;
    next += 12345;
    result <<= 10;
    result ^= (unsigned int) (next / 65536) % 1024;

    next *= 1103515245;
    next += 12345;
    result <<= 10;
    result ^= (unsigned int) (next / 65536) % 1024;

    _seed = next;

    return result;
}

