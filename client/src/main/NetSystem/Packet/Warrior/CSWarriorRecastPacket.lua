----
-- 文件名称：CSWarriorRecastPacket.lua
-- 功能描述：充值
-- 文件说明：充值
-- 作    者：田凯
-- 创建时间：2015-9-23
--  修改


--包定义
local CSWarriorRecastPacket = class("CSWarriorRecastPacket", PacketBase)
CSWarriorRecastPacket._PacketID = PacketDefine.PacketDefine_WarriorRecast_Send

--构造函数
function CSWarriorRecastPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSWarriorRecastPacket._PacketID
end

function CSWarriorRecastPacket:init(data)
    self._id = data[1]
    self._ids = data[2]
end

function CSWarriorRecastPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeInt(self._id)
    self._ContentStream:writeInt(5)
    for i = 1, 5 do
        self._ContentStream:writeInt(self._ids[i])
    end
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSWarriorRecastPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
end

function CSWarriorRecastPacket:Execute()
    print(self.__cname, self._IntResult) 
    if self._IntResult == 0 then
        DispatchEvent(GameEvent.GameEvent_UIEquipStreng_Succeed)
        DispatchEvent(GameEvent.GameEvent_UIEquipRecast_Succeed)
    end
end

--不要忘记最后的return
return CSWarriorRecastPacket