#ifndef __GX_TYPES_H__
#define __GX_TYPES_H__

#include "platform.h"

GX_NS_BEGIN

template <typename _T>
struct member_of;

template <typename _Tx, typename _Ux>
struct member_of<_Tx _Ux::*> {
    typedef _Tx type;
    typedef _Ux class_type;
};

template <typename _Tx, typename _Cx>
inline constexpr unsigned offsetof_member(_Tx _Cx::*member) {
    static_assert(
        std::is_member_object_pointer<decltype(member)>::value,
        "offsetof_member only use for member object pointer.");
    return reinterpret_cast<uintptr_t>(&(((_Cx*)0)->*member));
};

template <typename _Tx, typename _Cx>
inline _Cx *containerof_member(_Tx *ptr, _Tx _Cx::*member) {
    return reinterpret_cast<_Cx*>(reinterpret_cast<char*>(ptr)-offsetof_member(member));
}

GX_NS_END

#endif

