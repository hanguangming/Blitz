
----
-- 文件名称：SCSystemMessageNotifypacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local SCSystemMessageNotifypacket = class("SCSystemMessageNotifypacket", PacketBase)
SCSystemMessageNotifypacket._PacketID = PacketDefine.PacketDefine_SystemMessageNotify
--构造函数

function SCSystemMessageNotifypacket:ctor()
    self.super.ctor(self)
    self._PacketID = SCSystemMessageNotifypacket._PacketID
end

function SCSystemMessageNotifypacket:init(data)
end

function SCSystemMessageNotifypacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function SCSystemMessageNotifypacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._Data ={}
    self._msgId = byteStream:readByte()
    self._guid = byteStream:readInt()
    self._name = byteStream:readStringUInt()
    self._vip = byteStream:readByte()
    self._headID = byteStream:readInt()
    local num = byteStream:readInt()
    for i = 1, num do
        byteStream:readInt()
    end
    self._Data["guid"] = self._msgId
    self._Data["vip"] = self._vip
    self._Data["uid"] = self._guid
    self._Data["id"] = self._headID
    self._Data["name"] = self._name
    table.insert(GetGlobalData()._BroadData, self._Data)
end

--包处理
function SCSystemMessageNotifypacket:Execute()
    print(self.__cname)  
    --showBroad(self._Data)
end

--不要忘记最后的return
return SCSystemMessageNotifypacket