----
-- 文件名称：CSTrainCancelPacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local CSTrainCancelPacket = class("CSTrainCancelPacket", PacketBase)
CSTrainCancelPacket._PacketID = PacketDefine.PacketDefine_TrainCancel_Send
--构造函数

function CSTrainCancelPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSTrainCancelPacket._PacketID
end

function CSTrainCancelPacket:init(data)
    self._guid = data[1]
end

function CSTrainCancelPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeInt(self._guid)
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSTrainCancelPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
end

--包处理
function CSTrainCancelPacket:Execute()
    print(self.__cname, self._IntResult)
    if self._IntResult == 0 then
        DispatchEvent(GameEvent.GameEvent_UITrain_Update, GetGlobalData()._CurWarriorId)
    end
end

--不要忘记最后的return
return CSTrainCancelPacket