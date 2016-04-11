#ifndef __GX_APPLICATION_H__
#define __GX_APPLICATION_H__

#include <string>
#include <cstring>
#include "platform.h"
#include "memory.h"
#include "timermanager.h"
#include "path.h"
#include "pool.h"
#include "script.h"
#include "network.h"
#include "reactor.h"
#include "filemonitor.h"

GX_NS_BEGIN

class Application : public Object {
public:
    Application() noexcept;
    ~Application() noexcept;

    bool init(int argc, char* const argv[], const char *name = nullptr, int type = -1);
    bool init_env(int argc, char* const argv[]);

    unsigned id() const noexcept {
        return _id;
    }
    ptr<TimerManager> timer_manager() const noexcept {
        return _timermgr;
    }
    ptr<Reactor> reactor() const noexcept {
        return _reactor;
    }
    const char *name() const noexcept {
        return _name.c_str();
    }
    ptr<Script> script() const noexcept {
        return _script;
    }
    unsigned pid() const noexcept {
        return _pid;
    }
    const Path &app_dir() const noexcept {
        return _app_dir;
    }
    const Path &home_dir() const noexcept {
        return _home_dir;
    }
    const Path &etc_dir() const noexcept {
        return _etc_dir;
    }
    const Path &script_dir() const noexcept {
        return _script_dir;
    }
    const Path &script_var_dir() const noexcept {
        return _script_var_dir;
    }
    const Path &var_dir() const noexcept {
        return _var_dir;
    }
    const Path &image_dir() const noexcept {
        return _image_dir;
    }
    const Path &log_dir() const noexcept {
        return _log_dir;
    }
    const Address &log_addr() const noexcept {
        return _log_addr;
    }
    ptr<Network> network() const noexcept {
        return _network;
    }
    bool is_daemon() const noexcept {
        return _daemon;
    }
    bool loop() noexcept;
    void run() noexcept;
    void term() noexcept;
    bool termed() noexcept;
    void daemon() noexcept;
private:
    void init_name(const char *name) noexcept;
    timeval_t file_monitor_timer(timeval_t r, Timer&, timeval_t) noexcept;
    static void shutdown_routine(void *param) noexcept;
private:
    unsigned _id;
    object<TimerManager> _timermgr;
    object<Reactor> _reactor;
    object<FileMonitor> _filemonitor;
    object<Script> _script;
    std::string _name;
    unsigned _pid;
    Path _app_dir;
    Path _home_dir;
    Path _etc_dir;
    Path _script_dir;
    Path _script_var_dir;
    Path _var_dir;
    Path _image_dir;
    Path _log_dir;
    bool _daemon;
    object<Network> _network;
    Address _log_addr;
    int _type;
public:
    std::function<void()> shutdown;
};

extern const object<Application> the_app;


GX_NS_END

#endif

