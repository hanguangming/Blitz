#include "agentsvr.h"

struct AS_ChatServlet : Servlet<AS_Chat> {
    virtual int execute(request_type *req) {
        if (req->channel != G_CHAT_CHANNEL_PERSION) {
            G_PlayerMgr::instance()->broadcast_chat(req);
        }
        else {
            G_Player *player = G_PlayerMgr::instance()->get_player(req->magic);
            if (player && player->state() == G_PLAYER_STATE_ONLINE) {
                CL_NotifyChatReq msg;
                msg.player = req->player;
                msg.channel = req->channel;
                msg.magic = req->magic;
                msg.msg = std::move(req->msg);
                player->send(msg);
            }
        }
        return 0;
    }
};

GX_SERVLET_REGISTER(AS_ChatServlet, false);

