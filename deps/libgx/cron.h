#ifndef __GX_CRON_H__
#define __GX_CRON_H__

#include "platform.h"
#include "memory.h"
#include "bitstr.h"

GX_NS_BEGIN

class Cron : public Object {
public:
    static constexpr const unsigned	FIRST_MINUTE    = 0;
    static constexpr const unsigned	LAST_MINUTE     = 59;
    static constexpr const unsigned	MINUTE_COUNT    = (LAST_MINUTE - FIRST_MINUTE + 1);
    static constexpr const unsigned	FIRST_HOUR      = 0;
    static constexpr const unsigned	LAST_HOUR       = 23;
    static constexpr const unsigned	HOUR_COUNT      = (LAST_HOUR - FIRST_HOUR + 1);
    static constexpr const unsigned	FIRST_DOM       = 1;
    static constexpr const unsigned	LAST_DOM        = 31;
    static constexpr const unsigned	DOM_COUNT       = (LAST_DOM - FIRST_DOM + 1);
    static constexpr const unsigned	FIRST_MONTH     = 1;
    static constexpr const unsigned	LAST_MONTH      = 12;
    static constexpr const unsigned	MONTH_COUNT     = (LAST_MONTH - FIRST_MONTH + 1);
    static constexpr const unsigned	FIRST_DOW       = 0;
    static constexpr const unsigned	LAST_DOW        = 7;
    static constexpr const unsigned	DOW_COUNT       = (LAST_DOW - FIRST_DOW + 1);
    typedef void (*job_handler_t)();
    bool add_job(
        const char *month, 
        const char *day, 
        const char *week, 
        const char *hour, 
        const char *minute,
        const std::function<job_handler_t> &handler) noexcept;

private:
    bitstr<MINUTE_COUNT> _minute;
    bitstr<HOUR_COUNT> _hour;
    bitstr<DOM_COUNT> _day;
    bitstr<MONTH_COUNT> _month;
    bitstr<DOW_COUNT> _week;
};

GX_NS_END

#endif

