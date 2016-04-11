#ifndef __LIBGAME_MAP_SIDE_H__
#define __LIBGAME_MAP_SIDE_H__

#include "game.h"
#include "map_player.h"

class G_Map;

/* G_MapSide */
class G_MapSide : public Object {
    friend class G_Map;
    friend class G_MapCity;
public:
    G_MapSide(unsigned id) noexcept;

    void boardcast(unsigned servlet_id, const INotify *msg) noexcept;

    template <typename _T>
    void boardcast(const _T &msg) noexcept {
        boardcast(_T::the_message_id, msg.req);
    }

    unsigned id() const noexcept {
        return _id;
    }
private:
    unsigned _id;
    unsigned _coin;

    unsigned _aborigine_defender_num;
    unsigned _occupy_defender_num;
    G_MapCity *_capital;
    G_MapCity *_revive;
    G_MapPlayerSideList _player_list;
};

#endif

