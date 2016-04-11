#ifndef __LIBGAME_TRAIN_H__
#define __LIBGAME_TRAIN_H__

#include "object.h"
#include "soldier.h"
#include "libgame/g_train.h"
#include "timer.h"

class G_Train;
class G_Soldier;

class G_TrainInfo : public G_ObjectInfo {
    friend class G_TrainMgr;
    friend class G_Train;
private:
    timeval_t _time;
};

class G_TrainMgr : public G_ObjectInfoContainer<G_TrainInfo>, public singleton<G_TrainMgr> {
public:
    using G_ObjectInfoContainer<G_TrainInfo>::get_info;
    bool init();
};

class G_TrainLine : public G_Object<unsigned, G_TrainInfo>, public G_TimerObject {
    friend class G_Train;
public:
    G_TrainLine() noexcept : _train() { }

protected:
    timeval_t timer_handler(timeval_t now) override;
private:
    G_Train *_train;
};

class G_Train : public G_ObjectContainer<G_TrainLine> {
    friend class G_TrainLine;
public:
    using G_ObjectContainer<G_TrainLine>::objects;

    ptr<G_TrainLine> cancel(unsigned soldier_id);
    bool add(unsigned soldier_id, const G_TrainInfo *info);
    ptr<G_TrainLine> remove(unsigned soldier_id);
    unsigned count() const noexcept {
        return objects().size();
    }
    void init(G_Player *player, G_Soldier *soldier, const G_TrainInfo *info, timeval_t expire) noexcept;

};


#endif

