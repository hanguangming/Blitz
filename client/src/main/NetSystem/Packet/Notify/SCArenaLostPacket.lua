----
-- 文件名称：SCArenaLostPacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local SCArenaLostPacket = class("SCArenaLostPacket", PacketBase)
SCArenaLostPacket._PacketID = PacketDefine.PacketDefine_ArenaLostNotify
--构造函
local G_CD_FORGE_LOW     = 0
local G_CD_FORGE_MIDDLE   = 1
local G_CD_FORGE_HIGH     = 2
local G_CD_RECRUIT_LOW    = 3
local G_CD_RECRUIT_MIDDLE = 4
local G_CD_RECRUIT_HIGH   = 5

function SCArenaLostPacket:ctor()
    self.super.ctor(self)
    self._PacketID = SCArenaLostPacket._PacketID
end

function SCArenaLostPacket:init(data)

end

function SCArenaLostPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function SCArenaLostPacket:Read(byteStream)
    local CharacterServerDataManager = GameGlobal:GetCharacterServerDataManager()
    self.super.Read(self, byteStream)
    
    local size = byteStream:readInt()

    for i = 1, size do
        CharacterServerDataManager._SelfShaChangData = {}
        CharacterServerDataManager._SelfShaChangData._guid = byteStream:readInt()
        CharacterServerDataManager._SelfShaChangData._vip = byteStream:readInt()
        CharacterServerDataManager._SelfShaChangData._name = byteStream:readStringUInt()
        local num = byteStream:readInt()
        CharacterServerDataManager._SelfShaChangData._ZhenXingNum = num
        CharacterServerDataManager._SelfShaChangData._ZhenXingId = {}
        for i = 1, num do
            local newZhenXingData = CharacterServerDataManager:CreateZhenXingData()
            newZhenXingData._WuJiangTableID = byteStream:readInt()
            newZhenXingData._WuJiangAttack = byteStream:readInt()
            newZhenXingData._WuJiangAttackSpeed = byteStream:readInt()
            newZhenXingData._WuJiangHP = byteStream:readInt()
            newZhenXingData._WuJiangCurHP = byteStream:readInt()
    
            newZhenXingData._SoldierTableID =  byteStream:readInt()
            newZhenXingData._SoldierAttack  = byteStream:readInt()
            newZhenXingData._SoldierAttackSpeed  = byteStream:readInt()
            newZhenXingData._SoldierHP  = byteStream:readInt()
            newZhenXingData._SoldierNum  = byteStream:readByte()
            newZhenXingData._SoldierCurNum  = byteStream:readByte()
            newZhenXingData._ZhenXingStartRow = byteStream:readInt()
            newZhenXingData._ZhenXingStartCol = byteStream:readInt()
            CharacterServerDataManager._SelfShaChangData._ZhenXingId[i] = newZhenXingData._WuJiangTableID
            CharacterServerDataManager._SelfShaChangData[newZhenXingData._WuJiangTableID] = newZhenXingData
        end
    
        CharacterServerDataManager._EnemyShaChangData = {}
    
        CharacterServerDataManager._EnemyShaChangData._guid = byteStream:readInt()
        CharacterServerDataManager._EnemyShaChangData._vip = byteStream:readInt()
        CharacterServerDataManager._EnemyShaChangData._name = byteStream:readStringUInt()
        local num = byteStream:readInt()
        CharacterServerDataManager._EnemyShaChangData._ZhenXingNum = num
        for i = 1, num do
            local newZhenXingData = CharacterServerDataManager:CreateZhenXingData()
            newZhenXingData._WuJiangTableID = byteStream:readInt()
            newZhenXingData._WuJiangAttack = byteStream:readInt()
            newZhenXingData._WuJiangAttackSpeed = byteStream:readInt()
            newZhenXingData._WuJiangHP = byteStream:readInt()
            newZhenXingData._WuJiangCurHP = byteStream:readInt()
    
            newZhenXingData._SoldierTableID =  byteStream:readInt()
            newZhenXingData._SoldierAttack  = byteStream:readInt()
            newZhenXingData._SoldierAttackSpeed  = byteStream:readInt()
            newZhenXingData._SoldierHP  = byteStream:readInt()
            newZhenXingData._SoldierNum  = byteStream:readByte()
            newZhenXingData._SoldierCurNum  = byteStream:readByte()
            newZhenXingData._ZhenXingStartRow = byteStream:readInt()
            newZhenXingData._ZhenXingStartCol = byteStream:readInt()
            CharacterServerDataManager._EnemyShaChangData[newZhenXingData._WuJiangTableID] = newZhenXingData
        end
    
        self._BattleResult = byteStream:readByte()
        self._Frames = byteStream:readInt()
   end
end

--包处理
function SCArenaLostPacket:Execute()
    print(self.__cname) 
end

--不要忘记最后的return
return SCArenaLostPacket