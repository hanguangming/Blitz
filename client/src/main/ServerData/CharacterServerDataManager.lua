----
-- 文件名称：CharacterServerDataManager
-- 功能描述：各兵种武将的信息
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-5-4
--  修改：

-- 每一种兵的数据
local CharacterDataManager =  GetCharacterDataManager()
local SkillDataManager = GetSkillDataManager()
local CharacterServerDataManager = class("CharacterServerDataManager")
-- 士兵数据
local SoldierData = class("SoldierData")

function SoldierData:ctor(tableID)
    -- 表格ID
    self._TableID = tableID
    
    -- 表格数据
    self._CharacterData = CharacterDataManager[tableID]
    
    -- 关联技能数据
    self._CharacterSkillData1 = SkillDataManager[self._CharacterData.skill1]
    
    -- 关联技能数据2
    self._CharacterSkillData2 = SkillDataManager[tonumber(self._CharacterData.skill2)]
     
    -- 当前对应的UI索引
    self._CurrentUIIndex = 0
    
    -- 等级 
    self._Level = 0
    
    -- 经验
    self._Exp = 0
    
    -- 血量
    self._Hp = 0
    
    -- 护甲
    self._Def = 0
    
    -- 攻击距离 
    self._GongJu = 0
    
    -- 消耗
    self._Consume = 0
    
    -- 产出
    self._Output = 0
    
    self._EquipHp = 0

    -- 装备附加的移动速度
    self._EquipMoveSpeed = 0

    -- 装备附加的攻击速度
    self._EquipAtkSpeed = 0
    
    self._EquipAtk = 0
    
    -- 人口
    self._Population = 0
    
    -- 类型
    self._Type = 0
    
    -- 剩余时间
    self._Time = 0
    
    -- 训练类型
    self._TrainType = 0
    
    -- 升阶经验
    self._advanceExp = 0
    
    -- 攻击力
    self._Attack = 0
    
    -- 移动速度
    self._MoveSpeed = 0
    
    -- 攻击速度
    self._AtkSpeed = 0
    
    --训练结束时间
    self._TimeEnd = 0
end

-- 武将数据
local WuJiangData = class("WuJiangData")

function WuJiangData:ctor(tableID)
    -- 表格ID
    self._TableID = tableID
    
    -- 表格数据
    self._CharacterData = CharacterDataManager[tableID]
    
    -- 消耗
    self._Consume = self._CharacterData["consumeFood"]

    -- 产出
    self._Output = self._CharacterData["outFood"]

    -- 人口
    self._Population = 0
    
    -- 关联技能数据
    self._CharacterSkillData1 = SkillDataManager[self._CharacterData["skill1"]]
    
    -- 关联技能数据2
    self._CharacterSkillData2 = SkillDataManager[self._CharacterData["skill2"]]
    
    -- 当前对应的UI索引
    self._CurrentUIIndex = 0
    
    self._CurrentState = 0
    -- 装备信息
    
    -- 装备附加的攻击力
    self._EquipAtk = 0
    
    -- 装备附加的血量
    self._EquipHp = 0
    
    -- 装备附加的移动速度
    self._EquipMoveSpeed = 0
    
    -- 装备附加的攻击速度
    self._EquipAtkSpeed = 0
    
    -- 等级
    self._Level = 0
    
    -- 经验
    self._Exp = 0
    
    -- 血量
    self._Hp = 0
    
    -- 护甲
    self._Def = 0
    
    -- 攻击距离 
    self._GongJu = 0
    
    -- 攻击力
    self._Attack = 0
    
    -- 攻击速度
    self._AtkSpeed = 0
    
    -- 移动速度
    self._MoveSpeed = self._CharacterData["moveSpeed"]
    
    -- 装备
    self._Equip = {0,0,0,0,0,0,0,0} -- 8个
    
    -- 训练剩余时间
    self._Time = 0
    
    -- 训练类型
    self._TrainType = 0
    
    -- 升阶经验
    self._AdvanceExp = 0
    
end

function WuJiangData:update()
    self._EquipAtk = 0
    self._EquipHp = 0
    self._EquipMoveSpeed = 0
    self._EquipAtkSpeed = 0
    local ItemDataManager = GameGlobal:GetItemDataManager() 
    for i = 1, 8 do
        if self._Equip[i] > 0 then
            local equip = ItemDataManager:GetItem(self._Equip[i])
            self._EquipHp = self._EquipHp +  GameGlobal:GetEquipDataManager()[equip._ItemTableID][equip._ItemEquipLevel].hp
            self._EquipAtk = self._EquipAtk + GameGlobal:GetEquipDataManager()[equip._ItemTableID][equip._ItemEquipLevel].ap
            self._EquipAtkSpeed = self._EquipAtkSpeed  +  GameGlobal:GetEquipDataManager()[equip._ItemTableID][equip._ItemEquipLevel].as 
        end
    end
end

--阵形数据
local  ZhenXingData = class("ZhenXingData")
function ZhenXingData:ctor()
    --阵形ID
    self._ZhenXingID = 0
    --阵形初始位置 行列
    self._ZhenXingStartRow = 0
    self._ZhenXingStartCol = 0
    --武将TableID
    self._WuJiangTableID = 0
    self._SoldierTableID = 0
    --阵型位置X
    self._InitX = 0
    self._InitY = 0
    --根节点
    self._TipRootNode = nil
    -------------来自服务器的额外数据
    --    --等级
    self._WuJiangLevel = 0 
    --血量
    self._WuJiangHP = 0
    --攻击
    self._WuJiangAttack = 0
    self._WuJiangAttackSpeed = 0
    --士兵的
    self._SoldierLevel = 0
    self._SoldierHP = 0
    self._SoldierAttack = 0
    self._SoldierAttackSpeed = 0
end

--竞技场 玩家数据
local ShaChangPlayerInfo = class("ShaChangPlayerInfo")
function ShaChangPlayerInfo:ctor()
    --GUID
    self._GUID = 0
    --Vip
    self._Vip = 0
    --Name
    self._Name = 0
end
-- 管理器
function CharacterServerDataManager:ctor()
    -- 当前拥有的士兵
    self._OwnSolderList = {}
    -- 当前拥有的武将
    self._OwnLeaderLen = 0
    self._OwnLeaderList = {}
    -- 当前出战的武将列表
    self._OwnBattleLeaderList = {}
    self._TrainSoldierID = 0
    --布阵数据
    self._AllZhenXingTable = {[1] = {}, [2] = {}, [3] = {}}
    --阵营数据备份
    self._AllZhenXingCopyTable = {[1] = {}, [2] = {}, [3] = {}}
    --竞技场我方阵型数据
    self._SelfShaChangData = {}
    --竞技场敌方阵型数据
    self._EnemyShaChangData = {}
    --竞技场 攻方玩家信息
    self._AttackerShaChangPlayerData = ShaChangPlayerInfo.new()
    self._DefenderShaChangPlayerData = ShaChangPlayerInfo.new()
    --竞技场 
    self._CurrentShaChangBattleAwardTableID = 0 
    self._CurrentShaChangBattleResult = 0
    --竞技场 Key
    self._ShaChangBattleKey = ""
    --临时数据  tableID为key  用于布阵编辑器的数据备份
    self._OwnLeaderListCopyTable = {}
    self._OwnSolderListCopyTable = {}
    self._OwnLeaderLenCopy = 0
   
end

-- 创建士兵数据  tableID:表格ID
function CharacterServerDataManager:CreateSoldier(tableID)
    local newSoldierData = SoldierData.new(tableID)
    self._TrainSoldierID = tableID
    self._OwnSolderList[tableID] = newSoldierData
    return newSoldierData
end

function CharacterServerDataManager:NewSoldier(tableID)
    print(tableID)
    local soldierData = SoldierData.new(tableID)
    soldierData._Level = 1
    soldierData._Exp = 0
    soldierData._Hp = soldierData._CharacterData["hp"]
    soldierData._Def = soldierData._CharacterData["defence"]
    soldierData._Attack = soldierData._CharacterData["attack"]
    soldierData._AtkSpeed = soldierData._CharacterData["attackSpeed"]
    soldierData._GongJu = soldierData._CharacterData["maxAttackDistance"]
    soldierData._MoveSpeed = soldierData._CharacterData["moveSpeed"]
    soldierData._Consume = soldierData._CharacterData["consumeFood"]
    soldierData._Output = soldierData._CharacterData["outFood"] 
    soldierData._Population = soldierData._CharacterData["people"]
    soldierData._Type = soldierData._CharacterData["soldierType"]
    soldierData._Time = 0
    soldierData._TrainType = 0
    soldierData._advanceExp  = 0
    soldierData._TimeEnd = 0
    return soldierData
end

-- 获取某个士兵
function CharacterServerDataManager:GetSoldier(tableID)
     
    return  self._OwnSolderList[tableID]

end

function CharacterServerDataManager:UpdateSoldier()
    self._SoldierIDList = {}
    for i, v in pairs(self._OwnSolderList) do
        table.insert(self._SoldierIDList, i)
    end
end

-- 获取某个士兵
function CharacterServerDataManager:RemoveSoldier(tableID)
    self._OwnSolderList[tableID] = nil 
end 

--TODO:创建武将数据
function CharacterServerDataManager:CreateLeader(tableID)
    local newLeaderData = WuJiangData.new(tableID)
    self._OwnLeaderList[tableID] = newLeaderData
    return newLeaderData
end

function CharacterServerDataManager:GetLeader(tableID)
    return self._OwnLeaderList[tableID]
end

function CharacterServerDataManager:GetLeaderId()
    self:UpdateLeader()
    table.sort(self._LeaderIDList, function(a, b)
        if self._OwnLeaderList[a]._CharacterData.quality == self._OwnLeaderList[b]._CharacterData.quality  then
            return self._OwnLeaderList[a]._Level > self._OwnLeaderList[b]._Level
        else
            return self._OwnLeaderList[a]._CharacterData.quality > self._OwnLeaderList[b]._CharacterData.quality 
        end
    end)
   
    return  self._LeaderIDList[1]
end

function CharacterServerDataManager:RemoveLeader(tableID)
    self._OwnLeaderList[tableID] = nil 
end 

function CharacterServerDataManager:UpdateLeader()
    self._LeaderIDList = {}
    for i, v in pairs(self._OwnLeaderList) do
        table.insert(self._LeaderIDList, i)
    end
end

function CharacterServerDataManager:GetLeaderCount()
    local num = 0
    for i, v in pairs(self._OwnLeaderList) do
        num = num + 1
    end
    return num
end

function CharacterServerDataManager:GetPvpMaxWariors()
    local num = GetGlobalData()._TechnologyList[2][2]
    for i = 5, 7 do 
        if tonumber(num) == i then
            num = num - 2
            break
        end
    end
    if tonumber(num) == 0 then
        num = 2
    end
    return num
end

-- 获取武将
function CharacterServerDataManager:GetLeader(tableID)
    return self._OwnLeaderList[tableID]
end

--查找士兵
function CharacterServerDataManager:GetSoldierLess()
    for k, v in pairs(self._OwnSolderList)do
        if v ~= nil then
            if v._CharacterData.people == 1 then
                return k
            end
        end
    end
    return nil
end

--创建阵形(id:1 ,2 3 )
function CharacterServerDataManager:CreateZhenXingData()
    local newZhenXingData = ZhenXingData:new()
    return newZhenXingData
end
--获取阵形
function CharacterServerDataManager:GetZhenXingData(id, wuJiangTableID)
    if wuJiangTableID == nil then
        return self._AllZhenXingTable[id]
    end
    return self._AllZhenXingTable[id][wuJiangTableID]
end

function CharacterServerDataManager:GetZhenXingDataByID(id)
    for k, v in pairs(self._AllZhenXingTable[id])do
        return v
    end
end
    
--获取
function CharacterServerDataManager:GetCurrentZhenXingWuJiangCount(zhenXingIndex)
    local currentCount = 0
    local zhenXingData = self._AllZhenXingTable[zhenXingIndex]
    for k, v in pairs(zhenXingData)do
        currentCount = currentCount + 1
    end
    return currentCount
end
--获取一个阵型
function CharacterServerDataManager:GetOneZhenXing()
    local isHaveData = false
    local resultData = nil
    for i = 1, 3 do
        if self._AllZhenXingTable[i] ~= nil then
            for k, v in pairs(self._AllZhenXingTable[i])do
                if v ~= nil then
                    isHaveData = true 
                    resultData = self._AllZhenXingTable[i]
                    break
                end
            end
        end
        if isHaveData == true then
            break
        end
    end
    return resultData
end

--备份阵型数据
function CharacterServerDataManager:BackUpZhenXingData()
    self._AllZhenXingCopyTable =  clone(self._AllZhenXingTable)
end
--还原阵型数据
function CharacterServerDataManager:RestoreZhenXingData()
    self._AllZhenXingTable =  clone(self._AllZhenXingCopyTable)
end
--删除阵形
function CharacterServerDataManager:DeleteZhenXingData(id, wuJiangTableID)
    self._AllZhenXingTable[id][wuJiangTableID] = nil
end
--备份布阵编辑前的数据
function CharacterServerDataManager:BackupBeforeBuZhenEditor()
    self._OwnLeaderListCopyTable = clone(self._OwnLeaderList)
    self._OwnSolderListCopyTable = clone(self._OwnSolderList)
    self._AllZhenXingCopyTable =  clone(self._AllZhenXingTable)
    self._OwnLeaderLenCopy = self._OwnLeaderLen
end
--还原到布阵编辑器前的数据
function CharacterServerDataManager:RestoreBuZhenEditor()
    self._OwnLeaderList = clone(self._OwnLeaderListCopyTable)
    self._OwnSolderList = clone(self._OwnSolderListCopyTable)
    self._AllZhenXingTable = clone(self._AllZhenXingCopyTable)
    self._OwnLeaderLen =  self._OwnLeaderLenCopy
end

local newCharacterServerDataManager = CharacterServerDataManager:new()

function GetCharacterServerDataManager()
    return newCharacterServerDataManager
end


return newCharacterServerDataManager