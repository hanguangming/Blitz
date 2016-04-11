#include "mysql.h"
#include "log.h"
#include "rc.h"

GX_NS_BEGIN

/* Fields */
Fields::Fields() noexcept {
}

Fields::~Fields() {
}

bool Fields::init(StatementBase *stmt) {
    bool r = false;
    MYSQL_RES *res = nullptr;
    do {
        res = mysql_stmt_result_metadata(stmt->_stmt);
        if (!res) {
            stmt->do_error();
            break;
        }

        MYSQL_FIELD *field;
        while((field = mysql_fetch_field(res))) {
            switch (field->type) {
            case MYSQL_TYPE_TINY:
                _fields.push_back(object<Field<int8_t>>(field->type));
                break;
            case MYSQL_TYPE_SHORT:
                _fields.push_back(object<Field<int16_t>>(field->type));
                break;
            case MYSQL_TYPE_LONG:
                _fields.push_back(object<Field<int32_t>>(field->type));
                break;
            case MYSQL_TYPE_LONGLONG:
                _fields.push_back(object<Field<int64_t>>(field->type));
                break;
            case MYSQL_TYPE_STRING:
            case MYSQL_TYPE_VAR_STRING:
                _fields.push_back(object<Field<char*>>(field->type, field->max_length ? field->max_length : 256));
                break;
            default:
                _fields.push_back(object<FieldBase>(field->type));
                break;
            }
        }
        r = true;
    } while (0);

    if (res) {
        mysql_free_result(res);
    }

    return r;
}

bool Fields::bind(StatementBase *stmt) {
    MYSQL_BIND binds[_fields.size()];
    memset(binds, 0, sizeof(MYSQL_BIND) * _fields.size());
    for (unsigned i = 0; i < _fields.size(); ++i) {
        _fields[i]->bind(binds + i);
    }

    if (mysql_stmt_bind_result(stmt->_stmt, binds)) {
        stmt->do_error();
        return false;
    }
    return true;
}

/* ResultSet */
ResultSet::ResultSet(StatementBase *stmt, size_t count) noexcept
: _stmt(stmt), _count(count)
{ }

ResultSet::~ResultSet() {
    if (_stmt) {
        mysql_stmt_free_result(_stmt->_stmt);
    }
}

bool ResultSet::fetch() noexcept {
    _curcol = 0;
    if (!_stmt) {
        return false;
    }
    int n = mysql_stmt_fetch(_stmt->_stmt);
    if (n) {
        if (n == MYSQL_DATA_TRUNCATED) {
            log_error("mmmmmmmmmmmmmmmmmmmmmmmmmmmmmysql data truncated.");
        }
        _stmt->do_error();
        return false;
    }
    return true;
}

/* StatementBase */
StatementBase::StatementBase(const char *sql) noexcept
: _mysql(), _stmt(), _sql(sql)
{ }

StatementBase::~StatementBase() noexcept {
    close();
}

void StatementBase::close() noexcept {
    if (_stmt) {
        mysql_stmt_close(_stmt);
        _stmt = nullptr;
    }
    _mysql = nullptr;
    _fields = nullptr;
}

bool StatementBase::prepare(ptr<MySQL> mysql) noexcept {
    close();
    _mysql = mysql;
    _stmt = mysql_stmt_init(&_mysql->_mysql);
    if (!_stmt) {
        do_error();
        return false;
    }
    if (mysql_stmt_prepare(_stmt, _sql.c_str(), _sql.size())) {
        do_error();
        return false;
    }
    bind();
    return true;
}

void StatementBase::do_error() noexcept {
    int n = mysql_stmt_errno(_stmt);
    switch (n) {
    case CR_SERVER_LOST:
        _mysql->_connected = false;
        break;
    }
}

int StatementBase::do_exec() noexcept {
    if (mysql_stmt_execute(_stmt)) {
        if (1062 == mysql_stmt_errno(_stmt)) {
            return -GX_EDUP;
        }
        do_error();
        return -1;
    }
    return mysql_stmt_affected_rows(_stmt);
}

ptr<ResultSet> StatementBase::do_query() noexcept {
    if (mysql_stmt_execute(_stmt)) {
        do_error();
        return object<ResultSet>(nullptr, 0);
    }
    if (!_fields) {
        _fields = object<Fields>();
        if (!_fields->init(this)) {
            do_error();
            return object<ResultSet>(nullptr, 0);
        }
        if (!_fields->bind(this)) {
            do_error();
            return object<ResultSet>(nullptr, 0);
        }
    }
    if (mysql_stmt_store_result(_stmt)) {
        do_error();
        return object<ResultSet>(nullptr, 0);
    }

    return object<ResultSet>(this, mysql_stmt_num_rows(_stmt));
}

void StatementBase::attach_container() noexcept {
    StatementContainer::instance()->_stmts.push_front(this);
}

void StatementBase::detach_container() noexcept {
    decltype(StatementContainer::instance()->_stmts)::remove(this);
}

/* MySQL */
MySQL::MySQL(const char *host, unsigned port, const char *user, const char *passwd, const char *database) noexcept {
    _host = host;
    _port = port;
    _user = user;
    _passwd = passwd;
    _database = database;
    _connected = false;
    mysql_init(&_mysql);
}

bool MySQL::connect() noexcept {
    _connected = mysql_real_connect(&_mysql, _host.c_str(), _user.c_str(), _passwd.c_str(), _database.c_str(), _port, NULL, 0);
    return _connected;
}

const char *MySQL::errorMsg() noexcept {
    return mysql_error(&_mysql);
}

int MySQL::errorNum() noexcept {
    return mysql_errno(&_mysql);
}

/* StatementContainer */
bool StatementContainer::prepare(ptr<MySQL> mysql) noexcept {
    for (auto &stmt : _stmts) {
        if (!stmt.prepare(mysql)) {
            log_error("prepare statement failed, '%s'", stmt.sql());
            return false;
        }
    }
    return true;
}

GX_NS_END



