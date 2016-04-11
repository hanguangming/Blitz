----
-- 文件名称：PacketDefine.lua
-- 功能描述：网络包类型定义
-- 文件说明：网络包类型定义
-- 作    者：王雷雷
-- 创建时间：2015-5-23
--  修改：
--    
--逻辑错误码：
--
--

PacketState = 
{
    GX_EFAIL = 256,
    GX_EDUP = 257,
    GX_EEXIST = 258,
    GX_ENOTEXIST = 259,
    GX_EREADY = 260,
    GX_ENOTREADY = 261,
    GX_ELESS  =  262,
    GX_EMORE  =  263,
    GX_EPARAM =  264,

    --系统错误码：
    GX_ETIMEOUT = 512,
    GX_ECLOSED = 513,
    GX_ECLOSE = 514,
    GX_EBUSY = 515,
}
--包ID
PacketDefine = 
{
    -- 注册
    PacketDefine_Register_Send = 0x10002,
    -- 登录包
    PacketDefine_Login_Send = 0x10000,
    
    PacketDefine_MapLogin_Send = 0x60001,
    
    PacketDefine_HeartBeat_Send = 0x40000001,
        
    -- 物品通知       
    PacketDefine_ItemNotify = 0x8001,
    -- 货币通知
    PacketDefine_ValueNotify = 0x8002,
    
    PacketDefine_ForgeNotify = 0x8003,

    PacketDefine_CooldownNotify = 0x8004,
    
    PacketDefine_SoldierValueNotify = 0x8005,
    
    PacketDefine_SoldierNotify = 0x8006,
    
    PacketDefine_TrainNotify = 0x8007,
    
    PacketDefine_KickNotify = 0x8008,
    
    PacketDefine_FormationNotify = 0x8009,
    
    PacketDefine_TechNotify = 0x800a,
    
    PacketDefine_TaskNotify = 0x800b,
    
    PacketDefine_MapPresendNotify = 0x880c,
    
    PacketDefine_MoveNotify = 0x800d,
    
    PacketDefine_MapRemoveNotify = 0x800e,
    
    PacketDefine_MapCityPresendNotify = 0x800f,
    
    PacketDefine_MapUnitPresendNotify = 0x8010,
    
    PacketDefine_MapUnitStateNotify = 0x8011,
    
    PacketDefine_ArenaLostNotify = 0x8012, 
    
    PacketDefine_FightNotify = 0x8013, 
    
    PacketDefine_SystemMessageNotify = 0x8014,
    
    PacketDefine_ChatNotify = 0x8015,
    
    PacketDefine_MapFightInfoNotify = 0x8016,
    
    PacketDefine_MapCityEnterNotify = 0x800c,
    
    PacketDefine_MapCityLeaveNotify = 0x8017,
    
    PacketDefine_FightInfoNotify = 0x8018,
    
    PacketDefine_PeopleNotify = 0x8019,
        
    -- 连接游戏
    PacketDefine_AgentLogin_Send = 0x0001,
    -- 商城通购买
    PacketDefine_ShopBuy_Send = 0x0002,
    -- 冶炼刷新
    PacketDefine_ForgeRefresh_Send = 0x0003,
    -- 冶炼购买
    PacketDefine_ForgeBuy_Send = 0x0004,
    -- 使用物品
    PacketDefine_UseItem_Send = 0x0005,
    -- 充值
    PacketDefine_Recharge_Send = 0x0006,
    
    PacketDefine_WarriorStreng_Send = 0x0007,
    
    PacketDefine_WarriorRecast_Send = 0x0008,
        
    PacketDefine_Recruit_Send = 0x0009,
    -- 进阶
    PacketDefine_SoldierUp_Send = 0x000a,
    -- 转生
    PacketDefine_HeroUp_Send = 0x000b,
    
    PacketDefine_Train_Send = 0x000c,
    
    PacketDefine_TrainCancel_Send = 0x000d,
    -- 雇佣
    PacketDefine_HeroEmploy_Send = 0x000e,
    -- 出战
    PacketDefine_HeroUse_Send = 0x000f,
    -- 装备穿戴
    PacketDefine_EquipUse_Send = 0x0010,
    -- 突飞
    PacketDefine_ExpUp_Send = 0x0011,
    
    PacketDefine_FormationSave_Send = 0x0012,
    
    PacketDefine_TechResearch_Send = 0x0013,
    -- 关卡胜利
    PacketDefine_Stage_Send = 0x0014,
    
    PacketDefine_StageEnd_Send = 0x0024,
    
    PacketDefine_StageBatch_Send = 0x0025,
    -- 阵型
    PacketDefine_FormationUse_Send = 0x0015,
    
    PacketDefine_TaskFinish_Send = 0x0016,
    
    PacketDefine_MapMove_Send = 0x17,
    
    PacketDefine_Supplement_Send = 0x18,
    
    PacketDefine_QueryCorps_Send = 0x19,
    
    PacketDefine_Shadow_Send = 0x1a,
    
    PacketDefine_ArenaList_Send = 0x001b,
    
    PacketDefine_ArenaChallenge_Send = 0x001c,
    
    PacketDefine_FightResult_Send = 0x001d,
    
    PacketDefine_ArenaAward_Send = 0x001e,
    
    PacketDefine_SoldierRankingList_Send = 0x001f,
    
    PacketDefine_ScoreRankingList_Send = 0x20,
    
    PacketDefine_PlayerSoldierInfo_Send = 0x21,
    
    PacketDefine_AppeaRankingList_Send = 0x22,
        
    PacketDefine_Appearnace_Send = 0x23,
    
    PacketDefine_Char_Send = 0x26,
        
    PacketDefine_SellItem_Send = 0x27,
    
    PacketDefine_MapCitySubscribe_Send = 0x28,
    
    PacketDefine_MapPvp_Send = 0x29,
    
}

PacketDir = {
    "Login",
    "Notify",
    "Store",
    "Smelt",
    "System",
    "Warrior",
    "Map",
    "Battle"
}

PacketAndroidDir = {
    "main/NetSystem/Packet/Login/CSAgentLoginPacket",
    "main/NetSystem/Packet/Login/CSLoginPacket",
    "main/NetSystem/Packet/Login/CSRegisterPacket",
    
    "main/NetSystem/Packet/Notify/SCCooldownNotifyPacket",
    "main/NetSystem/Packet/Notify/SCForgeNotifyPacket",
    "main/NetSystem/Packet/Notify/SCFormationNotifyPacket",
    "main/NetSystem/Packet/Notify/SCItemNotifyPacket", 
    "main/NetSystem/Packet/Notify/SCKickNotifyPacket",
    
    "main/NetSystem/Packet/Notify/SCSoldierNotifyPacket",
    "main/NetSystem/Packet/Notify/SCSoldierValueNotifyPacket",
    "main/NetSystem/Packet/Notify/SCTaskNotifyPacket",
    "main/NetSystem/Packet/Notify/SCTechNotifyPacket",
    "main/NetSystem/Packet/Notify/SCTrainNotifyPacket",
    
    "main/NetSystem/Packet/Notify/SCValueNotifyPacket",
    "main/NetSystem/Packet/Notify/SCArenaLostPacket",
    "main/NetSystem/Packet/Notify/SCSystemMessageNotifypacket",
    "main/NetSystem/Packet/Notify/SCFightNotifyPacket",
    "main/NetSystem/Packet/Notify/SCMapCityPresendPacket",
    
    "main/NetSystem/Packet/Notify/SCFightInfoNotifyPacket",
    "main/NetSystem/Packet/Notify/SCMapRemoveNotifyPacket",
    "main/NetSystem/Packet/Notify/SCMapUnitPresendPacket",
    "main/NetSystem/Packet/Notify/SCMapUnitStatePresendPacket",
    "main/NetSystem/Packet/Notify/SCMoveNoitfyPacket",
     
    "main/NetSystem/Packet/Notify/SCMapFightInfoNotifyPacket",
    "main/NetSystem/Packet/Notify/SCChatNotifyPacket",
    "main/NetSystem/Packet/Notify/SCMapCityEnterNotifyPacket",
    "main/NetSystem/Packet/Notify/SCMapCityLeaveNotifyPacket",
    "main/NetSystem/Packet/Notify/SCPeopleNotifyPacket",
    
    "main/NetSystem/Packet/Store/CSStoreBuyPacket",
    "main/NetSystem/Packet/Smelt/CSForgeBuyPacket",
    "main/NetSystem/Packet/Smelt/CSForgeRefreshPacket",
    
    "main/NetSystem/Packet/System/CSHertBeatPacket",
    "main/NetSystem/Packet/System/CSRechargePacket",
    "main/NetSystem/Packet/System/CSStagePacket",
    "main/NetSystem/Packet/System/CSStageEndPacket",
    "main/NetSystem/Packet/System/CSStageBatchPacket",
    "main/NetSystem/Packet/System/CSTaskFinishPacket",
    "main/NetSystem/Packet/System/CSUserItemPacket",
    "main/NetSystem/Packet/System/CSChatPacket",
    "main/NetSystem/Packet/System/CSSellItemPacket",
    
    "main/NetSystem/Packet/Warrior/CSAppearnacePacket",
    "main/NetSystem/Packet/Warrior/CSEquipUsePacket",
    "main/NetSystem/Packet/Warrior/CSExpUpPacket",
    "main/NetSystem/Packet/Warrior/CSFormationSavePacket",
    "main/NetSystem/Packet/Warrior/CSFormationUsePacket",
    "main/NetSystem/Packet/Warrior/CSHeroEmployPacket",
    "main/NetSystem/Packet/Warrior/CSHeroUpPacket",
    "main/NetSystem/Packet/Warrior/CSHeroUsePacket",
    "main/NetSystem/Packet/Warrior/CSPlayerSoldierInfoPacket",
    "main/NetSystem/Packet/Warrior/CSRecruitPacket",
    "main/NetSystem/Packet/Warrior/CSScoreRankingListPacket",
    "main/NetSystem/Packet/Warrior/CSSoldierRankingListPacket",
    "main/NetSystem/Packet/Warrior/CSSoldierUpPacket",
    "main/NetSystem/Packet/Warrior/CSTechResearchPacket",
    "main/NetSystem/Packet/Warrior/CSTrainCancelPacket",
    "main/NetSystem/Packet/Warrior/CSTrainPacket",
    "main/NetSystem/Packet/Warrior/CSWarriorRecastPacket",
    "main/NetSystem/Packet/Warrior/CSWarriorStrengPacket",
    
    "main/NetSystem/Packet/Battle/CSArenaAwardPacket",
    "main/NetSystem/Packet/Battle/CSArenaChallengePacket",
    "main/NetSystem/Packet/Battle/CSFightResultPacket",
    "main/NetSystem/Packet/Battle/CSArenaListPacket",
    "main/NetSystem/Packet/Battle/CSArenaRankingListPacket",
    
    "main/NetSystem/Packet/Map/CSMapCitySubscribePacket",
    "main/NetSystem/Packet/Map/CSMapLoginPacket",
    "main/NetSystem/Packet/Map/CSMapMovePacket",
    "main/NetSystem/Packet/Map/CSQueryCorpsPacket",
    "main/NetSystem/Packet/Map/CSShaowPacket",
    "main/NetSystem/Packet/Map/CSSupplementPacket",
    "main/NetSystem/Packet/Map/CSMapPvpPacket",
    
}