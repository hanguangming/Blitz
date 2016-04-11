#include "struct_tree.h"
#include "union_tree.h"
#include "union_ptr_tree.h"
#include "log.h"

void StructTree::parse(Parser *parser) 
{
    _name = parser->cur();
    if (!_name->is_iden()) {
        log_expect(_name->loc(), "identifier");
    }
    parser->eat(loc);
    parseInherited(parser, nullptr);
}

void StructTree::parseInherited(Parser *parser, ptr<StructTree> inherited) {
    static object<StructTree> default_base(object<IdenToken>(parser->input(), Unistr::get("SSCC_DEFAULT_BASE")));
    if (!inherited) {
        inherited = default_base;
    }
    if (parser->cur()->type() == ':') {
        parser->eat(loc);
        ptr<Token> token = parser->cur();
        if (!token->is_iden()) {
            log_expect(token->loc(), "identifier");
        }
        parser->eat(loc);
        _inherited = parser->symbols().get(token->text());
        if (!_inherited) {
            log_error(token->loc(), "unknown struct name '%s'", token->text());
        }
    }
    else if (inherited) {
        _inherited = inherited;
    }
    parseBody(parser);
}

void StructTree::parseBody(Parser *parser) {
    if (parser->cur()->type() != '{') {
        log_expect(parser->cur()->loc(), "{");
    }
    parser->eat(loc);

    parseItems(parser);

    if (parser->cur()->type() != ';') {
        log_expect(parser->cur()->loc(), ";");
    }
    parser->eat(loc);
}

void StructTree::parseItems(Parser *parser) {
    while (1) {
        ptr<Token> token = parser->cur();
        switch (token->type()) {
        case '}':
            parser->eat();
            return;
        case TOKEN_UNION:
            parser->eat();
            parseUnion(parser);
            break;
        case TOKEN_UNION_PTR:
            parser->eat();
            parseUnionPtr(parser);
            break;
        default:
            do {
                object<StructItemTree> item;
                item->parse(parser);
    
                if (getItem(item->name()->text(), true)) {
                    log_error(item->name()->loc(), "dup item name '%s'", item->name()->text());
                }
                _symbols.push_back(item);
            } while (0);
        }
    }
}

void StructTree::parseUnion(Parser *parser) {
    object<UnionTree> tree(this);
    tree->parse(parser);

    if (tree->name()) {
        if (getItem(tree->name()->text(), true)) {
            log_error(tree->name()->loc(), "dup item name '%s'", tree->name()->text());
        }
    }
    else {
        for (auto sym : *tree) {
            if (getItem(sym->decl()->name()->text(), true)) {
                log_error(sym->decl()->name()->loc(), "dup item name '%s'", sym->decl()->name()->text());
            }
        }
    }
    _symbols.push_back(tree);
}

void StructTree::parseUnionPtr(Parser *parser) {
    object<UnionPtrTree> tree(this);
    tree->parse(parser);

    if (getItem(tree->name()->text(), true)) {
        log_error(tree->name()->loc(), "dup item name '%s'", tree->name()->text());
    }
    _symbols.push_back(tree);
}

ptr<Tree> StructTree::getItem(const char *name, bool find_union) {
    for (auto sym : _symbols) {
        switch (sym->type()) {
        case TREE_STRUCT_ITEM:
            if (sym.cast<StructItemTree>()->name()->text() == name) {
                return sym;
            }
            break;
        case TREE_UNION:
            if (sym.cast<UnionTree>()->name()) {
                if (sym.cast<UnionTree>()->name()->text() == name) {
                    return sym;
                }
            }
            else if (find_union) {
                for (auto sym2 : *sym.cast<UnionTree>()) {
                    if (sym2->decl()->name()->text() == name) {
                        return sym2;
                    }
                }
            }
            break;
        case TREE_UNION_PTR:
            if (sym.cast<UnionPtrTree>()->name()->text() == name) {
                return sym;
            }
            break;
        }
    }
    return nullptr;
}

