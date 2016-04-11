#ifndef __CPP_LANG_H__
#define __CPP_LANG_H__

#include "lang.h"
#include "cpp_printer.h"
#include "define_tree.h"
#include "struct_tree.h"
#include "struct_item_tree.h"
#include "type_tree.h"
#include "union_tree.h"
#include "union_ptr_tree.h"
#include "message_tree.h"
#include "include_tree.h"

class CppLang : public Language {
public:
    CppLang();
    void option(const char *name, ptr<Token> value) override;
    void print(SymbolTable &symbols, FILE *file) override;

protected:
    void print_define(CppPrinter &printer, ptr<DefineTree> tree);
    void print_struct(CppPrinter &printer, ptr<StructTree> tree);
    void print_message(CppPrinter &printer, ptr<MessageTree> tree);
    void print_message_opt(CppPrinter &printer, ptr<MessageTree> tree);
    void print_include(CppPrinter &printer, ptr<IncludeTree> tree);

    void print_dump(CppPrinter &printer, ptr<StructTree> tree);
    void print_serial(CppPrinter &printer, ptr<StructTree> tree);
    void print_unserial(CppPrinter &printer, ptr<StructTree> tree);
    void print_tolua(CppPrinter &printer, ptr<StructTree> tree);
    void print_fromlua(CppPrinter &printer, ptr<StructTree> tree);

    void print_indent(CppPrinter &printer);

    void print_var(CppPrinter &printer, ptr<StructItemTree> tree, bool union_item);
    void print_union(CppPrinter &printer, ptr<UnionTree> tree);
    void print_union_ptr(CppPrinter &printer, ptr<UnionPtrTree> tree);

    const char *type_decl(ptr<TypeTree> tree, bool union_item);
    const char *type_decl(ptr<StructItemTree> tree, bool union_item);

    void print_base_var_serial(CppPrinter &printer, ptr<StructItemTree> tree, const char *name);
    void print_base_var_unserial(CppPrinter &printer, ptr<StructItemTree> tree, const char *name);
    void print_base_var_dump(CppPrinter &printer, ptr<StructItemTree> tree, const char *name);
    void print_base_var_tolua(CppPrinter &printer, ptr<StructItemTree> tree, const char *name);
    void print_base_var_fromlua(CppPrinter &printer, ptr<StructItemTree> tree, const char *name);

    void print_struct_serial(CppPrinter &printer, ptr<StructItemTree> tree, const char *name, bool is_pointer);
    void print_struct_unserial(CppPrinter &printer, ptr<StructItemTree> tree, const char *name, bool is_pointer);
    void print_struct_dump(CppPrinter &printer, ptr<StructItemTree> tree, const char *name, bool is_pointer);
    void print_struct_tolua(CppPrinter &printer, ptr<StructItemTree> tree, const char *name, bool is_pointer);
    void print_struct_fromlua(CppPrinter &printer, ptr<StructItemTree> tree, const char *name, bool is_pointer);

    void print_array_serial(CppPrinter &printer, ptr<StructItemTree> tree, const char *name);
    void print_array_unserial(CppPrinter &printer, ptr<StructItemTree> tree, const char *name);
    void print_array_dump(CppPrinter &printer, ptr<StructItemTree> tree, const char *name);
    void print_array_tolua(CppPrinter &printer, ptr<StructItemTree> tree, const char *name);
    void print_array_fromlua(CppPrinter &printer, ptr<StructItemTree> tree, const char *name);

    void print_var_serial(CppPrinter &printer, ptr<StructItemTree> tree, const char *prefix, bool is_pointer);
    void print_var_unserial(CppPrinter &printer, ptr<StructItemTree> tree, const char *prefix, bool is_pointer);
    void print_var_dump(CppPrinter &printer, ptr<StructItemTree> tree, const char *prefix, bool is_pointer);
    void print_var_tolua(CppPrinter &printer, ptr<StructItemTree> tree, const char *prefix, bool is_pointer);
    void print_var_fromlua(CppPrinter &printer, ptr<StructItemTree> tree, const char *prefix, bool is_pointer);

    void print_union_serial(CppPrinter &printer, ptr<UnionTree> tree);
    void print_union_unserial(CppPrinter &printer, ptr<UnionTree> tree);
    void print_union_dump(CppPrinter &printer, ptr<UnionTree> tree);
    void print_union_tolua(CppPrinter &printer, ptr<UnionTree> tree);
    void print_union_fromlua(CppPrinter &printer, ptr<UnionTree> tree);

    void print_union_ptr_serial(CppPrinter &printer, ptr<UnionPtrTree> tree);
    void print_union_ptr_unserial(CppPrinter &printer, ptr<UnionPtrTree> tree);
    void print_union_ptr_dump(CppPrinter &printer, ptr<UnionPtrTree> tree);
    void print_union_ptr_tolua(CppPrinter &printer, ptr<UnionPtrTree> tree);
    void print_union_ptr_fromlua(CppPrinter &printer, ptr<UnionPtrTree> tree);

    void print_constructor(CppPrinter &printer, ptr<StructTree> tree);
protected:
    const char *_serial_name;
    const char *_unserial_name;
};

#endif


