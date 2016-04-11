#ifndef __GX_RC_H__
#define __GX_RC_H__

#include "platform.h"

GX_NS_BEGIN

enum {
    GX_LOGIC_RC = 256,
    GX_EFAIL = GX_LOGIC_RC,
    GX_EDUP         = 257,
    GX_EEXISTS      = 258,
    GX_ENOTEXISTS   = 259,
    GX_EREADY       = 260,
    GX_ENOTREADY    = 261,
    GX_ELESS        = 262,
    GX_EMORE        = 263,
    GX_EPARAM       = 264,
    GX_EAGAIN       = 265,

    GX_ESYS_RC      = 512,
    GX_ETIMEOUT = GX_ESYS_RC,
    GX_ECLOSED      = 513,
    GX_ECLOSE       = 514,
    GX_EBUSY        = 515,
    GX_ESYS_END,
};

GX_NS_END

#endif
