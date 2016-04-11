#ifndef __GX_TRANSACTION_H__
#define __GX_TRANSACTION_H__

#include "platform.h"

GX_NS_BEGIN

struct Transaction {
    virtual bool begin() noexcept = 0;
    virtual void commit() noexcept = 0;
    virtual void rollback() noexcept = 0;
};

GX_NS_END

#endif

