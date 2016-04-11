#ifndef __GX_LIST_H__
#define __GX_LIST_H__


#include "platform.h"
#include "types.h"

GX_NS_BEGIN

#define __GX_LIST_OBJECT__(x)   static_cast<type*>(x)
#define __GX_LIST_VALUE__(x)    static_cast<value_type*>(x)
#define __GX_LIST_ENTRY__(x)    static_cast<entry_type&>(__GX_LIST_VALUE__(x)->*(__field))

enum class list_type {
    list,
    clist,
    slist,
    stlist,
    unknown,
};

template <
    typename _T, 
    typename _Ux,
    typename _Entry, 
    _Entry _Ux::*__field, 
    list_type __type = _Entry::type>
struct list {
    static_assert(__type >= list_type::list && __type < list_type::unknown, "unknown list type.");
};

/* list */
struct list_entry {
    static constexpr const list_type type = list_type::list;
    void *_next;
    void **_prev;
};

template <typename _T, typename _Ux, typename _Entry, _Entry _Ux::*__field> 
struct list<_T, _Ux, _Entry, __field, list_type::list> {
public:
    typedef _T type;
    typedef _Ux value_type;
    typedef _Entry entry_type;

public:
    class iterator {
    private:
        value_type *_ptr;
    public:
        iterator(value_type *ptr = nullptr) noexcept : _ptr(ptr) {}
        iterator(const iterator &x) noexcept : _ptr(x._ptr) {}

        iterator &operator=(const iterator &x) noexcept {
            _ptr = x._ptr;
            return *this;
        }

        type& operator*() noexcept {
            return *__GX_LIST_OBJECT__(_ptr);
        }

        type* operator->() noexcept {
            return __GX_LIST_OBJECT__(_ptr);
        }

        type* pointer() noexcept {
            return __GX_LIST_OBJECT__(_ptr);
        }

        iterator& operator++() noexcept {
            _ptr = __GX_LIST_VALUE__(__GX_LIST_ENTRY__(_ptr)._next);
            return *this;
        }

        iterator operator++(int) noexcept {
            iterator tmp(_ptr);
            _ptr = __GX_LIST_VALUE__(__GX_LIST_ENTRY__(_ptr)._next);
            return tmp;
        }

        bool operator==(const iterator &x) const noexcept {
            return _ptr == x._ptr;
        }

        bool operator!=(const iterator &x) const noexcept {
            return _ptr != x._ptr;
        }
    };
public:
    list() noexcept : _first() {}
    list(const list &x) = delete;
    list(list &&x) noexcept : _first() {
        swap(x);
    }

    void clear() noexcept {
        _first = nullptr;
    }

    void swap(list &x) {
        std::swap(_first, x._first);
    }

    list &operator=(const list &x) = delete;

    list &operator=(list &&x) noexcept {
        swap(x);
        return *this;
    }

    static type *insert_back(type *listelm, type *elm) noexcept {
        register entry_type &listed = __GX_LIST_ENTRY__(listelm);
        register entry_type &entry = __GX_LIST_ENTRY__(elm);

        if ((entry._next = listed._next) != nullptr) {
            __GX_LIST_ENTRY__(listed._next)._prev = &entry._next;
        }
        listed._next = elm;
        entry._prev = &listed._next;
        return elm;
    }

    static type *insert_front(type *listelm, type *elm) noexcept {
        register entry_type &listed = __GX_LIST_ENTRY__(listelm);
        register entry_type &entry = __GX_LIST_ENTRY__(elm);

        entry._prev = listed._prev;
        entry._next = listelm;
        *listed._prev = elm;
        listed._prev = &entry._next;

        return elm;
    }

    static type *remove(type *elm) noexcept {
        register entry_type &entry = __GX_LIST_ENTRY__(elm);

        if (entry._next != nullptr) {
            __GX_LIST_ENTRY__(entry._next)._prev = entry._prev;
        }
        *entry._prev = entry._next;
        return elm;
    }

    type *first() const noexcept {
        return _first ? __GX_LIST_OBJECT__(_first) : nullptr;
    }

    type *front() const noexcept {
        return _first ? __GX_LIST_OBJECT__(_first) : nullptr;
    }

    static type *next(type *elm) noexcept {
        void *p = __GX_LIST_ENTRY__(elm)._next;
        return p ? __GX_LIST_OBJECT__(__GX_LIST_VALUE__(p)) : nullptr;
    }

    bool empty() const noexcept {
        return !_first;
    }

    type *push_front(type *elm) noexcept {
        register entry_type &entry = __GX_LIST_ENTRY__(elm);
        if ((entry._next = _first) != nullptr) {
            __GX_LIST_ENTRY__(_first)._prev = &entry._next;
        }
        _first = elm;
        entry._prev = reinterpret_cast<void**>(&_first);
        return elm;
    }

    type *pop_front() noexcept {
        if (!_first) {
            return nullptr;
        }
        return remove(__GX_LIST_OBJECT__(_first));
    }

    iterator begin() noexcept {
        return iterator(_first);
    }

    const iterator begin() const noexcept {
        return iterator(_first);
    }

    iterator end() noexcept {
        return iterator(nullptr);
    }

    const iterator end() const noexcept {
        return iterator(nullptr);
    }
private:
    value_type *_first;
};

/* slist_entry */
struct slist_entry {
    static constexpr const list_type type = list_type::slist;
    void *_next;
};

template <typename _T, typename _Ux, typename _Entry, _Entry _Ux::*__field> 
struct list<_T, _Ux, _Entry, __field, list_type::slist> {
public:
    typedef _T type;
    typedef _Ux value_type;
    typedef _Entry entry_type;
public:
    class iterator {
    private:
        value_type *_ptr;
    public:
        iterator(value_type *ptr) noexcept : _ptr(ptr) {}
        iterator(const iterator &x) noexcept : _ptr(x._ptr) {}
        iterator &operator=(const iterator &x) noexcept {
            _ptr = x._ptr;
            return *this;
        }

        type& operator*() noexcept {
            return *__GX_LIST_OBJECT__(_ptr);
        }

        type* operator->() noexcept {
            return __GX_LIST_OBJECT__(_ptr);
        }

        type* pointer() noexcept {
            return __GX_LIST_OBJECT__(_ptr);
        }

        iterator& operator++() noexcept {
            _ptr = __GX_LIST_VALUE__(__GX_LIST_ENTRY__(_ptr)._next);
            return *this;
        }

        iterator operator++(int) noexcept {
            iterator tmp(_ptr);
            _ptr = __GX_LIST_VALUE__(__GX_LIST_ENTRY__(_ptr)._next);
            return tmp;
        }

        bool operator==(const iterator &x) const noexcept {
            return _ptr == x._ptr;
        }

        bool operator!=(const iterator &x) const noexcept {
            return _ptr != x._ptr;
        }
    };

public:
    list() noexcept : _first(nullptr) {}
    list(const list &x) = delete;
    list(list &&x) noexcept {
        swap(x);
    }

    void clear() noexcept {
        _first = nullptr;
    }

    list &operator=(const list &x) = delete;

    list &operator=(list &&x) noexcept {
        swap(x);
        return *this;
    }

    void swap(list &x) noexcept {
        std::swap(_first, x._first);
    }

    static type *insert_back(type *listelm, type *elm) noexcept {
        register entry_type &listed = __GX_LIST_ENTRY__(listelm);
        register entry_type &entry = __GX_LIST_ENTRY__(elm);

        entry._next = listed._next;
        listed._next = elm;
        return elm;
    }

    bool empty() const noexcept {
        return !_first;
    }

    type *first() const noexcept {
        return _first ? __GX_LIST_OBJECT__(_first) : nullptr;
    }

    type *front() const noexcept {
        return _first ? __GX_LIST_OBJECT__(_first) : nullptr;
    }

    static type *next(type *elm) noexcept {
        void *p = __GX_LIST_ENTRY__(elm)._next;
        return p ? __GX_LIST_OBJECT__(__GX_LIST_VALUE__(p)) : nullptr;
    }

    type *push_front(type *elm) noexcept {
        register entry_type &entry = __GX_LIST_ENTRY__(elm);

        entry._next = _first;
        _first = elm;
        return elm;
    }

    type *pop_front() noexcept {
        value_type *elm = _first;
        if (elm) {
            _first = __GX_LIST_VALUE__(__GX_LIST_ENTRY__(elm)._next);
            return __GX_LIST_OBJECT__(elm);
        }
        return nullptr;
    }

    type *remove(type *elm, type *prev) noexcept {
        if (!prev) {
            return pop_front();
        }
        else {
            register entry_type &entry = __GX_LIST_ENTRY__(prev);
            entry._next = __GX_LIST_ENTRY__(entry._next)._next;
            return elm;
        }
    }

    type *remove(type *_elm) noexcept {
        value_type *elm = __GX_LIST_VALUE__(_elm);
        if (_first == elm) {
            return pop_front();
        }
        else {
            value_type *curelm = _first;
            register entry_type *entry;
            while (curelm) {
                entry = &__GX_LIST_ENTRY__(curelm);
                if (entry->_next == elm) {
                    break;
                }
                curelm = __GX_LIST_VALUE__(entry->_next);
            }
            if (curelm) {
                entry->_next = __GX_LIST_ENTRY__(entry->_next)._next;
                return _elm;
            }
            return nullptr;
        }
    }

    iterator begin() noexcept {
        return iterator(_first);
    }

    const iterator begin() const noexcept {
        return iterator(_first);
    }

    iterator end() noexcept {
        return iterator(nullptr);
    }

    const iterator end() const noexcept {
        return iterator(nullptr);
    }
private:
    value_type *_first;
};

/* stlist */
struct stlist_entry {
    static constexpr const list_type type = list_type::stlist;
    void *_next;
};

template <typename _T, typename _Ux, typename _Entry, _Entry _Ux::*__field> 
struct list<_T, _Ux, _Entry, __field, list_type::stlist> {
public:
    typedef _T type;
    typedef _Ux value_type;
    typedef _Entry entry_type;

public:
    class iterator {
    private:
        value_type *_ptr;
    public:
        iterator(value_type *ptr) noexcept : _ptr(ptr) {}
        iterator(const iterator &x) noexcept : _ptr(x._ptr) {}
        iterator &operator=(const iterator &x) noexcept {
            _ptr = x._ptr;
            return *this;
        }

        type& operator*() noexcept {
            return *__GX_LIST_OBJECT__(_ptr);
        }

        type* operator->() noexcept {
            return __GX_LIST_OBJECT__(_ptr);
        }

        type* pointer() noexcept {
            return __GX_LIST_OBJECT__(_ptr);
        }

        iterator& operator++() noexcept {
            _ptr = __GX_LIST_VALUE__(__GX_LIST_ENTRY__(_ptr)._next);
            return *this;
        }

        iterator operator++(int) noexcept {
            iterator tmp(_ptr);
            _ptr = __GX_LIST_VALUE__(__GX_LIST_ENTRY__(_ptr)._next);
            return tmp;
        }

        bool operator==(const iterator &x) const noexcept {
            return _ptr == x._ptr;
        }

        bool operator!=(const iterator &x) const noexcept {
            return _ptr != x._ptr;
        }
    };
public:
    list() noexcept : _first(nullptr), _last(&_first) {}
    list(const list &) = delete;
    list(list &&x) noexcept {
        swap(x);
    }

    list &operator=(const list&) = delete;
    
    list &operator=(list &&x) noexcept {
        swap(x);
        return *this;
    }

    void clear() noexcept {
        _first = nullptr;
        _last = &_first;
    }

    void swap(list &x) noexcept {
        std::swap(_first, x._first);
        std::swap(_last, x._last);
        if (!_first) {
            _last = &_first;
        }
        if (!x._first) {
            x._last = &x._first;
        }
    }

    bool empty() const noexcept {
        return !_first;
    }

    type *first() const noexcept {
        return _first ? __GX_LIST_OBJECT__(_first) : nullptr;
    }

    type *front() const noexcept {
        return _first ? __GX_LIST_OBJECT__(_first) : nullptr;
    }

    static type *next(type *elm) noexcept {
        void *p = __GX_LIST_ENTRY__(elm)._next;
        return p ? __GX_LIST_OBJECT__(__GX_LIST_VALUE__(p)) : nullptr;
    }

    type *push_front(type *elm) noexcept {
        register entry_type &entry = __GX_LIST_ENTRY__(elm);

        if ((entry._next = _first) == nullptr) {
            _last = reinterpret_cast<value_type**>(&entry._next);
        }
        _first = __GX_LIST_VALUE__(elm);
        return elm;
    }

    type *push_back(type *elm) noexcept {
        register entry_type &entry = __GX_LIST_ENTRY__(elm);

        entry._next = nullptr;
        *_last = __GX_LIST_VALUE__(elm);
        _last = reinterpret_cast<value_type**>(&entry._next);

        return elm;
    }

    type* pop_front() noexcept {
        value_type* elm = _first;
        if (elm) {
            if ((_first = __GX_LIST_VALUE__(__GX_LIST_ENTRY__(elm)._next)) == nullptr) {
                _last = &_first;
            }
            return __GX_LIST_OBJECT__(elm);
        }
        return nullptr;
    }

    type *insert_back(type *listelm, type *elm) noexcept {
        register entry_type &listed = __GX_LIST_ENTRY__(listelm);
        register entry_type &entry = __GX_LIST_ENTRY__(elm);

        if ((entry._next = listed._next) == nullptr) {
            _last = &entry._next;
        }
        listed._next = __GX_LIST_VALUE__(elm);
        return elm;
    }

    type *remove(type *elm, type *prev) noexcept {
        if (!prev) {
            return pop_front();
        } 
        else {
            register entry_type &entry = __GX_LIST_ENTRY__(prev);
            if ((entry._next = __GX_LIST_ENTRY__(entry._next)._next) == nullptr) {
                _last = reinterpret_cast<value_type**>(&entry._next);
            }
            return elm;
        }
    }

    type *remove(type *_elm) noexcept {
        value_type *elm = __GX_LIST_VALUE__(_elm);
        if (_first == elm) {
            return pop_front();
        } 
        else {
            value_type *curelm = _first;
            register entry_type *entry;
            while (curelm) {
                entry = &__GX_LIST_ENTRY__(curelm);
                if (entry->_next == elm) {
                    break;
                }
                curelm = __GX_LIST_OBJECT__(entry->_next);
            }
            if (curelm) {
                if (!(entry->_next = __GX_LIST_ENTRY__(entry->_next)._next)) {
                    _last = reinterpret_cast<value_type**>(&entry->_next);
                }
                return _elm;
            }
            return nullptr;
        }
    }

    iterator begin() noexcept {
        return iterator(_first);
    }

    const iterator begin() const noexcept {
        return iterator(_first);
    }

    iterator end() noexcept {
        return iterator(nullptr);
    }

    const iterator end() const noexcept {
        return iterator(nullptr);
    }
private:
    value_type *_first;
    value_type **_last;
};

/* clist */
struct clist_entry {
    static constexpr const list_type type = list_type::clist;
    clist_entry() noexcept { }
    clist_entry(clist_entry *next, clist_entry *prev) noexcept : _next(next), _prev(prev) { }
    clist_entry(clist_entry *next) noexcept : _next(next) {}
    
    void remove() noexcept {
        _next->_prev = _prev;
        _prev->_next = _next;
    }

    void insert_back(clist_entry *listed) noexcept {
        _next = listed->_next;
        _prev = listed;
        listed->_next->_prev = this;
        listed->_next = this;
    }

    void insert_front(clist_entry *listed) noexcept {
        _next = listed;
        _prev = listed->_prev;
        listed->_prev->_next = this;
        listed->_prev = this;
    }

    clist_entry *_next;
    clist_entry *_prev;
};

#define __GX_CLIST_VALUE__(entry) containerof_member(entry, __field)

template <typename _T, typename _Ux, typename _Entry, _Entry _Ux::*__field> 
struct list<_T, _Ux, _Entry, __field, list_type::clist> : protected clist_entry {
public:
    typedef _T type;
    typedef _Ux value_type;
    typedef _Entry entry_type;
public:
    class iterator {
    private:
        entry_type *_entry;
    public:
        iterator(entry_type *entry) noexcept : _entry(entry) {}
        iterator(const iterator &x) noexcept : _entry(x._entry) {}

        iterator &operator=(const iterator &x) noexcept {
            _entry = x._entry;
            return *this;
        }

        type& operator*() noexcept {
            return *__GX_LIST_OBJECT__(__GX_CLIST_VALUE__(_entry));
        }

        type* operator->() noexcept {
            return __GX_LIST_OBJECT__(__GX_CLIST_VALUE__(_entry));
        }

        type* pointer() noexcept {
            return __GX_LIST_OBJECT__(__GX_CLIST_VALUE__(_entry));
        }

        iterator& operator++() noexcept {
            _entry = _entry->_next;
            return *this;
        }

        iterator operator++(int) noexcept {
            iterator tmp(_entry);
            _entry = _entry->_next;
            return tmp;
        }

        iterator& operator--() noexcept {
            _entry = _entry->_prev;
            return *this;
        }

        iterator operator--(int) noexcept {
            iterator tmp(_entry);
            _entry = _entry->_prev;
            return tmp;
        }

        bool operator==(const iterator &x) const noexcept {
            return _entry == x._entry;
        }

        bool operator!=(const iterator &x) const noexcept {
            return _entry != x._entry;
        }
    };

    
    class reverse_iterator {
    private:
        entry_type *_entry;
    public:
        reverse_iterator(entry_type *entry) noexcept : _entry(entry) {}
        reverse_iterator(const iterator &x) noexcept : _entry(x._entry) {}

        reverse_iterator &operator=(const reverse_iterator &x) noexcept {
            _entry = x._entry;
            return *this;
        }

        type& operator*() noexcept {
            return *__GX_LIST_OBJECT__(__GX_CLIST_VALUE__(_entry));
        }

        type* operator->() noexcept {
            return __GX_LIST_OBJECT__(__GX_CLIST_VALUE__(_entry));
        }

        type* pointer() noexcept {
            return __GX_LIST_OBJECT__(__GX_CLIST_VALUE__(_entry));
        }

        reverse_iterator& operator++() noexcept {
            _entry = _entry->_prev;
            return *this;
        }

        reverse_iterator operator++(int) noexcept {
            iterator tmp(_entry);
            _entry = _entry->_prev;
            return tmp;
        }

        reverse_iterator& operator--() noexcept {
            _entry = _entry->_next;
            return *this;
        }

        reverse_iterator operator--(int) noexcept {
            iterator tmp(_entry);
            _entry = _entry->_next;
            return tmp;
        }

        bool operator==(const reverse_iterator &x) const noexcept {
            return _entry == x._entry;
        }

        bool operator!=(const reverse_iterator &x) const noexcept {
            return _entry != x._entry;
        }
    };

public:
    list() noexcept : clist_entry(this, this) {}
    list(const list &x) = delete;
    list(list &&x) noexcept : clist_entry(this, this) {
        swap(x);
    }

    list &operator=(const list&) = delete;

    list &operator=(list &&x) noexcept {
        swap(x);
        return *this;
    }

    void clear() noexcept {
        _next = this;
        _prev = this;
    }

    void swap(list &x) noexcept {
        if (x.empty()) {
            if (!empty()) {
                x._next = _next;
                x._prev = _prev;
                x._next->_prev = x._prev->_next = std::addressof(x);
                clear();
            }
        }
        else {
            if (empty()) {
                _next = x._next; 
                _prev = x._prev;
                _next->_prev = _prev->_next = this;
                x.clear();
            }
            else {
                std::swap(_next, x._next);
                std::swap(_prev, x._prev);
                x._next->_prev = x._prev->_next = std::addressof(x);
                _next->_prev = _prev->_next = this;
            }
        }
    }

    static type *insert_back(type *listelm, type *elm) noexcept {
        register entry_type *listed = &__GX_LIST_ENTRY__(listelm);
        register entry_type *entry = &__GX_LIST_ENTRY__(elm);
        entry->insert_back(listed);
        return elm;
    }

    static type *insert_front(type *listelm, type *elm) noexcept {
        register entry_type *listed = &__GX_LIST_ENTRY__(listelm);
        register entry_type *entry = &__GX_LIST_ENTRY__(elm);
        entry->insert_front(listed);
        return elm;
    }

    static type *remove(type *elm) noexcept {
        register entry_type *entry = &__GX_LIST_ENTRY__(elm);
        entry->remove();
        return elm;
    }

    type *push_front(type *elm) noexcept {
        register entry_type *entry = &__GX_LIST_ENTRY__(elm);
        entry->insert_back(this);
        return elm;
    }

    type *push_back(type *elm) noexcept {
        register entry_type *entry = &__GX_LIST_ENTRY__(elm);
        entry->insert_front(this);
        return elm;
    }

    type *pop_front() noexcept {
        register entry_type *entry = _next;
        if (entry == this) {
            return nullptr;
        }
        else {
            entry->remove();
            return __GX_LIST_OBJECT__(__GX_CLIST_VALUE__(entry));
        }
    }

    type *pop_back() noexcept {
        register entry_type *entry = _prev;
        if (entry == this) {
            return nullptr;
        }
        else {
            entry->remove();
            return __GX_LIST_OBJECT__(__GX_CLIST_VALUE__(entry));
        }
    }

    type *first() noexcept {
        return _next == this ? nullptr : __GX_LIST_OBJECT__(__GX_CLIST_VALUE__(_next));
    }

    value_type *last() noexcept {
        return _prev == this ? nullptr : __GX_LIST_OBJECT__(__GX_CLIST_VALUE__(_prev));
    }

    value_type *front() noexcept {
        return _next == this ? nullptr : __GX_LIST_OBJECT__(__GX_CLIST_VALUE__(_next));
    }

    value_type *back() noexcept {
        return _prev == this ? nullptr : __GX_LIST_OBJECT__(__GX_CLIST_VALUE__(_prev));
    }

    bool empty() const noexcept {
        return _prev == this;
    }

    iterator begin() noexcept {
        return iterator(_next);
    }

    const iterator begin() const noexcept {
        return iterator(_next);
    }

    iterator end() noexcept {
        return iterator(this);
    }

    const iterator end() const noexcept {
        return iterator(const_cast<entry_type*>(static_cast<const clist_entry*>(this)));
    }

    reverse_iterator rbegin() noexcept {
        return reverse_iterator(_prev);
    }

    const reverse_iterator rbegin() const noexcept {
        return reverse_iterator(_prev);
    }

    reverse_iterator rend() noexcept {
        return reverse_iterator(this);
    }

    const reverse_iterator rend() const noexcept {
        return reverse_iterator(this);
    }
};

GX_NS_END

#define gx_list(_Tx, entry) GX_NS::list<                          \
    _Tx,                                                          \
    typename GX_NS::member_of<decltype(&_Tx::entry)>::class_type, \
    typename GX_NS::member_of<decltype(&_Tx::entry)>::type,       \
    &_Tx::entry>



#endif

