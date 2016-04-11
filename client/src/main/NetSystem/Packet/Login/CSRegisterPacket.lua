----
-- 文件名称：CSRegisterPacket.lua
-- 功能描述：注册包
-- 文件说明：注册包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改


--包定义
local CSRegisterPacket = class("CSRegisterPacket", PacketBase)
CSRegisterPacket._PacketID = PacketDefine.PacketDefine_Register_Send

--构造函数
function CSRegisterPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSRegisterPacket._PacketID
    --用户名
    self._UserName = ""
    --密码
    self._Password = ""
    --平台
    self._Platform = 0
end

function CSRegisterPacket:init(data)
    self._UserName = data[1]
    self._Password = data[2]
    self._Platform = data[3]
end

function CSRegisterPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeStringUInt(self._UserName)
    self._ContentStream:writeStringUInt(self._Password)
    self._ContentStream:writeInt(self._Platform)
    self._ContentStream:writeStringUInt(g_PlayerName)
    self._ContentStream:writeByte(g_CountryID - 1)
        
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSRegisterPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
end

function CSRegisterPacket:Execute()
    print(self.__cname, self._IntResult) 
    if self._IntResult == 0 then
        SaveDate("username", self._UserName, 4)
        SaveDate("password", self._Password, 4)
        local data = {self._UserName, self._Password, "qzone", "pf3366", 4}
        SendLoginMsg(PacketDefine.PacketDefine_Login_Send, data)
    end
end

--不要忘记最后的return
return CSRegisterPacket