----
-- 文件名称：GameLevel.lua
-- 功能描述：游戏关卡:游戏场景构建(兵,地图，技能特效等)游戏关卡逻辑
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-4-21
--  修改：
--  制作规范： Sprite_SelfHome  Sprite_EnemyHome BG
--
local LeaderSkillInfo = class("LeaderSkillInfo")
local NetSystem = GameGlobal:GetNetSystem()
local stringFind = string.find
local stringSub = string.sub
local mathAbs = math.abs
local mathCeil = math.ceil
local mathFloor = math.floor
local mathPow = math.pow
local stringFormat = string.format
local sharedScheduler = cc.Director:getInstance():getScheduler()

--临时测试用
gHurtFactor = 1
--是否开启关卡Tile测试
local ENABLE_LEVEL_TILE_TEST = false

function LeaderSkillInfo:ctor()
    --tableID
    self._SkillTableID = 0
    self._SkillTableIDList = nil
    --武将ClientID
    self._LeaderClientID = 0
    --间隔时间
    self._SkillInterval = 10
    --技能可用剩余时间
    self._CurrentSkillLeft = 0
    --技能段数
    self._SkillStageCount = 0
    --技能当前段
    self._CurrentSkillStage = 0
    --是否更新
    self._IsEnable = false
    --技能总的冷却时间
    self._SkillTotalCD = 0
    --每一段的CD时间
    self._SkillCDList = nil
    --技能
    self._SKillHurtFactorList = nil
end
--获取当前可用的技能TableID
function  LeaderSkillInfo:GetCanUseSkillTableID()
    if self._CurrentSkillStage < 1 then
        return 0
    end
    return self._SkillTableIDList[self._CurrentSkillStage]
end

--关卡类型
LevelLogicType =
    {
        --PVE
        LevelLogicType_PVE = 1,
        --PVE中的PVP(20关等阵形通关逻辑)
        LevelLogicType_PVE_PVP = 2,
        --竞技场PVP
        LevelLogicType_PVP = 3,
        --国战PVP
        LevelLogicType_GuoZhanPVP = 4,
    }

--阵型数据
local ZhenXingData = class("ZhenXingData")
function ZhenXingData:ctor()
    --士兵TableID
    self._ArmyTableID = 0
    --所在行
    self._TileRow = 0
    --所在列
    self._TileCol = 0
    --等级
    self._Level = 1
    --血量
    self._HP = 0
    --攻击
    self._Attack = 0
end
local WaveSoldierInfo = class("WaveSoldierInfo")
function WaveSoldierInfo:ctor()
    --id
    self._WaveSoldierTableID = 0
    --数量
    self._WaveSoldierCount = 0
    --等级
    self._WaveSoldierLevel = 0
end

local director = cc.Director:getInstance()
GameLevel = class("GameLevel")
local CharacterManager = require("main.Logic.CharacterManager")
local SkillManager = require("main.Logic.SkillManager")
local SkillBuffManager = require("main.Logic.SkillBuffManager")
local UISystem = nil
local TableDataManager = GameGlobal:GetDataTableManager()
local CharacterDataManager = TableDataManager:GetCharacterDataManager()
local LevelDataManager = TableDataManager:GetLevelDataManager()
local SkillTableDataManager = nil
local mathRandom = function(a, b)
    if a < b then
      return math.random(a, b)
    else
      return math.random(b, a)
    end
end
local mathCeil = math.ceil
local mathFloor = math.floor
local DispatchEvent = DispatchEvent
local AddEvent = AddEvent
local RemoveEvent = RemoveEvent
local GameBattle = nil

--关卡状态
LevelState =
    {
        --非法
        LevelState_Invalid = -1,
        --将要开始
        LevelState_WillStart = 0,
        --已经开始
        LevelState_Runing = 1,
        --
        LevelState_WaitServerInfo = 2,
    }
--战斗结果
BattleResult =
    {
        --失败
        BattleResult_Lose = 0,
        --胜利
        BattleResult_Win = 1,
    }

--Tile数据结构
local TileData = class("TileData")
function TileData:ctor()
    --行与列
    self._Row = 0
    self._Col = 0
    --坐标
    self._X = 0
    self._Y = 0
    --角色ID列表
    self._IDList = {}
    --测试Label
    self._TestLabel = nil
end

--levelID
function GameLevel.Create(levelID)
    local newLevel = GameLevel.new(levelID)
    return newLevel
end

--构造
function GameLevel:ctor(levelID)
    print("GameLevel:ctor ", levelID)
    --回合时间
    self._ROUNDTIME = 10
    --敌方出兵间隔
    self._ENEMY_SOLDIERTIME = 5
    --关卡ID
    self._LevelTableID = levelID
    --level table data
    self._LevelTableData = LevelDataManager[levelID]
    --每回合最大人口数
    self._LevelMaxPeopleRound = 0
    --初始粮草
    self._LevelInitFoodCount = 3000
    --初始化出兵位置
    self._LevelInitRandomYMin = nil
    self._LevelInitRandomYMax = nil
    --level data end
    --如果表格中未配置，给一个默认的
    if self._LevelTableData ~= nil   then
        if self._LevelTableData.CSB ~= nil and self._LevelTableData.CSB ~= "" then
            self._LevelSceneName = self._LevelTableData.CSB
        else
            self._LevelSceneName = "csb/changjing/BattleScene.csb"
        end
    else
        self._LevelSceneName = "csb/changjing/BattleScene_PVP.csb"
    end

    --场景行走左下右上区域
    self._LevelLeftBottomPositionX = nil
    self._LevelLeftBottomPositionY = nil
    self._LevelRightTopPositionX = nil
    self._LevelRightTopPositionY = nil
    --根节点
    self._LevelNode = nil
    --角色层节点
    self._LevelSoldierNode = nil
    --特效层节点
    self._LevelEffectNode = nil
    --当前回合的粮草
    self._CurrentRoundFood = 0
    --当前粮草产出
    self._CurrentOutputFood = 0
    --选中的兵种
    self._SelectedSoldiersTable = {}
    --时间
    self._TrigerSoldierTime = 0
    --出兵间隔时间
    self._TrigerSoldierInterval = 0.1
    --回合计时
    self._CurrentRoundTime = 0
    --当前回合数
    self._CurrentRoundCount = 0
    --友方兵  key:guid  value:guid(包含了武
    self._SelfSoldierIDList = {}
    --敌兵出兵计时器
    self._TrigerEnemySoldierTime = 0
    --敌兵列表  key:guid  value:guid
    self._EnemySoldierIDList = {}
    --已出武将列表
    self._SelfOutWuJiaList = {}
    --敌主已出武将列表
    self._EnemyOutWuJiaList = {}
    --敌兵出兵序列
    self._AllWaveEnemySoldierList = {}
    --敌方出兵计时器
    self._CurrentEnemyTrigerSoldierTimer = 0
    --当前敌兵的波数
    self._CurrentEnemySoldierWaveCount = 0
    --敌人当前波已出兵的数量
    self._CurrentWaveEnemySoldierCount = 0
    --已方城池建筑ID
    self._SelfBattleBuildingID = -1
    --敌方城池建筑ID
    self._EnemyBattleBuildingID = -1
    --临时计数
    self._CurrentRoundPeopleCount = 0
    --出兵X位置
    self._SelfStartX = nil
    self._EnemyStartX = nil
    --场景大小
    self._LevelSize = nil
    --自定义事件处理
    self._SoldierDieCallBack = nil
    self._LeaderDieCallBack = nil
    self._BuildHPChangeCallBack = nil
    self._GuoZhanZhenXingCallBack = nil
    --我方武将技能CD更新
    self._LeaderSkillInfoList = nil
    --当前角色数目
    self._CurrentCharacterCount = 0
    --是否结束
    self._Finished = false
    --战斗结果(-1：无结果  0:失败  1：胜利)
    self._BattleResult = -1
    --临时测试武将种类用
    self._TestArmyList = 0
    self._TestCurrentArmyIndex = 1
    self._CurrentCharacterTypeCount = 0
    --地图格子
    self._TileDataTable = nil
    --关卡状态
    self._CurrentLevelState = LevelState.LevelState_Invalid
    --关卡的逻辑类型
    self._LevelLogicType = LevelLogicType.LevelLogicType_PVE
    --临时测试用，测试格子数据
    self._TileTestLabelList = nil
    --游戏开始时的计数
    self._GameStartTimeCount = 3
    --开始倒计时的TimerID
    self._GameStartTimerID = 0
    --PVE中PVP配置的ID
    self._PVEPVPConfigID = 0
    --PVP总血量
    self._PVPSelfTotalHP = 0
    self._PVPEnemyTotalHP = 0
    --PVE中的PVP 已方阵型数据
    self._SelfZhengXingList = nil
    self._EnemyPVEZhenXingList = nil
    --竞技场 PVP 已方阵形数据表
    self._SelfShaChangPVPZhenXing = nil
    self._EnemyShaChangPVPZhenXing = nil
    --PVE中的PVP 阵型索引
    self._PVEPVPSelectZhenXingIndex = 1
    --CheckData
    self._CurrentCheckDataCount = 0
    --当前战斗ID
    self._CurrentGuoZhanID = 0
    self._CurrentStartTime = 0
    --当前暂停的
    self._CurrentPauseTargets = nil
    --是否暂停
    self._IsPause = false
    --当前突出显示的技能ID
    self._CurrentUpdateSkillGUID = 0
end

--初始化
function GameLevel:Init()
    if self._LevelTableData ~= nil then
        if self._LevelTableData.pvp ~= 0
           and self._LevelTableData.pvp ~= nil
           and self._LevelTableData.pvp ~= "0" then
            self._LevelLogicType = LevelLogicType.LevelLogicType_PVE_PVP
            self._LevelSceneName = "csb/changjing/BattleScene_PVP.csb"
        else
            self._LevelLogicType = LevelLogicType.LevelLogicType_PVE
        end
    end
    --竞技场 PVP
    if self._LevelTableID == -1 then
        self._LevelLogicType = LevelLogicType.LevelLogicType_PVP
        self._LevelSceneName = "csb/changjing/BattleScene_PVP.csb"
        --国战PVP
    elseif self._LevelTableID == -2 then
        self._LevelLogicType = LevelLogicType.LevelLogicType_GuoZhanPVP
        self._LevelSceneName = "csb/changjing/BattleScene_PVP.csb"
        self._CurrentLevelState = LevelState.LevelState_WaitServerInfo
    end
    --场景节点
    self._LevelNode = cc.CSLoader:createNode(self._LevelSceneName)
    self._LevelNode:retain()
    self._LevelNode:setAnchorPoint(0.5, 0.5)
    self._LevelNode:setPositionX((cc.Director:getInstance():getWinSizeInPixels().width) / 2)
    self._LevelNode:setPositionY((cc.Director:getInstance():getWinSizeInPixels().height ) / 2)
    self._LevelSoldierNode = cc.Node:create()
    self._LevelSoldierNode:retain()
    self._LevelNode:addChild(self._LevelSoldierNode)
    --self._LevelNode:setPositionY(-50)
    self._LevelEffectNode = cc.Node:create()
    self._LevelEffectNode:retain()
    self._LevelNode:addChild(self._LevelEffectNode)
    --查找场景节点下的建筑子节点，如果有创建BattleBuilding
    local selfHomeBuldingSprite = self._LevelNode:getChildByName("Sprite_SelfHome")
    local enemyHomeBuildingSprite = self._LevelNode:getChildByName("Sprite_EnemyHome")
    --标识场景区域的四个节点
    local levelLeftTopNode = self._LevelNode:getChildByName("Node_LeftTop")
    local levelLeftBottomNode = self._LevelNode:getChildByName("Node_LeftBottom")
    local levelRightTopNode = self._LevelNode:getChildByName("Node_RightTop")
    local levelRightBottomNode = self._LevelNode:getChildByName("Node_RightBottom")
    --
    if  levelLeftBottomNode ~= nil and levelRightTopNode ~= nil then
        self._LevelLeftBottomPositionX, self._LevelLeftBottomPositionY = levelLeftBottomNode:getPosition()
        self._LevelRightTopPositionX,  self._LevelRightTopPositionY = levelRightTopNode:getPosition()

        print("Level init pos LeftBottom", self._LevelLeftBottomPositionX, self._LevelLeftBottomPositionY)
        print("Level init pos RightTop", self._LevelRightTopPositionX, self._LevelRightTopPositionY)

        self._LevelLeftBottomPositionX = mathCeil(self._LevelLeftBottomPositionX)
        self._LevelLeftBottomPositionY = mathCeil(self._LevelLeftBottomPositionY)
        self._LevelRightTopPositionX = mathCeil(self._LevelRightTopPositionX)
        self._LevelRightTopPositionY = mathCeil(self._LevelRightTopPositionY)

        print("Level init pos LeftBottom", self._LevelLeftBottomPositionX, self._LevelLeftBottomPositionY)
        print("Level init pos RightTop", self._LevelRightTopPositionX, self._LevelRightTopPositionY)
        self._LevelInitRandomYMin = mathCeil(self._LevelLeftBottomPositionY)
        self._LevelInitRandomYMax = mathCeil(self._LevelRightTopPositionY)
    end
    --如果场景制作时，缺少了节点Node_LeftBottom Node_RightBottom，为了不报错，程序赋默认值
    if self._LevelInitRandomYMin == nil then
        self._LevelInitRandomYMin = 190
    end
    if self._LevelInitRandomYMax == nil then
        self._LevelInitRandomYMax = 490
    end
    --敌我双方的兵营
    local bgSprite = self._LevelNode:getChildByName("BG")
    if selfHomeBuldingSprite ~= nil then
        local selfHomeX, selfHomeY = selfHomeBuldingSprite:getPosition()
        self._SelfStartX = selfHomeX
        if self._LevelLogicType == LevelLogicType.LevelLogicType_PVE then
            local newBuilding = CharacterManager:CreateBuilding()
            local clientID = newBuilding:GetClientGUID()
            newBuilding:IsEnemy(false)
            newBuilding:SetBuildingTotalHP(self._LevelTableData.hp)
            newBuilding:SetCurrentHP(self._LevelTableData.hp)
            newBuilding:SetPosition(selfHomeX, selfHomeY)
            self._SelfSoldierIDList[clientID] = clientID
            self._SelfBattleBuildingID = clientID
        end
    end
    --dump(bgSprite:getContentSize(), "level size")
    self._LevelSize = bgSprite:getContentSize()
    if enemyHomeBuildingSprite ~= nil then
        local enemyHomeX, enemyHomeY = enemyHomeBuildingSprite:getPosition()
        self._EnemyStartX = enemyHomeX
        if self._LevelLogicType == LevelLogicType.LevelLogicType_PVE then
            local newBuilding = CharacterManager:CreateBuilding()
            local clientID = newBuilding:GetClientGUID()
            newBuilding:IsEnemy(true)
            newBuilding:SetBuildingTotalHP(self._LevelTableData.hp)
            newBuilding:SetCurrentHP(self._LevelTableData.hp)
            newBuilding:SetPosition(enemyHomeX, enemyHomeY)
            self._EnemySoldierIDList[clientID] = clientID
            self._EnemyBattleBuildingID = clientID
        end
    end
    --构建场景格子数据
    if self._TileDataTable == nil then
        self._TileDataTable = {}
        local yLength =  mathAbs(self._LevelInitRandomYMax - self._LevelInitRandomYMin)
        local xLength = mathAbs(self._LevelRightTopPositionX - self._LevelLeftBottomPositionX)
        local rowsNumber = mathCeil(yLength / SIZE_ONE_TILE)
        local colsNumber = mathCeil(xLength / SIZE_ONE_TILE )
        for i = 1, rowsNumber do
            self._TileDataTable[i] = {}
            for j = 1, colsNumber do
                local newTileData = TileData.new()
                newTileData._Row = i
                newTileData._Col = j
                newTileData._X = self._LevelLeftBottomPositionX +  (newTileData._Col - 1 )* SIZE_ONE_TILE + SIZE_ONE_TILE / 2
                newTileData._Y =  self._LevelLeftBottomPositionY +  (newTileData._Row - 1)* SIZE_ONE_TILE + SIZE_ONE_TILE / 2
                if ENABLE_LEVEL_TILE_TEST == true then
                    newTileData._TestLabel = cc.Label:createWithTTF("0", "fonts/arial.ttf", 14)
                    newTileData._TestLabel:setPosition(newTileData._X, newTileData._Y)
                    self._LevelNode:addChild(newTileData._TestLabel)
                end
                self._TileDataTable[i][j] = newTileData
            end
        end
    end
    --逻辑
    if self._LevelLogicType == LevelLogicType.LevelLogicType_PVE then
        self:InitPVELogic()
    elseif self._LevelLogicType == LevelLogicType.LevelLogicType_PVE_PVP then
        self:InitPVEPVPLogic()
    elseif self._LevelLogicType == LevelLogicType.LevelLogicType_PVP then
        self:InitPVPLogic()
    elseif self._LevelLogicType == LevelLogicType.LevelLogicType_GuoZhanPVP then
        self:InitGuoZhanPVPLogic()
    end
    
    self._SchedulerID = sharedScheduler:scheduleScriptFunc(function() self.Update(self, 1 / 30) end, 0, false)

end

--销毁
function GameLevel:Destroy()

    sharedScheduler:unscheduleScriptEntry(self._SchedulerID)
    --自定义事件移除
    if self._SoldierDieCallBack ~= nil then
        RemoveEvent(self._SoldierDieCallBack)
        self._SoldierDieCallBack = nil
    end
    if self._LeaderDieCallBack ~= nil then
        RemoveEvent(self._LeaderDieCallBack)
        self._LeaderDieCallBack = nil
    end
    if self._BuildHPChangeCallBack ~= nil then
        RemoveEvent(self._BuildHPChangeCallBack)
        self._BuildHPChangeCallBack = nil
    end
    if self._GuoZhanZhenXingCallBack ~= nil then
        RemoveEvent(self._GuoZhanZhenXingCallBack)
        self._GuoZhanZhenXingCallBack = nil
    end
    if CharacterManager ~= nil then
        CharacterManager:DestroyAllCharacter()
    end
    if SkillManager ~= nil then
        SkillManager:DestroyAllSkill()
    end
    if SkillBuffManager ~= nil then
        SkillBuffManager:DestroyAllBuff()
    end
    if  self._TileTestLabelList ~= nil then
        self._TileTestLabelList = nil
    end
    if  self._GameStartTimerID ~= nil then
        GameGlobal:GetTimerManager():RemoveTimer(self._GameStartTimerID)
        self._GameStartTimerID = nil
    end
    CharacterManager._CurrentTestCount = 0
    SkillManager._CurrentTestCount = 0
    --场景节点移除
    if self._LevelSoldierNode ~= nil then
        self._LevelSoldierNode:removeFromParent(true)
        self._LevelSoldierNode:removeAllChildren()
        self._LevelSoldierNode:release()
        self._LevelSoldierNode = nil
    end
    if self._LevelEffectNode ~= nil then
        self._LevelEffectNode:removeFromParent(true)
        self._LevelEffectNode:removeAllChildren()
        self._LevelEffectNode:release()
        self._LevelEffectNode = nil
    end
    if self._LevelNode ~= nil then
        self._LevelNode:removeFromParent(true)
        self._LevelNode:removeAllChildren()
        self._LevelNode:release()
        self._LevelNode = nil
    end
    
    --table
    self._SelectedSoldiersTable = nil
    self._SelfSoldierIDList = nil
    self._EnemySoldierIDList = nil
    self._SelfOutWuJiaList = nil
    self._EnemyOutWuJiaList = nil
    self._LeaderSkillInfoList = nil
end

--振动
local function ShakeCallBack(node)
    if node == nil then
        return
    end
    local skillGUID = node:getTag()
    local skill = SkillManager:GetSkill(skillGUID)
    if skill == nil then
        return
    end
    --print("ShakeCallBack skill find")
    skill._IsShake = false
end

--振动
function GameLevel:Shake(guid, time, offsetX, offsetY)
    local movedToAct = cc.MoveBy:create(time, cc.p(offsetX,   offsetY))
    local moveBackAct = cc.MoveBy:create(time, cc.p(-1 * offsetX, -1 * offsetY))
    local callback = cc.CallFunc:create(ShakeCallBack)
    local actions = {movedToAct, moveBackAct, callback}
    self._LevelNode:setTag(guid)
    self._LevelNode:runAction(transition.sequence(actions))
end

--设置颜色
local function SetCascadeEnabled(currentNode)
    local children = currentNode:getChildren()
    local childCount = currentNode:getChildrenCount() 
    for i = 1, childCount do
        local node = children[i]
        node:setCascadeColorEnabled(true)
        node:setCascadeOpacityEnabled(true)
        SetCascadeEnabled(node)
    end
end
--设置颜色
local function SetCascadeDisabled(currentNode)
    local children = currentNode:getChildren()
    local childCount = currentNode:getChildrenCount() 
    for i = 1, childCount do
        local node = children[i]
        node:setCascadeColorEnabled(false)
        node:setCascadeOpacityEnabled(false)
        SetCascadeDisabled(node)
    end
end

--重新校正场景的位置
function GameLevel:FixLevelPosition()
    local parentNode = self._LevelNode:getParent()
    if parentNode ~= nil then
        --local parentSpaceSize = parentNode:getContentSize()
        -- dump(parentSpaceSize, "parentSpaceSize")
        local levelContentSize = self._LevelNode:getContentSize()
        dump(levelContentSize, "_LevelNode")
        local winSize = cc.Director:getInstance():getWinSizeInPixels()
        dump(winSize, "winSize")
        local newY = (winSize.height - self._LevelSize.height )/ 2
        self._LevelNode:setPositionX((levelContentSize.width) / 2)
        self._LevelNode:setPositionY(newY + levelContentSize.height / 2)
    end
end
--初始化PVE逻辑
function GameLevel:InitPVELogic()
    self._Finished = false
--    if self._SoldierDieCallBack == nil then
--        self._SoldierDieCallBack = AddEvent(GameEvent.GameEvent_SoldierDie, self.OnSoldierDie)
--    end
--    if self._LeaderDieCallBack == nil then
--        self._LeaderDieCallBack = AddEvent(GameEvent.GameEvent_LeaderDie, self.OnLeaderDie)
--    end
--    if self._BuildHPChangeCallBack == nil then
--        self._BuildHPChangeCallBack = AddEvent(GameEvent.GameEvent_BuildHPChange, self.OnCityHPChange)
--    end
    --self._LevelMaxPeopleRound = self._LevelTableData.maxpeo
    --self._LevelInitFoodCount = self._LevelTableData.food
    self._TrigerSoldierTime = 0
    self._TrigerEnemySoldierTime = 0
    self._CurrentRoundTime = self._ROUNDTIME
    self._CurrentRoundCount = 1
    --
    self._CurrentRoundFood = self._LevelInitFoodCount
    self._CurrentOutputFood = self._LevelInitFoodCount
    self._CurrentRoundPeopleCount = self._LevelMaxPeopleRound
    self:SetCurrentRoundPeople(0)
    self._CurrentEnemySoldierWaveCount = 0
    self._CurrentWaveEnemySoldierCount = 0
    self._CurrentEnemyTrigerSoldierTimer = self._ENEMY_SOLDIERTIME
    self._LeaderSkillInfoList = {}
    --解析关卡出兵数据
    local currentString =  self._LevelTableData.bingList
    local currentIndex = 0
    while currentString ~= nil and currentString ~= "" do
        local tagPosStart = stringFind(currentString,"%(")
        local tagPosEnd = stringFind(currentString,"%)")
        local info = stringSub(currentString, tagPosStart + 1, tagPosEnd - 1)
        local infoList = Split(info, ",")
        local newWaveSoldierInfo = WaveSoldierInfo.new()
        newWaveSoldierInfo._WaveSoldierTableID = tonumber(infoList[1])
        newWaveSoldierInfo._WaveSoldierCount = tonumber(infoList[2])
        newWaveSoldierInfo._WaveSoldierLevel = tonumber(infoList[3])
        currentString = stringSub(currentString, tagPosEnd + 1)
        currentIndex = currentIndex + 1
        self._AllWaveEnemySoldierList[currentIndex] = newWaveSoldierInfo
    end

    --将army.txt中的数据存到以1开始的key的table: self._TestArmyList
    self._TestArmyList = {}
    local currentIndex = 0
    for k, v in pairs(CharacterDataManager)do
        currentIndex = currentIndex + 1
        self._TestArmyList[currentIndex] = k
    end

    self._GameStartTimeCount = 3
    self._GameStartTimerID = 0
    DispatchEvent(GameEvent.GameEvent_UIBattle_RefreshRoundTimer, {roundTime = self._GameStartTimeCount})

end
--初始化PVE中的PVP逻辑
function GameLevel:InitPVEPVPLogic()
    self._Finished = false
    if self._SoldierDieCallBack == nil then
        self._SoldierDieCallBack = AddEvent(GameEvent.GameEvent_SoldierDie, self.OnSoldierDie)
    end
    if self._LeaderDieCallBack == nil then
        self._LeaderDieCallBack = AddEvent(GameEvent.GameEvent_LeaderDie, self.OnLeaderDie)
    end
    if self._LevelTableData ~= nil then
        self._PVEPVPConfigID = self._LevelTableData.pvp
    end
    self._PVPSelfTotalHP = 0
    self._PVPEnemyTotalHP = 0
end
--设置缩放
function GameLevel:SetTimeScale(scale)
    if self._LevelNode ~= nil then
        --self._LevelNode:setTimeScale(scale)
    end
end
--暂停
function GameLevel:Pause(isPause)
    local  pDirector = cc.Director:getInstance()
    local scheduler = pDirector:getScheduler()
    self._IsPause = isPause
    if isPause == true then
        --pDirector:getActionManager():pauseTarget(self._LevelNode)
        --scheduler:setTimeScale(0)
        self._CurrentPauseTargets = pDirector:getActionManager():pauseAllRunningActions()
    else
        --pDirector:getActionManager():resumeTarget(self._LevelNode)
        --scheduler:setTimeScale(1)
        if self._CurrentPauseTargets ~= nil then
            pDirector:getActionManager():resumeTargets(self._CurrentPauseTargets)
            self._CurrentPauseTargets = nil
        end

    end
end
 --
 
--初始化沙场PVP逻辑
function GameLevel:InitPVPLogic()
    self._Finished = false
    self:addEvent(GameEvent.GameEvent_SoldierDie, self.OnSoldierDie)
    self:addEvent(GameEvent.GameEvent_LeaderDie, self.OnLeaderDie)

    self._PVPSelfTotalHP = 0
    self._PVPEnemyTotalHP = 0
end

--初始化国战PVP
function GameLevel:InitGuoZhanPVPLogic()
    self._Finished = false
    self:addEvent(GameEvent.GameEvent_GuoZhan_ZhenXingDataRefresh, self.OnGuoZhanZhenXingRefresh)
    self:addEvent(GameEvent.GameEvent_SoldierDie, self.OnSoldierDie)
    self:addEvent(GameEvent.GameEvent_LeaderDie, self.OnLeaderDie)

    self._PVPSelfTotalHP = 0
    self._PVPEnemyTotalHP = 0
end

--创建阵形数据(小兵阵形)
function GameLevel:CreateZhenXingData(armyData, dataTable, startRow, startCol, level,  hp, attack)
    if armyData == nil or dataTable == nil then
        return
    end
    local people = armyData.people
    if people == 1 then
        for row = 1, 5 do
            for col = 1, 4 do
                local levelZhenXingData = ZhenXingData:new()
                levelZhenXingData._ArmyTableID = armyData.id
                levelZhenXingData._TileRow = startRow + ZHEN_XING_PEO_1[row][col][1]
                levelZhenXingData._TileCol = startCol + ZHEN_XING_PEO_1[row][col][2]
                levelZhenXingData._HP = hp
                levelZhenXingData._Level = level
                levelZhenXingData._Attack = attack
                table.insert(dataTable, levelZhenXingData)
            end
        end
    elseif people == 5 then
        for row = 1, 2 do
            for col = 1, 2 do
                local levelZhenXingData = ZhenXingData:new()
                levelZhenXingData._ArmyTableID = armyData.id
                levelZhenXingData._TileRow = startRow + ZHEN_XING_PEO_5[row][col][1]
                levelZhenXingData._TileCol = startCol + ZHEN_XING_PEO_5[row][col][2]
                levelZhenXingData._Level = level
                levelZhenXingData._HP = hp
                levelZhenXingData._Attack = attack
                table.insert(dataTable, levelZhenXingData)
            end
        end
    elseif people == 10 then
        for row = 1, 2 do
            local levelZhenXingData = ZhenXingData:new()
            levelZhenXingData._ArmyTableID = armyData.id
            levelZhenXingData._TileRow = startRow + ZHEN_XING_PEO_10[row][1]
            levelZhenXingData._TileCol = startCol + ZHEN_XING_PEO_10[row][2]
            levelZhenXingData._Level = level
            levelZhenXingData._HP = hp
            levelZhenXingData._Attack = attack
            table.insert(dataTable, levelZhenXingData)
        end
    end
end
--初始化已方PVE中的PVP阵形数据
function GameLevel:InitSelfPVEPVPZhenXing()
    -- local zhenXingServerData = Characters
    local TableDataManager = GameGlobal:GetDataTableManager()
    local armyDataTable = TableDataManager:GetCharacterDataManager()
    local CharacterServerDataManager = GameGlobal:GetCharacterServerDataManager()
    local BattleServerDataManager = GameGlobal:GetBattleServerDataManager()
    self._PVEPVPSelectZhenXingIndex = BattleServerDataManager._CurrentPVEPVPZhenXing
    local currentData =  CharacterServerDataManager:GetZhenXingData(self._PVEPVPSelectZhenXingIndex)
    if  currentData ~= nil then
        self._SelfZhengXingList = {}
        for k, v in pairs(currentData)do
            local wuJiangTableID = v._WuJiangTableID
            local soldierTableID = v._SoldierTableID
            local startRow = v._ZhenXingStartRow - 1
            local startCol = v._ZhenXingStartCol - 1
            --武将
            local levelZhenXingData = ZhenXingData:new()
            levelZhenXingData._ArmyTableID = wuJiangTableID
            levelZhenXingData._TileRow = startRow + ZHEN_XING_WUJIANG_POS[1][1]
            levelZhenXingData._TileCol = startCol + ZHEN_XING_WUJIANG_POS[1][2]
            table.insert(self._SelfZhengXingList, levelZhenXingData)
            local armyData =  armyDataTable[soldierTableID]
            self:CreateZhenXingData(armyData, self._SelfZhengXingList, startRow, startCol)
        end
    end
end

--初始化已方PVP阵形数据(数据结构转换为GameLevel内用的,统一PVP与PVE逻辑数据结构)
function GameLevel:InitSelfPVPZhenXing()
    local TableDataManager = GameGlobal:GetDataTableManager()
    local armyDataTable = TableDataManager:GetCharacterDataManager()
    local CharacterServerDataManager = GameGlobal:GetCharacterServerDataManager()
    local currentData = CharacterServerDataManager._SelfShaChangData
    if  currentData ~= nil then
        self._SelfShaChangPVPZhenXing = {}
        for k, v in pairs(currentData)do
            local wuJiangTableID = v._WuJiangTableID
            local soldierTableID = v._SoldierTableID
            local startRow = v._ZhenXingStartRow - 1
            local startCol = v._ZhenXingStartCol - 1
            --武将
            local levelZhenXingData = ZhenXingData:new()
            levelZhenXingData._ArmyTableID = wuJiangTableID
            levelZhenXingData._TileRow = startRow + ZHEN_XING_WUJIANG_POS[1][1]
            levelZhenXingData._TileCol = startCol + ZHEN_XING_WUJIANG_POS[1][2]
            levelZhenXingData._HP = v._WuJiangHP
            levelZhenXingData._Attack = v._WuJiangAttack
            levelZhenXingData._Level = v._WuJiangLevel
            table.insert(self._SelfShaChangPVPZhenXing, levelZhenXingData)
            local armyData =  armyDataTable[soldierTableID]
            self:CreateZhenXingData(armyData, self._SelfShaChangPVPZhenXing, startRow, startCol,v._SoldierLevel, v._SoldierHP, v._SoldierAttack)
        end
    end
end
--初始化敌方PVP阵形数据
function GameLevel:InitEnemyPVPZhenXing()
    local TableDataManager = GameGlobal:GetDataTableManager()
    local armyDataTable = TableDataManager:GetCharacterDataManager()
    local CharacterServerDataManager = GameGlobal:GetCharacterServerDataManager()
    local currentData = CharacterServerDataManager._EnemyShaChangData
    if  currentData ~= nil then
        self._EnemyShaChangPVPZhenXing = {}
        for k, v in pairs(currentData)do
            local wuJiangTableID = v._WuJiangTableID
            local soldierTableID = v._SoldierTableID
            local startRow = v._ZhenXingStartRow - 1
            local startCol = v._ZhenXingStartCol - 1
            --武将
            local levelZhenXingData = ZhenXingData:new()
            levelZhenXingData._ArmyTableID = wuJiangTableID
            levelZhenXingData._TileRow = startRow + ZHEN_XING_WUJIANG_POS[1][1]
            levelZhenXingData._TileCol = startCol + ZHEN_XING_WUJIANG_POS[1][2]
            levelZhenXingData._HP = v._WuJiangHP
            levelZhenXingData._Attack = v._WuJiangAttack
            levelZhenXingData._Level = v._WuJiangLevel
            table.insert(self._EnemyShaChangPVPZhenXing, levelZhenXingData)
            local armyData =  armyDataTable[soldierTableID]
            self:CreateZhenXingData(armyData, self._EnemyShaChangPVPZhenXing, startRow, startCol,v._SoldierLevel, v._SoldierHP, v._SoldierAttack)
        end
    end
end
--初始化敌方PVE阵形数据
function GameLevel:InitEnemyPVEZhenXing()
    local TableDataManager = GameGlobal:GetDataTableManager()
    local armyDataTable = TableDataManager:GetCharacterDataManager()
    local CharacterServerDataManager = GameGlobal:GetCharacterServerDataManager()
    local zhenXingConfig = TableDataManager:GetPVPLevelConfigDataManager()
    local currentData = zhenXingConfig[self._PVEPVPConfigID]
    if  currentData ~= nil then
        self._EnemyPVEZhenXingList = {}
        for k, v in pairs(currentData)do
            local wuJiangTableID = v._WuJiangTableID
            local soldierTableID = v._SoldierTableID
            local startRow = v._ZhenXingStartRow - 1
            local startCol = v._ZhenXingStartCol - 1
            --武将
            local levelZhenXingData = ZhenXingData:new()
            levelZhenXingData._ArmyTableID = wuJiangTableID
            levelZhenXingData._TileRow = startRow + ZHEN_XING_WUJIANG_POS[1][1]
            levelZhenXingData._TileCol = startCol + ZHEN_XING_WUJIANG_POS[1][2]
            levelZhenXingData._Level = v._Level
            
            table.insert(self._EnemyPVEZhenXingList, levelZhenXingData)
            local armyData =  armyDataTable[soldierTableID]
            self:CreateZhenXingData(armyData, self._EnemyPVEZhenXingList, startRow, startCol,v._Level)
        end
    end
end

--设置关卡状态
function GameLevel:SetLevelState(levelState)
    if levelState ~= self._CurrentLevelState then
        DispatchEvent(GameEvent.GameEvent_LevelStateChange, {levelState = levelState})
        self._CurrentLevelState = levelState
        if self._CurrentLevelState == LevelState.LevelState_WillStart then
            if self._LevelLogicType == LevelLogicType.LevelLogicType_PVE then
                self._GameStartTimerID = GameGlobal:GetTimerManager():AddTimer(1, GameLevel.UpdateGameStartTime)
                --PVE中的PVP
            elseif self._LevelLogicType == LevelLogicType.LevelLogicType_PVE_PVP then
                self._GameStartTimerID = GameGlobal:GetTimerManager():AddTimer(1, GameLevel.UpdateGameStartTime)
                if  self._PVEPVPConfigID ~= nil and self._PVEPVPConfigID ~= 0 then
                    --已方根据CharacterServerManager中的数据转化为GameLevel的阵型数据结构
                    self:InitSelfPVEPVPZhenXing()
                    self:InitEnemyPVEZhenXing()
--                    --有阵型数据
                    local tempZhenXingConfig = TableDataManager:GetPVPLevelConfigDataManager()
                    if self._SelfZhengXingList ~= nil and #self._SelfZhengXingList > 0 then
                        --初始化已方阵型兵
                        for k, v in pairs(self._SelfZhengXingList)do
                            self:AddSelfPVEPVPSoldier(v)
                        end
                    else
                        --没有阵型数据，取临时测试数据
                        --初始化已方阵型兵
                        for k, v in pairs(self._EnemyPVEZhenXingList)do
                            self:AddSelfPVEPVPSoldier(v)
                        end
                    end

                    --敌方取配置表中的数据
                    for k, v in pairs(self._EnemyPVEZhenXingList)do
                        self:AddEnemyPVEPVPSoldier(v)
                    end
--                    DispatchEvent(GameEvent.GameEvent_PVPTotalHP, {selfHP = self._PVPSelfTotalHP, enemyHP = self._PVPEnemyTotalHP})
                end
                --沙场点兵PVP  
            elseif self._LevelLogicType == LevelLogicType.LevelLogicType_PVP then
                self._GameStartTimerID = GameGlobal:GetTimerManager():AddTimer(1, GameLevel.UpdateGameStartTime)
                --根据CharacterServerManager中的数据(服务器下发)转化为GameLevel的阵型数据结构
                self:InitSelfPVPZhenXing()
                self:InitEnemyPVPZhenXing()
                --初始化双方阵形兵
                for k, v in pairs(self._SelfShaChangPVPZhenXing)do
                    self:AddSelfPVPSoldier(v)
                end
                for k, v in pairs(self._EnemyShaChangPVPZhenXing)do
                    self:AddEnemyPVPSoldier(v)
                end
                DispatchEvent(GameEvent.GameEvent_PVPTotalHP, {selfHP = self._PVPSelfTotalHP, enemyHP = self._PVPEnemyTotalHP})
                --国战士兵初始化
            elseif self._LevelLogicType == LevelLogicType.LevelLogicType_GuoZhanPVP then
                if  self._GameStartTimerID ~= nil then
                    GameGlobal:GetTimerManager():RemoveTimer(self._GameStartTimerID)
                    self._GameStartTimerID = nil
                end
                self._GameStartTimerID = GameGlobal:GetTimerManager():AddTimer(1, GameLevel.UpdateGameStartTime)
                self:InitGuoZhanPVPSoldiers()
                DispatchEvent(GameEvent.GameEvent_PVPTotalHP, {selfHP = self._PVPSelfTotalHP, enemyHP = self._PVPEnemyTotalHP})
            end
        end
    end
end
--更新地图格子数据
function GameLevel:UpdateLevelTileData(oldPositionX, oldPositionY, newPositionX, newPositionY, clientID)
    if clientID == nil or clientID == 0 then
        return
    end
    oldPositionX = oldPositionX - self._LevelLeftBottomPositionX
    oldPositionY = oldPositionY - self._LevelLeftBottomPositionY
    newPositionX = newPositionX - self._LevelLeftBottomPositionX
    newPositionY = newPositionY - self._LevelLeftBottomPositionY
    local oldTileRow = mathCeil(oldPositionY / SIZE_ONE_TILE)
    local oldTileCol = mathCeil(oldPositionX / SIZE_ONE_TILE)
    local newTileRow = mathCeil(newPositionY / SIZE_ONE_TILE)
    local newTileCol = mathCeil(newPositionX / SIZE_ONE_TILE)
    local oldRowTileData = self._TileDataTable[oldTileRow]
    local oldTileData = nil
    if oldRowTileData ~= nil then
        oldTileData = oldRowTileData[oldTileCol]
    end
    if oldTileData ~= nil then
        oldTileData._IDList[clientID] = nil
    end
    local newRowTileData = self._TileDataTable[newTileRow]
    local newTileData =  nil
    if newRowTileData ~= nil then
        newTileData = newRowTileData[newTileCol]
    end
    if newTileData ~= nil then
        newTileData._IDList[clientID] = clientID
    end


    ----测试代码，显示Tile的数据
    if ENABLE_LEVEL_TILE_TEST == false then
        return
    end
    if oldTileRow == newTileRow and oldTileCol == newTileCol then
        return
    end

    if oldTileData ~= nil then
        local count = 0
        for k, v in pairs(oldTileData._IDList)do
            count = count + 1
        end
        local oldLabel = oldTileData._TestLabel
        if oldLabel ~= nil then
            oldLabel:setString(tostring(count))
        end
    end

    if newTileData ~= nil then
        local count = 0
        for k, v in pairs(newTileData._IDList)do
            count = count + 1
        end
        local newLabel = newTileData._TestLabel
        if newLabel ~= nil then
            newLabel:setString(tostring(count))
        end
    end

    --print("UpdateLevelTileData ", oldTileRow, oldTileCol, newTileRow, newTileCol, clientID)
end
--格子内是否存在攻击者
function GameLevel:IsAttackerInTile(characterInstance)
    if characterInstance == nil then
        return false
    end
    --print("GameLevel:IsAttackerInTile enter", os.date())
    local isHaveAttack = false
    local currentCount = 0
    local currentX = characterInstance._CharacterPositionX - self._LevelLeftBottomPositionX
    local currentY = characterInstance._CharacterPositionY - self._LevelLeftBottomPositionY
    if currentX >= 0 and currentY >= 0 then
        local colsIndex = mathCeil(currentX / SIZE_ONE_TILE)
        local rowsIndex =  mathCeil(currentY /  SIZE_ONE_TILE)
        local currentRowTable = self._TileDataTable[rowsIndex]
        if currentRowTable ~= nil then
            local tileInfo = currentRowTable[colsIndex]
            if tileInfo ~= nil then
                for k, v in pairs(tileInfo._IDList)do
                    local currentCharacter = CharacterManager:GetCharacterByClientID(k)
                    if currentCharacter ~= nil and currentCharacter ~= characterInstance then
                        if characterInstance._IsEnemy == currentCharacter._IsEnemy then
                            if currentCharacter:GetCurrentState() == CharacterState.CharacterState_Attack then
                                currentCount = currentCount + 1
                               -- print("GameLevel:IsAttackerInTile ", currentCount, rowsIndex, colsIndex,  os.date())
                                if currentCount >= 1 then
                                    isHaveAttack = true
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return isHaveAttack
end
--获取某个格子是否被占（有同伴在攻击）
function GameLevel:IsHaveAttackerInTileRowCol(characterInstance, row, col)
    if characterInstance == nil then
        return -1
    end
    -- print("GameLevel:IsHaveAttackerInTileRowCol enter", os.date())

    local currentRowTable = self._TileDataTable[row]
    if currentRowTable == nil then
        return -1
    end
    local tileInfo = currentRowTable[col]
    if tileInfo == nil then
        return -1
    end
    local isHaveAttack = false
    local currentCount = 0
    for k, v in pairs(tileInfo._IDList)do
        local currentCharacter = CharacterManager:GetCharacterByClientID(k)
        if currentCharacter ~= nil and currentCharacter ~= characterInstance then
            if characterInstance._IsEnemy == currentCharacter._IsEnemy then
                if currentCharacter:GetCurrentState() == CharacterState.CharacterState_Attack then
                    currentCount = currentCount + 1
                    if currentCount >= 1 then
                        isHaveAttack = true
                        break
                    end
                end
            end
        end
    end
    return isHaveAttack
end

--获取目标所在的格子
function GameLevel:GetTileByXY(x, y)
    local currentX = x - self._LevelLeftBottomPositionX
    local currentY = y - self._LevelLeftBottomPositionY
    local colsIndex = mathCeil(currentX / SIZE_ONE_TILE)
    local rowsIndex =  mathCeil(currentY /  SIZE_ONE_TILE)
    return rowsIndex, colsIndex
end
--获取某个Tile的XY
function GameLevel:GetXYByTile(row, col)
    local x = self._LevelLeftBottomPositionX +  (col - 1 )* SIZE_ONE_TILE + SIZE_ONE_TILE / 2
    local y =  self._LevelLeftBottomPositionY +  (row - 1)* SIZE_ONE_TILE + SIZE_ONE_TILE / 2
    return x, y
end
--开始战斗倒计时Timer
function GameLevel.UpdateGameStartTime()
    local currentLevel = GameGlobal:GetGameLevel()
    if currentLevel ~= nil then
        currentLevel._GameStartTimeCount = currentLevel._GameStartTimeCount - 1
        DispatchEvent(GameEvent.GameEvent_UIBattle_RefreshRoundTimer, {roundTime = currentLevel._GameStartTimeCount})
        if  currentLevel._GameStartTimeCount == 0 then
            GameGlobal:GetTimerManager():RemoveTimer(currentLevel._GameStartTimerID)
            currentLevel._GameStartTimerID = 0
            currentLevel:SetLevelState(LevelState.LevelState_Runing)
            if currentLevel._LevelLogicType == LevelLogicType.LevelLogicType_PVE then
                local roundDataManager = TableDataManager:GetPVERoundDataManager()
                local roundData = roundDataManager[currentLevel._CurrentRoundCount]
                currentLevel:SetCurrentRoundPeople(roundData.peo)
            end
        end
    end
end

--更新
function GameLevel:Update(deltaTime)
    if self._Finished == true then
        return
    end
    if self._IsPause == true then
        if self._CurrentUpdateSkillGUID ~= 0 then
            local currentSkill =  SkillManager:GetSkill(self._CurrentUpdateSkillGUID) 
            if currentSkill ~= nil then
                currentSkill:Update(deltaTime)
            end
        end
        return
    end
    
    if self._CurrentLevelState == LevelState.LevelState_Invalid then
        self:SetLevelState(LevelState.LevelState_WillStart)
        return
    end
    if self._CurrentLevelState ~= LevelState.LevelState_Runing then
        return
    end
    if self._LevelLogicType == LevelLogicType.LevelLogicType_PVE then
        self:UpdatePVE(deltaTime)
    end
end

--PVE逻辑帧s
function GameLevel:UpdatePVE(deltaTime)
    local selfBattleCity = CharacterManager:GetCharacterByClientID()
    SkillManager:Update(deltaTime)
    if UISystem == nil then
        UISystem = require("main.UI.UISystem")
    end
   
    --技能CD更新
    for k, v in pairs(self._LeaderSkillInfoList)do
        if v ~= nil and v._IsEnable == true then
            local battleUI = UISystem:GetUIInstance(UIType.UIType_BattleUI)
            local targetCharacter = CharacterManager:GetCharacterByClientID(v._LeaderClientID)
            if targetCharacter ~= nil then
                if v._CurrentSkillLeft > 0 then
                    v._CurrentSkillLeft = v._CurrentSkillLeft - deltaTime
                end
                if v._CurrentSkillLeft < 0 then
                    v._CurrentSkillLeft = 0
                end
                local percent = mathCeil( v._CurrentSkillLeft / v._SkillInterval * 100)
                --新添加的技能段 相关 add 9.21
                if v._CurrentSkillLeft == 0 then
                    v._CurrentSkillStage = v._CurrentSkillStage + 1
                    if v._CurrentSkillStage >= v._SkillStageCount  then
                        v._IsEnable = false
                    else
                        --设置成下一阶数据
                        v._IsEnable = true
                        local nextStage = v._CurrentSkillStage + 1
                        local nextTableID = v._SkillTableIDList[nextStage]
                        if nextTableID ~= nil and nextTableID ~= 0 then
                            v._CurrentSkillLeft = v._SkillCDList[nextStage]
                            v._SkillInterval = v._SkillCDList[nextStage]
                        else
                            v._IsEnable = false
                        end
                    end
                end
                if battleUI ~= nil then
                   battleUI:UpdateSkillCD(targetCharacter._CharacterData.id, percent, v)
                end
            end
        end
    end

    -- 出兵逻辑
    self._TrigerSoldierTime = self._TrigerSoldierTime + deltaTime
    local lastRoundTimeSecond = mathFloor(self._CurrentRoundTime)
    self._CurrentRoundTime =  self._CurrentRoundTime - deltaTime
    local currentRoundTimeSecond = mathFloor(self._CurrentRoundTime)
    --我方出兵
    
    if self._CurrentRoundPeopleCount > 0 then
        if self._TrigerSoldierTime >= self._TrigerSoldierInterval then
            self._TrigerSoldierTime = 0
            for k, v in pairs(self._SelectedSoldiersTable)do
                if v == true then
                    local characterData =  CharacterDataManager[k]
                    if characterData ~= nil then
                        if self:IsCanOutCharacter(k) ==  true then
                            if characterData.type == CharacterType.CharacterType_Soldier then
                                local x = mathRandom(128, self._SelfStartX)
                                local row = mathRandom(1, 16)
                                Fight:addPveUnit(1, 0, k, nil, math.floor(x / 16), row, self._LevelTableID)
                                self:SetCurrentRoundPeople(self._CurrentRoundPeopleCount - characterData.people)
                                
                                --DispatchEvent(GameEvent.GameEvent_SmallMap_CreateCharacter,{clientID = currentNewSoldier:GetClientGUID()})
                            elseif characterData.type == CharacterType.CharacterType_Leader then
                                --武将只出一次
                                if self._SelfOutWuJiaList[k] == nil then
                                    local x = mathRandom(128, self._SelfStartX)
                                    local row = mathRandom(1, 15)
                                    local unit = Fight:addPveUnit(1, 1, k, nil, math.floor(x / 16), row, self._LevelTableID)
                                    local currentNewSoldier = self:AddSoldier(k, unit)
                                    self:SetCurrentRoundPeople(self._CurrentRoundPeopleCount - characterData.people)
                                    self._SelfOutWuJiaList[k] = true
                                    DispatchEvent(GameEvent.GameEvent_OutLeader, k)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    --敌方出兵
    self._CurrentEnemyTrigerSoldierTimer = self._CurrentEnemyTrigerSoldierTimer + deltaTime
    if self._CurrentEnemyTrigerSoldierTimer >= self._ENEMY_SOLDIERTIME then
        self._CurrentEnemyTrigerSoldierTimer = 0
        self._CurrentWaveEnemySoldierCount = 0
        self._CurrentEnemySoldierWaveCount = self._CurrentEnemySoldierWaveCount + 1
    end
    
    local enemyWaveCount = #self._AllWaveEnemySoldierList
    if self._CurrentEnemySoldierWaveCount <  enemyWaveCount then
        self._TrigerEnemySoldierTime = self._TrigerEnemySoldierTime + deltaTime
        local currentWaveInfo = self._AllWaveEnemySoldierList[self._CurrentEnemySoldierWaveCount]
        local currentWaveMaxSoldierCount = currentWaveInfo._WaveSoldierCount
        local tableID = currentWaveInfo._WaveSoldierTableID
        local characterData =  CharacterDataManager[tableID]
        if self._CurrentWaveEnemySoldierCount < currentWaveMaxSoldierCount then
            if self._TrigerEnemySoldierTime >= self._TrigerSoldierInterval then
                self._TrigerEnemySoldierTime = 0
                if characterData ~= nil then
                    if characterData.type == CharacterType.CharacterType_Soldier then
                        local x = mathRandom(self._EnemyStartX - 85, self._EnemyStartX)
                        local row = mathRandom(1, 16)
                        Fight:addPveUnit(0, 0, tableID, currentWaveInfo._WaveSoldierLevel, math.floor(x / 16), row , self._LevelTableID)
                        self._CurrentWaveEnemySoldierCount = self._CurrentWaveEnemySoldierCount + 1
                        --DispatchEvent(GameEvent.GameEvent_SmallMap_CreateCharacter,{clientID = currentNewSoldier:GetClientGUID()})
                    elseif characterData.type == CharacterType.CharacterType_Leader then
                        if self._EnemyOutWuJiaList ~= nil then
                            if self._EnemyOutWuJiaList[tableID] == nil then
                                local x = mathRandom(self._EnemyStartX, self._EnemyStartX - 85)
                                local row = mathRandom(1, 16)
                                Fight:addPveUnit(0, 1, tableID, currentWaveInfo._WaveSoldierLevel, math.floor(x / 16), row, self._LevelTableID)
                                
                                self._CurrentWaveEnemySoldierCount = self._CurrentWaveEnemySoldierCount + 1
                                self._EnemyOutWuJiaList[tableID] = true
                              --  DispatchEvent(GameEvent.GameEvent_SmallMap_CreateCharacter,{clientID = currentNewSoldier:GetClientGUID()})
                            end
                        end
                    end
                end
            end
        end
    end

    -- 回合倒计时刷新时间
    if lastRoundTimeSecond ~= currentRoundTimeSecond then
        DispatchEvent(GameEvent.GameEvent_UIBattle_RefreshRoundTimer, {roundTime = currentRoundTimeSecond + 1})
    end
    --当前回合结束
    if self._CurrentRoundTime <= 0 then
        self._CurrentRoundTime = self._ROUNDTIME
        if self._CurrentRoundCount < 10 then
            local newPeopleCount = 0
            if TableDataManager == nil then
                TableDataManager = GameGlobal:GetDataTableManager()
            end
            local roundDataManager = TableDataManager:GetPVERoundDataManager()
            local roundData = roundDataManager[self._CurrentRoundCount + 1]
            if roundData ~= nil then
                self:SetCurrentRoundPeople(self._CurrentRoundPeopleCount + roundData.peo)
            end
        end
        self._CurrentRoundCount = self._CurrentRoundCount + 1
        DispatchEvent(GameEvent.GameEvent_UIBattle_RefreshRound, {round = self._CurrentRoundCount})
    end
end

-- 已方单位还有活着的
function GameLevel:IsHaveSelfSoldier()
    local currentCount = 0
    for k, v in pairs(self._SelfSoldierIDList)do
        currentCount = currentCount + 1
        break
    end
    if currentCount > 0 then
        return true
    end
    return false
end

--敌方单位还有活着的吗
function GameLevel:IsHaveEnemySoldier()
    local currentCount = 0
    for k, v in pairs(self._EnemySoldierIDList)do
        currentCount = currentCount + 1
        break
    end
    if currentCount > 0 then
        return true
    end
    return false
end
--PVE中的PVP逻辑帧(20关阵形通关逻辑)
function GameLevel:PVEPVPUpdate(deltaTime)
    --是否结束判定
    if self:IsHaveSelfSoldier() == false then
        self._BattleResult = BattleResult.BattleResult_Lose
    end
    if self:IsHaveEnemySoldier() == false then
        self._BattleResult = BattleResult.BattleResult_Win
    end
    if self._BattleResult ~= nil and self._BattleResult ~= -1 then
        DispatchEvent(GameEvent.GameEvent_UIBattle_BattleResult, {battleResult = self._BattleResult, round = self._CurrentRoundCount})
        self._Finished = true
        return
    end
    --
    CharacterManager:Update(deltaTime)
    SkillManager:Update(deltaTime)
    SkillBuffManager:Update(deltaTime)
end
--国战PVP逻辑帧
function GameLevel:GuoZhanPVPUpdate(deltaTime)
    --是否结束判定
    if self:IsHaveSelfSoldier() == false then
        self._BattleResult = BattleResult.BattleResult_Lose
    end
    if self:IsHaveEnemySoldier() == false then
        self._BattleResult = BattleResult.BattleResult_Win
    end

    if self._BattleResult ~= nil and self._BattleResult ~= -1 then
        --DispatchEvent(GameEvent.GameEvent_UIBattle_BattleResult, {battleResult = self._BattleResult, round = self._CurrentRoundCount})
        print("GameLevel _Finished ......", self._CurrentGuoZhanID, os.date(),  self._CurrentStartTime)
        self._Finished = true
        --LogSystem:Output()
        return
    end
    --
    CharacterManager:Update(deltaTime)
    SkillManager:Update(deltaTime)
    SkillBuffManager:Update(deltaTime)
end

--获取武将技能CD信息
function GameLevel:GetLeaderSkillInfo(leaderTableID)
    return self._LeaderSkillInfoList[leaderTableID]
end
--设置技能
function GameLevel:SetLeaderSkillCurrentCD(leaderTableID, currentTime)
    -- print("SetLeaderSkillCurrentCD", leaderTableID, currentTime)
    local currentSkillInfo = self._LeaderSkillInfoList[leaderTableID]
    if currentSkillInfo ~= nil then
        currentSkillInfo._CurrentSkillLeft = currentTime
    end
end
--重置
function GameLevel:ResetLeaderSkill(leaderTableID)
    local currentSkillInfo = self._LeaderSkillInfoList[leaderTableID]
    if currentSkillInfo ~= nil then
        currentSkillInfo._CurrentSkillStage = 0
        currentSkillInfo._CurrentSkillLeft = currentSkillInfo._SkillCDList[1]
    end
end
--设置
function GameLevel:GetCurrentLeaderSkillHurtFactor(leaderTableID)
    local currentSkillInfo = self._LeaderSkillInfoList[leaderTableID]
    if currentSkillInfo ~= nil then
        local stage = currentSkillInfo._CurrentSkillStage
       return  currentSkillInfo._SKillHurtFactorList[stage]
    end
end
--设置当前回合的人口
function GameLevel:SetCurrentRoundPeople(people)
    if people ~= self._CurrentRoundPeopleCount then
        self._CurrentRoundPeopleCount = people
        DispatchEvent(GameEvent.GameEvent_UIBattle_PeopleChange, {roundPeople = people})
    end
end
--设置当前回合的粮草
function GameLevel:SetCurrentRoundConsumeFood(food)
    if food ~= self._CurrentRoundFood then
        self._CurrentRoundFood = food
        DispatchEvent(GameEvent.GameEvent_UIBattle_RoundFoodChange, {roundFood = food})
    end
end
--设置当前的粮草产出
function GameLevel:SetCurrentOutFood(food)
    if food ~= self._CurrentOutputFood then
        self._CurrentOutputFood = food
        DispatchEvent(GameEvent.GameEvent_UIBattle_OutFoodChange, {roundFood = food})
    end
end

--设置当前的数目
function GameLevel:SetCurrentCharacterCount(currentCount)
    if currentCount ~= self._CurrentCharacterCount then
        DispatchEvent(GameEvent.GameEvent_UIBattle_TestSoldierNumber, {characterCount = currentCount})
    end
    self._CurrentCharacterCount = currentCount
end

-- 是否能出
function GameLevel:IsCanOutCharacter(tableID)
    local characterData = CharacterDataManager[tableID]
    if  characterData.people <= self._CurrentRoundPeopleCount then
        return true
    end
    return false
end

--选中某兵种
function GameLevel:SetSelected(tableID, isSelected)
    self._SelectedSoldiersTable[tableID] = isSelected
end
--关卡根结点
function GameLevel:GetRootNode()
    return self._LevelNode
end

--使关卡变暗
function GameLevel:DarkLevel(currentCharacter)
    if self._LevelNode ~= nil then
        SetCascadeEnabled(self._LevelNode)
        self._LevelNode:setColor(cc.c3b(128, 128, 128))
        self._LevelNode:setOpacity(100)
        if currentCharacter ~= nil then
            local characterRootNode = currentCharacter:GetCharacterNode()
            if characterRootNode ~= nil then
                characterRootNode:setCascadeColorEnabled(false)
                characterRootNode:setCascadeOpacityEnabled(false)
                characterRootNode:setColor(display.COLOR_WHITE)
            end
        end
    end
end
--使关卡恢复
function GameLevel:DeDarkLevel()
    if self._LevelNode ~= nil then
        SetCascadeDisabled(self._LevelNode)
        self._LevelNode:setColor(display.COLOR_WHITE)
        self._LevelNode:setOpacity(255)
    end
end

--设置当前要突显的技能
function GameLevel:SetCurrentWuJiangSkill(skillClientID)
    self._CurrentUpdateSkillGUID = skillClientID
    local currentSkill =  SkillManager:GetSkill(self._CurrentUpdateSkillGUID) 
    if currentSkill ~= nil then
        local skillRootNode = currentSkill:GetSkillRootNode()
        if skillRootNode ~= nil then
            skillRootNode:setCascadeColorEnabled(false)
            skillRootNode:setCascadeOpacityEnabled(false)
            skillRootNode:setColor(display.COLOR_WHITE)
        end
    end
end

--获取测试的兵ID
function GameLevel:GetNextTestArmyTableID()
    local currentTableID = self._TestArmyList[self._TestCurrentArmyIndex]
    self._TestCurrentArmyIndex = self._TestCurrentArmyIndex + 1
    if self._CurrentCharacterTypeCount < #self._TestArmyList then
        self._CurrentCharacterTypeCount = self._CurrentCharacterTypeCount + 1
        DispatchEvent(GameEvent.GameEvent_UIBattle_TestSoldierType, {characterCount = self._CurrentCharacterTypeCount})
    end
    if self._TestCurrentArmyIndex > #self._TestArmyList then
        self._TestCurrentArmyIndex = 1
    end
    return currentTableID
end

--添加友方兵
function GameLevel:AddSoldier(tableID, unit)
    --[[
    --TODO：去掉测试代码 下面是测试兵种类的代码
    tableID = self:GetNextTestArmyTableID()
    if tableID == nil then
    return
    end
    ]]--
    --
    local newSoldier = CharacterManager:CreateSoldier(tableID)
    newSoldier._unit = unit
--    local newNode = newSoldier:GetCharacterNode()
--    local parentNode = newNode:getParent()
--    if parentNode == nil then
--        self._LevelSoldierNode:addChild(newNode)
--    end
    --临时
    local x = mathRandom(self._SelfStartX, self._SelfStartX + 50)
    local y = mathRandom(self._LevelInitRandomYMin, self._LevelInitRandomYMax)
    newSoldier:SetPosition(x, y)
    newSoldier:IsEnemy(false)
    newSoldier:InitLogicData()
    local clientID = newSoldier:GetClientGUID()
    self._SelfSoldierIDList[clientID] = clientID
    --友方武将
    if newSoldier._CharacterData.type == CharacterType.CharacterType_Leader then
        local skillInfo = LeaderSkillInfo:new()
        skillInfo._LeaderClientID = clientID
        skillInfo._SkillTableID = newSoldier._CharacterData.skill2

        skillInfo._CurrentSkillLeft = 0

        if SkillTableDataManager == nil then
            SkillTableDataManager = GetSkillDataManager()
        end
        local skillData = SkillTableDataManager[skillInfo._SkillTableID]
        if skillData ~= nil then
            skillInfo._SkillInterval = newSoldier._CharacterData.skillcd
        end
        skillInfo._IsEnable = true
        --统计武将技能列表，add 9.21
        skillInfo._SkillTotalCD = 0
        skillInfo._SkillTableIDList = {}
        skillInfo._SkillCDList = {}
        skillInfo._SKillHurtFactorList = {}
        local count = 0
        local hurtCount = 0
        for i = 2, 4 do
            local skillFieldName = stringFormat("skill%d",i)
            local tableID = newSoldier._CharacterData[skillFieldName]
            --[[
            --临时测试begin
            if i == 3 then
            tableID = 5035
            elseif i == 4 then
            tableID = 0
            end
            --测试end
            ]]--
            if tableID ~= 0 and tableID ~= nil then
                count = count + 1
                skillInfo._SkillTableIDList[count] = tableID

                local currentSkillData = SkillTableDataManager[tableID]
                if currentSkillData ~= nil then
                    local skillCD = newSoldier._CharacterData.skillcd
                    skillInfo._SkillCDList[count] = skillCD
                    skillInfo._SkillTotalCD =  skillInfo._SkillTotalCD + skillCD
                end
            end
            local skillHurtFieldName = stringFormat("skill%ddamage", i)
            local factor = newSoldier._CharacterData[skillHurtFieldName]
            if factor ~= nil then
                hurtCount = hurtCount + 1
                skillInfo._SKillHurtFactorList[hurtCount] = factor
            end
        end

        skillInfo._SkillStageCount = count
        skillInfo._CurrentSkillLeft = skillInfo._SkillInterval
        skillInfo._CurrentSkillStage = 1
        if skillInfo._SkillStageCount == 1 then
            skillInfo._IsEnable = false
            skillInfo._CurrentSkillLeft = 0
        else
            skillInfo._IsEnable = true
            skillInfo._CurrentSkillLeft = skillInfo._SkillCDList[skillInfo._CurrentSkillStage + 1]
        end
        local leaderTableID = newSoldier._CharacterData.id
        self._LeaderSkillInfoList[leaderTableID] = skillInfo

    end
    self:SetCurrentCharacterCount(self._CurrentCharacterCount + 1)
    return newSoldier
end

--添加敌方兵
function GameLevel:AddEnemySoldier(tableID, currentlevel)
    --[[
    --TODO：去掉测试代码 下面是测试兵种类的代码
    tableID = self:GetNextTestArmyTableID()
    if tableID == nil then
    return
    end
    ]]--
    --printInfo("AddEnemySoldier ", tableID)
    local newSoldier = CharacterManager:CreateSoldier(tableID)
    local newNode = newSoldier:GetCharacterNode()
    local parentNode = newNode:getParent()
    if parentNode == nil then
        self._LevelSoldierNode:addChild(newNode)
    end
    local x = mathRandom(self._EnemyStartX, self._EnemyStartX - 50)
    local y = mathRandom(self._LevelInitRandomYMin, self._LevelInitRandomYMax)
    newSoldier:SetPosition(x, y)
    newSoldier:IsEnemy(true)
    newSoldier:SetEnemyLevel(currentlevel)
    newSoldier:InitLogicData()
    local clientID = newSoldier:GetClientGUID()
    self._EnemySoldierIDList[clientID] = clientID
    self:SetCurrentCharacterCount(self._CurrentCharacterCount + 1)
    return newSoldier
end

--添加PVEPVP已方单位含武将
function GameLevel:AddSelfPVEPVPSoldier(zhenXingInfo)
    local tableID = zhenXingInfo._ArmyTableID
    local row = zhenXingInfo._TileRow
    local col = zhenXingInfo._TileCol
    
    
--    local newSoldier = CharacterManager:CreateSoldier(tableID)
--    local newNode = newSoldier:GetCharacterNode()
--    local parentNode = newNode:getParent()
--    if parentNode == nil then
--        self._LevelSoldierNode:addChild(newNode)
--    end
--    local x = self._LevelLeftBottomPositionX + col * SIZE_ONE_TILE
--    local y = self._LevelLeftBottomPositionY + row * SIZE_ONE_TILE
    
    Fight:addPveBossUnit(1, tableID > 10000 and 0 or 1, tableID, 1, col, row)
--    newSoldier:SetPosition(x, y)
--    newSoldier:IsEnemy(false)
--    newSoldier:InitPVEPVPLogicData()
--    local clientID = newSoldier:GetClientGUID()
--    self._SelfSoldierIDList[clientID] = clientID
--    self:SetCurrentCharacterCount(self._CurrentCharacterCount + 1)
--    self._PVPSelfTotalHP = self._PVPSelfTotalHP + newSoldier:GetCurrentHP()
    return newSoldier
end

--添加敌方单位
function GameLevel:AddEnemyPVEPVPSoldier(zhenXingInfo)
    local tableID = zhenXingInfo._ArmyTableID
    local row = zhenXingInfo._TileRow
    local col = zhenXingInfo._TileCol
    local currentlevel = zhenXingInfo._Level

    Fight:addPveBossUnit(0, tableID > 10000 and 0 or 1, tableID, currentlevel, 89 - col, row)
    
--    local newSoldier = CharacterManager:CreateSoldier(tableID)
--    local newNode = newSoldier:GetCharacterNode()
--    local parentNode = newNode:getParent()
--    if parentNode == nil then
--        self._LevelSoldierNode:addChild(newNode)
--    end
--    local x = self._LevelRightTopPositionX -   col * SIZE_ONE_TILE
--    local y = self._LevelLeftBottomPositionY +  row * SIZE_ONE_TILE
--    newSoldier:SetPosition(x, y)
--    newSoldier:IsEnemy(true)
--    newSoldier:SetEnemyLevel(currentlevel)
--    newSoldier:InitPVEPVPLogicData()
--    local clientID = newSoldier:GetClientGUID()
--    self._EnemySoldierIDList[clientID] = clientID
--    self:SetCurrentCharacterCount(self._CurrentCharacterCount + 1)
--    self._PVPEnemyTotalHP = self._PVPEnemyTotalHP + newSoldier:GetCurrentHP()
    return newSoldier
end

--添加已方PVP单位
function GameLevel:AddSelfPVPSoldier(zhenXingInfo)
    local tableID = zhenXingInfo._ArmyTableID
    local row = zhenXingInfo._TileRow
    local col = zhenXingInfo._TileCol
    local newSoldier = CharacterManager:CreateSoldier(tableID)
    local newNode = newSoldier:GetCharacterNode()
    local parentNode = newNode:getParent()
    if parentNode == nil then
        self._LevelSoldierNode:addChild(newNode)
    end
    local x = self._LevelLeftBottomPositionX + col * SIZE_ONE_TILE
    local y = self._LevelLeftBottomPositionY + row * SIZE_ONE_TILE
    newSoldier:SetPosition(x, y)
    newSoldier:IsEnemy(false)
    --攻击与血量外部传入
    newSoldier:InitPVPLogicData(zhenXingInfo._HP, zhenXingInfo._Attack)
    local clientID = newSoldier:GetClientGUID()
    self._SelfSoldierIDList[clientID] = clientID
    self:SetCurrentCharacterCount(self._CurrentCharacterCount + 1)
    self._PVPSelfTotalHP = self._PVPSelfTotalHP + newSoldier:GetCurrentHP()
    return newSoldier

end

--添加敌方PVP单位
function GameLevel:AddEnemyPVPSoldier(zhenXingInfo)
    local tableID = zhenXingInfo._ArmyTableID
    local row = zhenXingInfo._TileRow
    local col = zhenXingInfo._TileCol
    local currentlevel = zhenXingInfo._Level

    local newSoldier = CharacterManager:CreateSoldier(tableID)
    local newNode = newSoldier:GetCharacterNode()
    local parentNode = newNode:getParent()
    if parentNode == nil then
        self._LevelSoldierNode:addChild(newNode)
    end
    local x = self._LevelRightTopPositionX -   col * SIZE_ONE_TILE
    local y = self._LevelLeftBottomPositionY +  row * SIZE_ONE_TILE
    newSoldier:SetPosition(x, y)
    newSoldier:IsEnemy(true)
    newSoldier:SetEnemyLevel(currentlevel)
    newSoldier:InitPVPLogicData(zhenXingInfo._HP, zhenXingInfo._Attack)
    local clientID = newSoldier:GetClientGUID()
    self._EnemySoldierIDList[clientID] = clientID
    self:SetCurrentCharacterCount(self._CurrentCharacterCount + 1)
    self._PVPEnemyTotalHP = self._PVPEnemyTotalHP + newSoldier:GetCurrentHP()
    return newSoldier

end

--初始化国战双方阵型兵种
function GameLevel:InitGuoZhanPVPSoldiers()

    local GuoZhanServerDataManager = GameGlobal:GetGuoZhanServerDataManager()
    --[[
    --攻方
    --SoldierID
    self._SoldierTableID = 0
    --攻击
    self._Attack = 0
    --血量
    self._HP = 0
    --位置(格子)
    self._TileX = 0
    self._TileY = 0
    ]]--
    --攻方
    for k, v in pairs(GuoZhanServerDataManager._GuoZhanAttackerZhenXingData)do
        local tableID = v._SoldierTableID
        local row = v._TileX
        local col = v._TileY
        local hp = v._HP
        local attack = v._Attack
        local attackSpeed = v._AttackSpeed
        local newSoldier = CharacterManager:CreateSoldier(tableID)
        local newNode = newSoldier:GetCharacterNode()
        local parentNode = newNode:getParent()
        if parentNode == nil then
            self._LevelSoldierNode:addChild(newNode)
        end
        local x = self._LevelLeftBottomPositionX + col * SIZE_ONE_TILE
        local y = self._LevelLeftBottomPositionY + row * SIZE_ONE_TILE
        newSoldier:SetPosition(x, y)
        newSoldier:IsEnemy(false)
        newSoldier:InitGuoZhanPVPLogicData(hp, attack, attackSpeed)
        local clientID = newSoldier:GetClientGUID()
        self._SelfSoldierIDList[clientID] = clientID
        self:SetCurrentCharacterCount(self._CurrentCharacterCount + 1)
        self._PVPSelfTotalHP = self._PVPSelfTotalHP + newSoldier:GetCurrentHP()
        --print("InitGuoZhanPVPSoldiers attacker ", tableID, x, y)
        --LogSystem:WriteLog("InitGuoZhanPVPSoldiers attacker tableID:%d hp:%d attack:%d pos(%d, %d) attackInterval:%f attackDis:%f",tableID, hp, attack, x, y,
            --newSoldier._AttackInterval, newSoldier._MaxAttackDistance)
    end

    --守方
    for k, v in pairs(GuoZhanServerDataManager._GuoZhanDefenderZhenXingData)do
        local tableID = v._SoldierTableID
        local row = v._TileX
        local col = v._TileY
        local hp = v._HP
        local attack = v._Attack
        local attackSpeed = v._AttackSpeed

        local newSoldier = CharacterManager:CreateSoldier(tableID)
        local newNode = newSoldier:GetCharacterNode()
        local parentNode = newNode:getParent()
        if parentNode == nil then
            self._LevelSoldierNode:addChild(newNode)
        end
        local x = self._LevelRightTopPositionX -   col * SIZE_ONE_TILE
        local y = self._LevelLeftBottomPositionY +  row * SIZE_ONE_TILE
        newSoldier:SetPosition(x, y)
        newSoldier:IsEnemy(true)
        --newSoldier:SetEnemyLevel(currentlevel)
        newSoldier:InitGuoZhanPVPLogicData(hp, attack, attackSpeed)
        local clientID = newSoldier:GetClientGUID()
        self._EnemySoldierIDList[clientID] = clientID
        self:SetCurrentCharacterCount(self._CurrentCharacterCount + 1)
        self._PVPEnemyTotalHP = self._PVPEnemyTotalHP + newSoldier:GetCurrentHP()
        --print("InitGuoZhanPVPSoldiers defender ", tableID, x, y)
       -- LogSystem:WriteLog("InitGuoZhanPVPSoldiers defender tableID:%d hp:%d attack:%d pos(%d, %d) attackInterval:%f attackDis:%f",tableID, hp, attack, x, y,
            --newSoldier._AttackInterval, newSoldier._MaxAttackDistance)
    end
end

--清理当前国战的所有士兵
function GameLevel:CleanGuoZhanLogic(battleID)
    print("--------------------------------GameLevel:CleanGuoZhanLogic -----------------------------", battleID, os.date())
    if  self._GameStartTimerID ~= nil then
        GameGlobal:GetTimerManager():RemoveTimer(self._GameStartTimerID)
        self._GameStartTimerID = nil
    end
    self._CurrentGuoZhanID = battleID
    self._CurrentStartTime = os.date()
    self._Finished = false
    self._PVPSelfTotalHP = 0
    self._PVPEnemyTotalHP = 0
    self._GameStartTimeCount = 3
    self._SelfSoldierIDList = {}
    self._EnemySoldierIDList = {}
    self._BattleResult = -1
    --print("RemoveFromSoldiers remove ", clientID)
    self:SetCurrentCharacterCount(0)
    --清理当前所有士兵
    if CharacterManager ~= nil then
        CharacterManager:DestroyAllCharacter()
    end
    if SkillManager ~= nil then
        SkillManager:DestroyAllSkill()
    end
    if SkillBuffManager ~= nil then
        SkillBuffManager:DestroyAllBuff()
    end
end
----移除
function GameLevel:RemoveFromSoldiers(clientID)
    CharacterManager:DestroySoldier(clientID)
    self._SelfSoldierIDList[clientID] = nil
    self._EnemySoldierIDList[clientID] = nil
    --print("RemoveFromSoldiers remove ", clientID)
    self:SetCurrentCharacterCount(self._CurrentCharacterCount - 1)
end
--移除 废弃的接口
function GameLevel:RemoveSelfSoldier(clientID)
    CharacterManager:DestroySoldier(clientID)
    self._SelfSoldierIDList[clientID] = nil
end
--移除  废弃的接口
function GameLevel:RemoveEnemySoldier(clientID)
    CharacterManager:DestroySoldier(clientID)
    self._EnemySoldierIDList[clientID] = nil
end

--关卡内添加普攻技能
function GameLevel:AddSkill(skillTableID, senderID, targetID)
    local newSkill = SkillManager:CreateSkill(skillTableID,senderID,targetID, false)
    local skillRootNode =  newSkill:GetSkillRootNode()
    if skillRootNode ~= nil then
        local parentNode = skillRootNode:getParent()
        if parentNode == nil then
            self._LevelSoldierNode:addChild(skillRootNode)
        end
    end
end
--添加某武将技能
function GameLevel:AddLeaderSkill(skillTableID, senderID, positon, skillDamageFactor, unit)
    local newSkill = SkillManager:CreateSkill(skillTableID,senderID, nil, true, skillDamageFactor)
    newSkill._unit = unit
    local skillRootNode =  newSkill:GetSkillRootNode()
    if skillRootNode ~= nil then
        local parentNode = skillRootNode:getParent()
        if parentNode == nil then
            local skillPosition = self._LevelEffectNode:convertToNodeSpace(positon)
            
            self._LevelNode:addChild(skillRootNode, 1000)
            skillRootNode:setPosition(skillPosition)
            --newSkill:UpdateOrder()
        end
    end
    return newSkill
end

function GameLevel:AddSkillNode(skillRootNode)
    local parentNode = skillRootNode:getParent()
    if parentNode == nil then
        self._LevelSoldierNode:addChild(skillRootNode)
    end
end

function GameLevel:GetLevelSkillPosition(worldPositon)
    if self._LevelEffectNode == nil then
        return nil
    end
    return  self._LevelEffectNode:convertToNodeSpace(worldPositon)
end
--移除
function GameLevel:RemoveSkill(clientID)
    SkillManager:DestroySkill(clientID)
end

function GameLevel:MoveX(deltaX)
    if self._LevelNode ~= nil then
        local winsize =  director:getWinSize()
        --dump(winsize,"winsize")
        --local winsizePix = director:getWinSizeInPixels()
        --dump(winsizePix,"winsizePix")
        local currentX =  self._LevelNode:getPositionX()
        local currentY = self._LevelNode:getPositionY()

        currentX = currentX + deltaX
        if currentX >= -(self._LevelSize.width * self._LevelNode:getScale() - winsize.width - winsize.width * self._LevelNode:getScale() / 2) and currentX <= winsize.width / 2 *self._LevelNode:getScale() then
            self._LevelNode:setPosition(currentX, currentY)
        end
    end
end
--更新位置X
function GameLevel:UpdateX(scaletmp)
    if self._LevelNode ~= nil then
        local winsize =  director:getWinSize()
        local currentX =  self._LevelNode:getPositionX()
        if currentX <= (- self._LevelSize.width * scaletmp + winsize.width + winsize.width * scaletmp / 2)  then
            currentX = (- self._LevelSize.width * scaletmp + winsize.width + winsize.width * scaletmp / 2)
            self._LevelNode:setPositionX(currentX)  self._LevelNode:setPositionX(currentX)
        elseif currentX >= winsize.width / 2 * scaletmp then
            currentX = winsize.width / 2 * scaletmp
            self._LevelNode:setPositionX(currentX)
        end
    end
end
--获取可移动范围 X
function  GameLevel:GetCanMoveZoneX()
    local currrentScaleX = self._LevelNode:getScaleX()
    local standWidth = 960
    local canMoveX = (self._LevelSize.width - standWidth) * currrentScaleX
    return canMoveX
end
--获取场景大小
function GameLevel:GetLevelSiZe()
    return self._LevelSize
end

function GameLevel:setScale(scale)
    if self._LevelNode ~= nil then
        self._LevelNode:setScale(scale)
    end
end

----------------自定义事件处理------------------------------------
--小兵死亡
function GameLevel.OnSoldierDie(event)
    print(event)
    local clientGUID = event._usedata.guid
    --dump(event._usedata)
    if GameBattle == nil then
        GameBattle = require("main.Game.GameBattle")
    end
    local currentLevel = GameBattle:GetGameLevel()
    currentLevel:RemoveFromSoldiers(clientGUID)
end

--武将死亡
function GameLevel.OnLeaderDie(event)
    print(event)
    local clientGUID = event._usedata.guid
    --dump(event._usedata)
    if GameBattle == nil then
        GameBattle = require("main.Game.GameBattle")
    end
    local currentLevel = GameBattle:GetGameLevel()
    currentLevel:RemoveFromSoldiers(clientGUID)
end
--城池血量变化
function GameLevel.OnCityHPChange(event)
    local clientGUID = event._usedata.guid
    local building = CharacterManager:GetCharacterByClientID(clientGUID1)
    if building ~= nil then
        local currentHP = building._CurrentHP
        if currentHP <= 0 then
            print("OnCityHPChange", clientGUID)
            CharacterManager:DestroySoldier(clientGUID)
        end
    end
end
--国战阵型刷新
function GameLevel.OnGuoZhanZhenXingRefresh(event)

end