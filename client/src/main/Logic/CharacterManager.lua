----
-- 文件名称：CharacterManager.lua
-- 功能描述：角色管理器:创建与销毁 角色，获取某个角色
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-4-24
--  修改：

local CharacterManager = class("CharacterManager")
function CharacterManager:ctor()
    --角色table  key:id value:character 所有角色（小兵 武将 建筑）
    self._Soldiers = {}
    --当前guid
    self._CurrentSoldierID = 0
    --测试计数
    self._CurrentTestCount = 0
end

--创建角色
function CharacterManager:CreateSoldier(tableID)
    self._CurrentSoldierID = self._CurrentSoldierID + 1
    local Character = require("main.Logic.Character")
    local soldier = Character.new(tableID)
    self._Soldiers[self._CurrentSoldierID] = soldier
    soldier:SetClientGUID(self._CurrentSoldierID)
    self._CurrentTestCount = self._CurrentTestCount + 1
    return soldier
end

--销毁
function CharacterManager:DestroySoldier(clientGUID)
    if self._Soldiers[clientGUID] ~= nil then
        self._Soldiers[clientGUID]:Destroy()
        self._Soldiers[clientGUID] = nil
        self._CurrentTestCount = self._CurrentTestCount - 1
    end
end

--创建特殊的building
function CharacterManager:CreateBuilding()
    self._CurrentSoldierID = self._CurrentSoldierID + 1
    local BattleBuilding = require("main.Logic.BattleBuilding")
    local newBuilding = BattleBuilding.new()
    self._Soldiers[self._CurrentSoldierID] = newBuilding
    newBuilding:SetClientGUID(self._CurrentSoldierID)
    return newBuilding
end

--销毁建筑
function CharacterManager:DestroyBulding(clientGUID)
    if self._Soldiers[clientGUID] ~= nil then
        self._Soldiers[clientGUID]:Destroy()
        self._Soldiers[clientGUID] = nil
    end
end
--Update
function CharacterManager:Update(deltaTime)
    --print("CharacterManager:Update begin")
    for k, v in pairs(self._Soldiers)do
        if v ~= nil then
            v:Update(deltaTime)
            --print("update ", v._CharacterTableID, v._IsEnemy)
        end
    end
    --print("CharacterManager:Update end")
end

--获取某个soldier
function CharacterManager:GetCharacterByClientID(guid)
    return self._Soldiers[guid]
end

--获取某个武将
function CharacterManager:GetLeaderByTableID(tableID)
    local leadGUID = nil
    for k, v in pairs(self._Soldiers)do
        --print("GetLeaderByTableID", v.characterTableID, tableID)
        if tonumber(v._CharacterTableID) == tonumber(tableID)then
            leadGUID = k
            break
        end
    end
    return leadGUID
end
--删除所有角色
function CharacterManager:DestroyAllCharacter()
    for k, v in pairs(self._Soldiers)do
        v:Destroy()
        self._CurrentTestCount = self._CurrentTestCount - 1
    end
    self._Soldiers = {} 
    self._CurrentSoldierID = 0
    print("CharacterManager:DestroyAllCharacter......")
end
local newInstance = CharacterManager.new()
return newInstance
--