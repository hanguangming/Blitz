#ifndef __LIBGAME_FORMATION_H__
#define __LIBGAME_FORMATION_H__

#include "object.h"
#include "soldier.h"
#include "libgame/g_defines.h"
#include "libgame/g_formation.h"
#include "fight.h"

class G_FormationItem : public G_Object<unsigned, G_SoldierInfo> {
    friend class G_Formation;
public:
    G_FormationItem() noexcept : _soldier(), _x(), _y() { }
    const G_SoldierInfo *soldier() const noexcept {
        return _soldier;
    }
    int x() const noexcept {
        return _x;
    }
    int y() const noexcept {
        return _y;
    }
private:
    const G_SoldierInfo *_soldier;
    int _x;
    int _y;
};

class G_Formation : public G_ObjectContainer<G_FormationItem> {
    friend class G_Formations;
    friend class G_Corps;
public:
    G_Formation(unsigned id) noexcept : _id(id) { }
    using G_ObjectContainer<G_FormationItem>::objects;
private:
    bool init(G_Player *player, const obstack_vector<G_FormationItemOpt> &opts, bool igorn_error) noexcept;
    void change_soldier(const G_SoldierInfo *old_info, const G_SoldierInfo *new_info) noexcept;
    void remove_soldier(const G_SoldierInfo *info) noexcept;
    void to_opt(G_FormationOpt &opt) noexcept;
private:
    unsigned _id;
};

class G_Formations : public Object {
public:
    G_Formation *formation(unsigned index) noexcept {
        assert(index < G_FORMATION_NUM);
        return _formations[index];
    }

    bool init(G_Player *player, const obstack_vector<G_FormationOpt> &opts, bool igorn_error) noexcept;
    void change_soldier(const G_SoldierInfo *old_info, const G_SoldierInfo *new_info) noexcept;
    void remove_soldier(const G_SoldierInfo *info) noexcept;
    void to_opt(obstack_vector<G_FormationOpt> &opts) noexcept;
private:
    ptr<G_Formation> _formations[G_FORMATION_NUM];
};

#endif

