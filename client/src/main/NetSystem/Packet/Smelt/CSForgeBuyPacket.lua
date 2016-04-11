----
-- 文件名称：CSForgeBuyPacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local CSForgeBuyPacket = class("CSForgeBuyPacket", PacketBase)
CSForgeBuyPacket._PacketID = PacketDefine.PacketDefine_ForgeBuy_Send
--构造函数

function CSForgeBuyPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSForgeBuyPacket._PacketID
end

function CSForgeBuyPacket:init(data)
    self._Index = data[1]
end

function CSForgeBuyPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeByte(self._Index)
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSForgeBuyPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
   
end

--包处理
function CSForgeBuyPacket:Execute()
    print(self.__cname, self._IntResult) 
    DispatchEvent(GameEvent.GameEvent_GameEvent_UIEquip_Buy)
end

--不要忘记最后的return
return CSForgeBuyPacket