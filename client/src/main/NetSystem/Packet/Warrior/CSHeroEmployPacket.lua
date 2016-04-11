----
-- 文件名称：CSHeroEmployPacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local CSHeroEmployPacket = class("CSHeroEmployPacket", PacketBase)
CSHeroEmployPacket._PacketID = PacketDefine.PacketDefine_HeroEmploy_Send
--构造函数

function CSHeroEmployPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSHeroEmployPacket._PacketID
end

function CSHeroEmployPacket:init(data)
    self._guid = data[1]
    self._employ = data[2]
end

function CSHeroEmployPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeInt(self._guid)
    self._ContentStream:writeByte(self._employ)   
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSHeroEmployPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
end

--包处理
function CSHeroEmployPacket:Execute()
    print(self.__cname, self._IntResult) 
    --DispatchEvent(GameEvent.GameEvent_UIRecruitOpen_Succeed)'
    if self._IntResult == 0 then
        DispatchEvent(GameEvent.GameEvent_UIWarrior_Succeed)
        DispatchEvent(GameEvent.GameEvent_UIRecruitWarrior_Succeed)
    end
end

--不要忘记最后的return
return CSHeroEmployPacket