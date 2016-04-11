----
-- 文件名称：CharacterPVP.lua
-- 功能描述：PVP角色类（基于Character将逻辑与显示分离的版本）
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-9-29
--

local CharacterDataManager = GetCharacterDataManager()
--local CharacterServerDataManager = GameGlobal:GetCharacterServerDataManager()
local CharacterPVPEntity = require("main.Logic.CharacterPVPEntity")

local stringFormat = string.format
local mathAbs = math.abs
local mathFloor = math.floor
local mathPower = math.pow
local mathSqrt = math.sqrt
local mathCeil = math.ceil
--依赖的数据结构 TODO: entity

local BuffInfo = class("BuffInfo")
function BuffInfo:ctor()
    --Buff 表格ID
    self._BuffTableID = 0
    --Buff 属性类型
    self._BuffAttributeType = 0
    --Buff clientID
    self._BuffClientID = 0
    --buff entity 
    self._BuffEntity = 0
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


local CharacterPVP = class("CharacterPVP")
--构造
function CharacterPVP:ctor(characterTableID, isNeedShow, currentLevel)
    --当前Level
    self._CurrentLevel = currentLevel
    --
    self._CharacterManager = self._CurrentLevel:GetCharacterPVPManager()
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

    --血条显示时间
    self._HPBarShowTime = 0

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
    --武将技能伤害系数
    self._SkillHurtFactor = 1
    
    --显示相关
    self._CharacterEntity = nil
    if isNeedShow == nil then
        isNeedShow = false
    end
     self._IsNeedShow = isNeedShow
    if isNeedShow == true then
        self._CharacterEntity = CharacterPVPEntity:new()
    end
    --CSB资源名称
    self._CSBName = ""
    --归属武将TableID
    self._BelongWuJiangTableID = 0
    --所属大阵的row col
    self._ZhenXingRow = 0
    self._ZhenXingCol = 0
    --原阵型兵数目
    self._ZhenXingSoldierCount = 0
    self:Init()
end

--初始化
function CharacterPVP:Init()
    self._CurrentSearchEnemyInterval = self._SEARCH_ENEMY_TIME
    --temp
    if self._CharacterData == nil then
        print("CharacterPVP self._CharacterData == nil ", self._CharacterTableID)
        --self._CharacterData = CharacterDataManager[0]
    end
    if self._CharacterData ~= nil then
        self._CharacterType = self._CharacterData.type
    end
    if self._CharacterEntity ~= nil then
        self._CharacterEntity:Init(self._CharacterData)
    end
    self._SkillHurtFactor = self._CharacterData.skilldamage
    self:SetState(CharacterState.CharacterState_Walk)
    self._AttackMeCharacterIDList = {}
end

--销毁 
function CharacterPVP:Destroy()
    --Buff 
    if self._BuffInfoList ~= nil and self._BuffInfoList ~= 0 then
        for k, v in pairs(self._BuffInfoList)do
            if v._BuffEntity ~= nil then
                v._BuffEntity:Destroy()
            end
        end
    end
    self._BuffInfoList = nil
    
    if self._CharacterEntity ~= nil then
        self._CharacterEntity:Destroy()
        self._CharacterEntity = nil
    end
    
    self._AttackMeCharacterIDList = nil
end



--初始化角色动态数据
function CharacterPVP:InitLogicData()
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
           -- serverData = CharacterServerDataManager:GetSoldier(self._CharacterTableID)
        else
            --serverData = CharacterServerDataManager:GetLeader(self._CharacterTableID)
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
--初始化沙场PVP数据(血量与攻击力取来自服务器的)
function CharacterPVP:InitPVPLogicData(hp, attack, attackSpeed)
    self:InitLogicData()
    --PVP数据校正
    self._LookZoneY = 100 * SIZE_ONE_TILE
    self._SEARCH_ENEMY_TIME = 0.5
    self._CurrentHP = hp
    self._TotalHP = hp
    self._Attack = attack
    --外部传过来了attackSpeed就赋值
    if attackSpeed ~= nil and attackSpeed ~= 0 then
        self._AttackSpeed = attackSpeed
        self._AttackInterval = 1 / (self._AttackSpeed * ATTACK_SPEED_FACTOR)
    end
    --local logInfo = stringFormat("InitPVPLogicData tableID:%d  ms:%.2f as:%.2f minD:%d maxD:%d aInterval:%.2f, zX:%d hp:%d attack: %d search: %.2f", self._CharacterTableID, self._MoveSpeed, self._AttackSpeed, 
        --self._MinAttackDistance, self._MaxAttackDistance, self._AttackInterval, self._LookZoneX, self._TotalHP, self._Attack, self._SEARCH_ENEMY_TIME)
   -- print(logInfo)
end

--初始化国战PVP数据 
function CharacterPVP:InitGuoZhanPVPLogicData(hp, attack, attackSpeed)
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
    --local logInfo = stringFormat("InitGuoZhanPVPLogicData tableID:%d  ms:%.2f as:%.2f minD:%d maxD:%d aInterval:%.2f, zX:%d hp:%d attack: %d search: %.2f", self._CharacterTableID, self._MoveSpeed, self._AttackSpeed, 
       -- self._MinAttackDistance, self._MaxAttackDistance, self._AttackInterval, self._LookZoneX, self._TotalHP, self._Attack, self._SEARCH_ENEMY_TIME)
    --print(logInfo)
end

--设置敌兵等级
function CharacterPVP:SetEnemyLevel(level)
    self._Level = level
end
--设置
function CharacterPVP:SetBelongWuJiang(wuJiangTableID)
    if wuJiangTableID ~= nil then
        self._BelongWuJiangTableID = wuJiangTableID
    end
end
--设置大阵的行列
function CharacterPVP:SetZhenXingRowCol(row, col)
    self._ZhenXingRow = row
    self._ZhenXingCol = col
end
--原阵型兵数目 
function CharacterPVP:SetZhenXingSoldierCount(soldierCount)
    self._ZhenXingSoldierCount = soldierCount
end

--获取角色移动动画速度
function CharacterPVP:GetWalkAnimSpeed()
    local factor = 1
    local nowMoveSpeed = self._MoveSpeed
    if self._CharacterData ~= nil then
        local standMoveSpeed = self._CharacterData.moveSpeed * NORMAL_WALK_SPEED_PIXEL
        if standMoveSpeed ~= nil then
            factor = nowMoveSpeed / standMoveSpeed
            --print("self._CharacterTableID",self._CharacterTableID, nowMoveSpeed, standMoveSpeed, factor)
        else
            print("GetWalkAnimSpeed invalid table data", self._CharacterTableID, self._CharacterData._MoveSpeed)
            dump(self._CharacterData)
        end
    end
    if factor <= 0 then
        factor = 1
    end
    return factor
end

--获取攻击动画速度
function CharacterPVP:GetAttackAnimSpeed()
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

--------------- buff相关 begin ---------------------
------------采用保存值的做法，避免使用乘除时可能产生差1的情况
--保存Buff属性值
function CharacterPVP:SaveBuffAttackSpeed()
    self._AttackSpeedBeforeBuff = self._AttackSpeed
end
--保存 Buff属性值
function CharacterPVP:SaveBuffMoveSpeed()
    self._MoveSpeedBeforeBuff = self._MoveSpeed
end
--保存 Buff攻击力
function CharacterPVP:SaveAttackBuff()
    self._AttackBeforeBuff = self._Attack
end
--保存Buff
function CharacterPVP:SaveAttackDistanceBuff()
    self._AttackDistanceBeforeBuff = self._MaxAttackDistance
end

--还原属性值
function CharacterPVP:RestoreBuffAttackSpeed()
    self._AttackSpeed =  self._AttackSpeedBeforeBuff
end
--移动速度
function CharacterPVP:RestoreBuffMoveSpeed()
    self._MoveSpeed = self._MoveSpeedBeforeBuff
end
--攻击力
function CharacterPVP:RestoreAttack()
    self._Attack =  self._AttackBeforeBuff
end
--攻击距离
function CharacterPVP:RestoreAttackDistance()
    self._MaxAttackDistance =  self._AttackDistanceBeforeBuff
end

--Buff是否已经存在
function CharacterPVP:GetBuffByProperty(propertyType)
    if self._BuffInfoList == 0 then
        self._BuffInfoList = {}
    end
    return self._BuffInfoList[propertyType]
end
--添加 Buff
function CharacterPVP:AddBuff(propertyType,  buff)
    if self._BuffInfoList == 0 then
        self._BuffInfoList = {}
    end

    local newBuff = BuffInfo.new()
    newBuff._BuffTableID = buff._BuffTableID
    newBuff._BuffAttributeType = propertyType
    newBuff._BuffClientID = buff._ClientGUID
    if self._IsNeedShow == true then
        if newBuff._BuffEntity == nil then
            newBuff._BuffEntity = BuffEntityInfo:new(buff._CSBFileName)
        end

        if buff._CSBFileName ~= "" then
            newBuff._BuffEntity:Init()
        end
    else
        newBuff._BuffEntity = nil
    end
    self._BuffInfoList[propertyType] = newBuff
end

--移除Buff
function CharacterPVP:RemoveBuff(propertyType)
    local buffInfo = self._BuffInfoList[propertyType]
    if  buffInfo ~= nil then
        if buffInfo._BuffEntity ~= nil then
            buffInfo._BuffEntity:Destroy()
            buffInfo._BuffEntity = nil
        end
    end
    self._BuffInfoList[propertyType] = nil
end
---------------buff相关 end---------------------


--添加攻击者到List
function CharacterPVP:AddAttackerToList()

end

--获取当前状态
function CharacterPVP:GetCurrentState()
    return  self._CurrentState
end

--设置角色状态
function CharacterPVP:SetState(state)
    self._CurrentState = state
    local currentState = self._CurrentState
    if self._CharacterTableID == 500423 then
        print("CharacterPVP:SetState 500423", state, os.date())
    end
    if currentState == CharacterState.CharacterState_Walk then
        self._CurrentSearchEnemyInterval = self._SEARCH_ENEMY_TIME
    elseif currentState == CharacterState.CharacterState_Walk_Idle then

    elseif currentState == CharacterState.CharacterState_Walk_ToTarget then

    elseif currentState == CharacterState.CharacterState_Attack then
        self._CurrentAttackInterval = 0
        --攻击时 朝向目标
        if self._CharacterTargetClientID ~= nil and self._CharacterTargetClientID ~= 0 then
            local targetCharacter = self._CharacterManager:GetCharacterByClientID(self._CharacterTargetClientID)
            if targetCharacter ~= nil then
                local moveXDir = 1
                if targetCharacter._CharacterPositionX - self._CharacterPositionX < 0 then
                    moveXDir = -1
                end
                self:SetDirectonX(moveXDir)
            end
        end 
        local currentLevel = self._CurrentLevel
        if currentLevel ~= nil then
            currentLevel:AddSkill(self._CharacterData.skill1, self._ClientID, self._CharacterTargetClientID)
        end
    elseif currentState == CharacterState.CharacterState_WalkForTime then
        --print("in walkForTime ", self._ClientID)
        self._CurrentAttackWalkTime = 0
        --如果有目标，朝目标方向移动
        local targetCharacter = self._CharacterManager:GetCharacterByClientID(self._CharacterTargetClientID)
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
            --[[
            --从目标周围的九个格子内寻一空白格子(这种方式在PVP中不合适，会使得计算结果不一致，因为有随机random,去掉)
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
                print("CharacterState_WalkForTime ", selectRow, selectCol, self._MoveForTimeDir.x, self._MoveForTimeDir.y, self._WALK_ALWAYS_TIME)
            end
            ]]--
        end

    elseif currentState == CharacterState.CharacterState_Die then

    elseif currentState == CharacterState.CharacterState_DieFadeOut then

    end
    
    if self._CharacterEntity ~= nil then
        self._CharacterEntity:SetState(currentState, self)
    end
end

--找目标
--TODO:测试性能
--根据侦察范围，找目标敌人, 
function CharacterPVP:GetEnemyTarget()

    local currentLevel = self._CurrentLevel
    local targetID = nil
    local minDistance = 10000
    local pairs = pairs
    -- print("---------Character:GetEnemyTarget")
    if currentLevel ~= nil then
        if self._IsEnemy == false then
            for k, v in pairs(currentLevel._EnemySoldierIDList)do
                -- print("false ", v)
                local curCharacter = self._CharacterManager:GetCharacterByClientID(v)
                if curCharacter ~= nil and curCharacter._CurrentHP > 0 then
                    local posXOffset = curCharacter._CharacterPositionX - self._CharacterPositionX
                    local posYOffset = curCharacter._CharacterPositionY - self._CharacterPositionY
                    local xDistance = mathAbs(posXOffset)
                    local yDistance = mathAbs(posYOffset)
                    if xDistance <= self._LookZoneX and yDistance <= self._LookZoneY then
                        local distance = mathSqrt(mathPower(posXOffset, 2) + mathPower(posYOffset, 2))
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
                    local curCharacter = self._CharacterManager:GetCharacterByClientID(currentBattleBuildingID)
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
                local curCharacter = self._CharacterManager:GetCharacterByClientID(v)
                if curCharacter ~= nil and curCharacter._CurrentHP > 0 then
                    local posXOffset = curCharacter._CharacterPositionX - self._CharacterPositionX
                    local posYOffset = curCharacter._CharacterPositionY - self._CharacterPositionY
                    local xDistance = mathAbs(posXOffset)
                    if mathAbs(posXOffset) <= self._LookZoneX and mathAbs(posYOffset) <= self._LookZoneY then
                        local distance = mathSqrt(mathPower(posXOffset, 2) + mathPower(posYOffset, 2))
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
                    local curCharacter = self._CharacterManager:GetCharacterByClientID(currentBattleBuildingID)
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
    --print("---------GetEnemyTarget result ", targetID)
    if self._IsEnemy == false and self._CharacterType == CharacterType.CharacterType_Leader then
        --print("!!!!!!!!!!!!!!!!!!CharacterPVP:GetEnemyTarget my leader: ", targetID)
    end
    return targetID
end

--校正方向到八方向(dir：原方向)
function CharacterPVP:FixDirectionTo8Dir(dir)
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
function CharacterPVP:IsHaveAttacker(curCharacter)
    local isHave = false
    local currentLevel = self._CurrentLevel
    if currentLevel ~= nil then
        isHave =  currentLevel:IsAttackerInTile(curCharacter)
    end

    --如果当前目标是城池，那么强制返回false
    if self._CharacterTargetClientID ~= 0 and self._CharacterTargetClientID ~= nil then
        local targetCharacter = self._CharacterManager:GetCharacterByClientID(self._CharacterTargetClientID)
        if targetCharacter ~= nil then
            if targetCharacter._CharacterType == CharacterType.CharacterType_Building then
                isHave = false
            end
        end
    end
    return isHave
end
--是否能够攻击
function CharacterPVP:IsCanAttack(targetCharacter)
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
function CharacterPVP:Update(deltaTime)

    self._CurrentAttackInterval = self._CurrentAttackInterval + deltaTime
    if self._CurrentState ~= CharacterState.CharacterState_Die
        and  self._CurrentState ~= CharacterState.CharacterState_DieFadeOut
        and self._CurrentState ~= CharacterState.CharacterState_Dead then
        --判断当前是否
        if self._CurrentHP <= 0 then
            self:SetState(CharacterState.CharacterState_Die)
        end
    end
    --血条显示
    self._HPBarShowTime = self._HPBarShowTime - deltaTime
    if self._CurrentState ~= CharacterState.CharacterState_Die and self._CurrentState ~= CharacterState.CharacterState_Dead then
        if self._HPBarShowTime > 0 then
            if self._CharacterEntity ~= nil  then
                self._CharacterEntity:SetHPProgressBarVisible(true)
            end
        else
            if self._CharacterEntity ~= nil  then
                self._CharacterEntity:SetHPProgressBarVisible(false)
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
            self:SetPosition(newPositionX, self._CharacterPositionY)
        else
            --找到敌人，如果在攻击范围内发动攻击，否则朝目标移动
            self._CharacterTargetClientID = targetID
            local targetCharacter = self._CharacterManager:GetCharacterByClientID(targetID)
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
        local targetCharacter = self._CharacterManager:GetCharacterByClientID(self._CharacterTargetClientID)
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
            targetCharacter = self._CharacterManager:GetCharacterByClientID(self._CharacterTargetClientID)
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
            local currentTarget = self._CharacterManager:GetCharacterByClientID(newTargetID)
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
        local targetCharacter = self._CharacterManager:GetCharacterByClientID(self._CharacterTargetClientID)
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
            targetCharacter = self._CharacterManager:GetCharacterByClientID(self._CharacterTargetClientID)
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
        --攻击间隔时间到
        if self._CurrentAttackInterval > self._AttackInterval then
            self._CurrentAttackInterval = 0
            --寻找个目标
            local newTargetID = self:GetEnemyTarget()
            local currentTarget = self._CharacterManager:GetCharacterByClientID(newTargetID)
            if currentTarget == nil then
                self:SetState(CharacterState.CharacterState_Walk)
            else
                self._CharacterTargetClientID = newTargetID
                local currentCharacter = self._CharacterManager:GetCharacterByClientID(self._CharacterTargetClientID)
                if self:IsCanAttack(currentCharacter) then
                    if self:IsHaveAttacker(self) == false then
                        self:SetState(CharacterState.CharacterState_Attack)
                    else
                        self:SetState(CharacterState.CharacterState_WalkForTime)
                    end
                else
                    self:SetState(CharacterState.CharacterState_Walk)
                end
            end

        --攻击间隔时间不到    
        else
            if self._CharacterEntity ~= nil then
                --当前攻击状态是否已经结束
                if self._CharacterEntity:IsCurrentAnimDone() then
                    self:SetState(CharacterState.CharacterState_Walk_Idle)
                end 
            end
        end
 
    --死亡     
    elseif self._CurrentState == CharacterState.CharacterState_Die then
        if self._CharacterEntity == nil then
            --没有表现的直接销毁
            self:SetState(CharacterState.CharacterState_Dead)
            --[[
            if self._CharacterData.type == CharacterType.CharacterType_Soldier then
                DispatchEvent(GameEvent.GameEvent_SoldierDie, {guid = self._ClientID, tableID = self._CharacterTableID, isEnemy = self._IsEnemy})
            elseif self._CharacterData.type == CharacterType.CharacterType_Leader then
                DispatchEvent(GameEvent.GameEvent_LeaderDie, {guid = self._ClientID, tableID = self._CharacterTableID, isEnemy = self._IsEnemy})
            end
            ]]--
            self._CurrentLevel:RemoveFromSoldiers(self._ClientID)
        else
            --死亡动作播放完成后，进入CharacterState_Dead状态
            if self._CharacterEntity:IsCurrentAnimDone() then
                self:SetState(CharacterState.CharacterState_DieFadeOut)
            end
        end
    elseif self._CurrentState == CharacterState.CharacterState_DieFadeOut then
        if self._CharacterEntity ~= nil then
            if self._CharacterEntity:IsDieFadeOutDone() then
                self:SetState(CharacterState.CharacterState_Dead)
                if self._CharacterData.type == CharacterType.CharacterType_Soldier then
                    DispatchEvent(GameEvent.GameEvent_SoldierDie, {guid = self._ClientID, tableID = self._CharacterTableID, isEnemy = self._IsEnemy})
                elseif self._CharacterData.type == CharacterType.CharacterType_Leader then
                    DispatchEvent(GameEvent.GameEvent_LeaderDie, {guid = self._ClientID, tableID = self._CharacterTableID, isEnemy = self._IsEnemy})
                end
            end
        end
    end
end

-----------------------------------------------set 与  get ----------------------------------------------
--获取根节点
function CharacterPVP:GetCharacterNode()
    if self._CharacterEntity == nil then
        return nil
    end
    return self._CharacterEntity:GetCharacterNode()
end
--获取状态
function CharacterPVP:GetCharacterState()
    return self._CurrentState
end

--设置位置
function CharacterPVP:SetPosition(x, y)
    local newX = mathCeil(x)
    local newY = mathCeil(y)
    local oldX = mathCeil(self._CharacterPositionX)
    local oldY = mathCeil(self._CharacterPositionY)
    --更新关卡Tile数据
    local currentLevel = self._CurrentLevel
    if currentLevel ~= nil then
        currentLevel:UpdateLevelTileData(oldX, oldY, newX, newY, self._ClientID)
    end

    --print("SetPosition ", newX, newY, x, y)
    self._CharacterPositionX = x
    self._CharacterPositionY = y

    if self._CharacterEntity ~= nil then
        self._CharacterEntity:SetPosition(x, y, self)
        
    end
end


--是否敌方设置
function  CharacterPVP:IsEnemy(isEnemy)
    self._IsEnemy = isEnemy
    if self._CharacterEntity ~= nil then
        self._CharacterEntity:InitHPProgressBar(isEnemy, self._CharacterType)
    end
    
    if self._IsEnemy == true then
        self:SetDirectonX(-1)
    else
        self:SetDirectonX(1)
    end
    
end

--设置朝向 dirX: 1:右 -1:左
function CharacterPVP:SetDirectonX(dirX)
   if self._CharacterEntity ~= nil then
        self._CharacterEntity:SetDirectonX(dirX)
   end
    self._CharacterDirectionX = dirX
end
--ID
function CharacterPVP:SetClientGUID(guid)
    self._ClientID = guid
end
--Get ID
function CharacterPVP:GetClientGUID()
    return self._ClientID
end
--设置 当前血量
function CharacterPVP:SetCurrentHP(hp)
    if hp < 0 then
        hp = 0
    end
    if hp ~= self._CurrentHP then
        local changeValue = self._CurrentHP - hp
        self._CurrentHP = hp
        local percent =  mathFloor(self._CurrentHP / self._TotalHP * 100)
        if self._CharacterEntity ~= nil then
            self._CharacterEntity:SetHPProgressBarPercent(percent)
        end
        self._HPBarShowTime = 3
        DispatchEvent(GameEvent.GameEvent_BattleHPChange, {isEnemy = self._IsEnemy, hpChange = changeValue})
    end
end

function CharacterPVP:GetCurrentHP()
    return self._CurrentHP
end

return CharacterPVP