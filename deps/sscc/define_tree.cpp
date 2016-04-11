#include "define_tree.h"
#include "log.h"
#include "parser.h"

void DefineTree::parse(Parser *parser) 
{
    bool skip = parser->skip_newline(false);

    _name = parser->cur();
    if (!_name->is_iden()) {
        log_expect(_name->loc(), "identifier");
    }
    parser->eat(loc);

    _value = object<ExprTree>();
    _value->parse(parser);

    loc << _value->loc;

    if (!parser->cur()->is_eol()) {
        log_error(parser->cur()->loc(), "bad define");
    }
    parser->eat();
    parser->skip_newline(skip); 
}
