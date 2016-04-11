----
-- 文件名称：SkillPVPManager.lua
-- 功能描述：PVP技能管理器：copy from SkillManager
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-10-13
--  修改：

local SkillPVPManager = class("SkillPVPManager")
local SkillPVP = nil 
--构造
function SkillPVPManager:ctor(currentLevel)
    --当前Level
    self._CurrentLevel = currentLevel
    --技能唯一标识
    self._CurrentSkillID = 0
    --技能table
    self._SkillTable = 0
end

--创建技能
function SkillPVPManager:CreateSkill(skillTableID, senderID, targetID, isLeaderSkill, skillHurtFactor, isNeedShow)
    if SkillPVP == nil then
        SkillPVP = require("main.Logic.SkillPVP")
    end
    if self._SkillTable == 0 then
        self._SkillTable = {}
    end 
    local newSkill = SkillPVP.new(skillTableID, senderID, targetID, isLeaderSkill, skillHurtFactor, isNeedShow, self._CurrentLevel)
    self._CurrentSkillID = self._CurrentSkillID + 1
    newSkill:SetClientID(self._CurrentSkillID)
    self._SkillTable[self._CurrentSkillID] = newSkill
    return newSkill
end

--销毁
function SkillPVPManager:DestroySkill(skillTableID)
    if self._SkillTable[skillTableID] ~= nil then
        self._SkillTable[skillTableID]:Destroy()
        self._SkillTable[skillTableID] = nil
    end
end
--编辑器需要调用的接口，逻辑中不需要调用 
function SkillPVPManager:GetSkillEditorSkill()
    if self._CurrentSkillID ~= nil then
        return self._SkillTable[self._CurrentSkillID]
    end
end
--获取技能
function SkillPVPManager:GetSkill(skillGUID)
    return self._SkillTable[skillGUID]
end

--TODO:删除所有技能
function SkillPVPManager:DestroyAllSkill()
    if self._SkillTable == 0 then
        return
    end
    for k, v in pairs(self._SkillTable)do
        v:Destroy()
    end
    self._SkillTable = {}
end

--帧更新
function SkillPVPManager:Update(deltaTime)
    if self._SkillTable == 0 then
        return
    end
    for k, v in pairs(self._SkillTable)do
        v:Update(deltaTime)
        if v:IsFinished() == true then
            v:Destroy()
            self._SkillTable[k] = nil
        end
    end
end

return  SkillPVPManager