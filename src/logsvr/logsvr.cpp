#include "libgx/gx.h"
GX_NS_USING

struct LogEntry {
    LogEntry() : name(), file() { }
    ~LogEntry() {
        if (file) {
            fclose(file);
        }
    }
    const char *name;
    size_t hash;
    FILE *file;
};

struct equal {
    bool operator()(const LogEntry *lhs, const LogEntry *rhs) const noexcept {
        return lhs->hash == rhs->hash && !strcmp(lhs->name, rhs->name);
    }
};

struct hash {
    size_t operator()(const LogEntry *entry) const noexcept {
        return entry->hash;
    }
};

int main(int argc, char **argv) {
    std::unordered_set<LogEntry*, hash, equal> entries;

    if (!the_app->init_env(argc, argv)) {
        return 1;
    }

    int fd;
    if ((fd = socket(AF_INET,SOCK_DGRAM,0)) < 0) {
        perror("socket");
        return 1;
    }

    const Address &addr = the_app->log_addr();
    if (bind(fd, addr, Address::length) < 0) {
        perror("bind");
        return 1;
    }

    FILE *log_file = fopen((the_app->log_dir() + "sgq.log").c_str(), "a");

    char buf[1024 * 32];
    the_app->daemon();


    while (1) {
        socklen_t addr_len = Address::length;
        Address addr = the_app->log_addr();
        int n = recvfrom(fd, buf, sizeof(buf), 0 , addr, &addr_len);
        if (n < 0) {
            break;
        }
        else if (!n) {
            continue;
        }

        char *p = buf;
        int level;
        level = *((char*)p);
        p++;
        n--;

        if (n < (int)sizeof(timeval_t)) {
            continue;
        }

        timeval_t t = *((timeval_t*)p);
        p += sizeof(timeval_t);
        n -= sizeof(timeval_t);

        if (n < 1) {
            continue;
        }
        unsigned name_len = *((unsigned char*)p);
        p++;
        n--;

        if (name_len <= 1) {
            continue;
        }

        if (n < (int)name_len + 1) {
            continue;
        }

        char *name = p;
        if (name[name_len]) {
            continue;
        }

        p += (name_len + 1);
        n -= (name_len + 1);

        if (n < 1) {
            continue;
        }
        unsigned id = *((unsigned char*)p);
        p++;
        n--;

        if (n <= 1) {
            continue;
        }

        if (p[n - 1]) {
            continue;
        }

        switch (level) {
        case LOG_DEBUG:
            level = 'D';
            break;
        case LOG_INFO:
            level = 'I';
            break;
        case LOG_WARNING:
            level = 'W';
            break;
        case LOG_ERROR:
            level = 'E';
            break;
        case LOG_DIE:
            level = 'd';
            break;
        default:
            continue;
        }

        struct LogEntry entry, *logentry;
        entry.name = name;
        entry.hash = hash_iterative(name, name_len);
        auto em = entries.emplace(&entry);

        if (em.second) {
            char log_name[512];
            sprintf(log_name, "%s.log", name);
            FILE *file = fopen((the_app->log_dir() + log_name).c_str(), "a");
            if (!file) {
                entries.erase(em.first);
                continue;
            }

            logentry = new LogEntry;
            const_cast<LogEntry*&>(*em.first) = logentry;

            logentry->name = Pool::instance()->strdup(name);
            logentry->hash = entry.hash;
            logentry->file = file;
        }
        else {
            logentry = *em.first;
        }
        struct tm tm; 
        t /= 1000;
        localtime_r((time_t*)&t, &tm);
        tm.tm_year += 100;
        tm.tm_mon++;
        /*
        fprintf(logentry->file, "%s[%u]:%02d:%02d:%02d:%c: ", name, id, tm.tm_hour, tm.tm_min, tm.tm_sec, level);
        fputs(p, logentry->file);
        fputc('\n', logentry->file);
        fflush(logentry->file);*/

        fprintf(log_file, "%s[%u]:%02d:%02d:%02d:%c: ", name, id, tm.tm_hour, tm.tm_min, tm.tm_sec, level);
        fputs(p, log_file);
        fputc('\n', log_file);
        fflush(log_file);

    }

    fclose(log_file);
    for (auto entry : entries) {
        delete entry;
    }
    return 0; 
}


