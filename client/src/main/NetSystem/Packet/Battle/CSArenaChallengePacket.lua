----
-- 文件名称：CSArenaChallengePacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local CSArenaChallengePacket = class("CSArenaChallengePacket", PacketBase)
CSArenaChallengePacket._PacketID = PacketDefine.PacketDefine_ArenaChallenge_Send
--构造函数

function CSArenaChallengePacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSArenaChallengePacket._PacketID
end

function CSArenaChallengePacket:init(data)
    self._guid = data[1]
end

function CSArenaChallengePacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeInt(self._guid)
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSArenaChallengePacket:Read(byteStream)
    local CharacterServerDataManager = GameGlobal:GetCharacterServerDataManager()
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
    CharacterServerDataManager._CurrentShaChangBattleAwardTableID = byteStream:readInt()
    G_FightInfo = {}
    G_FightInfo["attacker"] = {}
    G_FightInfo["defender"] = {}
    G_FightInfo["attacker"]["teams"] = {}
    G_FightInfo["defender"]["teams"] = {}
    CharacterServerDataManager._AttackerShaChangPlayerData._GUID = byteStream:readInt()
    CharacterServerDataManager._AttackerShaChangPlayerData._Vip = byteStream:readInt()
    CharacterServerDataManager._AttackerShaChangPlayerData._Name = byteStream:readStringUInt()
    G_FightInfo["attacker"]["uid"] = CharacterServerDataManager._AttackerShaChangPlayerData._GUID
    G_FightInfo["attacker"]["vip"] = CharacterServerDataManager._AttackerShaChangPlayerData._Vip
    G_FightInfo["attacker"]["name"] = CharacterServerDataManager._AttackerShaChangPlayerData._Name
    local num = byteStream:readInt()
    local attackList = {}
    for i = 1, num do
        local newZhenXingData = CharacterServerDataManager:CreateZhenXingData()
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
    end
    
    CharacterServerDataManager._DefenderShaChangPlayerData._GUID = byteStream:readInt()
    CharacterServerDataManager._DefenderShaChangPlayerData._Vip = byteStream:readInt()
    CharacterServerDataManager._DefenderShaChangPlayerData._Name = byteStream:readStringUInt()
    G_FightInfo["defender"]["uid"] = CharacterServerDataManager._DefenderShaChangPlayerData._GUID
    G_FightInfo["defender"]["vip"] = CharacterServerDataManager._DefenderShaChangPlayerData._Vip
    G_FightInfo["defender"]["name"] = CharacterServerDataManager._DefenderShaChangPlayerData._Name
    local num = byteStream:readInt()
    local defenderList = {}
    for i = 1, num do
        local newZhenXingData = CharacterServerDataManager:CreateZhenXingData()
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
    end
    
    self._BattleResult = byteStream:readByte()
    self._Frames = byteStream:readInt()
    G_FightInfo["result"] = self._BattleResult
    G_FightInfo["frames"] = self._Frames
    G_FightInfo["time"] = byteStream:readInt() * 30 /  1000
    G_FightInfo["seed"] = byteStream:readInt()
end

--包处理
function CSArenaChallengePacket:Execute()
    print(self.__cname, self._IntResult) 
    if self._IntResult == 0 then
        GameGlobal:GetUISystem():CloseUI(UIType.UIType_ShaChangDianBing)
        GameGlobal:GlobalLevelState(3)
        CalculateFightInfo(G_FightInfo, true)
        if  self._BattleResult == 1 then  -- self win
            SendMsg(PacketDefine.PacketDefine_ArenaList_Send)
        end
    end
end

--不要忘记最后的return
return CSArenaChallengePacket