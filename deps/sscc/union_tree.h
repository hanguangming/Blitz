#ifndef __UNION_TREE_H__
#define __UNION_TREE_H__

#include <list>
#include "parser.h"
#include "tree.h"
#include "union_item_tree.h"
#include "struct_item_tree.h"

struct StructTree;

class UnionTree : public Tree {
public:
	UnionTree(StructTree *the_struct) : Tree(TREE_UNION), _struct(the_struct) { }
	void parse(Parser *parser) override;
	
	ptr<Token> name() const {
		return _name;
	}

	ptr<StructItemTree> key() const {
		return _key;
	}

	typedef std::list<ptr<UnionItemTree>>::iterator iterator;

	iterator begin() {
		return _symbols.begin();
	}

	iterator end() {
		return _symbols.end();
	}

	size_t size() const {
		return _symbols.size();
	}
private:
	StructTree *_struct;
	ptr<StructItemTree> _key;
	ptr<Token> _name;
	std::list<ptr<UnionItemTree>> _symbols;
};

#endif

