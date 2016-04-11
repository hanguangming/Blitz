#include <list>
#include "singleton.h"

GX_NS_BEGIN

void singleton_base::registerSingleton(ptr<Object> instance)  {
    static std::list<ptr<Object>> singletons;
    singletons.push_front(instance);
}

GX_NS_END


