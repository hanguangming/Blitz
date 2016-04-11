----
-- 文件名称：SkillManager.lua
-- 功能描述：技能管理器 : 负责技能的创建与销毁
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-4-27
--  修改：

local SkillManager = class("SkillManager")
local Skill = nil 
--构造
function SkillManager:ctor()
    --技能唯一标识
    self._CurrentSkillID = 0
    --技能table
    self._SkillTable = 0
    --测试计数 
    self._CurrentTestCount = 0
end

--创建技能
function SkillManager:CreateSkill(skillTableID, senderID, targetID, isLeaderSkill, skillHurtFactor)
    if Skill == nil then
        Skill = require("main.Logic.Skill")
    end
    if self._SkillTable == 0 then
        self._SkillTable = {}
    end 
    local newSkill = Skill.new(skillTableID, senderID, targetID, isLeaderSkill, skillHurtFactor)
    self._CurrentSkillID = self._CurrentSkillID + 1
    newSkill:SetClientID(self._CurrentSkillID)
    self._SkillTable[self._CurrentSkillID] = newSkill
    self._CurrentTestCount = self._CurrentTestCount + 1
    return newSkill
end

--销毁
function SkillManager:DestroySkill(skillTableID)
    if self._SkillTable[skillTableID] ~= nil then
        self._SkillTable[skillTableID]:Destroy()
        self._SkillTable[skillTableID] = nil
        self._CurrentTestCount = self._CurrentTestCount - 1
    end
end
--编辑器需要调用的接口，逻辑中不需要调用 
function SkillManager:GetSkillEditorSkill()
    if self._CurrentSkillID ~= nil then
        return self._SkillTable[self._CurrentSkillID]
    end
end
--获取技能
function SkillManager:GetSkill(skillGUID)
    return self._SkillTable[skillGUID]
end

--TODO:删除所有技能
function SkillManager:DestroyAllSkill()
    if self._SkillTable == 0 then
        return
    end
    for k, v in pairs(self._SkillTable)do
        v:Destroy()
        self._CurrentTestCount = self._CurrentTestCount - 1
    end
    self._SkillTable = {}
    self._CurrentSkillID = 0
end

--帧更新
function SkillManager:Update(deltaTime)
    if self._SkillTable == 0 then
        return
    end
    for k, v in pairs(self._SkillTable)do
        v:Update(deltaTime)
        if v:IsFinished() == true then
            v:Destroy()
            self._CurrentTestCount = self._CurrentTestCount - 1
            self._SkillTable[k] = nil
        end
    end
end

local newSkillManager = SkillManager.new()
return  newSkillManager