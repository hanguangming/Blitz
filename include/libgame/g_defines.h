#pragma once

#define G_OPT_INSERT 0x0
#define G_OPT_UPDATE 0x1
#define G_OPT_REMOVE 0x2
#define G_OPT_UNKNOWN 0x3
#define G_CD_FORGE_LOW 0x0
#define G_CD_FORGE_MIDDLE 0x1
#define G_CD_FORGE_HIGH 0x2
#define G_CD_RECRUIT_LOW 0x3
#define G_CD_RECRUIT_MIDDLE 0x4
#define G_CD_RECRUIT_HIGH 0x5
#define G_CD_UNKNOWN 0x6
#define G_FORGE_NUM 0x5
#define G_FORGE_SHOP 0x0
#define G_FORGE_NEW 0x0
#define G_FORGE_LOW 0x1
#define G_FORGE_MIDDLE 0x2
#define G_FORGE_HIGH 0x3
#define G_FORGE_UNKNOWN 0x4
#define G_RECRUIT_NEW 0x0
#define G_RECRUIT_LOW 0x1
#define G_RECRUIT_MIDDLE 0x2
#define G_RECRUIT_HIGH 0x3
#define G_RECRUIT_UNKNOWN 0x4
#define G_ITYPE_SOUL1 0x0
#define G_ITYPE_SOUL2 0x1
#define G_ITYPE_EQUIP_BEGIN 0x2
#define G_ITYPE_EQUIP_END 0x9
#define G_ITYPE_BOX 0xc
#define G_ITYPE_COIN 0x13
#define G_ITYPE_MONEY 0x14
#define G_ITYPE_EXP 0x15
#define G_ITEM_MONEY 0x1
#define G_ITEM_COIN 0x2
#define G_ITEM_EXP 0x3
#define G_ITEM_HONOR 0x4
#define G_ITEM_RECRUIT 0x5
#define G_ITEM_MORDERS 0x6
#define G_ITEM_UNKNOWN 0x7
#define G_TASK_MAIN 0x0
#define G_TASK_BRANCH_1 0x1
#define G_TASK_BRANCH_2 0x2
#define G_TASK_BRANCH_3 0x3
#define G_TASK_BRANCH_4 0x4
#define G_TASK_UNKNOWN 0x5
#define G_TASK_STATE_NOREADY 0x0
#define G_TASK_STATE_ACCEPTED 0x1
#define G_TASK_STATE_FINISHED 0x2
#define G_TASK_STATE_REMOVED 0x3
#define G_TASK_STATE_END 0x4
#define G_TASK_STATE_UNKNOWN 0x5
#define G_TASK_COND_STAGE 0x1
#define G_TASK_COND_LEVEL 0x3
#define G_TASK_COND_BUY_ITEM 0xa
#define G_TASK_COND_TECH 0xc
#define G_VALUE_MONEY 0x0
#define G_VALUE_COIN 0x1
#define G_VALUE_HONOR 0x2
#define G_VALUE_RECRUIT 0x3
#define G_VALUE_RECHARGE 0x4
#define G_VALUE_LEVEL 0x5
#define G_VALUE_EXP 0x6
#define G_VALUE_VIP 0x7
#define G_VALUE_RECRUIT_BEGIN 0x8
#define G_VALUE_RECRUIT_1 0x8
#define G_VALUE_RECRUIT_2 0x9
#define G_VALUE_RECRUIT_3 0xa
#define G_VALUE_RECRUIT_4 0xb
#define G_VALUE_RECRUIT_5 0xc
#define G_VALUE_RECRUIT_END 0xc
#define G_VALUE_STAGE 0xd
#define G_VALUE_MORDERS 0xe
#define G_VALUE_FORMATION_PVE 0xf
#define G_VALUE_FORMATION_PVP 0x10
#define G_VALUE_FORMATION_ARENA 0x11
#define G_VALUE_TIGER_USE_TIMES 0x12
#define G_VALUE_SUPPLEMENT 0x13
#define G_VALUE_SHADOW 0x14
#define G_VALUE_CHALLENGE 0x15
#define G_VALUE_APPEARANCE 0x16
#define G_VALUE_MEXP 0x17
#define G_VALUE_UNKNOWN 0x18
#define G_TMP_VALUE_BEGIN 0x80
#define G_VALUE_SCORE 0x0
#define G_TMP_VALUE_UNKNOWN 0x1
#define G_RAND_MAX 0x2710
#define G_TYPE_SOLDIER 0x1
#define G_TYPE_HERO 0x2
#define G_SOLDIER_LEVEL 0x0
#define G_SOLDIER_EXP 0x1
#define G_SOLDIER_USED 0x2
#define G_SOLDIER_EQUIP_BEGIN 0x3
#define G_SOLDIER_EQUIP_1 0x3
#define G_SOLDIER_EQUIP_2 0x4
#define G_SOLDIER_EQUIP_3 0x5
#define G_SOLDIER_EQUIP_4 0x6
#define G_SOLDIER_EQUIP_5 0x7
#define G_SOLDIER_EQUIP_6 0x8
#define G_SOLDIER_EQUIP_7 0x9
#define G_SOLDIER_EQUIP_8 0xa
#define G_SOLDIER_EQUIP_END 0xa
#define G_SOLDIER_UNKNOWN 0xb
#define G_TRAIN_LOW 0x1
#define G_TRAIN_MIDDLE 0x2
#define G_TRAIN_HIGH 0x3
#define G_FORMATION_NUM 0x3
#define G_FORMATION_PVE 0x0
#define G_FORMATION_PVP 0x1
#define G_FORMATION_ARENA 0x2
#define G_FORMATION_UNKNOWN 0x3
#define G_TECH_COND_NONE 0x0
#define G_TECH_COND_LEVEL 0x1
#define G_TECH_COND_STAGE 0x2
#define G_TECH_COND_PRETECH 0x3
#define G_TECH_SOLDIERUP_NUM 0x0
#define G_TECH_SOLDIER_PVE_NUM 0x1
#define G_TECH_SOLDIER_PVP_NUM 0x2
#define G_TECH_SOLDIER_UNLOCK 0x3
#define G_TECH_SPEED 0x4
#define G_TECH_UNKNOWN 0x5
#define G_SOLDIERUP_NUM 0x1
#define G_SOLDIER_PVE_NUM 0x2
#define G_SOLDIER_PVP_NUM 0x3
#define G_SPEED 0x2710
#define G_SIDE_SHU 0x0
#define G_SIDE_WEI 0x1
#define G_SIDE_WU 0x2
#define G_SIDE_OTHER 0x3
#define G_SIDE_MAN 0x3
#define G_SIDE_HUANG 0x4
#define G_SIDE_UNKNOWN 0x5
#define G_PLAYER_INIT_MONEY 0x1
#define G_PLAYER_INIT_COIN 0x2
#define G_PLAYER_INIT_ITEM 0x3
#define G_PLAYER_INIT_SOLDIER 0x4
#define G_MOVE_NORMAL 0x0
#define G_MOVE_DART 0x1
#define G_MOVE_RETREAT 0x2
#define G_MOVE_UNKNOWN 0x3
#define G_CITY_PEACE 0x0
#define G_CITY_FIGHT 0x1
#define G_CITY_UNKNOWN 0x2
#define G_MAP_UNIT_PLAYER 0x0
#define G_MAP_UNIT_SHADOW 0x1
#define G_MAP_UNIT_DEFENDER 0x2
#define G_MAP_UNIT_UNKNOWN 0x3
#define G_MAP_UNIT_STATE_WAIT 0x0
#define G_MAP_UNIT_STATE_FIGHT 0x1
#define G_MAP_UNIT_STATE_REMOVED 0x2
#define G_MAP_UNIT_STATE_UNKNOWN 0x3
#define G_MAP_CAPITAL 0x1
#define G_MAP_REVIVE 0x5
#define G_FIGHT_QUEUE_SIZE 0x3
#define G_ARENA_LIST_SIZE 0x5
#define G_ARENA_TOP_LIST_SIZE 0x3
#define G_FIGHT_DEUCE 0x0
#define G_FIGHT_ATTACKER_WIN 0x1
#define G_FIGHT_DEFENDER_WIN 0x2
#define G_FIGHT_UNKNOWN 0x3
#define G_QUALITY_0 0x0
#define G_QUALITY_1 0x1
#define G_QUALITY_2 0x2
#define G_QUALITY_3 0x3
#define G_QUALITY_RANKING_BEGIN 0x4
#define G_QUALITY_4 0x4
#define G_QUALITY_5 0x5
#define G_QUALITY_6 0x6
#define G_QUALITY_UNKNOWN 0x7
#define G_QUALITY_RANKING_NUM 0x3
#define G_RANKING_LIST_NUM 0x64
#define G_ARENA_RANKING_LIST_NUM 0x14
#define G_CHAT_CHANNEL_WORLD 0x0
#define G_CHAT_CHANNEL_SIDE 0x1
#define G_CHAT_CHANNEL_PERSION 0x2
#define G_CHAT_CHANNEL_UNKNOWN 0x3
#define G_FIGHT_REPORT_MAX 0x5
#define G_NICKNAME_LIMIT 0x30
#define G_USERNAME_LIMIT 0x40
#define G_PASSWD_LIMIT 0x40
#define G_MEXP_UNIT 0x64
#define G_MEXP_PER_PEOPLE 0x5
#define G_MEXP_DEFEND 0x7d0
#define G_MEXP_ATTACK 0xbb8
#define G_MEXP_FCM1 0x1388
#define G_MEXP_FCM2 0x3a98
#define G_MEXP_PER_MONEY 0x3e8
#define G_MEXP_MAX 0x493e0

