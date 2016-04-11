#ifndef __GX_OBJECT_H__
#define __GX_OBJECT_H__

#include "platform.h"
#include "list.h"

#if GX_MT
#include <atomic>
#endif

#define GX_CHECK_OBJECT(T)                 \
    static_assert(                         \
        std::is_base_of<Object, T>::value, \
        "gx::Object must is the base class of " #T)

GX_NS_BEGIN

template <typename> class ptr;
template <typename> class weak_ptr;

class Object {
    template <typename> friend class object;
    template <typename> friend class ptr;
public:
    typedef size_t count_type;

public:
    Object() noexcept : _ref(0) { }
    Object(const Object &x) noexcept : _ref(0) { }
    Object(Object &&x) noexcept : _ref(0) { }

    virtual ~Object() noexcept {
        assert(!_ref.load());
    }

    std::size_t use_count() const {
        return _ref.load();
    }

    const Object &operator=(const Object &x) noexcept {
        return *this;
    }
    const Object &operator=(const Object &&x) noexcept {
        return *this;
    }
protected:
    ptr<Object> self() noexcept;
    ptr<const Object> self() const noexcept;
private:
    template <typename _T, typename ..._Args>
    static _T *create(_Args&&...args) noexcept {
        _T *obj = new _T(std::forward<_Args>(args)...);
        return obj;
    }

    void destroy() const noexcept {
        delete this;
    }

    void retain() const noexcept {
        _ref.fetch_add(1);
    }

    void release() const noexcept {
        size_t ref = _ref.fetch_sub(1);
        assert(ref > 0);
        if (ref == 1) {
            destroy();
        }
    }
private:
#if GX_MT
    typedef std::atomic<count_type> ref_type;
#else
    struct ref_type {
        ref_type(count_type init) : _count(init) { }

        count_type fetch_sub(count_type n) noexcept {
            count_type old = _count;
            _count -= n;
            return old;
        }
        count_type fetch_add(count_type n) noexcept {
            count_type old = _count;
            _count += n;
            return old;
        }
        void store(count_type n) noexcept {
            _count = n;
        }
        count_type load() noexcept {
            return _count;
        }
    private:
        count_type _count;
    };
#endif

private:
    mutable ref_type _ref;
};

class WeakableObject : public Object {
    template <typename> friend class weak_ptr;
public:
    struct weak_ptr_type {
        weak_ptr_type() noexcept : _ptr() { }
        ~weak_ptr_type() noexcept {
            deattch();
        }
        void attach(WeakableObject *obj) noexcept;
        void deattch() noexcept;
        void *_ptr;
        list_entry _entry;
    };
    typedef gx_list(weak_ptr_type, _entry) weak_list;
public:
    ~WeakableObject() noexcept {
        weak_ptr_type *ptr;
        while ((ptr = _weak_list.pop_front())) {
            ptr->_ptr = nullptr;
        }
    }
private:
    weak_list _weak_list;
};

inline void WeakableObject::weak_ptr_type::attach(WeakableObject *obj) noexcept {
    assert(!_ptr);
    if (obj) {
        _ptr = obj;
        obj->_weak_list.push_front(this);
    }
}

inline void WeakableObject::weak_ptr_type::deattch() noexcept {
    if (_ptr) {
        weak_list::remove(this);
        _ptr = nullptr;
    }
}

GX_NS_END

#endif

