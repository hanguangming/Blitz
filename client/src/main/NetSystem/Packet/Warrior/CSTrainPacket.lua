----
-- 文件名称：CSTrainPacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local CSTrainPacket = class("CSTrainPacket", PacketBase)
CSTrainPacket._PacketID = PacketDefine.PacketDefine_Train_Send
--构造函数

function CSTrainPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSTrainPacket._PacketID
end

function CSTrainPacket:init(data)
    self._guid = data[1]
    self._type = data[2]
end

function CSTrainPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeInt(self._guid)
    self._ContentStream:writeByte(self._type)
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSTrainPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
end

--包处理
function CSTrainPacket:Execute()
    print(self.__cname, self._IntResult)
    if self._IntResult == 0 then 
        DispatchEvent(GameEvent.GameEvent_UITrainSuccess_Update)
    end
end

--不要忘记最后的return
return CSTrainPacket