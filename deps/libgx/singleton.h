#ifndef __GX_SINGLETON_H__
#define __GX_SINGLETON_H__

#include "platform.h"
#include "memory.h"
GX_NS_BEGIN

class singleton_base {
protected:
    static void registerSingleton(ptr<Object> instance);
};

template <typename _T, typename ..._Deps>
class singleton : singleton_base {
private:
    template <std::size_t __n, typename _D> 
    struct trace_deps {
        static bool check() noexcept {
            return true;
        }
    };

    template <std::size_t __n, typename _D, typename ..._Others>
    struct trace_deps<__n, std::tuple<_D, _Others...>> {
        static bool check() noexcept {
            if (!std::is_same<_T, _D>::value) {
                if (!_D::instance()) {
                    return false;
                }
            }
            return trace_deps<__n - 1, std::tuple<_Others...>>::check();
        }
    };

    template <typename _D, typename ..._Others>
    struct trace_deps<1, std::tuple<_D, _Others...>> {
        static bool check() noexcept {
            if (!std::is_same<_T, _D>::value) {
                if (!_D::instance()) {
                    return false;
                }
            }
            return true;
        }
    };

    static _T *construct_object() noexcept {
        if (!trace_deps<sizeof...(_Deps), std::tuple<_Deps...>>::check()) {
            return nullptr;
        }
        object<_T> obj;
        registerSingleton(obj);
        return obj;
    }
public:
	static _T *instance() {
		static _T *obj = nullptr;
        if (!obj) {
            obj = construct_object();
        }
		return obj;
	}
};

GX_NS_END

#endif

