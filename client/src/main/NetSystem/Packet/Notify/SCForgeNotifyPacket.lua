----
-- 文件名称：SCForgeNotifyPacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local SCForgeNotifyPacket = class("SCForgeNotifyPacket", PacketBase)
SCForgeNotifyPacket._PacketID = PacketDefine.PacketDefine_ForgeNotify
--构造函数

function SCForgeNotifyPacket:ctor()
    self.super.ctor(self)
    self._PacketID = SCForgeNotifyPacket._PacketID
end

function SCForgeNotifyPacket:init(data)

end

function SCForgeNotifyPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function SCForgeNotifyPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._num = byteStream:readInt()
    local ItemDataManager = GameGlobal:GetItemDataManager()
    if self._num > 0 then
        self._Data = {}
        for i = 1, self._num do
            local euqip = {}
            self._guid = byteStream:readByte()
            self._tableId = byteStream:readInt()
            self._used = byteStream:readByte()
            euqip[1] = self._guid
            euqip[2] = self._tableId
            euqip[3] = self._used
            self._Data[i] = euqip
            GetGlobalData()._SmeltEquip[self._guid + 1] = euqip
        end
    end
end

--包处理
function SCForgeNotifyPacket:Execute()
    print(self.__cname)  
    DispatchEvent(GameEvent.GameEvent_UIEquipSmelt_Succeed)
end

--不要忘记最后的return
return SCForgeNotifyPacket