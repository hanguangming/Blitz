#ifndef __MESSAGE_TREE_H__
#define __MESSAGE_TREE_H__

#include "struct_tree.h"
#include "define_tree.h"

class MessageTree : public Tree {
public:
	MessageTree() : Tree(TREE_MESSAGE) { }
	void parse(Parser *parser) override;
	
	ptr<Token> name() const {
		return _name;	
	}

	ptr<DefineTree> id() const {
		return _id;
	}

	ptr<StructTree> req() const {
		return _req;
	}

	ptr<StructTree> rsp() const {
		return _rsp;
	}
protected:
	void parseBody(Parser *parser);

protected:
	ptr<Token> _name;
	ptr<DefineTree> _id;
	ptr<StructTree> _req;
	ptr<StructTree> _rsp;
};

#endif

