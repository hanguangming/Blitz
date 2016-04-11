#ifndef __STAGE_H__
#define __STAGE_H__

#include <unordered_set>
#include <cstdlib>
#include <vector>
#include <cstdint>

extern "C" {
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
}
#include "Eigen/Eigen"
using namespace Eigen;
#include "bsd_queue.h"

#include "hash.h"
#include "unit.h"
#include "cell.h"

class Stage;

/* Size */
struct Size {
    Size() : width(), height() 
    { }

    Size(unsigned w, unsigned h)
    : width(w), height(h)
    { }

    unsigned width;
    unsigned height;
};


/* Stage */
class Stage {
    friend class Unit;
public:
    Stage(lua_State *L, unsigned width, unsigned height, unsigned seed);
    ~Stage();
    unsigned frames() const {
        return _frames;
    }
    Unit *get_unit(unsigned id) const {
        static Unit tmp;
        tmp._id = id;
        tmp._hash = hash_iterative(&tmp._id, sizeof(tmp._id));
        auto it = _units.find(&tmp);
        if (it == _units.end()) {
            return nullptr;
        }
        return *it;
    }
    Unit *add_unit(bool is_attacker, bool is_hero, int type, int x, int y);
    void destroy_unit(Unit *unit);
    float unit_distance(Unit *unit1, Unit *unit2) {
        return Cells::distance(unit1->_cell, unit2->_cell);
    }

    void use();
    static Stage *cur() {
        return LIST_FIRST(&_stage_list);
    }
    unsigned loop(bool render);
    void unit_die(Unit *unit);
    void unit_update_callback(int cb);
    void unit_state(Unit *unit, unsigned state);
    void effect_range(bool attacker, int min_x, int min_y, int max_x, int max_y, int func);
    void effect_all(bool attacker, int func);
    unsigned rand();
private:
    struct unit_hash {
        size_t operator()(const Unit *unit) const {
            return unit->_hash;
        }
    };
    struct unit_cmp {
        bool operator()(const Unit *lhs, const Unit *rhs) const {
            return lhs->_id == rhs->_id;
        }
    };
    void update_unit_pos(Unit *unit, const Vector2f &pos);
    void update_unit_state(Unit *unit, unsigned value);
    void update_unit_box(Unit *unit);
    void update_unit_dir(Unit *unit);
    bool unit_update(Unit *unit, bool render);
    void unit_search(Unit *unit);
    bool unit_call_update(Unit *unit, bool render);
    void unit_try_search(Unit *unit);
    void unit_move(Unit *unit);
    int unit_attack_distance_check(Unit *unit, Unit *target);
    bool unit_attack_pos_check(Unit *unit);
    bool unit_attack_time_check(Unit *unit);
private:
    lua_State *_lua;
    Cells _cells;
    unsigned _num;
    std::unordered_set<Unit*, unit_hash, unit_cmp> _units;
    UnitSideLists _unit_lists;
    unit_list_t _unit_state_lists[UNIT_STATE_UNKNOWN];
    unit_list_t _die_list;
    unit_list_t _move_list;
    unsigned _frames;
    LIST_ENTRY(Stage) _entry;
    static LIST_HEAD(stage_list_t, Stage) _stage_list;
    int _unit_update_cb;
    bool _order;
    unsigned _seed;
};


#endif

