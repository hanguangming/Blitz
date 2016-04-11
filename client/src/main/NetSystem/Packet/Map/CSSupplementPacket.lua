----
-- 文件名称：CSSupplementPacket.lua
-- 功能描述：物品使用
-- 文件说明：物品使用
-- 作    者：田凯
-- 创建时间：2015-9-23
--  修改


--包定义
local CSSupplementPacket = class("CSSupplementPacket", PacketBase)
CSSupplementPacket._PacketID = PacketDefine.PacketDefine_Supplement_Send

--构造函数
function CSSupplementPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSSupplementPacket._PacketID
end

function CSSupplementPacket:init(data)

end

function CSSupplementPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSSupplementPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
    self._people = byteStream:readInt()
end

function CSSupplementPacket:Execute()
    print(self.__cname, self._IntResult) 
    if self._IntResult == 0 then
        local GuoZhanServerDataManager = GameGlobal:GetGuoZhanServerDataManager()
        GuoZhanServerDataManager._CurrentSoldierCount = self._people
        GuoZhanServerDataManager._TotalSoldierCount = self._people
        DispatchEvent(GameEvent.GameEvent_GuoZhan_UpdateMap, {type = 1})
    end
end

return  CSSupplementPacket