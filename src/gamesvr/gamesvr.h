#ifndef __GAMESVR_H__
#define __GAMESVR_H__

#include "libgx/gx.h"
GX_NS_USING;

#include "gamesvr_msg.h"

struct G_GameNode {
    G_GameNode() noexcept
    : _network_node(),
      _instance()
    { }

    std::string _name;
    NetworkNode *_network_node;
    unsigned _instance;
};

void startup();
void shutdown();

#endif

