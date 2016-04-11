#ifndef __PRINTER_H__
#define __PRINTER_H__

#include <cstdio>
#include <cstdlib>
#include <cstdarg>

class Printer {
public:
	Printer();
	~Printer();

	void open(const char *filename);
	void open(FILE *file);
	void vprint(const char *fmt, va_list ap);
	void print(const char *fmt, ...);
	void println(const char *fmt, ...);
public:
	unsigned tabsize;
	unsigned indent;
private:
	FILE *_file;
	bool _newline;
};

#endif

