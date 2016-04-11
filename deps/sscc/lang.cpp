#include <unordered_map>
#include <memory>
#include "lang.h"
#include "log.h"
static std::unordered_map<const char*, ptr<Language>> __map;

Language::Language(const char *name) : _name(Unistr::get(name, strlen(name)))
{ }

Language *Language::get(const char *name) {
	name = Unistr::get(name, strlen(name));
    auto it = __map.find(name);
    if (it == __map.end()) {
        return nullptr;
    }
    return it->second;
}

Language *Language::reg(ptr<Language> lang) {
    auto em = __map.emplace(lang->name(), lang);
    return em.first->second; 
}



