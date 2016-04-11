#ifndef __LIBGAME_GUID_H__
#define __LIBGAME_GUID_H__

#include "game.h"

class G_GuidObject {
public:
    G_GuidObject() noexcept : _guid() { }

    uint64_t make_guid() noexcept {
        return ++_guid;
    }
    void check_guid(uint64_t guid) noexcept {
        if (guid > _guid) {
            _guid = guid;
        }
    }
private:
    uint64_t _guid;
};

#endif

