#include <cassert>
#include "cpp_printer.h"

void CppPrinter::s(const char *fmt, ...) {
	va_list ap;
	va_start(ap, fmt);
	vprint(fmt, ap);
	println(";");
}

void CppPrinter::p(const char *fmt, ...) {
	va_list ap;
	va_start(ap, fmt);
	unsigned old = indent;
	indent = 0;
	vprint(fmt, ap);
	println("");
	indent = old;
}

void CppPrinter::d(const char *name, const char *fmt, ...) {
	va_list ap;
	va_start(ap, fmt);

	unsigned old = indent;
	indent = 0;
	print("#define %s ", name);
	vprint(fmt, ap);
	println("");
	indent = old;
}

void CppPrinter::if_(const char *fmt, ...) {
	va_list ap;
	va_start(ap, fmt);

	print("if (");
	vprint(fmt, ap);
	println(") {");

	_blocks.push(BLOCK_IF);
	++indent;
}

void CppPrinter::else_() {
	assert(_blocks.top() == BLOCK_IF);
	end();
	println("else {");
	_blocks.push(BLOCK_ELSE);
	++indent;
}

void CppPrinter::else_if_(const char *fmt, ...) {
	va_list ap;
	va_start(ap, fmt);

	assert(_blocks.top() == BLOCK_IF);
	end();
	print("else if (");
	vprint(fmt, ap);
	println(") {");
	_blocks.push(BLOCK_IF);
	++indent;
}

void CppPrinter::for_(const char *fmt, ...) {
	va_list ap;
	va_start(ap, fmt);

	print("for (");
	vprint(fmt, ap);
	println(") {");
	_blocks.push(BLOCK_FOR);
	++indent;
}

void CppPrinter::while_(const char *fmt, ...) {
	va_list ap;
	va_start(ap, fmt);
	print("while (");
	vprint(fmt, ap);
	println(") {");
	_blocks.push(BLOCK_WHILE);
	++indent;
}

void CppPrinter::do_() {
	println("do {");
	_blocks.push(BLOCK_DO);
	++indent;
}

void CppPrinter::function_(const char *fmt, ...) {
	va_list ap;
	va_start(ap, fmt);

	vprint(fmt, ap);
	println(" {");
	_blocks.push(BLOCK_FUNC);
	++indent;
}

void CppPrinter::struct_(const char *name, const char *inherited) {
	if (inherited) {
		println("struct %s : %s {", name, inherited);
	}
	else {
		println("struct %s {", name);
	}
	_blocks.push(BLOCK_STRUCT);
	++indent;
}

void CppPrinter::class_(const char *name, const char *inherited) {
	if (inherited) {
		println("class %s : %s {", name, inherited);
	}
	else {
		println("class %s {", name);
	}
	_blocks.push(BLOCK_CLASS);
	++indent;
}

void CppPrinter::enum_() {
	println("enum {");
	_blocks.push(BLOCK_ENUM);
	++indent;
}

void CppPrinter::end() {
	assert(_blocks.size() > 0);
	--indent;
	switch (_blocks.top()) {
	case BLOCK_IF:
	case BLOCK_ELSE:
	case BLOCK_FOR:
	case BLOCK_WHILE:
	case BLOCK_FUNC:
		println("}");
		break;
	case BLOCK_STRUCT:
	case BLOCK_UNION:
	case BLOCK_CLASS:
	case BLOCK_ENUM:
		println("};");
		break;
	case BLOCK_DO:
		println("} while (0);");
		break;
	default:
		assert(0);
	}
	_blocks.pop();
}

void CppPrinter::end(const char *fmt, ...) {
	va_list ap;
	va_start(ap, fmt);

	assert(_blocks.size() > 0);
	assert(_blocks.top() == BLOCK_DO);

	--indent;
	print("} while (");
	vprint(fmt, ap);
	println(");");
	_blocks.pop();
}

