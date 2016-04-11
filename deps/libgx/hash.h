#ifndef __GX_HASH_H__
#define __GX_HASH_H__

#include "platform.h"

GX_NS_BEGIN

inline std::size_t hash_string(const char *p) noexcept {

    const unsigned char *str = (const unsigned char *)p;
    std::size_t r = 0;
    unsigned char c;

    while ((c = *str++) != 0) {
        r = r * 67 + c - 113;
    }

    return r;
}

inline std::size_t hash_string_n(const char *p, std::size_t size) noexcept {
    const unsigned char *str = (const unsigned char *)p;
    std::size_t r = 0;
    unsigned char c;

    while (size--) {
        c = *str++;
        r = r * 67 + c - 113;
    }

    return r;
}

inline std::size_t hash_iterative(const void *key, unsigned int len, std::size_t initval = 0x01000193U) noexcept {
    static const uint64_t m = 0xc6a4a7935bd1e995ULL;
    static const uint64_t r = 47;
    register uint64_t h = ((uint64_t)initval) ^ (len * m);
    register const uint64_t *data = (const uint64_t*)key;
    register const uint64_t *end = data + (len / sizeof(uint64_t));

    register uint64_t k ;
    while (data != end) {
            k = *data++;
            k *= m;
            k ^= k >> r;
            k *= m;
            h ^= k;
            h *= m;
    };

    register const unsigned char *data2 = (const unsigned char*)data;
    switch (len & (sizeof(uint64_t) - 1)) {
    case 7: h ^= (uint64_t)(data2[6]) << 48;
    case 6: h ^= (uint64_t)(data2[5]) << 40;
    case 5: h ^= (uint64_t)(data2[4]) << 32;
    case 4: h ^= (uint64_t)(data2[3]) << 24;
    case 3: h ^= (uint64_t)(data2[2]) << 16;
    case 2: h ^= (uint64_t)(data2[1]) << 8;
    case 1: h ^= (uint64_t)(data2[0]);
            h *= m;
    }
    h ^= h >> r;
    h *= m;
    h ^= h >> r;
    return (std::size_t)h;
}

GX_NS_END

#endif

