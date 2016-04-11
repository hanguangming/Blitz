#ifndef __GX_PROB_H__
#define __GX_PROB_H__

#include <vector>
#include "memory.h"

GX_NS_BEGIN


template <typename _T>
class ProbContainer : public Object {
public:
    class Prob {
        friend class ProbContainer;
    public:
        Prob() { }
        Prob(unsigned value, ptr<_T> object) noexcept 
        : _prob(value), _object(object) { }

        bool operator<(const Prob &rhs) const noexcept {
            return _prob < rhs._prob;
        }

        unsigned prob() const noexcept {
            return _prob;
        }

        ptr<_T> object() const noexcept {
            return _object;
        }
    private:
        unsigned _prob;
        ptr<_T> _object;
    };

public:
    void push(unsigned prob, ptr<_T> object) noexcept {
        assert(prob);
        _probs.emplace_back(max() + prob, object);
    }
    unsigned max() const noexcept {
        if (_probs.empty()) {
            return 0;
        }
        return _probs.back()._prob;
    }
    ptr<_T> get(unsigned prob) const noexcept {
        static Prob tmp;
        if (!prob || prob > max()) {
            return nullptr;
        }
        tmp._prob = prob;
        return std::lower_bound(_probs.begin(), _probs.end(), tmp)->_object;
    }
    const std::vector<Prob> &probs() const noexcept {
        return _probs;
    }
protected:
    std::vector<Prob> _probs;
};

GX_NS_END

#endif

