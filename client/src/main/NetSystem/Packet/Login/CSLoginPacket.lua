----
-- 文件名称：CSLoginPacket.lua
-- 功能描述：登录测试包
-- 文件说明：登录测试包
-- 作    者：王雷雷
-- 创建时间：2015-5-23
--  修改
 
--包定义
local CSLoginPacket = class("CSLoginPacket", PacketBase)
CSLoginPacket._PacketID = PacketDefine.PacketDefine_Login_Send

--构造函数
function CSLoginPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSLoginPacket._PacketID
    
    self._StrOpenID = ""
    self._StrOpenKey = ""
    self._StrPf = ""
    self._StrPfKey = ""
    self._ServerID = 0
end

function CSLoginPacket:init(data)
    self._StrOpenID = data[1]
    self._StrOpenKey = data[2]
    self._StrPf = data[3]
    self._StrPfKey = data[4]
    self._ServerID = data[5]
end

--发送数据包,需要重写Write,顺序必须同页游一致,一定要仔细
function CSLoginPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeStringUInt(self._StrOpenID)
    self._ContentStream:writeStringUInt(self._StrOpenKey)
    print(self._StrOpenID, self._StrOpenKey)
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

--读包
function CSLoginPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
    if self._IntResult == 0 then 
        self._Uid = byteStream:readInt()
        gUid = self._Uid
        self._SessionKey = byteStream:readDouble()
        gSessionKey = self._SessionKey
        self.IP = byteStream:readStringUInt()
        self.port = byteStream:readShort()
        print(self.IP)
        print(self.port) 
        local netSystem = GameGlobal:GetNetSystem()
        netSystem:CreateGameConnect(self.IP , self.port)
        
    end
end

--包处理
function CSLoginPacket:Execute()
    print(self.__cname, self._IntResult) 
    if self._IntResult == 0 then 
        performWithDelay(GameGlobal:GetUISystem():GetUIRootNode(), self.EnterGame, 0.5)
    elseif self._IntResult == PacketState.GX_ENOTEXIST then
        GameGlobal:GetUISystem():OpenUI(UIType.UIType_Country)
    elseif self._IntResult == PacketState.GX_EBUSY then
    end
end

function CSLoginPacket:EnterGame()
    SendMsg(PacketDefine.PacketDefine_AgentLogin_Send, {gUid, gSessionKey})
end

--不要忘记最后的return
return CSLoginPacket
