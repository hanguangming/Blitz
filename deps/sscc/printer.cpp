#include <cstring>
#include <errno.h>
#include "printer.h"
#include "log.h"

Printer::Printer() 
: tabsize(4), 
  indent(),
  _file(),
  _newline(true)
{ }

Printer::~Printer() {
}

void Printer::open(const char *filename) {
	_file = fopen(filename, "w");
	if (!_file) {
		log_error("open output file '%s' failed, %s", filename, strerror(errno));
	}
}

void Printer::open(FILE *file) {
	_file = file;
}

void Printer::vprint(const char *fmt, va_list ap) {
	if (_newline) {
		_newline = false;
		for (unsigned i = 0; i < indent * tabsize; ++i) {
			fputc(' ', _file);
		}
	}
	vfprintf(_file, fmt, ap);
}

void Printer::print(const char *fmt, ...) {
	va_list ap;
	va_start(ap, fmt);
	vprint(fmt, ap);
}

void Printer::println(const char *fmt, ...) {
	va_list ap;
	va_start(ap, fmt);
	vprint(fmt, ap);
	fputc('\n', _file);
	_newline = true;
}



