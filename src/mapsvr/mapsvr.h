#ifndef __MAPSVR_H__
#define __MAPSVR_H__


#include "libgx/gx.h"
GX_NS_USING;

#include "mapsvr_msg.h"
#include "libgame/map.h"

template <typename _T, typename _Request = typename _T::request_type, typename _Response = typename _T::response_type>
class MS_Servlet : public Servlet<_T, _Request, _Response> {
public:
    typedef _T type;
    typedef typename _T::request_type request_type;
    typedef typename _T::response_type response_type;

    int execute(request_type *req, response_type *rsp) override {
        G_Map *map = G_Map::instance();
        G_MapPlayer *player = map->get_player(req->id());
        if (player) {
            return execute(map, player, req, rsp);
        }
        return GX_ENOTEXISTS;
    }

    virtual int execute(G_Map *map, G_MapPlayer *player, request_type *req, response_type *rsp) = 0;
};

template <typename _T>
class MS_Servlet<_T, typename _T::request_type, void> : public Servlet<_T, typename _T::request_type, void> {
public:
    typedef _T type;
    typedef typename _T::request_type request_type;
    typedef typename _T::response_type response_type;

    int execute(request_type *req) override {
        G_Map *map = G_Map::instance();
        return execute(map, req);
    }

    virtual int execute(G_Map *map, request_type *req) = 0;
};

#endif

