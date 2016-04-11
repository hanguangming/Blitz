#include "loginsvr.h"

int main(int argc, char **argv) {
    if (!the_app->init(argc, argv)) {
        return 1;
    }

    if (!load_global()) {
        log_error("load global failed.");
        return 1;
    }

    the_app->run();
    return 0;
}


