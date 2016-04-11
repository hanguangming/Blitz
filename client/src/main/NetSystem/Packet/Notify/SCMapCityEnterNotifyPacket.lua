
----
-- 文件名称：SCMapCityEnterNotifyPacket.lua
-- 功能描述：物品使用
-- 文件说明：物品使用
-- 作    者：田凯
-- 创建时间：2015-9-23
--  修改


--包定义
local SCMapCityEnterNotifyPacket = class("SCMapCityEnterNotifyPacket", PacketBase)
SCMapCityEnterNotifyPacket._PacketID = PacketDefine.PacketDefine_MapCityEnterNotify

--构造函数
function SCMapCityEnterNotifyPacket:ctor()
    self.super.ctor(self)
    self._PacketID = SCMapCityEnterNotifyPacket._PacketID
end

function SCMapCityEnterNotifyPacket:init(data)
end

function SCMapCityEnterNotifyPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function SCMapCityEnterNotifyPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._enterCity = byteStream:readInt() 
end

function SCMapCityEnterNotifyPacket:Execute()
    print(self.__cname, self._enterCity) 
    DispatchEvent(GameEvent.GameEvent_UIMap_Move_City, self._enterCity)
end

return  SCMapCityEnterNotifyPacket