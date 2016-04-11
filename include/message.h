#pragma once
#include "libgx/serial.h"

#include "sys/network.h"
#define LS_BEGIN 0x10000
#define LS_LOGIN_ACCOUNT 0x10000
#define LS_LOGIN_SESSION 0x10001
#define LS_REGISTER 0x10002
#define CL_BEGIN 0x0
#define CL_LOGIN 0x1
#define CL_SHOP_BUY 0x2
#define CL_FORGE_REFRESH 0x3
#define CL_FORGE_BUY 0x4
#define CL_USE_ITEM 0x5
#define CL_RECHARGE 0x6
#define CL_EQUIPUP 0x7
#define CL_RECAST 0x8
#define CL_RECRUIT 0x9
#define CL_SOLDIER_UP 0xa
#define CL_HERO_UP 0xb
#define CL_TRAIN 0xc
#define CL_TRAIN_CANCEL 0xd
#define CL_EMPLOY 0xe
#define CL_USE_HERO 0xf
#define CL_USE_EQUIP 0x10
#define CL_EXP_UP 0x11
#define CL_FORMATION_SAVE 0x12
#define CL_TECH_RESEARCH 0x13
#define CL_STAGE 0x14
#define CL_FORMATION_USE 0x15
#define CL_TASK_FINISH 0x16
#define CL_MOVE 0x17
#define CL_SUPPLEMENT 0x18
#define CL_QUERY_CORPS 0x19
#define CL_SHADOW 0x1a
#define CL_ARENA_LIST 0x1b
#define CL_ARENA_CHALLENGE 0x1c
#define CL_FIGHT_RESULT 0x1d
#define CL_ARENA_AWARD 0x1e
#define CL_SOLDIER_RANKING_LIST 0x1f
#define CL_SCORE_RANKING_LIST 0x20
#define CL_PLAYER_SOLDIER_INFO 0x21
#define CL_ARENA_RANKING_LIST 0x22
#define CL_APPEARANCE 0x23
#define CL_STAGE_END 0x24
#define CL_STAGE_BATCH 0x25
#define CL_CHAT 0x26
#define CL_SELL 0x27
#define CL_MAP_SUBSCRIBE 0x28
#define CL_MAP_PVP 0x29
#define CL_NOTIFY_BEGIN 0x8000
#define CL_NOTIFY_ITEMS 0x8001
#define CL_NOTIFY_VALUES 0x8002
#define CL_NOTIFY_FORGE 0x8003
#define CL_NOTIFY_COOLDOWN 0x8004
#define CL_NOTIFY_SOLDIER_VALUES 0x8005
#define CL_NOTIFY_SOLDIER 0x8006
#define CL_NOTIFY_TRAIN 0x8007
#define CL_NOTIFY_KICK 0x8008
#define CL_NOTIFY_FORMATION 0x8009
#define CL_NOTIFY_TECH 0x800a
#define CL_NOTIFY_TASK 0x800b
#define CL_NOTIFY_MAP_CITY_ENTER 0x800c
#define CL_NOTIFY_MOVE_PRESEND 0x800d
#define CL_NOTIFY_REMOVE_PRESEND 0x800e
#define CL_NOTIFY_CITY_PRESEND 0x800f
#define CL_NOTIFY_MAP_UNIT_PRESEND 0x8010
#define CL_NOTIFY_MAP_UNIT_STATE_PRESEND 0x8011
#define CL_NOTIFY_FIGHT_REPORT 0x8012
#define CL_NOTIFY_FIGHT 0x8013
#define CL_NOTIFY_SYSTEM 0x8014
#define CL_NOTIFY_CHAT 0x8015
#define CL_NOTIFY_MAP_FIGHT_INFO 0x8016
#define CL_NOTIFY_MAP_CITY_LEAVE 0x8017
#define CL_NOTIFY_FIGHT_INFO 0x8018
#define CL_NOTIFY_PEOPLE 0x8019
#define ID_BEGIN 0x30000
#define ID_GEN 0x30001
#define AS_BEGIN 0x40000
#define AS_LOGIN 0x40001
#define AS_FIGHT_INFO 0x40002
#define AS_ARENA_LOSE 0x40003
#define AS_PLAYER_SOLDIER_INFO 0x40004
#define AS_REGISTER 0x40005
#define AS_FIGHT 0x40006
#define AS_SYSTEM_NOTIFY 0x40007
#define AS_CHAT 0x40008
#define AS_MEXP 0x40009
#define GM_ADD_ITEM 0x4000a
#define GM_ADD_MONEY 0x4000b
#define GM_ADD_HERO 0x4000c
#define GM_UPDATE_SOLDIER_LEVEL 0x4000d
#define GM_UPDATE_LEVEL 0x4000e
#define GM_UPDATE_VIP 0x4000f
#define GM_UPDATE_STAGE 0x40010
#define GM_ADD_EXP 0x40011
#define GM_UPDATE_MORDERS 0x40012
#define GM_FIGHT_WITH 0x40013
#define DB_BEGIN 0x20000
#define DB_ACCOUNT_QUERY 0x20001
#define DB_ACCOUNT_REGISTER 0x20002
#define DB_LOAD 0x20003
#define DB_SHOP_BUY 0x20004
#define DB_FORGE_REFRESH 0x20005
#define DB_FORGE_BUY 0x20006
#define DB_RECHARGE 0x20007
#define DB_USE_COIN_ITEM 0x20008
#define DB_USE_MONEY_ITEM 0x20009
#define DB_USE_EXP_ITEM 0x2000a
#define DB_USE_SOUL_ITEM 0x2000b
#define DB_EQUIPUP 0x2000c
#define DB_RECAST 0x2000d
#define DB_RECRUIT 0x2000e
#define DB_SOLDIER_UP 0x2000f
#define DB_HERO_UP 0x20010
#define DB_TRAIN 0x20011
#define DB_TRAIN_CANCEL 0x20012
#define DB_EMPLOY 0x20013
#define DB_FIRE 0x20014
#define DB_USE_HERO 0x20015
#define DB_USE_EQUIP 0x20016
#define DB_EXP_UP 0x20017
#define DB_FORMATION_SAVE 0x20018
#define DB_TECH_RESEARCH 0x20019
#define DB_STAGE 0x2001a
#define DB_FORMATION_USE 0x2001b
#define DB_AGENT_TIMER 0x2001c
#define DB_TASK_UPDATE 0x2001d
#define DB_TASK_FINISH 0x2001e
#define DB_SUPPLEMENT 0x2001f
#define DB_SHADOW 0x20020
#define DB_ARENA_CHALLENGE_START 0x20021
#define DB_ARENA_CHALLENGE_END 0x20022
#define DB_ARENA_CHALLENGE_AWARD 0x20023
#define DB_ARENA_AWARD 0x20024
#define DB_APPEARANCE 0x20025
#define DB_GM_VALUE_ITEM 0x20026
#define DB_USE_BOX_ITEM 0x20027
#define DB_CHAT 0x20028
#define DB_SELL 0x20029
#define DB_LOGIN 0x2002a
#define DB_LOGOUT 0x2002b
#define DB_AGENT 0x2002c
#define DB_MEXP 0x2002d
#define MS_BEGIN 0x50000
#define MS_LOGIN 0x50001
#define MS_LOGOUT 0x50002
#define MS_MOVE 0x50003
#define MS_SUPPLEMENT 0x50004
#define MS_QUERY_CORPS 0x50005
#define MS_SHADOW 0x50006
#define MS_UPDATE_LEVEL 0x50007
#define MS_UPDATE_VIP 0x50008
#define MS_UPDATE_SIDE 0x50009
#define MS_UPDATE_APPEARANCE 0x5000a
#define MS_UPDATE_SPEED 0x5000b
#define MS_SUBSCRIBE 0x5000c
#define MS_PVP 0x5000d
#define MC_BEGIN 0x60000
#define MC_LOGIN 0x60001
#define WS_REGISTER 0x80000
#define WS_ARENA_LIST 0x80001
#define WS_PLAYER_TOUCH 0x80002
#define WS_ARENA_CHALLENGE 0x80003
#define WS_ARENA_AWARD 0x80004
#define WS_LOGIN 0x80005
#define WS_LOGOUT 0x80006
#define WS_SOLDIER_RANKING_LIST 0x80007
#define WS_SCORE_RANKING_LIST 0x80008
#define WS_ARENA_RANKING_LIST 0x80009
#define WS_SCORE_UPDATE 0x8000a
#define WS_SOLDIER_UPDATE 0x8000b
#define WS_UPDATE_LEVEL 0x8000c
#define WS_UPDATE_VIP 0x8000d
#define WS_UPDATE_SIDE 0x8000e
#define WS_UPDATE_APPEARANCE 0x8000f
#define FS_REGISTER 0x70000
#define FS_FIGHT 0x70001
#define GS_BEGIN 0x90000
#define GS_COMMAND 0x90001
#define GM_BEGIN 0xa0000
#define GM_UPDATE_TIME 0xa0001
#define GM_SHUTDOWN 0xa0002
#define E_FAIL 0x100
#define E_TIMEOUT 0x101
#define E_DUP 0x102
#define E_EXIST 0x103
#define E_NOTEXIST 0x104
#define E_READY 0x105
#define E_NOTREADY 0x106
#define E_CLOSED 0x107

