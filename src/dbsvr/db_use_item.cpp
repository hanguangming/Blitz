#include "dbsvr/dbsvr.h"

struct DB_UseCoinItemServlet : DB_Servlet<DB_UseCoinItem> {
public:
    virtual int execute(request_type *req, response_type *rsp) {
        apply_value_opts(req->id(), req->value_opts);
        apply_item_opts(req->id(), req->item_opts);
        return 0;
    }
};

GX_SERVLET_REGISTER(DB_UseCoinItemServlet, false);

struct DB_UseMoneyItemServlet : DB_Servlet<DB_UseMoneyItem> {
public:
    virtual int execute(request_type *req, response_type *rsp) {
        apply_value_opts(req->id(), req->value_opts);
        apply_item_opts(req->id(), req->item_opts);
        return 0;
    }
};

GX_SERVLET_REGISTER(DB_UseMoneyItemServlet, false);

struct DB_UseExpItemServlet : DB_Servlet<DB_UseExpItem> {
public:
    virtual int execute(request_type *req, response_type *rsp) {
        apply_value_opts(req->id(), req->value_opts);
        apply_item_opts(req->id(), req->item_opts);
        return 0;
    }
};

GX_SERVLET_REGISTER(DB_UseExpItemServlet, false);

struct DB_UseSoulItemServlet : DB_Servlet<DB_UseSoulItem> {
    virtual int execute(request_type *req, response_type *rsp) {
        apply_soldier_value_opts(req->id(), req->value_opts);
        apply_item_opts(req->id(), req->item_opts);
        return 0;
    }
};

GX_SERVLET_REGISTER(DB_UseSoulItemServlet, false);

struct DB_UseBoxItemServlet : DB_Servlet<DB_UseBoxItem> {
    virtual int execute(request_type *req, response_type *rsp) {
        apply_value_opts(req->id(), req->value_opts);
        apply_item_opts(req->id(), req->item_opts);
        return 0;
    }
};

GX_SERVLET_REGISTER(DB_UseBoxItemServlet, false)
