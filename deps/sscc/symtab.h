#ifndef __SYMTAB_H__
#define __SYMTAB_H__

#include <map>
#include <list>
#include "tree.h"

class DefineTree;
class StructTree;

class SymbolTable {
public:
    typedef std::list<ptr<Tree>>::iterator iterator;
public:
    ptr<Tree> probe(const char *name, ptr<Tree> tree, bool export_it = true);
    ptr<Tree> get(const char *name);
    void exportSymbol(ptr<Tree> tree);

    iterator begin() {
        return _list.begin();
    }

    iterator end() {
        return _list.end();
    }

private:
    std::map<const char*, ptr<Tree>> _map;
    std::list<ptr<Tree>> _list;
};

#endif

