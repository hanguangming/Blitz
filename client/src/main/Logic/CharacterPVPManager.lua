----
-- 文件名称：CharacterPVPManager.lua
-- 功能描述：PVP角色管理器:创建与销毁 角色，获取某个角色 copy from CharacterManager
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-10-13
--  修改：

local CharacterPVPManager = class("CharacterPVPManager")
function CharacterPVPManager:ctor(currentLevel)
    --角色table  key:id value:character 所有角色（小兵 武将 建筑）
    self._Soldiers = {}
    --当前guid
    self._CurrentSoldierID = 0
    --当前Level
    self._CurrentLevel = currentLevel
end

--创建角色
function CharacterPVPManager:CreateSoldier(tableID, isNeedShow)
    self._CurrentSoldierID = self._CurrentSoldierID + 1
    local CharacterPVP = require("main.Logic.CharacterPVP")
    local soldier = CharacterPVP.new(tableID, isNeedShow, self._CurrentLevel)
    self._Soldiers[self._CurrentSoldierID] = soldier
    soldier:SetClientGUID(self._CurrentSoldierID)
    return soldier
end

--销毁
function CharacterPVPManager:DestroySoldier(clientGUID)
    if self._Soldiers[clientGUID] ~= nil then
        self._Soldiers[clientGUID]:Destroy()
        self._Soldiers[clientGUID] = nil
    end
end

--创建特殊的building
function CharacterPVPManager:CreateBuilding()
    self._CurrentSoldierID = self._CurrentSoldierID + 1
    local BattleBuilding = require("main.Logic.BattleBuilding")
    local newBuilding = BattleBuilding.new()
    self._Soldiers[self._CurrentSoldierID] = newBuilding
    newBuilding:SetClientGUID(self._CurrentSoldierID)
    return newBuilding
end

--销毁建筑
function CharacterPVPManager:DestroyBulding(clientGUID)
    if self._Soldiers[clientGUID] ~= nil then
        self._Soldiers[clientGUID]:Destroy()
        self._Soldiers[clientGUID] = nil
    end
end
--Update
function CharacterPVPManager:Update(deltaTime)
    --print("CharacterManager:Update ----------------------------begin")
    for k, v in pairs(self._Soldiers)do
        if v ~= nil then
            v:Update(deltaTime)
            --print("update ", v._CharacterTableID, v._IsEnemy, v._ClientID)
        end
    end
    --print("CharacterManager:Update ---------------------------- end")
end

--获取某个soldier
function CharacterPVPManager:GetCharacterByClientID(guid)
    return self._Soldiers[guid]
end

--获取某个武将
function CharacterPVPManager:GetLeaderByTableID(tableID)
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
function CharacterPVPManager:DestroyAllCharacter()
    for k, v in pairs(self._Soldiers)do
        v:Destroy()
    end
    self._Soldiers = {} 
    self._CurrentSoldierID = 0
end

return CharacterPVPManager
--