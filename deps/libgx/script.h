#ifndef __GX_SCRIPT_H__
#define __GX_SCRIPT_H__

#include <stack>
#include <vector>
#include <map>
#include <list>
#include <cinttypes>
#include "lua.hpp"
#include "platform.h"
#include "memory.h"
#include "path.h"
#include "data.h"
#include "tuple_apply.h"
#include "singleton.h"
#include "filemonitor.h"

#if(LUA_VERSION_NUM < 502)
lua_Integer lua_tointegerx(lua_State *L, int index, int *isnum);
lua_Number lua_tonumberx(lua_State *L, int index, int *isnum);
#endif

GX_NS_BEGIN

enum class ScriptFileType {
    LUA,
    CSV,
    UNKNOWN,
};

class ScriptTable;
class ScriptVariant;
class ScriptResult;
class Script;

/* ScriptValue */
template <typename _T>
struct ScriptValue;

template <>
struct ScriptValue<int8_t> {
    typedef int8_t type;
    static constexpr type default_value() noexcept {
        return type();
    }
    static int push(lua_State *L, type value) noexcept {
        lua_pushinteger(L, value);
        return 1;
    }
    static type pop(lua_State *L, int index) noexcept {
        int isnum;
        type value = (type)lua_tointegerx(L, index, &isnum);
        return isnum ? value : default_value();
    }
};

template <>
struct ScriptValue<uint8_t> {
    typedef uint8_t type;
    static constexpr type default_value() noexcept {
        return type();
    }
    static int push(lua_State *L, type value) noexcept {
        lua_pushinteger(L, value);
        return 1;
    }
    static type pop(lua_State *L, int index) noexcept {
        int isnum;
        type value = (type)lua_tointegerx(L, index, &isnum);
        return isnum ? value : default_value();
    }
};

template <>
struct ScriptValue<int16_t> {
    typedef int16_t type;
    static constexpr type default_value() noexcept {
        return type();
    }
    static int push(lua_State *L, type value) noexcept {
        lua_pushinteger(L, value);
        return 1;
    }
    static type pop(lua_State *L, int index) noexcept {
        int isnum;
        type value = (type)lua_tointegerx(L, index, &isnum);
        return isnum ? value : default_value();
    }
};

template <>
struct ScriptValue<uint16_t> {
    typedef uint16_t type;
    static constexpr type default_value() noexcept {
        return type();
    }
    static int push(lua_State *L, type value) noexcept {
        lua_pushinteger(L, value);
        return 1;
    }
    static type pop(lua_State *L, int index) noexcept {
        int isnum;
        type value = (type)lua_tointegerx(L, index, &isnum);
        return isnum ? value : default_value();
    }
};

template <>
struct ScriptValue<int32_t> {
    typedef int32_t type;
    static constexpr type default_value() noexcept {
        return type();
    }
    static int push(lua_State *L, type value) noexcept {
        lua_pushinteger(L, value);
        return 1;
    }
    static type pop(lua_State *L, int index) noexcept {
        int isnum;
        type value = (type)lua_tointegerx(L, index, &isnum);
        return isnum ? value : default_value();
    }
};

template <>
struct ScriptValue<uint32_t> {
    typedef uint32_t type;
    static constexpr type default_value() noexcept {
        return type();
    }
    static int push(lua_State *L, type value) noexcept {
        lua_pushinteger(L, value);
        return 1;
    }
    static type pop(lua_State *L, int index) noexcept {
        int isnum;
        type value = (type)lua_tointegerx(L, index, &isnum);
        return isnum ? value : default_value();
    }
};

template <>
struct ScriptValue<int64_t> {
    typedef int64_t type;
    static constexpr type default_value() noexcept {
        return type();
    }
    static int push(lua_State *L, type value) noexcept {
        lua_pushinteger(L, value);
        return 1;
    }
    static type pop(lua_State *L, int index) noexcept {
        int isnum;
        type value = (type)lua_tointegerx(L, index, &isnum);
        return isnum ? value : default_value();
    }
};

template <>
struct ScriptValue<uint64_t> {
    typedef uint64_t type;
    static constexpr type default_value() noexcept {
        return type();
    }
    static int push(lua_State *L, type value) noexcept {
        lua_pushinteger(L, value);
        return 1;
    }
    static type pop(lua_State *L, int index) noexcept {
        int isnum;
        type value = (type)lua_tointegerx(L, index, &isnum);
        return isnum ? value : default_value();
    }
};

template <>
struct ScriptValue<float> {
    typedef float type;
    static constexpr type default_value() noexcept {
        return type();
    }
    static int push(lua_State *L, type value) noexcept {
        lua_pushnumber(L, value);
        return 1;
    }
    static type pop(lua_State *L, int index) noexcept {
        int isnum;
        type value = (type)lua_tonumberx(L, index, &isnum);
        return isnum ? value : default_value();
    }
};

template <>
struct ScriptValue<double> {
    typedef double type;
    static constexpr type default_value() noexcept {
        return type();
    }
    static int push(lua_State *L, type value) noexcept {
        lua_pushnumber(L, value);
        return 1;
    }
    static type pop(lua_State *L, int index) noexcept {
        int isnum;
        type value = (type)lua_tonumberx(L, index, &isnum);
        return isnum ? value : default_value();
    }
};

template <>
struct ScriptValue<std::string> {
    static constexpr const char *default_value() noexcept {
        return "";
    }
    static int push(lua_State *L, const char *value) noexcept {
        lua_pushstring(L, value);
        return 1;
    }
    static const char *pop(lua_State *L, int index) noexcept {
        const char *value = lua_tostring(L, index);
        return value ? value : default_value();
    }
};

template <>
struct ScriptValue<const char*> {
    static constexpr const char *default_value() noexcept {
        return "";
    }
    static int push(lua_State *L, const char *value) noexcept {
        if (value) {
            lua_pushstring(L, value);
        }
        else {
            lua_pushnil(L);
        }
        return 1;
    }
    static const char *pop(lua_State *L, int index) noexcept {
        const char *value = lua_tostring(L, index);
        return value ? value : default_value();
    }
};

template <>
struct ScriptValue<char*> : public ScriptValue<const char*> { };

template <>
struct ScriptValue<void> {
    static int push(lua_State *L) noexcept {
        return 0;
    }
    static void pop(lua_State *L, int index) noexcept {
    }
};

template <typename ..._Args>
struct ScriptValue<std::tuple<_Args...>> {
    typedef std::tuple<_Args...> type;
    static constexpr const char *default_value() noexcept {
        return type();
    }
    static void push(lua_State *L, const type &value) noexcept {
        push_tuple<0>(L, value);
        return sizeof...(_Args);
    }
    static type pop(lua_State *L, int index) noexcept {
        return type();
    }
private:
    template <unsigned __index>
    static void push_tuple(lua_State *L, const type &t) noexcept {
        if (__index >= sizeof...(_Args)) {
            return;
        }
        ScriptValue<typename std::tuple_element<__index, type>::type>::push(L, std::get<__index>(t));
        push_tuple<__index>(L, t);
    }
};

/* ScriptFunction */
template<typename _T, typename _Signature>
class ScriptFunction;

template<typename _T, typename _R, typename... _Args>
class ScriptFunction<_T, _R(_Args...)> {
private:
    typedef std::tuple<_Args...> tuple_type;

    template <unsigned __index>
    static typename std::enable_if<
        __index >= sizeof...(_Args),
        void>::type
    pop(lua_State *L, int top, tuple_type &params) {
    }

    template <unsigned __index>
    static typename std::enable_if<
        __index < sizeof...(_Args),
        void>::type
    pop(lua_State *L, int top, tuple_type &params) {
        if (__index > (unsigned)top) {
            std::get<__index>(params) = ScriptValue<typename std::tuple_element<__index, tuple_type>::type>::default_value();
        }
        else {
            std::get<__index>(params) = ScriptValue<typename std::tuple_element<__index, tuple_type>::type>::pop(L, __index + 1);
        }
        pop<__index + 1>(L, top, params);
    }

public:
    virtual _R operator()(_Args...args) = 0;

    template <typename _Res>
    static typename std::enable_if<
        !std::is_void<_Res>::value,
        int>::type
    execute(lua_State *L, ScriptFunction *instance, _Args...args) noexcept {
        return ScriptValue<_R>::push(L, (*instance)(std::forward<_Args>(args)...));
    }
    template <typename _Res>
    static typename std::enable_if<
        std::is_void<_Res>::value,
        int>::type
    execute(lua_State *L, ScriptFunction *instance, _Args...args) noexcept {
        (*instance)(std::forward<_Args>(args)...);
        return 0;
    }

    static int wrapper(lua_State *L) noexcept {
        static _T instance;
        int top = lua_gettop(L);
        tuple_type params;
        pop<0>(L, top, params);
        return tuple_apply<true>(execute<_R>, params, L, &instance);
    }
};

/* ScriptFunctionManager */
class ScriptFunctionManager : public Object, public singleton<ScriptFunctionManager> {
public:
    bool registerFunction(const char *name, int(*func)(lua_State*)) noexcept {
        return _map.emplace(name, func).second;
    }

    void upload(Script *script) noexcept;
private:
    std::map<std::string, int(*)(lua_State*)> _map;
};

/* ScriptFunctionRegister */
template <typename _T>
struct ScriptFunctionRegister {
    ScriptFunctionRegister(const char *name) noexcept {
        ScriptFunctionManager::instance()->registerFunction(name, _T::wrapper);
    }
};
#define GX_SCRIPT_REG_FUNC(name, T) static ScriptFunctionRegister<T> __script_func_##T(name)

/* ScriptException */
class ScriptException {
public:
    ScriptException(const char *name, const char *msg) noexcept
    : _name(name), _msg(msg) { }

    const char *name() const noexcept {
        return _name.c_str();
    }
    const char *message() const noexcept {
        return _msg.c_str();
    }
private:
    std::string _name;
    std::string _msg;
};
/* ScriptInvoker */
template<typename _Signature>
struct ScriptInvoker;

template<typename _R, typename... _Args>
struct ScriptInvoker<_R(_Args...)> {
    static int push(lua_State *L) {
        return 0;
    }

    template <typename _T, typename ..._Params>
    static int push(lua_State *L, _T &&param, _Params&&...params) {
        return ScriptValue<_T>::push(L, std::forward<_T>(param)) + push(L, std::forward<_Params>(params)...);
    }


    template <typename _T>
    static typename std::enable_if<
        !std::is_void<_T>::value,
        _T>::type
    invoke_(lua_State *L, const char *name, _Args...args) {
        int base = lua_gettop(L);
        lua_getglobal(L, name);
        int argc = push(L, std::forward<_Args>(args)...);
        if (lua_pcall(L, argc, LUA_MULTRET, 0)) {
            const char *error = lua_tostring(L, -1);
            lua_pop(L, 1);
            throw ScriptException(name, error);
        }
        int top = lua_gettop(L);
        lua_pop(L, top - base);
        if (top > base) {
            _T r = ScriptValue<_R>::pop(L, base);
            lua_pop(L, top - base);
            return r;
        }
        else {
            _T r = ScriptValue<_R>::default_value();
            lua_pop(L, top - base);
            return r;
        }
    }

    template <typename _T>
    static typename std::enable_if<
        std::is_void<_T>::value,
        _T>::type
    invoke_(lua_State *L, const char *name, _Args...args) {
        int base = lua_gettop(L);
        lua_getglobal(L, name);
        int argc = push(L, std::forward<_Args>(args)...);
        if (lua_pcall(L, argc, LUA_MULTRET, 0)) {
            const char *error = lua_tostring(L, -1);
            lua_pop(L, 1);
            throw ScriptException(name, error);
        }
        int top = lua_gettop(L);
        lua_pop(L, top - base);
    }

    static _R invoke(lua_State *L, const char *name, _Args...args) {
        return invoke_<_R>(L, name, std::forward<_Args>(args)...);
    }
};

/* Script */
class Script : public Object {
public:
    Script(ptr<FileMonitor> monitor) noexcept;
    ~Script() noexcept;

    operator lua_State*() noexcept {
        return _lua;
    }

    int load(const Path &filename, ScriptFileType type = ScriptFileType::UNKNOWN) noexcept;

    int64_t read_integer(const char *name, int64_t default_value = 0) noexcept;
    double read_number(const char *name, double default_value = 0) noexcept;
    std::string read_string(const char *name, const char *default_value = nullptr) noexcept;
    ptr<ScriptTable> read_table(const char *name) noexcept;

    ScriptResult call(const char *func, const std::vector<ScriptVariant> &params) noexcept;

    void read_variant(int index, ScriptVariant &var) noexcept;
    ptr<ScriptVariant> read_variant(int index) noexcept;

    template <typename _R, typename ..._Args>
    _R invoke(const char *func, _Args...args) {
        ScriptInvoker<_R(_Args...)>::invoke(*this, func, std::forward<_Args>(args)...);
    }

    static Script *get_script(lua_State *L) noexcept;
private:
    static std::map<intptr_t, Script*> &get_map() noexcept {
        static std::map<intptr_t, Script*> map;
        return map;
    }
    void reload(Path path, const Path&);
    int load2(const Path &path, ScriptFileType type) noexcept;
    int sys_load(const Path &filename, ScriptFileType type) noexcept;
    int load_lua(const Path &path, const Data *data) noexcept;
    int load_csv(const Path &path, const Data *data) noexcept;
protected:
    lua_State *_lua;
    std::list<Path> _stack;
    ptr<FileMonitor> _monitor;
    Path _root;
};

class ScriptTableIterator;

class ScriptTable : public Object {
    friend class Script;
    friend class ScriptVariant;
    friend class ScriptTableFetcher;
public:
    typedef ScriptTableIterator iterator;
public:
    ScriptTable() noexcept;
    ScriptTable(ptr<Script> script, int index) noexcept;
    ~ScriptTable() noexcept;

    int64_t read_integer(const char *name, int64_t default_value = 0) noexcept;
    int64_t read_integer(unsigned index, int64_t default_value = 0) noexcept;
    double read_number(const char *name, double default_value = 0) noexcept;
    double read_number(unsigned index, double default_value = 0) noexcept;
    std::string read_string(const char *name, const char *default_value = nullptr) noexcept;
    std::string read_string(unsigned index, const char *default_value = nullptr) noexcept;
    ptr<ScriptTable> read_table(const char *name) noexcept;
    ptr<ScriptTable> read_table(unsigned index) noexcept;
    ptr<ScriptVariant> read(const char *name) noexcept;
    ptr<ScriptVariant> read(unsigned index) noexcept;

    bool is_nil() const noexcept {
        return _script == nullptr;
    }
    ptr<Script> script() const noexcept {
        return _script;
    }
    size_t size() const noexcept;
    iterator begin();
    iterator end();

private:
    void push_stack() const noexcept;
protected:
    ptr<Script> _script;
};

enum class ScriptVariableType {
    INTEGER,
    NUMBER,
    STRING,
    TABLE,
    NIL,
};

class ScriptVariant : public Object {
    friend class Script;
public:
    ScriptVariant() noexcept
    : _type(ScriptVariableType::NIL), _vint(0)
    { }
    ScriptVariant(const ScriptVariant &x) noexcept : _type(ScriptVariableType::NIL) {
        assign(x);
    }
    ScriptVariant(int64_t x) noexcept
    : _type(ScriptVariableType::INTEGER),
      _vint(x)
    { }
    explicit ScriptVariant(double x) noexcept
    : _type(ScriptVariableType::NUMBER),
      _vnum(x)
    { }
    explicit ScriptVariant(const char *x) noexcept
    : _type(ScriptVariableType::STRING),
      _vstr(x ? x : "")
    { }
    ScriptVariant(const std::string &x) noexcept
    : _type(ScriptVariableType::STRING),
      _vstr(x)
    { }
    ScriptVariant(const std::string &&x) noexcept
    : _type(ScriptVariableType::STRING),
      _vstr(std::move(x))
    { }
    ScriptVariant(ptr<ScriptTable> x) noexcept
    : _type(ScriptVariableType::TABLE),
      _vtab(std::move(x))
    { }
    ScriptVariableType type() const {
        return _type;
    }
    bool is_arithmetic() const noexcept {
        return _type == ScriptVariableType::INTEGER || _type == ScriptVariableType::INTEGER;
    }
    bool is_string() const noexcept {
        return _type == ScriptVariableType::STRING;
    }
    bool is_table() const noexcept {
        return _type == ScriptVariableType::TABLE;
    }
    bool is_nil() const noexcept {
        return _type == ScriptVariableType::NIL;
    }
    void clear() noexcept {
        switch (_type) {
        case ScriptVariableType::INTEGER:
        case ScriptVariableType::NUMBER:
            _vint = 0;
            break;
        case ScriptVariableType::STRING:
            _vstr.clear();
            break;
        case ScriptVariableType::TABLE:
            _vtab = nullptr;
            break;
        default:
            return;
        }
        _type = ScriptVariableType::NIL;
    }
    int64_t integer() const noexcept {
        switch (_type) {
        case ScriptVariableType::INTEGER:
            return _vint;
        case ScriptVariableType::NUMBER:
            return (int64_t)_vnum;
        case ScriptVariableType::STRING:
            return std::strtol(_vstr.c_str(), nullptr, 10);
        case ScriptVariableType::TABLE:
            assert(0);
            break;
        default:
            return 0;
        }
    }
    void assign(int64_t value) noexcept {
        switch (_type) {
        case ScriptVariableType::STRING:
            _vstr.clear();
            break;
        case ScriptVariableType::TABLE:
            _vtab = nullptr;
            break;
        default:
            break;
        }
        _type = ScriptVariableType::INTEGER;
        _vint = value;
    }
    double number() const noexcept {
        switch (_type) {
        case ScriptVariableType::INTEGER:
            return (double)_vint;
        case ScriptVariableType::NUMBER:
            return _vnum;
        case ScriptVariableType::STRING:
            return std::strtod(_vstr.c_str(), nullptr);
        case ScriptVariableType::TABLE:
            assert(0);
        default:
            return 0;
        }
    }
    void assign(double value) noexcept {
        switch (_type) {
        case ScriptVariableType::STRING:
            _vstr.clear();
            break;
        case ScriptVariableType::TABLE:
            _vtab = nullptr;
            break;
        default:
            break;
        }
        _type = ScriptVariableType::NUMBER;
        _vnum = value;
    }
    std::string string() const noexcept {
        char buf[128];
        switch (_type) {
        case ScriptVariableType::INTEGER:
            sprintf(buf, "%" PRId64, _vint);
            return buf;
        case ScriptVariableType::NUMBER:
            sprintf(buf, "%f", _vnum);
            return buf;
        case ScriptVariableType::STRING:
            return _vstr;
        case ScriptVariableType::TABLE:
            assert(0);
        default:
            return "";
        }
    }
    void assign(const std::string &value) noexcept {
        switch (_type) {
        case ScriptVariableType::TABLE:
            _vtab = nullptr;
            break;
        default:
            break;
        }
        _type = ScriptVariableType::STRING;
        _vstr = value;
    }
    void assign(const char *value) noexcept {
        switch (_type) {
        case ScriptVariableType::TABLE:
            _vtab = nullptr;
            break;
        default:
            break;
        }
        _type = ScriptVariableType::STRING;
        _vstr = value ? value : "";
    }
    void assign(std::string &&value) noexcept {
        switch (_type) {
        case ScriptVariableType::TABLE:
            _vtab = nullptr;
            break;
        default:
            break;
        }
        _type = ScriptVariableType::STRING;
        _vstr = std::move(value);
    }
    ptr<ScriptTable> table() const noexcept {
        switch (_type) {
        case ScriptVariableType::INTEGER:
        case ScriptVariableType::NUMBER:
        case ScriptVariableType::STRING:
            assert(0);
        case ScriptVariableType::NIL:
            return nullptr;
        case ScriptVariableType::TABLE:
            return _vtab;
        default:
            return nullptr;
        }
    }
    void assign(ptr<ScriptTable> value) noexcept {
        switch (_type) {
        case ScriptVariableType::STRING:
            _vstr.clear();
            break;
        default:
            break;
        }
        _type = ScriptVariableType::TABLE;
        _vtab = std::move(value);
    }
    void assign(const ScriptVariant &x) noexcept {
        clear();
        _type = x._type;
        switch (_type) {
        case ScriptVariableType::INTEGER:
            _vint = x._vint;
            break;
        case ScriptVariableType::NUMBER:
            _vnum = x._vnum;
            break;
        case ScriptVariableType::STRING:
            _vstr = x._vstr;
            break;
        case ScriptVariableType::TABLE:
            _vtab = x._vtab;
            break;
        default:
            break;
        }
    }
    void assign(nullptr_t) noexcept {
        if (_type != ScriptVariableType::NIL) {
            clear();
        }
    }
    ScriptVariant &operator=(int64_t value) noexcept {
        assign(value);
        return *this;
    }
    ScriptVariant &operator=(double value) noexcept {
        assign(value);
        return *this;
    }
    ScriptVariant &operator=(const std::string &value) noexcept {
        assign(value);
        return *this;
    }
    ScriptVariant &operator=(std::string &&value) noexcept {
        assign(std::move(value));
        return *this;
    }
    ScriptVariant &operator=(const char *value) noexcept {
        assign(value);
        return *this;
    }
    ScriptVariant &operator=(ptr<ScriptTable> value) noexcept {
        assign(value);
        return *this;
    }
    ScriptVariant &operator=(const ScriptVariant &x) noexcept {
        assign(x);
        return *this;
    }
private:
    void push_stack(Script *script) const noexcept;

private:
    ScriptVariableType _type;
    union {
        int64_t _vint;
        double  _vnum;
    };
    std::string _vstr;
    ptr<ScriptTable> _vtab;
};

struct ScriptVariable : Object {
    ScriptVariable() noexcept { }
    ScriptVariable(ptr<ScriptVariant> n, ptr<ScriptVariant> v) noexcept
    : name(n), value(v)
    { }
    ScriptVariable(const ScriptVariable &x) noexcept
    : name(x.name), value(x.value)
    { }
    ScriptVariable(ScriptVariable &&x) noexcept
    : name(), value() {
        name.swap(x.name);
        value.swap(x.value);
    }

    ptr<ScriptVariant> name;
    ptr<ScriptVariant> value;
};

class ScriptResult : public Object {
    friend class Script;
    friend class ScriptTable;
public:
    ScriptResult(bool result) noexcept : _result(result) { }
    ScriptResult(const ScriptResult &x) noexcept
    : _result(x._result),
      _values(x._values)
    { }
    ScriptResult(ScriptResult &&x) noexcept
    : _result(x._result),
      _values(std::move(x._values))
    { }

    operator bool() const noexcept {
        return _result;
    }
    const std::vector<ScriptVariant> &values() const noexcept {
        return _values;
    }
private:
    bool _result;
    std::vector<ScriptVariant> _values;
};

class ScriptTableFetcher : public Object {
public:
    ScriptTableFetcher(ptr<ScriptTable> table) noexcept;
    ~ScriptTableFetcher() noexcept;
    bool fetch(ScriptVariable &var) noexcept;
private:
    ptr<ScriptTable> _table;
};

class ScriptTableIterator {
public:
    ScriptTableIterator(ptr<ScriptTableFetcher> fetcher) noexcept : _fetcher(fetcher) { }
    ScriptTableIterator(const ScriptTableIterator &x) noexcept
    : _fetcher(x._fetcher),
      _var(x._var)
    { }

    const ScriptVariable &operator*() const noexcept {
        return _var;
    }
    ScriptTableIterator& operator++() noexcept {
        if (_fetcher) {
            _fetcher->fetch(_var);
        }
        return *this;
    }
    ScriptTableIterator operator++(int) noexcept {
        ScriptTableIterator tmp(*this);
        if (_fetcher) {
            _fetcher->fetch(_var);
        }
        return tmp;
    }
    bool operator==(const ScriptTableIterator &x) const noexcept {
        return _var.name == x._var.name;
    }
    bool operator!=(const ScriptTableIterator &x) const noexcept {
        return _var.name != x._var.name;
    }
private:
    ptr<ScriptTableFetcher> _fetcher;
    ScriptVariable _var;
};


GX_NS_END

#endif



