----
-- 文件名称：SCSoldierNotifyPacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local SCSoldierNotifyPacket = class("SCSoldierNotifyPacket", PacketBase)
SCSoldierNotifyPacket._PacketID = PacketDefine.PacketDefine_SoldierNotify
--构造函数

local G_SOLIDER_LEVEL = 0
local G_SOLIDER_EXP = 1

        
function SCSoldierNotifyPacket:ctor()
    self.super.ctor(self)
    self._PacketID = SCSoldierNotifyPacket._PacketID
end

function SCSoldierNotifyPacket:init(data)
end

function SCSoldierNotifyPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function SCSoldierNotifyPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._Count = byteStream:readInt()
    if self._Count > 0 then
        for i = 1, self._Count do
            self._guid = byteStream:readInt()
            print(self._guid)
            local CharacterServerDataManager = GameGlobal:GetCharacterServerDataManager() 
            if self._guid > 10000 then
                CharacterServerDataManager:RemoveSoldier(self._guid)
            else
                CharacterServerDataManager:RemoveLeader(self._guid)
            end
        end
    end
end

--包处理
function SCSoldierNotifyPacket:Execute()
    print(self.__cname)  
    DispatchEvent(GameEvent.GameEvent_UIWarrior_Succeed)
end

--不要忘记最后的return
return SCSoldierNotifyPacket