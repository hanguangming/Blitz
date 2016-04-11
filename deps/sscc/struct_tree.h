#ifndef __STRUCT_TREE_H__
#define __STRUCT_TREE_H__

#include <list>
#include "tree.h"
#include "parser.h"

class MessageTree;

class StructTree : public Tree {
public:
    StructTree() : Tree(TREE_STRUCT), message() { }
    StructTree(ptr<Token> name) : Tree(TREE_STRUCT), _name(name), message() { }

    void parse(Parser *parser) override;

    ptr<Token> name() const {
        return _name;
    }

	void name(ptr<Token> value) {
		_name = value;
	}

    ptr<StructTree> inherited() const {
        return _inherited.cast<StructTree>();
    }

    void parseInherited(Parser *parser, ptr<StructTree> inherited);
    void parseBody(Parser *parser);
    void parseItems(Parser *parser);
    ptr<Tree> getItem(const char *name, bool find_union);
    
    typedef std::list<ptr<Tree>>::iterator iterator;

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
    void parseUnion(Parser *parser);
    void parseUnionPtr(Parser *parser);
protected:
    ptr<Token> _name;
    ptr<Tree> _inherited;
    std::list<ptr<Tree>> _symbols;
public:
	MessageTree *message;
};

#endif

