----
-- 文件名称：CSTaskFinishPacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local CSTaskFinishPacket = class("CSTaskFinishPacket", PacketBase)
CSTaskFinishPacket._PacketID = PacketDefine.PacketDefine_TaskFinish_Send
--构造函数

function CSTaskFinishPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSTaskFinishPacket._PacketID
end

function CSTaskFinishPacket:init(data)
    self._guid = data[1]
end

function CSTaskFinishPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeInt(self._guid) 
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSTaskFinishPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
end

--包处理
function CSTaskFinishPacket:Execute()
    print(self.__cname, self._IntResult) 
    if self._IntResult == 0 then
       DispatchEvent(GameEvent.GameEvent_UITask_Succeed)
       DispatchEvent(GameEvent.GameEvent_UITaskUpdate_Succeed)
    end
end

--不要忘记最后的return
return CSTaskFinishPacket