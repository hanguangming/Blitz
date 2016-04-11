#include "cell.h"

unsigned Cells::_cell_size  = 16;
unsigned Cells::_grid_width  = 5;
unsigned Cells::_grid_height = 5;
unsigned Cells::_max_width   = 0;
unsigned Cells::_max_height  = 0;
unsigned Cells::_max_cw = 0;
unsigned Cells::_max_ch = 0;

std::vector<float> Cells::_distances;

void Cells::init(unsigned pw, unsigned ph, unsigned cs, unsigned gw, unsigned gh) {
    if (_distances.size()) {
        return;
    }
    _cell_size = cs;
    _grid_width = gw;
    _grid_height = gh;
    _max_width = pw;
    _max_height = ph;

    _max_cw = pw / cs;
    _max_ch = ph / cs;

    if (pw % cs) {
        ++_max_cw;
    }
    if (ph % cs) {
        ++_max_ch;
    }

    _distances.resize(_max_cw * _max_ch);
    for (unsigned x = 0; x < _max_cw; ++x) {
        for (unsigned y = 0; y < _max_ch; ++y) {
            _distances[y * _max_cw + x] = std::sqrt(x * x + y * y);
        }
    }
}

Cells::Cells(unsigned pw, unsigned ph) {
    if (pw > _max_width) {
        pw = _max_width;
    }
    if (ph > _max_height) {
        ph = _max_height;
    }

    _cw = pw / _cell_size;
    _ch = ph / _cell_size;
    if (pw % _cell_size) {
        _cw++;
    }
    if (ph % _cell_size) {
        _ch++;
    }
    if (_cw < 1) {
        _cw = 1;
    }
    if (_ch < 1) {
        _ch = 1;
    }
    _gw = _cw / _grid_width;
    _gh = _ch / _grid_height;
    if (_cw % _grid_width) {
        _gw++;
    }
    if (_ch % _grid_height) {
        _gh++;
    }

    _cells = (Cell*)std::malloc(sizeof(Cell) * _cw * _ch);
    memset(_cells, 0, sizeof(Cell) * _cw * _ch);
    _grids = (Grid*)std::malloc(sizeof(Grid) * _gw * _gh);
    memset(_grids, 0, sizeof(Grid) * _gw * _gh);

    for (int x = 0; x < _gw; ++x) {
        for (int y = 0; y < _gh; ++y) {
            Grid *g = get_grid(x, y);
            g->pos = Vector2i(x, y);
        }
    }

    for (int x = 0; x < _cw; ++x) {
        for (int y = 0; y < _ch; ++y) {
            Cell *c = get_cell(x, y);
            Grid *g = get_grid(x / _grid_width, y / _grid_height);
            c->pos = Vector2f(x, y);
            c->grid = g;
        }
    }
    _box.min() = Vector2f(0, 0);
    _box.max() = Vector2f(_cw - 1, _ch - 1);
}

void Cells::get_range(bool attacker, const AlignedBox2f &box, Range *range) {
    range->_attacker = attacker;
    range->_cbox = box.intersection(_box);
    range->_cells = this;
    Cell *cell_min = get_cell(range->_cbox.min());
    Cell *cell_max = get_cell(range->_cbox.max());
    range->_gmin = cell_min->grid;
    range->_gmax = cell_max->grid;

    range->_cur = range->_gmin;
    range->_unit = LIST_FIRST(range->_cur->lists.list(attacker));
}



