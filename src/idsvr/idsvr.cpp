#include "idsvr.h"
#include <unordered_map>
#include <unistd.h>

std::unordered_map<uint32_t, uint64_t> the_map;
FILE *the_file;
#define ID_FILENAME "id.dmp"
#define TMP_FILENAME "id.dmp.tmp"
#define STOR_FMT "%u %" PRIu64 "\n"
static void load_file(FILE *file) {
    uint32_t type;
    uint64_t id;
    while (fscanf(file, STOR_FMT, &type, &id) == 2) {
        the_map[type] = id;
    }
}

static void save_file(FILE *file) {
    for (auto it = the_map.begin(); it != the_map.end(); ++it) {
        fprintf(file, STOR_FMT, it->first, it->second);
    }
    fflush(file);
}

int main(int argc, char **argv) {
    if (!the_app->init(argc, argv)) {
        return 1;
    }

    Path tmp_path = the_app->var_dir() + TMP_FILENAME;
    Path file_path = the_app->var_dir() + ID_FILENAME;

    FILE *tmp_file = fopen(tmp_path.c_str(), "rb");
    if (tmp_file) {
        load_file(tmp_file);
        fclose(tmp_file);
    }
    else {
        FILE *file = fopen(file_path.c_str(), "rb");
        if (file) {
            load_file(file);
            fclose(file);
            rename(file_path.c_str(), tmp_path.c_str());
        }
    }

    the_file = fopen(file_path.c_str(), "w+b");
    if (!the_file) {
        log_error("create id dump file '%s' failed.", file_path.c_str());
        return 1;
    }
    save_file(the_file);
    fflush(the_file);

    unlink(tmp_path.c_str());

    the_app->run();

    fclose(the_file);
    return 0;
}

class ID_GenServlet : public Servlet<ID_Gen> {
public:
    virtual int execute(request_type *req, response_type *rsp) {
        uint64_t id = 1024;
        auto r = the_map.emplace(req->type, id);
        if (!r.second) {
            id = ++r.first->second;
        }
        fprintf(the_file, STOR_FMT, req->type, id);
        fflush(the_file);
        rsp->id = id;
        return 0;
    }
};

GX_SERVLET_REGISTER(ID_GenServlet, false);

