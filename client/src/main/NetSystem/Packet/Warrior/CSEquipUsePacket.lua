----
-- 文件名称：CSEquipUsePacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local CSEquipUsePacket = class("CSEquipUsePacket", PacketBase)
CSEquipUsePacket._PacketID = PacketDefine.PacketDefine_EquipUse_Send
--构造函数

function CSEquipUsePacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSEquipUsePacket._PacketID
end

function CSEquipUsePacket:init(data)
    self._guid = data[1]
    self._equipId = data[2]
end

function CSEquipUsePacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeInt(self._guid)
    self._ContentStream:writeInt(self._equipId)
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSEquipUsePacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
end

--包处理
function CSEquipUsePacket:Execute()
    print(self.__cname, self._IntResult) 
    if self._IntResult == 0 then
        DispatchEvent(GameEvent.GameEvent_UIWarrior_Equip_Take)
    end
end

--不要忘记最后的return
return CSEquipUsePacket