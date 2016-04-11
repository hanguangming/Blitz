----
-- 文件名称：CSChatPacket.lua
-- 功能描述：物品使用
-- 文件说明：物品使用
-- 作    者：田凯
-- 创建时间：2015-9-23
--  修改


--包定义
local CSChatPacket = class("CSChatPacket", PacketBase)
CSChatPacket._PacketID = PacketDefine.PacketDefine_Char_Send

--构造函数
function CSChatPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSChatPacket._PacketID
end

function CSChatPacket:init(data)
    self._channel = data[1]
    self._magic = data[2]
    self._msg = data[3]
end

function CSChatPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeByte(self._channel)
    self._ContentStream:writeInt(self._magic)
    self._ContentStream:writeStringUInt(self._msg)
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSChatPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
end

function CSChatPacket:Execute()
    print(self.__cname, self._IntResult) 
    if self._IntResult == 0 then
    end
end

return  CSChatPacket