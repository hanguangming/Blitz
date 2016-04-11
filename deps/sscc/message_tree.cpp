#include "message_tree.h"
#include "log.h"

void MessageTree::parse(Parser *parser) {
    static object<StructTree> request_base(object<IdenToken>(parser->input(), Unistr::get("SSCC_REQUEST_BASE")));
    static object<StructTree> response_base(object<IdenToken>(parser->input(), Unistr::get("SSCC_RESPONSE_BASE")));

    _name = parser->cur();
    if (!_name->is_iden()) {
        log_expect(_name->loc(), "identifier");
    }
    parser->eat();

    if (parser->cur()->type() != '<') {
        log_expect(parser->cur()->loc(), "'<'");
    }
    parser->eat();

    ptr<Token> id_token = parser->cur();
    if (!id_token->is_iden()) {
        log_expect(_name->loc(), "identifier");
    }
    parser->eat();

    ptr<Tree> id_tree = parser->symbols().get(id_token->text());
    if (!id_tree) {
        log_error(id_token->loc(), "unknown id name '%s'", id_token->text());
    }
    if (id_tree->type() != TREE_DEFINE) {
        log_error(id_token->loc(), "id '%s' is not a define", id_token->text());
    }
    _id = id_tree.cast<DefineTree>();
    
    if (parser->cur()->type() != '>') {
        log_expect(parser->cur()->loc(), "'>'");
    }
    parser->eat();

    if (parser->cur()->type() != '{') {
        log_expect(parser->cur()->loc(), "'{'");
    }
    parser->eat();

    while (1) {
        ptr<Token> token = parser->cur();
        if (parser->cur()->type() == '}') {
            parser->eat();
            break;
        }

        if (token->type() != TOKEN_STRUCT) {
            log_expect(token->loc(), "struct");
        }
        parser->eat();
    
        token = parser->cur();
        parser->eat();
        switch (token->type()) {
        case TOKEN_REQUEST:
            if (_req) {
                log_error(token->loc(), "dup declare request");
            }
            _req = object<StructTree>();
            _req->parseInherited(parser, request_base);
            token->text(Unistr::get(Pool::instance()->printf(the_request_name, _name->text())));
            if (_req != parser->symbols().probe(token->text(), _req, false)) {
                log_error(token->loc(), "dup struct name");
            }
            _req->name(token);
            _req->message = this;
            break;
        case TOKEN_RESPONSE:
            if (_rsp) {
                log_error(token->loc(), "dup declare response");
            }
            _rsp = object<StructTree>();
            _rsp->parseInherited(parser, response_base);
            token->text(Unistr::get(Pool::instance()->printf(the_response_name, _name->text())));
            if (_rsp != parser->symbols().probe(token->text(), _rsp, false)) {
                log_error(token->loc(), "dup struct name");
            }
            _rsp->name(token);
            _rsp->message = this;
            break;
        default:
            log_expect(token->loc(), "request or response");
        }
    }

    if (!_req) {
        log_error(id_token->loc(), "message must declare request");
    }


    if (parser->cur()->type() != ';') {
        log_expect(parser->cur()->loc(), "';'");
    }
    parser->eat();
}



