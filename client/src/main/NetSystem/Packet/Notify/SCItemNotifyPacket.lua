----
-- 文件名称：SCItemNotifyPacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local SCItemNotifyPacket = class("SCItemNotifyPacket", PacketBase)
SCItemNotifyPacket._PacketID = PacketDefine.PacketDefine_ItemNotify
--构造函数

function SCItemNotifyPacket:ctor()
    self.super.ctor(self)
    self._PacketID = SCItemNotifyPacket._PacketID
    self._Uid = 0
    self._SessionKey = 0
end

function SCItemNotifyPacket:init(data)
     self._id = data[1]
     self._type = data[2]
     self._count = data[3]
     self._used = data[4]
end
    
function SCItemNotifyPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeInt(self._objData[1])
    self._ContentStream:writeDouble(self._objData[2])
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function SCItemNotifyPacket:Read(byteStream) 
    self.super.Read(self, byteStream)
    self._Size = byteStream:readInt()
    local ItemDataManager = GameGlobal:GetItemDataManager()
    if self._Size > 0 then
        for i = 1, self._Size do
            self._guid = byteStream:readInt()
            self._tableId = byteStream:readInt()
            self._count = byteStream:readInt()
            self._used = byteStream:readByte()
            self._level = byteStream:readInt()
            if self._count == 0 then
                ItemDataManager:DeleteItem(self._guid)
            else
                local newItem = ItemDataManager:CreateItem(self._guid)
                newItem._ItemTableID = self._tableId
                newItem._CurrentItemCount = self._count
                newItem._ItemEquipLevel = self._level
                newItem._ItemTableData = self._used
                newItem:setData()
            end
        end
    end
end

--包处理
function SCItemNotifyPacket:Execute()
    print(self.__cname)  
    DispatchEvent(GameEvent.GameEvent_UIStore_Succeed)
end

--不要忘记最后的return
return SCItemNotifyPacket