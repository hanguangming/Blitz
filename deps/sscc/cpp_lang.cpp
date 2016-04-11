#include "cpp_lang.h"

CppLang::CppLang() : Language("cpp") {
}

void CppLang::option(const char *name, ptr<Token> value) {

}

const char *CppLang::type_decl(ptr<TypeTree> tree, bool union_item) {
    switch (tree->type()) {
    case TYPE_INT8:
        return "SSCC_INT8";
    case TYPE_UINT8:
        return "SSCC_UINT8";
    case TYPE_INT16:
        return "SSCC_INT16";
    case TYPE_UINT16:
        return "SSCC_UINT16";
    case TYPE_INT32:
        return "SSCC_INT32";
    case TYPE_UINT32:
        return "SSCC_UINT32";
    case TYPE_INT64:
        return "SSCC_INT64";
    case TYPE_UINT64:
        return "SSCC_UINT64";
    case TYPE_FLOAT:
        return "SSCC_FLOAT";
    case TYPE_DOUBLE:
        return "SSCC_DOUBLE";
    case TYPE_STRING:
        return "SSCC_STRING";
    case TYPE_STRUCT:
        if (union_item) {
            return Pool::instance()->printf("SSCC_POINTER(%s)", tree->decl()->name()->text());
        }
        else {
            return tree->decl()->name()->text();
        }
    default:
        assert(0);
        return nullptr;
    }
}

const char *CppLang::type_decl(ptr<StructItemTree> tree, bool union_item) {
    const char *type;
    if (tree->array()) {
        type = type_decl(tree->type(), false);
        type = Pool::instance()->printf("SSCC_VECTOR(%s)", type);
    }
    else {
        type = type_decl(tree->type(), union_item);
    }
    return type;
}

void CppLang::print_define(CppPrinter &printer, ptr<DefineTree> tree) {
    switch (tree->value()->exprType()) {
    case EXPR_INT:
        printer.d(tree->name()->text(), "0x%llx", tree->value()->vint());
        break;
    case EXPR_STRING:
        printer.d(tree->name()->text(), "\"%s\"", tree->value()->vstr());
        break;
    default:
        assert(0);
        break;
    }
}

void CppLang::print_var(CppPrinter &printer, ptr<StructItemTree> tree, bool union_item) {
    printer.s("%s %s", type_decl(tree, union_item), tree->name()->text());
}

void CppLang::print_union(CppPrinter &printer, ptr<UnionTree> tree) {
    printer.println("struct {");
    ++printer.indent;

    for (auto item : *tree) {
        print_var(printer, item->decl(), true);
    }

    --printer.indent;
    if (tree->name()) {
        printer.println("} %s;", tree->name()->text());
    }
    else {
        printer.println("};");
    }
}

void CppLang::print_union_ptr(CppPrinter &printer, ptr<UnionPtrTree> tree) {
    printer.s("SSCC_POINTER(SSCC_DEFAULT_BASE) %s", tree->name()->text());
}

void CppLang::print_base_var_serial(CppPrinter &printer, ptr<StructItemTree> tree, const char *name) {
    const char *method;
    switch (tree->type()->type()) {
    case TYPE_INT8:
        method = "SSCC_WRITE_INT8";
        break;
    case TYPE_UINT8:
        method = "SSCC_WRITE_UINT8";
        break;
    case TYPE_INT16:
        method = "SSCC_WRITE_INT16";
        break;
    case TYPE_UINT16:
        method = "SSCC_WRITE_UINT16";
        break;
    case TYPE_INT32:
        method = "SSCC_WRITE_INT32";
        break;
    case TYPE_UINT32:
        method = "SSCC_WRITE_UINT32";
        break;
    case TYPE_INT64:
        method = "SSCC_WRITE_INT64";
        break;
    case TYPE_UINT64:
        method = "SSCC_WRITE_UINT64";
        break;
    case TYPE_FLOAT:
        method = "SSCC_WRITE_FLOAT";
        break;
    case TYPE_DOUBLE:
        method = "SSCC_WRITE_DOUBLE";
        break;
    case TYPE_STRING:
        method = "SSCC_WRITE_STRING";
        break;
    default:
        assert(0);
        return;
    }

    printer.s("%s(%s)", method, name);
}

void CppLang::print_base_var_unserial(CppPrinter &printer, ptr<StructItemTree> tree, const char *name) {
    const char *method;
    switch (tree->type()->type()) {
    case TYPE_INT8:
        method = "SSCC_READ_INT8";
        break;
    case TYPE_UINT8:
        method = "SSCC_READ_UINT8";
        break;
    case TYPE_INT16:
        method = "SSCC_READ_INT16";
        break;
    case TYPE_UINT16:
        method = "SSCC_READ_UINT16";
        break;
    case TYPE_INT32:
        method = "SSCC_READ_INT32";
        break;
    case TYPE_UINT32:
        method = "SSCC_READ_UINT32";
        break;
    case TYPE_INT64:
        method = "SSCC_READ_INT64";
        break;
    case TYPE_UINT64:
        method = "SSCC_READ_UINT64";
        break;
    case TYPE_FLOAT:
        method = "SSCC_READ_FLOAT";
        break;
    case TYPE_DOUBLE:
        method = "SSCC_READ_DOUBLE";
        break;
    case TYPE_STRING:
        method = "SSCC_READ_STRING";
        break;
    default:
        assert(0);
        return;
    }

    printer.s("%s(%s)", method, name);
}

void CppLang::print_base_var_dump(CppPrinter &printer, ptr<StructItemTree> tree, const char *name) {
    switch (tree->type()->type()) {
    case TYPE_INT8:
        printer.s("SSCC_PRINT(\"%%d(0x%%x)\", (int)%s, (unsigned)%s)", name, name);
        break;
    case TYPE_UINT8:
        printer.s("SSCC_PRINT(\"%%u(0x%%x)\", (unsigned)%s, (unsigned)%s)", name, name);
        break;
    case TYPE_INT16:
        printer.s("SSCC_PRINT(\"%%d(0x%%x)\", (int)%s, (unsigned)%s)", name, name);
        break;
    case TYPE_UINT16:
        printer.s("SSCC_PRINT(\"%%u(0x%%x)\", (unsigned)%s, (unsigned)%s)", name, name);
        break;
    case TYPE_INT32:
        printer.s("SSCC_PRINT(\"%%d(0x%%x)\", (int)%s, (unsigned)%s)", name, name);
        break;
    case TYPE_UINT32:
        printer.s("SSCC_PRINT(\"%%u(0x%%x)\", (unsigned)%s, (unsigned)%s)", name, name);
        break;
    case TYPE_INT64:
        printer.s("SSCC_PRINT(\"%%" PRId64 "(0x%%" PRIx64 ")\", %s, %s)", name, name);
        break;
    case TYPE_UINT64:
        printer.s("SSCC_PRINT(\"%%" PRIu64 "(0x%%" PRIx64 ")\", %s, %s)", name, name);
        break;
    case TYPE_FLOAT:
        printer.s("SSCC_PRINT(\"%%f\", (double)%s)", name);
        break;
    case TYPE_DOUBLE:
        printer.s("SSCC_PRINT(\"%%f\", %s)", name);
        break;
    case TYPE_STRING:
        printer.s("SSCC_PRINT(\"\\\"%%s\\\"\", SSCC_STRING_CSTR(%s))", name);
        break;
    default:
        assert(0);
        return;
    }
}

void CppLang::print_base_var_tolua(CppPrinter &printer, ptr<StructItemTree> tree, const char *name) {
    switch (tree->type()->type()) {
    case TYPE_INT8:
    case TYPE_UINT8:
    case TYPE_INT16:
    case TYPE_UINT16:
    case TYPE_INT32:
    case TYPE_UINT32:
    case TYPE_INT64:
    case TYPE_UINT64:
        printer.s("lua_pushinteger(sscc_L, (lua_Integer)%s)", name);
        break;
    case TYPE_FLOAT:
    case TYPE_DOUBLE:
        printer.s("lua_pushnumber(sscc_L, (lua_Number)%s)", name);
        break;
    case TYPE_STRING:
        printer.s("lua_pushlstring(sscc_L, SSCC_STRING_CSTR(%s), SSCC_STRING_SIZE(%s))", name);
        break;
    default:
        assert(0);
        return;
    }
}

void CppLang::print_base_var_fromlua(CppPrinter &printer, ptr<StructItemTree> tree, const char *name) {
    switch (tree->type()->type()) {
    case TYPE_INT8:
    case TYPE_UINT8:
    case TYPE_INT16:
    case TYPE_UINT16:
    case TYPE_INT32:
    case TYPE_UINT32:
    case TYPE_INT64:
    case TYPE_UINT64:
        printer.do_(); {
            printer.s("int isnum");
            printer.s("%s = lua_tointegerx(sscc_L, -1, &isnum)", name);
            printer.if_("!isnum"); {
                printer.s("goto sscc_exit");
            }
            printer.end();
        }
        printer.end();
        break;
    case TYPE_FLOAT:
        printer.do_(); {
            printer.s("int isnum");
            printer.s("%s = (SSCC_FLOAT)lua_tonumberx(sscc_L, -1, &isnum)", name);
            printer.if_("!isnum"); {
                printer.s("goto sscc_exit");
            }
            printer.end();
        }
        printer.end();
        break;
    case TYPE_DOUBLE:
        printer.do_(); {
            printer.s("int isnum");
            printer.s("%s = (SSCC_DOUBLE)lua_tonumberx(sscc_L, -1, &isnum)", name);
            printer.if_("!isnum"); {
                printer.s("goto sscc_exit");
            }
            printer.end();
        }
        printer.end();
        break;
    case TYPE_STRING:
        printer.do_(); {
            printer.s("const char *sscc_str = lua_tostring(sscc_L, -1)");
            printer.if_("!sscc_str", name); {
                printer.s("goto sscc_exit");
            }
            printer.end();
            printer.s("%s = sscc_str", name);
        }
        printer.end();
        break;
    default:
        assert(0);
        return;
    }
}

void CppLang::print_struct_serial(CppPrinter &printer, ptr<StructItemTree> tree, const char *name, bool is_pointer) {
    if (is_pointer) {
        printer.if_("!SSCC_POINTER_GET(%s)->SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)", name); {
            printer.s("return false");
        }
        printer.end();
    }
    else {
        printer.if_("!%s.SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)", name); {
            printer.s("return false");
        }
        printer.end();
    }
}

void CppLang::print_struct_unserial(CppPrinter &printer, ptr<StructItemTree> tree, const char *name, bool is_pointer) {
    if (is_pointer) {
        printer.s("SSCC_POINTER_SET(%s, SSCC_CREATE(%s))", name, tree->type()->decl()->name()->text());
        printer.if_("!SSCC_POINTER_GET(%s)->SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)", name); {
            printer.s("return false");
        }
        printer.end();
    }
    else {
        printer.if_("!%s.SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)", name); {
            printer.s("return false");
        }
        printer.end();
    }
}

void CppLang::print_struct_dump(CppPrinter &printer, ptr<StructItemTree> tree, const char *name, bool is_pointer) {
    printer.s("SSCC_PRINT(\"{\\n\")");
    printer.s("++sscc_indent");
    if (is_pointer) {
        printer.s("SSCC_POINTER_GET(%s)->SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM)", name);
    }
    else {
        printer.s("%s.SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM)", name);
    }
    printer.s("--sscc_indent");
    print_indent(printer);
    printer.s("SSCC_PRINT(\"}\")");
}

void CppLang::print_struct_tolua(CppPrinter &printer, ptr<StructItemTree> tree, const char *name, bool is_pointer) {
    printer.s("lua_createtable(sscc_L, 0, %u)", tree->type()->decl()->size());
    if (is_pointer) {
        printer.s("SSCC_POINTER_GET(%s)->SSCC_TOLUA_FUNC(sscc_L, -1)", name);
    }
    else {
        printer.s("%s.SSCC_TOLUA_FUNC(sscc_L, -1)", name);
    }
}

void CppLang::print_struct_fromlua(CppPrinter &printer, ptr<StructItemTree> tree, const char *name, bool is_pointer) {
    if (is_pointer) {
        printer.s("SSCC_POINTER_SET(%s, SSCC_CREATE(%s))", name, tree->type()->decl()->name()->text());
        printer.if_("!SSCC_POINTER_GET(%s)->SSCC_FROMLUA_FUNC(sscc_L, -1 SSCC_FROMLUA_PARAM)", name); {
            printer.s("goto sscc_exit");
        }
        printer.end();
    }
    else {
        printer.if_("!%s.SSCC_FROMLUA_FUNC(sscc_L, -1 SSCC_FROMLUA_PARAM)", name); {
            printer.s("goto sscc_exit");
        }
        printer.end();
    }
}

void CppLang::print_array_serial(CppPrinter &printer, ptr<StructItemTree> tree, const char *name) {
    printer.if_("!SSCC_WRITE_SIZE(SSCC_VECTOR_SIZE(%s))", name); {
        printer.s("return false");
    }
    printer.end();

    printer.for_("auto &sscc_i : %s", name); {
        if (tree->type()->type() == TYPE_STRUCT) {
            print_struct_serial(printer, tree, "sscc_i", false);
        }
        else {
            print_base_var_serial(printer, tree, "sscc_i");
        }
    }
    printer.end();
}

void CppLang::print_array_unserial(CppPrinter &printer, ptr<StructItemTree> tree, const char *name) {
    printer.do_(); {
        printer.s("size_t sscc_size");
        printer.s("SSCC_READ_SIZE(sscc_size)");

        printer.for_("size_t sscc_i = 0 ; sscc_i < sscc_size; ++sscc_i"); {
            printer.s("SSCC_VECTOR_EMPLACE_BACK(%s)", name);
            if (tree->type()->type() == TYPE_STRUCT) {
                print_struct_unserial(printer, tree, Pool::instance()->printf("SSCC_VECTOR_BACK(%s)", name), false);
            }
            else {
                print_base_var_unserial(printer, tree, Pool::instance()->printf("SSCC_VECTOR_BACK(%s)", name));
            }
        }
        printer.end();
    }
    printer.end();
}

void CppLang::print_array_dump(CppPrinter &printer, ptr<StructItemTree> tree, const char *name) {
    printer.s("SSCC_PRINT(\"{\\n\")");
    printer.s("++sscc_indent");

    printer.do_(); {
        printer.s("size_t sscc_i = 0");
        printer.for_("auto &sscc_obj : %s", name); {
            print_indent(printer);
            printer.s("SSCC_PRINT(\"[%%lu] = \", sscc_i++)");
            name = "sscc_obj";
            if (tree->type()->type() == TYPE_STRUCT) {
                print_struct_dump(printer, tree, name, false);
            }
            else {
                print_base_var_dump(printer, tree, name);
            }
            printer.s("SSCC_PRINT(\",\\n\")");
        }
        printer.end();
    }
    printer.end();
    printer.s("--sscc_indent");
    print_indent(printer);
    printer.s("SSCC_PRINT(\"}\")", name);
}

void CppLang::print_array_tolua(CppPrinter &printer, ptr<StructItemTree> tree, const char *name) {
    printer.s("lua_createtable(sscc_L, SSCC_VECTOR_SIZE(%s), 0)", name);

    printer.do_(); {
        printer.s("lua_Integer sscc_i = 0");
        printer.for_("auto &sscc_obj : %s", name); {
            printer.s("lua_pushinteger(sscc_L, ++sscc_i)");
            printer.s("SSCC_VECTOR_BACK(%s)", name);
            if (tree->type()->type() == TYPE_STRUCT) {
                print_struct_tolua(printer, tree, "sscc_obj", false);
            }
            else {
                print_base_var_tolua(printer, tree, "sscc_obj");
            }
            printer.s("lua_settable(sscc_L, -3)");
        }
        printer.end();
    }
    printer.end();
}
void CppLang::print_array_fromlua(CppPrinter &printer, ptr<StructItemTree> tree, const char *name) {
    printer.for_("size_t sscc_i = 1; ; ++sscc_i"); {
        printer.s("lua_pushinteger(sscc_L, sscc_i)");
        printer.s("lua_gettable(sscc_L, -2)");
        printer.if_("lua_isnil(sscc_L, -1)"); {
            printer.s("lua_pop(sscc_L, 1)");
            printer.s("break");
        }
        printer.end();

        printer.s("SSCC_VECTOR_EMPLACE_BACK(%s)", name);
        if (tree->type()->type() == TYPE_STRUCT) {
            print_struct_fromlua(printer, tree, Pool::instance()->printf("SSCC_VECTOR_BACK(%s)", name), false);
        }
        else {
            print_base_var_fromlua(printer, tree, Pool::instance()->printf("SSCC_VECTOR_BACK(%s)", name));
        }
        printer.s("lua_pop(sscc_L, 1)");
    }
    printer.end();
}

void CppLang::print_var_serial(CppPrinter &printer, ptr<StructItemTree> tree, const char *prefix, bool is_pointer) {
    const char *name;
    if (prefix) {
        name = Pool::instance()->printf("this->%s.%s", prefix, tree->name()->text());
    }
    else {
        name = Pool::instance()->printf("this->%s", tree->name()->text());
    }
    if (tree->array()) {
        print_array_serial(printer, tree, name);
        return;
    }
    if (tree->type()->type() == TYPE_STRUCT) {
        print_struct_serial(printer, tree, name, is_pointer);
        return;
    }
    print_base_var_serial(printer, tree, name);
}

void CppLang::print_var_unserial(CppPrinter &printer, ptr<StructItemTree> tree, const char *prefix, bool is_pointer) {
    const char *name;
    if (prefix) {
        name = Pool::instance()->printf("%s.%s", prefix, tree->name()->text());
    }
    else {
        name = Pool::instance()->printf("this->%s", tree->name()->text());
    }
    if (tree->array()) {
        print_array_unserial(printer, tree, name);
        return;
    }
    if (tree->type()->type() == TYPE_STRUCT) {
        print_struct_unserial(printer, tree, name, is_pointer);
        return;
    }
    print_base_var_unserial(printer, tree, name);
}

void CppLang::print_var_dump(CppPrinter &printer, ptr<StructItemTree> tree, const char *prefix, bool is_pointer) {
    const char *name = tree->name()->text();
    print_indent(printer);
    printer.s("SSCC_PRINT(\"%s = \")", name);
    if (prefix) {
        name = Pool::instance()->printf("this->%s.%s", prefix, name);
    }
    else {
        name = Pool::instance()->printf("this->%s", name);
    }
    if (tree->array()) {
        print_array_dump(printer, tree, name);
    }
    else if (tree->type()->type() == TYPE_STRUCT) {
        print_struct_dump(printer, tree, name, is_pointer);
    }
    else {
        print_base_var_dump(printer, tree, name);
    }
}

void CppLang::print_var_tolua(CppPrinter &printer, ptr<StructItemTree> tree, const char *prefix, bool is_pointer) {
    const char *name;
    if (prefix) {
        name = Pool::instance()->printf("this->%s.%s", prefix, tree->name()->text());
    }
    else {
        name = Pool::instance()->printf("this->%s", tree->name()->text());
    }

    printer.s("lua_pushlstring(sscc_L, \"%s\", %u)", tree->name()->text(), strlen(tree->name()->text()));
    if (tree->array()) {
        print_array_tolua(printer, tree, name);
    }
    else if (tree->type()->type() == TYPE_STRUCT) {
        print_struct_tolua(printer, tree, name, is_pointer);
    }
    else {
        print_base_var_tolua(printer, tree, name);
    }
    printer.s("lua_settable(sscc_L, sscc_index)");
}

void CppLang::print_var_fromlua(CppPrinter &printer, ptr<StructItemTree> tree, const char *prefix, bool is_pointer) {
    const char *name;
    if (prefix) {
        name = Pool::instance()->printf("this->%s.%s", prefix, tree->name()->text());
    }
    else {
        name = Pool::instance()->printf("this->%s", tree->name()->text());
    }

    printer.s("lua_pushlstring(sscc_L, \"%s\", %u)", tree->name()->text(), strlen(tree->name()->text()));
    printer.s("lua_gettable(sscc_L, sscc_index)");
    printer.if_("!lua_isnil(sscc_L, -1)"); {
        if (tree->array()) {
            print_array_fromlua(printer, tree, name);
        }
        else if (tree->type()->type() == TYPE_STRUCT) {
            print_struct_fromlua(printer, tree, name, is_pointer);
        }
        else {
            print_base_var_fromlua(printer, tree, name);
        }
    }
    printer.end();
    printer.s("lua_pop(sscc_L, 1)");
}

void CppLang::print_union_serial(CppPrinter &printer, ptr<UnionTree> tree) {
    if (!tree->size()) {
        return;
    }
    const char *union_name = tree->name() ? tree->name()->text() : nullptr;

    unsigned old_indent = printer.indent;
    printer.println("switch (this->%s) {", tree->key()->name()->text()); {
        for (auto sym : *tree) {
            printer.indent = old_indent;
            printer.println("case %s:", sym->index()->name()->text());
            ++printer.indent;
            print_var_serial(printer, sym->decl(), union_name, true);
            printer.s("break");
        }
    }
    printer.indent = old_indent;
    printer.println("default:");
    ++printer.indent;
    printer.s("return false");

    printer.indent = old_indent;
    printer.println("}");
}

void CppLang::print_union_unserial(CppPrinter &printer, ptr<UnionTree> tree) {
    if (!tree->size()) {
        return;
    }
    const char *union_name = tree->name() ? tree->name()->text() : nullptr;

    unsigned old_indent = printer.indent;
    printer.println("switch (this->%s) {", tree->key()->name()->text()); {
        for (auto sym : *tree) {
            printer.indent = old_indent;
            printer.println("case %s:", sym->index()->name()->text());
            ++printer.indent;
            print_var_unserial(printer, sym->decl(), union_name, true);
            printer.s("break");
        }
    }
    printer.indent = old_indent;
    printer.println("default:");
    ++printer.indent;
    printer.s("return false");

    printer.indent = old_indent;
    printer.println("}");
}

void CppLang::print_union_dump(CppPrinter &printer, ptr<UnionTree> tree) {
    if (!tree->size()) {
        return;
    }

    const char *union_name;
    print_indent(printer);
    if (tree->name()) {
        printer.s("SSCC_PRINT(\"union %s<\")", tree->name()->text());
        union_name = tree->name()->text();
    }
    else {
        printer.s("SSCC_PRINT(\"union<\")");
        union_name = nullptr;
    }

    printer.s("++sscc_indent");

    const char *key_name = Pool::instance()->printf("this->%s", tree->key()->name()->text());
    unsigned old_indent = printer.indent;
    printer.println("switch (%s) {", key_name); {
        for (auto sym : *tree) {
            printer.indent = old_indent;
            printer.println("case %s:", sym->index()->name()->text());
            ++printer.indent;

            printer.s("SSCC_PRINT(\"%s> = {\\n\")", sym->index()->name()->text());
            print_var_dump(printer, sym->decl(), union_name, true);
            printer.s("SSCC_PRINT(\",\\n\")");
            printer.s("break");
        }
    }
    printer.indent = old_indent;
    printer.println("default:");
    ++printer.indent;
    printer.s("SSCC_PRINT(\"unknown: \")");
    print_base_var_dump(printer, tree->key(), key_name);
    printer.s("SSCC_PRINT(\"> = {\\n\")");

    printer.indent = old_indent;
    printer.println("}");

    printer.s("--sscc_indent");
    print_indent(printer);
    printer.s("SSCC_PRINT(\"}\")");
}

void CppLang::print_union_tolua(CppPrinter &printer, ptr<UnionTree> tree) {
    if (!tree->size()) {
        return;
    }
    const char *union_name = tree->name() ? tree->name()->text() : nullptr;

    if (union_name) {
        printer.do_();
        printer.s("int sscc_old_index = sscc_index");
        printer.s("sscc_index = -3");
        printer.s("lua_pushlstring(sscc_L, \"%s\", %u)", union_name, strlen(union_name));
        printer.s("lua_createtable(sscc_L, 0, 1)");
    }
    unsigned old_indent = printer.indent;
    printer.println("switch (this->%s) {", tree->key()->name()->text()); {
        for (auto sym : *tree) {
            printer.indent = old_indent;
            printer.println("case %s:", sym->index()->name()->text());
            ++printer.indent;
            print_var_tolua(printer, sym->decl(), union_name, true);
            printer.s("break");
        }
    }
    printer.indent = old_indent;
    printer.println("default:");
    ++printer.indent;
    printer.s("break");

    printer.indent = old_indent;
    printer.println("}");

    if (union_name) {
        printer.s("sscc_index = sscc_old_index");
        printer.s("lua_settable(sscc_L, sscc_index)");
        printer.end();
    }
}

void CppLang::print_union_fromlua(CppPrinter &printer, ptr<UnionTree> tree) {
    if (!tree->size()) {
        return;
    }
    const char *union_name = tree->name() ? tree->name()->text() : nullptr;

    if (union_name) {
        printer.do_();
        printer.s("int sscc_old_index = sscc_index");
        printer.s("sscc_index = -2");
        printer.s("lua_pushlstring(sscc_L, \"%s\", %u)", union_name, strlen(union_name));
        printer.s("lua_gettable(sscc_L, sscc_index)");
    }

    unsigned old_indent = printer.indent;
    printer.println("switch (this->%s) {", tree->key()->name()->text()); {
        for (auto sym : *tree) {
            printer.indent = old_indent;
            printer.println("case %s:", sym->index()->name()->text());
            ++printer.indent;
            print_var_fromlua(printer, sym->decl(), union_name, true);
            printer.s("break");
        }
    }
    printer.indent = old_indent;
    printer.println("default:");
    ++printer.indent;
    printer.s("goto sscc_exit");

    printer.indent = old_indent;
    printer.println("}");

    if (union_name) {
        printer.s("sscc_index = sscc_old_index");
        printer.s("lua_pop(sscc_L, 1)");
        printer.end();
    }
}

void CppLang::print_union_ptr_serial(CppPrinter &printer, ptr<UnionPtrTree> tree) {
    if (!tree->size()) {
        return;
    }

    const char *union_name = tree->name()->text();
    printer.s("SSCC_ASSERT(SSCC_POINTER_GET(this->%s))", union_name);
    unsigned old_indent = printer.indent;
    printer.println("switch (this->%s) {", tree->key()->name()->text()); {
        for (auto sym : *tree) {
            printer.indent = old_indent;
            printer.println("case %s:", sym->index()->name()->text());
            ++printer.indent;
            printer.if_("!static_cast<%s*>(SSCC_POINTER_GET(this->%s))->SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)", sym->decl()->name()->text(), union_name); {
                printer.s("return false");
            }
            printer.end();
            printer.s("break");
        }
    }
    printer.indent = old_indent;
    printer.println("default:");
    ++printer.indent;
    printer.s("return false");

    printer.indent = old_indent;
    printer.println("}");
}

void CppLang::print_union_ptr_unserial(CppPrinter &printer, ptr<UnionPtrTree> tree) {
    if (!tree->size()) {
        return;
    }

    const char *union_name = tree->name()->text();
    unsigned old_indent = printer.indent;
    printer.println("switch (this->%s) {", tree->key()->name()->text()); {
        for (auto sym : *tree) {
            printer.indent = old_indent;
            printer.println("case %s:", sym->index()->name()->text());
            ++printer.indent;
            printer.s("SSCC_POINTER_SET(this->%s, SSCC_CREATE(%s))", tree->name()->text(), sym->decl()->name()->text());
            printer.s("break");
        }
    }
    printer.indent = old_indent;
    printer.println("default:");
    ++printer.indent;
    printer.s("return false");

    printer.indent = old_indent;
    printer.println("}");

    printer.if_("!SSCC_POINTER_GET(this->%s)->SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)", union_name); {
        printer.s("return false");
    }
    printer.end();
}

void CppLang::print_union_ptr_dump(CppPrinter &printer, ptr<UnionPtrTree> tree) {
    if (!tree->size()) {
        return;
    }

    print_indent(printer);
    printer.s("SSCC_PRINT(\"union_ptr %s<\")", tree->name()->text());
    printer.s("++sscc_indent");

    const char *key_name = Pool::instance()->printf("this->%s", tree->key()->name()->text());

    unsigned old_indent = printer.indent;
    printer.println("switch (%s) {", key_name); {
        for (auto sym : *tree) {
            printer.indent = old_indent;
            printer.println("case %s:", sym->index()->name()->text());
            ++printer.indent;

            printer.s("SSCC_PRINT(\"%s: %s> = {\\n\")", sym->index()->name()->text(), sym->decl()->name()->text());
            printer.s("SSCC_POINTER_GET(this->%s)->SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM)", tree->name()->text());
            printer.s("break");
        }
    }
    printer.indent = old_indent;
    printer.println("default:");
    ++printer.indent;
    printer.s("SSCC_PRINT(\"unknown: \")");
    print_base_var_dump(printer, tree->key(), key_name);
    printer.s("SSCC_PRINT(\"> = {\\n\")");

    printer.indent = old_indent;
    printer.println("}");

    printer.s("--sscc_indent");
    print_indent(printer);
    printer.s("SSCC_PRINT(\"}\")");
}

void CppLang::print_union_ptr_tolua(CppPrinter &printer, ptr<UnionPtrTree> tree) {
    if (!tree->size()) {
        return;
    }

    const char *union_name = tree->name()->text();
    printer.if_("SSCC_POINTER_GET(this->%s)", union_name); {
        printer.s("lua_pushlstring(sscc_L, \"%s\", %u)", union_name, strlen(union_name));
        printer.s("lua_createtable(sscc_L, 0, 1)");

        unsigned old_indent = printer.indent;
        printer.println("switch (this->%s) {", tree->key()->name()->text()); {
            for (auto sym : *tree) {
                printer.indent = old_indent;
                printer.println("case %s:", sym->index()->name()->text());
                ++printer.indent;
                printer.s("static_cast<%s*>(SSCC_POINTER_GET(this->%s))->SSCC_TOLUA_FUNC(sscc_L, -1)", sym->decl()->name()->text(), union_name);
                printer.s("break");
            }
        }
        printer.indent = old_indent;
        printer.println("default:");
        ++printer.indent;
        printer.s("break");

        printer.indent = old_indent;
        printer.println("}");
        printer.s("lua_settable(sscc_L, sscc_index)");
    }
    printer.end();
};

void CppLang::print_union_ptr_fromlua(CppPrinter &printer, ptr<UnionPtrTree> tree) {
    if (!tree->size()) {
        return;
    }

    const char *union_name = tree->name()->text();

    printer.s("lua_pushlstring(sscc_L, \"%s\", %u)", union_name, strlen(union_name));
    printer.s("lua_gettable(sscc_L, sscc_index)");

    unsigned old_indent = printer.indent;
    printer.println("switch (this->%s) {", tree->key()->name()->text()); {
        for (auto sym : *tree) {
            printer.indent = old_indent;
            printer.println("case %s:", sym->index()->name()->text());
            ++printer.indent;
            printer.s("SSCC_POINTER_SET(this->%s, SSCC_CREATE(%s))", tree->name()->text(), sym->decl()->name()->text());
            printer.s("break");
        }
    }
    printer.indent = old_indent;
    printer.println("default:");
    ++printer.indent;
    printer.s("goto sscc_exit");

    printer.indent = old_indent;
    printer.println("}");

    printer.if_("!SSCC_POINTER_GET(this->%s)->SSCC_FROMLUA_FUNC(sscc_L, sscc_index SSCC_FROMLUA_PARAM)", union_name); {
        printer.s("goto sscc_exit");
    }
    printer.end();
    printer.s("lua_pop(sscc_L, 1)");
}

void CppLang::print_serial(CppPrinter &printer, ptr<StructTree> tree) {
    printer.function_("bool SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM_DECL) const override"); {
        if (tree->inherited()) {
            printer.if_("!%s::SSCC_SERIAL_FUNC(SSCC_SERIAL_PARAM)", tree->inherited()->name()->text()); {
                printer.s("return false");
            }
            printer.end();
        }
        for (auto sym : *tree) {
            switch (sym->type()) {
            case TREE_STRUCT_ITEM:
                print_var_serial(printer, sym.cast<StructItemTree>(), nullptr, false);
                break;
            case TREE_UNION:
                print_union_serial(printer, sym.cast<UnionTree>());
                break;
            case TREE_UNION_PTR:
                print_union_ptr_serial(printer, sym.cast<UnionPtrTree>());
                break;
            default:
                assert(0);
                break;
            }
        }
        printer.s("return true");
    }
    printer.end();
};

void CppLang::print_unserial(CppPrinter &printer, ptr<StructTree> tree) {
    printer.function_("bool SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM_DECL) override"); {
        if (tree->inherited()) {
            printer.if_("!%s::SSCC_UNSERIAL_FUNC(SSCC_UNSERIAL_PARAM)", tree->inherited()->name()->text()); {
                printer.s("return false");
            }
            printer.end();
        }
        for (auto sym : *tree) {
            switch (sym->type()) {
            case TREE_STRUCT_ITEM:
                print_var_unserial(printer, sym.cast<StructItemTree>(), nullptr, false);
                break;
            case TREE_UNION:
                print_union_unserial(printer, sym.cast<UnionTree>());
                break;
            case TREE_UNION_PTR:
                print_union_ptr_unserial(printer, sym.cast<UnionPtrTree>());
                break;
            default:
                assert(0);
                break;
            }
        }
        printer.s("return true");
    }
    printer.end();
};

void CppLang::print_constructor(CppPrinter &printer, ptr<StructTree> tree) {
    bool first = true;
    printer.println("%s(SSCC_ALLOCATOR_PARAM_DECL)", tree->name()->text());
    if (tree->inherited()) {
        printer.print(": %s(SSCC_ALLOCATOR_PARAM)", tree->inherited()->name()->text());
        first = false;
    }

    ptr<StructItemTree> item;
    for (auto sym : *tree) {
        switch (sym->type()) {
        case TREE_STRUCT_ITEM:
            item = sym.cast<StructItemTree>();
            if (first) {
                first = false;
            }
            else {
                printer.println(",");
            }

            if (item->array()) {
                printer.print("  %s(%s::allocator_type(SSCC_ALLOCATOR_PARAM))", item->name()->text(), type_decl(item, false));
                break;
            }
            if (item->type()->type() == TYPE_STRUCT) {
                printer.print("  %s(SSCC_ALLOCATOR_PARAM)", item->name()->text());
                break;
            }
            if (item->type()->type() == TYPE_STRING) {
                printer.print("  %s(%s::allocator_type(SSCC_ALLOCATOR_PARAM))", item->name()->text(), type_decl(item, false));
                break;
            }
            printer.print("  %s()", item->name()->text());
            break;
        default:
            break;
        }
    }

    printer.println("");
    printer.println("{ }");
};

void CppLang::print_indent(CppPrinter &printer) {
    printer.s("SSCC_PRINT_INDENT(sscc_indent)");
}

void CppLang::print_dump(CppPrinter &printer, ptr<StructTree> tree) {
    printer.p("#ifdef SSCC_USE_DUMP");
    printer.function_("void SSCC_DUMP_FUNC(unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override"); {
        if (tree->inherited()) {
            printer.s("%s::SSCC_DUMP_FUNC(sscc_indent SSCC_DUMP_PARAM)", tree->inherited()->name()->text());
        }

        for (auto sym : *tree) {
            switch (sym->type()) {
            case TREE_STRUCT_ITEM:
                print_var_dump(printer, sym.cast<StructItemTree>(), nullptr, false);
                break;
            case TREE_UNION:
                print_union_dump(printer, sym.cast<UnionTree>());
                break;
            case TREE_UNION_PTR:
                print_union_ptr_dump(printer, sym.cast<UnionPtrTree>());
                break;
            default:
                assert(0);
                break;
            }
            printer.s("SSCC_PRINT(\",\\n\")");
        }
    }
    printer.end();

    printer.function_("void SSCC_DUMP_FUNC(const char *sscc_name, unsigned sscc_indent SSCC_DUMP_PARAM_DECL) override"); {
        printer.if_("!sscc_name"); {
            printer.s("sscc_name = the_class_name");
        }
        printer.end();
        print_indent(printer);
        printer.s("SSCC_PRINT(\"%%s = {\\n\", sscc_name)");
        printer.s("SSCC_DUMP_FUNC(sscc_indent + 1 SSCC_DUMP_PARAM)");
        print_indent(printer);
        printer.s("SSCC_PRINT(\"}\\n\")");
    }
    printer.end();
    printer.p("#endif");
}

void CppLang::print_tolua(CppPrinter &printer, ptr<StructTree> tree) {
    printer.function_("void SSCC_TOLUA_FUNC(lua_State *sscc_L, int sscc_index) override"); {
        printer.s("int sscc_top = lua_gettop(sscc_L)");
        printer.if_("sscc_index < 0"); {
            printer.s("sscc_index = sscc_top + sscc_index + 1");
        }
        printer.end();

        if (tree->inherited()) {
            printer.s("%s::SSCC_TOLUA_FUNC(sscc_L, sscc_index)", tree->inherited()->name()->text());
        }

        for (auto sym : *tree) {
            switch (sym->type()) {
            case TREE_STRUCT_ITEM:
                print_var_tolua(printer, sym.cast<StructItemTree>(), nullptr, false);
                break;
            case TREE_UNION:
                print_union_tolua(printer, sym.cast<UnionTree>());
                break;
            case TREE_UNION_PTR:
                print_union_ptr_tolua(printer, sym.cast<UnionPtrTree>());
                break;
            default:
                assert(0);
                break;
            }
        }
        printer.s("SSCC_ASSERT(sscc_top == lua_gettop(sscc_L))");
    }
    printer.end();
}

void CppLang::print_fromlua(CppPrinter &printer, ptr<StructTree> tree) {
    printer.function_("bool SSCC_FROMLUA_FUNC(lua_State *sscc_L, int sscc_index SSCC_FROMLUA_PARAM_DECL) override"); {
        printer.if_("!lua_istable(sscc_L, sscc_index)"); {
            printer.s("return false");
        }
        printer.end();

        printer.s("int sscc_top = lua_gettop(sscc_L)");
        printer.if_("sscc_index < 0"); {
            printer.s("sscc_index = sscc_top + sscc_index + 1");
        }
        printer.end();

        if (tree->inherited()) {
            printer.if_("!%s::SSCC_FROMLUA_FUNC(sscc_L, sscc_index SSCC_FROMLUA_PARAM)", tree->inherited()->name()->text()); {
                printer.s("goto sscc_exit");
            }
            printer.end();
        }
        for (auto sym : *tree) {
            switch (sym->type()) {
            case TREE_STRUCT_ITEM:
                print_var_fromlua(printer, sym.cast<StructItemTree>(), nullptr, false);
                break;
            case TREE_UNION:
                print_union_fromlua(printer, sym.cast<UnionTree>());
                break;
            case TREE_UNION_PTR:
                print_union_ptr_fromlua(printer, sym.cast<UnionPtrTree>());
                break;
            default:
                assert(0);
                break;
            }
        }
        printer.s("SSCC_ASSERT(sscc_top == lua_gettop(sscc_L))");
        printer.s("return true");
        printer.p("sscc_exit:");
        printer.s("sscc_index = lua_gettop(sscc_L)");
        printer.s("SSCC_ASSERT(sscc_index >= sscc_top)");
        printer.s("sscc_index -= sscc_top");
        printer.if_("sscc_index > 0"); {
            printer.s("lua_pop(sscc_L, sscc_index)");
        }
        printer.end();
        printer.s("return false");
    }
    printer.end();
}

void CppLang::print_struct(CppPrinter &printer, ptr<StructTree> tree) {
    const char *inherited = tree->inherited() ? tree->inherited()->name()->text() : nullptr;
    printer.struct_(tree->name()->text(), inherited); {
        printer.s("static constexpr const char *the_class_name = \"%s\"", tree->name()->text());
        if (tree->message) {
            printer.s("static constexpr int the_message_id = %s", tree->message->id()->name()->text());
            printer.s("static constexpr const char *the_message_name = \"%s\"", tree->message->id()->name()->text());
            printer.s("typedef %s the_message_type", tree->message->name()->text());
        }
        for (auto sym : *tree) {
            switch (sym->type()) {
            case TREE_STRUCT_ITEM:
                print_var(printer, sym.cast<StructItemTree>(), false);
                break;
            case TREE_UNION:
                print_union(printer, sym.cast<UnionTree>());
                break;
            case TREE_UNION_PTR:
                print_union_ptr(printer, sym.cast<UnionPtrTree>());
                break;
            default:
                assert(0);
                break;
            }
        }

        printer.println("");
        print_constructor(printer, tree);
        printer.println("");
        print_serial(printer, tree);
        printer.println("");
        print_unserial(printer, tree);
        printer.println("");
        print_dump(printer, tree);
        printer.println("");
        printer.p("#ifdef SSCC_USE_LUA");
        print_tolua(printer, tree);
        printer.println("");
        print_fromlua(printer, tree);
        printer.p("#endif");
    }
    printer.end();
}

void CppLang::print_message(CppPrinter &printer, ptr<MessageTree> tree) {
    printer.s("struct %s", tree->name()->text());

    print_struct(printer, tree->req());
    if (tree->rsp()) {
        print_struct(printer, tree->rsp());
    }

    printer.struct_(tree->name()->text(), nullptr); {
        printer.s("static constexpr const char *the_class_name = \"%s\"", tree->name()->text());
        printer.s("static constexpr int the_message_id = %s", tree->id()->name()->text());
        printer.s("static constexpr const char *the_message_name = \"%s\"", tree->id()->name()->text());

        if (tree->req()) {
            printer.s("typedef %s request_type", tree->req()->name()->text());
        }
        if (tree->rsp()) {
            printer.s("typedef %s response_type", tree->rsp()->name()->text());
        }
        else {
            printer.s("typedef void response_type");
        }

        printer.println("");
        printer.s("SSCC_POINTER(request_type) req");
        if (tree->rsp()) {
            printer.s("SSCC_POINTER(response_type) rsp");
        }

        printer.println("");
        if (tree->rsp()) {
            printer.println("%s(SSCC_MESSAGE_PARAM_DECL) : req(SSCC_CREATE(request_type)), rsp() { }", tree->name()->text());
        }
        else {
            printer.println("%s(SSCC_MESSAGE_PARAM_DECL) : req(SSCC_CREATE(request_type)) { }", tree->name()->text());
        }
    }
    printer.end();
}

void CppLang::print_message_opt(CppPrinter &printer, ptr<MessageTree> tree) {
    printer.s("SSCC_MESSAGE_OPT(%s)", tree->name()->text());
}

void CppLang::print_include(CppPrinter &printer, ptr<IncludeTree> tree) {
    printer.p("#include \"%s.h\"", (tree->path()->directory() + tree->path()->basename()).c_str());
}

void CppLang::print(SymbolTable &symbols, FILE *file) {
    CppPrinter printer;
    printer.open(file);

    printer.println("#pragma once");
    printer.p(head().str().c_str());
    for (auto sym : symbols) {
        switch (sym->type()) {
        case TREE_DEFINE:
            print_define(printer, sym.cast<DefineTree>());
            break;
        case TREE_STRUCT:
            print_struct(printer, sym.cast<StructTree>());
            break;
        case TREE_MESSAGE:
            print_message(printer, sym.cast<MessageTree>());
            break;
        case TREE_INCLUDE:
            print_include(printer, sym.cast<IncludeTree>());
            break;
        default:
            assert(0);
            break;
        }
    }
    printer.p(tail().str().c_str());
}




