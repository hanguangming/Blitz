----
-- 文件名称：SCMapFightInfoNotifyPacket.lua
-- 功能描述：物品使用
-- 文件说明：物品使用
-- 作    者：田凯
-- 创建时间：2015-9-23
--  修改

--服务器数据 -->客户端阵形数据(zhenXingData:服务器数据    dataTable:输出数据的Table) copy from SCFightNotifyPacket
local function CreateZhenXingData(zhenXingData, dataTable)
    if zhenXingData == nil or dataTable == nil then
        print("error: CreateZhenXingData zhenXingData == nil or dataTable == nil", zhenXingData, dataTable)
        return
    end
    local GuoZhanServerDataManager =  GameGlobal:GetGuoZhanServerDataManager()
    --武将阵形数据
    local startRow = zhenXingData._ZhenXingStartRow
    local startCol = zhenXingData._ZhenXingStartCol
    local wuJiangTableID = zhenXingData._WuJiangTableID
    local levelZhenXingData = GuoZhanServerDataManager:CreateGuoZhanZhenXing()
    levelZhenXingData._SoldierTableID = wuJiangTableID
    levelZhenXingData._TileX = startRow + ZHEN_XING_WUJIANG_POS[1][1]
    levelZhenXingData._TileY = startCol + ZHEN_XING_WUJIANG_POS[1][2]
    levelZhenXingData._HP = zhenXingData._WuJiangCurHP
    levelZhenXingData._AttackSpeed = zhenXingData._WuJiangAttackSpeed
    levelZhenXingData._Attack = zhenXingData._WuJiangAttack
    levelZhenXingData._BelongWuJiangTableID = zhenXingData._WuJiangTableID
    levelZhenXingData._BigZhenXingRow = startRow
    levelZhenXingData._BigZhenXingCol = startCol
    levelZhenXingData._SoldierCount = zhenXingData._SoldierNum
    if levelZhenXingData._HP > 0 then
        table.insert(dataTable, levelZhenXingData)
    end
    local soldierTableID = zhenXingData._SoldierTableID
    local soldierCount = zhenXingData._SoldierNum
    local currentCount = 0
    --小兵阵形数据 根据所占人口
    local TableDataManager = GameGlobal:GetDataTableManager()
    local armyDataManager = TableDataManager:GetCharacterDataManager()
    local armyData = armyDataManager[soldierTableID]
    if armyData == nil then
        print("CreateZhenXingData armyData == nil", soldierTableID)
    end
    local people = armyData.people
    if people == 1 then
        for row = 1, 5 do
            if currentCount >= soldierCount then
                break
            end
            for col = 1, 4 do
                if currentCount >= soldierCount then
                    break
                end
                local levelZhenXingData = GuoZhanServerDataManager:CreateGuoZhanZhenXing()
                levelZhenXingData._SoldierTableID = zhenXingData._SoldierTableID
                levelZhenXingData._TileX = startRow + ZHEN_XING_PEO_1[row][col][1]
                levelZhenXingData._TileY = startCol + ZHEN_XING_PEO_1[row][col][2]
                levelZhenXingData._HP = zhenXingData._SoldierHP
                levelZhenXingData._AttackSpeed = zhenXingData._SoldierAttackSpeed
                levelZhenXingData._Attack = zhenXingData._SoldierAttack
                levelZhenXingData._BelongWuJiangTableID = wuJiangTableID
                levelZhenXingData._BigZhenXingRow = startRow
                levelZhenXingData._BigZhenXingCol = startCol
                levelZhenXingData._SoldierCount = zhenXingData._SoldierNum
                table.insert(dataTable, levelZhenXingData)
                currentCount = currentCount + 1
            end
        end
    elseif people == 5 then
        for row = 1, 2 do
            if currentCount >= soldierCount then
                break
            end
            for col = 1, 2 do
                if currentCount >= soldierCount then
                    break
                end
                local levelZhenXingData = GuoZhanServerDataManager:CreateGuoZhanZhenXing()
                levelZhenXingData._SoldierTableID = zhenXingData._SoldierTableID
                levelZhenXingData._TileX = startRow + ZHEN_XING_PEO_5[row][col][1]
                levelZhenXingData._TileY = startCol + ZHEN_XING_PEO_5[row][col][2]
                levelZhenXingData._HP = zhenXingData._SoldierHP
                levelZhenXingData._AttackSpeed = zhenXingData._SoldierAttackSpeed
                levelZhenXingData._Attack = zhenXingData._SoldierAttack
                levelZhenXingData._BelongWuJiangTableID = wuJiangTableID
                levelZhenXingData._BigZhenXingRow = startRow
                levelZhenXingData._BigZhenXingCol = startCol
                levelZhenXingData._SoldierCount = zhenXingData._SoldierNum
                table.insert(dataTable, levelZhenXingData)
                currentCount = currentCount + 1
            end
        end
    elseif people == 10 then
        for row = 1, 2 do
            if currentCount >= soldierCount then
                break
            end
            local levelZhenXingData = GuoZhanServerDataManager:CreateGuoZhanZhenXing()
            levelZhenXingData._SoldierTableID = zhenXingData._SoldierTableID
            levelZhenXingData._TileX = startRow + ZHEN_XING_PEO_10[row][1]
            levelZhenXingData._TileY = startCol + ZHEN_XING_PEO_10[row][2]
            levelZhenXingData._HP = zhenXingData._SoldierHP
            levelZhenXingData._AttackSpeed = zhenXingData._SoldierAttackSpeed
            levelZhenXingData._Attack = zhenXingData._SoldierAttack
            levelZhenXingData._BelongWuJiangTableID = wuJiangTableID
            levelZhenXingData._BigZhenXingRow = startRow
            levelZhenXingData._BigZhenXingCol = startCol
            levelZhenXingData._SoldierCount = zhenXingData._SoldierNum
            table.insert(dataTable, levelZhenXingData)
            currentCount = currentCount + 1
        end
    end
end

--包定义
local SCMapFightInfoNotifyPacket = class("SCMapFightInfoNotifyPacket", PacketBase)
SCMapFightInfoNotifyPacket._PacketID = PacketDefine.PacketDefine_MapFightInfoNotify

--构造函数
function SCMapFightInfoNotifyPacket:ctor()
    self.super.ctor(self)
    self._PacketID = SCMapFightInfoNotifyPacket._PacketID
end

function SCMapFightInfoNotifyPacket:init(data)

end

function SCMapFightInfoNotifyPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function SCMapFightInfoNotifyPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    G_FightInfo = {}
    G_FightInfo["attacker"] = {}
    G_FightInfo["defender"] = {}
    G_FightInfo["attacker"]["teams"] = {}
    G_FightInfo["defender"]["teams"] = {}
    local GuoZhanServerDataManager =  GameGlobal:GetGuoZhanServerDataManager()
    GuoZhanServerDataManager._BattleCheckBattleID = self._FightID
    GuoZhanServerDataManager._GuoZhanAttackerZhenXingData  = {}
    local attack = GuoZhanServerDataManager:CreateGetGuoZhanAttackerPlayerData()
    attack._GUID = byteStream:readInt()
    attack._Vip = byteStream:readInt()
    attack._Name = byteStream:readStringUInt()
    local num = byteStream:readInt()
    G_FightInfo["attacker"]["uid"] = attack._GUID
    G_FightInfo["attacker"]["vip"] = attack._Vip
    G_FightInfo["attacker"]["name"] = attack._Name
    --GuoZhanServerDataManager._SelfShaChangData._ZhenXingNum = num
    --GuoZhanServerDataManager._SelfShaChangData._ZhenXingId = {}
    local tempAttackerZhenXingTable = {}
    for i = 1, num do
        local newZhenXingData = GuoZhanServerDataManager:CreateGuoZhanZhenXingNew()
        newZhenXingData._WuJiangTableID = byteStream:readInt()
        newZhenXingData._WuJiangAttack = byteStream:readInt()
        newZhenXingData._WuJiangAttackSpeed = byteStream:readInt()
        newZhenXingData._WuJiangHPMax = byteStream:readInt()
        newZhenXingData._WuJiangHP = byteStream:readInt()

        newZhenXingData._SoldierTableID =  byteStream:readInt()
        newZhenXingData._SoldierAttack  = byteStream:readInt()
        newZhenXingData._SoldierAttackSpeed  = byteStream:readInt()
        newZhenXingData._SoldierHP  = byteStream:readInt()
        newZhenXingData._SoldierNum  = byteStream:readByte()
        newZhenXingData._ZhenXingStartRow = byteStream:readInt()
        newZhenXingData._ZhenXingStartCol = byteStream:readInt()
        
        local data = {}
        data[1] = newZhenXingData._WuJiangTableID 
        data[2] = newZhenXingData._WuJiangAttack
        data[3] = newZhenXingData._WuJiangAttackSpeed
        data[4] = newZhenXingData._WuJiangHP
        data[5] = newZhenXingData._WuJiangHPMax
        data[6] = newZhenXingData._SoldierTableID
        data[7] = newZhenXingData._SoldierAttack
        data[8] = newZhenXingData._SoldierAttackSpeed
        data[9] = newZhenXingData._SoldierHP
        data[10] = newZhenXingData._SoldierNum
        data[12] = newZhenXingData._ZhenXingStartRow
        data[13] = newZhenXingData._ZhenXingStartCol
        
        G_FightInfo["attacker"]["teams"][i] = {}
        G_FightInfo["attacker"]["teams"][i].hero_id = data[1]
        G_FightInfo["attacker"]["teams"][i].hero_attack = data[2]
        G_FightInfo["attacker"]["teams"][i].hero_attack_speed = data[3]
        G_FightInfo["attacker"]["teams"][i].hero_hp = data[4]
        G_FightInfo["attacker"]["teams"][i].hero_hp_max = data[5]

        G_FightInfo["attacker"]["teams"][i].soldier_id = data[6]
        G_FightInfo["attacker"]["teams"][i].soldier_attack = data[7]
        G_FightInfo["attacker"]["teams"][i].soldier_attack_speed = data[8]
        G_FightInfo["attacker"]["teams"][i].soldier_hp = data[9]
        G_FightInfo["attacker"]["teams"][i].soldier_num = data[10]
        G_FightInfo["attacker"]["teams"][i].x = data[12]
        G_FightInfo["attacker"]["teams"][i].y = data[13]
        --GuoZhanServerDataManager._SelfShaChangData._ZhenXingId[i] = newZhenXingData._WuJiangTableID
        tempAttackerZhenXingTable[newZhenXingData._WuJiangTableID] = newZhenXingData
        --GuoZhanServerDataManager._GuoZhanAttackerZhenXingData [newZhenXingData._WuJiangTableID] = 
    end

    --GuoZhanServerDataManager._GuoZhanDefenderZhenXingData  = {}
    local tempDefenderZhenXingTable = {}
    local defender = GuoZhanServerDataManager:CreateGetGuoZhanDefenderPlayerData()
    defender._GUID = byteStream:readInt()
    defender._Vip = byteStream:readInt()
    defender._Name = byteStream:readStringUInt()
    local num = byteStream:readInt()
    G_FightInfo["defender"]["uid"] = defender._GUID
    G_FightInfo["defender"]["vip"] = defender._Vip
    G_FightInfo["defender"]["name"] = defender._Name
    --GuoZhanServerDataManager._EnemyShaChangData._ZhenXingNum = num
    --GuoZhanServerDataManager._EnemyShaChangData._ZhenXingId = {}
    for i = 1, num do
        local newZhenXingData = GuoZhanServerDataManager:CreateGuoZhanZhenXingNew()
        newZhenXingData._WuJiangTableID = byteStream:readInt()
        newZhenXingData._WuJiangAttack = byteStream:readInt()
        newZhenXingData._WuJiangAttackSpeed = byteStream:readInt()
        newZhenXingData._WuJiangHPMax = byteStream:readInt()
        newZhenXingData._WuJiangHP = byteStream:readInt()

        newZhenXingData._SoldierTableID =  byteStream:readInt()
        newZhenXingData._SoldierAttack  = byteStream:readInt()
        newZhenXingData._SoldierAttackSpeed  = byteStream:readInt()
        newZhenXingData._SoldierHP  = byteStream:readInt()
        newZhenXingData._SoldierNum  = byteStream:readByte()
        newZhenXingData._ZhenXingStartRow = byteStream:readInt()
        newZhenXingData._ZhenXingStartCol = byteStream:readInt()
        
        local data = {}
        data[1] = newZhenXingData._WuJiangTableID 
        data[2] = newZhenXingData._WuJiangAttack
        data[3] = newZhenXingData._WuJiangAttackSpeed
        data[4] = newZhenXingData._WuJiangHP
        data[5] = newZhenXingData._WuJiangHPMax
        data[6] = newZhenXingData._SoldierTableID
        data[7] = newZhenXingData._SoldierAttack
        data[8] = newZhenXingData._SoldierAttackSpeed
        data[9] = newZhenXingData._SoldierHP
        data[10] = newZhenXingData._SoldierNum
        data[12] = newZhenXingData._ZhenXingStartRow
        data[13] = newZhenXingData._ZhenXingStartCol

        G_FightInfo["defender"]["teams"][i] = {}
        G_FightInfo["defender"]["teams"][i].hero_id = data[1]
        G_FightInfo["defender"]["teams"][i].hero_attack = data[2]
        G_FightInfo["defender"]["teams"][i].hero_attack_speed = data[3]
        G_FightInfo["defender"]["teams"][i].hero_hp = data[4]
        G_FightInfo["defender"]["teams"][i].hero_hp_max = data[5]
        G_FightInfo["defender"]["teams"][i].soldier_id = data[6]
        G_FightInfo["defender"]["teams"][i].soldier_attack = data[7]
        G_FightInfo["defender"]["teams"][i].soldier_attack_speed = data[8]
        G_FightInfo["defender"]["teams"][i].soldier_hp = data[9]
        G_FightInfo["defender"]["teams"][i].soldier_num = data[10]
        G_FightInfo["defender"]["teams"][i].x = data[12]
        G_FightInfo["defender"]["teams"][i].y = data[13]
        
        --GuoZhanServerDataManager._EnemyShaChangData._ZhenXingId[i] = newZhenXingData._WuJiangTableID
        --GuoZhanServerDataManager._GuoZhanDefenderZhenXingData[newZhenXingData._WuJiangTableID] = newZhenXingData
        tempDefenderZhenXingTable[newZhenXingData._WuJiangTableID] = newZhenXingData
    end
 
    self._BattleResult = byteStream:readByte()
    self._Frames = byteStream:readInt()
    
    G_FightInfo["result"] = self._BattleResult
    G_FightInfo["frames"] = self._Frames
    G_FightInfo["time"] = byteStream:readInt() * 30 /  1000
    G_FightInfo["seed"] = byteStream:readInt()

    --转化数据格式 
    GuoZhanServerDataManager._GuoZhanAttackerZhenXingData = {}
    for k, v in pairs(tempAttackerZhenXingTable)do
        CreateZhenXingData(v, GuoZhanServerDataManager._GuoZhanAttackerZhenXingData)
    end
    GuoZhanServerDataManager._GuoZhanDefenderZhenXingData = {}
    for k, v in pairs(tempDefenderZhenXingTable)do
        CreateZhenXingData(v, GuoZhanServerDataManager._GuoZhanDefenderZhenXingData)
    end
    
end


function SCMapFightInfoNotifyPacket:Execute()
    print(self.__cname, self._IntResult) 
    CalculateFightInfo(G_FightInfo, true)
end

return  SCMapFightInfoNotifyPacket