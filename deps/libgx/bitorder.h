#ifndef __GX_BITORDER_H__
#define __GX_BITORDER_H__

#include "platform.h"

GX_NS_BEGIN

struct BitOrder {
    static const unsigned char ordertab[256];

    /* (1 << order(n)) >= n */
    static unsigned order(unsigned long n) {
        register unsigned r = 0;
        register unsigned long m = n;
        while (m & (~0xff)) {
            m >>= 8;
            r += 8;
        }
        r += ordertab[m];
        if ((1UL << r) < n) {
            r++;
        }
        return r;
    }
};

GX_NS_END

#endif
