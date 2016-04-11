
----
-- 文件名称：CSSellItemPacket.lua
-- 功能描述：物品使用
-- 文件说明：物品使用
-- 作    者：田凯
-- 创建时间：2015-9-23
--  修改


--包定义
local CSSellItemPacket = class("CSSellItemPacket", PacketBase)
CSSellItemPacket._PacketID = PacketDefine.PacketDefine_SellItem_Send

--构造函数
function CSSellItemPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSSellItemPacket._PacketID
end

function CSSellItemPacket:init(data)
    self._id = data[1]
end

function CSSellItemPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    print(self._id)
    print(self._num)
    self._ContentStream:writeInt(self._id)
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSSellItemPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
end

function CSSellItemPacket:Execute()
    print(self.__cname, self._IntResult) 
    if self._IntResult == 0 then
        DispatchEvent(GameEvent.GameEvent_UIBag_Succeed)
    end
end

--不要忘记最后的return
return CSSellItemPacket