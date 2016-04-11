----
-- 文件名称：CSArenaAwardPacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local CSArenaAwardPacket = class("CSArenaAwardPacket", PacketBase)
CSArenaAwardPacket._PacketID = PacketDefine.PacketDefine_ArenaAward_Send
--构造函数

function CSArenaAwardPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSArenaAwardPacket._PacketID
end

function CSArenaAwardPacket:init(data)

end

function CSArenaAwardPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSArenaAwardPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()

end

--包处理
function CSArenaAwardPacket:Execute()
    print(self.__cname, self._IntResult) 
    
end

--不要忘记最后的return
return CSArenaAwardPacket