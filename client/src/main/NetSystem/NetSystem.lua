----
-- 文件名称：NetSystem.lua
-- 功能描述：网络模块
-- 文件说明：端网络模块：发送，接收数据包,分发处理包
-- 作    者：王雷雷
-- 创建时间：2015-5-22
--  修改：
--  
cc.utils = require("cocos.framework.cc.utils.init")
PacketBase = require("main.NetSystem.PacketBase")
require("main.GameEvent.GameEvent")
local SocketTCP = require("main.NetSystem.SocketTCP")
local NetSystem = class("NetSystem")
local PacketPathPrefix = "main.NetSystem.Packet." 
local stringFormat = string.format
local ByteArrayVarint = require("cocos.framework.cc.utils.ByteArrayVarint")
local ByteArray = require("cocos.framework.cc.utils.ByteArray")
local SocketOutNet = false
local scheduler = require("cocos.framework.scheduler")
local gSendIng = false
--单包长度不超过2046
NetSystem.PACKET_MAX_LEN = 20000

--构造
function NetSystem:ctor()
    --TCP socket
    self._Socket = nil
    --包工厂
    self._PacketMsgFactory = {}
    
    --注册网络包

    if device.platform == "android" or true then
        for i = 1, #PacketAndroidDir do
            self:RegisterMsgPacket(PacketAndroidDir[i]) 
        end
    else
        for i = 1, #PacketDir do
            local Msgs = loadLua(PacketDir[i])
            for j = 1, #Msgs do
                self:RegisterMsgPacket(Msgs[j]) 
            end
        end
    end
   
   
    --输入流,处理接收的
    self._InputStream = ByteArrayVarint.new(PacketBase.ENDIAN)
    --心跳计时器
    self._HeartBeatTimer = 0
    AddEvent(GameEvent.SocketTCP_EVENT_CONNECTED,self.onConnectStatusSuccess)
    AddEvent(GameEvent.SocketTCP_EVENT_CLOSED,self.onClose)
    AddEvent(GameEvent.SocketTCP_EVENT_CONNECT_FAILURE,self.onConnectStatusFail)
    AddEvent(GameEvent.SocketTCP_EVENT_DATA,self.onReceiveCommand)
    
    self._GameEnter = false
    if not SocketOutNet then
        self._LoginIP = "192.168.254.97"
        self._LoginPort = 2600
    else
        self._LoginIP = "203.195.157.135"
        self._LoginPort = 3000
    end
--    self:CreateMapConnect(self._LoginIP, self._LoginPort)
--    self:CreateLoginConnect(self._LoginIP, self._LoginPort)
end

--连接
function NetSystem:Connect(ip, port)
    self._isConnected = false
    self._Socket = SocketTCP.new(ip, port, false)
    self._Socket:connect()
end

--注册发送包
function NetSystem:RegisterMsgPacket(packetClassFile)
    print(packetClassFile)
    local packet = require(packetClassFile)
    if packet ~= nil then
        local packetID = packet._PacketID 
        if self._PacketMsgFactory[packetID] == nil then
            self._PacketMsgFactory[packetID] = packet.new()
        else
            printError("RegisterPacket error: packetID: %d already exist file:%s ", packetID, packetClassFile)
        end
    else
        printError("RegisterPacket error: nil ", packetClassFile)
    end
end

--创建包
function NetSystem:GetMsgPacket(packetID)
    local packetClass = self._PacketMsgFactory[packetID]
    return packetClass
end

--接收的包是否已注册
function NetSystem:IsValidPacketType(packetType)
    return (self._PacketMsgFactory[packetType] ~= nil)
end

--发送数据包
function NetSystem:SendPacket(packet)
    if  packet ~= nil then
        print( self._Socket.name, "__"..packet.__cname.."__SendPacket", os.date(), gSendIng)
        if self._Socket.name == "game" then
            if not gSendIng then
                packet:Clear()
                self._Socket:send(packet:GetPacketByteStream())
                if packet._PacketID ~= PacketDefine.PacketDefine_HeartBeat_Send then
                    gSendIng = true
                end
            end
        else
            if not gSendIng then
                self._CurPacket = packet
                gHandleId = scheduler.scheduleGlobal(self.performWithDelaySend, 0)
                gSendIng = true
            end
        end
    end
end

function NetSystem.performWithDelaySend(__event)
    if GetNetSystem()._isConnected then
        GetNetSystem()._CurPacket:Clear()
        GetNetSystem()._Socket:send(GetNetSystem()._CurPacket:GetPacketByteStream())
        scheduler.unscheduleGlobal(gHandleId)
    end
end

--关闭
function NetSystem.onClose(target, __event)
    print("onClose__event")
    if GetNetSystem()._GameEnter then
        GameGlobal:GetUISystem():OpenUI(UIType.UIType_ReLinkUI)
    end 
    GetNetSystem()._isConnected = false
    GetNetSystem()._GameEnter = false
end

--状态变化
local _func;
function NetSystem.onConnectStatusSuccess(__event)
    GetNetSystem()._isConnected = __event._usedata.isConnected
    print("onConnectStatusSuccess",  GetNetSystem()._isConnected)
    GameGlobal:GetUISystem():CloseUI(UIType.UIType_ReLinkUI)
end

--帧更新
function NetSystem:Update(deltaTime)
    if self._Socket == nil or  self._mapSocket == nil then
        return
    end
    if self._Socket.isConnected == true then
        self._HeartBeatTimer = self._HeartBeatTimer + deltaTime
        if self._HeartBeatTimer >= 60 then
            self._HeartBeatTimer = 0
            SendMsg(PacketDefine.PacketDefine_HeartBeat_Send)
            SendMapMsg(PacketDefine.PacketDefine_HeartBeat_Send)
        end
    end
end

--连接失败
function NetSystem.onConnectStatusFail(__event)
    printInfo("NetSystem.onConnectStatusFail ")
    gSendIng = false
end

--接收数据
function NetSystem.onReceiveCommand(__event)
    --print("NetSystem onReceiveCommand raw data:", cc.utils.ByteArray.toString(__event._usedata.data, 16), os.date())
    --解包
    local gNetSystem = GetNetSystem()
    local __byteString = __event._usedata.data
    if __byteString == nil then
        return
    end
    gNetSystem._InputStream:setPos(gNetSystem._InputStream:getLen() + 1)
    gNetSystem._InputStream:writeBuf(__byteString)
    gNetSystem._InputStream:setPos(1)
    local preLen = PacketBase.PACKET_LEN + PacketBase.PACKET_TYPELEN
    --根据PacketBase里包头定义解析包
    while gNetSystem._InputStream:getAvailable() >= preLen do
        local packetLen = gNetSystem._InputStream:readUShort()
        local contentLen = packetLen
        local type = gNetSystem._InputStream:readInt()
        local size = 6
        if gNetSystem._InputStream:getAvailable() < contentLen - size then 
            -- restore the position to the head of data, behind while loop, 
            -- we will save this incomplete buffer in a new buffer,
            -- and wait next parsePackets performation.
            --printf("received data is not enough, waiting... need %u, get %u", contentLen, gNetSystem._InputStream:getAvailable())
            --printInfo("buf:", gNetSystem._InputStream:toString())
            gNetSystem._InputStream:setPos(gNetSystem._InputStream:getPos() - preLen)
            break 
        end
        --
        if contentLen <= gNetSystem.PACKET_MAX_LEN then
            if gNetSystem:IsValidPacketType(type) then
                printInfo("%d process packet type = %s, contentLen = %d",type, string.format("0x%x",type), contentLen)
                local newPacket = gNetSystem:GetMsgPacket(type)
                local positonBeforeRead = gNetSystem._InputStream:getPos()
                local packetStream = ByteArrayVarint.new(PacketBase.ENDIAN)
                packetStream:writeBytes(gNetSystem._InputStream, gNetSystem._InputStream:getPos(), contentLen - 2)
                packetStream:setPos(1)
                newPacket:Read(packetStream)
                if type < 0x8000 or type >= 0x10000 then
                    gSendIng = false
                    print(string.format("0x%x",type))
                else
                    if type == 0x8013 or type == 0x8005 then
                        gSendIng = false
                    end
                end
                newPacket:Execute() 
                gNetSystem._InputStream:setPos(gNetSystem._InputStream:getPos() + contentLen - size)
            else
                --跳过该包不处理
                printInfo("skip packet type = %s contentLen = %d", string.format("0x%x",type), contentLen)
                gNetSystem._InputStream:setPos(gNetSystem._InputStream:getPos() + contentLen - size)
            end
        else
           --error
            printError("invalid contentLen: %d type: %d", contentLen, type)
        end
    end
    -- clear buffer on exhausted
    if gNetSystem._InputStream:getAvailable() <= 0 then
        gNetSystem._InputStream = ByteArrayVarint.new(PacketBase.ENDIAN)
    else
        -- some datas in buffer yet, write them to a new blank buffer.
        printf("cache incomplete buff,len: %u, available: %u", gNetSystem._InputStream:getLen(), gNetSystem._InputStream:getAvailable())
        local __tmp = ByteArrayVarint.new(PacketBase.ENDIAN)
        gNetSystem._InputStream:readBytes(__tmp, 1, gNetSystem._InputStream:getAvailable())
        gNetSystem._InputStream = __tmp
        printf("tmp len: %u, availabl: %u", __tmp:getLen(), __tmp:getAvailable())
        print("buf:", __tmp:toString())
    end
end

function NetSystem:CreateLoginConnect(ip, port)
    self._LoginIP = ip
    self._LoginPort = port
    self._GameEnter = false
    self:Connect(ip, port) 
    self._Socket.name = "login"
end

function NetSystem:CheckLoginConnect()
    if gSendIng then
        return
    end
    if self._Socket ~= nil then
        self._Socket:close()
        self._Socket = nil
    end
    self:Connect(self._LoginIP, self._LoginPort) 
end

function NetSystem:CreateMapConnect(ip, port)
    self._MapIP = ip
    self._MapPort = port
    self._mapSocket = SocketTCP.new(ip, port, false)
    self._mapSocket:connect()
    self._mapSocket.name = "map"
end

function NetSystem:SendMapPacket(packet)
    if  packet ~= nil then
        print( self._mapSocket.name, "__"..packet.__cname.."__SendPacket", os.date(), gSendIng)
        if self._mapSocket.name == "map" then
            if not gSendIng then
                packet:Clear()
                self._mapSocket:send(packet:GetPacketByteStream())
                if packet._PacketID ~= PacketDefine.PacketDefine_HeartBeat_Send then
                    gSendIng = true
                end
            end
        end
    end
end

function NetSystem:CreateGameConnect(ip, port)
    self._Socket:close()
    self._Socket = nil
    self._GameIP = ip
    self._GamePort = port
    self:Connect(ip, port) 
    self._Socket.name = "game"
    self._Socket.tcp:setoption("tcp-nodelay", true)
end

function NetSystem:CloseConnect()
    self._Socket:close()
    self._Socket = nil
    self._mapSocket:close()
    self._mapSocket = nil
end

local globalNetSystemInstance = NetSystem.new()

function GetNetSystem()
    return globalNetSystemInstance
end

return globalNetSystemInstance