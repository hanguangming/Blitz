----
-- 文件名称：CSWarriorStrengPacket.lua
-- 功能描述：充值
-- 文件说明：充值
-- 作    者：田凯
-- 创建时间：2015-9-23
--  修改


--包定义
local CSWarriorStrengPacket = class("CSWarriorStrengPacket", PacketBase)
CSWarriorStrengPacket._PacketID = PacketDefine.PacketDefine_WarriorStreng_Send

--构造函数
function CSWarriorStrengPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSWarriorStrengPacket._PacketID
end

function CSWarriorStrengPacket:init(data)
    self._guid = data[1]
    self._count = data[2]
end

function CSWarriorStrengPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeInt(self._guid)
    self._ContentStream:writeByte(self._count)
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSWarriorStrengPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
end

function CSWarriorStrengPacket:Execute()
    print(self.__cname, self._IntResult) 
    if self._IntResult == 0 then
        DispatchEvent(GameEvent.GameEvent_UIEquipStreng_Succeed)
    end
end

--不要忘记最后的return
return CSWarriorStrengPacket