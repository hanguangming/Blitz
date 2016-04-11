----
-- 文件名称：CSHeroUsePacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local CSHeroUsePacket = class("CSHeroUsePacket", PacketBase)
CSHeroUsePacket._PacketID = PacketDefine.PacketDefine_HeroUse_Send
--构造函数

function CSHeroUsePacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSHeroUsePacket._PacketID
end

function CSHeroUsePacket:init(data)
    self._guid = data[1]
    self._use = data[2]
end

function CSHeroUsePacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeInt(self._guid)
    self._ContentStream:writeByte(self._use)  
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSHeroUsePacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
end

--包处理
function CSHeroUsePacket:Execute()
    if self._IntResult == 0 then
        print(self.__cname, self._IntResult) 
    end
end

--不要忘记最后的return
return CSHeroUsePacket