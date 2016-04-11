#include "union_tree.h"
#include "struct_tree.h"

void UnionTree::parse(Parser *parser) {
	if (parser->cur()->type() != '<') {
		log_expect(parser->cur()->loc(), "'<'");
	}
	parser->eat();

	ptr<Token> token = parser->cur();
	if (!token->is_iden()) {
		log_expect(token->loc(), "identifier");
	}
	parser->eat();

	ptr<Tree> tree = _struct->getItem(token->text(), false);
	if (!tree) {
		log_error(token->loc(), "unknown key field '%s'", token->text());
	}
	if (tree->type() != TREE_STRUCT_ITEM) {
		log_error(token->loc(), "key field must is integer type", token->text());
	}
	if (!type_is_integer(tree.cast<StructItemTree>()->type()->type())) {
		log_error(token->loc(), "key field must is integer type", token->text());
	}
	_key = tree.cast<StructItemTree>();

	if (parser->cur()->type() != '>') {
		log_expect(parser->cur()->loc(), "'>'");
	}
	parser->eat();

	if (parser->cur()->type() != '{') {
		log_expect(parser->cur()->loc(), "'{'");
	}
	parser->eat();

	while (1) {
		switch (parser->cur()->type()) {
		case '}':
			do {
				parser->eat();
				ptr<Token> token = parser->cur();

				if (token->is_iden()) {
					parser->eat();
					_name = token;
					token = parser->cur();
				}

				if (token->type() == ';') {
					parser->eat();
					return;
				}
				else {
					log_expect(token->loc(), "identifier or ';'");
				}
				return;
			} while (0);
		default:
			do {
				object<UnionItemTree> item;
				item->parse(parser);
				for (auto sym : _symbols) {
					if (item->index()->value()->vint() == sym->index()->value()->vint()) {
						log_error(item->index()->loc, "dup union item index");
					}
					if (item->decl()->name()->text() == sym->decl()->name()->text()) {
						log_error(item->decl()->name()->loc(), "dup union item name");
					}
				}
				_symbols.push_back(item);
			} while (0);
		}
	}
}

