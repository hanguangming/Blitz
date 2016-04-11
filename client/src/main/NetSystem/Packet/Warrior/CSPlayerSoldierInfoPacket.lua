----
-- 文件名称：CSPlayerSoldierInfoPacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local CSPlayerSoldierInfoPacket = class("CSPlayerSoldierInfoPacket", PacketBase)
CSPlayerSoldierInfoPacket._PacketID = PacketDefine.PacketDefine_PlayerSoldierInfo_Send
--构造函数

function CSPlayerSoldierInfoPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSPlayerSoldierInfoPacket._PacketID
end

function CSPlayerSoldierInfoPacket:init(data)
    self._guid = data[1]
end

function CSPlayerSoldierInfoPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeInt(self._guid)
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSPlayerSoldierInfoPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
    local num = byteStream:readInt()
    self.Data = {}
    for i = 1, num do
        local tmp = {}
        tmp[1] = byteStream:readInt()
        tmp[2] = byteStream:readShort()
        self.Data[i] = tmp
    end
end

--包处理
function CSPlayerSoldierInfoPacket:Execute()
    print(self.__cname, self._IntResult) 
    if self._IntResult == 0 then
        DispatchEvent(GameEvent.GameEvent_UIHeroGet_Succeed, self.Data)
    end
end

--不要忘记最后的return
return CSPlayerSoldierInfoPacket