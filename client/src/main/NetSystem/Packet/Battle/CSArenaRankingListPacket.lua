----
-- 文件名称：CSArenaRankingListPacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local CSArenaRankingListPacket = class("CSArenaRankingListPacket", PacketBase)
CSArenaRankingListPacket._PacketID = PacketDefine.PacketDefine_AppeaRankingList_Send
--构造函数

function CSArenaRankingListPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSArenaRankingListPacket._PacketID
end

function CSArenaRankingListPacket:init(data)

end

function CSArenaRankingListPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSArenaRankingListPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
   
    local num = byteStream:readInt()
    for i = 1, num do
        local data = GameGlobal:GetBattleServerDataManager():CreateShaChangRankData()
        data._id = byteStream:readInt()
        data._Rank = byteStream:readInt()
        data._Country = byteStream:readByte()
        data._VIP = byteStream:readByte()
        data._headId = byteStream:readInt()
        data._Level = byteStream:readShort()
        data._Name = byteStream:readStringUInt()
        data._BattleValue = byteStream:readInt()
        GameGlobal:GetBattleServerDataManager()._ShaChangRankData[i] = data
    end
end

--包处理
function CSArenaRankingListPacket:Execute()
    print(self.__cname, self._IntResult) 
    if self._IntResult == 0 then
        DispatchEvent(GameEvent.GameEvent_UIShaChangRank_RefreshRank)
    end
end

--不要忘记最后的return
return CSArenaRankingListPacket