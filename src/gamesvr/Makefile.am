bin_PROGRAMS = gamesvr
BUILT_SOURCES = token.h

token.h: token.gperf
	gperf -t  -L C++ token.gperf > token.h

gamesvr_SOURCES =           \
    gamesvr.cpp             \
    gs_command.cpp


AM_LDFLAGS = -lgxs -lgame

