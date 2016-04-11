#include "award.h"
#include "player.h"

/* G_AwardMgr */
bool G_AwardMgr::init() {
    auto tab_info = the_app->script()->read_table("the_award_info");
    if (tab_info->is_nil()) {
        return false;
    }

    G_AwardInfo *info = nullptr;

    for (unsigned line = 1; ; ++line) {
        auto tab_item = tab_info->read_table(line);

        if (tab_item->is_nil()) {
            break;
        }

        int id = tab_item->read_integer("id", -1);
        int item_id = tab_item->read_integer("p1", -1);
        if (id <= 0 && item_id < 0) {
            continue;
        }

        if (id > 0) {
            info = probe_info(id);
            info->_min = tab_item->read_integer("min", 0);
            info->_max = tab_item->read_integer("max", 0);
            continue;
        }

        if (item_id < 0) {
            continue;
        }
        if (!info) {
            continue;
        }

        const G_ItemInfo *item_info = G_ItemMgr::instance()->get_info(item_id);
        if (!item_info) {
            log_error("unknown item id '%d'.", item_id);
            return false;
        }
        unsigned prob = tab_item->read_integer("c1", 0);
        object<G_AwardItemInfo> award_item_info;
        award_item_info->_info = item_info;
        award_item_info->_min = tab_item->read_integer("s1", 0);
        award_item_info->_max = tab_item->read_integer("l1", 0);

        if (!prob) {
            continue;
        }
        if (prob >= G_RAND_MAX) {
            info->_must.emplace_back(award_item_info);
            continue;
        }

        info->_probs.push(prob, award_item_info);
    }
    return true;
}

typedef std::map<const G_ItemInfo*, unsigned> award_result_t;
/* G_AwardInfo */
static inline void put_item(award_result_t &result, const G_ItemInfo *info, unsigned count) noexcept {
    result[info] += count;
}

static inline void put_item(G_Player *player, award_result_t &result, const G_AwardItemInfo *info) noexcept {
    put_item(result, info->info(), player->rand(info->min(), info->max()));
}

void G_AwardInfo::exec(G_Player *player, unsigned count, obstack_vector<G_AwardItem> *infos) const noexcept {
    award_result_t result;
    for (unsigned i = 0; i < count; ++i) {
        for (G_AwardItemInfo *item : _must) {
            put_item(player, result, item);
        }

        G_AwardItemInfo *info = _probs.get(player->rand());
        if (info) {
            put_item(player, result, info);
        }
    }

    for (auto it = result.begin(); it != result.end(); ++it) {
        const G_ItemInfo *info = it->first;
        unsigned count = it->second;
        if (infos) {
            infos->emplace_back();
            auto &item = infos->back();
            item.id = info->id();
            item.count = count;
        }
        switch (info->id()) {
        case G_ITEM_MONEY: 
            do {
                G_Money money;
                money.money = count;
                player->add_money(money);
            } while (0);
            break;
        case G_ITEM_COIN:
            do {
                G_Money money;
                money.coin = count;
                player->add_money(money);
            } while (0);
            break;
        case G_ITEM_EXP:
            player->add_exp(count);
            break;
        case G_ITEM_HONOR:
            do {
                G_Money money;
                money.honor = count;
                player->add_money(money);
            } while (0);
            break;
        case G_ITEM_RECRUIT:
            do {
                G_Money money;
                money.recruit = count;
                player->add_money(money);
            } while (0);
            break;
        case G_ITEM_MORDERS:
            do {
                player->add_morders(count);
            } while (0);
            break;
        default:
            player->bag()->put_item(info, count);
            break;
        }
    }

}

