----
-- 文件名称：SCMoveNoitfyPacket.lua
-- 功能描述：物品使用
-- 文件说明：物品使用
-- 作    者：田凯
-- 创建时间：2015-9-23
--  修改


--包定义
local SCMoveNoitfyPacket = class("SCMoveNoitfyPacket", PacketBase)
SCMoveNoitfyPacket._PacketID = PacketDefine.PacketDefine_MoveNotify

--构造函数
function SCMoveNoitfyPacket:ctor()
    self.super.ctor(self)
    self._PacketID = SCMoveNoitfyPacket._PacketID
end

function SCMoveNoitfyPacket:init(data)

end

function SCMoveNoitfyPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function SCMoveNoitfyPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    local serverID = byteStream:readInt()
    local name = byteStream:readStringUInt()
    local from = byteStream:readInt()
    local to = byteStream:readInt()
    local vip = byteStream:readByte()
    local side = byteStream:readByte()
    local speed = byteStream:readInt()
    local headId = byteStream:readInt()
    local GuoZhanMapPlayerManager = require("main.Logic.GuoZhanMapPlayerManager")
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
        gcity = to
    else
        walkPlayer =  GuoZhanMapPlayerManager:GetPlayerByServerID(serverID)
    end
    
    if walkPlayer == nil then
         walkPlayer =  GuoZhanMapPlayerManager:GetPlayerByServerID(serverID)
        local isSelf = (serverID == gUid)
        walkPlayer = GuoZhanMapPlayerManager:CreatePlayer(serverID, headId, isSelf)
    end
   
    self._PlayerServerID = serverID
    --GameGlobal:GetUISystem():GetUIInstance(UIType.UIType_WorldMap):updatePlayerListener({guid = serverID, headId = headId, city = from})
    DispatchEvent(GameEvent.GameEvent_UIMap_Add_Player, {guid = serverID, headId = headId, city = from})
    DispatchEvent(GameEvent.GameEvent_UIMap_Move, {from = from, to = to, guid = serverID, isSelf = (serverID == gUid)})
    --walkPlayer:StartMove(from, to)
end

function SCMoveNoitfyPacket:Execute()
    print(self.__cname, self._IntResult) 
    --DispatchEvent(GameEvent.GameEvent_UIWorldMap_ShowPlayer,{serverID = self._PlayerServerID})
end

return  SCMoveNoitfyPacket