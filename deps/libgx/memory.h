#ifndef __GX_MEMORY_H__
#define __GX_MEMORY_H__

#include "platform.h"
#include "object.h"
#include <cstdio>
GX_NS_BEGIN

template <typename _T>
class ptr {
    template<typename> friend class ptr;
    template<typename> friend class object;
    friend class Object;
public:
    typedef _T type;

public:
    ptr() noexcept : _ptr()
    { }
    ptr(nullptr_t) noexcept : _ptr()
    { }
    template <typename _Tx>
    ptr(const ptr<_Tx> &x) noexcept : _ptr() {
        assign(x);
    }
    ptr(const ptr &x) noexcept : _ptr(x._ptr) {
        if (_ptr) {
            _ptr->retain();
        }
    }
    ptr(ptr &&x) noexcept : _ptr() {
        swap(x);
    }
    ~ptr() noexcept {
        GX_CHECK_OBJECT(_T);
        if (_ptr){
            auto tmp = _ptr;
            _ptr = nullptr;
            tmp->release();
        }
    }
    template <typename _Tx>
    void assign(const ptr<_Tx> &x) noexcept {
        assign(x._ptr);
    }
    void swap(ptr &x) noexcept {
        std::swap(_ptr, x._ptr);
    }
    template <typename _Tx>
    ptr &operator=(const ptr<_Tx> &x) noexcept {
        assign(x);
        return *this;
    }
    ptr &operator=(const ptr &x) noexcept {
        assign(x);
        return *this;
    }
    ptr &operator=(ptr &&x) noexcept {
        swap(x);
        return *this;
    }
    ptr &operator=(nullptr_t) noexcept {
        if (_ptr) {
            _ptr->release();
            _ptr = nullptr;
        }
        return *this;
    }
    type *operator->() const noexcept {
        return _ptr;
    }
    operator type*() const noexcept {
        return _ptr;
    }
    type &operator *() const noexcept {
        return *_ptr;
    }
    type *get() const noexcept {
        return _ptr;
    }
    template <typename _Tx>
    inline ptr<_Tx> cast() const noexcept {
        if (!_ptr) {
            return ptr<_Tx>();
        }
        return ptr<_Tx>(static_cast<_Tx*>(_ptr));
    }
private:
    ptr(type *x) noexcept : _ptr(x) {
        assert(x);
        _ptr->retain();
    }
    template <typename _Tx>
    void assign(_Tx *x) noexcept {
        GX_CHECK_OBJECT(_Tx);
        static_assert(std::is_base_of<_T, _Tx>::value, "lhs must is base of rhs.");

        if (_ptr == x) {
            return;
        }
        if (_ptr) {
            _ptr->release();
            _ptr = nullptr;
        }
        if (x) {
            _ptr = static_cast<type*>(x);
            _ptr->retain();
        }
    }

    static void *operator new(std::size_t) {
        return nullptr;
    }
    static void *operator new (std::size_t, void*) {
        return nullptr;
    }
    static void *operator new[] (std::size_t) {
        return nullptr;
    }
    static void *operator new[] (std::size_t, void*) {
        return nullptr;
    }
private:
    type *_ptr;
};

template <typename _T1, typename _T2>
inline bool operator==(const ptr<_T1> &lhs, const ptr<_T2> &rhs) noexcept {
    return lhs.get() == rhs.get();
}

template <typename _T1, typename _T2>
inline bool operator==(const ptr<_T1> &lhs, const _T2 *rhs) noexcept {
    GX_CHECK_OBJECT(_T2);
    return lhs.get() == rhs;
}

template <typename _T1, typename _T2>
inline bool operator==(_T1 *lhs, const ptr<_T2> &rhs) noexcept {
    GX_CHECK_OBJECT(_T1);
    return lhs == rhs.get();
}


template <typename _T>
class object final : public ptr<_T> {
public:
    typedef ptr<_T> base;

    template <typename ..._Args>
    object(_Args&&...args) noexcept
    : base(Object::create<_T>(std::forward<_Args>(args)...))
    { }

private:
    static void *operator new(std::size_t) {
        return nullptr;
    }
    static void *operator new (std::size_t, void*) {
        return nullptr;
    }
    static void *operator new[] (std::size_t) {
        return nullptr;
    }
    static void *operator new[] (std::size_t, void*) {
        return nullptr;
    }
};

inline ptr<Object> Object::self() noexcept {
    assert(_ref.load() > 0);
    return ptr<Object>(this);
}

inline ptr<const Object> Object::self() const noexcept {
    assert(_ref.load() > 0);
    return ptr<const Object>(this);
}

template <typename _T>
class weak_ptr final : protected WeakableObject::weak_ptr_type {
public:
    typedef _T type;
    typedef WeakableObject::weak_ptr_type base;
public:
    weak_ptr() noexcept : base()
    { }
    weak_ptr(nullptr_t) noexcept : base()
    { }
    weak_ptr(const weak_ptr &x) noexcept : base() {
        if (x._ptr) {
            attach(x.get());
        }
    }
    weak_ptr(ptr<type> x) noexcept : base() {
        attach(x.get());
    }
    weak_ptr(weak_ptr&&) = delete;

    type *get() const noexcept {
        if (!_ptr) {
            return nullptr;
        }
        return static_cast<type*>(_ptr) ;
    }

    weak_ptr &operator=(const weak_ptr &x) noexcept {
        deattch();
        attach(x.get());
        return *this;
    }
    weak_ptr &operator=(type *x) noexcept {
        deattch();
        attach(x);
        return *this;
    }
    weak_ptr &operator=(weak_ptr &&x) = delete;

    type *operator->() const noexcept {
        return get();
    }
    operator type*() const noexcept {
        return get();
    }
    type &operator *() const noexcept {
        return *get();
    }
private:
    static void *operator new(std::size_t) {
        return nullptr;
    }
    static void *operator new (std::size_t, void*) {
        return nullptr;
    }
    static void *operator new[] (std::size_t) {
        return nullptr;
    }
    static void *operator new[] (std::size_t, void*) {
        return nullptr;
    }
};

GX_NS_END

#endif

