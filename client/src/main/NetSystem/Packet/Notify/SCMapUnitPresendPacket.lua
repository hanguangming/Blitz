----
-- 文件名称：SCMapUnitPresendPacket.lua
-- 功能描述：物品使用
-- 文件说明：物品使用
-- 作    者：田凯
-- 创建时间：2015-9-23
--  修改


--包定义
local SCMapUnitPresendPacket = class("SCMapUnitPresendPacket", PacketBase)
SCMapUnitPresendPacket._PacketID = PacketDefine.PacketDefine_MapUnitPresendNotify

--构造函数
function SCMapUnitPresendPacket:ctor()
    self.super.ctor(self)
    self._PacketID = SCMapUnitPresendPacket._PacketID
end

function SCMapUnitPresendPacket:init(data)
    self._channel = data[1]
    self._magic = data[2]
    self._msg = data[3]
end

function SCMapUnitPresendPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function SCMapUnitPresendPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._defendsNum = byteStream:readInt()
    local GuoZhanServerDataManager = GameGlobal:GetGuoZhanServerDataManager()

    for i = 1 , self._defendsNum do
        local player = GuoZhanServerDataManager:CreateGuoZhanPlayerData()
        player._Type = byteStream:readByte()
        player._Guid = byteStream:readInt()
        player._PlayerName = byteStream:readStringUInt()
        player._VIPLevel = byteStream:readByte()
        player._Country = byteStream:readByte()
        player._State = byteStream:readByte()
        table.insert(GuoZhanServerDataManager._GuoZhanDefenderPlayerInfoList ,player)
    end
    
    self._attacksNum = byteStream:readInt()
    for i = 1 , self._attacksNum do
        local player = GuoZhanServerDataManager:CreateGuoZhanPlayerData()
        player._Type = byteStream:readByte()
        player._Guid = byteStream:readInt()
        player._PlayerName = byteStream:readStringUInt()
        player._VIPLevel = byteStream:readByte()
        player._Country = byteStream:readByte()
        player._State = byteStream:readByte()
        table.insert(GuoZhanServerDataManager._GuoZhanAttackerPlayerInfoList ,player)
    end
end

function SCMapUnitPresendPacket:Execute()
    print(self.__cname, self._IntResult) 
    if self._IntResult == 0 then
    end
end

return  SCMapUnitPresendPacket