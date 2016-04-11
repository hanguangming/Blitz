----
-- 文件名称：CSMapLoginPacket.lua
-- 功能描述：物品使用
-- 文件说明：物品使用
-- 作    者：田凯
-- 创建时间：2015-9-23
--  修改


--包定义
local CSMapLoginPacket = class("CSMapLoginPacket", PacketBase)
CSMapLoginPacket._PacketID = PacketDefine.PacketDefine_MapLogin_Send

--构造函数
function CSMapLoginPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSMapLoginPacket._PacketID
end

function CSMapLoginPacket:init(data)
    self._id = data[1]
    self._key = data[2]
end

function CSMapLoginPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeInt(gUid)
    self._ContentStream:writeDouble(gSessionKey)
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSMapLoginPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
    gcity = byteStream:readInt() 
    print(gcity)
end

function CSMapLoginPacket:Execute()
    print(self.__cname, self._IntResult) 
    if self._IntResult == 0 then
--        local GuoZhanMapPlayerManager = require("main.Logic.GuoZhanMapPlayerManager")
--        GuoZhanMapPlayerManager._SelfServerID = gUid
--        local player = GuoZhanMapPlayerManager:CreatePlayer(gUid, GetPlayer()._HeadId, true)
--        player:StartMoveFeiXing(gcity)
--        print(gcity)
    end
end

return  CSMapLoginPacket