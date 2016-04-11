#ifndef __GX_RBTREE_H__
#define __GX_RBTREE_H__

#include "platform.h"

GX_NS_BEGIN

class rbtree {
public:
    static constexpr const int red = 0;
    static constexpr const int black = 1;

    struct node {
        friend class rbtree;

        node *parent() const noexcept {
            return (node*)(_parent_color & ~3);
        }

        unsigned color() const noexcept {
            return _parent_color & 1;
        }

        bool is_red() const noexcept {
            return !(_parent_color & 1);
        }

        bool is_black() const noexcept {
            return _parent_color & 1;
        }

        void set_red() noexcept {
            _parent_color &= ~1;
        }

        void set_black() noexcept {
            _parent_color |= 1;
        }

        void set_parent(node *parent) noexcept {
            _parent_color = (_parent_color & 3) | (intptr_t)parent;
        }

        void set_color(int color) noexcept {
            _parent_color = (_parent_color & ~1) | color;
        }

        node *next() const noexcept{
            register const node *parent, *node;

            if (this->parent() == this) {
                return nullptr;
            }

            if ((node = _right)) {
                while (node->_left) {
                    node = node->_left;
                }
                return const_cast<struct node*>(node);
            }

            node = this;
            while ((parent = node->parent()) && node == parent->_right) {
                node = parent;
            }

            return const_cast<struct node*>(parent);
        }

        node *prev() const noexcept {
            register const node *parent, *node;

            if (this->parent() == node) {
                return nullptr;
            }

            if ((node = _left)) {
                while (node->_right) {
                    node = node->_right;
                }
                return const_cast<struct node*>(node);
            }

            node = this;
            while ((parent = node->parent()) && node == parent->_left) {
                node = parent;
            }

            return const_cast<struct node*>(parent);
        }

        intptr_t _parent_color;
        node *_right;
        node *_left;
    };

public:
    rbtree() : _root() {}

    bool empty() const noexcept {
        return !_root;
    }

    void clear()  noexcept {
        _root = nullptr;
    }

    node *root() const noexcept {
        return _root;
    }

    node *front() const noexcept {
        register node *node = _root;
        if (node) {
            while (node->_left) {
                node = node->_left;
            }
        }
        return node;
    }

    node *back() const noexcept {
        register node *node = _root;
        if (node) {
            while (node->_right) {
                node = node->_right;
            }
        }
        return node;
    }

    static void link(node *n, node *parent, node **link) {
        n->_parent_color = (intptr_t)parent;
        n->_left = n->_right = nullptr;
        *link = n;
    }

    void insert(node *n) noexcept;
    void remove(node *n) noexcept;
    void replace(node *victim, node *new_node) noexcept;

private:
    void rotate_left(register node *n) noexcept;
    void rotate_right(register node *n) noexcept;
    void erase_color(node *n, node *parent) noexcept;

protected:
    node *_root;
};

GX_NS_END


#endif

