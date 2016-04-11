----
-- 文件名称：SCFightNotifyPacket.lua
-- 功能描述：通知客户端战斗计算专用
-- 文件说明：
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改
  

--包定义
local SCFightNotifyPacket = class("SCFightNotifyPacket", PacketBase)
SCFightNotifyPacket._PacketID = PacketDefine.PacketDefine_FightNotify
--构造函数

function SCFightNotifyPacket:ctor()
    self.super.ctor(self)
    self._PacketID = SCFightNotifyPacket._PacketID
end

function SCFightNotifyPacket:init(data)
  
end

function SCFightNotifyPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function SCFightNotifyPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    local FightInfo = {}
    FightInfo["fightID"] = byteStream:readInt()
    FightInfo["attacker"] = {}
    FightInfo["defender"] = {}
    FightInfo["attacker"]["teams"] = {}
    FightInfo["defender"]["teams"] = {}
    FightInfo["attacker"]["uid"] = byteStream:readInt()
    FightInfo["attacker"]["vip"] = byteStream:readInt()
    FightInfo["attacker"]["name"] = byteStream:readStringUInt()

    local num = byteStream:readInt()
    for i = 1, num do
        FightInfo["attacker"]["teams"][i] = {}
        FightInfo["attacker"]["teams"][i].hero_id = byteStream:readInt()
        FightInfo["attacker"]["teams"][i].hero_attack = byteStream:readInt()
        FightInfo["attacker"]["teams"][i].hero_attack_speed = byteStream:readInt()
        FightInfo["attacker"]["teams"][i].hero_hp_max = byteStream:readInt()
        FightInfo["attacker"]["teams"][i].hero_hp = byteStream:readInt()

        FightInfo["attacker"]["teams"][i].soldier_id = byteStream:readInt()
        FightInfo["attacker"]["teams"][i].soldier_attack = byteStream:readInt()
        FightInfo["attacker"]["teams"][i].soldier_attack_speed =byteStream:readInt()
        FightInfo["attacker"]["teams"][i].soldier_hp = byteStream:readInt()
        FightInfo["attacker"]["teams"][i].soldier_num = byteStream:readByte()
        FightInfo["attacker"]["teams"][i].x = byteStream:readInt()
        FightInfo["attacker"]["teams"][i].y = byteStream:readInt()
    end
    
    FightInfo["defender"]["uid"] = byteStream:readInt()
    FightInfo["defender"]["vip"] = byteStream:readInt()
    FightInfo["defender"]["name"] = byteStream:readStringUInt()
    
    local num = byteStream:readInt()
    for i = 1, num do
        FightInfo["defender"]["teams"][i] = {}
        FightInfo["defender"]["teams"][i].hero_id = byteStream:readInt()
        FightInfo["defender"]["teams"][i].hero_attack = byteStream:readInt()
        FightInfo["defender"]["teams"][i].hero_attack_speed = byteStream:readInt()
        FightInfo["defender"]["teams"][i].hero_hp_max = byteStream:readInt()
        FightInfo["defender"]["teams"][i].hero_hp = byteStream:readInt()
        
        FightInfo["defender"]["teams"][i].soldier_id = byteStream:readInt()
        FightInfo["defender"]["teams"][i].soldier_attack = byteStream:readInt()
        FightInfo["defender"]["teams"][i].soldier_attack_speed = byteStream:readInt()
        FightInfo["defender"]["teams"][i].soldier_hp = byteStream:readInt()
        FightInfo["defender"]["teams"][i].soldier_num = byteStream:readByte()
        FightInfo["defender"]["teams"][i].x = byteStream:readInt()
        FightInfo["defender"]["teams"][i].y = byteStream:readInt()
    end 
    
    FightInfo["result"] = byteStream:readByte()
    FightInfo["frames"] = byteStream:readInt()
    FightInfo["time"] = byteStream:readInt() * 30 /  1000
    FightInfo["seed"] = byteStream:readInt()
    
    self.FightInfo = FightInfo 
end

--包处理
function SCFightNotifyPacket:Execute()
    print(self.__cname) 
    local FightInfo = CalculateFightInfo(self.FightInfo, false)
    SendMsg(PacketDefine.PacketDefine_FightResult_Send, FightInfo)
end

--不要忘记最后的return
return SCFightNotifyPacket