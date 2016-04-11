----
-- 文件名称：SkillBuff.lua
-- 功能描述：技能Buff 
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-7-7
--  修改：
--
local SkillBuff = class("SkillBuff")
local SkillBuffTableDataManager = GameGlobal:GetSkillBuffTableDataManager()
local SkillManager = nil
local CharacterManager = nil
local SkillBuffManager = nil
--表格中属性类型
local BuffAttributeType = 
{
    --生命
   BuffAttributeType_HP = 1,
   --攻击
   BuffAttributeType_Attack = 2,
    --攻速
   BuffAttributeType_AttackSpeed = 4,
   --攻距
   BuffAttributeType_AttackDistance = 5,
   --速度
   BuffAttributeType_MoveSpeed = 6,
}
local ValueType = 
{
    --1 绝对值
    ValueType_Absolute = 1,
    --2 百分比
    ValueType_Percent = 2,
}
--tableID:表格ID　senderID:发射者ID skillID:技能 client ID
function SkillBuff:ctor(tableID, senderID, skillID, skillInstance)
    --Buff表格ID
    self._BuffTableID = tableID
    --技能ID
    self._SkillID = skillID
    --GUID
    self._ClientGUID = 0
    --Buff Data
    print(tableID)
    self._BuffTableData = SkillBuffTableDataManager[tableID]
    --CSB 文件
    self._CSBFileName = ""
    --Buff表现节点
    self._BuffNode = nil
    --当前持续时间
    self._CurrentTime = 0
    --当前作用目标clientID
    self._CurrentTargetID = 0
    --是否结束
    self._IsFinished = false
    --持续时间
    self._ContinueTime = 0
    --当前持续时间
    self._CurrentContinueTime = 0
    --当前间隔时间
    self._CurrentInterval = 0
    --间隔时间
    self._IntervalTime = 0
    --修改的属性类型()
    self._AttributeType = 0
    --属性值类型
    self._ValueType = 0
    --属性值
    self._AttributeValue = 0
    --当前作用次数
    self._CurrentCount = 0
    --作用目标列表
    self._TargetIDList = nil
    
    self:Init(skillInstance)
end

--初始化
function SkillBuff:Init(skillInstance)
    
    if SkillManager == nil then
        SkillManager = require("main.Logic.SkillManager")
    end
    if CharacterManager == nil then
        CharacterManager = require("main.Logic.CharacterManager")
    end
    if SkillBuffManager == nil then
        SkillBuffManager = require("main.Logic.SkillBuffManager")
    end 
    local csbFileName = ""
    if self._BuffTableData ~= nil then
        csbFileName = self._BuffTableData.csbResName
        self._CSBFileName = csbFileName
    end
--    self._ContinueTime = self._BuffTableData.alltime
--    self._IntervalTime = self._BuffTableData.oncetime
--    self._AttributeType = self._BuffTableData.propertyType
--    
--    self._ValueType = self._BuffTableData.valtype
--    self._AttributeValue = self._BuffTableData.val
    --初始间隔时间
    self._CurrentContinueTime = 0
    self._CurrentCount = 0
    --一开始立即起作用
    self._CurrentInterval = self._IntervalTime
    local currentSkill = SkillManager:GetSkill(self._SkillID)
    self._TargetIDList = {}
    if currentSkill == nil then
        currentSkill = skillInstance
    end
    if currentSkill ~= nil then
        currentSkill:SelectBuffTargetList(self._TargetIDList)
    end
end

--销毁
function SkillBuff:Destroy()
     self._TargetIDList = nil
end

--是否完成
function SkillBuff:IsFinished()
    return self._IsFinished
end

--从目标列表移除
function SkillBuff:RemoveTargetFromList(characterClientID)
     for k, v in pairs(self._TargetIDList)do
        if characterClientID == v then
            self._TargetIDList[k] = nil
            break
        end
     end
end
--设置 ClientID
function SkillBuff:SetClientID(clientID)
    self._ClientGUID = clientID
end
--保存角色当前的属性
function SkillBuff:SaveCharacterProperty(currentCharacter)
    if self._AttributeType == BuffAttributeType.BuffAttributeType_HP then

    elseif self._AttributeType == BuffAttributeType.BuffAttributeType_Attack then
        currentCharacter:SaveAttackBuff()
    elseif self._AttributeType == BuffAttributeType.BuffAttributeType_AttackSpeed then
        currentCharacter:SaveBuffAttackSpeed()
    elseif self._AttributeType == BuffAttributeType.BuffAttributeType_MoveSpeed then
        currentCharacter:SaveBuffMoveSpeed()
    elseif self._AttributeType == BuffAttributeType.BuffAttributeType_AttackDistance then
        currentCharacter:SaveAttackDistanceBuff()
    end
end
--还原角色的属性
function SkillBuff:RestoreCharacterProperty(currentCharacter)
    if self._AttributeType == BuffAttributeType.BuffAttributeType_HP then

    elseif self._AttributeType == BuffAttributeType.BuffAttributeType_Attack then
        currentCharacter:RestoreAttack()
    elseif self._AttributeType == BuffAttributeType.BuffAttributeType_AttackSpeed then
        currentCharacter:RestoreBuffAttackSpeed()
    elseif self._AttributeType == BuffAttributeType.BuffAttributeType_MoveSpeed then
        currentCharacter:RestoreBuffMoveSpeed()
    elseif self._AttributeType == BuffAttributeType.BuffAttributeType_AttackDistance then
        currentCharacter:RestoreAttackDistance()
    end
end
--设置Buff的属性效果
function SkillBuff:ApplyBuffProperty(currentCharacter)
    local addValue = 0
    if self._ValueType == ValueType.ValueType_Absolute then
        addValue = self._AttributeValue
        if self._AttributeType == BuffAttributeType.BuffAttributeType_HP then
            local currentHP =  currentCharacter._CurrentHP
            currentHP = currentHP + addValue
            currentCharacter:SetCurrentHP(currentHP)
        elseif self._AttributeType == BuffAttributeType.BuffAttributeType_Attack then
            local currentAttack = currentCharacter._Attack
            currentAttack = currentAttack + addValue
            currentCharacter._Attack = currentAttack
        elseif self._AttributeType == BuffAttributeType.BuffAttributeType_AttackSpeed then
            local attackSpeed = currentCharacter._AttackSpeed
            attackSpeed = attackSpeed + addValue
            currentCharacter._AttackSpeed = attackSpeed
        elseif self._AttributeType == BuffAttributeType.BuffAttributeType_MoveSpeed then
            local moveSpeed = currentCharacter._MoveSpeed
            moveSpeed = moveSpeed + addValue
            currentCharacter._MoveSpeed = moveSpeed
        elseif self._AttributeType == BuffAttributeType.BuffAttributeType_AttackDistance then
            local attackDistance = currentCharacter._MaxAttackDistance
            attackDistance = attackDistance + addValue
            currentCharacter._MaxAttackDistance = attackDistance
        end
    elseif self._ValueType == ValueType.ValueType_Percent then
        addValue = self._AttributeValue   
        
        if self._AttributeType == BuffAttributeType.BuffAttributeType_HP then
            local currentHP =  currentCharacter._CurrentHP
            addValue = currentHP * (addValue / 100)
            currentHP = currentHP + addValue
            currentCharacter:SetCurrentHP(currentHP)
        elseif self._AttributeType == BuffAttributeType.BuffAttributeType_Attack then
            local currentAttack = currentCharacter._Attack
            addValue = currentAttack * (addValue / 100)
            currentAttack = currentAttack + addValue
            currentCharacter._Attack = currentAttack
        elseif self._AttributeType == BuffAttributeType.BuffAttributeType_AttackSpeed then
            local attackSpeed = currentCharacter._AttackSpeed
            addValue = attackSpeed * (addValue / 100)
            attackSpeed = attackSpeed + addValue
            currentCharacter._AttackSpeed = attackSpeed
        elseif self._AttributeType == BuffAttributeType.BuffAttributeType_MoveSpeed then
            local moveSpeed = currentCharacter._MoveSpeed
            addValue = moveSpeed * (addValue / 100)
            moveSpeed = moveSpeed + addValue
            currentCharacter._MoveSpeed = moveSpeed
        elseif self._AttributeType == BuffAttributeType.BuffAttributeType_AttackDistance then
            local attackDistance = currentCharacter._MaxAttackDistance
            addValue = attackDistance * (addValue / 100)
            attackDistance = attackDistance + addValue
            currentCharacter._MaxAttackDistance = attackDistance
        end
    end
end
--更新
function SkillBuff:Update(deltaTime)
    if self._IsFinished == true then
        return
    end
    self._CurrentContinueTime = self._CurrentContinueTime + deltaTime
    --持续时间到，结束
    if self._CurrentContinueTime > self._ContinueTime then
        self._IsFinished = true
        --还原作用目标的属性值
         for k, v in pairs(self._TargetIDList)do
            local currentCharacter = CharacterManager:GetCharacterByClientID(v)
            if currentCharacter ~= nil then
                currentCharacter:RemoveBuff(self._AttributeType)
                self:RestoreCharacterProperty(currentCharacter)
            end
         end
        return
    end
    self._CurrentInterval = self._CurrentInterval + deltaTime
    --间隔时间到，作用一次
    if self._CurrentInterval > self._IntervalTime then
        self._CurrentInterval = 0
        self._CurrentCount = self._CurrentCount + 1
        if self._TargetIDList ~= nil and self._TargetIDList ~= 0 then
            --第一次起作用时,保存currentCharacter Buff之前的属性值
            if self._CurrentCount == 1 then
                --校正目标列表(如果有相同属性的Buff在玩家身上，替换成当前的，目前定的Buff效果不叠加)
                for k, v in pairs(self._TargetIDList)do
                    local currentCharacter = CharacterManager:GetCharacterByClientID(v)
                    if  currentCharacter ~= nil then
                        local currentBuffInfo = currentCharacter:GetBuffByProperty(self._AttributeType)
                        if currentBuffInfo ~= nil then
                            local currentBuff = SkillBuffManager:GetSkillBuffByClientID(currentBuffInfo._BuffClientID) 
                            if currentBuff ~= nil then
                                currentBuff:RemoveTargetFromList(v)
                                currentBuff:RestoreCharacterProperty(currentCharacter)
                            end
                            --移除角色身上的Buff
                            currentCharacter:RemoveBuff(self._AttributeType)
                        end
                        currentCharacter:AddBuff(self._AttributeType, self)
                    end          
                end
                --保存角色原属性
                for k, v in pairs(self._TargetIDList)do
                    local currentCharacter = CharacterManager:GetCharacterByClientID(v)
                    if currentCharacter ~= nil then
                        self:SaveCharacterProperty(currentCharacter)
                    end
                end
            end
            
            --操作作用目标的属性
           for k, v in pairs(self._TargetIDList)do
                 local currentCharacter = CharacterManager:GetCharacterByClientID(v)
                 if currentCharacter ~= nil then
                     self:ApplyBuffProperty(currentCharacter)
                 end
           end 
       end
    end
end


return SkillBuff