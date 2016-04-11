#include <map>
#include <unistd.h>
#include <sys/types.h>
#include <signal.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/file.h>

#include "gamesvr.h"
#include "sys_msg.h"

std::map<unsigned, G_GameNode> _nodes;
void startup(const char *name) {
    Pool pool;

    for (auto &network_node : the_app->network()->nodes()) {
        if (strcmp(network_node->name(), name) == 0) {
            for (unsigned i = 0; i < network_node->instance_count(); ++i) {
                char *cmd = pool.printf(
                    "%s/bin/%s", 
                    the_app->home_dir().c_str(), network_node->name());
                char *id = pool.printf("%d", i);

                pid_t pid = fork();
                if (pid < 0) {
                    log_error("fork error.");
                    exit(1);
                } else if (pid > 0) {
                    G_GameNode game_node;
                    game_node._instance = i;
                    game_node._network_node = network_node;
                    game_node._name = network_node->name();
                    _nodes[pid] = game_node;
                } else {
                    execlp(cmd, cmd, "-h", the_app->home_dir().c_str(), "-n", id, nullptr);
                    perror(cmd);
                    exit(errno);            
                }
            }
        }
    }
}

void startup() {
    _nodes.clear();

    startup("dbsvr");
    startup("idsvr");
    startup("worldsvr");
    startup("fightsvr");
    startup("mapsvr");
    startup("agentsvr");
    startup("loginsvr");
}

void shutdown(const char *name) {
    for (auto it = _nodes.begin(); it != _nodes.end(); ++it) {
        G_GameNode &node = it->second;
        if (node._name == name) {
            pid_t pid = it->first;
            int status;
            kill(pid, SIGTERM);
            waitpid(pid, &status, 0);
        }
    }
}

void shutdown() {
    shutdown("loginsvr");
    shutdown("agentsvr");
    shutdown("mapsvr");
    shutdown("fightsvr");
    shutdown("worldsvr");
    shutdown("idsvr");
    shutdown("dbsvr");
}

int main(int argc, char **argv) {
    if (!the_app->init(argc, argv)) {
        return 1;
    }

    std::string pid_name = the_app->name();
    pid_name += ".pid";
    Path lock_name = the_app->var_dir() + pid_name.c_str();
    int lock_file = open(lock_name.c_str(), O_WRONLY | O_CREAT, 0644);
    if (lock_file < 0) {
        fprintf(stderr, "create lock file '%s' failed.", lock_name.c_str());
        exit(1);  
    }
    if (flock(lock_file, LOCK_EX | LOCK_NB) < 0) {
        if (errno != EWOULDBLOCK) {
            fprintf(stderr, "create lock file '%s' failed.", lock_name.c_str());
        }
        else {
            fprintf(stderr, "process already running.\n");
        }
        close(lock_file);
        exit(1);
    }
    else {
        Data buf(256);
        sprintf(buf.data(), "%d", the_app->pid());
        if (write(lock_file, buf.data(), strlen(buf.data())) < 0) {
            fprintf(stderr, "write lock file '%s' failed.", lock_name.c_str());
            close(lock_file);
            exit(1);
        }
    }

    if (the_app->is_daemon()) {
        the_app->daemon();
    }
    startup();
    the_app->run();
    shutdown();
    close(lock_file);
    return 0;
}




