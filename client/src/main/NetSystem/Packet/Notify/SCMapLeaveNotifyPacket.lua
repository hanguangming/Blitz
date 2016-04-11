----
-- 文件名称：SCMapCityLeaveNotifyPacket.lua
-- 功能描述：物品使用
-- 文件说明：物品使用
-- 作    者：田凯
-- 创建时间：2015-9-23
--  修改


--包定义
local SCMapCityLeaveNotifyPacket = class("SCMapCityLeaveNotifyPacket", PacketBase)
SCMapCityLeaveNotifyPacket._PacketID = PacketDefine.PacketDefine_MapCityLeaveNotify

--构造函数
function SCMapCityLeaveNotifyPacket:ctor()
    self.super.ctor(self)
    self._PacketID = SCMapCityLeaveNotifyPacket._PacketID
end

function SCMapCityLeaveNotifyPacket:init(data)
    self._id = data[1]
    self._key = data[2]
end

function SCMapCityLeaveNotifyPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function SCMapCityLeaveNotifyPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._LeaveCity = byteStream:readInt() 
end

function SCMapCityLeaveNotifyPacket:Execute()
    print(self.__cname, self._IntResult) 
   
end

return  SCMapCityLeaveNotifyPacket