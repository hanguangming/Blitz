----
-- 文件名称：CSStoreBuyPacket.lua
-- 功能描述：商城购买
-- 文件说明：商城购买
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改


--包定义
local CSStoreBuyPacket = class("CSStoreBuyPacket", PacketBase)
CSStoreBuyPacket._PacketID = PacketDefine.PacketDefine_ShopBuy_Send

--构造函数
function CSStoreBuyPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSStoreBuyPacket._PacketID
end

function CSStoreBuyPacket:init(data)
    self._Id = data[1]
    self._Num = data[2]
    self._ShopId = data[3]
end

function CSStoreBuyPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    print(self._Id)
    self._ContentStream:writeInt(self._Id)
    self._ContentStream:writeInt(self._ShopId)
    self._ContentStream:writeInt(self._Num)
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSStoreBuyPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
end

function CSStoreBuyPacket:Execute()
    print("CSStoreBuyPacket enter execute"..self._IntResult)
    if self._IntResult == 0 then
        DispatchEvent(GameEvent.GameEvent_UIAdvanced_Buy)
        DispatchEvent(GameEvent.GameEvent_UITrain_UpdateItemNum)
        DispatchEvent(GameEvent.GameEvent_UIStoreBuy_Succeed)
        DispatchEvent(GameEvent.GameEvent_GameEvent_UIEquip_Buy)
        DispatchEvent(GameEvent.GameEvent_UIWarriorStoreBuy_Update)
    end
end

--不要忘记最后的return
return CSStoreBuyPacket