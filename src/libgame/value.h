#ifndef __LIBGAME_VALUE_H__
#define __LIBGAME_VALUE_H__

#include <array>
#include <vector>
#include "game.h"
#include "libgame/g_value.h"
#include "dbsvr/db_login.h"

class DB_LoginRsp;

class G_ValueOpts {
    friend class G_ValuesBase;
    friend class G_AgentContext;
public:
    const std::vector<G_ValueOpt> &opts() const noexcept {
        return _opts;
    }
private:
    std::vector<G_ValueOpt> _opts;
};

class G_ValuesBase : public Object {
protected:
    virtual void mark_update(unsigned index, unsigned value) noexcept;
};

template <unsigned _MaxID>
class G_Values : public G_ValuesBase {
    typedef std::array<unsigned, _MaxID> array_type;
public:
    G_Values() noexcept : _values() { }
    unsigned get(unsigned index) const noexcept {
        assert(index < _MaxID);
        return _values[index];
    }
    unsigned set(unsigned index, unsigned value) noexcept {
        assert(index < _MaxID);
        if (_values[index] != value) {
            _values[index] = value;
            mark_update(index, value);
        }
        return value;
    }
    unsigned add(unsigned index, unsigned value) noexcept {
        return set(index, get(index) + value);
    }
    unsigned sub(unsigned index, unsigned value) noexcept {
        return set(index, get(index) - value);
    }
    const array_type &values() const noexcept {
        return _values;
    }

    void init(unsigned id, unsigned value) noexcept {
        if (id < _MaxID) {
            _values[id] = value;
        }
    }
private:
    array_type _values;
};

#endif

