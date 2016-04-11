#include "token.h"

const char *the_keyword_texts[TOKEN_KEYWORD_END - TOKEN_KEYWORD_BEGIN];

void Token::init()
{
#define KEYWORD_DECL(x, y) do {                                                    \
        the_keyword_texts[x - TOKEN_KEYWORD_BEGIN] = Unistr::get(y, strlen(y), x); \
    } while (0);
#include "keyword.h"
#undef KEYWORD_DECL
}


