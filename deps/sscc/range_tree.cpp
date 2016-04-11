#include "range_tree.h"

void RangeTree::parse(Parser *parser) {
	ptr<Tree> tree;
	ptr<Token> token = parser->cur();
	if (token->is_iden()) {
		parser->eat();

		tree = parser->symbols().get(token->text());
		if (!tree) {
			log_error(token->loc(), "unknown define name '%s'", token->text());
		}
		if (tree->type() != TREE_DEFINE) {
			log_error(token->loc(), "'%s' is not a define", token->text());
		}

		_min = tree.cast<DefineTree>();
		token = parser->cur();
	}

	if (token->type() == TOKEN_RANGE) {
		parser->eat();
		token = parser->cur();
	}
	else {
		_max = _min;
		return;
	}

	if (token->is_iden()) {
		parser->eat();

		tree = parser->symbols().get(token->text());
		if (!tree) {
			log_error(token->loc(), "unknown define name '%s'", token->text());
		}
		if (tree->type() != TREE_DEFINE) {
			log_error(token->loc(), "'%s' is not a define", token->text());
		}

		_max = tree.cast<DefineTree>();
	}
}


