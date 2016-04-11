#ifndef __UNION_PTR_ITEM_TREE_H__
#define __UNION_PTR_ITEM_TREE_H__

#include "tree.h"
#include "parser.h"
#include "struct_tree.h"
#include "define_tree.h"

class UnionPtrItemTree : public Tree {
public:
	UnionPtrItemTree() : Tree(TREE_UNION_PTR_ITEM) { }

	void parse(Parser *parser) override;

	ptr<DefineTree> index() const {
		return _index;
	}

	ptr<StructTree> decl() const {
		return _decl;
	}
protected:
	ptr<DefineTree> _index;
	ptr<StructTree> _decl;
};

#endif

