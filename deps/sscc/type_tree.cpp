#include "type_tree.h"

void TypeTree::parse(Parser *parser) {
	ptr<Token> token = parser->cur();

	switch (token->type()) {
	case TOKEN_INT8:
		_type = TYPE_INT8;
		break;
	case TOKEN_UINT8:
		_type = TYPE_UINT8;
		break;
	case TOKEN_INT16:
		_type = TYPE_INT16;
		break;
	case TOKEN_UINT16:
		_type = TYPE_UINT16;
		break;
	case TOKEN_INT32:
		_type = TYPE_INT32;
		break;
	case TOKEN_UINT32:
		_type = TYPE_UINT32;
		break;
	case TOKEN_INT64:
		_type = TYPE_INT64;
		break;
	case TOKEN_UINT64:
		_type = TYPE_UINT64;
		break;
	case TOKEN_FLOAT:
		_type = TYPE_FLOAT;
		break;
	case TOKEN_DOUBLE:
		_type = TYPE_DOUBLE;
		break;
	case TOKEN_STRING:
		_type = TYPE_STRING;
		break;
	default:
		if (token->is_iden()) {
			_type = TYPE_STRUCT;
			_decl = parser->symbols().get(token->text()).cast<StructTree>();
			if (!_decl) {
				log_error(token->loc(), "unknown data type '%s'", token->text());
			}
			break;
		}
		log_expect(token->loc(), "data type or union");
	}

	parser->eat();
}


