#ifndef __STRUCT_ITEM_TREE_H__
#define __STRUCT_ITEM_TREE_H__

#include "tree.h"
#include "parser.h"
#include "type_tree.h"
#include "range_tree.h"

class StructItemTree : public Tree {
public:
    StructItemTree() : Tree(TREE_STRUCT_ITEM) { }
    void parse(Parser *parser) override;

	ptr<Token> name() const {
		return _name;
	}

	ptr<TypeTree> type() const {
		return _type;
	}

	ptr<RangeTree> array() const {
		return _array;
	}

	ptr<RangeTree> range() const {
		return _range;
	}

	ptr<ExprTree> defaultValue() const {
		return _default;
	}
public:
	ptr<Token> _name;
	object<TypeTree> _type;
	ptr<RangeTree> _array;
	object<RangeTree> _range;
	ptr<ExprTree> _default;
};

#endif

