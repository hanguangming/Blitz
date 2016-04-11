----
-- 文件名称：CSMapMovePacket.lua
-- 功能描述：物品使用
-- 文件说明：物品使用
-- 作    者：田凯
-- 创建时间：2015-9-23
--  修改


--包定义
local CSMapMovePacket = class("CSMapMovePacket", PacketBase)
CSMapMovePacket._PacketID = PacketDefine.PacketDefine_MapMove_Send

--构造函数
function CSMapMovePacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSMapMovePacket._PacketID
end

function CSMapMovePacket:init(data)
    self._type = data[1]
    self._path = data[2]
end

function CSMapMovePacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeByte(self._type)
    self._ContentStream:writeInt(#self._path)
    for i = 1, #self._path do
        self._ContentStream:writeInt(self._path[i])
    end
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSMapMovePacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
end

function CSMapMovePacket:Execute()
    print(self.__cname, self._IntResult) 
    if self._IntResult == 0 then
    end
end

return  CSMapMovePacket