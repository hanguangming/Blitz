----
-- 文件名称：CSUserItemPacket.lua
-- 功能描述：物品使用
-- 文件说明：物品使用
-- 作    者：田凯
-- 创建时间：2015-9-23
--  修改


--包定义
local CSUserItemPacket = class("CSUserItemPacket", PacketBase)
CSUserItemPacket._PacketID = PacketDefine.PacketDefine_UseItem_Send

--构造函数
function CSUserItemPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSUserItemPacket._PacketID
end

function CSUserItemPacket:init(data)
    self._id = data[1]
    self._num = data[2]
end

function CSUserItemPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    print(self._id)
    print(self._num)
    self._ContentStream:writeInt(self._id)
    self._ContentStream:writeInt(self._num)
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSUserItemPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
end

function CSUserItemPacket:Execute()
    print(self.__cname, self._IntResult) 
    if self._IntResult == 0 then
        DispatchEvent(GameEvent.GameEvent_UIBag_Succeed)
    end
end

--不要忘记最后的return
return CSUserItemPacket