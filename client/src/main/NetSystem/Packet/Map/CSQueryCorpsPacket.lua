----
-- 文件名称：CSQueryCorpsPacket.lua
-- 功能描述：物品使用
-- 文件说明：物品使用
-- 作    者：田凯
-- 创建时间：2015-9-23
--  修改


--包定义
local CSQueryCorpsPacket = class("CSQueryCorpsPacket", PacketBase)
CSQueryCorpsPacket._PacketID = PacketDefine.PacketDefine_QueryCorps_Send

--构造函数
function CSQueryCorpsPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSQueryCorpsPacket._PacketID
end

function CSQueryCorpsPacket:init(data)

end

function CSQueryCorpsPacket:Write()
    self:WritePacketContentID()
    --包的其它字段

    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSQueryCorpsPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
    self._uid = byteStream:readInt()
    self._vip = byteStream:readInt()
    self._name = byteStream:readStringUInt()
    self._num = byteStream:readInt()
    for i = 1, self._num do
        self._hero_id = byteStream:readInt()
        self._hero_attack = byteStream:readInt()
        self._hero_attack_speed = byteStream:readInt()
        self._hero_hp_max = byteStream:readInt()
        self._hero_hp = byteStream:readInt()

        self._soldier_id = byteStream:readInt()
        self._soldier_attack = byteStream:readInt()
        self._soldier_attack_speed = byteStream:readInt()
        self._soldier_hp = byteStream:readInt()
        self._soldier_num = byteStream:readByte()

        self._soldier_x = byteStream:readInt()
        self._soldier_y = byteStream:readInt()
    end
end

function CSQueryCorpsPacket:Execute()
    print(self.__cname, self._IntResult) 
    if self._IntResult == 0 then
        if self._num > 0 then
        end
    end
end

return  CSQueryCorpsPacket