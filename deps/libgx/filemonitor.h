#ifndef __GX_FILE_MONITOR_H__
#define __GX_FILE_MONITOR_H__

#include <functional>
#include <unordered_set>

#include "timermanager.h"
#include "path.h"
#include "timeval.h"
#include "hash.h"

GX_NS_BEGIN

#if !defined(GX_PLATFORM_WIN32) && !defined(__GX_SERVER__)
class FileMonitor : public Object {
public:
    FileMonitor() noexcept { }
    void loop() noexcept { }
    bool add(const Path &path, std::function<void(const Path&)> handler) noexcept { return true; }
};
#else
#define GX_USE_FILEMONITOR

#ifdef GX_PLATFORM_WIN32
typedef FILETIME filetime_t;
#else
typedef time_t filetime_t;
#endif

class FileMonitor : public Object {
public:
    FileMonitor() noexcept : _running(false) { }
    void loop() noexcept;
    bool add(const Path &path, std::function<void(const Path&)> handler) noexcept;

private:
    struct entry {
        entry(const Path &path, filetime_t &time, std::function<void(const Path&)> handler) noexcept
            : _time(time), _path(path), _handler(handler)
        { }
        bool operator==(const entry &x) const noexcept {
            return _path == x._path;
        }
        struct hash {
            size_t operator()(const entry &x) const noexcept {
                return hash_iterative(x._path.c_str(), x._path.size());
            }
        };

        mutable filetime_t _time;
        Path _path;
        std::function<void(const Path&)> _handler;
    };
private:
    static bool modify_time(const Path &path, filetime_t &time) noexcept;
private:
    bool _running;
    std::unordered_set<entry, entry::hash> _files;
};

#endif
GX_NS_END



#endif
