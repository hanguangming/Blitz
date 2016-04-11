#include <cstdlib>
#include <cstring>
#include <unordered_set>
#include "unistr.h"
#include "log.h"

std::unordered_set<Unistr, Unistr::hash> Unistr::_set;
object<Obstack> Unistr::_pool;

const Unistr &Unistr::get(const char *str, size_t size, int type, bool trim) {
    if (trim) {
        while (size) {
            int c = *str;
            if (c != ' ' && c != '\t') {
                break;
            }
            str++;
            size--;
        }

        const char *p = str + size;
        while (size) {
            int c = *--p;
            if (c != ' ' && c != '\t') {
                break;
            }
            size--;
        }
    }

	if (!size) {
		size = strlen(str);
	}

    static Unistr tmp;
    tmp._str = (char*)str;
    tmp._size = size;
    tmp._hash = hash_string_n(str, size);
    auto em = _set.insert(tmp);

    Unistr &ret = (Unistr&)*em.first;
    if (em.second) {
        ret._str = (char*)_pool->copy0(str, size);
        ret._type = type;
        ret._hash = tmp._hash;
        ret._size = size;
    }
    return ret;
}

