#include "lex.h"
#include "log.h"
#include "unistr.h"

inline bool is_iden_first_char(int c) {
    return ('a' <= c && 'z' >= c) || ('A' <= c && 'Z' >= c) || ('_' == c);
}

inline bool is_iden_char(int c) {
    return is_iden_first_char(c) || ('0' <= c && '9' >= c);
}

Lex::Lex() {
}

static void __lex_block_comment(Input &input) {
    input.eat();
    input.eat();

    int n = 1;
    int c;
    while ((c = input.cur())) {
        input.eat();
        if (c == '*') {
            c = input.cur();
            if (!c) {
                return;
            }
            input.eat();
            if (c == '/' && !--n) {
                return;
            }
        }
    }
    log_expect(input.loc(), "'*/'");
}

static void __lex_line_comment(Input &input) {
    input.eat();
    input.eat();

    int c;
    while ((c = input.cur())) {
        input.eat();
        if (c == '\n') {
            break;
        }
    }
    return;
}

static ptr<Token> __lex_iden_or_keyword(Input &input, Obstack &pool) {
    pool << (char)input.cur();
    input.eat();
    int c;
    while ((c = input.cur())) {
        if (!is_iden_char(c)) {
            break;
        }
        pool << (char)c;
        input.eat();
    }
    size_t size = pool.object_size();
    const Unistr &str = Unistr::get((char*)pool.finish(), size);
    if (is_keyword(str.type())) {
        return object<Token>(str.type(), input, the_keyword_texts[str.type() - TOKEN_KEYWORD_BEGIN]);
    }
    else {
        return object<IdenToken>(input, str);
    }
}

static ptr<Token> __lex_prec_keyword(Input &input, Obstack &pool) {
    ptr<Token> token = __lex_iden_or_keyword(input, pool);
    if (token->is_iden()) {
        return token;
    }
    log_expect(token->loc(), "define or include");
    return nullptr;
}

static ptr<Token> __lex_segment(Input &input, Obstack &pool) {
    input.eat();
    input.eat();

    int c = input.cur();
    if (!is_iden_first_char(c)) {
        ptr<SegmentToken> r = object<SegmentToken>(input, nullptr);
        return r;
    }

    return object<SegmentToken>(input, __lex_iden_or_keyword(input, pool));
}

static ptr<Token> __lex_string(Input &input, Obstack &pool) {
    int c;
    size_t size;
    while ((c = input.cur())) {
        input.eat();
        switch (c) {
        case '\\':
            pool << (char)c;
            c = input.cur();
            if (!c) {
                log_expect(input.loc(), "'\"'");
            }
            input.eat();
            pool << (char)c;
            break; 
        case '"':
            size = pool.object_size();
            return object<StringToken>(input, Unistr::get((char*)pool.finish(), size));
        default:
            pool << (char)c;
            break;
        }
    }
    return nullptr;
}

static ptr<Token> __lex_integer(Input &input, Obstack &pool) {
    size_t size;
    char *str;
    int c = input.cur();
    input.eat();
    pool << (char)c;

    if (c == '0') {
        c = input.cur();
        if (c == 'x' || c == 'X') {
            pool << (char)c;
            input.eat();
            while (1) {
                c = input.cur();
                if (('0' <= c && '9' >= c) || ('a' <= c && 'f' >= c) || ('A' <= c && 'F' >= c)) {
                    input.eat();
                    pool << (char)c;
                }
                else {
                    size = pool.object_size();
                    pool << '\0';
                    str = (char*)pool.finish();
                    if (size <= 2) {
                        log_error(input.loc(), "bad hex integer");
                    }
                    return object<IntegerToken>(input, Unistr::get(str, size), std::strtoull(str, nullptr, 16));
                }
            }
        }
    }

    while (1) {
        c = input.cur();
        if (('0' <= c && '9' >= c)) {
            input.eat();
            pool << (char)c;
        }
        else {
            size = pool.object_size();
            pool << '\0';
            str = (char*)pool.finish();
            return object<IntegerToken>(input, Unistr::get(str, size), std::strtoull(str, nullptr, 10));
        }
    }
    return nullptr; 
}

ptr<Token> Lex::get(Input &input) {
    int c;
    Obstack pool;
    while ((c = input.cur())) {
        pool.clear();
        input.mark_begin();
        switch (c) {
        case ' ':
        case '\t':
            input.eat();
            continue;
        case '/':
            switch (input.look()) {
            case '*':
                __lex_block_comment(input);
                continue;
            case '/':
                __lex_line_comment(input);
                continue;
            }
            break;
        case '%':
            if (input.is_newline()) {
                c = input.look();
                if (c == '%') {
                    return __lex_segment(input, pool);
                }
                if (is_iden_first_char(c)) {
                    input.eat();
                    return __lex_prec_keyword(input, pool);
                }
            }
            break;
        case '\"':
            input.eat();
            return __lex_string(input, pool);
        case '0' ... '9':
            return __lex_integer(input, pool);
        case '|':
            if (input.look() == '|') {
                input.eat();
                input.eat();
                return object<Token>(TOKEN_LOGIC_OR, input);
            }
            break;
        case '&':
            if (input.look() == '&') {
                input.eat();
                input.eat();
                return object<Token>(TOKEN_LOGIC_AND, input);
            }
            break;
        case '=':
            if (input.look() == '=') {
                input.eat();
                input.eat();
                return object<Token>(TOKEN_EQ, input);
            }
            break;
        case '!':
            if (input.look() == '=') {
                input.eat();
                input.eat();
                return object<Token>(TOKEN_NE, input);
            }
            break;
        case '>':
            switch (input.look()) {
            case '=':
                input.eat();
                input.eat();
                return object<Token>(TOKEN_GE, input);
            case '>':
                input.eat();
                input.eat();
                return object<Token>(TOKEN_SHIFT_RIGHT, input);
            }
            break;
        case '<':
            switch (input.look()) {
            case '=':
                input.eat();
                input.eat();
                return object<Token>(TOKEN_LE, input);
            case '<':
                input.eat();
                input.eat();
                return object<Token>(TOKEN_SHIFT_LEFT, input);
            }
            break;
        case '.':
            if (input.look() == '.') {
                input.eat();
                input.eat();
                return object<Token>(TOKEN_RANGE, input);
            }
            break;
        }

        if (is_iden_first_char(c)) {
            return __lex_iden_or_keyword(input, pool);
        }
        input.eat();
        return object<Token>(c, input); 
    }
    return object<Token>(0, input);;

}



