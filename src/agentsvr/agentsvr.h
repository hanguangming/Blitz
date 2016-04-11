#ifndef __AGENTSVR_H__
#define __AGENTSVR_H__

#include "libgx/gx.h"
GX_NS_USING;

#include "agentsvr_msg.h"
#include "libgame/player.h"
#include "libgame/context.h"
#include "libgame/g_defines.h"

template <typename _T, typename _Request = typename _T::request_type, typename _Response = typename _T::response_type>
class CL_Servlet : public Servlet<_T, _Request, _Response> {
public:
    typedef _T type;
    typedef typename _T::request_type request_type;
    typedef typename _T::response_type response_type;

    int execute(request_type *req, response_type *rsp) override {
        G_AgentContext *ctx = G_AgentContext::instance();
        G_PlayerStub *stub = ctx->stub();
        if (!stub) {
            return -1;
        }
        G_Player *player = stub->check_client(ctx);
        if (!player) {
            return -1;
        }
        if (player->state() != G_PLAYER_STATE_ONLINE) {
            return -1;
        }
        return execute(player, req, rsp);
    }

    virtual int execute(G_Player *player, request_type *req, response_type *rsp) = 0;

    template <typename _Msg>
    void send(_Msg &msg) {
        if (the_context()->peer()) {
            if (this->dump_msg()) {
                msg.req->dump(nullptr, 0, the_context()->pool());
                the_context()->pool()->grow1('\0');
                log_debug("\n%s", (char*)the_context()->pool()->finish());
            }
            the_context()->peer()->send(_Msg::the_message_id, 0, msg.req);
        }
    }
};

template <typename _T>
class CL_Servlet<_T, typename _T::request_type, void> : public Servlet<_T, typename _T::request_type, void> {
public:
    typedef _T type;
    typedef typename _T::request_type request_type;
    typedef typename _T::response_type response_type;

    int execute(request_type *req) override {
        G_AgentContext *ctx = G_AgentContext::instance();
        G_PlayerStub *stub = ctx->stub();
        if (!stub) {
            return -1;
        }
        G_Player *player = stub->player();
        if (!player) {
            return -1;
        }
        if (player->state() != G_PLAYER_STATE_ONLINE) {
            return -1;
        }
        return execute(player, req);
    }

    virtual int execute(G_Player *player, request_type *req) = 0;
};

template <typename _T, typename _Request = typename _T::request_type, typename _Response = typename _T::response_type>
class AS_Servlet : public Servlet<_T, _Request, _Response> {
public:
    typedef _T type;
    typedef typename _T::request_type request_type;
    typedef typename _T::response_type response_type;

    int execute(request_type *req, response_type *rsp) override {
        G_AgentContext *ctx = G_AgentContext::instance();
        G_PlayerStub *stub = G_PlayerMgr::instance()->get_stub(req->id());
        if (!stub) {
            return GX_ENOTEXISTS;
        }
        if (!stub->attach(ctx)) {
            return -1;
        }
        G_Player *player = G_PlayerMgr::instance()->load_player(req->id());
        if (!player) {
            return GX_ENOTEXISTS;
        }
        return execute(player, req, rsp);
    }

    virtual int execute(G_Player *player, request_type *req, response_type *rsp) = 0;

    template <typename _Msg>
    void send(_Msg &msg) {
        if (the_player()->peer()) {
            if (this->dump_msg()) {
                msg.req->dump(nullptr, 0, the_context()->pool());
                the_context()->pool()->grow1('\0');
                log_debug("\n%s", (char*)the_context()->pool()->finish());
            }
            the_player()->peer()->send(_Msg::the_message_id, 0, msg.req);
        }
    }
};

template <typename _T>
class AS_Servlet<_T, typename _T::request_type, void> : public Servlet<_T, typename _T::request_type, void> {
public:
    typedef _T type;
    typedef typename _T::request_type request_type;
    typedef typename _T::response_type response_type;

    int execute(request_type *req) override {
        G_AgentContext *ctx = G_AgentContext::instance();
        G_PlayerStub *stub = G_PlayerMgr::instance()->get_stub(req->id());
        if (!stub) {
            return GX_ENOTEXISTS;
        }
        if (!stub->attach(ctx)) {
            return -1;
        }
        G_Player *player = G_PlayerMgr::instance()->load_player(req->id());
        if (!player) {
            return GX_ENOTEXISTS;
        }
        return execute(player, req);
    }

    virtual int execute(G_Player *player, request_type *req) = 0;

    template <typename _Msg>
    void send(_Msg &msg) {
        if (the_player()->peer()) {
            if (this->dump_msg()) {
                msg.req->dump(nullptr, 0, the_context()->pool());
                the_context()->pool()->grow1('\0');
                log_debug("\n%s", (char*)the_context()->pool()->finish());
            }
            the_player()->peer()->send(_Msg::the_message_id, 0, msg.req);
        }
    }
};

#endif


