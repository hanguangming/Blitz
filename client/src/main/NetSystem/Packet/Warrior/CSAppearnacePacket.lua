----
-- 文件名称：CSAppearnacePacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local CSAppearnacePacket = class("CSAppearnacePacket", PacketBase)
CSAppearnacePacket._PacketID = PacketDefine.PacketDefine_Appearnace_Send
--构造函数

function CSAppearnacePacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSAppearnacePacket._PacketID
end

function CSAppearnacePacket:init(data)
    self._tableId = data[1]
end

function CSAppearnacePacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeInt(self._tableId)
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSAppearnacePacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
    local GuoZhanMapPlayerManager = require("main.Logic.GuoZhanMapPlayerManager")
    GuoZhanMapPlayerManager._SelfServerID = gUid
    local player = GuoZhanMapPlayerManager:CreatePlayer(gUid, GetPlayer()._HeadId, true)
--    player:StartMoveFeiXing(gcity)
end

--包处理
function CSAppearnacePacket:Execute()
    print(self.__cname, self._IntResult) 
end

--不要忘记最后的return
return CSAppearnacePacket