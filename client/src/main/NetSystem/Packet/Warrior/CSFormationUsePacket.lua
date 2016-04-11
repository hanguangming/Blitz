----
-- 文件名称：CSFormationUsePacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local CSFormationUsePacket = class("CSFormationUsePacket", PacketBase)
CSFormationUsePacket._PacketID = PacketDefine.PacketDefine_FormationUse_Send
--构造函数

local G_FORMATION_PVE = 0
local G_FORMATION_PVP = 1
local G_FORMATION_ARENA = 2
        
function CSFormationUsePacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSFormationUsePacket._PacketID
end

function CSFormationUsePacket:init(data)
    self._Type = data[1]
    self._Index = data[2]
end

function CSFormationUsePacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeByte(self._Type)
    self._ContentStream:writeByte(self._Index)
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSFormationUsePacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
end

--包处理
function CSFormationUsePacket:Execute()
    print(self.__cname, self._IntResult) 
    if self._IntResult == 0 then
        DispatchEvent(GameEvent.GameEvent_UIRecruitOpen_Succeed)
    end
end

--不要忘记最后的return
return CSFormationUsePacket