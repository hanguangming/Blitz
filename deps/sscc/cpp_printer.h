#ifndef __CPP_PRINTER_H__
#define __CPP_PRINTER_H__

#include <stack>
#include "printer.h"

class CppPrinter : public Printer {
public:
	void p(const char *fmt, ...);
	void s(const char *fmt, ...);
	void d(const char *name, const char *fmt, ...);
	void if_(const char *fmt, ...);
	void else_();
	void else_if_(const char *fmt, ...);
	void for_(const char *fmt, ...);
	void while_(const char *fmt, ...);
	void do_();
	void function_(const char *fmt, ...);
	void struct_(const char *name, const char *inherited);
	void class_(const char *name, const char *inherited);
	void enum_();
	void end();
	void end(const char *fmt, ...);
protected:
	enum {
		BLOCK_IF,
		BLOCK_ELSE,
		BLOCK_FOR,
		BLOCK_WHILE,
		BLOCK_DO,
		BLOCK_FUNC,
		BLOCK_STRUCT,
		BLOCK_UNION,
		BLOCK_CLASS,
		BLOCK_ENUM,
	};
protected:
	std::stack<int> _blocks;
};

#endif

