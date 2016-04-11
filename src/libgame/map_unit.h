#ifndef __LIBGAME_MAP_UNIT_H__
#define __LIBGAME_MAP_UNIT_H__

#include "game.h"
#include "fight.h"

class G_MapSide;
class G_MapFightItem;

class G_MapUnit {
    friend class G_Map;
    friend class G_MapCity;
public:
    G_MapUnit(unsigned type) noexcept;

    virtual unsigned unit_id() const noexcept = 0;

    virtual const std::string &name() const noexcept {
        return _name;
    }
    virtual unsigned vip() const noexcept {
        return 0;
    }
    virtual G_MapSide *side() const noexcept {
        return _side;
    }
    virtual unsigned level() const noexcept {
        return 0;
    }
    virtual unsigned appearance() const noexcept {
        return 0;
    }
    unsigned unit_type() const noexcept {
        return _unit_type;
    }
    unsigned state() const noexcept {
        return _state;
    }
    virtual void get_corps(G_FightCorps *corps) noexcept = 0;
    virtual void set_corps(const G_FightCorps *corps) noexcept = 0;
    virtual void fight_finish() noexcept = 0;
protected:
    unsigned _unit_type;
    G_MapSide *_side;
    std::string _name;
    unsigned _state;
public:
    clist_entry _unit_entry;
};

class G_MapUnitList : protected gx_list(G_MapUnit, _unit_entry) {
    typedef gx_list(G_MapUnit, _unit_entry) base_type;
public:
    G_MapUnitList() noexcept 
    : _count() 
    { }

    using base_type::begin;
    using base_type::end;
    using base_type::empty;
    using base_type::front;
    using base_type::pop_front;

    void push_back(G_MapUnit *unit) noexcept {
        base_type::push_back(unit);
        _count++;
    }

    void remove(G_MapUnit *unit) noexcept {
        base_type::remove(unit);
        _count--;
        assert(_count >= 0);
    }

    unsigned count() const noexcept {
        return _count;
    }
private:
    unsigned _count;
};

#endif

