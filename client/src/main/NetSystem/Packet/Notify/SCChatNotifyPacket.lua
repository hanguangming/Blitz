----
-- 文件名称：SCChatNotifyPacket.lua
-- 功能描述：物品使用
-- 文件说明：物品使用
-- 作    者：田凯
-- 创建时间：2015-9-23
--  修改


--包定义
local SCChatNotifyPacket = class("SCChatNotifyPacket", PacketBase)
SCChatNotifyPacket._PacketID = PacketDefine.PacketDefine_ChatNotify

--构造函数
function SCChatNotifyPacket:ctor()
    self.super.ctor(self)
    self._PacketID = SCChatNotifyPacket._PacketID
end

function SCChatNotifyPacket:init(data)

end

function SCChatNotifyPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function SCChatNotifyPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    local uid = byteStream:readInt() 
    local name = byteStream:readStringUInt() 
    local vip = byteStream:readByte() 
    local headid = byteStream:readInt() 
    local channel = byteStream:readByte()
    local magic = byteStream:readInt()
    local msg = byteStream:readStringUInt()
end
 
function SCChatNotifyPacket:Execute()
    print(self.__cname, self._IntResult) 
end

return  SCChatNotifyPacket