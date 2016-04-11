#ifndef __INCLUDE_TREE_H__
#define __INCLUDE_TREE_H__

#include "parser.h"
#include "tree.h"

class IncludeTree : public Tree {
public:
	IncludeTree(ptr<Path> path) : Tree(TREE_INCLUDE), _path(path) { }

	void parse(Parser *parser) override;
	
	ptr<Path> path() const {
		return _path;
	}
protected:
	ptr<Path> _path;
};

#endif

