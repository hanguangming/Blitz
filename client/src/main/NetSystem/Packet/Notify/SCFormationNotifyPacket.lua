----
-- 文件名称：SCFormationNotifyPacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local SCFormationNotifyPacket = class("SCFormationNotifyPacket", PacketBase)
SCFormationNotifyPacket._PacketID = PacketDefine.PacketDefine_FormationNotify
--构造函数

local G_SOLIDER_LEVEL = 0
local G_SOLIDER_EXP = 1


function SCFormationNotifyPacket:ctor()
    self.super.ctor(self)
    self._PacketID = SCFormationNotifyPacket._PacketID
end

function SCFormationNotifyPacket:init(data)

end

function SCFormationNotifyPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function SCFormationNotifyPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._Count = byteStream:readInt()
    local CharacterServerDataManager = GameGlobal:GetCharacterServerDataManager()
    if self._Count > 0 then
        for i = 1, self._Count do
            local k = byteStream:readByte()
            local num = byteStream:readInt()
            local currentData = CharacterServerDataManager._AllZhenXingTable[k+1]
            for i = 1, num do
                local warriorId = byteStream:readInt()
                local soldierId = byteStream:readInt()
                local row = byteStream:readInt()
                local col = byteStream:readInt()
                if GameGlobal:GetCharacterServerDataManager():GetLeader(warriorId) ~= nil then
                    currentData[warriorId] = {}
                    currentData[warriorId]._WuJiangTableID = warriorId
                    currentData[warriorId]._SoldierTableID = soldierId
                    currentData[warriorId]._ZhenXingStartRow = row
                    currentData[warriorId]._ZhenXingStartCol = col
                end
            end
        end
    end
end

--包处理
function SCFormationNotifyPacket:Execute()
    print(self.__cname)  
end

--不要忘记最后的return
return SCFormationNotifyPacket