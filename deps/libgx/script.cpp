#include <sstream>
#include <map>
#include "script.h"
#include "fileloader.h"
#include "log.h"
#include "application.h"
#include "csvloader.h"
#include "application.h"

#if(LUA_VERSION_NUM < 502)
lua_Integer lua_tointegerx(lua_State *L, int index, int *isnum) {
    if (!lua_isnumber(L, index)) {
        if (isnum) {
            *isnum = 0;
        }
        return 0;
    }
    if (isnum) {
        *isnum = 1;
    }
    return lua_tointeger(L, index);
}

lua_Number lua_tonumberx(lua_State *L, int index, int *isnum) {
    if (!lua_isnumber(L, index)) {
        if (isnum) {
            *isnum = 0;
        }
        return 0;
    }
    if (isnum) {
        *isnum = 1;
    }
    return lua_tonumber(L, index);
}

#define lua_rawlen lua_objlen
#endif

GX_NS_BEGIN

/* ScriptTable::fetcher */
ScriptTableFetcher::ScriptTableFetcher(ptr<ScriptTable> table) noexcept : _table(table) {
    if (table->is_nil()) {
        return;
    }
    table->push_stack();
    lua_pushnil(*table->script());
}

ScriptTableFetcher::~ScriptTableFetcher() noexcept {
    if (_table->is_nil()) {
        return;
    }
    lua_pop(*_table->script(), 1);
}

bool ScriptTableFetcher::fetch(ScriptVariable &var) noexcept {
    if (_table->is_nil()) {
        return false;
    }

    if (!lua_next(*_table->script(), -2)) {
        var.name = nullptr;
        var.value = nullptr;
        return false;
    }

    var.name = _table->script()->read_variant(-2);
    var.value = _table->script()->read_variant(-1);
    lua_pop(*_table->script(), 1);
    return true;
}

/* ScriptVariant */
inline void ScriptVariant::push_stack(Script *script) const noexcept {
    switch (_type) {
    case ScriptVariableType::INTEGER:
        lua_pushinteger(*script, _vint);
        break;
    case ScriptVariableType::NUMBER:
        lua_pushnumber(*script, _vnum);
        break;
    case ScriptVariableType::STRING:
        lua_pushstring(*script, _vstr.c_str());
        break;
    case ScriptVariableType::TABLE:
        if (!_vtab->is_nil()) {
            _vtab->push_stack();
            break;
        }
    case ScriptVariableType::NIL:
        lua_pushnil(*script);
        break;
    }
}

/* ScriptTable */
ScriptTable::ScriptTable() noexcept
: _script()
{ }

ScriptTable::ScriptTable(ptr<Script> script, int index) noexcept : _script(script) {
    if (script) {
        lua_pushlightuserdata(*script, this);       // top +1
        if (index < 0) {
            --index;
        }
        lua_pushvalue(*script, index);              // top +2
        lua_settable(*script, LUA_REGISTRYINDEX);   // top +0
    }
}

ScriptTable::~ScriptTable() noexcept {
    if (_script) {
        lua_pushlightuserdata(*_script, (void*)this);
        lua_pushnil(*_script);
        lua_settable(*_script, LUA_REGISTRYINDEX);
    }
}

ptr<ScriptVariant> ScriptTable::read(const char *name) noexcept {
    if (is_nil()) {
        return object<ScriptVariant>();
    }
    push_stack();
    lua_pushstring(*_script, name);             // top +2
    lua_gettable(*_script, -2);                 // top +2
    ptr<ScriptVariant> var = _script->read_variant(-1);
    lua_pop(*_script, 2);
    return var;
}

ptr<ScriptVariant> ScriptTable::read(unsigned index) noexcept {
    if (is_nil()) {
        return object<ScriptVariant>();
    }
    push_stack();
    lua_pushinteger(*_script, index);           // top +2
    lua_gettable(*_script, -2);                 // top +2
    ptr<ScriptVariant> var = _script->read_variant(-1);
    lua_pop(*_script, 2);
    return var;
}

int64_t ScriptTable::read_integer(const char *name, int64_t default_value) noexcept {
    if (!_script) {
        return default_value;
    }
    push_stack();
    lua_pushstring(*_script, name);             // top +2
    lua_gettable(*_script, -2);                 // top +2

    int isnum;
    int64_t d = lua_tointegerx(*_script, -1, &isnum);
    if (!isnum) {
        d = default_value;
    }
    lua_pop(*_script, 2);
    return d;
}

int64_t ScriptTable::read_integer(unsigned index, int64_t default_value) noexcept {
    if (!_script) {
        return default_value;
    }
    push_stack();
    lua_pushinteger(*_script, index);
    lua_gettable(*_script, -2);
    int isnum;
    int64_t d = lua_tointegerx(*_script, -1, &isnum);
    if (!isnum) {
        d = default_value;
    }
    lua_pop(*_script, 2);
    return d;
}

double ScriptTable::read_number(const char *name, double default_value) noexcept {
    if (!_script) {
        return default_value;
    }
    push_stack();
    lua_pushstring(*_script, name);
    lua_gettable(*_script, -2);
    int isnum;
    double d = lua_tonumberx(*_script, -1, &isnum);
    if (!isnum) {
        d = default_value;
    }
    lua_pop(*_script, 2);
    return d;
}

double ScriptTable::read_number(unsigned index, double default_value) noexcept {
    if (!_script) {
        return default_value;
    }
    push_stack();
    lua_pushinteger(*_script, index);
    lua_gettable(*_script, -2);
    int isnum;
    double d = lua_tonumberx(*_script, -1, &isnum);
    if (!isnum) {
        d = default_value;
    }
    lua_pop(*_script, 2);
    return d;
}

std::string ScriptTable::read_string(const char *name, const char *default_value) noexcept {
    if (!default_value) {
        default_value = "";
    }
    if (!_script) {
        return default_value;
    }
    push_stack();
    lua_pushstring(*_script, name);
    lua_gettable(*_script, -2);
    const char *str = lua_tostring(*_script, -1);
    if (!str) {
        str = default_value;
    }
    lua_pop(*_script, 2);
    return str;
}

std::string ScriptTable::read_string(unsigned index, const char *default_value) noexcept {
    if (!default_value) {
        default_value = "";
    }
    if (!_script) {
        return default_value;
    }
    push_stack();
    lua_pushinteger(*_script, index);
    lua_gettable(*_script, -2);
    const char *str = lua_tostring(*_script, -1);
    if (!str) {
        str = default_value;
    }
    lua_pop(*_script, 2);
    return str;
}

ptr<ScriptTable> ScriptTable::read_table(const char *name) noexcept {
    if (!_script) {
        return self().cast<ScriptTable>();
    }
    push_stack();
    lua_pushstring(*_script, name);                 // top +2
    lua_gettable(*_script, -2);                     // top +2

    if (!lua_istable(*_script, -1)) {
        lua_pop(*_script, 2);
        return object<ScriptTable>();
    }

    object<ScriptTable> table(_script, -1);
    lua_pop(*_script, 2);
    return table;
}

ptr<ScriptTable> ScriptTable::read_table(unsigned index) noexcept {
    if (!_script) {
        return self().cast<ScriptTable>();
    }
    push_stack();
    lua_pushinteger(*_script, index);
    lua_gettable(*_script, -2);

    if (!lua_istable(*_script, -1)) {
        lua_pop(*_script, 2);
        return object<ScriptTable>();
    }

    object<ScriptTable> table(_script, -1);
    lua_pop(*_script, 2);
    return table;
}

size_t ScriptTable::size() const noexcept {
    lua_pushlightuserdata(*_script, (void*)this);
    lua_gettable(*_script, LUA_REGISTRYINDEX);
    size_t result = lua_rawlen(*_script, -1);
    lua_pop(*_script, 1);
    return result;
}

ScriptTable::iterator ScriptTable::begin() {
    iterator it(object<ScriptTableFetcher>(self().cast<ScriptTable>()));
    ++it;
    return it;
}

ScriptTable::iterator ScriptTable::end() {
    return iterator(nullptr);
}

inline void ScriptTable::push_stack() const noexcept {
    assert(!is_nil());
    lua_pushlightuserdata(*_script, (void*)this);
    lua_gettable(*_script, LUA_REGISTRYINDEX);
}

/* script */
Script *Script::get_script(lua_State *L) noexcept {
    auto &map = get_map();
    auto it = map.find((intptr_t)L);
    if (it == map.end()) {
        return nullptr;
    }
    return it->second;
}

static int __script_debug(lua_State *L) {
    std::stringstream stream;
    for (int i = 1; i <= lua_gettop(L); i++) {
        const char *p = lua_tostring(L, i);
        if (p) {
            stream << p;
        }
        else {
            stream << "<nil>";
        }
    }
    log_debug("%s", stream.str().c_str());
    return 0;
}

static int __script_home_dir(lua_State *L) {
    lua_pushstring(L, the_app->home_dir().c_str());
    return 1;
}

static int __script_load(lua_State *L) {
    Script *script = Script::get_script(L);
    if (!script) {
        return 0;
    }

    const char *p = lua_tostring(L, -1);
    if (!p) {
        luaL_error(L, "bad file name.");
    }

    int n = script->load(p);
    if (n < 0) {
        luaL_error(L, "lua load failed");
    }
    return n;
}

static int __script_getenv(lua_State *L) {
    const char *p = lua_tostring(L, -1);
    if (!p) {
        luaL_error(L, "getenv: bad env name.");
    }
    const char *ret = getenv(p);
    if (!ret) {
        lua_pushnil(L);
    }
    else {
        lua_pushstring(L, ret);
    }
    return 1;
}

static int __script_setenv(lua_State *L) {
    const char *name = lua_tostring(L, -2);
    if (!name) {
        luaL_error(L, "setenv: bad env name.");
    }
    const char *value = lua_tostring(L, -1);
    if (!value) {
        value = "";
    }
    setenv(name, value, 1);
    return 0;
}

Script::Script(ptr<FileMonitor> monitor) noexcept {
    _monitor = monitor;
    _lua = luaL_newstate();
    if (!_lua) {
        log_die("create lua state failed.");
    }
    get_map().emplace((intptr_t)_lua, this);
    luaL_openlibs(_lua);
    lua_register(_lua, "debug", __script_debug);
    lua_register(_lua, "load",  __script_load);
    lua_register(_lua, "home_dir",  __script_home_dir);
    lua_register(_lua, "getenv",  __script_getenv);
    lua_register(_lua, "setenv",  __script_setenv);
}

Script::~Script() noexcept {
    get_map().erase((intptr_t)_lua);
    if (_lua) {
        lua_close(_lua);
    }
}

int Script::sys_load(const Path &filename, ScriptFileType type) noexcept {
    Path path;
    std::string ext = filename.extension();
    if (ext.empty()) {
        path = filename.directory() + (filename.basename() + ".lua");
        type = ScriptFileType::LUA;
    }
    else {
        path = filename;
    }
    log_info("script: load '%s'.", path.c_str());

    if (type == ScriptFileType::UNKNOWN) {
        if (ext == "csv") {
            type = ScriptFileType::CSV;
        }
        else if (ext == "lua") {
            type = ScriptFileType::LUA;
        }
        else if (ext == "conf") {
            type = ScriptFileType::LUA;
        }
        else if (ext == "var") {
            type = ScriptFileType::LUA;
        }
    }

    int result = -1;
    auto data = FileLoader::load(path);
    if (data) {
        switch (type) {
        case ScriptFileType::LUA:
            result = load_lua(path, data);
            break;
        case ScriptFileType::CSV:
            result = load_csv(path, data);
            break;
        default:
            log_error("script: unknown file type '%s'.", path.c_str());
        }
    }
    else {
        log_error("script: open '%s' failed", path.c_str());
    }

    if (result >= 0) {
        _monitor->add(path, std::bind(&Script::reload, this, _stack.front(), _1));
    }
    return result;
}

void Script::reload(Path path, const Path&) {
    load(_root, ScriptFileType::LUA);
}

int Script::load(const Path &filename, ScriptFileType type) noexcept {
    Path path;
    if (_stack.empty()) {
        _root = filename;
    }
    if (filename.is_absolute()) {
        path = the_app->home_dir() + filename;
    }
    else {
        if (_stack.empty()) {
            return -1;
        }
        path = _stack.back() + filename;
    }
    return load2(path, type);
}

int Script::load2(const Path &path, ScriptFileType type) noexcept {
    _stack.emplace_back(path.directory());
    if (path.filename() == "*") {
        for (auto file : path.directory()) {
            if (sys_load(file, type) < 0) {
                _stack.pop_back();
                return -1;
            }
        }
        _stack.pop_back();
        return 0;
    }

    int result = sys_load(path, type);
    _stack.pop_back();
    return result;
}

int Script::load_lua(const Path &path, const Data *data) noexcept {
    if (luaL_dostring(_lua, data->data())) {
        const char *error = lua_tostring(_lua, -1);
        log_error("script: load lua file'%s' failed, %s.", path.c_str(), error);
        lua_pop(_lua, 1);
        return -1;
    }
    return 0;
}

int Script::load_csv(const Path &path, const Data *data) noexcept {
    CsvLoader loader;
    int n = loader.load(*data);
    if (n) {
        log_error("script: load csv file '%s' failed, at line %d.", path.c_str(), n);
        return -1;
    }

    lua_createtable(_lua, loader.rows().size(), 0);
    unsigned index = 1;
    for (auto row : loader.rows()) {
        lua_pushinteger(_lua, index++);
        lua_createtable(_lua, 0, row->info()->columns().size());
        for (auto col : row->info()->columns()) {
            const char *str = (*row)[col->column()];
            if (!*str) {
                continue;
            }
            lua_pushstring(_lua, col->name());
            lua_pushstring(_lua, str);
            lua_settable(_lua, -3);
        }
        lua_settable(_lua, -3);
    }
    return 1;
}

int64_t Script::read_integer(const char *name, int64_t default_value) noexcept {
    lua_getglobal(_lua, name);                    // top +1
    int isnum;
    int64_t d = lua_tointegerx(_lua, -1, &isnum);
    if (!isnum) {
        d = default_value;
    }
    lua_pop(_lua, 1);
    return d;
}

double Script::read_number(const char *name, double default_value) noexcept {
    lua_getglobal(_lua, name);
    int isnum;
    double d = lua_tonumberx(_lua, -1, &isnum);
    if (!isnum) {
        d = default_value;
    }
    lua_pop(_lua, 1);
    return d;
}

std::string Script::read_string(const char *name, const char *default_value) noexcept {
    if (!default_value) {
        default_value = "";
    }
    lua_getglobal(_lua, name);
    const char *str = lua_tostring(_lua, -1);
    if (!str) {
        str = default_value;
    }
    lua_pop(_lua, 1);
    return str;
}

ptr<ScriptTable> Script::read_table(const char *name) noexcept {
    lua_getglobal(_lua, name);                    // top + 1
    if (!lua_istable(_lua, -1)) {
        lua_pop(_lua, 1);
        return object<ScriptTable>();
    }

    object<ScriptTable> table(this, -1);
    lua_pop(_lua, 1);
    return table;
}

void Script::read_variant(int index, ScriptVariant &var) noexcept {
    switch(lua_type(_lua, index)){
    case LUA_TNUMBER:
        var.assign(lua_tonumber(_lua, index));
        break;
    case LUA_TBOOLEAN:
        var.assign((int64_t)lua_tointeger(_lua, index));
        break;
    case LUA_TSTRING:
        var.assign(lua_tostring(_lua, index));
        break;
    case LUA_TTABLE:
        var = object<ScriptTable>(this, index);
        break;
    case LUA_TNIL:
    case LUA_TFUNCTION:
    case LUA_TUSERDATA:
    case LUA_TTHREAD:
    case LUA_TLIGHTUSERDATA:
    default:
        var.clear();
    }
}

ptr<ScriptVariant> Script::read_variant(int index) noexcept {
    switch(lua_type(_lua, index)){
    case LUA_TNIL:
        return object<ScriptVariant>();
    case LUA_TNUMBER:
        return object<ScriptVariant>(lua_tonumber(_lua, index));
    case LUA_TBOOLEAN:
        return object<ScriptVariant>((int64_t)lua_tointeger(_lua, index));
    case LUA_TSTRING:
        return object<ScriptVariant>(lua_tostring(_lua, index));
    case LUA_TTABLE:
        return object<ScriptVariant>(object<ScriptTable>(this, index));
    case LUA_TFUNCTION:
    case LUA_TUSERDATA:
    case LUA_TTHREAD:
    case LUA_TLIGHTUSERDATA:
    default:
        return object<ScriptVariant>();
    }
}

ScriptResult Script::call(const char *func, const std::vector<ScriptVariant> &params) noexcept {
    int n = lua_gettop(_lua);
    lua_getglobal(_lua, func);
    for (auto &x : params) {
        x.push_stack(this);
    }
    if (lua_pcall(_lua, params.size(), LUA_MULTRET, 0)) {
        const char *error = lua_tostring(_lua, -1);
        log_error("script: call %s failed, %s.", func, error);
        _stack.pop_back();
        lua_pop(_lua, 1);
        return ScriptResult(false);
    }
    ScriptResult result(true);

    int top = lua_gettop(_lua);
    for (int i = n + 1; i <= top; ++i) {
        result._values.emplace_back();
        read_variant(i, result._values.back());
    }
    lua_pop(_lua, top - n);
    return result;
}

/* ScriptFunctionManager */
void ScriptFunctionManager::upload(Script *script) noexcept {
    for (auto it = _map.begin(); it != _map.end(); ++it) {
        lua_pushcfunction(*script, it->second);
        lua_setglobal(*script, it->first.c_str());
    }
}


GX_NS_END

