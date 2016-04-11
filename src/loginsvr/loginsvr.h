#ifndef __LOGINSVR_H__
#define __LOGINSVR_H__

#include "libgame/global.h"
#include "loginsvr_msg.h"

template <typename _T>
class LS_Servlet : public Servlet<_T> {
public:
    typedef _T type;
    typedef typename _T::request_type request_type;
    typedef typename _T::response_type response_type;

    LS_Servlet() noexcept {
        this->short_link(true, the_linger_time);
    }
};

#endif

