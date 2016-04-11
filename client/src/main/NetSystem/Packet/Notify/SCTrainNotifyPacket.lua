----
-- 文件名称：SCTrainNotifyPacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local SCTrainNotifyPacket = class("SCTrainNotifyPacket", PacketBase)
SCTrainNotifyPacket._PacketID = PacketDefine.PacketDefine_TrainNotify
--构造函数

function SCTrainNotifyPacket:ctor()
    self.super.ctor(self)
    self._PacketID = SCTrainNotifyPacket._PacketID
end

function SCTrainNotifyPacket:init(data)

end

function SCTrainNotifyPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function SCTrainNotifyPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._Count = byteStream:readInt()
    if self._Count > 0 then
        for i = 1, self._Count do
            self._guid = byteStream:readInt()
            self._time = byteStream:readInt()
            self._type = byteStream:readByte()
            local CharacterServerDataManager = GameGlobal:GetCharacterServerDataManager() 
            local warror =  CharacterServerDataManager:GetLeader(self._guid)
            if warror == nil then
                warror =  CharacterServerDataManager:GetSoldier(self._guid)
            end
            warror._Time = math.floor(self._time / 1000)
            warror._TimeEnd = math.floor(self._time / 1000) + os.time()
            if self._time == 0 then
                warror._TrainType = 0
            else
                warror._TrainType = self._type
            end
        end
    end
end

--包处理
function SCTrainNotifyPacket:Execute()
    print(self.__cname)  
    DispatchEvent(GameEvent.GameEvent_UITrain_Update, self._guid)
end

--不要忘记最后的return
return SCTrainNotifyPacket