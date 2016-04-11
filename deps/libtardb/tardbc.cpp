#include "libgx/gx.h"
#include "cpp_printer.h"
GX_NS_USING

enum {
    FT_INT8,
    FT_UINT8,
    FT_INT16,
    FT_UINT16,
    FT_INT32,
    FT_UINT32,
    FT_INT64,
    FT_UINT64,
    FT_NUMBER,
    FT_STRING,
};

class Table;

class TableField : public Object {
public:
    std::string _name;
    int _type;
    unsigned _index;
};

class TableIndex : public Object {
public:
    void load(Table *table, ScriptTable *t);
public:
    std::string _name;
    std::vector<ptr<TableField>> _fields;
};

class Table : public Object {
public:
    Table(std::string &&name) : _name(name) { }
    void load(ScriptTable *table) {
        ptr<ScriptTable> fields = table->read_table("field");
        if (!fields->is_nil()) {
            for (unsigned i = 1; ; ++i) {
                auto t = fields->read_table(i);
                if (t->is_nil()) {
                    break;
                }
                std::string name = t->read_string("name", "");
                if (!name.size()) {
                    fprintf(stderr, "field name is empty.\n");
                    exit(1);
                }
                std::string type = t->read_string("type", "");
                object<TableField> field;
                field->_name = name;
                field->_index = i - 1;
                if (type == "int8") {
                    field->_type = FT_INT8;
                }
                else if (type == "uint8") {
                    field->_type = FT_UINT8;
                }
                else if (type == "int16") {
                    field->_type = FT_INT16;
                }
                else if (type == "uint16") {
                    field->_type = FT_UINT16;
                }
                else if (type == "int32") {
                    field->_type = FT_INT32;
                }
                else if (type == "uint32") {
                    field->_type = FT_UINT32;
                }
                else if (type == "int64") {
                    field->_type = FT_INT64;
                }
                else if (type == "uint64") {
                    field->_type = FT_UINT64;
                }
                else if (type == "double") {
                    field->_type = FT_NUMBER;
                }
                else if (type == "string") {
                    field->_type = FT_STRING;
                }
                else {
                    fprintf(stderr, "unknown filed type '%s'.\n", type.c_str());
                    exit(1);
                }
                auto r = _fields.emplace(name, field);
                if (!r.second) {
                    fprintf(stderr, "dup file name '%s'.\n", name.c_str());
                    exit(1);
                }
                _field_list.push_back(field);
            }
        }
        ptr<ScriptTable> indies = table->read_table("index");
        if (!indies->is_nil()) {
            for (auto &v : *indies) {
                object<TableIndex> index;
                index->_name = v.name->string();
                index->load(this, v.value->table());
                auto r = _indies.emplace(index->_name, index);
                if (!r.second) {
                    fprintf(stderr, "dup index name '%s'.\n", index->_name.c_str());
                    exit(1);
                }
            }
        }
    }
public:
    std::string _name;
    std::map<std::string, ptr<TableField>> _fields;
    std::vector<ptr<TableField>> _field_list;
    std::map<std::string , ptr<TableIndex>> _indies;
};

class Database : public Object {
public:
    Database(const char *name) : _name(name) { }
    void load(ScriptTable *table) {
        ptr<ScriptTable> tables = table->read_table("table");
        for (auto &v : *tables) {
            object<Table> tb(v.name->string());
            tb->load(v.value->table());
            _tables[tb->_name] = tb;
        }
    }
public:
    std::string _name;
    std::map<std::string, ptr<Table>> _tables;
};

inline void TableIndex::load(Table *table, ScriptTable *t) {
    auto fields = t->read_table("field");
    if (!fields->is_nil()) {
        for (unsigned i = 1; ; ++i) {
            auto field = fields->read_table(i);
            if (field->is_nil()) {
                break;
            }
            std::string name = field->read_string(1, "");
            auto it = table->_fields.find(name);
            if (it == table->_fields.end()) {
                fprintf(stderr, "unknown index field name '%s'.\n", name.c_str());
                exit(1);
            }
            for (auto &p : _fields) {
                if (p == it->second) {
                    fprintf(stderr, "dup index field name '%s'.\n", name.c_str());
                    exit(1);
                }
            }
            _fields.push_back(it->second);
        }
    }
}

std::map<std::string, ptr<Database>> _databases;

void load(const char *input) {
    ptr<Data> data = FileLoader::load(input);
    if (!data) {
        fprintf(stderr, "load file '%s' failed.\n", input);
        exit(1);
    }
    if (luaL_dostring(*the_app->script(), data->data())) {
        const char *error = lua_tostring(*the_app->script(), -1);
        fprintf(stderr, "load file %s, %s.", input, error);
        exit(1);
    }

    ptr<ScriptTable> databases = the_app->script()->read_table("database");
    if (!databases) {
        fprintf(stderr, "no database.\n");
        exit(1);
    }

    for (auto &v : *databases) {
        object<Database> db(v.name->string().c_str());
        db->load(v.value->table());
        _databases[db->_name] = db;
    }
}

void usage() {
     fprintf(stderr, "Usage: tardbc -i input_file -o output_file\n");
     exit(1);
}

int main(int argc, char **argv) {
    int opt;
    const char *input_name = nullptr;
    const char *output_name = nullptr;

    while ((opt = getopt(argc, argv, "i:o:")) != -1) {
        switch (opt) {
        case 'i':
            input_name = optarg;
            break;
        case 'o':
            output_name = optarg;
            break;
        default:
            usage();
        }
    }

    if (!input_name || !output_name) {
        usage();
    }

    load(input_name);
    return 0;
}
