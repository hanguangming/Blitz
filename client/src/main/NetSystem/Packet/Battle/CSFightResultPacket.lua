----
-- 文件名称：CSArenaChallengeResult.lua
-- 功能描述：发送战斗结果
-- 文件说明：
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改   发送客户端立即计算结果

--包定义
local CSFightResultPacket = class("CSFightResultPacket", PacketBase)
CSFightResultPacket._PacketID = PacketDefine.PacketDefine_FightResult_Send
--构造函数

function CSFightResultPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSFightResultPacket._PacketID
end

function CSFightResultPacket:init(data)
    self.FightInfo = data
end

function CSFightResultPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    local FightInfo = self.FightInfo
    self._ContentStream:writeInt(FightInfo.fightID)
   
    self._ContentStream:writeInt(FightInfo["attacker"].uid)
    self._ContentStream:writeInt(FightInfo["attacker"].vip)
    self._ContentStream:writeStringUInt(FightInfo["attacker"].name)
    local attackTeamNum 
    if FightInfo["result"] == 2 then
        attackTeamNum = 0
    else
        attackTeamNum = #FightInfo["attacker"]["teams"]
    end
    self._ContentStream:writeInt(attackTeamNum)
    
    for i = 1, attackTeamNum  do
        local team = FightInfo["attacker"]["teams"][i]
        self._ContentStream:writeInt(team.hero_id)
        self._ContentStream:writeInt(team.hero_attack)
        self._ContentStream:writeInt(team.hero_attack_speed)
        self._ContentStream:writeInt(team.hero_hp_max)
        self._ContentStream:writeInt(team.hero_hp)

        self._ContentStream:writeInt(team.soldier_id)
        self._ContentStream:writeInt(team.soldier_attack)
        self._ContentStream:writeInt(team.soldier_attack_speed)
        self._ContentStream:writeInt(team.soldier_hp)
        self._ContentStream:writeByte(team.soldier_num)
        self._ContentStream:writeInt(team.x)
        self._ContentStream:writeInt(team.y)
    end
    
    self._ContentStream:writeInt(FightInfo["defender"].uid)
    self._ContentStream:writeInt(FightInfo["defender"].vip)
    self._ContentStream:writeStringUInt(FightInfo["defender"].name)
    local defenderTeamNum
    if FightInfo["result"] == 1 then
        defenderTeamNum = 0
    else
        defenderTeamNum = #FightInfo["defender"]["teams"]
    end
    self._ContentStream:writeInt(defenderTeamNum)
    for i = 1, defenderTeamNum  do
        local team = FightInfo["defender"]["teams"][i]
        self._ContentStream:writeInt(team.hero_id)
        self._ContentStream:writeInt(team.hero_attack)
        self._ContentStream:writeInt(team.hero_attack_speed)
        self._ContentStream:writeInt(team.hero_hp_max)
        self._ContentStream:writeInt(team.hero_hp)

        self._ContentStream:writeInt(team.soldier_id)
        self._ContentStream:writeInt(team.soldier_attack)
        self._ContentStream:writeInt(team.soldier_attack_speed)
        self._ContentStream:writeInt(team.soldier_hp)
        self._ContentStream:writeByte(team.soldier_num)
        self._ContentStream:writeInt(team.x)
        self._ContentStream:writeInt(team.y)
    end
    
    self._ContentStream:writeByte(FightInfo["result"])
    self._ContentStream:writeInt(FightInfo["frames"])
    self._ContentStream:writeInt(FightInfo["time"])
    self._ContentStream:writeInt(FightInfo["seed"])
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSFightResultPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
end

function CSFightResultPacket:Execute()
    print(self.__cname, self._IntResult) 
end

return CSFightResultPacket