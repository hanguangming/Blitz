----
-- 文件名称：GuoZhanMapPlayerManager.lua
-- 功能描述：国战地图上的玩家 管理器
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-8-13

local GuoZhanMapPlayer = require("main.Logic.GuoZhanMapPlayer")
local GuoZhanMapPlayerManager = class("GuoZhanMapPlayerManager")

function GuoZhanMapPlayerManager:ctor()
    --所有玩家列表
    self._AllPlayerTable = {}
    --主角国战ServerID
    self._SelfServerID = 0
end


--创建玩家isSelf:是否主角
function GuoZhanMapPlayerManager:CreatePlayer(serverID, tableID, isSelf)
    local newPlayer = GuoZhanMapPlayer:new()
    newPlayer:Init(serverID, tableID, isSelf)
    self._AllPlayerTable[serverID] = newPlayer
    return newPlayer
end

--删除某个玩家
function GuoZhanMapPlayerManager:DestroyPlayerByServerID(serverID)
    local currentPlayer = self._AllPlayerTable[serverID]
    if currentPlayer ~= nil then
        currentPlayer:Destroy()
    end
    self._AllPlayerTable[serverID] = nil
end

--显示所有玩家
function GuoZhanMapPlayerManager:ShowAllPlayer()
    for k, v in pairs(self._AllPlayerTable)do
        if v ~= nil then
           v:PlayWalkAnim()
        end
    end
end
--删除所有角色
function GuoZhanMapPlayerManager:DestroyAllPlayer()
    
end

--获取主角
function GuoZhanMapPlayerManager:GetSelfPlayer()
    return self._AllPlayerTable[self._SelfServerID]
end

--获取某个玩家
function GuoZhanMapPlayerManager:GetPlayerByServerID(serverID)
    return self._AllPlayerTable[serverID]
end

--Update
function GuoZhanMapPlayerManager:Update(deltaTime)
    for k, v in pairs(self._AllPlayerTable)do
        if v ~= nil then
            v:Update(deltaTime)
        end
    end
end

local newInstance = GuoZhanMapPlayerManager.new()
return newInstance

