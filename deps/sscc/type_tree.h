#ifndef __TYPE_TREE_H__
#define __TYPE_TREE_H__


#include "tree.h"
#include "parser.h"
#include "struct_tree.h"

enum {
	TYPE_INT8,
    TYPE_UINT8,
    TYPE_INT16,
    TYPE_UINT16,
    TYPE_INT32,
    TYPE_UINT32,
    TYPE_INT64,
    TYPE_UINT64,
    TYPE_FLOAT,
    TYPE_DOUBLE,
	TYPE_STRING,
	TYPE_STRUCT,
	TYPE_UNKNOWN,
};

inline bool type_is_integer(int type) {
	return type == 	TYPE_INT8 ||
		type == TYPE_UINT8 ||
		type == TYPE_INT16 ||
		type == TYPE_UINT16 ||
		type == TYPE_INT32 ||
		type == TYPE_UINT32 ||
		type == TYPE_INT64 ||
		type == TYPE_UINT64;
}

class TypeTree : public Tree {
public:
	TypeTree() : Tree(TREE_TYPE) { }
	void parse(Parser *parser) override;

	int type() const {
		return _type;
	}

	ptr<StructTree> decl() const {
		return _decl;
	}
private:
	int _type;
	ptr<StructTree> _decl;
};

#endif


