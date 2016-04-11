----
-- 文件名称：CSScoreRankingListPacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local CSScoreRankingListPacket = class("CSScoreRankingListPacket", PacketBase)
CSScoreRankingListPacket._PacketID = PacketDefine.PacketDefine_ScoreRankingList_Send
--构造函数

function CSScoreRankingListPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSScoreRankingListPacket._PacketID
end

function CSScoreRankingListPacket:init(data)
    self._guid = data[1]
    self._count = data[2]
end

function CSScoreRankingListPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeShort(self._guid)
    self._ContentStream:writeShort(self._count)
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSScoreRankingListPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
    self._SelfIndex = byteStream:readInt()
    self._Data = {}
    self._Data[0] = self._SelfIndex
    local num = byteStream:readInt()
    for i = 1, num do
        local data = {}
        data[1] = byteStream:readInt()
        data[7] = byteStream:readByte()
        data[2] = byteStream:readByte()
        data[5] = byteStream:readInt()
        data[3] = byteStream:readStringUInt()
        data[4] = byteStream:readInt()
        self._Data[i] = data
    end
end

--包处理
function CSScoreRankingListPacket:Execute()
    print(self.__cname, self._IntResult) 
    if self._IntResult == 0 then
        DispatchEvent(GameEvent.GameEvent_UIHeroTop_Open, self._Data)
    end
end

--不要忘记最后的return
return CSScoreRankingListPacket