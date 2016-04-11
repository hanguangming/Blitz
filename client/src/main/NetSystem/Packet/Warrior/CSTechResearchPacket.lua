----
-- 文件名称：CSTechResearchPacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local CSTechResearchPacket = class("CSTechResearchPacket", PacketBase)
CSTechResearchPacket._PacketID = PacketDefine.PacketDefine_TechResearch_Send
--构造函数

function CSTechResearchPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSTechResearchPacket._PacketID
end

function CSTechResearchPacket:init(data)
    self._guid = data[1]
end

function CSTechResearchPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeInt(self._guid)
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSTechResearchPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
end

--包处理
function CSTechResearchPacket:Execute()
    print(self.__cname, self._IntResult) 
    if self._IntResult == 0 then
        DispatchEvent(GameEvent.GameEvent_UITechnology_Open)
    end
end

--不要忘记最后的return
return CSTechResearchPacket