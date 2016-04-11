#include "value.h"
#include "context.h"
#include "dbsvr/db_login.h"

void G_ValuesBase::mark_update(unsigned index, unsigned value) noexcept {
    auto &opts = the_data()->_value_opts;
    opts.emplace_back();
    G_ValueOpt &opt = opts.back();
    opt.id = index;
    opt.value = value;
}


