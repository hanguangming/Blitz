----
-- 文件名称：CSSoldierRankingListPacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local CSSoldierRankingListPacket = class("CSSoldierRankingListPacket", PacketBase)
CSSoldierRankingListPacket._PacketID = PacketDefine.PacketDefine_SoldierRankingList_Send
--构造函数

function CSSoldierRankingListPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSSoldierRankingListPacket._PacketID
end

function CSSoldierRankingListPacket:init(data)
    self._start = data[1]
    self._end = data[2]
end

function CSSoldierRankingListPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeShort(self._start)
    self._ContentStream:writeShort(self._end)
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSSoldierRankingListPacket:Read(byteStream)
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
        local tmp = {}
        for j = 1, data[4] do
            tmp[j] = byteStream:readShort()
        end
        data[6] = tmp
        self._Data[i] = data
    end
end

--包处理
function CSSoldierRankingListPacket:Execute()
    print(self.__cname, self._IntResult) 
    if self._IntResult == 0 then
        DispatchEvent(GameEvent.GameEvent_UIHeroTop_Open, self._Data)
    end
end

--不要忘记最后的return
return CSSoldierRankingListPacket