#ifndef __LIBFIGHT_H__
#define __LIBFIGHT_H__

extern "C" {
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
}

void libfight_init(lua_State *L);

#endif

