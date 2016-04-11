#ifndef __GX_GETOPT_H__
#define __GX_GETOPT_H__

#include "platform.h"

#ifdef GX_PLATFORM_WIN32
GX_NS_BEGIN
int getopt(int argc, char * const argv[], const char *optstring);
extern char *optarg;
extern int optind, opterr, optopt;
GX_NS_END
#else
#include <getopt.h>
#endif

#endif
