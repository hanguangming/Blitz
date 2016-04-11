----
-- 文件名称：UITypeDefine
-- 功能描述：UI类型定义
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-4-21
--  修改：
UIType = 
{
    --资源LoadingUI
    UIType_LoadingUI = 1,
    --聊天
    UIType_TalkUI = 3,
    --登陆UI
    UIType_LoginUI = 4,
    --战斗场景UI   
    UIType_BattleUI = 5,
    --背包UI
    UIType_PackageUI = 6,
    --士兵UI
    UIType_SoldierUI = 7,
    --训练UI
    UIType_TrainUI = 8 ,
    --主城UI
    UIType_MaincityUI = 9,
    -- Warrior UI
    UIType_WarriorUI = 10,
    -- SelectWarrior UI
    UIType_WarriorListUI = 11,
    -- Bag UI
    UIType_BagUI = 12,
    -- Store UI
    UIType_StoreUI = 13,
    -- Equip UI
    UIType_EquipUI = 14,
    -- Advanced UI
    UIType_AdvancedUI = 15,
    -- reborn UI
    UIType_RebornUI = 16,
    -- 
    UIType_RebornWarriorListUI = 17,
    --战斗结算UI
    UIType_BattleResUI = 18,  
    --战斗失败
    UIType_BattleLoseUI = 19, 
    --奖励
    UIType_RewardUI = 20, 
    --冶炼
    UIType_UISmelt = 21,
    --招募
    UIType_UIRecruit = 22,
    --关卡地图
    UIType_CustomMap = 23,
    --关卡选择
    UIType_CustomSelect = 24,
    --关卡敌方信息
    UIType_CustomEnmeyInfo = 25,
    --布阵UI
    UIType_BuZhen = 26,
    --武将商店UI
    UIType_WarriorStore = 27,
    --使用虎符界面
    UIType_UseHuFu = 28,
    --商城外单个物品的购买
    UIType_BuyItem = 29,
    --关卡扫荡
    UIType_CustomSweep = 30,
    --布阵时士兵选择列表UI
    UIType_SoldierSelectListUI = 31,
    --沙场UI
    UIType_ShaChangDianBing = 32,
    --科技
    UIType_Technology = 33,
    --设置
    UIType_Setting = 34,
    --task
    UIType_Task = 35,
    --沙场奖励列表
    UIType_ShaChangRewardList = 36,
    --沙场排行榜
    UIType_ShaChangRank = 37,
    --沙场荣誉商店
    UIType_RongYuShop = 38,
    --关卡敌方boss信息
    UIType_CustomEnmeyBossInfo = 39,
    --英雄榜
    UIType_HeroTop = 40,
    --sign
    UIType_SignInUI = 41,
    --vip
    UIType_VipUI = 42,
    --世界地图
    UIType_WorldMap = 43,
    --card
    UIType_MonthCardUI = 44,
    --功勋
    UIType_Feats = 45,
    --功勋榜
    UIType_FeatsTop = 46,
    --每日红包
    UIType_EveryReward = 47,
    --
    UIType_BottomList = 48,
    --mini map
    UIType_MiniMap = 50,
    
    UIType_Country = 51,
    
    UIType_Server = 52,
    
    UIType_UIRecharge = 53,
    
    UIType_UIActivity = 54,
    
    UIType_CustomReward = 55,
    --每日任务
    UIType_EveryTask = 56,
    
    UIType_UIChallenge = 57,
    --玩家信息
    UIType_PlayerInfo = 561,
    --GMUI
    UIType_GMUI = 900,
    -- tip
    UIType_TipUI = 999,
    
    --测试UI
    UIType_ReLinkUI = 1000,
    UIType_SkillEditor = 1001,
    UIType_BuZhenEditor = 1002,
    UIType_WorldMapEditor = 1003,
}

--UI所对应的lua文件
--TODO:添加可配置的数据（zorder, 是否卸载资源）
UIScriptData = 
{
    [UIType.UIType_TalkUI]= "UITalk",
    [UIType.UIType_LoginUI]= "UILogin",
    [UIType.UIType_BattleUI]= "UIBattle",
    [UIType.UIType_PackageUI] = "UIPackage",
    [UIType.UIType_SoldierUI] = "UISoldier",
    [UIType.UIType_TrainUI] = "UITrain",
    [UIType.UIType_PackageUI] = "UIPackage",
    [UIType.UIType_MaincityUI] = "UIMaincity",
    [UIType.UIType_WarriorUI] = "UIWarrior",
    [UIType.UIType_WarriorListUI] = "UIWarriorList",
    [UIType.UIType_BagUI] = "UIBag",
    [UIType.UIType_StoreUI] = "UIStore",
    [UIType.UIType_TipUI] = "UITip",
    [UIType.UIType_SkillEditor] = "UISkillEditor",
    [UIType.UIType_EquipUI] = "UIEquip",
    [UIType.UIType_RebornUI] = "UIReborn",
    [UIType.UIType_AdvancedUI] = "UIAdvanced",
    [UIType.UIType_RebornWarriorListUI] = "UIRebornWarriorList",
    [UIType.UIType_BattleResUI] = "UIBattleRes",
    [UIType.UIType_BattleLoseUI] = "UIBattleLose",
    [UIType.UIType_GMUI] = "UIGm",
    [UIType.UIType_RewardUI] = "UIRewardList",
    [UIType.UIType_UISmelt] = "UISmelt",
    [UIType.UIType_UIRecruit] = "UIRecruit",
    [UIType.UIType_CustomMap] = "UICustomMap",
    [UIType.UIType_RewardUI] = "UIRewardList",
    [UIType.UIType_CustomSelect] = "UICustomSelect",
    [UIType.UIType_CustomEnmeyInfo] = "UICustomEnmeyInfo",
    [UIType.UIType_BuZhen]= "UIBuZhen",
    [UIType.UIType_WarriorStore]= "UIWarriorStore",
    [UIType.UIType_UseHuFu] = "UIUseHuFu",
    [UIType.UIType_BuyItem] = "UIBuy",
    [UIType.UIType_SoldierSelectListUI] = "UISoldierSelectList",
    [UIType.UIType_Technology] = "UITechnology",
    [UIType.UIType_Setting] = "UISetting",
    [UIType.UIType_CustomSweep] = "UICustomSweep",
    [UIType.UIType_ShaChangDianBing] = "UIShangChangDianBing",
    [UIType.UIType_ShaChangRewardList] = "UIShaChangJiangLiList",
    [UIType.UIType_Task] = "UITask",
    [UIType.UIType_ShaChangRank] = "UIShangChangRank",
    [UIType.UIType_RongYuShop] = "UIShaChangRongYuShop",
    [UIType.UIType_BuZhenEditor] = "UIBuZhenEditor",
    [UIType.UIType_HeroTop] = "UIHeroTop",
    [UIType.UIType_CustomEnmeyBossInfo] = "UICustomEnmeyBossInfo",
    [UIType.UIType_WorldMapEditor] = "UIWorldMapEditor",
    [UIType.UIType_SignInUI] = "UISignIn",
    [UIType.UIType_VipUI] = "UIVip",
    [UIType.UIType_Feats] = "UIFeats",
    [UIType.UIType_FeatsTop] = "UIFeatsTop",
    [UIType.UIType_WorldMap] = "UIWorldMap",
    [UIType.UIType_MonthCardUI] = "UIMonthCard",
    [UIType.UIType_EveryReward] = "UIEveryReward",
    [UIType.UIType_BottomList] = "UIBottomList",
    [UIType.UIType_MiniMap] = "UIMiniWorldMap",
    [UIType.UIType_Country] = "UICountrySelect",
    [UIType.UIType_Server] = "UIServerSelect",
    [UIType.UIType_UIRecharge] = "UIRecharge",
    [UIType.UIType_UIActivity] = "UIActivity",
    [UIType.UIType_ReLinkUI] = "UIRelink",
    [UIType.UIType_CustomReward] = "UICustomReward",
    [UIType.UIType_PlayerInfo] = "UIPlayerInfo",
    [UIType.UIType_EveryTask] = "UIEveryTask",
    [UIType.UIType_UIChallenge] = "UIChallenge",
    --资源LoadingUI
    [UIType.UIType_LoadingUI] = "UILoading"
}
