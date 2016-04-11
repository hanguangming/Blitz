----
-- 文件名称：SCSoldierNotifyPacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local SCTechNotifyPacket = class("SCTechNotifyPacket", PacketBase)
SCTechNotifyPacket._PacketID = PacketDefine.PacketDefine_TechNotify
--构造函数

local G_TRAIN_LOW                 = 1
local G_TRAIN_MIDDLE              = 2
local G_TRAIN_HIGH                = 3


function SCTechNotifyPacket:ctor()
    self.super.ctor(self)
    self._PacketID = SCTechNotifyPacket._PacketID
end

function SCTechNotifyPacket:init(data)
end

function SCTechNotifyPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function SCTechNotifyPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._Count = byteStream:readInt()
    if self._Count > 0 then
        for i = 1, self._Count do
            local data = {}
            self._type = byteStream:readByte()
            self._cur = byteStream:readInt()
            self._research = byteStream:readInt()
            self._price_num = byteStream:readByte()
            self._cooldown = byteStream:readInt()
            data[1] = self._type
            data[2] = self._cur
            data[3] = self._research
            data[4] = self._price_num
            data[5] = math.floor(self._cooldown / 1000)
            GetGlobalData()._TechnologyList[data[1] + 1] = data
        end
    end
end

--包处理
function SCTechNotifyPacket:Execute()
    for i, v in pairs(GameGlobal:GetTechnologyDataManager()) do
        GameGlobal:GetServerTechnologyDataManager():UpdateTechnology(i)
    end
    DispatchEvent(GameEvent.GameEvent_UITechnology_Open)
    print(self.__cname, self._Count)  
end

--不要忘记最后的return
return SCTechNotifyPacket