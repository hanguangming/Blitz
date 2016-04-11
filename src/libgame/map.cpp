#include <unordered_set>
#include <map>

#include "map.h"
#include "agentsvr/cl_notify.h"

/* G_GraphicMatrix */
G_GraphicMatrix::G_GraphicMatrix(unsigned size) noexcept {
    assert(size);
    _size = size;
    unsigned n = size * size * sizeof(unsigned);

    _elems = (unsigned*)std::malloc(n);
    memset(_elems, 0, n);
}

G_GraphicMatrix::~G_GraphicMatrix() noexcept {
    if (_elems) {
        std::free(_elems);
    }
}


/* G_Map */
G_Map::G_Map() noexcept 
: _players(_pool),
  _peers(_pool)
{
    for (unsigned i = 0; i < G_SIDE_UNKNOWN; ++i) {
        _sides[i] = object<G_MapSide>(i);
    }
}

bool G_Map::init() {
    auto tab_info = the_app->script()->read_table("the_map_info");
    if (tab_info->is_nil()) {
        return false;
    }
    for (unsigned i = 1; ; ++i) {
        auto tab_item = tab_info->read_table(i);
        if (tab_item->is_nil()) {
            break;
        }

        int id = tab_item->read_integer("id", -1);
        if (id < 0) {
            continue;
        }

        G_MapCity *city = probe_city(id);

        city->_coin = tab_item->read_integer("tongqian");
        unsigned side_id = tab_item->read_integer("mbelong");
        side_id--;
        if (side_id > G_SIDE_UNKNOWN) {
            log_error("unknown side id '%d'.", side_id + 1);
            return false;
        }

        city->_origin = city->_side = get_side(side_id);
        city->_side->_coin += city->_coin;

        auto joins = tab_item->read_table("xiangling");
        if (joins->is_nil()) {
            log_error("city '%d' is solo.", id);
            return false;
        }

        for (unsigned j = 1; ; ++j) {
            int join_item = joins->read_integer(j, -1);
            if (join_item < 0) {
                break;
            }
            city->_joins[join_item] = probe_city(join_item);
        }
    }
    if (!init_side()) {
        return false;
    }
    for (G_MapCity *city : _city_list) {
        if (!city->_origin) {
            log_error("city %d bad.", city->_id);
            continue;
        }
        city->init();
    }

    object<G_GraphicMatrix> path(_city_list.size());
    G_GraphicMatrix mat(_city_list.size());

    for (unsigned i = 0; i < _city_list.size(); ++i) {
        for (unsigned j = 0; j < _city_list.size(); ++j) {
            if (i == j) {
                mat.elem(i, j) = 0;
            }
            else {
                G_MapCity *city = _city_list[i];
                G_MapCity *city2 = _city_list[j];
                if (city->_joins.find(city2->_id) == city->_joins.end()) {
                    mat.elem(i, j) = UINT32_MAX;
                }
                else {
                    mat.elem(i, j) = 1;
                }
            }
        }
    }
    for (unsigned i = 0; i < _city_list.size(); ++i) {
        for (unsigned j = 0; j < _city_list.size(); ++j) {
            path->elem(i, j) = UINT32_MAX;
        }
    }
    for(unsigned k = 0; k < _city_list.size(); k++) {
        for(unsigned i = 0; i < _city_list.size(); i++) {
            for(unsigned j = 0; j < _city_list.size(); j++) {
                if((mat.elem(i, k) && mat.elem(k, j) && mat.elem(i, k) < UINT32_MAX && mat.elem(k, j) < UINT32_MAX) && 
                   (mat.elem(i, k) + mat.elem(k, j) < mat.elem(i, j))) {
                    mat.elem(i, j) = mat.elem(i, k) + mat.elem(k, j);
                    path->elem(i, j) = path->elem(k, j);
                }  
            }  
        }
    }
    _path = path;
    return true;
}

/*
void displaypath(int source,int dest){  
    stack<int> shortpath;  
    int temp = dest;  
    while(temp != source){  
        shortpath.push(temp);  
        temp = path[source][temp];  
    }  
    shortpath.push(source);  
    cout<<"short distance:"<<weight[source][dest]<<endl<<"path:";  
    while(!shortpath.empty()){  
        cout<<shortpath.top()<<" ";  
        shortpath.pop();  
    }  
}  
*/
bool G_Map::init_side() {
    auto tab_info = the_app->script()->read_table("the_side_info");
    if (tab_info->is_nil()) {
        return false;
    }
    for (unsigned i = 1; ; ++i) {
        auto tab_item = tab_info->read_table(i);
        if (tab_item->is_nil()) {
            break;
        }

        unsigned id = tab_item->read_integer("id", 0);
        id--;
        if (id > G_SIDE_UNKNOWN) {
            log_error("unknown side '%d'.", id + 1);
            return false;
        }

        G_MapSide *side = _sides[id];
        unsigned capital_id = tab_item->read_integer("capital", 0);
        unsigned revive_id = tab_item->read_integer("reborn", 0);

        if (id < G_SIDE_OTHER) {
            side->_capital = get_city(capital_id);
            if (!side->_capital) {
                log_error("unknown capital city '%d'.", capital_id);
                return false;
            }
            side->_revive = get_city(revive_id);
            if (!side->_revive) {
                log_error("unknown revive city '%d'.", revive_id);
                return false;
            }
        }

        side->_aborigine_defender_num = tab_item->read_integer("defarmy1", 0); 
        side->_occupy_defender_num = tab_item->read_integer("defarmy2", 0); 
    }
    return true;
}

G_MapCity *G_Map::get_city(unsigned id) noexcept {
    static object<G_MapCity> tmp;
    tmp->_id = id;
    tmp->_hash = hash_iterative(&id, sizeof(id));

    auto it = _cities.find(tmp);
    if (it == _cities.end()) {
        return nullptr;
    }
    return *it;
}

G_MapCity *G_Map::probe_city(unsigned id) noexcept {
    static object<G_MapCity> tmp;
    tmp->_id = id;
    tmp->_hash = hash_iterative(&id, sizeof(id));

    auto r = _cities.emplace(tmp);
    if (r.second) {
        object<G_MapCity> city;
        const_cast<ptr<G_MapCity>&>(*r.first) = city;
        city->_id = id;
        city->_hash = tmp->_hash;
        city->_index = _city_list.size();
        _city_list.push_back(city.get());
    }
    return *r.first;
}

void G_Map::login(unsigned id, const G_MapPlayerInfo &info, uint64_t key) noexcept {
    G_MapPlayer *player = _players.probe_player(id);
    if (player->_key) {
        logout(player, false);
    }
    _peers.add_object(player, the_context()->peer());
    player->name(info.name);
    player->vip(info.vip);
    player->level(info.level);
    player->side(get_side(info.side));
    player->appearance(info.appearance);
    player->speed(info.speed);
    player->_key = key;

    if (!player->_city) {
        player->_city = player->_side->_revive;
        player->_city->enter(player);
    }
}

bool G_Map::login(G_MapPlayer *player, uint64_t key, Peer *peer) noexcept {
    assert(peer);
    if (!player->_key || player->_key != key) {
        return false;
    }
    if (player->_peer) {
        return false;
    }

    peer->peer_object = player;
    player->_peer = peer;
    _peer_list.push_front(player);
    player->_side->_player_list.push_front(player);

    do {
        CL_NotifyCityPresendReq msg;
        for (G_MapCity *city : _city_list) {
            if (city->_state == G_CITY_FIGHT || city->_side != city->_origin) {
                msg.cities.emplace_back();
                auto &presend = msg.cities.back();
                city->to_presend(presend);
                if (msg.cities.size() >= 64) {
                    peer->send(CL_NotifyCityPresend::the_message_id, &msg);
                    msg.cities.resize(0);
                }
            }
        }
        if (msg.cities.size()) {
            peer->send(CL_NotifyCityPresend::the_message_id, &msg);
        }
    } while (0);

    do {
        CL_NotifyPeopleReq msg;
        msg.people = player->people();
        msg.people_all = player->people_all();
        peer->send(CL_NotifyPeopleReq::the_message_id, &msg);
    } while (0);
    return true;
}

void G_Map::logout(G_MapPlayer *player, bool remove) noexcept {
    if (!player->_key) {
        return;
    }
    player->_key = 0;

    _peers.remove_object(player);

    if (player->_peer) {
        G_MapPlayerPeerList::remove(player);
        G_MapPlayerSideList::remove(player);
        player->_peer->close();
    }
    if (player->_subscribe) {
        player->subscribe(nullptr);
    }
    /*
    if (remove && player->_city == player->_side->_revive) {
        _players.remove_player(player);
    }*/
}

void G_Map::move(G_MapPlayer *player, obstack_vector<unsigned> &path, unsigned type) noexcept {
    player->_path = std::vector<unsigned>(path.begin(), path.end());
    player->_path_index = 0;
    if (!player->_move_timer) {
        move_next(player, type);
    }
}

timeval_t G_Map::move_timer_handler(G_MapPlayer *player, Timer&, timeval_t) {
    player->_move_timer = nullptr;
    move_next(player, G_MOVE_NORMAL);
    return 0;
}

timeval_t G_Map::move_next(G_MapPlayer *player, unsigned type) noexcept {
    if (player->_path_index >= player->_path.size()) {
        goto stop;
    }
    else {
        unsigned id = player->_path[player->_path_index++];
        G_MapCity *city = get_city(id);
        if (!city) {
            log_debug("no city %d", id);
            goto stop;
        }
        if (player->_city->_joins.find(id) == player->_city->_joins.end()) {
            log_debug("no join between %d with %d", player->_city->id(), id);
            goto stop;
        }
        if (!move(player, city, type)) {
            goto stop;
        }
        player->_move_timer = the_app->timer_manager()->schedule(
            player->_speed, 
            std::bind(&G_Map::move_timer_handler, this, player, _1, _2));
        broadcast_move(player);
        return player->_speed;
    }

stop:
    player->_path.resize(0);
    if (player->_from) {
        player->_from = nullptr;
        broadcast_remove(player);
    }
    return 0;
}

bool G_Map::move(G_MapPlayer *player, G_MapCity *city, unsigned type) noexcept {
    if (!city->enter_check(player)) {
        return false;
    }
    if (!player->_city->leave(player, type, city)) {
        return false;
    }
    player->_from = player->_city;
    city->enter(player);
    return true;
}

void G_Map::broadcast(unsigned servlet_id, const INotify *msg) noexcept {
    ProtocolInfo info;
    info.servlet = servlet_id;
    info.seq = 0;
    info.message = msg;
    _protocol.serial(info, _stream, false);

    for (G_MapPlayer &player : _peer_list) {
        assert(player._peer);
        player._peer->send(_stream);
    }

    _stream.clear();
}


void G_Map::broadcast_move(const G_MapPlayer *player) noexcept {
    CL_NotifyMovePresendReq msg;
    player->to_presend(msg.presend);
    log_debug("player %d move to %d.", player->id(), msg.presend.to);
    broadcast(msg);
}

void G_Map::broadcast_remove(const G_MapPlayer *player) noexcept {
    CL_NotifyRemovePresendReq msg;
    msg.id = player->id();
    broadcast(msg);
}


