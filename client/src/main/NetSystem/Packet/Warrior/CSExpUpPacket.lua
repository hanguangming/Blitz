----
-- 文件名称：CSExpUpPacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local CSExpUpPacket = class("CSExpUpPacket", PacketBase)
CSExpUpPacket._PacketID = PacketDefine.PacketDefine_ExpUp_Send
--构造函数

function CSExpUpPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSExpUpPacket._PacketID
end

function CSExpUpPacket:init(data)
    self._guid = data[1]
    self._count = data[2]
end

function CSExpUpPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeInt(self._guid)
    self._ContentStream:writeInt(self._count)
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSExpUpPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
end

--包处理
function CSExpUpPacket:Execute()
    print(self.__cname, self._IntResult) 
    if self._IntResult == 0 then
        DispatchEvent(GameEvent.GameEvent_UITrain_Update, GetGlobalData()._CurWarriorId)
    end
end

--不要忘记最后的return
return CSExpUpPacket