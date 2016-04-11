#ifndef __LIBGAME_MONEY_H__
#define __LIBGAME_MONEY_H__

struct G_Money {
    G_Money() noexcept : money(), coin(), honor(), recruit() { }
    uint64_t money;
    uint64_t coin;
    uint64_t honor;
    uint64_t recruit;
};

inline G_Money operator*(const G_Money &lhs, unsigned rhs) noexcept {
    G_Money result;
    result.money = lhs.money * rhs;
    result.coin = lhs.coin * rhs;
    result.honor = lhs.honor * rhs;
    result.recruit = lhs.recruit * rhs;
    return result;
}

inline G_Money operator*(const G_Money &lhs, uint64_t rhs) noexcept {
    G_Money result;
    result.money = lhs.money * rhs;
    result.coin = lhs.coin * rhs;
    result.honor = lhs.honor * rhs;
    result.recruit = lhs.recruit * rhs;
    return result;
}

inline G_Money operator+(const G_Money &lhs, const G_Money &rhs) noexcept {
    G_Money result;
    result.money = lhs.money + rhs.money;
    result.coin = lhs.coin + rhs.coin;
    result.honor = lhs.honor + rhs.honor;
    result.recruit = lhs.recruit + rhs.recruit;
    return result;
}

inline G_Money operator-(const G_Money &lhs, const G_Money &rhs) noexcept {
    G_Money result;
    result.money = lhs.money - rhs.money;
    result.coin = lhs.coin - rhs.coin;
    result.honor = lhs.honor - rhs.honor;
    result.recruit = lhs.recruit - rhs.recruit;
    return result;
}

inline bool operator>(const G_Money &lhs, const G_Money &rhs) noexcept {
    return lhs.money > rhs.money &&
        lhs.coin > rhs.coin &&
        lhs.honor > rhs.honor &&
        lhs.recruit > rhs.recruit;
}

inline bool operator>=(const G_Money &lhs, const G_Money &rhs) noexcept {
    return lhs.money >= rhs.money &&
        lhs.coin >= rhs.coin &&
        lhs.honor >= rhs.honor &&
        lhs.recruit >= rhs.recruit;
}

inline bool operator<(const G_Money &lhs, const G_Money &rhs) noexcept {
    return !(lhs >= rhs);
}

inline bool operator<=(const G_Money &lhs, const G_Money &rhs) noexcept {
    return !(lhs > rhs);
}

#endif

