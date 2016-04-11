#include "dbsvr.h"

/*
message DB_ForgeRefresh<DB_FORGE_REFRESH> {
    struct request {
        G_BagItemOpt item_opts[];
        G_ForgeOpt forge_opts[];
    };
    struct response {
    };
};
*/
class DB_ForgeRereshServlet : public DB_Servlet<DB_ForgeRefresh> {
public:
    virtual int execute(request_type *req, response_type *rsp) {
        apply_item_opts(req->id(), req->item_opts);
        apply_cooldown_opts(req->id(), req->cd_opts);
        exec(_deleteForge, req->id());
        for (auto &opt : req->forge_opts) {
            exec(_insertForge, req->id(), opt.index, opt.id, opt.used);
        }
        return 0;
    }

    GX_STMT(_deleteForge, "delete from forge where uid = ?", unsigned);
    GX_STMT(_insertForge, "insert into forge (uid, idx, item, used) values (?, ?, ?, ?)", unsigned, unsigned, unsigned, unsigned);
};

GX_SERVLET_REGISTER(DB_ForgeRereshServlet, false);


/*
message DB_ForgeBuy<DB_FORGE_BUY> {
    struct request {
        uint8 index;
        G_Money money;
    };
    struct response {
    };
};
*/
class DB_ForgeBuyervlet : public DB_Servlet<DB_ForgeBuy> {
public:
    virtual int execute(request_type *req, response_type *rsp) {
        apply_value_opts(req->id(), req->value_opts);
        apply_item_opts(req->id(), req->item_opts);
        exec(_updateForge, 1, req->id(), req->index);
        return 0;
    }

    GX_STMT(_updateForge, "update forge set used = ? where uid = ? and idx = ?", unsigned, unsigned, unsigned);
};

GX_SERVLET_REGISTER(DB_ForgeBuyervlet, false);

