----
-- 文件名称：ItemDataManager.lua
-- 功能描述：各兵种武将的信息
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-6-13
--  修改：
-- 物品的管理类
-- 
local ItemDataManager = class("ItemDataManager")
local ItemData = class("ItemData")

-- 数据结构定义
function ItemData:ctor(tableID)
    -- tableID excel中的表格ID
    self._ItemTableID = tableID
    self._ItemTableData = 0
    
    
    -- 来自服务器数据
    -- 物品服务器标识
    self._ItemServerID = 0
    -- 当前数量
    self._CurrentItemCount = 0
    self._ItemEquipLevel = 0
    self._ItemProperty = {{0,0},{0,0},{0,0},{0,0}}
    --....
    self._EquipHp = 0
    self._EquipAtk = 0
    self._EquipSpeed = 0
    self._ItemList = {}
    self._GiftList = {}
    self._OtherList = {}
end

function ItemData:setData() 
    local PropDataManager = GameGlobal:GetDataTableManager():GetPropDataManager()
    self._PropData = PropDataManager[self._ItemTableID]
    if self._PropData["subtype"] >= 2 and self._PropData["subtype"] <= 9 then
        if self._ItemEquipLevel == 0 then
            self._ItemEquipLevel = 1
        end
        if GameGlobal:GetEquipDataManager()[self._ItemTableID] ~= nil then
            self._EquipHp = GameGlobal:GetEquipDataManager()[self._ItemTableID][self._ItemEquipLevel].hp
            self._EquipAtk = GameGlobal:GetEquipDataManager()[self._ItemTableID][self._ItemEquipLevel].ap
            self._EquipSpeed = GameGlobal:GetEquipDataManager()[self._ItemTableID][self._ItemEquipLevel].as
        end
    end
end

function ItemDataManager:ctor()
    -- 所有物品的数据 key:serverID
    self._AllItemTable = {}
    self._ItemCount = 0
end

-- 创建物品
function ItemDataManager:CreateItem(serverID)
    local newItem = ItemData.new(serverID)
    newItem._ItemServerID = serverID
    self._AllItemTable[serverID] = newItem
    return newItem
end

-- 删除物品
function ItemDataManager:DeleteItem(serverID)
    self._AllItemTable[serverID] = nil
end

-- 获取某物品
function ItemDataManager:GetItem(serverID)
   return  self._AllItemTable[serverID]
end

function ItemDataManager:GetItemCount(tableID)
    local num = 0
    for i, v in pairs(self._AllItemTable) do
         if v._ItemTableID == tableID then
            num = num + v._CurrentItemCount
         end
    end
    return num
end

function ItemDataManager:GetEquipCount(tableID)
    local count = 0
    for i, v in pairs(self._AllItemTable) do
        if v._ItemTableID == tableID and v._ItemTableData == 0 then
            count = count + 1
        end
    end
    return count
end

function ItemDataManager:GetEquipListByLevel(guid, tableID)
    local equip = {}
    for i, v in pairs(self._AllItemTable) do
        if v._ItemTableID == tableID and guid ~= v._ItemServerID and v._ItemTableData == 0 then
            table.insert(equip, v)
        end
    end
    
    table.sort(equip, function (a, b)
        return a._ItemEquipLevel < b._ItemEquipLevel
    end)
    local ids = {}
    for i, v in pairs(equip) do
        table.insert(ids, v._ItemServerID)
    end
    return ids
end

function ItemDataManager:GetStoreItem()
    return self._ItemList
end

function ItemDataManager:GetStoreGift()
    return self._GiftList
end

function ItemDataManager:GetStoreOther()
    return self._OtherList
end

function ItemDataManager:GetStoreListByType(type)
    local count = #GameGlobal:GetShopDataManager()
    local shopItemList = {}
    local tick = 1 
    for i = 1, count do
        if tonumber(GameGlobal:GetShopDataManager()[i].type1) == type then
            shopItemList[tick] = GameGlobal:GetShopDataManager()[i]
            tick = tick + 1
        end
    end
    return shopItemList
end

function ItemDataManager:GetItemPrice(type)
    local count = #GameGlobal:GetShopDataManager()
    for i = 1, count do
        if tonumber(GameGlobal:GetShopDataManager()[i].id2) == type then
            return GameGlobal:GetShopDataManager()[i].price1
        end
    end
end

local newItemDataManager = ItemDataManager:new()

return newItemDataManager