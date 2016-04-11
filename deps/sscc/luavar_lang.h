#ifndef __LUAVAR_LANG_H__
#define __LUAVAR_LANG_H__

#include "lang.h"

class LuaVarLang : public Language {
public:
    LuaVarLang();
    void option(const char *name, ptr<Token> value) override;
    void print(SymbolTable &symbols, FILE *file) override;
};

#endif

