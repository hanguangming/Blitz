AC_INIT([sgq], [0.1])
AM_INIT_AUTOMAKE([foreign])

AC_CONFIG_HEADERS([config.h])

AC_PROG_CXX
AC_PROG_LEX
AC_PROG_YACC
AC_PROG_LIBTOOL

export CXXFLAGS="$CXXFLAGS -std=c++11 -O2 -Wall -I. -I.. "
export CXXFLAGS="$CXXFLAGS -I`pwd`/deps"
export CXXFLAGS="$CXXFLAGS -I`pwd`/deps/libgx"
export CXXFLAGS="$CXXFLAGS -I/usr/include/luajit-2.0"
export CXXFLAGS="$CXXFLAGS -I`pwd`/include"
export CXXFLAGS="$CXXFLAGS -I`pwd`/src"
export CXXFLAGS="$CXXFLAGS -D__GX_SERVER__"
export LDFLAGS="$LDFLAGS -L`pwd`/deps/libgx -lluajit-5.1 -lrt -lm -ldl -lz -lmysqlclient"
export LDFLAGS="$LDFLAGS -L`pwd`/src/libgame"

AC_CONFIG_SUBDIRS([
	deps/libgx
	deps/sscc
])

AC_CONFIG_FILES([
	Makefile 
	deps/Makefile
	deps/libtardb/Makefile
	src/Makefile
	src/libgame/Makefile
	src/libfight/Makefile
	src/logsvr/Makefile
	src/idsvr/Makefile
	src/dbsvr/Makefile
	src/loginsvr/Makefile
	src/agentsvr/Makefile
	src/mapsvr/Makefile
	src/worldsvr/Makefile
	src/fightsvr/Makefile
	src/gamesvr/Makefile
])


AC_OUTPUT


