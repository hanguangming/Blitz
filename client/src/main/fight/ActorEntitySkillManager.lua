----
-- 文件名称：ActorSkillEntityManager.lua
-- 功能描述：角色技能 显示相关   管理器
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-11-10
local TableDataManager =  GameGlobal:GetDataTableManager()
local SkillAttackTable = TableDataManager:GetSkillAttackDataManager()
local SkillDataManager = TableDataManager:GetSkillDataManager()
local ActorSkillEntity = require("main.fight.ActorSkillEntity")
local pairs = pairs
local clone = clone
local GetSkillCSBNameByTableData = GetSkillCSBNameByTableData

SkillType = 
{
    --投掷类技能：如弓箭，炮弹等,老的形式将去掉
    SkillType_Throw = 0,
    --简单的普攻
    SkillType_Attack = 1,
    --手动放置类(武将技)
    SkillType_ManualPut = 2,print(...)
}

--运动轨迹
SkillPathType =
{
    --直线
    SkillPathType_Line = 1,
    --抛物线
    SkillPathType_Bezier = 2,
}
    
local ActorSkillEntityManager = 
{
    --列表
    _EntityList,
    --当前ID
    _CurrentID,
}

--清理
function ActorSkillEntityManager:Clear()
    self._CurrentID = 0
    self._EntityList = {}
end

--初始化
function ActorSkillEntityManager:Init()
    self._CurrentID = 0
end

--销毁
function ActorSkillEntityManager:Destroy()
    for k, v in pairs(self._EntityList) do
        v:Destroy()
    end
    self._EntityList = nil
    self._CurrentID = 0
end

--Get
function ActorSkillEntityManager:GetEntity(guid)
    return self._EntityList[guid]
end

--创建普攻的表现
function ActorSkillEntityManager:CreateAttackEntity(tableID, senderX, senderY, targetX, targetY)
    --print("ActorSkillEntityManager:CreateAttackEntity ", tableID, senderX, senderY, targetX, targetY)
    local skillData = SkillDataManager[tableID]
    if skillData == nil then
        print("ActorSkillEntityManager:CreateEntity skillData == nil", tableID)
        return        
    end
    local csbFileName = GetSkillCSBNameByTableData(skillData, false)
    if csbFileName == nil or csbFileName == "" then
        return
    end
    local skillType = SkillType.SkillType_Attack
    self._CurrentID = self._CurrentID + 1

    local currentID = self._CurrentID
    local newEntity = clone(ActorSkillEntity)
    newEntity:Clear()
    newEntity:Init(currentID, tableID, csbFileName, skillType)
    self._EntityList[currentID] = newEntity
    
    --添加到当前关卡节点
    if gGameLevel ~= nil then
        local levelEntity = GameGlobal:GetGameLevel()._GameLevelEntity
        local curNode = newEntity:GetSkillRootNode()
        if levelEntity ~= nil then
            levelEntity:AddSkillNode(curNode)
        else
            GameGlobal:GetGameLevel():AddSkillNode(curNode)
        end
    end 
    
    --初始化参数
    local skillAttackParam = SkillAttackTable[tableID]
    if skillAttackParam ~= nil then
        newEntity:InitSkillMoveAnim(senderX, senderY, targetX, targetY, skillAttackParam._Path, skillAttackParam._OffsetX, skillAttackParam._OffsetY, skillAttackParam._MoveSpeed, skillAttackParam._MiddleFactor, skillAttackParam._EndAnimCSBName)
    end
    return newEntity
end
--创建武将技能

--删除
function ActorSkillEntityManager:DestroyEntity(guid)
    local currentEntity = self._EntityList[guid]
    if currentEntity ~= nil then
        currentEntity:Destroy()
        self._EntityList[guid] = nil
    end
end

--删除全部
function ActorSkillEntityManager:DestroyAllEntity()
    for k, v in pairs(self._EntityList) do
        v:Destroy()
    end
    self._EntityList = {}
end

--Update
function  ActorSkillEntityManager:Update()
    for k, v in pairs(self._EntityList) do
        v:Update()
        if v:IsFinished() then
            if v:IsMoveEndAnimFinish() then
                v:Destroy()
                self._EntityList[k] = nil
            end
        end
    end
end

ActorSkillEntityManager:Clear()
return ActorSkillEntityManager