----
-- 文件名称：CSShaowPacket.lua
-- 功能描述：物品使用
-- 文件说明：物品使用
-- 作    者：田凯
-- 创建时间：2015-9-23
--  修改


--包定义
local CSShaowPacket = class("CSShaowPacket", PacketBase)
CSShaowPacket._PacketID = PacketDefine.PacketDefine_Shadow_Send

--构造函数
function CSShaowPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSShaowPacket._PacketID
end

function CSShaowPacket:init(data)

end

function CSShaowPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSShaowPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
end

function CSShaowPacket:Execute()
    print(self.__cname, self._IntResult) 
    if self._IntResult == 0 then
        DispatchEvent(GameEvent.GameEvent_GuoZhan_BattlePlayerList)
    end
end

return  CSShaowPacket