#ifndef __GX_BITSTR_H__
#define __GX_BITSTR_H__

#include "platform.h"
#include "types.h"

GX_NS_BEGIN

struct bitstr_base {
    static bool test(const char *buf, unsigned bit) noexcept {
        return buf[bit_byte(bit)] & bit_mask(bit);
    }
    static void set(char *buf, unsigned bit) noexcept {
        buf[bit_byte(bit)] |= bit_mask(bit);
    }
    static void clear(char *buf, unsigned bit) noexcept {
        buf[bit_byte(bit)] &= bit_mask(bit);
    }
    static void set(char *buf, unsigned start, unsigned stop) noexcept {
        register int startbyte = bit_byte(start);
        register int stopbyte = bit_byte(stop);
        if (startbyte == stopbyte) {
            buf[startbyte] |= ((0xff << (start & 0x7)) & (0xff >> (7 - (stop & 0x7))));
        } else {
            buf[startbyte] |= 0xff << (start & 0x7);
            while (++startbyte < stopbyte) {
                buf[startbyte] = 0xff;
            }
            buf[stopbyte] |= 0xff >> (7 - (stop & 0x7));
        }
    }
    static void clear(char *buf, unsigned start, unsigned stop) noexcept {
        register int startbyte = bit_byte(start);
        register int stopbyte = bit_byte(stop);
        if (startbyte == stopbyte) {
            buf[startbyte] &= ((0xff >> (8 - (start & 0x7))) | (0xff << ((stop & 0x7) + 1)));
        } else {
            buf[startbyte] &= 0xff >> (8 - (start & 0x7));
            while (++startbyte < stopbyte) {
                buf[startbyte] = 0;
            }
            buf[stopbyte] &= 0xff << ((stop & 0x7) + 1);
        }
    }
    static unsigned bit_byte(unsigned bit) noexcept {
        return bit >> 3;
    }
    static unsigned bit_mask(unsigned bit) noexcept {
        return 1 << (bit & 0x7);
    }
};

template <unsigned __Size>
class bitstr : public bitstr_base {
public:
    static constexpr const unsigned bit_size    = __Size;
    static constexpr const unsigned byte_size   = ((((bit_size) - 1) >> 3) + 1);
    bitstr() noexcept {
        std::memset(_buf, 0, sizeof(_buf));
    }
    unsigned size() const {
        return __Size;
    }
    bool test(unsigned bit) const noexcept {
        return bitstr_base::test(_buf, bit);
    }
    void set(unsigned bit) noexcept {
        bitstr_base::set(_buf, bit);
    }
    void clear(unsigned bit) noexcept {
        bitstr_base::clear(_buf, bit);
    }
    void set(unsigned start, unsigned stop) noexcept {
        bitstr_base::set(_buf, start, stop);
    }
    void clear(unsigned start, unsigned stop) noexcept {
        bitstr_base::clear(_buf, start, stop);
    }
    char *data() noexcept {
        return _buf;
    }
private: 
    char _buf[byte_size];
};

GX_NS_END

#endif

