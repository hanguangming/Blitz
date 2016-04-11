#include "loginsvr.h"
#include "worldsvr/ws_register.h"
#include "libgame/g_defines.h"

struct LS_RegisterServlet : LS_Servlet<LS_Register> {
public:
    int execute(request_type *req, response_type *rsp) override {
        if (req->side >= G_SIDE_OTHER) {
            return -1;
        }
        if (req->user.size() > G_USERNAME_LIMIT) {
            return -1;
        }
        if (req->nickname.size() > G_NICKNAME_LIMIT) {
            return -1;
        }
        if (req->passwd.size() > G_PASSWD_LIMIT) {
            return -1;
        }

        WS_Register msg;
        msg.req->id(1);
        msg.req->user = req->user;
        msg.req->passwd = req->passwd;
        msg.req->platform = req->platform;
        msg.req->nickname = req->nickname;
        msg.req->side = req->side;
        return call(msg);
    }
};

GX_SERVLET_REGISTER(LS_RegisterServlet, true);

