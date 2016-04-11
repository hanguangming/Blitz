#ifndef __VAR_TREE_H__
#define __VAR_TREE_H__

#include "tree.h"
#include "parser.h"

enum {
    VAR_INT8,
    VAR_UINT8,
    VAR_INT16,
    VAR_UINT16,
    VAR_INT32,
    VAR_UINT32,
    VAR_INT64,
    VAR_UINT64,
    VAR_FLOAT,
    VAR_DOUBLE,
    VAR_STRING,
    VAR_CUSTOM,
    VAR_UNKNOWN,
};

class VarTree : public Tree {
public:
    VarTree() : Tree(TREE_VAR) { }
    void parse(Parser *parser) override;

    int varType() const {
        return _varType;
    }
    const char *name() const {
        return _name;
    }
    bool is_pointer() const {
        return _is_pointer;
    }
private:
    int _varType;
    const char *_name;
    bool _is_pointer;
};

#endif

