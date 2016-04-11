#ifndef __UNION_PTR_TREE_H__
#define __UNION_PTR_TREE_H__

#include <list>
#include "parser.h"
#include "tree.h"
#include "union_ptr_item_tree.h"

class StructItemTree;
class StructTree;

class UnionPtrTree : public Tree {
public:
	UnionPtrTree(StructTree *the_struct) : Tree(TREE_UNION_PTR), _struct(the_struct) { }

	void parse(Parser *parser) override;
	ptr<Token> name() const {
		return _name;
	}

	ptr<StructItemTree> key() const {
		return _key;
	}

	typedef std::list<ptr<UnionPtrItemTree>>::iterator iterator;

	iterator begin() {
		return _symbols.begin();
	}

	iterator end() {
		return _symbols.end();
	}

	size_t size() const {
		return _symbols.size();
	}
protected:
	ptr<Token> _name;
	ptr<StructItemTree> _key;
	std::list<ptr<UnionPtrItemTree>> _symbols;

	StructTree *_struct;
};

#endif

