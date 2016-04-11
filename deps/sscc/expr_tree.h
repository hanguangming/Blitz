#ifndef __CONSTEXPR_TREE_H__
#define __CONSTEXPR_TREE_H__

#include <cstdint>
#include <cassert>
#include "tree.h"
#include "parser.h"

enum {
    EXPR_INT,
    EXPR_STRING,
    EXPR_UNKNOWN,
};

class ExprTree : public Tree
{
public:
    ExprTree() : Tree(TREE_EXPR), _exprType(EXPR_UNKNOWN) { }
    ExprTree(int64_t value) : Tree(TREE_EXPR), _exprType(EXPR_INT), _vint(value) { }
    ExprTree(const char *value) : Tree(TREE_EXPR), _exprType(EXPR_STRING), _vstr(value) { }

    void parse(Parser *parser) override;
    int exprType() const {
        return _exprType;
    }

    int64_t vint() const {
        assert(_exprType == EXPR_INT);
        return _vint;
    }

    void vint(int64_t value) {
        _vint = value;
        _exprType = EXPR_INT;
    }

    const char *vstr() const {
        assert(_exprType == EXPR_STRING);
        return _vstr;
    }

    void vstr(const char *value) {
        _vstr = value;
        _exprType = EXPR_STRING;
    }
protected:
    int _exprType;
    union {
        int64_t _vint;
        const char *_vstr;
    };
};

#endif

