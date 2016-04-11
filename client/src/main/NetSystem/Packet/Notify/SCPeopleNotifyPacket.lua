----
-- 文件名称：SCPeopleNotifyPacket.lua
-- 功能描述：物品使用
-- 文件说明：物品使用
-- 作    者：田凯
-- 创建时间：2015-9-23
--  修改


--包定义
local SCPeopleNotifyPacket = class("SCPeopleNotifyPacket", PacketBase)
SCPeopleNotifyPacket._PacketID = PacketDefine.PacketDefine_PeopleNotify

--构造函数
function SCPeopleNotifyPacket:ctor()
    self.super.ctor(self)
    self._PacketID = SCPeopleNotifyPacket._PacketID
end

function SCPeopleNotifyPacket:init(data)

end

function SCPeopleNotifyPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function SCPeopleNotifyPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    local people = byteStream:readInt()
    local peopleAll = byteStream:readInt()
    local GuoZhanServerDataManager = GameGlobal:GetGuoZhanServerDataManager()
    GuoZhanServerDataManager._CurrentSoldierCount = people
    GuoZhanServerDataManager._TotalSoldierCount = peopleAll
end

function SCPeopleNotifyPacket:Execute()
    print(self.__cname, self._IntResult) 
    DispatchEvent(GameEvent.GameEvent_GuoZhan_UpdateMap, {type = 2})
end

return  SCPeopleNotifyPacket