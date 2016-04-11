#ifndef __GX_CSVLOADER_H__
#define __GX_CSVLOADER_H__

#include <vector>
#include <string>
#include <map>
#include "platform.h"
#include "memory.h"
#include "data.h"

GX_NS_BEGIN
class CsvColInfo : public Object {
    friend class CsvRow;
public:
    CsvColInfo(int col, const char *name) : _col(col), _name(name) {}
    unsigned column() const noexcept {
        return _col;
    }
    const char *name() const noexcept {
        return _name.c_str();
    }
private:
    unsigned _col;
    std::string _name;
};

class CsvInfo : public Object {
    friend class CsvRow;
    friend class CsvLoader;
public:
    const CsvColInfo *operator[](const char *name) const noexcept;
    const CsvColInfo *operator[](unsigned col) const noexcept;
    const std::vector<ptr<CsvColInfo>> &columns() const noexcept {
        return _cols;
    }
private:
    bool add_col(const char *name, unsigned col);

private:
    std::map<std::string, ptr<CsvColInfo>> _name_map;
    std::map<unsigned, ptr<CsvColInfo>> _col_map;
    std::vector<ptr<CsvColInfo>> _cols;
};

class CsvRow : public Object {
    friend class CsvLoader;
public:
    size_t size() const noexcept {
        return _cols.size();
    }
    const char *operator[](unsigned i) const noexcept;
    const char *operator[](const char *name) const noexcept;

    CsvInfo *info() const noexcept {
        return _info;
    }
    
    uint64_t getu(unsigned i, unsigned defaultValue = 0) const noexcept;
    uint64_t getu(const char *name, unsigned defaultValue = 0) const noexcept;

    int64_t geti(unsigned i, int defaultValue = 0) const noexcept;
    int64_t geti(const char *name, int defaultValue = 0) const noexcept;

    const char *gets(unsigned i, const char *defaultValue) const noexcept;
    const char *gets(const char *name, const char *defaultValue) const noexcept;
    bool is_blank() const noexcept;
protected:
    ptr<CsvInfo> _info;
    std::vector<std::string> _cols;
};

class CsvLoader : public Object {
public:
    int load(const Data &data);
    const std::vector<ptr<CsvRow>> &rows() const noexcept {
        return _rows;
    }
public:
    std::vector<ptr<CsvRow>> _rows;
};

GX_NS_END

#endif

