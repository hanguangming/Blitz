----
-- 文件名称：SCMapPresendNotifyPacket.lua
-- 功能描述：物品使用
-- 文件说明：物品使用
-- 作    者：田凯
-- 创建时间：2015-9-23
--  修改


--包定义
local SCMapPresendNotifyPacket = class("SCMapPresendNotifyPacket", PacketBase)
SCMapPresendNotifyPacket._PacketID = PacketDefine.PacketDefine_MapPresendNotify

--构造函数
function SCMapPresendNotifyPacket:ctor()
    self.super.ctor(self)
    self._PacketID = SCMapPresendNotifyPacket._PacketID
end

function SCMapPresendNotifyPacket:init(data)

end

function SCMapPresendNotifyPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function SCMapPresendNotifyPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    local GuoZhanMapPlayerManager = require("main.Logic.GuoZhanMapPlayerManager")
    self._Num = byteStream:readInt()
    for i = 1 , self._Num do
        local serverID = byteStream:readInt()
        local name = byteStream:readStringUInt()
        local from = byteStream:readInt()
        local to = byteStream:readInt()
        local vip = byteStream:readByte()
        local side = byteStream:readByte()
        local speed = byteStream:readInt()
        local headId = byteStream:readInt()
        local walkPlayer
        if (serverID == gUid) then
            walkPlayer =  GuoZhanMapPlayerManager:GetSelfPlayer()
            if walkPlayer ~= nil then
                if GuoZhanMapPlayerManager._SelfServerID == 0 then
                    GuoZhanMapPlayerManager._AllPlayerTable[0] = nil
                    GuoZhanMapPlayerManager._SelfServerID = serverID
                    walkPlayer._PlayerServerID = serverID
                    GuoZhanMapPlayerManager._AllPlayerTable[serverID] = walkPlayer
                end
            else
                walkPlayer =  GuoZhanMapPlayerManager:GetPlayerByServerID(serverID)     
            end
        else
            walkPlayer =  GuoZhanMapPlayerManager:GetPlayerByServerID(serverID)
        end

        if walkPlayer == nil then
            walkPlayer =  GuoZhanMapPlayerManager:GetPlayerByServerID(serverID)
            local isSelf = (serverID == gUid)
            walkPlayer = GuoZhanMapPlayerManager:CreatePlayer(serverID, headId, isSelf)
        end
        self._PlayerServerID = serverID
        walkPlayer:StartMove(from, to)
    end
end

function SCMapPresendNotifyPacket:Execute()
    print(self.__cname, self._IntResult) 
    if self._IntResult == 0 then
        if self._PlayerServerID ~= 0 then
            local GuoZhanMapPlayerManager = require("main.Logic.GuoZhanMapPlayerManager")
            DispatchEvent(GameEvent.GameEvent_UIWorldMap_ShowPlayer,{serverID = self._PlayerServerID})
        end
    end
end

return  SCMapPresendNotifyPacket