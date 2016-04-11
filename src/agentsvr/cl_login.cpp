#include "agentsvr.h"

class CL_LoginServlet : public Servlet<CL_Login> {
public:
    virtual int execute(request_type *req, response_type *rsp) {
        G_Player *player = G_PlayerMgr::instance()->get_player(req->uid);
        if (!player) {
            return -1;
        }

        switch (player->state()) {
        case G_PLAYER_STATE_LOGIN_WAIT:
        case G_PLAYER_STATE_KEEP_SESSION:
            break;
        default:
            return -1;
        }

        if (req->key != player->session_key()) {
            return -1;
        }

        if (!player->login(G_AgentContext::instance())) {
            return -1;
        }

        if (!the_context()->peer()) {
            return -1;
        }

        timeval_t now = logic_time();


        rsp->name = player->name();
        rsp->side = player->side();
        auto instance = the_app->network()->instance(SERVLET_MAP_CLIENT, 0);
        rsp->map_host = instance.ap();
        rsp->map_port = instance.port();

        do {
            CL_NotifyItemsReq notify;
            for (auto &item : player->bag()->items()) {
                notify.items.emplace_back();
                auto &notify_item = notify.items.back();
                notify_item.id = item->id();
                notify_item.base = item->info()->id();
                notify_item.count = item->count();
                notify_item.used = item->used();
                notify_item.value = item->value();
            }
            send(notify);
        } while (0);

        do {
            CL_NotifyValuesReq notify;
            unsigned i = 0;
            for (auto &value : player->values().values()) {
                notify.values.emplace_back();
                auto &v = notify.values.back();
                v.id = i++;
                v.value = value;
            }

            i = G_TMP_VALUE_BEGIN;
            for (auto &value : player->values2().values()) {
                notify.values.emplace_back();
                auto &v = notify.values.back();
                v.id = i++;
                v.value = value;
            }

            send(notify);
        } while (0);

        do {
            CL_NotifyCooldownReq notify;
            for (unsigned i = 0; i < G_CD_UNKNOWN; ++i) {
                notify.cds.emplace_back();
                auto &cd = notify.cds.back();
                cd.id = i;
                cd.time = player->cooldown()->get(i);
            }
            send(notify);
        } while (0);
        do {
            CL_NotifyForgeReq notify;
            unsigned i = 0;
            for (auto &item : player->forge()->items()) {
                if (item.info()) {
                    notify.items.emplace_back();
                    auto &opt = notify.items.back();
                    opt.index = i;
                    opt.used = item.used();
                    opt.id = item.info()->id();
                }
                i++;
            }
            send(notify);
        } while (0);
        for (const G_Soldier *soldier : player->corps()->soldiers()) {
            CL_NotifySoldierValuesReq notify;
            notify.sid = soldier->id();
            unsigned i = 0;
            for (auto value : soldier->values().values()) {
                if (value) {
                    notify.values.emplace_back();
                    auto &v = notify.values.back();
                    v.id = i;
                    v.value = value;
                }
                i++;
            }
            send(notify);
        }
        do {
            CL_NotifyTrainReq notify;
            for (G_TrainLine *line : player->hero_train()->objects()) {
                notify.lines.emplace_back();
                auto &opt = notify.lines.back();
                opt.sid = line->id();
                timeval_t t = line->expire();
                opt.time = t > now ? t - now : 0;
                opt.type = line->info()->id();
            }
            for (G_TrainLine *line : player->soldier_train()->objects()) {
                notify.lines.emplace_back();
                auto &opt = notify.lines.back();
                opt.sid = line->id();
                timeval_t t = line->expire();
                opt.time = t > now ? t - now : 0;
                opt.type = line->info()->id();
            }
            send(notify);
        } while (0);
        do {
            CL_NotifyFormationReq notify;
            player->formations()->to_opt(notify.formations);
            send(notify);
        } while (0);
        do {
            CL_NotifyTechReq notify;
            player->tech()->to_opt(notify.techs);
            send(notify);
        } while (0);
        do {
            CL_NotifyTaskReq notify;
            player->task()->to_opt(notify.tasks);
            send(notify);
        } while (0);
        do {
            CL_NotifyFightReportReq notify;
            player->fight_report()->to_opt(notify.infos);
            send(notify);
        } while (0);
        return 0;
    }

    template <typename _Notify>
    void send(_Notify &notify) {
        if (this->dump_msg()) {
            notify.dump(nullptr, 0, the_context()->pool());
            the_context()->pool()->grow1('\0');
            log_debug("\n%s", (char*)the_context()->pool()->finish());
        }
        the_context()->peer()->send(_Notify::the_message_id, 0, &notify);
    }

};

GX_SERVLET_REGISTER(CL_LoginServlet, true);

