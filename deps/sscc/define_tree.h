#ifndef __DEFINE_TREE_H__
#define __DEFINE_TREE_H__

#include "tree.h"
#include "expr_tree.h"

class DefineTree : public Tree {
public:
    DefineTree() : Tree(TREE_DEFINE) { }
	DefineTree(ptr<Token> name, ptr<ExprTree> value)
	: Tree(TREE_DEFINE), _name(name), _value(value) { }

    void parse(Parser *parser) override;

    ptr<Token> name() const {
        return _name;
    }
    ptr<ExprTree> value() const {
        return _value;
    }
private:
    ptr<Token> _name;
    ptr<ExprTree> _value;
};

#endif

