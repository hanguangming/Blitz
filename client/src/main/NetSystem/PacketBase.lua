----
-- 文件名称：PacketBase.lua
-- 功能描述：网络包父类
-- 文件说明：网络包父类
-- 作    者：王雷雷
-- 创建时间：2015-5-23
--  修改：
--  包格式: 包长(UShort)|包类型ID()|包体长度(2)|包体
--  所有数据包必须放在Packet目录下
--  
local ByteArrayVarint = require("cocos.framework.cc.utils.ByteArrayVarint")
require("main.NetSystem.PacketDefine")
local PacketBase = class("PacketBase")
local stringByte = string.byte
local stringChar = string.char

--字节序
PacketBase.ENDIAN = ByteArrayVarint.ENDIAN_LITTLE
--包长(2字节)
PacketBase.PACKET_LEN = 2
--包类型ID长(1字节)
PacketBase.PACKET_TYPELEN = 4

--构造函数
function PacketBase:ctor()
    --包类型
    self._PacketID = -1
    self._ContentStream = ByteArrayVarint.new(PacketBase.ENDIAN)
    self._OutputStream = ByteArrayVarint.new(PacketBase.ENDIAN)
end

--销毁
function PacketBase:Destroy()
    self._ContentStream = nil
    self._OutputStream = nil
end

function PacketBase:Clear()
    self._ContentStream._buf = {}
    self._ContentStream._pos = 1
    self._OutputStream._buf = {}
    self._OutputStream._pos = 1
end

--读流
function PacketBase:Read(byteStream)
    --printInfo("PacketBase:Read type = %d buffer: %s", self._PacketID, byteStream:toString(16))
end

--写流
function PacketBase:Write()
end

function PacketBase:Init()
end

--发送时获取发送的stream
function PacketBase:GetPacketByteStream()
    self:Write()
    print("send packet content:", self._OutputStream:toString(16))
    return self._OutputStream:getPack()
end

--接收到包的处理
function PacketBase:Execute()
    
end
--PacketID接口独立出来，方便修改
function PacketBase:WritePacketContentID()
    self._ContentStream:writeInt(self._PacketID)
end

--写包长，接口独立出来,方便修改
function PacketBase:WritePacketLength()
    print("self._ContentStream:getLen()"..self._ContentStream:getLen())
    self._OutputStream:writeUShort(self._ContentStream:getLen() + 2)
end

--写内容 
function PacketBase:WritePacketContent()
    self._OutputStream:writeBytes(self._ContentStream)
end
--加密对特定区域
function PacketBase:EncryptFrom(pos, key)
    local packetBuffer = self._OutputStream._buf
    for i = pos, #packetBuffer do
        local result = bit.bxor(stringByte(packetBuffer[i]), stringByte(key))
        packetBuffer[i] = stringChar(result)
    end
end
--加密
function PacketBase:Encrypt()
    local packetBuffer = self._OutputStream._buf
    for i = 4, #packetBuffer do
        local result = bit.bxor(stringByte(packetBuffer[i]), stringByte(packetBuffer[3]))
        packetBuffer[i] = stringChar(result)
    end
end

--解密
function PacketBase.DeEncrypt(byteStream, packetType)
    local packetBuffer = byteStream._buf
    for i = 1, #packetBuffer do
        local result = bit.bxor(stringByte(packetBuffer[i]), packetType)
        packetBuffer[i] = stringChar(result)
    end
end
return PacketBase