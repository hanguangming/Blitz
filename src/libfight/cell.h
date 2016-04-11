#ifndef __LIBFIGHT_CELL_H__
#define __LIBFIGHT_CELL_H__

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

#include "unit.h"

class Range;

/* Grid */
struct Grid {
    Vector2i pos;
    UnitSideLists lists;
};

/* Cell */
struct Cell {
    Vector2f center() const;
    Vector2f pos;
    Grid *grid;
    UnitSideLists lists;
};

/* Cells */
class Cells {
    friend class Cell;
    friend class Stage;
public:
    Cells(unsigned pw, unsigned ph);
    Cell *get_cell(int x, int y) {
        return _cells + _cw * y + x;
    }
    Cell *get_cell(const Vector2f &pos) {
        return get_cell(pos.x(), pos.y());
    }
    Cell *get_cell(const Vector2i &pos) {
        return get_cell(pos.x(), pos.y());
    }
    Grid *get_grid(int x, int y) {
        return _grids + _gw * y + x;
    }
    Grid *get_grid(const Vector2i &pos) {
        return get_grid(pos.x(), pos.y());
    }
    int cw() const {
        return _cw;
    }
    int ch() const {
        return _ch;
    }
    int gw() const {
        return _gw;
    }
    int gh() const {
        return _gh;
    }

    void get_range(bool attacker, const AlignedBox2f &box, Range *range);

    static void init(unsigned pw, unsigned ph, unsigned cs, unsigned gw, unsigned gh);
    static float distance(const Cell *c1, const Cell *c2) {
        Vector2f v = c1->pos - c2->pos;
        unsigned dx = v.x() < 0 ? -v.x() : v.x();
        unsigned dy = v.y() < 0 ? -v.y() : v.y();
        return _distances[dy * _max_cw + dx];
    }
    static unsigned cell_size() {
        return _cell_size;
    }
private:
    int _cw;
    int _ch;
    int _gw;
    int _gh;

    Cell *_cells;
    Grid *_grids;
    AlignedBox2f _box;

    static unsigned _max_cw;
    static unsigned _max_ch;
    static unsigned _cell_size;
    static unsigned _grid_width;
    static unsigned _grid_height;
    static unsigned _max_width;
    static unsigned _max_height;
    static std::vector<float> _distances;
};

/* Range */
class Range {
    friend class Cells;
public:
    Unit *next() {
        while (1) {
            while (_unit) {
                Unit *tmp = _unit;
                _unit = LIST_NEXT(_unit, _grid_entry);
                if (!tmp->_died && _cbox.contains(tmp->cell()->pos)) {
                    return tmp;
                }
            }
            if (_cur->pos.x() < _gmax->pos.x()) {
                _cur = _cells->get_grid(_cur->pos.x() + 1, _cur->pos.y());
            }
            else if (_cur->pos.y() < _gmax->pos.y()) {
                _cur = _cells->get_grid(_gmin->pos.x(), _cur->pos.y() + 1);
            }
            else {
                break;
            }
            _unit = LIST_FIRST(_cur->lists.list(_attacker));
        }
        return nullptr;
    }
private:
    AlignedBox2f _cbox;
    Grid *_gmin;
    Grid *_gmax;
    Grid *_cur;
    Unit *_unit;
    Cells *_cells;
    bool _attacker;
};

inline Vector2f Cell::center() const {
    return Vector2f(Cells::_cell_size * (pos.x() + 0.5), Cells::_cell_size * (pos.y() + 0.5));
}

#endif

