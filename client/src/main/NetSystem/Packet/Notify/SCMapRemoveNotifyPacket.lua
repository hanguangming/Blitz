----
-- 文件名称：SCMapRemoveNotifyPacket.lua
-- 功能描述：物品使用
-- 文件说明：物品使用
-- 作    者：田凯
-- 创建时间：2015-9-23
--  修改


--包定义
local SCMapRemoveNotifyPacket = class("SCMapRemoveNotifyPacket", PacketBase)
SCMapRemoveNotifyPacket._PacketID = PacketDefine.PacketDefine_MapRemoveNotify

--构造函数
function SCMapRemoveNotifyPacket:ctor()
    self.super.ctor(self)
    self._PacketID = SCMapRemoveNotifyPacket._PacketID
end

function SCMapRemoveNotifyPacket:init(data)

end

function SCMapRemoveNotifyPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function SCMapRemoveNotifyPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._guid = byteStream:readInt()
end

function SCMapRemoveNotifyPacket:Execute()
    print(self.__cname, self._guid) 
    if self._guid ~= gUid then
        local GuoZhanMapPlayerManager = require("main.Logic.GuoZhanMapPlayerManager")
        GuoZhanMapPlayerManager:DestroyPlayerByServerID(self._guid)
    end
end

return  SCMapRemoveNotifyPacket