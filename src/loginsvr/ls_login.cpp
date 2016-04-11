#include "loginsvr.h"
#include "dbsvr/db_account.h"
#include "agentsvr/as_login.h"

struct LS_LoginAccountServlet : LS_Servlet<LS_LoginAccount> {
public:
    int execute(request_type *req, response_type *rsp) override {
        int rc;

        DB_AccountQuery queryAccount;
        unsigned tmp = hash_string(req->user.c_str());
        if (!tmp) {
            tmp = 1;
        }
        queryAccount.req->id(tmp);
        queryAccount.req->user = req->user;
        queryAccount.req->server = the_server_id;
        if ((rc = call(queryAccount))) {
            return rc;
        }
        AS_Login login;
        login.req->id(queryAccount.rsp->uid);
        if ((rc = call(login))) {
            return rc;
        }

        rsp->uid = queryAccount.rsp->uid;
        rsp->key = login.rsp->key;
        rsp->host = login.rsp->host;
        rsp->port = login.rsp->port;
        return 0;
    }
};

GX_SERVLET_REGISTER(LS_LoginAccountServlet, true);


