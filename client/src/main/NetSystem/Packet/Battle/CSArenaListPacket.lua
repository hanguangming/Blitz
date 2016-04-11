----
-- 文件名称：CSArenaListPacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local CSArenaListPacket = class("CSArenaListPacket", PacketBase)
CSArenaListPacket._PacketID = PacketDefine.PacketDefine_ArenaList_Send
--构造函数

function CSArenaListPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSArenaListPacket._PacketID
end

function CSArenaListPacket:init(data)

end

function CSArenaListPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSArenaListPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    local PlayerDataManager = GameGlobal:GetGamePlayerDataManager()
    PlayerDataManager._ShaChangTop5Info = {}
    self._IntResult = byteStream:readInt()
    GetPlayer()._MyShaChangRank = byteStream:readInt()
    local num = byteStream:readInt()
    for i = 1, num do
        self._id = byteStream:readInt()
        self._index = byteStream:readInt()
        byteStream:readByte()
        self._vip = byteStream:readByte()
        self._headId = byteStream:readInt()
        self._name = byteStream:readStringUInt()
        local player = PlayerDataManager:CreateShaChangOtherData()
        player._WuJiangTableID =  self._id
        player._Name = self._name
        player._Level = 1
        player._HeadId = self._headId
        player._VIPLevel = self._vip
        player._HeadID = self._headId
        player._Rank = self._index
        PlayerDataManager._ShaChangTop5Info[i] = player
    end
   
    PlayerDataManager._OtherShaChangPlayerTable = {}
    
    local num = byteStream:readInt()
    for i = 1, num do
        self._id = byteStream:readInt()
        self._index = byteStream:readInt()
        byteStream:readByte()
        self._vip = byteStream:readByte()
        self._headId = byteStream:readInt()
        self._name = byteStream:readStringUInt()
        local player = PlayerDataManager:CreateShaChangOtherData()
        player._WuJiangTableID =  self._id
        player._Name =  self._name
        player._Level = 1
        player._HeadId = self._headId
        player._VIPLevel = self._vip
        player._Rank = self._index
        PlayerDataManager._OtherShaChangPlayerTable[i] = player
    end
 
end

--包处理
function CSArenaListPacket:Execute()
    print(self.__cname, self._IntResult) 
    if self._IntResult == 0 then
        DispatchEvent(GameEvent.GameEvent_UIShaChang_RefreshPlayer)
    end
end

--不要忘记最后的return
return CSArenaListPacket