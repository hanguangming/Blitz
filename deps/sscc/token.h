#ifndef __TOKEN_H__
#define __TOKEN_H__

#include <memory>
#include <cassert>
#include <cstdint>

#include "libgx/gx.h"
using namespace gx;

#include "input.h"
#include "unistr.h"
#include "log.h"

#define KEYWORD_DECL(x, y) x,
enum {
    TOKEN_IDEN = 256,
    TOKEN_CONST_STRING,
    TOKEN_INTEGER,
    TOKEN_BOOL,
    TOKEN_BLOCK_COMMENT,
    TOKEN_LINE_COMMENT,
    TOKEN_SEGMENT,
    TOKEN_LOGIC_OR,
    TOKEN_LOGIC_AND,
    TOKEN_EQ,
    TOKEN_NE,
    TOKEN_GE,
    TOKEN_LE,
    TOKEN_SHIFT_LEFT,
    TOKEN_SHIFT_RIGHT,
    TOKEN_RANGE,
    TOKEN_KEYWORD_BEGIN,
    TOKEN_KEYWORD_BEGIN_1 = TOKEN_KEYWORD_BEGIN - 1,
#include "keyword.h"
    TOKEN_KEYWORD_END,
    TOKEN_UNKNOWN = TOKEN_KEYWORD_END,
};
#undef KEYWORD_DECL

extern const char *the_keyword_texts[TOKEN_KEYWORD_END - TOKEN_KEYWORD_BEGIN];
inline bool is_keyword(int type) {
    return type >= TOKEN_KEYWORD_BEGIN && type < TOKEN_KEYWORD_END;
}

class Token : public Object {
public:
    Token(int type, const Input &input, const char *text = nullptr) : _type(type), _loc(input.loc()), _text(text) { }

    int type() const {
        return _type;
    }

    const Location &loc() const {
        return _loc;
    }

    bool operator==(int c) const {
        return c == _type;
    }

    bool operator!=(int c) const {
        return c != _type;
    }

    virtual const char *text() const {
        return _text;
    }

	void text(const char *str) {
		_text = str;
	}

    bool is_iden() const {
        return _type == TOKEN_IDEN || ::is_keyword(_type);
    }

    bool is_keyword() const {
        return ::is_keyword(_type);
    }

    bool is_eol() const {
        return _type == 0 || _type == '\n';
    }
    static void init();
protected:
    int _type;
    Location _loc;
	const char *_text;
};

inline bool token_is_constant(const Token *token) {
    switch (token->type()) {
    case TOKEN_CONST_STRING:
    case TOKEN_INTEGER:
    case TOKEN_BOOL:
        return true;
    default:
        return false;
    }
}

inline const char *keyword_text(int type) {
    assert(type >= TOKEN_KEYWORD_BEGIN && type < TOKEN_KEYWORD_END);
    return the_keyword_texts[type - TOKEN_KEYWORD_BEGIN];
}

/* SegmentToken */
class SegmentToken : public Token {
public:
    SegmentToken(const Input &input, ptr<Token> name) 
    : Token(TOKEN_SEGMENT, input), _name(name) 
    { }

    const Token *name() const {
        return _name.get();
    }

    const char *text() const override {
        return _name ? _name->text() : nullptr;
    }
private:
    ptr<Token> _name;
};

/* IdenToken */
class IdenToken : public Token {
public:
    IdenToken(const Input &input, const Unistr &content) 
    : Token(TOKEN_IDEN, input, content)
    { }

    const char *text() const {
        return _text;
    }
};

/* StringToken */
class StringToken : public Token {
public:
    StringToken(const Input &input, const Unistr &content) 
    : Token(TOKEN_CONST_STRING, input, content)
    { }

    const char *text() const {
        return _text;
    }
};

/* IntegerToken */
class IntegerToken : public Token {
public:
    IntegerToken(const Input &input, const Unistr &text, int64_t value) 
    : Token(TOKEN_INTEGER, input), _text(text), _value(value)
    { }
    const char * text() const override {
        return _text;
    }
    int64_t value() const {
        return _value;
    }
private:
    const char *_text;
    int64_t _value;
};

/* BoolToken */
class BoolToken : public Token {
public:
    BoolToken(const Input &input, bool value) 
    : Token(TOKEN_BOOL, input), _value(value)
    { }
    const char * text() const override {
        return keyword_text(_value ? TOKEN_TRUE : TOKEN_FALSE);
    }
    bool value() const {
        return _value;
    }
private:
    bool _value;
};

#endif

