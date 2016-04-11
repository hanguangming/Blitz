lib_LTLIBRARIES = libgxs.la

GX_SOURCES =      	    \
    object.cpp          \
    singleton.cpp       \
    bitorder.cpp        \
    page.cpp            \
    printf.cpp          \
    path.cpp            \
    stream.cpp          \
    log.cpp             \
    obstack.cpp         \
    pool.cpp            \
    allocator.cpp       \
    getopt.cpp          \
    fileloader.cpp      \
    csvloader.cpp       \
    charset.cpp         \
    rbtree.cpp          \
    timeval.cpp         \
    timermanager.cpp    \
    script.cpp          \
    utils.cpp           \
    servlet.cpp         \
    network.cpp         \
    socket.cpp          \
    reactor.cpp         \
    peer.cpp            \
    protocol.cpp        \
    coroutine.cpp       \
    context.cpp         \
    filesystem.cpp      \
    filemonitor.cpp     \
    application.cpp     \
    mysql.cpp           \
    prob.cpp            \
    cron.cpp

libgxs_la_SOURCES = $(GX_SOURCES)
libgxs_la_CXXFLAGS = -std=c++11 -O2 -Wall -D__GX_SERVER__ -Wl,-E 
libgxs_la_LDFLAGS = -lluajit-5.1 -lmysqlclient
