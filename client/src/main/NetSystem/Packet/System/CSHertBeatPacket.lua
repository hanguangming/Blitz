----
-- 文件名称：CSHertBeatPacket.lua
-- 功能描述：物品使用
-- 文件说明：物品使用
-- 作    者：田凯
-- 创建时间：2015-9-23
--  修改


--包定义
local CSHertBeatPacket = class("CSHertBeatPacket", PacketBase)
CSHertBeatPacket._PacketID = PacketDefine.PacketDefine_HeartBeat_Send

--构造函数
function CSHertBeatPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSHertBeatPacket._PacketID
end

function CSHertBeatPacket:init(data)

end

function CSHertBeatPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSHertBeatPacket:Read(byteStream)
    self.super.Read(self, byteStream)
end

function CSHertBeatPacket:Execute()
    print(self.__cname, self._IntResult) 
    if self._IntResult == 0 then
    end
end

return  CSHertBeatPacket