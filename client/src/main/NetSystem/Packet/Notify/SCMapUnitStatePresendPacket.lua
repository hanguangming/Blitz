----
-- 文件名称：SCMapUnitStatePresendPacket.lua
-- 功能描述：物品使用
-- 文件说明：物品使用
-- 作    者：田凯
-- 创建时间：2015-9-23
--  修改


--包定义
local SCMapUnitStatePresendPacket = class("SCMapUnitStatePresendPacket", PacketBase)
SCMapUnitStatePresendPacket._PacketID = PacketDefine.PacketDefine_MapUnitStateNotify

local G_MAP_UNIT_STATE_WAIT = 0
local G_MAP_UNIT_STATE_FIGHT = 1
local G_MAP_UNIT_STATE_REMOVED = 2
        
--构造函数
function SCMapUnitStatePresendPacket:ctor()
    self.super.ctor(self)
    self._PacketID = SCMapUnitStatePresendPacket._PacketID
end

function SCMapUnitStatePresendPacket:init(data)

end

function SCMapUnitStatePresendPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function SCMapUnitStatePresendPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._Num = byteStream:readInt()
    local GuoZhanServerDataManager = GameGlobal:GetGuoZhanServerDataManager()
    for i = 1 , self._Num do 
        local type = byteStream:readByte()
        local guid =byteStream:readInt()
        local state = byteStream:readByte()
        if state == 2 then
            GuoZhanServerDataManager:DeleteGuoZhanPlayerData(guid)
        else
            GuoZhanServerDataManager:UpdateGuoZhanPlayerData(guid, state)
        end
    end
end

function SCMapUnitStatePresendPacket:Execute()
    print(self.__cname, self._IntResult) 
    DispatchEvent(GameEvent.GameEvent_GuoZhan_BattlePlayerList)
end

return  SCMapUnitStatePresendPacket