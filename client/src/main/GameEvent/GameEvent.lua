----
-- 文件名称：GameEvent.lua
-- 功能描述：游戏中事件机制：用于逻辑模块间的传递信息
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-5-4
--  修改：
-- TODO:测试该模块的性能

local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
-- 事件定义部分
GameEvent = 
{
    -----------------网络事件--------------------
    SocketTCP_EVENT_DATA = "SOCKET_TCP_DATA",
    SocketTCP_EVENT_CLOSE = "SOCKET_TCP_CLOSE",
    SocketTCP_EVENT_CLOSED = "SOCKET_TCP_CLOSED",
    SocketTCP_EVENT_CONNECTED = "SOCKET_TCP_CONNECTED",
    SocketTCP_EVENT_CONNECT_FAILURE = "SOCKET_TCP_CONNECT_FAILURE",
    GameEvent_UIFight_Succeed = "UIEvent_UIFight_Open",
    --通用的测试消息,用来验证一些临时代码
    GameEvent_CommonTest = "CommonTest",
    -------------------逻辑事件
    -- 武将出来了
    GameEvent_OutLeader = "LevelEvent_OutLeader",
    -- 武将死了
    GameEvent_LeaderDie = "LevelEvent_LeaderDie",
    --小兵死了
    GameEvent_SoldierDie = "LevelEvent_SoldierDie",
    -- 建筑血量变化 
    GameEvent_BuildHPChange = "LevelEvent_BuildHPChange",
    -- 玩家信息
    GameEvent_MyselfInfoChange = "PlayerEvent_InfoChange",
    -- 关卡状态改变
    GameEvent_LevelStateChange = "LevelEvent_LevelStateChange",
    -- 战斗中小兵或武将血量变化 
    GameEvent_BattleHPChange = "LevelEvent_CharacterHPChange",
    -- 通知PVP总血量值
    GameEvent_PVPTotalHP = "LevelEvent_PVPTotalHP",
    ------------------UI刷新事件
    GameEvent_UIBattle_RefreshRound = "UIEvent_UIBattle_RefreshRound",
    GameEvent_UIBattle_RefreshRoundTimer = "UIEvent_UIBattle_RefreshRoundTimer",
    GameEvent_UIBattle_RoundFoodChange = "UIEvent_UIBattle_RoundFoodChange",
    GameEvent_UIBattle_OutFoodChange = "UIEvent_UIBattle_OutFoodChange",
    GameEvent_UIBattle_PeopleChange = "UIEvent_UIBattle_PeopleChange",
    GameEvent_UIBattle_BattleResult = "UIEvent_UIBattle_BattleResult",
    GameEvent_UIBattle_TestSoldierNumber = "UIEvent_UIBattle_TestSoldierNumber",
    GameEvent_UILogin_Succeed = "UIEvent_UILogin_Succeed",
    GameEvent_UIBattle_TestSoldierType = "UIEvent_UIBattle_TestSoldierTypeNumber",
    GameEvent_UISoldier_Update = "GameEvent_UISoldier_Update",
    GameEvent_UITrain_Update = "GameEvent_UITrain_Update",
    GameEvent_UITrainSuccess_Update = "GameEvent_UITrainSuccess_Update",
    GameEvent_UIWarrior_Succeed = "UIEvent_UIWarrior_Succeed",
    GameEvent_UIEquip_Succeed = "UIEvent_UIEquip_Succeed",
    GameEvent_UIStore_Succeed ="UIEvent_UIStore_Succeed",
    GameEvent_UIStoreBuy_Succeed ="GameEvent_UIStoreBuy_Succeed",
    GameEvent_UIBag_Succeed = "UIEvent_UIBag_Succeed",
    GameEvent_UIWarrior_Embattle = "UIEvent_UIWarriorEmbattle_Succeed",
    GameEvent_UIStore_Update = "UIEvent_UIStore_Info",
    GameEvent_UIWarriorStore_Update = "UIEvent_UIWarriorStore_Info",
    GameEvent_UIWarriorStoreBuy_Update = "GameEvent_UIWarriorStoreBuy_Update",
    GameEvent_UIWarrior_Update = "UIEvent_UIWarrior_Update",
    GameEvent_UIWarrior_Equip_Take = "UIEvent_UIWarrior_Take",
    GameEvent_UIEquipStreng_Succeed = "UIEvent_UIEquip_Streng",
    GameEvent_UIEquipSmelt_Succeed = "UIEvent_UIEquip_Smelt",
    GameEvent_GameEvent_UIEquip_Buy = "GameEvent_UIEquip_Buy",
    GameEvent_UIEquipRecast_Succeed = "UIEvent_UIEquip_Recast",
    GameEvent_UIAdvanced_Succeed = "UIEvent_UIAdvanced_Open",
    GameEvent_UIAdvanced_Buy = "UIEvent_UIAdvanced_Buy",
    GameEvent_UIReborn_Succeed = "UIEvent_UIReborn_Open",
    GameEvent_Reborn_Succeed = "UIEvent_Reborn_Succeed",
    GameEvent_UIRebornList_Succeed = "UIEvent_UIRebornList_Open",
    GameEvent_UIRewardList_Succeed = "UIEvent_UIRewardList_Open",
    GameEvent_UIRebornListSelect_Succeed = "UIEvent_UIRebornListSelect_Open",
    GameEvent_UIRecruitOpen_Succeed = "UIEvent_UIRecruitOpen_Open",
    GameEvent_UIRecruit_Succeed = "UIEvent_UIRecruit_Succeed",
    GameEvent_UIRecruitWarrior_Succeed = "UIEvent_UIRecruitWarrior_Succeed",
    -- 布阵时选择了士兵
    GameEvent_UIBuZhen_SoldierSelect = "UIEvent_SoldierSelect",
    GameEvent_UITechnology_Open = "UIEvent_Technology_Open",
    --主界面小人
    GameEvent_MainCity_Notify = "GameEvent_MainCity_Notify",
    -- 邮件
    GameEvent_MailInfo_Notify = "GameEvent_MailInfo_Notify",
    -- 沙场刷新沙场玩家
    GameEvent_UIShaChang_RefreshPlayer = "UIEvent_ShaChang_RefreshPlayer",
    --沙场排行刷新
    GameEvent_UIShaChangRank_RefreshRank = "GameEvent_UIShaChangRank_RefreshRank",
    --关卡选择
    GameEvent_UICustomSelect_Succeed = "UIEvent_UICustomSelect_Succeed",
    -- 关卡敌方信息
    GameEvent_UICustomEnmeyInfo_Succeed = "UIEvent_UICustomEnmeyInfo_Succeed",
    -- 关卡boss信息
    GameEvent_UICustomEnmeyBossInfo_Succeed = "UIEvent_UICustomEnmeyBossInfo_Succeed",
    -- 使用虎符界面
    GameEvent_UIUseHuFu_Succeed = "UIEvent_UIUseHuFu_Succeed",
    -- 扫荡界面
    GameEvent_UICustomSweep_Succeed = "UIEvent_UICustomSweep_Succeed",
    -- 任务
    GameEvent_UITask_Succeed = "UIEvent_UITask_Succeed",
    GameEvent_UITaskUpdate_Succeed = "GameEvent_UITaskUpdate_Succeed",
    -- 英雄榜
    GameEvent_UIHeroTop_Open = "UIEvent_UIHeroTop_Succeed",
    GameEvent_UIHeroGet_Succeed = "UIEvent_UIHeroGet_Succeed",
    GameEvent_UIMonthCard_Succeed = "UIEvent_UIMonthCard_Succeed",
    GameEvent_UIVIP_Succeed = "UIEvent_UIVIP_Succeed",
    --世界地图
    GameEvent_UIWorldMap_ShowPlayer = "UIEvent_UIWorldMap_ShowPlayer",
    --国战 阵型数据刷新
    GameEvent_GuoZhan_ZhenXingDataRefresh = "GameEvent_GuoZhan_ZhenXingDataRefresh",
    --国战地图
    GameEvent_GuoZhan_JuDianStateRefresh = "GameEvent_GuoZhan_JuDianStateRefresh",
    GameEvent_SweepEnergy_Succeed = "UIEvent_SweepEnergy_Succeed",
    --国战战斗玩家列表刷新
    GameEvent_GuoZhan_BattlePlayerList = "GameEvent_GuoZhan_BattlePlayerList",
    GameEvent_GuoZhan_RefreshPlayer = "GameEvent_GuoZhan_RefreshPlayer",
    GameEvent_GuoZi_Succeed = "UIEvent_GuoZi_Succeed",
    GameEvent_GuoZhan_UpdateMap = "UIEvent_GuoZhanUpdateMap_Succeed",
    GameEvent_GuoZhan_UpdateFeat = "UIEvent_GuoZhanUpdateFeat_Succeed",
    GameEvent_GuoZhan_UpdateFeatTop = "UIEvent_GuoZhanUpdateFeatTop_Succeed",
    GameEvent_GuoZhan_ShowWalkPath = "GameEvent_GuoZhan_ShowWalkPath", 
    
    GameEvent_UITrain_UpdateItemNum = "GameEvent_UITrain_UpdateItemNum",
    
    GameEvent_UIMap_Move = "GameEvent_UIMap_Move",
    
    GameEvent_UIMap_State = "GameEvent_UIMap_State",
    
    GameEvent_UIMap_Move_City = "GameEvent_UIMap_Move_City",
    
    GameEvent_UIMap_Add_Player = "GameEvent_Add_Player",
}

--添加事件
function AddEvent(eventName, listener)
    local newListener = cc.EventListenerCustom:create(eventName,listener)
    eventDispatcher:addEventListenerWithFixedPriority(newListener, 1)
    return newListener
end

--移除事件
function RemoveEvent(newListener)
    if newListener then
        eventDispatcher:removeEventListener(newListener) 
    end
end
--移除事件通过名字,会移除掉所有这个名字的事件
function RemoveEventByName(eventName)
    eventDispatcher:removeCustomEventListeners(eventDispatcher)
end
--触发事件
function DispatchEvent(eventName, userData)
    local event = cc.EventCustom:new(eventName)
    event._usedata = userData
    eventDispatcher:dispatchEvent(event)
end