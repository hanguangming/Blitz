#ifndef __GX_ALLOCATOR_H__
#define __GX_ALLOCATOR_H__

#include <vector>
#include <string>
#include <map>

#include "platform.h"
#include "memory.h"
#include "obstack.h"

GX_NS_BEGIN

template <typename _T, typename _Pool>
class object_cache {
public:
    typedef _T type;
    typedef _Pool pool_type;
    static constexpr const int object_size = gx_align_default(sizeof(type));

private:
    struct node {
        node *_next;
    };
public:
    object_cache(ptr<pool_type> pool) noexcept : _pool(pool), _list() { }

    template <typename ..._Args>
    type* construct(_Args&&...args) noexcept {
        void *p;
        if (_list) {
            p = _list;
            _list = _list->_next;
        }
        else {
            p = _pool->alloc(object_size);
        }
        return new(p) type(std::forward<_Args>(args)...);
    };

    void destroy(type *obj) noexcept {
        obj->~type();
        node *p = reinterpret_cast<node*>(obj);
        p->_next = _list;
        _list = p;
    }
private:
    ptr<pool_type> _pool;
    node *_list;
};

template <typename _Tp>
class obstack_allocator {
    template <typename> friend class obstack_allocator;
    template <typename, typename, typename> friend class std::basic_string;
public:
      typedef size_t     size_type;
      typedef ptrdiff_t  difference_type;
      typedef _Tp*       pointer;
      typedef const _Tp* const_pointer;
      typedef _Tp&       reference;
      typedef const _Tp& const_reference;
      typedef _Tp        value_type;

      template<typename _Tp1>
      struct rebind { 
          typedef obstack_allocator<_Tp1> other; 
      };

      obstack_allocator(Obstack *pool) noexcept
      : _pool(pool)
      { }

      obstack_allocator(const obstack_allocator &other) noexcept
      : _pool(other._pool)
      { }

      template<typename _Tp1>
      obstack_allocator(const obstack_allocator<_Tp1> &other) noexcept
      : _pool(other._pool) 
      { }

      pointer address(reference __x) const noexcept { 
          return std::__addressof(__x); 
      }

      const_pointer address(const_reference __x) const noexcept { 
          return std::__addressof(__x); 
      }

      pointer allocate(size_type __n, const void* = 0) {
          return static_cast<_Tp*>(_pool->alloc(__n * sizeof(_Tp)));
      }

      void deallocate(pointer __p, size_type) { 
      }

      size_type max_size() const noexcept { 
          return size_t(-1) / sizeof(_Tp); 
      }

      template<typename _Up, typename... _Args>
      void construct(_Up* __p, _Args&&... __args) { 
          ::new((void *)__p) _Up(std::forward<_Args>(__args)...); 
      }

      template<typename _Up>
      void destroy(_Up* __p) {
           __p->~_Up(); 
      }

      bool operator==(const obstack_allocator &rhs) const noexcept {
          return _pool == rhs._pool;
      }

      bool operator!=(const obstack_allocator &rhs) const noexcept {
          return _pool != rhs._pool;
      }
      Obstack *pool() const noexcept {
          return _pool;
      }
private:
    obstack_allocator() noexcept : _pool() { }

private:
    Obstack *_pool;
};

template <typename _Key, typename _T, typename _Compare = std::less<_Key>>
struct obstack_map : std::map<_Key, _T, _Compare, obstack_allocator<std::pair<const _Key, _T>>> {
    typedef typename std::map<_Key, _T, _Compare, obstack_allocator<std::pair<const _Key, _T>>> base_type;
    typedef typename base_type::allocator_type allocator_type;
    using base_type::base_type;

    obstack_map(Obstack *pool) noexcept : base_type(_Compare(), allocator_type(pool)) { }
};

template <typename _Tp>
struct obstack_vector : std::vector<_Tp, obstack_allocator<_Tp>> {
    typedef typename std::vector<_Tp, obstack_allocator<_Tp>> base_type;
    typedef typename base_type::allocator_type allocator_type;

    using base_type::base_type;
    using base_type::begin;
    using base_type::end;

    void emplace_back() noexcept {
        do_emplace<_Tp>(this);
    }

    const std::vector<_Tp> &operator=(const std::vector<_Tp> &rhs) noexcept {
        *this = obstack_vector(rhs.begin(), rhs.end(), base_type::get_allocator());
        return rhs;
    }

    operator std::vector<_Tp>() const noexcept {
        return std::vector<_Tp>(base_type::begin(), base_type::end());
    }
private:
    template <typename _T1>
    static typename std::enable_if<
        std::is_class<_T1>::value, 
        void>::type
    do_emplace(obstack_vector<_Tp> *vec) noexcept {
        vec->base_type::emplace_back(vec->get_allocator().pool());
    }

    template <typename _T1>
    static typename std::enable_if<
        !std::is_class<_T1>::value, 
        void>::type
    do_emplace(obstack_vector<_Tp> *vec) noexcept {
        vec->base_type::emplace_back();
    }
};

struct obstack_string : std::basic_string<char, std::char_traits<char>, gx::obstack_allocator<char>> {
    typedef std::basic_string<char, std::char_traits<char>, gx::obstack_allocator<char>> base_type;
    using base_type::operator=;
    using base_type::base_type;

    const obstack_string &operator=(const std::string &rhs) noexcept {
        *this = obstack_string(rhs.c_str(), rhs.size(), get_allocator());
        return *this;
    }

    operator std::string() const noexcept {
        return std::string(c_str(), size());
    }
};

inline bool operator==(const obstack_string &lhs, const std::string &rhs) noexcept {
    if (lhs.size() != rhs.size()) {
        return false;
    }
    return memcmp(lhs.c_str(), rhs.c_str(), lhs.size());
}

inline bool operator==(const std::string lhs, const obstack_string &rhs) noexcept {
    return rhs == lhs;
}

inline bool operator!=(const obstack_string &lhs, const std::string &rhs) noexcept {
    return !(lhs == rhs);
};

inline bool operator!=(const std::string lhs, const obstack_string &rhs) noexcept {
    return !(lhs == rhs);
};

GX_NS_END

#endif

