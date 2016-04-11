#include "map_side.h"
#include "map.h"

G_MapSide::G_MapSide(unsigned id) noexcept
: _id(id), 
  _coin(),
  _aborigine_defender_num(),
  _occupy_defender_num(),
  _capital(),
  _revive()
{ }

void G_MapSide::boardcast(unsigned servlet_id, const INotify *msg) noexcept {
    ProtocolInfo info;
    info.servlet = servlet_id;
    info.seq = 0;
    info.message = msg;

    G_Map *map = G_Map::instance();
    map->_protocol.serial(info, map->_stream, false);

    for (G_MapPlayer &player : _player_list) {
        assert(player.peer());
        player.peer()->send(map->_stream);
    }

    map->_stream.clear();
}

