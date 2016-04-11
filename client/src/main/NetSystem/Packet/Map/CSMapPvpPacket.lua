----
-- 文件名称：CSShaowPacket.lua
-- 功能描述：物品使用
-- 文件说明：物品使用
-- 作    者：田凯
-- 创建时间：2015-9-23
--  修改


--包定义
local CSMapPvpPacket = class("CSMapPvpPacket", PacketBase)
CSMapPvpPacket._PacketID = PacketDefine.PacketDefine_MapPvp_Send

--构造函数
function CSMapPvpPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSMapPvpPacket._PacketID
end

function CSMapPvpPacket:init(data)

end

function CSMapPvpPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSMapPvpPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
end

function CSMapPvpPacket:Execute()
    print(self.__cname, self._IntResult) 
    if self._IntResult == 0 then
    end
end

return  CSMapPvpPacket