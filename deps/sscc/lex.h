#ifndef __LEX_H__
#define __LEX_H__

#include "token.h"

class Lex : public Object {
public:
    Lex();
    ptr<Token> get(Input &input);

};

#endif

