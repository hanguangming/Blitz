----
-- 文件名称：CSAgentLoginPacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local CSAgentLoginPacket = class("CSAgentLoginPacket", PacketBase)
CSAgentLoginPacket._PacketID = PacketDefine.PacketDefine_AgentLogin_Send
--构造函数

function CSAgentLoginPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSAgentLoginPacket._PacketID
    self._Uid = 0
    self._SessionKey = 0
end

function CSAgentLoginPacket:init(data)
    self._Uid = data[1]
    self._SessionKey = data[2]
end

function CSAgentLoginPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeInt(self._Uid)
    self._ContentStream:writeDouble(self._SessionKey)
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSAgentLoginPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
    GetPlayer()._UserName = byteStream:readStringUInt()
    g_CountryID = byteStream:readByte()
    GetPlayer()._Country = g_CountryID
    local ip = byteStream:readStringUInt()
    local port = byteStream:readShort()
    local netSystem = GameGlobal:GetNetSystem()
    print(ip, port)
    netSystem:CreateMapConnect(ip, port)
end

--包处理
function CSAgentLoginPacket:Execute()
    print(self.__cname, self._IntResult)  
    if self._IntResult == 0 then
        GetNetSystem()._GameEnter = true
        performWithDelay(GameGlobal:GetUISystem():GetUIRootNode(), self.MapLoginGame, 0.5)
        DispatchEvent(GameEvent.GameEvent_UILogin_Succeed, "")
    end
end

function CSAgentLoginPacket:MapLoginGame()
    SendMapMsg(PacketDefine.PacketDefine_MapLogin_Send)
end

--不要忘记最后的return
return CSAgentLoginPacket