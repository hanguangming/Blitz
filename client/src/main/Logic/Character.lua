----
-- 文件名称：Character.lua
-- 功能描述：角色: 处理角色状态机
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-4-21
-- 制作规范：人物的动作名称：Walk, Attack, Dead
--csb文件中，sprite的Tag值:1  血条节点HPNode 的Tag值为2
--
--  TODO:根据需求看是否需要派生 2015-4-25
--  
local CharacterDataManager = GetCharacterDataManager()
local CharacterServerDataManager = GameGlobal:GetCharacterServerDataManager()
local Character = class("Character")
local GameBattle = nil
local CharacterManager = nil
local stringFormat = string.format
local mathAbs = math.abs
local mathFloor = math.floor
local mathPower = math.pow
local mathSqrt = math.sqrt
local mathCeil = math.ceil
local UISystem = GameGlobal:GetUISystem()

local BuffInfo = class("BuffInfo")
function BuffInfo:ctor()
    --Buff 表格ID
    self._BuffTableID = 0
    --Buff 属性类型
    self._BuffAttributeType = 0
    --Buff clientID
    self._BuffClientID = 0
    --Buff Node
    self._CharacterBuffNode = 0
    --Buff 动画
    self._CharacterBuffTimelineAction = 0
end

--角色状态
CharacterState =
    {
        CharacterState_Invalid = -1,
        --初始方向的移动
        CharacterState_Walk = 0,
        --攻击间歇的表现（原地行走）
        CharacterState_Walk_Idle = 1,
        --朝目标移动
        CharacterState_Walk_ToTarget = 2,
        --攻击
        CharacterState_Attack = 3,
        --死亡
        CharacterState_Die = 4,
        --最终死亡状态
        CharacterState_Dead = 5,
        --当要攻击时格子内有同伴时，选个格子，朝其移动
        CharacterState_WalkForTime = 6,
        --死亡淡出
        CharacterState_DieFadeOut = 7,
        
        CharacterState_Count = 8,
    }
    
--构造
function Character:ctor(characterTableID)
    --寻敌间隔时间
    self._SEARCH_ENEMY_TIME = 0.5
    self._WALK_ALWAYS_TIME = 1
    self._CurrentState = CharacterState.CharacterState_Invalid
    --表格ID
    self._CharacterTableID = characterTableID
    --角色类型
    self._CharacterType = 0
    --client ID
    self._ClientID = 0
    --数据
    self._CharacterData = CharacterDataManager[characterTableID]
    --根节点
    self._CharacterRootNode = nil
    --动作
    self._CharacterTimeLineAction = nil
    --死亡淡出动画
    self._CharacterFadeOutAnim = nil
    --死亡冒出的文字
    self._DeadTextNode = nil
    --位置
    self._CharacterPositionX = 0
    self._CharacterPositionY = 0
    --是否敌方
    self._IsEnemy = false
    --朝向
    self._CharacterDirectionX = 1
    --攻击目标
    self._CharacterTargetClientID = 0
    --当前攻击间隔时间
    self._CurrentAttackInterval = 0
    --血条
    self._HPProgressBar = nil
    
    self._HpProgressBg = nil
    --血条显示时间
    self._HPBarShowTime = 0
    --用于调试的节点
    self._DebugLabel = nil
    --当前查找敌人逻辑间隔时间
    self._CurrentSearchEnemyInterval = 0
    --当前血量
    self._CurrentHP = 0
    --移动速度
    self._MoveSpeed = 0
    --攻击力
    self._Attack = 0
    --攻击速度
    self._AttackSpeed = 0
    --等级
    self._Level = 1
    --侦察范围X,Y
    self._LookZoneX = 0
    self._LookZoneY = 0
    --最大攻击距离
    self._MaxAttackDistance = 0
    --最小攻击距离
    self._MinAttackDistance = 0
    --攻击间隔时间
    self._AttackInterval = 0
    --施加Buff前的数值备份
    self._AttackBeforeBuff = 0
    self._AttackSpeedBeforeBuff = 0
    self._MoveSpeedBeforeBuff = 0
    self._AttackDistanceBeforeBuff = 0
    --Buff List
    self._BuffInfoList = 0
    --攻击我的敌人列表
    self._AttackMeCharacterIDList = nil
    --当前的攻击转向移动时间计时
    self._CurrentAttackWalkTime = 0
    --移动一段时间的方向
    self._MoveForTimeDir = 0
    --总血量
    self._TotalHP = 0
    --CSB资源名称
    self._CSBName = ""   
    self:Init()
end

--初始化
function Character:Init()
    self._CurrentSearchEnemyInterval = self._SEARCH_ENEMY_TIME
    --temp
    if self._CharacterData == nil then
        self._CharacterData = CharacterDataManager[0]
    end
    if self._CharacterData ~= nil then
       self._CharacterType = self._CharacterData.type
    end
    self._CSBName = GetArmyCSBName(self._CharacterData)
    self._CharacterRootNode = cc.CSLoader:createNode(self._CSBName)
    self._CharacterRootNode:retain()
    self._CharacterRootNode:setCascadeOpacityEnabled(true)
    self._CharacterTimeLineAction = cc.CSLoader:createTimeline(self._CSBName)
    if self._CharacterTimeLineAction ~= nil then
        self._CharacterTimeLineAction:retain()
    end
    --[[
    if self._DebugLabel == nil then
        self._DebugLabel = cc.Label:createWithTTF("test", "fonts/arial.ttf", 10)
        self._DebugLabel:retain()
        self._CharacterRootNode:addChild(self._DebugLabel)
    end
    ]]--
    self:SetState(CharacterState.CharacterState_Walk)
    self._AttackMeCharacterIDList = {}
    cc.SpriteFrameCache:getInstance():addSpriteFrames("meishu/ui/zhandou/UI_zd_wenzi.plist")
end

--销毁
function Character:Destroy()
    if self._CharacterTimeLineAction ~= nil then
        self._CharacterTimeLineAction:release()
        self._CharacterTimeLineAction = nil
    end

    if  self._CharacterFadeOutAnim ~= nil then
        self._CharacterFadeOutAnim:release()
        self._CharacterFadeOutAnim = nil
    end
    --Buff 
    if self._BuffInfoList ~= nil and self._BuffInfoList ~= 0 then
        for k, v in pairs(self._BuffInfoList)do
            if v._CharacterBuffNode ~= nil then
                v._CharacterBuffNode:removeFromParent()
                v._CharacterBuffNode:removeAllChildren()
                v._CharacterBuffNode:release()
            end
            if v._CharacterBuffTimelineAction ~= nil then
                v._CharacterBuffTimelineAction:release()
            end
        end
        self._BuffInfoList = nil
    end
    if self._HPProgressBar ~= nil then
        self._HPProgressBar:release()
        self._HPProgressBar = nil
    end
 
    if self._CharacterRootNode ~= nil then
        self._CharacterRootNode:removeFromParent()
        self._CharacterRootNode:removeAllChildren()
        self._CharacterRootNode:release()
        self._CharacterRootNode = nil
    end
    self._HpProgressBg = nil
    
    self._AttackMeCharacterIDList = nil
    self._DeadTextNode = nil
end

--初始化角色动态数据
function Character:InitLogicData()
    local zoneX = self._CharacterData.lookZoneX
    local zoneY =  self._CharacterData.lookZoneY
    --如果表格中未配置数据，即是0时，程序设置一个默认值（10, 10）
    if zoneX == 0 then
        zoneX = 10
    end
    if zoneY == 0 then
        zoneY = 10
    end
    --如果寻敌范围比攻距小，校正之
    if zoneX < self._CharacterData.maxAttackDistance then
        zoneX = self._CharacterData.maxAttackDistance
    end
    if zoneY < self._CharacterData.maxAttackDistance then
        zoneY = self._CharacterData.maxAttackDistance
    end
    --临时：强制将PVE的寻敌范围扩到整个场景的Y
    zoneY = 100
    if self._IsEnemy == true then
        --敌兵根据等级和表格数据计算
        self._MoveSpeed = self._CharacterData.moveSpeed * NORMAL_WALK_SPEED_PIXEL
        self._LookZoneX = zoneX * SIZE_ONE_TILE
        self._LookZoneY = zoneY * SIZE_ONE_TILE
        self._MaxAttackDistance = self._CharacterData.maxAttackDistance  * SIZE_ONE_TILE
        self._MinAttackDistance = self._CharacterData.attackDistanceMin * SIZE_ONE_TILE
        self._CurrentHP = self._CharacterData.hp + self._CharacterData.hpup * (self._Level - 1)
        self._TotalHP =  self._CurrentHP
        self._Attack = self._CharacterData.attack + self._CharacterData.attackup * (self._Level - 1)
        self._AttackSpeed = self._CharacterData.attackSpeed
        self._AttackInterval = 1 / (self._CharacterData.attackSpeed * ATTACK_SPEED_FACTOR)
    else
        --我方兵直接取数据
        local serverData = nil
        if self._CharacterData.type == CharacterType.CharacterType_Soldier then
            serverData = CharacterServerDataManager:GetSoldier(self._CharacterTableID)
        else
            serverData = CharacterServerDataManager:GetLeader(self._CharacterTableID)
        end
        --
        --TODO:校验是否是计算出来的，数据应该以最终计算出来的为准 
        if serverData ~= nil then
            self._Level = serverData._Level
            self._CurrentHP = serverData._Hp
            self._TotalHP = self._CurrentHP
            if serverData._MoveSpeed ~= 0 then
                self._MoveSpeed = serverData._MoveSpeed * NORMAL_WALK_SPEED_PIXEL
            else
                self._MoveSpeed = self._CharacterData.moveSpeed * NORMAL_WALK_SPEED_PIXEL
            end
            self._Attack = serverData._Attack
            self._AttackSpeed = serverData._AtkSpeed
        --下面分支只为测试，实际中不可能走到这里
        else
            self._Level = 1
            self._CurrentHP = self._CharacterData.hp + self._CharacterData.hpup * 0
            self._TotalHP = self._CurrentHP
            self._MoveSpeed = self._CharacterData.moveSpeed * NORMAL_WALK_SPEED_PIXEL
            self._Attack = self._CharacterData.attack + self._CharacterData.attackup * 0
            self._AttackSpeed = self._CharacterData.attackSpeed 
        end

        self._LookZoneX = zoneX * SIZE_ONE_TILE
        self._LookZoneY = zoneY * SIZE_ONE_TILE
        self._MaxAttackDistance = self._CharacterData.maxAttackDistance  * SIZE_ONE_TILE
        self._MinAttackDistance = self._CharacterData.attackDistanceMin * SIZE_ONE_TILE
        self._AttackInterval = 1 / (self._AttackSpeed * ATTACK_SPEED_FACTOR)
    end
end
--初始化PVE中PVP数据
function Character:InitPVEPVPLogicData()
    self:InitLogicData()
    --PVP数据校正
    self._LookZoneY = 100 * SIZE_ONE_TILE
    self._SEARCH_ENEMY_TIME = 0.5
end
--初始化沙场PVP数据(血量与攻击力取来自服务器的)
function Character:InitPVPLogicData(hp, attack)
    self:InitLogicData()
    --PVP数据校正
    self._LookZoneY = 100 * SIZE_ONE_TILE
    self._SEARCH_ENEMY_TIME = 0.5
    self._CurrentHP = hp
    self._TotalHP = hp
    self._Attack = attack
end
--初始化国战PVP数据 
function Character:InitGuoZhanPVPLogicData(hp, attack, attackSpeed)
    self:InitLogicData()
    --PVP数据校正
    self._LookZoneY = 100 * SIZE_ONE_TILE
    self._SEARCH_ENEMY_TIME = 0.5
    self._CurrentHP = hp
    self._TotalHP = hp
    self._Attack = attack
    --外部传过来了attackSpeed就赋值，目前仅针对武将
    if attackSpeed ~= nil and attackSpeed ~= 0 then
        self._AttackSpeed = attackSpeed
        self._AttackInterval = 1 / (self._AttackSpeed * ATTACK_SPEED_FACTOR)
    end
    local logInfo = stringFormat("InitGuoZhanPVPLogicData tableID:%d  ms:%.2f as:%.2f minD:%d maxD:%d aInterval:%.2f, zX:%d hp:%d attack: %d search: %.2f", self._CharacterTableID, self._MoveSpeed, self._AttackSpeed, 
    self._MinAttackDistance, self._MaxAttackDistance, self._AttackInterval, self._LookZoneX, self._TotalHP, self._Attack, self._SEARCH_ENEMY_TIME)
    print(logInfo)
end
--设置敌兵等级
function Character:SetEnemyLevel(level)
    self._Level = level
end
--获取角色移动动画速度
function Character:GetWalkAnimSpeed()
    local factor = 1
    local nowMoveSpeed = self._MoveSpeed
    if self._CharacterData ~= nil then
        local standMoveSpeed = self._CharacterData.moveSpeed * NORMAL_WALK_SPEED_PIXEL
        if standMoveSpeed ~= nil then
            factor = nowMoveSpeed / standMoveSpeed
            --print("self._CharacterTableID",self._CharacterTableID, nowMoveSpeed, standMoveSpeed, factor)
        else
            print("GetWalkAnimSpeed invalid table data", self._CharacterTableID, self._CharacterData._MoveSpeed)
            --dump(self._CharacterData)
        end
    end
    if factor <= 0 then
        factor = 1
    end
    return factor
end

--获取攻击动画速度
function Character:GetAttackAnimSpeed()
    local factor = 1
    local nowAttackSpeed = self._AttackSpeed
    if self._CharacterData ~= nil then
        local standAttackSpeed = self._CharacterData.attackSpeed
        if standAttackSpeed ~= nil then
            factor = nowAttackSpeed / standAttackSpeed
        else
            print("GetAttackAnimSpeed invalid table data", self._CharacterTableID, self._CharacterData.attackSpeed)
        end
    end
    if factor <= 0 then
        factor = 1
    end
    return factor
end
------------采用保存值的做法，避免使用乘除时可能产生差1的情况
--保存Buff属性值
function Character:SaveBuffAttackSpeed()
    self._AttackSpeedBeforeBuff = self._AttackSpeed
end
--保存 Buff属性值
function Character:SaveBuffMoveSpeed()
    self._MoveSpeedBeforeBuff = self._MoveSpeed
end
--保存 Buff攻击力
function Character:SaveAttackBuff()
    self._AttackBeforeBuff = self._Attack
end
--保存Buff
function Character:SaveAttackDistanceBuff()
    self._AttackDistanceBeforeBuff = self._MaxAttackDistance
end

--还原属性值
function Character:RestoreBuffAttackSpeed()
    self._AttackSpeed =  self._AttackSpeedBeforeBuff
end
--移动速度
function Character:RestoreBuffMoveSpeed()
    self._MoveSpeed = self._MoveSpeedBeforeBuff
end
--攻击力
function Character:RestoreAttack()
    self._Attack =  self._AttackBeforeBuff
end
--攻击距离
function Character:RestoreAttackDistance()
   self._MaxAttackDistance =  self._AttackDistanceBeforeBuff
end

--Buff是否已经存在
function Character:GetBuffByProperty(propertyType)
    if self._BuffInfoList == 0 then
        self._BuffInfoList = {}
    end
    return self._BuffInfoList[propertyType]
end
--添加 Buff
function Character:AddBuff(propertyType,  buff)
    if self._BuffInfoList == 0 then
        self._BuffInfoList = {}
    end
    
    local newBuff = BuffInfo.new()
    newBuff._BuffTableID = buff._BuffTableID
    newBuff._BuffAttributeType = propertyType
    newBuff._BuffClientID = buff._ClientGUID
    if buff._CSBFileName ~= "" then
        local newBuffNode = cc.CSLoader:createNode(buff._CSBFileName)
        local newAnim = cc.CSLoader:createTimeline(buff._CSBFileName)
        if newBuffNode ~= nil then
            newBuffNode:retain()
            newBuff._CharacterBuffNode = newBuffNode
            --[[
            local parentNode = seekNodeByName(self._CharacterRootNode, "NodeSkillBuff")
            if parentNode ~= nil then
                parentNode:addChild(newBuff._CharacterBuffNode)
            end
            ]]--
            if self._CharacterRootNode ~= nil then
                self._CharacterRootNode:addChild(newBuff._CharacterBuffNode)
            else
                print("invalid rootNode ....")
            end
            if newAnim ~= nil then
                newAnim:retain()
                newBuff._CharacterBuffNode:runAction(newAnim)
                newAnim:play("Buff", true)
                newBuff._CharacterBuffTimelineAction = newAnim
            end
        end
    end
    self._BuffInfoList[propertyType] = newBuff
end
--移除Buff
function Character:RemoveBuff(propertyType)
    local buffInfo = self._BuffInfoList[propertyType]
    if  buffInfo ~= nil then
        if buffInfo._CharacterBuffNode ~= nil then
            buffInfo._CharacterBuffNode:removeFromParent()
            buffInfo._CharacterBuffNode:removeAllChildren()
            buffInfo._CharacterBuffNode:release()
            buffInfo._CharacterBuffNode = nil
        end
        if buffInfo._CharacterBuffTimelineAction ~= nil then
            buffInfo._CharacterBuffTimelineAction:release()
            buffInfo._CharacterBuffTimelineAction = nil
        end
    end
    self._BuffInfoList[propertyType] = nil
end

--添加攻击者到List
function Character:AddAttackerToList()
    
end

--获取当前状态
function Character:GetCurrentState()
   return  self._CurrentState
end

--设置角色状态
function Character:SetState(state)
    if CharacterManager == nil then
        CharacterManager = require("main.Logic.CharacterManager")
    end
    self._CurrentState = state
    --print("Character:SetState ", self._ClientID, state)
    if self._CharacterRootNode ~= nil then
        self._CharacterRootNode:setScale(1, 1)
    end
    if self._CurrentState == CharacterState.CharacterState_Walk then
        if self._CharacterTimeLineAction ~= nil then
            local numAction = self._CharacterRootNode:getNumberOfRunningActions()
            if numAction == 0 then
                self._CharacterRootNode:runAction(self._CharacterTimeLineAction)
            end
            self._CharacterTimeLineAction:play("Walk", true)
            self._CharacterTimeLineAction:setTimeSpeed(self:GetWalkAnimSpeed())
        end
        self._CurrentSearchEnemyInterval = self._SEARCH_ENEMY_TIME
    elseif self._CurrentState == CharacterState.CharacterState_Walk_Idle then
        if self._CharacterTimeLineAction ~= nil then
            self._CharacterTimeLineAction:play("Walk", true)
            self._CharacterTimeLineAction:setTimeSpeed(self:GetWalkAnimSpeed())
        end
    elseif  self._CurrentState == CharacterState.CharacterState_Walk_ToTarget then
        if self._CharacterTimeLineAction ~= nil then
           -- self._CharacterTimeLineAction:play("Walk", true)
        end
    elseif self._CurrentState == CharacterState.CharacterState_Attack then
        self._CurrentAttackInterval = 0
        --攻击时 朝向目标
        if self._CharacterTargetClientID ~= nil and self._CharacterTargetClientID ~= 0 then
            local targetCharacter = CharacterManager:GetCharacterByClientID(self._CharacterTargetClientID)
            if targetCharacter ~= nil then
                local moveXDir = 1
                if targetCharacter._CharacterPositionX - self._CharacterPositionX < 0 then
                    moveXDir = -1
                end
                self:SetDirectonX(moveXDir)
            end
        end 
        if self._CharacterTimeLineAction ~= nil then
            self._CharacterTimeLineAction:play("Attack", false)
            self._CharacterTimeLineAction:setTimeSpeed(self:GetAttackAnimSpeed())
        end
        local gameInstance = GameGlobal:GetGameInstance()
        local gameBattle = gameInstance:GetCurrentGameStateInstance()
        local currentLevel = gameBattle:GetGameLevel()
        if currentLevel ~= nil then
            currentLevel:AddSkill(self._CharacterData.skill1, self._ClientID, self._CharacterTargetClientID)
        end
    elseif self._CurrentState == CharacterState.CharacterState_WalkForTime then
        --print("in walkForTime ", self._ClientID)
        self._CurrentAttackWalkTime = 0
        if self._CharacterTimeLineAction ~= nil then
            self._CharacterTimeLineAction:play("Walk", true)
            self._CharacterTimeLineAction:setTimeSpeed(self:GetWalkAnimSpeed())
        end
        if self._CharacterRootNode ~= nil then
            --self._CharacterRootNode:setScale(2, 2)
        end
        --如果有目标，朝目标方向移动
        local targetCharacter = CharacterManager:GetCharacterByClientID(self._CharacterTargetClientID)
        if targetCharacter == nil then
            local xDir = 0 
            if self._IsEnemy == true then
                xDir = -1
            else
                xDir = 1
            end
            self._MoveForTimeDir = cc.p(xDir, 0)
        else
            --new add 9.16 移动时间为移动一个格子所需的最大时间  根2(1.414)
            self._WALK_ALWAYS_TIME = SIZE_ONE_TILE * 1.42 / self._MoveSpeed 
            --默认朝目标移动
            local selfPosition = cc.p(self._CharacterPositionX, self._CharacterPositionY)
            local targetPosition = cc.p(targetCharacter._CharacterPositionX, targetCharacter._CharacterPositionY)
            local moveVec = cc.pSub(targetPosition, selfPosition)
            self._MoveForTimeDir = cc.pNormalize(moveVec)
            local moveXDir = 1
            if  self._MoveForTimeDir.x < 0 then
                moveXDir = -1
            end
            self:SetDirectonX(moveXDir)
            --从目标周围的九个格子内寻一空白格子
            local gameInstance = GameGlobal:GetGameInstance()
            local gameBattle = gameInstance:GetCurrentGameStateInstance()
            local currentLevel = gameBattle:GetGameLevel()
            if currentLevel == nil then
                return
            end
            local targetRow, targetCol = currentLevel:GetTileByXY(targetCharacter._CharacterPositionX, targetCharacter._CharacterPositionY)
            --3*3格子
            local tileList = 
            {
                {{-1, -1}, {-1, 0}, {-1,1}},
                {{0, -1}, {0, 0},{0,1}},
                {{1, -1}, {1, 0},{1, 1}},
            }
            local selectRow = nil
            local selectCol = nil
            --[[
            for i = 1, 3 do
                for j = 1, 3 do
                    local row = targetRow + tileList[i][j][1]
                    local col = targetCol + tileList[i][j][2]
                    if currentLevel:IsHaveAttackerInTileRowCol(self, row, col) == false  then
                        selectRow = row
                        selectCol = col
                        break
                    end
                end
                if selectRow ~= nil then
                    break
                end
            end
            ]]--
            
            local randomRow = math.random(1,3)
            local randomCol = math.random(1,3)
            selectRow = targetRow + tileList[randomRow][randomCol][1]
            selectCol = targetCol + tileList[randomRow][randomCol][2]
          
            if selectRow ~= nil and selectCol ~= nil then
                local destX, destY = currentLevel:GetXYByTile(selectRow, selectCol)
                local selfPosition = cc.p(self._CharacterPositionX, self._CharacterPositionY)
                local targetPosition = cc.p(destX, destY)
                local moveVec = cc.pSub(targetPosition, selfPosition)
                self._MoveForTimeDir = cc.pNormalize(moveVec)
                local moveXDir = 1
                if  self._MoveForTimeDir.x < 0 then
                    moveXDir = -1
                end
                self:SetDirectonX(moveXDir)
                --print("CharacterState_WalkForTime ", selectRow, selectCol, self._MoveForTimeDir.x, self._MoveForTimeDir.y, self._WALK_ALWAYS_TIME)
            end
        end
    elseif self._CurrentState == CharacterState.CharacterState_Die then
        if self._DeadTextNode == nil then
            local index = math.random(1,9)
            local frameName = stringFormat("UI_zd_wenzi_%03d.png", index)
            self._DeadTextNode = cc.Sprite:createWithSpriteFrameName(frameName)
            local hpParentNode = self._CharacterRootNode:getChildByTag(2)
            if hpParentNode ~= nil then
                hpParentNode:addChild(self._DeadTextNode)
            end
            if self._HPProgressBar ~= nil then
                self._HPProgressBar:setVisible(false)
                self._HPProgressBar:setScale(0)
            end
            if self._HpProgressBg ~= nil then
                self._HpProgressBg:setVisible(false)
                self._HpProgressBg:setScale(0)
            end
        end
        if self._CharacterTimeLineAction ~= nil then
            self._CharacterTimeLineAction:play("Dead", false)
            self._CharacterTimeLineAction:setTimeSpeed(1)
        end
    elseif self._CurrentState == CharacterState.CharacterState_DieFadeOut then
          if self._CharacterFadeOutAnim == nil then
            self._CharacterFadeOutAnim = cc.FadeOut:create(1)
            self._CharacterFadeOutAnim:retain()
          end
          if self._DeadTextNode ~= nil then
            self._DeadTextNode:setVisible(false)
          end 
         local characterSprite = self._CharacterRootNode:getChildByTag(1)
         if self._CharacterRootNode ~= nil then
            self._CharacterTimeLineAction:pause()
            self._CharacterTimeLineAction:gotoFrameAndPause(self._CharacterTimeLineAction:getEndFrame())
            self._CharacterRootNode:stopAction(self._CharacterTimeLineAction)
            self._CharacterRootNode:runAction(self._CharacterFadeOutAnim)
         end
    end
    --[[
    if self._CharacterTableID == 500423 then
        print("500423 setstate ",self._CurrentState, self._CurrentAttackInterval, self._AttackInterval, self:GetAttackAnimSpeed(), self._CharacterTimeLineAction:getCurrentFrame()
            ,self._CharacterTimeLineAction:getEndFrame())
    end
    ]]--
end

--找目标
--TODO:测试性能
--根据侦察范围，找目标敌人, 
function Character:GetEnemyTarget()
    local gameInstance = GameGlobal:GetGameInstance()
    local gameBattle = gameInstance:GetCurrentGameStateInstance()
    if CharacterManager == nil then
        CharacterManager = require("main.Logic.CharacterManager")
    end
    local currentLevel = gameBattle:GetGameLevel()
    local targetID = nil
    local minDistance = 10000
   -- print("---------Character:GetEnemyTarget")
    if currentLevel ~= nil then
        if self._IsEnemy == false then
            for k, v in pairs(currentLevel._EnemySoldierIDList)do
               -- print("false ", v)
                local curCharacter = CharacterManager:GetCharacterByClientID(v)
                if curCharacter ~= nil and curCharacter._CurrentHP > 0 then
                    local posXOffset = curCharacter._CharacterPositionX - self._CharacterPositionX
                    local posYOffset = curCharacter._CharacterPositionY - self._CharacterPositionY
                    local distance = mathSqrt(mathPower(posXOffset, 2) + mathPower(posYOffset, 2))
                    local xDistance = mathAbs(posXOffset)
                    if xDistance <= self._LookZoneX and mathAbs(posYOffset) <= self._LookZoneY then
                        if distance <= minDistance then
                            targetID = v
                            minDistance = distance
                        end
                    end
                end
            end
            --城池特殊处理
            if targetID == nil then
                local currentBattleBuildingID = currentLevel._EnemyBattleBuildingID
                if currentBattleBuildingID ~= nil then
                    local curCharacter = CharacterManager:GetCharacterByClientID(currentBattleBuildingID)
                    if curCharacter ~= nil then
                        local posXOffset = curCharacter._CharacterPositionX - self._CharacterPositionX
                        local xDistance = mathAbs(posXOffset)
                        if xDistance <= self._LookZoneX then
                            targetID = currentBattleBuildingID
                        end
                    end
                end
            end
        else
            for k, v in pairs(currentLevel._SelfSoldierIDList)do
               -- print("true ", v)
                local curCharacter = CharacterManager:GetCharacterByClientID(v)
                if curCharacter ~= nil and curCharacter._CurrentHP > 0 then
                    local posXOffset = curCharacter._CharacterPositionX - self._CharacterPositionX
                    local posYOffset = curCharacter._CharacterPositionY - self._CharacterPositionY
                    local distance = mathSqrt(mathPower(posXOffset, 2) + mathPower(posYOffset, 2))
                    local xDistance = mathAbs(posXOffset)
                    if mathAbs(posXOffset) <= self._LookZoneX and mathAbs(posYOffset) <= self._LookZoneY then
                        if distance <= minDistance then
                            targetID = v
                            minDistance = distance
                        end
                    end
                end
            end
            --城池特殊处理
            if targetID == nil then
                local currentBattleBuildingID = currentLevel._SelfBattleBuildingID
                if currentBattleBuildingID ~= nil then
                    local curCharacter = CharacterManager:GetCharacterByClientID(currentBattleBuildingID)
                    if curCharacter ~= nil then
                        local posXOffset = curCharacter._CharacterPositionX - self._CharacterPositionX
                        local xDistance = mathAbs(posXOffset)
                        if xDistance <= self._LookZoneX then
                            targetID = currentBattleBuildingID
                        end
                    end
                end
            end
        end
    end
    --print("---------result ", targetID)
    if self._IsEnemy == false and self._CharacterType == CharacterType.CharacterType_Leader then
        --print("!!!!!!!!!!!!!!!!!!CharacterPVP:GetEnemyTarget my leader: ", targetID)
    end
    return targetID
end

--校正方向到八方向(dir：原方向)
function Character:FixDirectionTo8Dir(dir)
    local cosAngle = mathAbs(dir.x)
    local xSign = 1
    if dir.x < 0 then
        xSign = -1
    end
    local ySign = 1
    if dir.y < 0 then
        ySign = -1
    end
    local newX = 0
    local newY = 0
    if cosAngle < 0.5 then
        newX = 0
        newY = 1
    elseif cosAngle < 0.86 then
        newX = 0.7
        newY = 0.7
    else
        newX = 1
        newY = 0
    end
    dir.x = xSign * newX
    dir.y = ySign * newY
    return dir
end
--是否有攻击者
function Character:IsHaveAttacker(curCharacter)
    local gameInstance = GameGlobal:GetGameInstance()
    local isHave = false
    if gameInstance:GetGameState() == GameState.GameState_Battle then
        local gameBattle = gameInstance:GetCurrentGameStateInstance()
        local currentLevel = gameBattle:GetGameLevel()
        if currentLevel ~= nil then
            isHave =  currentLevel:IsAttackerInTile(curCharacter)
        end
    end
    --如果当前目标是城池，那么强制返回false
    if self._CharacterTargetClientID ~= 0 and self._CharacterTargetClientID ~= nil then
        local targetCharacter = CharacterManager:GetCharacterByClientID(self._CharacterTargetClientID)
        if targetCharacter ~= nil then
            if targetCharacter._CharacterType == CharacterType.CharacterType_Building then
                isHave = false
            end
        end
    end
    return isHave
end
--是否能够攻击
function Character:IsCanAttack(targetCharacter)
    if targetCharacter == nil then
        return false
    end
    if targetCharacter._CurrentHP <= 0 then
        return false
    end
    local offsetX = mathAbs(targetCharacter._CharacterPositionX - self._CharacterPositionX)
    local offsetY = mathAbs(targetCharacter._CharacterPositionY - self._CharacterPositionY)
    local distance = mathSqrt(mathPower(offsetX, 2) + mathPower(offsetY, 2))
    if self._CharacterData ~= nil and targetCharacter._CharacterData ~= nil then
        distance = distance - (self._CharacterData.width + targetCharacter._CharacterData.width) / 2 * SIZE_ONE_TILE
    end
    
    if distance < self._MaxAttackDistance then
        return true
    else
        return false
    end
end
--Update
function Character:Update(deltaTime)
    if CharacterManager == nil then
        CharacterManager = require("main.Logic.CharacterManager")
    end
    --调试用
    if self._DebugLabel ~= nil then
        local showStr = "1"
        local newTargetID = self:GetEnemyTarget()
        if newTargetID == nil then
            newTargetID = 0
        end
        local currentTargetCharacter = CharacterManager:GetCharacterByClientID(newTargetID)--CharacterManager:GetCharacterByClientID(self._CharacterTargetClientID)
        if currentTargetCharacter == nil then
            showStr = "0"
        end
        local showTxt = stringFormat("%d(%d)", self._ClientID, self._CurrentHP)
        self._DebugLabel:setString(showTxt)
    end
   
    self._CurrentAttackInterval = self._CurrentAttackInterval + deltaTime
    if self._CurrentState ~= CharacterState.CharacterState_Die
        and  self._CurrentState ~= CharacterState.CharacterState_DieFadeOut
        and self._CurrentState ~= CharacterState.CharacterState_Dead then
        --判断当前是否
        if self._CurrentHP <= 0 then
            --国战PVP时以服务器传过来的死亡结果为主 --这种方案临时作废，代码预留
            --[[
            local gameInstance = GameGlobal:GetGameInstance()
            local gameBattle = gameInstance:GetCurrentGameStateInstance()
            local currentLevel = gameBattle:GetGameLevel()
            if currentLevel ~= nil and currentLevel._LevelLogicType == LevelLogicType.LevelLogicType_GuoZhanPVP then
                
                --return
            end
            ]]--
            self:SetState(CharacterState.CharacterState_Die)
        end
    end
    --血条显示
    self._HPBarShowTime = self._HPBarShowTime - deltaTime
    if self._CurrentState ~= CharacterState.CharacterState_Die and self._CurrentState ~= CharacterState.CharacterState_Dead then
       if self._HPBarShowTime > 0 then
            if self._HPProgressBar ~= nil then
                self._HPProgressBar:setVisible(true)
                self._HpProgressBg:setVisible(true)
            end
       else
            if self._HPProgressBar ~= nil then
                self._HPProgressBar:setVisible(false)
                self._HpProgressBg:setVisible(false)
            end
       end
    end
    ------TODO:是不是考虑将此部分逻辑转移到到AI里去
    --角色状态切换
    if self._CurrentState == CharacterState.CharacterState_Walk then
        --搜寻目标敌人
        self._CurrentSearchEnemyInterval = self._CurrentSearchEnemyInterval + deltaTime
        local targetID = nil
        if self._CurrentSearchEnemyInterval >= self._SEARCH_ENEMY_TIME then
            targetID = self:GetEnemyTarget()
            self._CurrentSearchEnemyInterval = 0
        end

        if targetID == nil then
            --定一个主方向
            if self._IsEnemy == true then
                self:SetDirectonX(-1)
            else
                self:SetDirectonX(1)
            end
            local newPositionX = self._CharacterPositionX + self._CharacterDirectionX * self._MoveSpeed * deltaTime
            self:SetPosition(newPositionX,self._CharacterPositionY)
        else
            --找到敌人，如果在攻击范围内发动攻击，否则朝目标移动
            self._CharacterTargetClientID = targetID
            local targetCharacter = CharacterManager:GetCharacterByClientID(targetID)
            if self:IsCanAttack(targetCharacter) then
                if self:IsHaveAttacker(self) == false then
                    self:SetState(CharacterState.CharacterState_Attack)
                else
                    self:SetState(CharacterState.CharacterState_WalkForTime)
                end
            else
                self:SetState(CharacterState.CharacterState_Walk_ToTarget)
            end
        end
    --朝当前目标移动
    elseif self._CurrentState == CharacterState.CharacterState_Walk_ToTarget then
        local targetCharacter = CharacterManager:GetCharacterByClientID(self._CharacterTargetClientID)
        if targetCharacter == nil then
            self:SetState(CharacterState.CharacterState_Walk)
            return
        end
        --搜寻目标敌人
        self._CurrentSearchEnemyInterval = self._CurrentSearchEnemyInterval + deltaTime
        local newTargetID = self._CharacterTargetClientID
        if self._CurrentSearchEnemyInterval >= self._SEARCH_ENEMY_TIME then
            newTargetID = self:GetEnemyTarget()
            self._CurrentSearchEnemyInterval = 0
        end
        if newTargetID ~= self._CharacterTargetClientID then
            --老的逻辑
           -- self:SetState(CharacterState.CharacterState_Walk)
           -- return
           
           --新的逻辑 9.11
            self._CharacterTargetClientID = newTargetID
            targetCharacter = CharacterManager:GetCharacterByClientID(self._CharacterTargetClientID)
            if targetCharacter == nil then
                return
            end
        end
        --移动，检测当前距离目标，如果在攻击范围，改为攻击状态
        local selfPosition = cc.p(self._CharacterPositionX, self._CharacterPositionY)
        local targetPosition = cc.p(targetCharacter._CharacterPositionX, targetCharacter._CharacterPositionY)
        local moveVec = cc.pSub(targetPosition, selfPosition)
        local moveDir = cc.pNormalize(moveVec)
       -- local moveDir = self:FixDirectionTo8Dir(moveDir)
        local moveDistance = self._MoveSpeed * deltaTime 
        local newPosition = cc.pAdd(selfPosition , cc.pMul(moveDir, moveDistance))
        local currentDistance = cc.pGetDistance(newPosition, targetPosition)
        local moveXDir = 1
        if moveDir.x > 0 then
            moveXDir = 1
        else
            moveXDir = -1
        end
        self:SetDirectonX(moveXDir)
        self:SetPosition(newPosition.x, newPosition.y)
        if self:IsCanAttack(targetCharacter) then
            if self:IsHaveAttacker(self) == false then
                self:SetState(CharacterState.CharacterState_Attack)
            else
                self:SetState(CharacterState.CharacterState_WalkForTime)
            end
        end
       -- print("CharacterState_Walk_ToTarget ",self._ClientID, self._CharacterTableID, self._CharacterTargetClientID, moveDistance, os.date(), self._MoveSpeed, newPosition.x, newPosition.y)
    --  攻击间隔，歇会
    elseif self._CurrentState == CharacterState.CharacterState_Walk_Idle then
        if self._CurrentAttackInterval > self._AttackInterval then
            self._CurrentAttackInterval = 0
            --寻找个目标
            local newTargetID = self:GetEnemyTarget()
            local currentTarget = CharacterManager:GetCharacterByClientID(newTargetID)
            if currentTarget == nil then
                self:SetState(CharacterState.CharacterState_Walk)
            else
                self._CharacterTargetClientID = newTargetID
                if self:IsCanAttack(currentTarget) then
                    if self:IsHaveAttacker(self) == false then
                        self:SetState(CharacterState.CharacterState_Attack)
                    else
                        self:SetState(CharacterState.CharacterState_WalkForTime)
                    end
                else
                    self:SetState(CharacterState.CharacterState_WalkForTime)
                end
            end
        end
    elseif self._CurrentState == CharacterState.CharacterState_WalkForTime then
        local targetCharacter = CharacterManager:GetCharacterByClientID(self._CharacterTargetClientID)
        if targetCharacter == nil then
            self:SetState(CharacterState.CharacterState_Walk)
            return
        end
        --搜寻目标敌人
        self._CurrentSearchEnemyInterval = self._CurrentSearchEnemyInterval + deltaTime
        local newTargetID = self._CharacterTargetClientID
        if self._CurrentSearchEnemyInterval >= self._SEARCH_ENEMY_TIME then
            newTargetID = self:GetEnemyTarget()
            self._CurrentSearchEnemyInterval = 0
        end
        if newTargetID ~= self._CharacterTargetClientID then
            --老的逻辑
            --self:SetState(CharacterState.CharacterState_Walk)11
           -- return
           
            --新的逻辑 9.11
            self._CharacterTargetClientID = newTargetID
            targetCharacter = CharacterManager:GetCharacterByClientID(self._CharacterTargetClientID)
            if targetCharacter == nil then
                return
            end
        end
        
        self._CurrentAttackWalkTime = self._CurrentAttackWalkTime + deltaTime
        local selfPosition = cc.p(self._CharacterPositionX, self._CharacterPositionY)
        local moveDistance = self._MoveSpeed * deltaTime 
        local newPosition = cc.pAdd(selfPosition , cc.pMul(self._MoveForTimeDir, moveDistance))
        self:SetPosition(newPosition.x, newPosition.y)
        if self:IsCanAttack(targetCharacter) then
            if self:IsHaveAttacker(self) == false then
                self:SetState(CharacterState.CharacterState_Attack)
                return
            end
        end
        if self._CurrentAttackWalkTime >= self._WALK_ALWAYS_TIME then
            self._CurrentAttackWalkTime = 0
            self:SetState(CharacterState.CharacterState_Walk)
        end
       -- print("CharacterState_WalkForTime", self._ClientID, self._CurrentAttackWalkTime)
    --攻击目标    
    elseif self._CurrentState == CharacterState.CharacterState_Attack then
         local currentTarget = CharacterManager:GetCharacterByClientID(self._CharacterTargetClientID)
         if currentTarget == nil or currentTarget._CurrentHP < 0 then
            self:SetState(CharacterState.CharacterState_Walk)
         else
             if self._CurrentAttackInterval > self._AttackInterval then
                self._CurrentAttackInterval = 0
                --寻找个目标
                local newTargetID = self:GetEnemyTarget()
                currentTarget = CharacterManager:GetCharacterByClientID(newTargetID)
                if currentTarget == nil then
                    self:SetState(CharacterState.CharacterState_Walk)
                else
                    self._CharacterTargetClientID = newTargetID
                    if self:IsCanAttack(currentTarget) then
                        if self:IsHaveAttacker(self) == false then
                            self:SetState(CharacterState.CharacterState_Attack)
                        else
                            self:SetState(CharacterState.CharacterState_WalkForTime)
                        end
                    else
                        self:SetState(CharacterState.CharacterState_WalkForTime)
                    end
                end
             else
                 if self._CharacterTimeLineAction:getCurrentFrame() >= self._CharacterTimeLineAction:getEndFrame() then
                    self:SetState(CharacterState.CharacterState_Walk_Idle)
                 end
             end
         end
        
   --死亡     
    elseif self._CurrentState == CharacterState.CharacterState_Die then
        --死亡动作播放完成后，进入CharacterState_Dead状态
        if self._CharacterTimeLineAction:getCurrentFrame() >= self._CharacterTimeLineAction:getEndFrame() then
            self:SetState(CharacterState.CharacterState_DieFadeOut)
        end
   elseif self._CurrentState == CharacterState.CharacterState_DieFadeOut then
        --死亡动作播放完成后，进入CharacterState_Dead状态
        if self._CharacterFadeOutAnim:isDone() then
            self:SetState(CharacterState.CharacterState_Dead)
            if self._CharacterData.type == CharacterType.CharacterType_Soldier then
                DispatchEvent(GameEvent.GameEvent_SoldierDie, {guid = self._ClientID, tableID = self._CharacterTableID, isEnemy = self._IsEnemy})
            elseif self._CharacterData.type == CharacterType.CharacterType_Leader then
                DispatchEvent(GameEvent.GameEvent_LeaderDie, {guid = self._ClientID, tableID = self._CharacterTableID, isEnemy = self._IsEnemy})
            end
            --print("--------------------Character Die", self._ClientID, self._CharacterTableID)
        end
    end

end

-----------------------------------------------set 与  get ----------------------------------------------
--获取根节点
function Character:GetCharacterNode()
    return self._CharacterRootNode
end
--获取状态
function Character:GetCharacterState()
    return self._CurrentState
end

--设置位置
function Character:SetPosition(x, y)
    local newX = mathCeil(x)
    local newY = mathCeil(y)
    local oldX = mathCeil(self._CharacterPositionX)
    local oldY = mathCeil(self._CharacterPositionY)
    --更新关卡Tile数据
    local currentLevel = GameGlobal:GetGameLevel()
    if currentLevel ~= nil then
        currentLevel:UpdateLevelTileData(oldX, oldY, newX, newY, self._ClientID)
    end
    --print("SetPosition ", newX, newY, x, y)
    self._CharacterPositionX = x
    self._CharacterPositionY = y
    
    if self._CharacterRootNode ~= nil then
        self._CharacterRootNode:setPosition(self._CharacterPositionX, self._CharacterPositionY)
        local parentNode = self._CharacterRootNode:getParent()
        if parentNode ~= nil then
            parentNode:reorderChild(self._CharacterRootNode, -y)
        end
    end
end


--是否敌方设置
function  Character:IsEnemy(isEnemy)
    self._IsEnemy = isEnemy
    local resName = "meishu/ui/zhandou/UI_zd_wujiangxue_02.png"
    
    if self._CharacterType == 1 then
        resName = "meishu/ui/zhandou/UI_zd_shibingxue_02.png"
    end
    if isEnemy == true then
        resName = "meishu/ui/zhandou/UI_zd_wujiangxue_03.png"
        if self._CharacterType == 1 then
            resName = "meishu/ui/zhandou/UI_zd_shibingxue_03.png"
        end
    end
    if self._HPProgressBar == nil then
        self._HpProgressBg = display.newSprite("meishu/ui/zhandou/UI_zd_wujiangxue_01.png",0,0)
        if self._CharacterType == 1 then
            self._HpProgressBg = display.newSprite("meishu/ui/zhandou/UI_zd_shibingxue_01.png",0,0)
        end
        self._HPProgressBar = cc.ProgressTimer:create(cc.Sprite:create(resName))
        self._HPProgressBar:retain()
        self._HPProgressBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        self._HPProgressBar:setMidpoint(cc.p(0, 0))
        self._HPProgressBar:setBarChangeRate(cc.p(1, 0))
        self._HPProgressBar:setPercentage(100)
        self._HPProgressBar:setPosition(cc.p(0, 0))
        self._HPProgressBar:setVisible(false)
        self._HpProgressBg:setVisible(false)
        if self._CharacterRootNode ~= nil then
            local hpParentNode = self._CharacterRootNode:getChildByTag(2)
            if hpParentNode ~= nil then
                hpParentNode:addChild(self._HpProgressBg)
                hpParentNode:addChild(self._HPProgressBar)
            end
        end
    end
     
    if self._IsEnemy == true then
        self:SetDirectonX(-1)
    else
        self:SetDirectonX(1)
    end
    
    --临时为了区分敌方兵,放大1.5倍 
    if isEnemy == true then
        if self._CharacterRootNode ~= nil then
            --self._CharacterRootNode:setScale(2,2)
        end
    end
end

--设置朝向 dirX: 1:右 -1:左
function Character:SetDirectonX(dirX)
    if self._CharacterRootNode ~= nil then
        local characterSprite = self._CharacterRootNode:getChildByTag(1)
        if characterSprite == nil then
            printError(" Character:SetDirectonX sprite == nil %d", self._CharacterTableID)
        end
        --characterSprite = tolua.cast(characterSprite, "cc.Sprite")
        if dirX == -1 then
            characterSprite:setFlippedX(true)
        else
            characterSprite:setFlippedX(false)
        end
        self._CharacterDirectionX = dirX
    end
end
--ID
function Character:SetClientGUID(guid)
    self._ClientID = guid
end
--Get ID
function Character:GetClientGUID()
    return self._ClientID
end
--设置 当前血量
function Character:SetCurrentHP(hp)
    if hp < 0 then
        hp = 0
    end
    if hp ~= self._CurrentHP then
        local changeValue = self._CurrentHP - hp
        self._CurrentHP = hp
        local percent =  mathFloor(self._CurrentHP / self._TotalHP * 100)
        if self._HPProgressBar ~= nil then
            self._HPProgressBar:setPercentage(percent)
        end
        self._HPBarShowTime = 3
        DispatchEvent(GameEvent.GameEvent_BattleHPChange, {isEnemy = self._IsEnemy, hpChange = changeValue})
    end
end

function Character:GetCurrentHP()
    return self._CurrentHP
end


return Character