#include "parser.h"
#include "lex.h"
#include "log.h"
#include "lang.h"
#include "define_tree.h"
#include "expr_tree.h"
#include "struct_tree.h"
#include "message_tree.h"
#include "include_tree.h"

#define QUEUE_SIZE 2

const char *the_request_name = "%sReq";
const char *the_response_name = "%sRsp";

Parser::Parser(Input &input, SymbolTable &symbols) 
: _phase(PARSE_PHASE_HEAD), 
  _index(), 
  _input(input), 
  _symbols(symbols) 
{
}

ptr<Token> Parser::cur() {
    int idx = _index % QUEUE_SIZE;
    if (_queue[idx] != nullptr) {
        return _queue[idx];
    }

    while (1) {
        ptr<Token> token = _lex->get(_input);
        if (_skip_newline && token != nullptr && *token == '\n') {
            continue;
        }

        _queue[idx] = token;
        return token;
    }
}

void Parser::eat() {
    int idx = _index++ % QUEUE_SIZE;
    _queue[idx] = nullptr;
}

void Parser::eat(Location &loc) {
    loc << cur()->loc();
    eat();
}

ptr<Token> Parser::look() {
    int idx = (_index + 1) % QUEUE_SIZE;
    if (_queue[idx] != nullptr) {
        return _queue[idx];
    }

    while (1) {
        ptr<Token> token = _lex->get(_input);
        if (_skip_newline && token != nullptr && *token == '\n') {
            continue;
        }
        _queue[idx] = token;
        return token;
    }
}

void Parser::parse_raw(std::stringstream *stream) {
    int c;
    while ((c = _input.cur())) {
        if (_input.is_newline()) {
            if (c == '%') {
                return;
            }
        }
        _input.eat();
        if (stream) {
            *stream << (char)c;
        }
    }
}

void Parser::parse_seg(ptr<Token> token) {
    SegmentToken *seg = static_cast<SegmentToken*>(token.get());
    Language *lang = Language::get(seg->name()->text());

    if (!lang) {
        log_error(token->loc(), "unknown language name '%p'.", seg->name()->text());
    }

    bool first = true;
    while (1) {
        token = cur(); 
        eat();
        if (token->is_eol()) {
            break;
        }

        ptr<Token> name = token;

        if (first) {
            if (!token->is_iden()) {
                log_expect(token->loc(), "identifier or eol");
            }
            first = false;
        }
        else {
            if (*token != ',') {
                log_expect(token->loc(), "',' or eol");
            }
            token = cur();
            eat();
            if (!token->is_iden()) {
                log_expect(token->loc(), "identifier or eol");
            }
        }
        token = cur();
        eat();
        if (*token != '=') {
            log_expect(token->loc(), "'='");
        }
        ptr<Token> value = cur();
        eat();
        if (!token_is_constant(value)) {
            log_expect(token->loc(), "constant");
        }
        lang->option(name->text(), value);
    }
    parse_raw(_input.is_root() ? &lang->head() : nullptr);
}

void Parser::prase_option() {
    bool old = skip_newline(false);
    ptr<Token> token = cur();
    eat();

    switch (token->type()) {
    case TOKEN_REQUEST_NAME:
        token = cur();
        eat();
        if (token->type() != TOKEN_CONST_STRING) {
            log_expect(token->loc(), "const string");
        }
        the_request_name = token->text();
        break;
    case TOKEN_RESPONSE_NAME:
        token = cur();
        eat();
        if (token->type() != TOKEN_CONST_STRING) {
            log_expect(token->loc(), "const string");
        }
        the_response_name = token->text();
        break;
    default:
        log_expect(token->loc(), "default_base or request_base or response_base");
    }

    token = cur();
    eat();

    if (!token->is_eol()) {
        log_expect(token->loc(), "eol");
    }
    skip_newline(old);
}

void Parser::parse_head(ptr<Token> token) {
    switch (token->type()) {
    case TOKEN_SEGMENT:
        parse_seg(token);
        break;
    case TOKEN_OPTION:
        prase_option();
        break;
    default:
        log_expect(token->loc(), "segment or option");
        break;
    }
}

void Parser::parse_enum() {
    if (cur()->type() != '{') {
        log_expect(cur()->loc(), "{");
    }
    eat();
    int64_t v = 0;
    while (1) {
        ptr<Token> token = cur();
        if (token->type() == '}') {
            eat();
            if (cur()->type() != ';') {
                log_expect(cur()->loc(), ";");
            }
            eat();
            return;
        }

        if (!token->is_iden()) {
            log_expect(token->loc(), "identifier");
        }

        Location loc;

        ptr<Token> iden_token = token;
        loc << iden_token->loc();
        eat();
        token = cur();

        object<ExprTree> expr;

        if (token->type() == '=') {
            eat();
            expr->parse(this);
            if (expr->exprType() != EXPR_INT) {
                log_expect(expr->loc, "integer expr");
            }
            v = expr->vint() + 1;
            loc << expr->loc;
        }
        else {
            expr->vint(v++);
        }

        object<DefineTree> def_tree(iden_token, expr);
        def_tree->loc = loc;
        if (def_tree != _symbols.probe(def_tree->name()->text(), def_tree, _input.is_root())) {
            log_error(def_tree->name()->loc(), "dup define name '%s'", def_tree->name()->text());
        }

        if (cur()->type() == ',') {
            eat();
            continue;
        }

        if (cur()->type() == '}') {
            continue;
        }

        log_expect(cur()->loc(), "',' or '}'");
    }
}

void Parser::parse_extern() {
    ptr<Token> name = cur();
    if (!name->is_iden()) {
        log_expect(name->loc(), "identifier");
    }
    eat();
    if (cur()->type() != ';') {
        log_expect(cur()->loc(), "';'");
    }
    eat();
    object<StructTree> tree;
    tree->name(name);
    _symbols.probe(tree->name()->text(), tree, false);
}

void Parser::parse_body(ptr<Token> token) {
    switch (token->type()) {
    case TOKEN_DEFINE:
        do {
            object<DefineTree> tree;
            tree->parse(this);
            if (tree != _symbols.probe(tree->name()->text(), tree, _input.is_root())) {
                log_error(tree->name()->loc(), "dup enum name '%s'", tree->name()->text());
            }
            return;
        } while (0);
    case TOKEN_ENUM:
        parse_enum();
        return;
    case TOKEN_EXTERN:
        parse_extern();
        return;
    case TOKEN_STRUCT:
        do {
            object<StructTree> tree;
            tree->parse(this);
            if (tree != _symbols.probe(tree->name()->text(), tree, _input.is_root())) {
                log_error(tree->name()->loc(), "dup struct name '%s'", tree->name()->text());
            }
            return;
        } while (0);
    case TOKEN_MESSAGE:
        do {
            object<MessageTree> tree;
            tree->parse(this);
            if (tree != _symbols.probe(tree->name()->text(), tree, _input.is_root())) {
                log_error(tree->name()->loc(), "dup message name '%s'", tree->name()->text());
            }
            return;
        } while (0);
        break;
    default:
        log_expect(token->loc(), "%define or enum or or struct or message");
    }
}

void Parser::parse_tail(ptr<Token> token) {
}

bool Parser::parse() {
    skip_newline(false);

    while (1) {
        ptr<Token> token = cur();
        if (!token->type()) {
            break;
        }
        eat();
        if (*token == '\n') {
            continue;
        }

        if (*token == TOKEN_INCLUDE) {
            bool old_skip_newline = skip_newline();
            skip_newline(false);
            token = cur();
            if (*token == TOKEN_CONST_STRING && look()->is_eol()) {
                eat();
                eat();
                skip_newline(old_skip_newline);
                ptr<Path> path = object<Path>(token->text());
                if (_input.is_root()) {
                    _symbols.exportSymbol(object<IncludeTree>(path));
                }
                _input.load(path);
            }
            else {
                log_expect(token->loc(), "string eol");
            }
            continue;
        }
        SegmentToken *seg = nullptr; 
        if (token->type() == TOKEN_SEGMENT) {
            seg = static_cast<SegmentToken*>(token.get());
            if (!seg->name()) {
                bool old_skip_newline = skip_newline();
                skip_newline(false);
                if (!look()->is_eol()) {
                    log_expect(token->loc(), "eol");
                }
                skip_newline(old_skip_newline);
                eat();
            }
            else {
                seg = nullptr;
            }
        }

        switch (_phase) {
        case PARSE_PHASE_HEAD:
            if (seg) {
                _phase = PARSE_PHASE_BODY;
                continue;
            }
            skip_newline(false);
            parse_head(token); 
            break;
        case PARSE_PHASE_BODY:
            if (seg) {
                _phase = PARSE_PHASE_TAIL;
                continue;
            }
            skip_newline(true);
            parse_body(token);
            break;
        case PARSE_PHASE_TAIL:
            if (seg) {
                log_error(token->loc(), "too more segment declear.");
            }
            skip_newline(false);
            parse_tail(token);
            break;
        }
    }
    return true; 
}


