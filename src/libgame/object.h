#ifndef __LIBGAME_OBJECT_H__
#define __LIBGAME_OBJECT_H__

#include <map>
#include <set>
#include <vector>

#include "game.h"
#include "libgame/g_defines.h"

class G_ObjectInfo : public Object {
    template <typename> friend class G_ObjectInfoContainer;
public:
    G_ObjectInfo() noexcept : _id() { }
    uint64_t id() const noexcept {
        return _id;
    }

private:
    uint64_t _id;
};

template <typename _T>
class G_ObjectInfoContainer : public Object {
public:
    typedef _T info_type;

protected:
    template <typename ..._Args>
    info_type *probe_info(uint64_t id, _Args&&...args) noexcept {
        auto r = _infos.emplace(id, nullptr);
        if (!r.second) {
            return r.first->second;
        }

        object<info_type> info(std::forward<_Args>(args)...);
        r.first->second = info;
        info->_id = id;
        return info;
    }

    const info_type *get_info(uint64_t id) const noexcept {
        auto it = _infos.find(id);
        if (it == _infos.end()) {
            return nullptr;
        }
        return it->second;
    }

protected:
    std::map<uint64_t, ptr<info_type>> _infos;
};

template <typename _Id, typename _Info>
class G_Object : public Object {
    template <typename, typename> friend class G_ObjectContainer;
public:
    G_Object() noexcept : _info(), _id() { }
    G_Object(const G_Object &x) noexcept : _info(x._info), _id(x._id) { }

    typedef _Id id_type;
    typedef _Info info_type;

    id_type id() const noexcept {
        return _id;
    }

    const info_type *info() const noexcept {
        return _info;
    }
protected:
    const info_type *_info;

private:
    id_type _id;
};

template <typename _T, typename _OptMgr = void>
class G_ObjectContainer : public Object {
public:
    typedef _T                      object_type;
    typedef typename _T::id_type    id_type;
    typedef typename _T::info_type  info_type;
protected:
    object_type *probe_object(id_type id, const info_type *info, _OptMgr *om = nullptr) noexcept {
        static object<object_type> tmp;
        assert(id && info);

        tmp->_id = id;
        auto r = _objects.emplace(tmp);
        if (!r.second) {
            assert((*r.first)->_id == id && (*r.first)->_info == info);
            return *r.first;
        }

        object<object_type> obj;
        obj->_id = id;
        obj->_info = info;
        const_cast<ptr<object_type>&>(*r.first) = obj;
        push_opt(G_OPT_INSERT, obj, om);
        return obj;
    }

    ptr<object_type> get_object(id_type id) noexcept {
        static object<object_type> tmp;
        tmp->_id = id;

        auto it = _objects.find(tmp);
        if (it == _objects.end()) {
            return nullptr;
        }
        return *it;  
    }

    ptr<object_type> remove_object(id_type id, _OptMgr *om = nullptr) noexcept {
        static object<object_type> tmp;
        tmp->_id = id;

        auto it = _objects.find(tmp);
        if (it == _objects.end()) {
            return nullptr;
        }

        ptr<object_type> obj = *it;
        _objects.erase(it);
        push_opt(G_OPT_REMOVE, obj, om);
        return obj;
    }
private:
    template <typename _Mgr = _OptMgr>
    typename std::enable_if<
        std::is_void<_Mgr>::value,
        void>::type
    push_opt(int type, ptr<object_type> obj, _Mgr *mgr) noexcept {
    }

    template <typename _Mgr = _OptMgr>
    typename std::enable_if<
        !std::is_void<_Mgr>::value,
        void>::type
    push_opt(int type, ptr<object_type> obj, _Mgr *mgr) noexcept {
        if (mgr) {
            mgr->push(type, obj);
        }
    }
private:
    struct cmp {
        bool operator()(const object_type *lhs, const object_type *rhs) const noexcept {
            return lhs->_id < rhs->_id;
        }
    };
protected:
    typedef std::set<ptr<object_type>, cmp> container_type;

    const container_type &objects() const noexcept {
        return _objects;
    }

private:
    container_type _objects;
};

#endif

