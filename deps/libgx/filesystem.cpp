#include <set>
#include "filesystem.h"

GX_NS_BEGIN

/* FileList */
struct FileList : Object {
    struct FileEntry {
        FileEntry(const std::string &name) noexcept : _name(name) { }
        std::string _name;
        bool operator<(const FileEntry &x) const noexcept {
            return _name < x._name;
        }
    };
    struct DirEntry {
        DirEntry() noexcept { }
        DirEntry(const char *path) noexcept : _path(path) { }
        void add(const std::string file) noexcept {
            _files.emplace(file);
        }
        bool operator<(const DirEntry &x) const noexcept {
            return _path < x._path;
        }
        std::string _path;
        std::set<FileEntry> _files;
    };

    struct Finder : FileFinder {
        Finder(ptr<FileList> filelist, const Path &path) noexcept 
        : _filelist(filelist) 
        , _path(path) {
            _it_dir = _filelist->_dirs.find(path.c_str());
            if (_it_dir != _filelist->_dirs.end()) {
                _it_file = (*_it_dir)._files.begin();
            }
        }

        bool next(Path &path) noexcept override {
            while (1) {
                if (_it_dir == _filelist->_dirs.end()) {
                    return false;
                }
                if (_it_file == (*_it_dir)._files.end()) {
                    ++_it_dir;
                    if (_it_dir == _filelist->_dirs.end()) {
                        return false;
                    }
                    _it_file = (*_it_dir)._files.begin();
                    continue;
                }
                path = Path((*_it_dir)._path) + (*_it_file)._name;
                ++_it_file;
                return true;
            }
        }

        ptr<FileList> _filelist;
        Path _path;
        std::set<DirEntry>::iterator _it_dir;
        std::set<FileEntry>::iterator _it_file;
    };

    void add(const Path &path) noexcept {
        if (path.empty()) {
            return;
        }
        Path dir = path.directory();
        auto em = _dirs.emplace(dir.c_str());
        DirEntry &entry = const_cast<DirEntry&>(*em.first);
        entry.add(path.filename());
    }

    bool exists(const Path &path) const noexcept {
        static DirEntry tmp;
        tmp._path = path.directory().c_str();
        return _dirs.find(tmp) != _dirs.end();
    }
    std::set<DirEntry> _dirs;
};

FileSystem::FileSystem() noexcept
: _type(OS), _use_filelist(false)
#ifdef ANDROID
, _assetmgr()
#endif
{ }

FileSystem::~FileSystem() noexcept
{ }

ptr<Data> FileSystem::os_load(const Path &path) noexcept {
    FILE *file = fopen(path.c_str(), "rb");
    if (!file) {
        return nullptr;
    }

    int size = fseek(file, 0, SEEK_END);
    if (size < 0) {
        fclose(file);
        return nullptr;
    }
    size = ftell(file);
    rewind(file);

    object<Data> data(size);
    if (fread(data->data(), 1, size, file) != (size_t)size) {
        fclose(file);
        return nullptr;
    }
    fclose(file);
    return data;
}

ptr<Data> FileSystem::asset_load(const Path &path) noexcept {
#ifndef ANDROID
    return nullptr;
#else
    if (!_assetmgr) {
        return nullptr;
    }
    AAsset *aa = AAssetManager_open(_assetmgr, path.c_str(), AASSET_MODE_UNKNOWN);
    if (!aa) {
        return nullptr;
    }
    off_t size = AAsset_getLength(aa);
    object<Data> data(size);
    AAsset_read(aa, data->data(), size);
    AAsset_close(aa);
    return data;
#endif
}

ptr<Data> FileSystem::load(const Path &path) noexcept {
    if (_use_filelist) {
        assert(_filelist);
        if (!_filelist->exists(path)) {
            return nullptr;
        }
    }
    switch (_type) {
    case OS:
        return os_load(path);
    case ASSETS:
        return asset_load(path);
    default:
        return nullptr;
    }
}

bool FileSystem::load_filelist(const Path &path) noexcept {
    ptr<Data> data = load(path);
    if (!data) {
        return false;
    }

    _filelist = object<FileList>();
    char *p2 = nullptr;
    for (char *p = data->data(); ; p++) {
        int c = *p;
        if (c == '\n' || c == '\r' || !c) {
            if (p2) {
                *p = '\0';
                _filelist->add(p2);
            }
            if (!c) {
                break;
            }
            p2 = nullptr;
            continue;
        }
        if (!p2) {
            p2 = p;
        }
    }

    return true;
}

ptr<FileFinder> FileSystem::os_find(const Path &path) noexcept {
    return nullptr;
}

ptr<FileFinder> FileSystem::filelist_find(const Path &path) noexcept {
    return nullptr;
}

ptr<FileFinder> FileSystem::find(const Path &path) noexcept {
    if (_use_filelist) {
        return filelist_find(path);
    }
    if (_type == OS) {
        return os_find(path);
    }
    return nullptr;
}

GX_NS_END
