----
-- 文件名称：SkillPVP.lua
-- 功能描述：战斗技能(仅适用于PVP的修改版本)
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-9-29
--  修改：基于Skill


 SkillType = 
    {
        --投掷类技能：如弓箭，炮弹等,老的形式将去掉
        SkillType_Throw = 0,
        --简单的普攻
        SkillType_Attack = 1,
        --手动放置类(武将技)
        SkillType_ManualPut = 2,
    }
    
--运动轨迹
 SkillPathType =
    {
        --直线
        SkillPathType_Line = 1,
        --抛物线
        SkillPathType_Bezier = 2,
    }

local SkillPVPEntity = require("main.Logic.SkillPVPEntity")

local mathAbs = math.abs
local TableDataManager = GameGlobal:GetDataTableManager()
local SkillDataManager = TableDataManager:GetSkillDataManager()
local SoldierRelationDataManager = TableDataManager:GetSoldierRelationDataManager()
local SkillTipDataManager = TableDataManager:GetSkillPosDataManager()
local mathCeil = math.ceil
local mathSqrt = math.sqrt
local mathCos = math.cos
local mathSin = math.sin
local stringFind = string.find
local stringSub = string.sub
local Skill = class("Skill")
local hurt = 20 * gHurtFactor

local SkillPVP = class("SkillPVP")

--构造
function SkillPVP:ctor(skillTableID, senderID, targetID, isLeaderSkill, skillHurtFactor,isNeedShow, currentLevel)
    --print("skillTableID ", skillTableID)
    --当前Level
    self._CurrentLevel = currentLevel
    --
    self._CharacterManager = self._CurrentLevel:GetCharacterPVPManager()
    --
    self._SkillBuffManager = self._CurrentLevel:GetSkillBuffPVPManager()
    --表格数据
    self._SkillTableData = SkillDataManager[skillTableID]
    --技能表格ID
    self._SkillTableID = skillTableID
    --施放者ID
    self._SenderID = senderID
    --目标ID
    self._TargetID = targetID
    --施术者TableID
    self._SenderTableID = 0
    --目标TableID
    self._TargetTableID = 0
    --技能形状类型
    self._SkillShapeType = -1
    --技能唯一标识
    self._ClientGUID = 0
    --当前持续时间
    self._CurrentTrigerTime = 0
    --触发伤害的时间
    self._TrigerTime = 0 --self._SkillTableData.trigerTime
    self._AnimLengthHalf = 0
    --触发总次数
    self._TrigerTotalCount = 1
    --当前触发次数
    self._CurrentTrigerCount = 0
    --触发时间
    self._SenderIsEnemy = false
    --技能类型
    if isLeaderSkill == nil or isLeaderSkill == false then
        self._SkillType = SkillType.SkillType_Attack
    else
        self._SkillType = SkillType.SkillType_ManualPut
    end
    --初始技能位置
    self._InitPositionX = 0
    self._InitPositionY = 0
    --施法者的攻 击力
    self._SenderAttack = 0
    --作用范围类型
    self._ZoneType = 0
    --子弹飞行速度
    self._BulletMoveSpeed = 0
    --子弹路径类型(1:直线  2：抛物线)
    self._BulletPathType = 2
    --子弹 中间点系数
    self._MiddleFactor = 1
    --攻击动画时长,多长时间后触发伤害
    self._AttackAnimLength = 0
    --初始偏移X
    self._InitOffsetX = 0
    --初始偏移Y
    self._InitOffsetY = 0
    --结束动画
    self._ThrowSkillFinishAnimCSBName = 0
    --轨迹运动的目标位置
    self._MoveEndDestPosition = nil
    --是否结束
    self._IsFinished = false
    --群攻技能的作用范围 
    self._ZoneX = 0
    self._ZoneY = 0
    --buff list
    self._BuffIDList = 0
    --是否已创建Buff
    self._IsCreateBuff = false
    --技能伤害系数
    if isLeaderSkill == true then
        self._SkillHurtFactor = 1
    end
    --当前震屏次数
    self._CurrentShakeCount = 0
    self._ShakeCount = 2
    self._IsShake = false    
    self._SkillPVPEntity = nil
    if isNeedShow == nil then
        isNeedShow = false
    end
    if isNeedShow == true then
        self._SkillPVPEntity = SkillPVPEntity:new()
    end
    self:Init()
end

--初始化
function SkillPVP:Init()
    self._SkillShapeType = self._SkillTableData.shapeType
    --BuffID List
    local currentString = self._SkillTableData.bufflist
    self._BuffIDList = {}
    if currentString ~= nil and currentString ~= "0" and currentString ~= "" then
        local tagPosStart = stringFind(currentString,"%(")
        local tagPosEnd = stringFind(currentString,"%)")
        local info = stringSub(currentString, tagPosStart + 1, tagPosEnd - 1)
        local idStrList = Split(info, ",")
        if idStrList ~= nil then
            for k, v in pairs(idStrList)do
                self._BuffIDList[k] = tonumber(v) 
            end
        end
    end
    --初始化 csb 
    self._SkillEffectCSBFileName = GetSkillCSBName(self)
    if self._SkillType == SkillType.SkillType_ManualPut  then
        --武将技时如果表格中未配置csb,程序赋一默认值
        if self._SkillEffectCSBFileName == "" or self._SkillEffectCSBFileName == "0" then
            self._SkillEffectCSBFileName = "csb/texiao/jineng/22001.csb"
        end
    end

    local sendCharacter = self._CharacterManager:GetCharacterByClientID(self._SenderID) 
    local targetCharacter = self._CharacterManager:GetCharacterByClientID(self._TargetID)
    if sendCharacter ~= nil then
        self._SenderAttack = sendCharacter._Attack
        self._InitPositionX = sendCharacter._CharacterPositionX
        self._InitPositionY = sendCharacter._CharacterPositionY
        self._SenderIsEnemy = sendCharacter._IsEnemy
        self._SenderTableID = sendCharacter._CharacterTableID
    end
    if targetCharacter ~= nil then
        self._TargetTableID = targetCharacter._CharacterTableID
    end

    --初始化攻击参数：
    self._ZoneX = 20
    self._ZoneY = 20
    self._ZoneType = self._SkillTableData.zoneType
    local posData = SkillTipDataManager[self._ZoneType]
    if posData ~= nil then
        self._ZoneX = posData.x * SIZE_ONE_TILE
        self._ZoneY = posData.y * SIZE_ONE_TILE
    else
        printError("config skillpos.txt error invalid type skillTableID: %d", self._SkillTableID)
    end

    local skillAttackTable = TableDataManager:GetSkillAttackDataManager()
    local skillAttackParam = skillAttackTable[self._SkillTableID]
    if skillAttackParam ~= nil then
        self._BulletMoveSpeed = skillAttackParam._MoveSpeed
        self._BulletPathType = skillAttackParam._Path
        self._MiddleFactor = skillAttackParam._MiddleFactor
        self._AttackAnimLength = skillAttackParam._HurtHitTime
        self._InitOffsetX = skillAttackParam._OffsetX
        self._InitOffsetY = skillAttackParam._OffsetY
        self._ThrowSkillFinishAnimCSBName = skillAttackParam._EndAnimCSBName
    end
    if sendCharacter ~= nil then
        if self._AttackAnimLength ~= nil then
            self._AttackAnimLength = self._AttackAnimLength * (1 / sendCharacter:GetAttackAnimSpeed())
        end
    end
    --伤害触发时机,武将技，近战普攻强制改为0
    if self._SkillType == SkillType.SkillType_ManualPut then
        self._AttackAnimLength = 0
    elseif self._SkillType == SkillType.SkillType_Attack then
        if self._SkillEffectCSBFileName == "" or self._SkillEffectCSBFileName == "0" then
            self._AttackAnimLength = 0
        end 
    end
    -- 
    if self._SkillPVPEntity ~= nil then
        self._SkillPVPEntity:Init(self._SkillEffectCSBFileName, self._SkillType)
    end 
end

--销毁
function SkillPVP:Destroy()
    --print("SkillPVP:Destroy", self._ClientGUID)
    --LogSystem:WriteLog("ID:%d SkillPVP:Destroy", self._ClientGUID)
    self._SkillTableData = nil
    self._MoveEndDestPosition = nil
    self._BuffIDList = nil
    
    if self._SkillPVPEntity ~= nil then
        self._SkillPVPEntity:Destroy()
        self._SkillPVPEntity = nil
    end
end

--
function SkillPVP:GetSoldierRelation(sendCharacter, targetCharacter)
    local soldierRelationFactor = 1
    local selfType = 0
    local destType = 0
    if sendCharacter ~= nil then
        selfType = sendCharacter._CharacterData.soldierType
    end
    if targetCharacter ~= nil then
        if targetCharacter._CharacterData ~= nil then
            destType = targetCharacter._CharacterData.soldierType
        end
    end
    local relationData = SoldierRelationDataManager[selfType]
    if relationData ~= nil then
        if relationData[tostring(destType)] ~= nil then
            soldierRelationFactor = relationData[tostring(destType)]
        end
    end 
    --print("soldierRelationFactor", soldierRelationFactor, selfType, destType)
    return soldierRelationFactor
end


--计算伤害
function SkillPVP:CalcHurtNumber(targetCharacter, senderID, targetID)
    --LogSystem:WriteLog("ID:%d enter CalcHurtNumber zoneType:%d (w:%d h:%d)", self._ClientGUID, self._ZoneType, self._ZoneX, self._ZoneY)
    local hurt = 0
    local totalHurt = 0
    local sendCharacter = self._CharacterManager:GetCharacterByClientID(senderID) 
    local targetCharacter = self._CharacterManager:GetCharacterByClientID(targetID)
    if self._ZoneType == AttackType.AttackType_DanTi then
        --正式的
        local soldierRelationFactor = self:GetSoldierRelation(sendCharacter, targetCharacter)
        if self._SenderAttack ~= nil then
            hurt = self._SenderAttack * gHurtFactor * soldierRelationFactor
        end
        if targetCharacter ~= nil then
            local currentHp = targetCharacter:GetCurrentHP()
            currentHp = currentHp - hurt 
            targetCharacter:SetCurrentHP(currentHp)
            --LogSystem:WriteLog("ID: %d Hurt danTi sender:%d %d(%d,%d) --> target:%d %d pos(%d,%d) hurt:%d nowHP:%d", self._ClientGUID, self._SenderTableID, senderID, self._InitPositionX, self._InitPositionY,self._TargetTableID, targetID, targetCharacter._CharacterPositionX, targetCharacter._CharacterPositionY, hurt, currentHp)
        end
        --可能计算不正错的值
        if hurt <= 5 then
            --printInfo("hurt:%d skill:%d factor:%d", hurt, self._SkillTableID, soldierRelationFactor)
        end
        return hurt
    else
        local currentLevel = self._CurrentLevel
        if currentLevel ~= nil then
            local enemyIDList = nil
            if self._SenderIsEnemy == true then
                enemyIDList = currentLevel._SelfSoldierIDList
            else
                enemyIDList = currentLevel._EnemySoldierIDList
            end
            for k, v in pairs(enemyIDList)do
                -- print("false ", v)
                local curCharacter = self._CharacterManager:GetCharacterByClientID(v)
                if curCharacter ~= nil then
                    local skillPositionX = self._InitPositionX
                    local skillPositionY = self._InitPositionY
                    --PVP不会进入SkillType_ManualPut分支
                    if self._SkillType == SkillType.SkillType_ManualPut then
                        --printError("pvp: please check that skill.txt: not should leader skill", self._SkillTableID)
                        if self._SkillRootNode ~= nil then
                            skillPositionX = self._SkillRootNode:getPositionX()
                            skillPositionY = self._SkillRootNode:getPositionY()
                        end
                    elseif self._SkillType == SkillType.SkillType_Attack then
                        --print("CalcHurtNumber _SkillEffectCSBFileName ", self._SkillEffectCSBFileName)
                        if self._SkillEffectCSBFileName ~= "" and self._SkillEffectCSBFileName ~= "0" then
                            skillPositionX = self._MoveEndDestPosition.x 
                            skillPositionY = self._MoveEndDestPosition.y 
                        end
                    end 

                    local soldierRelationFactor = self:GetSoldierRelation(sendCharacter, curCharacter)
                    if self._SenderAttack ~= nil then
                        hurt = self._SenderAttack * gHurtFactor * soldierRelationFactor
                    end
                    local posXOffset = curCharacter._CharacterPositionX - skillPositionX
                    local posYOffset = curCharacter._CharacterPositionY - skillPositionY
                    if  mathAbs(posXOffset) <= self._ZoneX / 2  and mathAbs(posYOffset) <= self._ZoneY / 2 then
                        local currentHp = curCharacter:GetCurrentHP()
                        currentHp = currentHp - hurt
                        curCharacter:SetCurrentHP(currentHp)
                        totalHurt = totalHurt + hurt
                        --LogSystem:WriteLog("ID:%d Hurt qunTi sender:%d %d pos(%d,%d) --> target:%d %d pos(%d,%d) hurt:%d nowHP: %d", self._ClientGUID, self._SenderTableID, senderID, skillPositionX, skillPositionY, curCharacter._CharacterTableID, curCharacter._ClientID, curCharacter._CharacterPositionX, curCharacter._CharacterPositionY, hurt, currentHp)
                    end
                end
            end
        end
        --printInfo("totalHurt %d", totalHurt)
        return totalHurt
    end
end

--填充作用目标(作用目标列表,根据技能作用范围，计算Buff的作用目标列表),PVP时不会进入此函数,若进入，说明技能表配置变化了
function SkillPVP:SelectBuffTargetList(targetList)
    if targetList == nil then
        return
    end
    if self._ZoneType == AttackType.AttackType_DanTi then
        targetList[1] = self._TargetID
    else
        local currentLevel = self._CurrentLevel
        local currentTargetIndex = 1
        if currentLevel ~= nil then
            local enemyIDList = nil
            if self._SenderIsEnemy == true then
                enemyIDList = currentLevel._SelfSoldierIDList
            else
                enemyIDList = currentLevel._EnemySoldierIDList
            end
            for k, v in pairs(enemyIDList)do
                -- print("false ", v)
                local curCharacter = self._CharacterManager:GetCharacterByClientID(v)
                if curCharacter ~= nil then
                    local skillPositionX = self._InitPositionX
                    local skillPositionY = self._InitPositionY
                    if self._SkillRootNode ~= nil then
                        skillPositionX = self._SkillRootNode:getPositionX()
                        skillPositionY = self._SkillRootNode:getPositionY()
                    end
                    local posXOffset = curCharacter._CharacterPositionX - skillPositionX
                    local posYOffset = curCharacter._CharacterPositionY - skillPositionY
                    if  mathAbs(posXOffset) <= self._ZoneX / 2  and mathAbs(posYOffset) <= self._ZoneY / 2 then
                        targetList[currentTargetIndex] = v
                        currentTargetIndex = currentTargetIndex + 1
                    end
                end
            end
        end
    end
end
--帧更新
function SkillPVP:Update(deltaTime)
    if self._IsFinished == true then
        return
    end
    self._CurrentTrigerTime = self._CurrentTrigerTime + deltaTime

    if self._IsCreateBuff == false then
        self._IsCreateBuff = true
        --如果 Buff不为空，加Buff
        if self._BuffIDList ~= 0 and self._BuffIDList ~= nil then
            for k, v in pairs(self._BuffIDList)do
                local newBuff = self._SkillBuffManager:CreateBuff(v, self._SenderID, self._ClientGUID, self)
            end
        end
    end

    --普攻
    if self._SkillType == SkillType.SkillType_Attack then
        ---无表现的普攻只是在特定的时间产生伤害值
        if self._SkillEffectCSBFileName == "" or self._SkillEffectCSBFileName == "0" then
            --普攻无表现的
            if self._CurrentTrigerTime >=  self._AttackAnimLength then
                local sendCharacter = self._CharacterManager:GetCharacterByClientID(self._SenderID) 
                local targetCharacter = self._CharacterManager:GetCharacterByClientID(self._TargetID)
                if sendCharacter._CharacterTableID == 500423 then
                    --print("SkillPVP 500423 will CalcHurtNumber", targetCharacter, self._TargetID, self._ClientGUID)
                end
                if targetCharacter ~= nil then
                    self:CalcHurtNumber(targetCharacter, self._SenderID, self._TargetID)
                end
                self._IsFinished = true
            end
            --有表现的普攻会投掷出弓箭,炮弹,火球等
        else
            if self._CurrentTrigerTime <  self._AttackAnimLength then
                return
            end

            --显示相关的
            if self._SkillPVPEntity ~= nil then
                --普攻有表现的             ---触发子弹发射
                local skillMoveAnim = self._SkillPVPEntity:GetSkillMoveAnim()
                if skillMoveAnim == nil then
                    local sendCharacter = self._CharacterManager:GetCharacterByClientID(self._SenderID) 
                    local targetCharacter = self._CharacterManager:GetCharacterByClientID(self._TargetID)
                    --LogSystem:WriteLog("ID:%d Show sender:%d target:%d frame:%d", self._ClientGUID, self._SenderID, self._TargetID, TEST_FRAME_COUNT)
                    if sendCharacter == nil or targetCharacter == nil then
                        self._IsFinished = true
                        return
                    end
                    if sendCharacter._IsEnemy == true then
                        print("enemy skill....")
                    end
                    local endPos = cc.p(targetCharacter._CharacterPositionX, targetCharacter._CharacterPositionY)
                    self._MoveEndDestPosition = endPos
                    self._SkillPVPEntity:InitSkillMoveAnim(sendCharacter, targetCharacter, self._BulletPathType, self._InitOffsetX, self._InitOffsetY, 
                            self._BulletMoveSpeed, self._MiddleFactor)
                    --下面为测试立即触发伤害的情况
                    if targetCharacter:GetCurrentHP() <= 0 then
                        return
                    end
                    self:CalcHurtNumber(targetCharacter, self._SenderID, self._TargetID)
                else
                    --普攻发射的弓箭炮弹等打到目标后
                    --print("if self._SkillPVPEntity:IsSkillMoveEnd()")
                    if self._SkillPVPEntity:IsSkillMoveEnd() then
                        --print("-----------------------------------------skill move end--------------------------")
                        local targetCharacter = self._CharacterManager:GetCharacterByClientID(self._TargetID)
                        --伤害计算 临时注释，移到上面了 测试伤害立即触发的情况
                        --self:CalcHurtNumber(targetCharacter, self._SenderID, self._TargetID)
                        if self._ThrowSkillFinishAnimCSBName ~= "" and self._ThrowSkillFinishAnimCSBName ~= "0" then
                            local moveEndSkillEffectAnim = self._SkillPVPEntity:GetMoveEndSkillAnim()
                            if moveEndSkillEffectAnim == nil then
                                self._SkillPVPEntity:CreateSkillMoveEndAnim(self._ThrowSkillFinishAnimCSBName)
                            end
                        else
                            self._IsFinished = true    
                        end
                    end
                end
                --移动结束后的动画特效
                local moveEndSkillEffectAnim = self._SkillPVPEntity:GetMoveEndSkillAnim()
                --print("-----------------------------------------moveEndSkillEffectAnim--------------------------", moveEndSkillEffectAnim)
                if moveEndSkillEffectAnim ~= nil then
                    if self._SkillPVPEntity:IsMoveEndAnimFinish() then
                        --print("-----------------------------------------skill move end anim end--------------------------")
                        self._IsFinished = true
                    end
                end
                self._SkillPVPEntity:UpdateOrder()
            --无显示的情况     
            else
                local sendCharacter = self._CharacterManager:GetCharacterByClientID(self._SenderID) 
                local targetCharacter = self._CharacterManager:GetCharacterByClientID(self._TargetID)
                --LogSystem:WriteLog("ID:%d noShow sender:%d target:%d frame:%d", self._ClientGUID, self._SenderID, self._TargetID, TEST_FRAME_COUNT)
                if sendCharacter == nil or targetCharacter == nil or targetCharacter:GetCurrentHP() <= 0 then
                    self._IsFinished = true
                    return
                end
                local endPos = cc.p(targetCharacter._CharacterPositionX, targetCharacter._CharacterPositionY)
                self._MoveEndDestPosition = endPos
                self:CalcHurtNumber(targetCharacter, self._SenderID, self._TargetID)
                self._IsFinished = true
            end
        end

    elseif self._SkillType == SkillType.SkillType_Throw then

    --武将技能(PVP不用处理此分支)
    elseif self._SkillType == SkillType.SkillType_ManualPut then
        
    end

end

--更新遮挡
function SkillPVP:UpdateOrder()
    if self._SkillPVPEntity == nil then
        return 
    end
    self._SkillPVPEntity:UpdateOrder()
end

------------------------------- set get------------------------------- 
-- 
function SkillPVP:SetClientID(clientID)
    self._ClientGUID = clientID
end
--
function SkillPVP:GetClientID(clientID)
    return self._ClientGUID
end
--
function SkillPVP:GetSkillRootNode()
    if self._SkillPVPEntity == nil then
        return nil
    end
    return self._SkillPVPEntity:GetSkillRootNode()
end
--
function SkillPVP:IsFinished()
    return self._IsFinished
end


return SkillPVP