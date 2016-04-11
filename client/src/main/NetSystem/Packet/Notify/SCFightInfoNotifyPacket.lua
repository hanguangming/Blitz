----
-- 文件名称：SCFightInfoNotifyPacket.lua
-- 功能描述：通知客户端战斗计算专用
-- 文件说明：
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改  

local SCFightInfoNotifyPacket = class("SCFightInfoNotifyPacket", PacketBase)
SCFightInfoNotifyPacket._PacketID = PacketDefine.PacketDefine_FightInfoNotify
-- 构造函数

function SCFightInfoNotifyPacket:ctor()
    self.super.ctor(self)
    self._PacketID = SCFightInfoNotifyPacket._PacketID
end

function SCFightInfoNotifyPacket:init(data)

end

function SCFightInfoNotifyPacket:Write()
    self:WritePacketContentID()
    -- 包的其它字段
    -- 最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function SCFightInfoNotifyPacket:Read(byteStream)
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
    G_FightInfo["attacker"]["uid"] = attack._GUID
    G_FightInfo["attacker"]["vip"] = attack._Vip
    G_FightInfo["attacker"]["name"] = attack._Name
    
    local num = byteStream:readInt()
    local tempAttackerZhenXingTable = {}
    local attackList = {}
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
        tempAttackerZhenXingTable[newZhenXingData._WuJiangTableID] = newZhenXingData
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
        
    end
    local tempDefenderZhenXingTable = {}
    local defender = GuoZhanServerDataManager:CreateGetGuoZhanDefenderPlayerData()
    defender._GUID = byteStream:readInt()
    defender._Vip = byteStream:readInt()
    defender._Name = byteStream:readStringUInt()
    G_FightInfo["defender"]["uid"] = defender._GUID
    G_FightInfo["defender"]["vip"] = defender._Vip
    G_FightInfo["defender"]["name"] = defender._Name
    
    local num = byteStream:readInt()
    local defenderList = {}
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
        tempDefenderZhenXingTable[newZhenXingData._WuJiangTableID] = newZhenXingData
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
        
    end
    self._BattleResult = byteStream:readByte()
    self._Frames = byteStream:readInt()
    
    G_FightInfo["result"] = self._BattleResult
    G_FightInfo["frames"] = self._Frames
    G_FightInfo["time"] = byteStream:readInt() * 30 /  1000
    G_FightInfo["seed"] = byteStream:readInt()
   
end

--包处理
function SCFightInfoNotifyPacket:Execute()
    CalculateFightInfo(G_FightInfo, true)
end

--不要忘记最后的return
return SCFightInfoNotifyPacket