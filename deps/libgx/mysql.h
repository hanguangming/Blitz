#ifndef __GX_MYSQL_H__
#define __GX_MYSQL_H__

#include <tuple>
#include <vector>
#include <list>
#include <string>
#include "mysql/mysql.h"
#include "mysql/errmsg.h"

#include "platform.h"
#include "memory.h"
#include "object.h"
#include "data.h"
#include "singleton.h"
#include "allocator.h"

GX_NS_BEGIN

class MySQL;
class StatementBase;
class ResultSet;
class StatementContainer;

class FieldBase : public Object {
    friend class Fields;
public:
    FieldBase(enum_field_types dbtype) noexcept : _dbtype(dbtype), _isnull(false), _error(false), _length() { }
    virtual int64_t to_int() const noexcept {
        assert(0);
        return 0;
    }
    virtual const char *to_str() const noexcept {
        assert(0);
        return nullptr;
    }
protected:
    virtual void bind(MYSQL_BIND *bind) noexcept {
        bind->buffer_type = _dbtype;
        bind->is_null = &_isnull;
        bind->error = &_error;
        bind->length = &_length;
    }
protected:
    enum_field_types _dbtype;
    my_bool _isnull;
    my_bool _error;
    size_t _length;
};

template <typename _T>
class Field { };

template <>
class Field<int8_t> : public FieldBase {
public:
    Field(enum_field_types dbtype) noexcept : FieldBase(MYSQL_TYPE_LONGLONG) { }
    int64_t to_int() const noexcept override {
        return _value;
    }
protected:
    void bind(MYSQL_BIND *bind) noexcept override {
        FieldBase::bind(bind);
        bind->buffer = &_value;
    }

protected:
    int64_t _value;
};

template <>
class Field<int16_t> : public FieldBase {
public:
    Field(enum_field_types dbtype) noexcept : FieldBase(MYSQL_TYPE_LONGLONG) { }
    int64_t to_int() const noexcept override {
        return _value;
    }

protected:
    void bind(MYSQL_BIND *bind) noexcept override {
        FieldBase::bind(bind);
        bind->buffer = &_value;
    }

protected:
    int64_t _value;
};

template <>
class Field<int32_t> : public FieldBase {
public:
    Field(enum_field_types dbtype) noexcept : FieldBase(MYSQL_TYPE_LONGLONG) { }
    int64_t to_int() const noexcept override {
        return _value;
    }

protected:
    void bind(MYSQL_BIND *bind) noexcept override {
        FieldBase::bind(bind);
        bind->buffer = &_value;
    }

protected:
    int64_t _value;
};

template <>
class Field<int64_t> : public FieldBase {
public:
    Field(enum_field_types dbtype) noexcept : FieldBase(MYSQL_TYPE_LONGLONG) { }
    int64_t to_int() const noexcept override {
        return _value;
    }

protected:
    void bind(MYSQL_BIND *bind) noexcept override {
        FieldBase::bind(bind);
        bind->buffer = &_value;
    }

protected:
    int64_t _value;
};

template <>
class Field<char*> : public FieldBase {
public:
    Field(enum_field_types dbtype, size_t maxsize) noexcept : FieldBase(dbtype), _value(maxsize) { }
    const char *to_str() const noexcept override {
        return _value.data();
    }

protected:
    void bind(MYSQL_BIND *bind) noexcept override {
        FieldBase::bind(bind);
        bind->buffer = _value.data();
        bind->buffer_length = _value.size();
    }

protected:
    Data _value;
};

class Fields : public Object {
    friend class StatementBase;
public:
    Fields() noexcept;
    ~Fields();
    FieldBase &at(size_t index) noexcept {
        assert(index < _fields.size());
        return *_fields[index].get();
    }
private:
    bool init(StatementBase *stmt);
    bool bind(StatementBase *stmt);
    std::vector<ptr<FieldBase>> _fields;
};

/* StatementBase */
class StatementBase : public Object {
    friend class MySQL;
    friend class Fields;
    friend class ResultSet;
    friend class StatementContainer;
protected:
    StatementBase(const char *sql) noexcept;
    ~StatementBase();

    virtual bool bind() = 0;
    int do_exec() noexcept;
    ptr<ResultSet> do_query() noexcept;
    void do_error() noexcept;
    void close() noexcept;
    void attach_container() noexcept;
    void detach_container() noexcept;
    const char *sql() const noexcept {
        return _sql.c_str();
    }
public:
    bool prepare(ptr<MySQL> mysql) noexcept;

protected:
    ptr<MySQL> _mysql;
    MYSQL_STMT *_stmt;
    ptr<Fields> _fields;
    std::string _sql;
    list_entry _entry;
};


/* ResultSet */
class ResultSet : public Object {
public:
    ResultSet(StatementBase *stmt, size_t count) noexcept;
    ~ResultSet() noexcept;
    bool fetch() noexcept;
    const FieldBase &at(size_t index) noexcept {
        return _stmt->_fields->at(index);
    }
    const FieldBase &operator[](size_t index) noexcept {
        return at(index);
    }
    void fseek(size_t n = 1) noexcept {
        _curcol += n;
    }
    const FieldBase &field() noexcept {
        return at(_curcol);
    }
    size_t count() const noexcept {
        return _count;
    }
private:
    StatementBase *_stmt;
    size_t _curcol;
    size_t _count;
};

static inline ptr<ResultSet>& operator<<(int8_t &lhs, ptr<ResultSet> &rhs) noexcept {
    lhs = rhs->field().to_int();
    rhs->fseek();
    return rhs;
}

static inline ptr<ResultSet>& operator<<(uint8_t &lhs, ptr<ResultSet> &rhs) noexcept {
    lhs = rhs->field().to_int();
    rhs->fseek();
    return rhs;
}

static inline ptr<ResultSet>& operator<<(int16_t &lhs, ptr<ResultSet> &rhs) noexcept {
    lhs = rhs->field().to_int();
    rhs->fseek();
    return rhs;
}

static inline ptr<ResultSet>& operator<<(uint16_t &lhs, ptr<ResultSet> &rhs) noexcept {
    lhs = rhs->field().to_int();
    rhs->fseek();
    return rhs;
}

static inline ptr<ResultSet>& operator<<(int32_t &lhs, ptr<ResultSet> &rhs) noexcept {
    lhs = rhs->field().to_int();
    rhs->fseek();
    return rhs;
}

static inline ptr<ResultSet>& operator<<(uint32_t &lhs, ptr<ResultSet> &rhs) noexcept {
    lhs = rhs->field().to_int();
    rhs->fseek();
    return rhs;
}

static inline ptr<ResultSet>& operator<<(int64_t &lhs, ptr<ResultSet> &rhs) noexcept {
    lhs = rhs->field().to_int();
    rhs->fseek();
    return rhs;
}

static inline ptr<ResultSet>& operator<<(uint64_t &lhs, ptr<ResultSet> &rhs) noexcept {
    lhs = rhs->field().to_int();
    rhs->fseek();
    return rhs;
}

static inline ptr<ResultSet>& operator<<(char *&lhs, ptr<ResultSet> &rhs) noexcept {
    lhs = (char*)rhs->field().to_str();
    rhs->fseek();
    return rhs;
}

static inline ptr<ResultSet>& operator<<(const char *&lhs, ptr<ResultSet> &rhs) noexcept {
    lhs = rhs->field().to_str();
    rhs->fseek();
    return rhs;
}

static inline ptr<ResultSet>& operator<<(std::string &lhs, ptr<ResultSet> &rhs) noexcept {
    lhs = (char*)rhs->field().to_str();
    rhs->fseek();
    return rhs;
}

static inline ptr<ResultSet>& operator<<(obstack_string &lhs, ptr<ResultSet> &rhs) noexcept {
    lhs = (char*)rhs->field().to_str();
    rhs->fseek();
    return rhs;
}

/* Statement */
template <typename _T>
struct BindType { };

template <>
struct BindType<int8_t> {
    int8_t _value;
    void bind(MYSQL_BIND *item) noexcept {
        item->buffer_type= MYSQL_TYPE_TINY;
        item->buffer= (char*)&_value;
    }
    void assign(int8_t value) noexcept {
        _value = value;
    }
};

template <>
struct BindType<uint8_t> {
    uint8_t _value;
    void bind(MYSQL_BIND *item) noexcept {
        item->buffer_type= MYSQL_TYPE_TINY;
        item->buffer= (char*)&_value;
    }
    void assign(uint8_t value) noexcept {
        _value = value;
    }
};

template <>
struct BindType<int16_t> {
    int16_t _value;
    void bind(MYSQL_BIND *item) noexcept {
        item->buffer_type= MYSQL_TYPE_SHORT;
        item->buffer= (char*)&_value;
    }
    void assign(int16_t value) noexcept {
        _value = value;
    }
};

template <>
struct BindType<uint16_t> {
    uint16_t _value;
    void bind(MYSQL_BIND *item) noexcept {
        item->buffer_type= MYSQL_TYPE_SHORT;
        item->buffer= (char*)&_value;
    }
    void assign(uint16_t value) noexcept {
        _value = value;
    }
};

template <>
struct BindType<int32_t> {
    int32_t _value;
    void bind(MYSQL_BIND *item) noexcept {
        item->buffer_type= MYSQL_TYPE_LONG;
        item->buffer= (char*)&_value;
    }
    void assign(int32_t value) noexcept {
        _value = value;
    }
};

template <>
struct BindType<uint32_t> {
    uint32_t _value;
    void bind(MYSQL_BIND *item) noexcept {
        item->buffer_type= MYSQL_TYPE_LONG;
        item->buffer= (char*)&_value;
    }
    void assign(uint32_t value) noexcept {
        _value = value;
    }
};

template <>
struct BindType<int64_t> {
    int64_t _value;
    void bind(MYSQL_BIND *item) noexcept {
        item->buffer_type= MYSQL_TYPE_LONGLONG;
        item->buffer= (char*)&_value;
    }
    void assign(int64_t value) noexcept {
        _value = value;
    }
};

template <>
struct BindType<uint64_t> {
    uint64_t _value;
    void bind(MYSQL_BIND *item) noexcept {
        item->buffer_type= MYSQL_TYPE_LONGLONG;
        item->buffer= (char*)&_value;
    }
    void assign(uint64_t value) noexcept {
        _value = value;
    }
};

template <>
struct BindType<const char*> {
    static constexpr size_t strsize = 256;
    char _value[strsize];
    size_t _length;
    void bind(MYSQL_BIND *item) noexcept {
        item->buffer_type= MYSQL_TYPE_STRING;
        item->buffer= _value;
        item->buffer_length= strsize;
        item->length= &_length;
    }
    void assign(const char *value) noexcept {
        strncpy(_value, value, strsize);
        _length = strlen(value);
    }
};

template <typename ..._Args>
class Statement : public StatementBase {
    friend class MySQL;
public:
    Statement(const char *sql) noexcept : StatementBase(sql) { }
protected:
    static constexpr size_t arg_count = sizeof...(_Args);

    template <size_t __index>
    typename std::enable_if<
        __index == arg_count,
        void>::type
    bind_param(MYSQL_BIND *binds) noexcept {
    }

    template <size_t __index>
    typename std::enable_if<
        __index != arg_count,
        void>::type
    bind_param(MYSQL_BIND *binds) noexcept {
        std::get<__index>(_values).bind(binds + __index);
        bind_param<__index + 1>(binds);
    }

    bool bind() noexcept override {
        MYSQL_BIND binds[arg_count];
        memset(binds, 0, sizeof(binds));
        bind_param<0>(binds);
        return mysql_stmt_bind_param(_stmt, binds) == 0;
    }

    template <size_t __index>
    void assign_param() noexcept {
    }

    template <size_t __index, typename _T>
    void assign_param(const _T value) noexcept {
        std::get<__index>(_values).assign(value);
    }

    template <size_t __index, typename _T, typename ..._Params>
    void assign_param(const _T value, const _Params...params) noexcept {
        std::get<__index>(_values).assign(value);
        assign_param<__index + 1>(std::forward<const _Params>(params)...);
    }

public:
    int exec(const _Args...args) noexcept {
        assign_param<0>(std::forward<const _Args>(args)...);
        return do_exec();
    }

    ptr<ResultSet> query(const _Args...args) noexcept {
        assign_param<0>(std::forward<const _Args>(args)...);
        return do_query();
    }

private:
    std::tuple<BindType<_Args>...> _values;
};

template <typename ..._Args>
class Stmt : public Statement<_Args...> {
public:
    Stmt(const char *sql) noexcept : Statement<_Args...>(sql) {
        StatementBase::attach_container();
    }
    ~Stmt() {
        StatementBase::detach_container();
    }
};

class MySQL : public Object {
    friend class StatementBase;
public:
    MySQL(const char *host, unsigned port, const char *user, const char *passwd, const char *database) noexcept;

    const char *host() const noexcept {
        return _host.c_str();
    }
    unsigned port() const noexcept {
        return _port;
    }
    const char *user() const noexcept {
        return _user.c_str();
    }
    const char *passwd() const noexcept {
        return _passwd.c_str();
    }
    const char *database() const noexcept {
        return _database.c_str();
    }

    bool connected() noexcept {
        return _connected;
    }
    bool connect() noexcept;
    const char *errorMsg() noexcept;
    int errorNum() noexcept;
public:
    template <typename ..._Args>
    auto prepare(const char *sql) noexcept -> Statement<_Args...>* {
        auto stmt = new Statement<_Args...>(this);
        stmt->prepare(sql);
        return stmt;
    }
private:
    MYSQL _mysql;
    std::string _host;
    unsigned _port;
    std::string _user;
    std::string _passwd;
    std::string _database;
    bool _connected;
};

/* StatementContainer */
class StatementContainer : public Object, public singleton<StatementContainer> {
    friend class StatementBase;
public:
    bool prepare(ptr<MySQL> mysql) noexcept;
private:
    gx_list(StatementBase, _entry) _stmts;
};

GX_NS_END

#define GX_STMT(name, sql, ...)                               \
    struct __gx_stmt_##name : gx::Stmt< __VA_ARGS__ > {       \
        __gx_stmt_##name() : gx::Stmt< __VA_ARGS__ >(sql) { } \
    } name

#define GX_STMT_IMPL(_class, name, sql, ...)                  \
    _class::__gx_stmt_##name : gx::Stmt< __VA_ARGS__ > {\
        __gx_stmt_##name() : gx::Stmt< __VA_ARGS__ >(sql) { } \
    } name

#endif

