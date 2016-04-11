----
-- 文件名称：CSRechargePacket.lua
-- 功能描述：充值
-- 文件说明：充值
-- 作    者：田凯
-- 创建时间：2015-9-23
--  修改


--包定义
local CSRechargePacket = class("CSRechargePacket", PacketBase)
CSRechargePacket._PacketID = PacketDefine.PacketDefine_Recharge_Send

--构造函数
function CSRechargePacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSRechargePacket._PacketID
end

function CSRechargePacket:init(data)
    self._id = data[1]
end

function CSRechargePacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeByte(self._id)
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSRechargePacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
end

function CSRechargePacket:Execute()
    print(self.__cname, self._IntResult) 
    
end

--不要忘记最后的return
return CSRechargePacket