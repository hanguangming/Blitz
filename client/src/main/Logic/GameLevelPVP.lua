----
-- 文件名称：GameLevelPVP.lua
-- 功能描述：游戏关卡:游戏场景构建(兵,地图，技能特效等)游戏关卡逻辑
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-9-29
--  修改：将PVP逻辑重写，改为逻辑与渲染部分分离 

local stringFind = string.find
local stringSub = string.sub
local mathAbs = math.abs
local mathCeil = math.ceil
local mathFloor = math.floor
local mathPow = math.pow
local stringFormat = string.format
--临时测试用
gHurtFactor = 1
--是否开启关卡Tile测试
local ENABLE_LEVEL_TILE_TEST = false
---------------------依赖数据结构
--武将技能数据
local LeaderSkillInfo = class("LeaderSkillInfo")
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
    --攻速
    self._AttackSpeed = 0
end

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


--逻辑部分
local GameLevelPVP = class("GameLevelPVP")

local CharacterPVPManager = require("main.Logic.CharacterPVPManager")
local SkillPVPManager = require("main.Logic.SkillPVPManager")
local SkillBuffPVPManager = require("main.Logic.SkillBuffPVPManager")
local GameLevelPVPEntity = require("main.Logic.GameLevelPVPEntity")
local TableDataManager = GameGlobal:GetDataTableManager()
local CharacterDataManager = TableDataManager:GetCharacterDataManager()
local LevelDataManager = TableDataManager:GetLevelDataManager()
local SkillTableDataManager = TableDataManager:GetSkillDataManager()
local mathRandom = math.random
local mathCeil = math.ceil
local mathFloor = math.floor
local DispatchEvent = DispatchEvent
local AddEvent = AddEvent
local RemoveEvent = RemoveEvent
local GameBattle = nil
local TILE_UNIT_COL_COUNT = 7

function GameLevelPVP.Create(levelID, isNeedShow)
    local newLevel = GameLevelPVP.new(levelID, isNeedShow)
    return newLevel
end

--构造
function GameLevelPVP:ctor(levelID, isNeedShow)
    --逻辑部分
    --是否需要显示
    self._IsNeedShow = isNeedShow
    --回合时间
    self._ROUNDTIME = 10
    --敌方出兵间隔
    self._ENEMY_SOLDIERTIME = 5
    --关卡ID
    self._LevelTableID = levelID
    --level table data
    self._LevelTableData = LevelDataManager[levelID]
    --每回合最大人口数
    self._LevelMaxPeopleRound = 30
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
    self._GameStartTimerID = nil
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
    
    if self._IsNeedShow == nil then
        self._IsNeedShow = false
    end
    --显示相关
    if self._IsNeedShow == true then
        self._GameLevelEntity = GameLevelPVPEntity:new()
    end
    self._CharacterPVPManager = nil
    self._SkillPVPManager = nil
    self._SkillBuffPVPManager = nil
    --当前帧数
    self._CurrentFrameCount = 0
end

--初始化
function GameLevelPVP:Init()
    --初始化各个管理器
    self._CharacterPVPManager = CharacterPVPManager.new(self)
    self._SkillPVPManager = SkillPVPManager.new(self)
    self._SkillBuffPVPManager = SkillBuffPVPManager.new(self)
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
    --初始化场景相关变量,在没有渲染的情况下，下面数值定死
    self._LevelLeftBottomPositionX = 16
    self._LevelLeftBottomPositionY = 115
    self._LevelRightTopPositionX = 1424
    self._LevelRightTopPositionY = 493
    self._LevelSize = {width = 1440, height = 640 }
    self._LevelInitRandomYMin = self._LevelLeftBottomPositionY
    self._LevelInitRandomYMax = self._LevelRightTopPositionY
    --需要渲染的话，从CSB文件里读取上面的数据
    if self._GameLevelEntity ~= nil then
        self._GameLevelEntity:Init(self._LevelSceneName)
        self._LevelLeftBottomPositionX = self._GameLevelEntity._LevelLeftBottomPositionX
        self._LevelLeftBottomPositionY = self._GameLevelEntity._LevelLeftBottomPositionY
        self._LevelRightTopPositionX = self._GameLevelEntity._LevelRightTopPositionX
        self._LevelRightTopPositionY = self._GameLevelEntity._LevelRightTopPositionY
        self._LevelInitRandomYMin = mathCeil(self._LevelLeftBottomPositionY)
        self._LevelInitRandomYMax = mathCeil(self._LevelRightTopPositionY)
        self._LevelSize = self._GameLevelEntity:GetLevelSize()
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
                self._TileDataTable[i][j] = newTileData
            end
        end
    end
    
    --逻辑
    if self._LevelLogicType == LevelLogicType.LevelLogicType_PVP then
        self:InitPVPLogic()
    elseif self._LevelLogicType == LevelLogicType.LevelLogicType_GuoZhanPVP then
        self:InitGuoZhanPVPLogic()
    end
end

--销毁
function GameLevelPVP:Destroy()
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
    --其它逻辑清理
    if self._CharacterPVPManager ~= nil then
        self._CharacterPVPManager:DestroyAllCharacter()
    end
    if self._SkillPVPManager ~= nil then
        self._SkillPVPManager:DestroyAllSkill()
    end
    if self._SkillBuffPVPManager ~= nil then
        self._SkillBuffPVPManager:DestroyAllBuff()
    end
    if  self._TileTestLabelList ~= nil then
        self._TileTestLabelList = nil
    end
    if  self._GameStartTimerID ~= nil then
        GameGlobal:GetTimerManager():RemoveTimer(self._GameStartTimerID)
        self._GameStartTimerID = nil
    end
    --数据清理
    self._SelectedSoldiersTable = nil
    self._SelfSoldierIDList = nil
    self._EnemySoldierIDList = nil
    self._SelfOutWuJiaList = nil
    self._EnemyOutWuJiaList = nil
    self._LeaderSkillInfoList = nil
    
    --显示销毁
    if self._GameLevelEntity ~= nil then
        self._GameLevelEntity:Destroy()
        self._GameLevelEntity = nil
    end
end

--更新
function GameLevelPVP:Update(deltaTime)
    if self._Finished == true then
        return
    end
    deltaTime = 0.033
    if self._CurrentLevelState == LevelState.LevelState_Invalid then
        self:SetLevelState(LevelState.LevelState_WillStart)
        return
    end
    if self._CurrentLevelState ~= LevelState.LevelState_Runing then
        return
    end
    self._CurrentFrameCount = self._CurrentFrameCount + 1
    if self._LevelLogicType == LevelLogicType.LevelLogicType_GuoZhanPVP then
        --self:GuoZhanPVPUpdate(deltaTime)
    elseif self._LevelLogicType == LevelLogicType.LevelLogicType_PVP then
        --self:PVEPVPUpdate(deltaTime)
    end
    -- print("---GameLevel Update end")
end

--更新地图格子数据
function GameLevelPVP:UpdateLevelTileData(oldPositionX, oldPositionY, newPositionX, newPositionY, clientID)
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
    
    --print("UpdateLevelTileData ", oldTileRow, oldTileCol, newTileRow, newTileCol, clientID)
end
--格子内是否存在攻击者
function GameLevelPVP:IsAttackerInTile(characterInstance)
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
                    local currentCharacter = self._CharacterPVPManager:GetCharacterByClientID(k)
                    if currentCharacter ~= nil and currentCharacter ~= characterInstance then
                        if characterInstance._IsEnemy == currentCharacter._IsEnemy then
                            if currentCharacter:GetCurrentState() == CharacterState.CharacterState_Attack then
                                currentCount = currentCount + 1
                                --print("GameLevel:IsAttackerInTile ", currentCount, rowsIndex, colsIndex,  os.date())
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
--

--获取某个格子是否被占（有同伴在攻击）
function GameLevelPVP:IsHaveAttackerInTileRowCol(characterInstance, row, col)
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
        local currentCharacter = self._CharacterPVPManager:GetCharacterByClientID(k)
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
function GameLevelPVP:GetTileByXY(x, y)
    local currentX = x - self._LevelLeftBottomPositionX
    local currentY = y - self._LevelLeftBottomPositionY
    local colsIndex = mathCeil(currentX / SIZE_ONE_TILE)
    local rowsIndex =  mathCeil(currentY /  SIZE_ONE_TILE)
    return rowsIndex, colsIndex
end
--获取某个Tile的XY
function GameLevelPVP:GetXYByTile(row, col)
    local x = self._LevelLeftBottomPositionX +  (col - 1 )* SIZE_ONE_TILE + SIZE_ONE_TILE / 2
    local y =  self._LevelLeftBottomPositionY +  (row - 1)* SIZE_ONE_TILE + SIZE_ONE_TILE / 2
    return x, y
end


--设置关卡状态
function GameLevelPVP:SetLevelState(levelState)
    if levelState ~= self._CurrentLevelState then
        DispatchEvent(GameEvent.GameEvent_LevelStateChange, {levelState = levelState})
        self._CurrentLevelState = levelState
--        if self._CurrentLevelState == LevelState.LevelState_WillStart then
--            if self._LevelLogicType == LevelLogicType.LevelLogicType_PVP then
--                if self._IsNeedShow == true then
--                    self._GameStartTimerID = GameGlobal:GetTimerManager():AddTimer(1, GameLevel.UpdateGameStartTime)
--                end
--                --根据CharacterServerManager中的数据(服务器下发)转化为GameLevel的阵型数据结构
--                self:InitSelfPVPZhenXing()
--                self:InitEnemyPVPZhenXing()
--                --初始化双方阵形兵
--                for k, v in pairs(self._SelfShaChangPVPZhenXing)do
--                    self:AddSelfPVPSoldier(v)
--                end
--                for k, v in pairs(self._EnemyShaChangPVPZhenXing)do
--                    self:AddEnemyPVPSoldier(v)
--                end
--                DispatchEvent(GameEvent.GameEvent_PVPTotalHP, {selfHP = self._PVPSelfTotalHP, enemyHP = self._PVPEnemyTotalHP})
--            elseif self._LevelLogicType == LevelLogicType.LevelLogicType_GuoZhanPVP then
--                if  self._GameStartTimerID ~= nil then
--                    GameGlobal:GetTimerManager():RemoveTimer(self._GameStartTimerID)
--                    self._GameStartTimerID = nil
--                end
--                if self._IsNeedShow == true then
--                    self._GameStartTimerID = GameGlobal:GetTimerManager():AddTimer(1, GameLevelPVP.UpdateGameStartTime)
--                else
--                    self._CurrentFrameCount = 0
--                end
--                self:InitGuoZhanPVPSoldiers()
--                DispatchEvent(GameEvent.GameEvent_PVPTotalHP, {selfHP = self._PVPSelfTotalHP, enemyHP = self._PVPEnemyTotalHP})
--            end
--        end
    end
end
--获取CharacterMananger
function GameLevelPVP:GetCharacterPVPManager()
    return self._CharacterPVPManager
end
--获取SkillPVPManager
function GameLevelPVP:GetSkillPVPManager()
    return self._SkillPVPManager
end
--获取SkillBuffPVPManager
function GameLevelPVP:GetSkillBuffPVPManager()
    return self._SkillBuffPVPManager
end

--创建阵形数据(小兵阵形)
function GameLevelPVP:CreateZhenXingData(armyData, dataTable, startRow, startCol, level,  hp, attack, attackSpeed)
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
                levelZhenXingData._AttackSpeed = attackSpeed
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
                levelZhenXingData._AttackSpeed = attackSpeed
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
            levelZhenXingData._AttackSpeed = attackSpeed
            table.insert(dataTable, levelZhenXingData)
        end
    end
end

--初始化已方PVP阵形数据(数据结构转换为GameLevel内用的,统一PVP与PVE逻辑数据结构)
function GameLevelPVP:InitSelfPVPZhenXing()
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
            levelZhenXingData._AttackSpeed = v._WuJiangAttackSpeed
            table.insert(self._SelfShaChangPVPZhenXing, levelZhenXingData)
            local armyData =  armyDataTable[soldierTableID]
            self:CreateZhenXingData(armyData, self._SelfShaChangPVPZhenXing, startRow, startCol,v._SoldierLevel, v._SoldierHP, v._SoldierAttack, v._SoldierAttackSpeed)
        end
    end
end

--初始化敌方PVP阵形数据
function GameLevelPVP:InitEnemyPVPZhenXing()
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
            self:CreateZhenXingData(armyData, self._EnemyShaChangPVPZhenXing, startRow, startCol,v._SoldierLevel, v._SoldierHP, v._SoldierAttack, v._SoldierAttackSpeed)
        end
    end
end

--添加已方PVP单位
function GameLevelPVP:AddSelfPVPSoldier(zhenXingInfo)
    local tableID = zhenXingInfo._ArmyTableID
    local row = zhenXingInfo._TileRow
    local col = zhenXingInfo._TileCol
    local newSoldier = self._CharacterPVPManager:CreateSoldier(tableID, self._IsNeedShow)
    if self._GameLevelEntity ~= nil then
        local newNode = newSoldier:GetCharacterNode()
        self._GameLevelEntity:AddSoldierNode(newNode)
    end
    local x = self._LevelLeftBottomPositionX + col * SIZE_ONE_TILE
    local y = self._LevelLeftBottomPositionY + row * SIZE_ONE_TILE
    newSoldier:SetPosition(x, y)
    newSoldier:IsEnemy(false)
    --攻击与血量外部传入
    newSoldier:InitPVPLogicData(zhenXingInfo._HP, zhenXingInfo._Attack, zhenXingInfo._AttackSpeed)
    local clientID = newSoldier:GetClientGUID()
    self._SelfSoldierIDList[clientID] = clientID
    self:SetCurrentCharacterCount(self._CurrentCharacterCount + 1)
    self._PVPSelfTotalHP = self._PVPSelfTotalHP + newSoldier:GetCurrentHP()
    return newSoldier

end

--添加敌方PVP单位
function GameLevelPVP:AddEnemyPVPSoldier(zhenXingInfo)
    local tableID = zhenXingInfo._ArmyTableID
    local row = zhenXingInfo._TileRow
    local col = zhenXingInfo._TileCol
    local currentlevel = zhenXingInfo._Level

    local newSoldier = self._CharacterPVPManager:CreateSoldier(tableID, self._IsNeedShow)
    if self._GameLevelEntity ~= nil then
        local newNode = newSoldier:GetCharacterNode()
        self._GameLevelEntity:AddSoldierNode(newNode)
    end
    local x = self._LevelRightTopPositionX -   col * SIZE_ONE_TILE 
    local y = self._LevelLeftBottomPositionY +  row * SIZE_ONE_TILE
    newSoldier:SetPosition(x, y)
    newSoldier:IsEnemy(true)
    newSoldier:SetEnemyLevel(currentlevel)
    newSoldier:InitPVPLogicData(zhenXingInfo._HP, zhenXingInfo._Attack, zhenXingInfo._AttackSpeed)
    local clientID = newSoldier:GetClientGUID()
    self._EnemySoldierIDList[clientID] = clientID
    self:SetCurrentCharacterCount(self._CurrentCharacterCount + 1)
    self._PVPEnemyTotalHP = self._PVPEnemyTotalHP + newSoldier:GetCurrentHP()
    return newSoldier

end


--初始化国战双方阵型兵种
function GameLevelPVP:InitGuoZhanPVPSoldiers()
    local GuoZhanServerDataManager = GameGlobal:GetGuoZhanServerDataManager()
    --攻方
    for k, v in pairs(GuoZhanServerDataManager._GuoZhanAttackerZhenXingData)do
        local tableID = v._SoldierTableID
        local row = v._TileX
        local col = v._TileY
        local hp = v._HP
        local attack = v._Attack
        local attackSpeed = v._AttackSpeed
        local belongWuJiangTableID = v._BelongWuJiangTableID
        local bigRow = v._BigZhenXingRow
        local bigCol = v._BigZhenXingCol
        local soldierCount = v._SoldierCount
        local newSoldier = self._CharacterPVPManager:CreateSoldier(tableID, self._IsNeedShow)
        if self._GameLevelEntity ~= nil then
            local newNode = newSoldier:GetCharacterNode()
            self._GameLevelEntity:AddSoldierNode(newNode)
        end
        
        local x = self._LevelLeftBottomPositionX + col * SIZE_ONE_TILE
        local y = self._LevelLeftBottomPositionY + row * SIZE_ONE_TILE
        newSoldier:SetPosition(x, y)
        newSoldier:IsEnemy(false)
        newSoldier:InitGuoZhanPVPLogicData(hp, attack, attackSpeed)
        newSoldier:SetBelongWuJiang(belongWuJiangTableID)
        newSoldier:SetZhenXingRowCol(bigRow, bigCol)
        newSoldier:SetZhenXingSoldierCount(soldierCount)
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
        local belongWuJiangTableID = v._BelongWuJiangTableID
        local bigRow = v._BigZhenXingRow
        local bigCol = v._BigZhenXingCol
        local soldierCount = v._SoldierCount
        local newSoldier = self._CharacterPVPManager:CreateSoldier(tableID, self._IsNeedShow)
        if self._GameLevelEntity ~= nil then
            local newNode = newSoldier:GetCharacterNode()
            self._GameLevelEntity:AddSoldierNode(newNode)
        end
        local x = self._LevelRightTopPositionX -   col * SIZE_ONE_TILE
        local y = self._LevelLeftBottomPositionY +  row * SIZE_ONE_TILE
        newSoldier:SetPosition(x, y)
        newSoldier:IsEnemy(true)
        newSoldier:SetBelongWuJiang(belongWuJiangTableID)
        newSoldier:SetZhenXingRowCol(bigRow, bigCol)
        newSoldier:SetZhenXingSoldierCount(soldierCount)
        --newSoldier:SetEnemyLevel(currentlevel)
        newSoldier:InitGuoZhanPVPLogicData(hp, attack, attackSpeed)
        local clientID = newSoldier:GetClientGUID()
        self._EnemySoldierIDList[clientID] = clientID
        self:SetCurrentCharacterCount(self._CurrentCharacterCount + 1)
        self._PVPEnemyTotalHP = self._PVPEnemyTotalHP + newSoldier:GetCurrentHP()
        --print("InitGuoZhanPVPSoldiers defender ", tableID, x, y)
        --LogSystem:WriteLog("InitGuoZhanPVPSoldiers defender tableID:%d hp:%d attack:%d pos(%d, %d) attackInterval:%f attackDis:%f",tableID, hp, attack, x, y,
        --newSoldier._AttackInterval, newSoldier._MaxAttackDistance)
    end
end

--是否完成
function GameLevelPVP:GetIsFinished()
    return self._Finished
end
--获取总帧数
function GameLevelPVP:GetTotalFrame()
    return self._CurrentFrameCount
end
--设置当前的数目
function GameLevelPVP:SetCurrentCharacterCount(currentCount)
    if currentCount ~= self._CurrentCharacterCount then
        DispatchEvent(GameEvent.GameEvent_UIBattle_TestSoldierNumber, {characterCount = currentCount})
    end
    self._CurrentCharacterCount = currentCount
end

--初始化沙场PVP逻辑
function GameLevelPVP:InitPVPLogic()
    self._Finished = false
    if self._SoldierDieCallBack == nil then
        self._SoldierDieCallBack = AddEvent(GameEvent.GameEvent_SoldierDie, self.OnSoldierDie)
    end
    if self._LeaderDieCallBack == nil then
        self._LeaderDieCallBack = AddEvent(GameEvent.GameEvent_LeaderDie, self.OnLeaderDie)
    end
    self._PVPSelfTotalHP = 0
    self._PVPEnemyTotalHP = 0
end

--初始化国战PVP
function GameLevelPVP:InitGuoZhanPVPLogic()
    self._Finished = false
    
    if self._SoldierDieCallBack == nil then
        self._SoldierDieCallBack = AddEvent(GameEvent.GameEvent_SoldierDie, self.OnSoldierDie)
    end
    if self._LeaderDieCallBack == nil then
        self._LeaderDieCallBack = AddEvent(GameEvent.GameEvent_LeaderDie, self.OnLeaderDie)
    end

    self._PVPSelfTotalHP = 0
    self._PVPEnemyTotalHP = 0
end

--国战PVP逻辑帧
function GameLevelPVP:GuoZhanPVPUpdate(deltaTime)
    --是否结束判定
    if self:IsHaveSelfSoldier() == false then
        self._BattleResult = BattleResult.BattleResult_Lose
    end
    if self:IsHaveEnemySoldier() == false then
        self._BattleResult = BattleResult.BattleResult_Win
    end

    if self._BattleResult ~= nil and self._BattleResult ~= -1 then
        --DispatchEvent(GameEvent.GameEvent_UIBattle_BattleResult, {battleResult = self._BattleResult, round = self._CurrentRoundCount})
        --print("GameLevel _Finished ......", self._CurrentGuoZhanID, os.date(),  self._CurrentStartTime)
        self._Finished = true
        --
       --LogSystem:WriteLog("final battle result-----------------")
       --LogSystem:WriteLog("final battle self -----------------")
        for k, v in pairs(self._SelfSoldierIDList)do
           if v ~= nil then
                local currentCharacter = self._CharacterPVPManager:GetCharacterByClientID(v)
                --LogSystem:WriteLog("attacker %d tid:%d hp:%d", currentCharacter._ClientID, currentCharacter._CharacterTableID, currentCharacter:GetCurrentHP())
           end
        end
        --LogSystem:WriteLog("final battle enemy -----------------")
        for k, v in pairs(self._EnemySoldierIDList)do
            if v ~= nil then
                local currentCharacter = self._CharacterPVPManager:GetCharacterByClientID(v)
                --LogSystem:WriteLog("defender %d tid:%d hp:%d", currentCharacter._ClientID, currentCharacter._CharacterTableID, currentCharacter:GetCurrentHP())
            end
        end
        --LogSystem:Output()
        return
    end
    --
    self._CharacterPVPManager:Update(deltaTime)
    self._SkillPVPManager:Update(deltaTime)
    self._SkillBuffPVPManager:Update(deltaTime)
end

--沙场点兵，战斗逻辑帧
function GameLevelPVP:PVEPVPUpdate(deltaTime)
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
    self._CharacterPVPManager:Update(deltaTime)
    self._SkillPVPManager:Update(deltaTime)
    self._SkillBuffPVPManager:Update(deltaTime)
end

----移除
function GameLevelPVP:RemoveFromSoldiers(clientID)
    self._CharacterPVPManager:DestroySoldier(clientID)
    self._SelfSoldierIDList[clientID] = nil
    self._EnemySoldierIDList[clientID] = nil
    --print("RemoveFromSoldiers remove ", clientID)
    self:SetCurrentCharacterCount(self._CurrentCharacterCount - 1)
end

--清理当前国战的所有士兵
function GameLevelPVP:CleanGuoZhanLogic(battleID)
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
    if self._CharacterPVPManager ~= nil then
        self._CharacterPVPManager:DestroyAllCharacter()
    end
    if self._SkillPVPManager ~= nil then
        self._SkillPVPManager:DestroyAllSkill()
    end
    if self._SkillBuffPVPManager ~= nil then
        self._SkillBuffPVPManager:DestroyAllBuff()
    end
end

--已方单位还有活着的
function GameLevelPVP:IsHaveSelfSoldier()
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
function GameLevelPVP:IsHaveEnemySoldier()
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

--TOOD:如下回调函数里的GameBattle

--开始战斗倒计时Timer
function GameLevelPVP.UpdateGameStartTime()
    local game = GameGlobal:GetGameInstance()
    local gameBattle = game:GetCurrentGameStateInstance()
    if gameBattle ~= nil then
        local currentLevel = gameBattle:GetGameLevel()
        if currentLevel ~= nil then
            currentLevel._GameStartTimeCount = currentLevel._GameStartTimeCount - 1
            DispatchEvent(GameEvent.GameEvent_UIBattle_RefreshRoundTimer, {roundTime = currentLevel._GameStartTimeCount})
            if  currentLevel._GameStartTimeCount == 0 then
                GameGlobal:GetTimerManager():RemoveTimer(currentLevel._GameStartTimerID)
                currentLevel._GameStartTimerID = nil
                currentLevel._GameStartTimerID = 0
                currentLevel:SetLevelState(LevelState.LevelState_Runing)
            end
        end
    end
end

--国战阵型刷新
function GameLevelPVP.OnGuoZhanZhenXingRefresh(event)

end
--关卡根结点
function GameLevelPVP:GetRootNode()
    if self._GameLevelEntity == nil then
        return nil
    end
    return self._GameLevelEntity:GetLevelRootNode()
end
--关卡内添加普攻技能
function GameLevelPVP:AddSkill(skillTableID, senderID, targetID)
    local newSkill = self._SkillPVPManager:CreateSkill(skillTableID,senderID,targetID, false, 1, self._IsNeedShow, self)
    if self._GameLevelEntity ~= nil then
        local skillRootNode =  newSkill:GetSkillRootNode()
        self._GameLevelEntity:AddSkillNode(skillRootNode)
    end
end
--添加某武将技能
function GameLevelPVP:AddLeaderSkill(skillTableID, senderID, positon, skillDamageFactor)
   local newSkill = self._SkillPVPManager:CreateSkill(skillTableID,senderID, nil, true, 1, self._IsNeedShow, self)
   if self._GameLevelEntity ~= nil then
        local skillRootNode =  newSkill:GetSkillRootNode()
        self._GameLevelEntity:AddLeaderSkillNode(skillRootNode, positon)
   end
   newSkill:UpdateOrder()
end
--获取技能的位置
function GameLevelPVP:GetLevelSkillPosition(worldPositon)
    if self._GameLevelEntity == nil then
        return nil
    end
    return  self._GameLevelEntity:GetLevelSkillPosition(worldPositon)
end

--移除
function GameLevelPVP:RemoveSkill(clientID)
    self._SkillPVPManager:DestroySkill(clientID)
end
--重新校正场景的位置
function GameLevelPVP:FixLevelPosition()
    if self._GameLevelEntity == nil then
        return 
    end
    self._GameLevelEntity:FixLevelPosition()
end

--设置位置X
function GameLevelPVP:MoveX(deltaX)
    if self._GameLevelEntity == nil then
        return 
    end
    self._GameLevelEntity:MoveX(deltaX)
end
--更新位置X
function GameLevelPVP:UpdateX(scaletmp)
    if self._GameLevelEntity == nil then
        return 
    end
    self._GameLevelEntity:UpdateX(scaletmp)
end
--缩放
function GameLevelPVP:setScale(scale)
    if self._GameLevelEntity == nil then
        return 
    end
    self._GameLevelEntity:setScale(scale)
end

--TOOD:如下回调函数里的GameBattle
--小兵死亡
function GameLevelPVP.OnSoldierDie(event)
    -- dump(event)
    local clientGUID = event._usedata.guid
    --dump(event._usedata)
    if GameBattle == nil then
        GameBattle = require("main.Game.GameBattle")
    end
    local currentLevel = GameBattle:GetGameLevel()
    currentLevel:RemoveFromSoldiers(clientGUID)
end

--武将死亡
function GameLevelPVP.OnLeaderDie(event)
    --dump(event)
    local clientGUID = event._usedata.guid
    --dump(event._usedata)
    if GameBattle == nil then
        GameBattle = require("main.Game.GameBattle")
    end
    local currentLevel = GameBattle:GetGameLevel()
    currentLevel:RemoveFromSoldiers(clientGUID)
end

return GameLevelPVP





