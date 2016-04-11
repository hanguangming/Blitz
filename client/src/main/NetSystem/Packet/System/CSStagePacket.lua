----
-- 文件名称：CSStagePacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local CSStagePacket = class("CSStagePacket", PacketBase)
CSStagePacket._PacketID = PacketDefine.PacketDefine_Stage_Send
--构造函数

function CSStagePacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSStagePacket._PacketID
end

function CSStagePacket:init(data)
    self._guid = data[1]
end

function CSStagePacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    print(self._guid)
    self._ContentStream:writeInt(self._guid)
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSStagePacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
end

--包处理
function CSStagePacket:Execute()
    print(self.__cname, self._IntResult) 
end

--不要忘记最后的return
return CSStagePacket