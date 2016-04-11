#include "dbsvr.h"

struct DB_TechResearchServlet : DB_Servlet<DB_TechResearch> {
    virtual int execute(request_type *req, response_type *rsp) {
        apply_value_opts(req->id(), req->value_opts);
        apply_soldier_value_opts(req->id(), req->soldier_value_opts);

        for (auto &opt : req->tech_opts) {
            exec(_updateTech, req->id(), opt.type, opt.cur, opt.research, opt.price_num, opt.cooldown);
        }
        return 0;
    }

    GX_STMT(_updateTech,
            "replace into tech (uid, id, cur, research, price_num, cooldown) values (?, ?, ?, ?, ?, ?)",
            unsigned, unsigned, unsigned, unsigned, unsigned, uint64_t);
};

GX_SERVLET_REGISTER(DB_TechResearchServlet, false);
