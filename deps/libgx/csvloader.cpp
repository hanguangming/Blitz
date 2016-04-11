#include "csvloader.h"
#include "utils.h"
GX_NS_BEGIN

/* CsvInfo */
bool CsvInfo::add_col(const char *name, unsigned col) {
    object<CsvColInfo> info(col, name);
    if (!_name_map.emplace(name, info).second) {
        return false;
    }
    if (!_col_map.emplace(col, info).second) {
        return false;
    }
    _cols.emplace_back(info);
    return true;
}

const CsvColInfo *CsvInfo::operator[](const char *name) const noexcept {
    auto it = _name_map.find(name);
    if (it == _name_map.end()) {
        return nullptr;
    }
    return it->second;
}

const CsvColInfo *CsvInfo::operator[](unsigned col) const noexcept {
    auto it = _col_map.find(col);
    if (it == _col_map.end()) {
        return nullptr;
    }
    return it->second;
}

/* CsvRow */
const char *CsvRow::operator[](unsigned i) const noexcept {
    if (i < _cols.size()) {
        return _cols[i].c_str();
    }
    return "";
}

const char *CsvRow::operator[](const char *name) const noexcept {
    const CsvColInfo *col = (*_info)[name];
    if (!col) {
        return "";
    }
    return (*this)[col->_col];
}

uint64_t CsvRow::getu(unsigned i, unsigned defaultValue) const noexcept {
    const char *str = (*this)[i];
    if (!*str) {
        return defaultValue;
    }
    return (uint64_t)std::strtoul(str, nullptr, 10);
}

uint64_t CsvRow::getu(const char *name, unsigned defaultValue) const noexcept {
    const char *str = (*this)[name];
    if (!*str) {
        return defaultValue;
    }
    return (uint64_t)strtoul(str, nullptr, 10);
}

int64_t CsvRow::geti(unsigned i, int defaultValue) const noexcept {
    const char *str = (*this)[i];
    if (!*str) {
        return defaultValue;
    }
    return strtoll(str, nullptr, 10);
}

int64_t CsvRow::geti(const char *name, int defaultValue) const noexcept {
    const char *str = (*this)[name];
    if (!*str) {
        return defaultValue;
    }
    return strtoll(str, nullptr, 10);
}

const char *CsvRow::gets(unsigned i, const char *defaultValue) const noexcept {
    const char *str = (*this)[i];
    if (*str) {
        return str;
    }
    return defaultValue;
}

const char *CsvRow::gets(const char *name, const char *defaultValue) const noexcept {
    const char *str = (*this)[name];
    if (*str) {
        return str;
    }
    return defaultValue;
}

bool CsvRow::is_blank() const noexcept {
    for (auto &str : _cols) {
        if (str.size() != 0) {
            return false;
        }
    }
    return true;
}

/* CsvLoader */
#define GETC() do {      \
    c = p < end ? *p : 0;\
    while (c) {          \
        p++;             \
        if ('\n' == c) { \
            lineno++;    \
        }                \
        if (c != '\r') { \
            break;       \
        }                \
        c = *p;          \
    }                    \
} while (0)

int CsvLoader::load(const Data &data) {
    char *p = data.data();
    char *end = p + data.size();
    int c;
    int lineno = 1;
    std::string str;
    ptr<CsvRow> old;
    ptr<CsvRow> row = object<CsvRow>();
    ptr<CsvInfo> info;

    GETC();
    while (1) {
        switch (c) {
        default:
            while (1) {
                if (c == '"') {
                    GETC();
                    if (c == '"') {
                        str += c;
                        GETC();
                    }
                    else {
                        return lineno;
                    }
                }
                else if (!c || c == ',' || c == '\n') {
                    break;
                }
                else {
                    str += c;
                    GETC();
                }
            }
            break;

        case '"':
            GETC();
            while (1) {
                if (!c) {
                    return lineno;
                }
                else if (c == '"') {
                    GETC();
                    if (c == '"') {
                        str += c;
                        GETC();
                    }
                    else {
                        if (c && c != ',' && c != '\n') {
                            return lineno;
                        }
                        break;
                    }
                }
                else {
                    str += c;
                    GETC();
                }
            }
            break;

        case ',':
            row->_cols.push_back(trim(str));
            str.clear();
            GETC();
            break;
        case '\n':
        case '\0':
            row->_cols.push_back(trim(str));
            if (info != nullptr) {
                if (!row->is_blank()) {
                    row->_info = info;
                    _rows.emplace_back(row);
                    row = object<CsvRow>();
                }
            }
            else {
                if (row->is_blank()) {
                    info = object<CsvInfo>();
                    if (old == nullptr) {
                        return lineno;
                    }
                    for (unsigned i = 0; i < old->_cols.size(); i++) {
                        if (old->_cols[i].size()) {
                            if (!info->add_col(old->_cols[i].c_str(), i)) {
                                return lineno;
                            }
                        }
                    }
                    old = nullptr;
                }
                else {
                    old = row;
                }
            }

            if (!c) {
                return 0;
            }

            GETC();
            row = object<CsvRow>();
            str.clear();
            break;
        }
    }
}

GX_NS_END

