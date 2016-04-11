#include "param.h"

G_ParamMgr::G_ParamMgr()
: _train_item(),
  _expup_item(),
  _fire_hero_limit(),
  _expup_value(),
  _tech_acc_time(),
  _tiger_item(),
  _tiger_times(),
  _tiger_grow(),
  _team_hero_people(),
  _team_soldier_people(),
  _free_supplement_num(),
  _supplement_item()
{ }

bool G_ParamMgr::init() {
    auto tab_info = the_app->script()->read_table("the_param_info");
    if (tab_info->is_nil()) {
        return false;
    }
    for (unsigned i = 1; ; ++i) {
        auto tab_item = tab_info->read_table(i);
        if (tab_item->is_nil()) {
            break;
        }

        std::string name = tab_item->read_string("name", "");
        std::string value = tab_item->read_string("value", "");

        if (name == "xunlianfu") {
            _train_item = G_ItemMgr::instance()->get_info(strtoul(value.c_str(), nullptr, 10));
        }
        else if (name == "tufeiling") {
            _expup_item = G_ItemMgr::instance()->get_info(strtoul(value.c_str(), nullptr, 10));
        }
        else if (name == "jiegu") {
            _fire_hero_limit = strtoul(value.c_str(), nullptr, 10);
        }
        else if (name == "tufeiling_exp") {
            _expup_value = strtoul(value.c_str(), nullptr, 10);
        }
        else if (name == "tech_acc_time") {
            _tech_acc_time = strtoul(value.c_str(), nullptr, 10) * 1000;
        }
        else if (name == "tech_acc_price") {
            _tech_acc_price.money = strtoul(value.c_str(), nullptr, 10);
        }
        else if (name == "tiger_item") {
            _tiger_item = G_ItemMgr::instance()->get_info(strtoul(value.c_str(), nullptr, 10));
        }
        else if (name == "tiger_times") {
            _tiger_times = strtoul(value.c_str(), nullptr, 10);
        }
        else if (name == "tiger_grow") {
            _tiger_grow = strtoul(value.c_str(), nullptr, 10);
        }
        else if (name == "freesodier") {
            _free_supplement_num = strtoul(value.c_str(), nullptr, 10);
        }
        else if (name == "heropopulation") {
            _team_hero_people = strtoul(value.c_str(), nullptr, 10);
        }
        else if (name == "sodierspopulation") {
            _team_soldier_people = strtoul(value.c_str(), nullptr, 10);
        }
        else if (name == "mubingling") {
            _supplement_item = G_ItemMgr::instance()->get_info(strtoul(value.c_str(), nullptr, 10));
        }
        else if (name == "freeshadow") {
            _free_shadow_num = strtoul(value.c_str(), nullptr, 10);
        }
        else if (name == "shadowdefaultcost") {
            _shadow_define_price.money = strtoul(value.c_str(), nullptr, 10);
        }
        else if (name == "shadowgrowtimes") {
            _shadow_grow_times = strtoul(value.c_str(), nullptr, 10);
        }
        else if (name == "shadowgrowcost") {
            _shadow_grow_price.money = strtoul(value.c_str(), nullptr, 10);
        }
        else if (name == "challenge_times") {
            _challenge_times = strtoul(value.c_str(), nullptr, 10);
        }
        else if (name == "tiaozhanling") {
            _challenge_item = G_ItemMgr::instance()->get_info(strtoul(value.c_str(), nullptr, 10));
        }
        else if (name == "challenge_win") {
            _challenge_win_award = G_AwardMgr::instance()->get_info(strtoul(value.c_str(), nullptr, 10));
        }
        else if (name == "challenge_lose") {
            _challenge_lose_award = G_AwardMgr::instance()->get_info(strtoul(value.c_str(), nullptr, 10));
        }
        else if (name == "train_acc_time") {
            _train_acc_time = strtoul(value.c_str(), nullptr, 10) * 1000;
        }
        else if (name == "train_acc_price") {
            _train_acc_price.money = strtoul(value.c_str(), nullptr, 10);
        }
        else if (name == "sweepopen") {
            _stage_batch_stage_limit = strtoul(value.c_str(), nullptr, 10);
        }
        else if (name == "sweeplimit") {
            _stage_batch_times_limit = strtoul(value.c_str(), nullptr, 10);
        }
    }

    if (!_train_item) {
        log_error("no train item.");
        return false;
    }

    if (!_expup_item) {
        log_error("no expup item.");
        return false;
    }

    if (!_tech_acc_time) {
        log_error("no tech acc time.");
        return false;
    }
    if (!_tiger_item) {
        log_error("no tiger item.");
        return false;
    }
    if (!_tiger_times) {
        log_error("bad tiger times.");
        return false;
    }
    if (!_supplement_item) {
        log_error("bad supplement times.");
        return false;
    }
    if (!_shadow_grow_times) {
        log_error("bad shadow grow times.");
        return false;
    }
    if (!_challenge_item) {
        log_error("bad challenge item.");
        return false;
    }
    if (!_challenge_win_award) {
        log_error("bad challenge win award.");
        return false;
    }
    if (!_challenge_lose_award) {
        log_error("bad challenge lose award.");
        return false;
    }
    if (!_train_acc_time) {
        log_error("bad train acc time.");
        return false;
    }
    return true;
}



