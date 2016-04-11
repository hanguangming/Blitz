#ifndef __GX_FILESYSTEM_H__
#define __GX_FILESYSTEM_H__

#include "platform.h"
#include "singleton.h"
#include "path.h"
#include "data.h"

#ifdef ANDROID
#include "android/asset_manager.h"
#endif

GX_NS_BEGIN

class FileEntry : public Object {
public:
    FileEntry(const Path &path, bool is_dir) noexcept 
    : _path(path), _is_dir(is_dir)
    { }

    bool is_dir() const noexcept {
        return _is_dir;
    }
    const Path &path() const noexcept {
        return _path;
    }
private:
    Path _path;
    bool _is_dir;
};

class Directory : public Object {
public:
    Directory(const Path &path) noexcept
    : _path(path) { }

private:
    Path _path;
};

class FileFinder : public Object {
public:
    virtual bool next(Path&) noexcept = 0;
};

class FileList;
class FileSystem : public Object, public singleton<FileSystem> {
public:
    enum {
        OS,
        ASSETS,
        UNKNOWN,
    };
public:
    FileSystem() noexcept;
    ~FileSystem() noexcept;

    int type() const noexcept {
        return _type;
    }
    void use_os() noexcept {
        _type = OS;
    }
#ifdef ANDROID
    void use_assets() noexcept {
        _type = ASSETS;
    }
#endif
    bool use_filelist() const noexcept {
        return _use_filelist;
    }
    void use_filelist(bool value) noexcept {
        _use_filelist = value;
    }
#ifdef ANDROID
    void set_assert_manager(AAssetManager *mgr) noexcept {
        _assetmgr = mgr;
    }
#endif
    ptr<Data> load(const Path &path) noexcept;
    bool load_filelist(const Path &path) noexcept;
    ptr<FileFinder> find(const Path &path) noexcept;

private:
    ptr<Data> os_load(const Path &path) noexcept;
    ptr<Data> asset_load(const Path &path) noexcept;
    ptr<FileFinder> os_find(const Path &path) noexcept;
    ptr<FileFinder> filelist_find(const Path &path) noexcept;
private:
    int _type;
    bool _use_filelist;
    ptr<FileList> _filelist;
#ifdef ANDROID
    AAssetManager *_assetmgr;
#endif
};

GX_NS_END

#endif

