#ifndef __LANG_H__
#define __LANG_H__

#include <sstream>
#include <cstdio>
#include "unistr.h"
#include "token.h"
#include "printer.h"
#include "symtab.h"

class Language : public Object {
public:
    Language(const char *name);
    virtual ~Language() { }
    const char *name() const {
        return _name;
    }

public:
    static Language *get(const char *name);
    template <typename _T>
    static Language *reg() {
        return reg(object<_T>());
    }

    std::stringstream &head() {
        return _head;
    }
    std::stringstream &tail() {
        return _tail;
    }

    virtual void option(const char *name, ptr<Token> value) = 0;
	virtual void print(SymbolTable &symbols, FILE *file) = 0;
private:
    static Language *reg(ptr<Language> lang);

protected:
    const char *_name;
    std::stringstream _head;
    std::stringstream _tail;
};


#endif
