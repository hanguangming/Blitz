----
-- 文件名称：SCKickNotifyPacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local SCKickNotifyPacket = class("SCKickNotifyPacket", PacketBase)
SCKickNotifyPacket._PacketID = PacketDefine.PacketDefine_KickNotify
--构造函数

function SCKickNotifyPacket:ctor()
    self.super.ctor(self)
    self._PacketID = SCKickNotifyPacket._PacketID
end

function SCKickNotifyPacket:init(data)
end

function SCKickNotifyPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function SCKickNotifyPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._Count = byteStream:readByte()
end

--包处理
function SCKickNotifyPacket:Execute()
    print(self.__cname)  
end

--不要忘记最后的return
return SCKickNotifyPacket