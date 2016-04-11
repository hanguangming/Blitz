----
-- 文件名称：SCSoldierValueNotifyPacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local SCSoldierValueNotifyPacket = class("SCSoldierValueNotifyPacket", PacketBase)
SCSoldierValueNotifyPacket._PacketID = PacketDefine.PacketDefine_SoldierValueNotify
--构造函数
local G_SOLIDER_LEVEL = 0
local G_SOLIDER_EXP = 1
local G_SOLIDER_USED = 2

function SCSoldierValueNotifyPacket:ctor()
    self.super.ctor(self)
    self._PacketID = SCSoldierValueNotifyPacket._PacketID
end

function SCSoldierValueNotifyPacket:init(data)
 
end

function SCSoldierValueNotifyPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function SCSoldierValueNotifyPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._TableID = byteStream:readInt()
    self._Count = byteStream:readInt()
    local warror
    local CharacterServerDataManager = GameGlobal:GetCharacterServerDataManager() 
    if self._TableID > 10000 then
        warror = CharacterServerDataManager:GetSoldier(self._TableID)
        if warror == nil then
            warror =  CharacterServerDataManager:CreateSoldier(self._TableID)
        end
    else
        warror = CharacterServerDataManager:GetLeader(self._TableID)
        if warror == nil then
            warror =  CharacterServerDataManager:CreateLeader(self._TableID)
        end
    end
    GetGlobalData()._CurWarror = warror
    GetGlobalData()._CurWarriorId = self._TableID

    if self._Count > 0 then
        for i = 1, self._Count do
            self._type = byteStream:readByte()
            self._value = byteStream:readInt()
            print(self._type, self._value)
            if self._type == G_SOLIDER_LEVEL then
                warror._Level = self._value
                warror._Hp = warror._CharacterData.hp + (warror._Level - 1) * warror._CharacterData.hpup    -- hp
                warror._Attack = warror._CharacterData.attack + (warror._Level - 1) * warror._CharacterData.attackup    -- attack
                warror._AtkSpeed = warror._CharacterData.attackSpeed   -- attack speed  
            elseif self._type == G_SOLIDER_EXP then 
                warror._Exp = self._value
            elseif self._type == G_SOLIDER_USED then 
                warror._CurrentState = self._value
                DispatchEvent(GameEvent.GameEvent_UIWarrior_Embattle, warror._CurrentState)
            elseif self._type >= 3 and self._type <= 10 then 
                warror._Equip[self._type - 2] = self._value
                warror:update()
            end
        end
    end
end

--包处理
function SCSoldierValueNotifyPacket:Execute()
    print(self.__cname) 
    if GetNetSystem()._GameEnter then
        local CharacterServerDataManager = GameGlobal:GetCharacterServerDataManager() 
        if CharacterServerDataManager:GetLeaderId() ~= GetPlayer()._HeadId and self._TableID < 10000 then
            SendMsg(PacketDefine.PacketDefine_Appearnace_Send, {CharacterServerDataManager:GetLeaderId()})
        end
    end
end

--不要忘记最后的return
return SCSoldierValueNotifyPacket