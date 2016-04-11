#ifndef __LIBFIGHT_UNIT_H__
#define __LIBFIGHT_UNIT_H__

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

class Stage;
class Cell;
//#define FIGHT_INFO_DUMP

/* Unit */
enum {
    UNIT_STATE_INIT,
    UNIT_STATE_STAY,
    UNIT_STATE_WALK,
    UNIT_STATE_ATTACK,
    UNIT_STATE_ATTACK_INTERVAL,
    UNIT_STATE_ATTACK_WALK,
    UNIT_STATE_DIE,
    UNIT_STATE_UNKNOWN,
};

class Unit {
    friend class Stage;
    friend class Range;
    
public:
    unsigned id() const {
        return _id;
    }
    unsigned state() const {
        return _state;
    }
    void state(unsigned value);
    void set_search_info(int width, int height, unsigned interval) {
        _origin_search_box.min() = Vector2f(-width, -height);
        _origin_search_box.max() = Vector2f(width, height);
        _search_interval = interval;
#ifdef FIGHT_INFO_DUMP
        fprintf(stderr, "search_info w=%d, h=%d, interval=%d\n", width, height, interval);
#endif
    }
    void set_attack_info(float min_w, float min_h, float max_w, float max_h, unsigned interval) {
        //max_w++;
        //max_h++;
        _origin_attack_max_box.min() = Vector2f(-max_w, -max_h);
        _origin_attack_max_box.max() = Vector2f(max_w, max_h);
        _origin_attack_min_box.min() = Vector2f(-min_w, -min_h);
        _origin_attack_min_box.max() = Vector2f(min_w, min_h);
        _attack_interval = interval;
#ifdef FIGHT_INFO_DUMP
        fprintf(stderr, "attack_info min_w=%f, min_h=%f, max_w=%f, max_h=%f, interval=%d\n", 
                (double)min_w, (double)min_h, (double)max_w, (double)max_h, interval);
#endif

    }
    void set_body_info(float width, float height, float speed) {
        _origin_body_box.min() = Vector2f(-width, -height);
        _origin_body_box.max() = Vector2f(width, height);
        _speed = speed;
        if (_attacker) {
            _dir.x() = _speed;
        }
        else {
            _dir.x() = -_speed;
        }
#ifdef FIGHT_INFO_DUMP
        fprintf(stderr, "body_info w=%f, h=%f, speed=%f\n", (double)width, (double)height, (double)speed);
#endif
    }
    Cell *cell() {
        return _cell;
    }
    void target(Unit *t) {
        if (_target != t) {
            if (_target) {
                LIST_REMOVE(this, _target_entry);
            }
            if (t) {
                assert(_attacker != t->_attacker);
                LIST_INSERT_HEAD(&t->_target_list, this, _target_entry);
            }
            else {
                _search_frames = 0;
            }
            _target = t;
        }
    }
    Unit *target() {
        return _target;
    }
    bool side() {
        return _attacker;
    }
    int dir() {
        return _dir.x() < 0 ? -1 : 1;
    }
    double get_value(int index) {
        assert(index >= 0 && (unsigned)index < sizeof(_values) / sizeof(double));
        return _values[index];
    }
    void set_value(int index, double value) {
        assert(index >= 0 && (unsigned)index < sizeof(_values) / sizeof(double));
        _values[index] = value;
    }
    const Vector2f &pos() const {
        return _pos;
    }
    float dir() const {
        return _dir.x();
    }
private:
    unsigned _id;
    unsigned _state;
    size_t _hash;
    unsigned _type;
    bool _attacker;
    bool _hero;
    Cell *_cell;
    Cell *_cell2;
    Stage *_stage;
    Vector2f _pos;

    double _values[16];

    AlignedBox2f _body_box;
    AlignedBox2f _attack_max_box;
    AlignedBox2f _attack_min_box;
    AlignedBox2f _search_box;

    AlignedBox2f _origin_body_box;
    AlignedBox2f _origin_attack_max_box;
    AlignedBox2f _origin_attack_min_box;
    AlignedBox2f _origin_search_box;

    float _speed;
    Unit *_target;
    Vector2f _dir;

    bool _died;
    bool _destroy;

    unsigned _search_frames;
    unsigned _search_interval;
    unsigned _attack_frames;
    unsigned _attack_interval;

    LIST_HEAD(, Unit) _target_list;
    LIST_ENTRY(Unit) _side_entry;
    LIST_ENTRY(Unit) _state_entry;
    LIST_ENTRY(Unit) _grid_entry;
    LIST_ENTRY(Unit) _cell_entry;
    LIST_ENTRY(Unit) _target_entry;
    LIST_ENTRY(Unit) _die_entry;
    LIST_ENTRY(Unit) _move_entry;
};

typedef LIST_HEAD(, Unit) unit_list_t;

class UnitSideLists {
public:
    UnitSideLists() {
        init();
    }
    unit_list_t *list(bool attacker) {
        return _lists + (attacker ? 0 : 1);
    }
    void init() {
        LIST_INIT(_lists);
        LIST_INIT(_lists + 1);
    }
private:
    unit_list_t _lists[2];
};

#endif
