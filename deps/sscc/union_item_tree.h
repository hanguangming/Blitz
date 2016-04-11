#ifndef __UNION_ITEM_TREE_H__
#define __UNION_ITEM_TREE_H__

#include "parser.h"
#include "tree.h"
#include "define_tree.h"
#include "struct_item_tree.h"

class UnionItemTree : public Tree {
public:
	UnionItemTree() : Tree(TREE_UNION_ITEM) { }
	void parse(Parser *parser) override;

	ptr<DefineTree> index() const {
		return _index;
	}

	ptr<StructItemTree> decl() const {
		return _decl;
	}
private:
	ptr<DefineTree> _index;
	object<StructItemTree> _decl;
};


#endif

