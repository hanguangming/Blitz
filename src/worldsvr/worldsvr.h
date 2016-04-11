#ifndef __WORLDSVR_H__
#define __WORLDSVR_H__


#include "libgx/gx.h"
GX_NS_USING;

#include "worldsvr_msg.h"
#include "libgame/global.h"
#include "libgame/world.h"

template <typename _T, typename _Request = typename _T::request_type, typename _Response = typename _T::response_type>
class WS_Servlet : public Servlet<_T, _Request, _Response> {
public:
    typedef _T type;
    typedef typename _T::request_type request_type;
    typedef typename _T::response_type response_type;


    int execute(request_type *req, response_type *rsp) override {
        G_World *world = G_World::instance();
        G_WorldPlayer *player = world->get_player(req->id());
        if (player) {
            return execute(world, player, req, rsp);
        }
        return GX_ENOTEXISTS;
    }
    virtual int execute(G_World *world, G_WorldPlayer *player, request_type *req, response_type *rsp) = 0;
};

template <typename _T>
class WS_Servlet<_T, typename _T::request_type, void> : public Servlet<_T, typename _T::request_type, void> {
public:
    typedef _T type;
    typedef typename _T::request_type request_type;
    typedef typename _T::response_type response_type;

    int execute(request_type *req) override {
        G_World *world = G_World::instance();
        return execute(world, req);
    }

    virtual int execute(G_World *world, request_type *req) = 0;
};

#endif


