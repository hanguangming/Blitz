#include "agentsvr.h"
#include "dbsvr/db_chat.h"

struct CL_ChatServlet : CL_Servlet<CL_Chat> {
    virtual int execute(G_Player *player, request_type *req, response_type *rsp) {
        if (req->channel >= G_CHAT_CHANNEL_UNKNOWN) {
            return G_LOGIC_ERROR;
        }
        const G_ChatInfo *info = G_ChatMgr::instance()->get_info(req->channel);
        if (!info) {
            return G_LOGIC_ERROR;
        }
        if (info->price().money && !player->has_money(info->price())) {
            return G_LOGIC_ERROR;
        }
        if (!player->chat_cd()->check_set(req->channel)) {
            return GX_ENOTREADY;
        }

        if (info->price().money) {
            player->use_money(info->price());
            DB_Chat msg;
            msg.req->id(player->id());
            msg.req->value_opts = the_value_opts();
            call(msg);
        }

        AS_Chat msg;
        player->make_chat_info(msg.req->player);
        msg.req->channel = req->channel;
        msg.req->magic = req->magic;
        msg.req->msg = std::move(req->msg);

        if (req->channel == G_CHAT_CHANNEL_SIDE) {
            req->magic = player->side();
        }

        if (req->channel == G_CHAT_CHANNEL_PERSION) {
            the_app->network()->send(req->magic, AS_Chat::the_message_id, msg.req);
        }
        else {
            the_app->network()->broadcast(msg);
        }

        return 0;
    }
};

GX_SERVLET_REGISTER(CL_ChatServlet, true);

