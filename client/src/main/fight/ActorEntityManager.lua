----
-- 文件名称：ActorEntityManager.lua
-- 功能描述：角色   显示相关管理器
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-11-10

local ActorEntity = require("main.fight.ActorEntity")
local ActorEntitySkillManager = require("main.fight.ActorEntitySkillManager")
local ActorEntityManager = 
{
    --列表
    _EntityList = {},
    --当前ID
    _CurrentID = 0,
}

--清理
function ActorEntityManager:Clear()
    self._CurrentID = 0
    self._EntityList = {}
    cc.SpriteFrameCache:getInstance():addSpriteFrames("meishu/ui/zhandou/UI_zd_wenzi.plist")
end

--初始化
function ActorEntityManager:Init()
    self._CurrentID = 0
end

--销毁
function ActorEntityManager:Destroy()
    for k, v in pairs(self._EntityList) do
        v:Destroy()
    end
    self._EntityList = nil
end

--Get
function ActorEntityManager:GetEntity(guid)
    return self._EntityList[guid]
end

function ActorEntityManager:SetEntityBuff(unit, buff)
--    self._EntityList[unit_id(unit)]._BuffIcon = buff
--    local BuffManager = GameGlobal:GetSkillBuffTableDataManager()
--    for id, v in pairs(buff) do
--        BuffManager[id].attackeffect
--        if  BuffManager[id].property == 2 then
--            set_value_3(unit, get_value_3(unit) * (1 + BuffManager[id].val / 100))    
--        elseif  BuffManager[id].property == 2 then
--        end       
--    end
end 

function ActorEntityManager:UpdateEntity(unit, state, target, x, y, ispve)
    local currentEntity = self._EntityList[unit_id(unit)]
    if currentEntity == nil then
        return
    end
    currentEntity:SetState(state, target, x, y)
    currentEntity:SetDirectonX(unit_dir(unit))
    if state == 3 and not ispve then
        self._EntityList[unit_id(target)]:SetHPProgressBarVisible(true)
        self._EntityList[unit_id(target)]:SetHPProgressBarPercent(get_value_2(target) / self._EntityList[unit_id(target)]._maxHP * 100)
    end
   
    currentEntity:SetHPProgressBarPercent(get_value_2(unit) / currentEntity._maxHP * 100)  
    currentEntity:Update()
    currentEntity:SetPosition(x, y)
    ActorEntitySkillManager:Update()
end

function ActorEntityManager:UpdateEntityState(unit, state)
    local currentEntity = self._EntityList[unit_id(unit)]
    if currentEntity == nil then
        return
    end
    currentEntity:SetState(state, target, x, y)
end

function ActorEntityManager:Update()
    for i , v in pairs(self._EntityList) do
        if v == nil then
            return
        end
        v:Update()
   end
    ActorEntitySkillManager:Update()
end

--创建(使用外部传递的guid) offsetX, offsetY:战斗区域偏移
function ActorEntityManager:CreateEntity(unit, tableID, isAttacker, offsetX, offsetY)
    local currentID = unit_id(unit)
    local newEntity = clone(ActorEntity)
    newEntity:Clear()
    newEntity._unit = unit
    newEntity._maxHP =  get_value_9(unit)
    newEntity:Init(currentID, tableID, isAttacker, offsetX, offsetY)
    self._EntityList[currentID] = newEntity
    return newEntity
end

--删除
function ActorEntityManager:DestroyEntity(guid)
    local currentEntity = self._EntityList[guid]
    if currentEntity ~= nil then
        currentEntity:Destroy()
        unit_destroy(currentEntity._unit)
        self._EntityList[guid] = nil
    end
end

function ActorEntityManager:DestroyDeathEntity()
    for k, v in pairs(self._EntityList) do
        if v._CurrentState == 6 or v._CurrentState == 7 then
            v:Destroy()
            unit_destroy(v._unit)
            self._EntityList[k] = nil
        end
    end
end

--删除全部
function ActorEntityManager:DestroyAllEntity()
    for k, v in pairs(self._EntityList) do
        v:Destroy()
        unit_destroy(v._unit)
        self._EntityList[k] = nil
    end
end
ActorEntityManager:Clear()
return ActorEntityManager