#include "filemonitor.h"
#include "utils.h"

#ifndef GX_PLATFORM_WIN32
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#endif

#include "log.h"

#ifdef GX_USE_FILEMONITOR

GX_NS_BEGIN

bool FileMonitor::add(const Path &path, std::function<void(const Path&)> handler) noexcept {
#if !defined(GX_PLATFORM_WIN32) && !defined(__GX_SERVER__)
    return true;
#endif
    filetime_t time;
    if (!modify_time(path, time)) {
        return false;
    }

    auto em = _files.emplace(path, time, handler);
    if (!em.second) {
        const_cast<filetime_t&>(em.first->_time) = time;
    }
    return true;
}

bool FileMonitor::modify_time(const Path &path, filetime_t &time) noexcept {
#ifndef GX_PLATFORM_WIN32
#ifndef __GX_SERVER__
    struct stat stat;

    if (::stat(path.c_str(), &stat)) {
        return false;
    }

    time = stat.st_mtime;
#endif
    return true;
#else
    HANDLE hFile = CreateFile(
        (wchar_t*)char2wchar(path.c_str())->data(),
        GENERIC_READ,
        FILE_SHARE_READ,
        nullptr,
        OPEN_EXISTING,
        FILE_ATTRIBUTE_READONLY,
        nullptr);

    if (hFile == INVALID_HANDLE_VALUE) {
        return false;
    }

    bool r = GetFileTime(hFile, nullptr, nullptr, &time);
    CloseHandle(hFile);
    return r;
#endif
}

void FileMonitor::loop() noexcept {
    return;
    for (auto &entry : _files) {
        filetime_t time;
        if (!modify_time(entry._path, time)) {
            continue;
        }
#ifdef GX_PLATFORM_WIN32
        if (entry._time.dwLowDateTime == time.dwLowDateTime && entry._time.dwHighDateTime == time.dwHighDateTime) {
#else
        if (entry._time == time) {
#endif
            continue;
        }
        entry._time = time;
        entry._handler(entry._path);
    }
}

GX_NS_END
#endif
