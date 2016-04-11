----
-- 文件名称：SkillBuffPVPManager.lua
-- 功能描述：技能Buff 
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-10-13
--  修改：
local SkillBuff = require("main.Logic.SkillBuffPVP")
local SkillBuffPVPManager = class("SkillBuffPVPManager")

--构造
function SkillBuffPVPManager:ctor(currentLevel)
    --当前Level
    self._CurrentLevel = currentLevel
    --当前Buff ID
    self._CurrentBuffID = 0
    --当前Buff Table
    self._AllBuffTable = 0
    self:Init()
end

--初始化
function SkillBuffPVPManager:Init()
    if self._AllBuffTable == 0 then
        self._AllBuffTable = {}
    end
end

--创建Buff
function SkillBuffPVPManager:CreateBuff(tableID, senderID, skillID, skillInstance)
    local newBuff = SkillBuff.new(tableID, senderID, skillID, skillInstance, self._CurrentLevel)
    if newBuff ~= nil then
        self._CurrentBuffID = self._CurrentBuffID + 1
        self._AllBuffTable[self._CurrentBuffID] = newBuff
        newBuff:SetClientID(self._CurrentBuffID)
    end
end

--销毁Buff
function SkillBuffPVPManager:DestroyBuff(buffClientID)
    if self._AllBuffTable[buffClientID] ~= nil then
        self._AllBuffTable[buffClientID]:Destroy()
        self._AllBuffTable[buffClientID] = nil
    end
    self._CurrentBuffID = 0
end
--获取
function SkillBuffPVPManager:GetSkillBuffByClientID(clientID)
    return  self._AllBuffTable[clientID]
end
--销毁所有Buff
function SkillBuffPVPManager:DestroyAllBuff()
    for k, v in pairs(self._AllBuffTable)do
        if v ~= nil then
            v:Destroy()
        end
    end
    self._AllBuffTable = {}
end

--帧更新
function SkillBuffPVPManager:Update(deltaTime)
    for k, v in pairs( self._AllBuffTable)do
        if v ~= nil then
            if v:IsFinished() == true then
                v:Destroy()
                self._AllBuffTable[k] = nil
            else
                v:Update(deltaTime)
            end
        end
    end
end
local newSkillBuffPVPManager = SkillBuffPVPManager.new()
return newSkillBuffPVPManager