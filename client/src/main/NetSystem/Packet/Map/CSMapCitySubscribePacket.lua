----
-- 文件名称：CSMapCitySubscribePacket.lua
-- 功能描述：物品使用
-- 文件说明：物品使用
-- 作    者：田凯
-- 创建时间：2015-9-23
--  修改


--包定义
local CSMapCitySubscribePacket = class("CSMapCitySubscribePacket", PacketBase)
CSMapCitySubscribePacket._PacketID = PacketDefine.PacketDefine_MapCitySubscribe_Send

--构造函数
function CSMapCitySubscribePacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSMapCitySubscribePacket._PacketID
end

function CSMapCitySubscribePacket:init(data)
    self._city = data[1]
end

function CSMapCitySubscribePacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeInt(self._city)
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSMapCitySubscribePacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
end

function CSMapCitySubscribePacket:Execute()
    print(self.__cname, self._IntResult) 
    if self._IntResult == 0 and self._city > 0 then
        DispatchEvent(GameEvent.GameEvent_GuoZhan_BattlePlayerList)
    end
end

return  CSMapCitySubscribePacket