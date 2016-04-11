----
-- 文件名称：SCValueNotifyPacket.lua
-- 功能描述：货币通知
-- 文件说明：货币通知
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local SCValueNotifyPacket = class("SCValueNotifyPacket", PacketBase)
SCValueNotifyPacket._PacketID = PacketDefine.PacketDefine_ValueNotify
--构造函数

local G_VALUE_MONEY               = 0
local G_VALUE_COIN                = 1
local G_VALUE_HONOR               = 2
local G_VALUE_RECRUIT             = 3
local G_VALUE_RECHARGE_MONEY      = 4
local G_VALUE_LEVEL               = 5
local G_VALUE_EXP                 = 6
local G_VALUE_VIP                 = 7
local G_VALUE_RECRUIT_INDEX1      = 8
local G_VALUE_RECRUIT_INDEX2      = 9
local G_VALUE_RECRUIT_INDEX3      = 10
local G_VALUE_RECRUIT_INDEX4      = 11
local G_VALUE_RECRUIT_INDEX5      = 12
local G_VALUE_STAGE               = 13
local G_VALUE_MORDERS             = 14
local G_VALUE_FORMATION_PVE       = 15
local G_VALUE_FORMATION_PVP       = 16
local G_VALUE_FORMATION_ARENA     = 17
local G_VALUE_TIGER_USE_TIMES     = 18
local G_VALUE_SUPPLEMENT          = 19
local G_VALUE_SHADOW              = 20
local G_VALUE_CHALLENGE           = 21
local G_VALUE_APPEARANCE          = 22
local G_VALUE_MEXP                = 23
local G_VALUE_UNKNOWN             = -1
local G_VALUE_SCORE               = 128

function SCValueNotifyPacket:ctor()
    self.super.ctor(self)
    self._PacketID = SCValueNotifyPacket._PacketID
end

function SCValueNotifyPacket:init(data)

end

function SCValueNotifyPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function SCValueNotifyPacket:Read(byteStream)
    
    local palyer = GetPlayer()
    self.super.Read(self, byteStream)
    local count = byteStream:readInt()
   
    for  i = 1, count do
        local type = byteStream:readByte()
        local value = byteStream:readInt()
        
        print(self.__cname, type, value)
        if type == G_VALUE_MONEY then
            palyer._Gold = value
        elseif type == G_VALUE_COIN then
            palyer._Silver = value
        elseif type == G_VALUE_HONOR then
            palyer._RongYuZhi = value
        elseif type == G_VALUE_RECRUIT then
            palyer._ZhaoMuValue = value
        elseif type == G_VALUE_RECHARGE_MONEY then
        elseif type == G_VALUE_LEVEL then
            palyer._Level = value
            for i, v in pairs(GameGlobal:GetTechnologyDataManager()) do
                GameGlobal:GetServerTechnologyDataManager():UpdateTechnology(i)
            end
        elseif type == G_VALUE_EXP then
            palyer._Exp = value 
        elseif type == G_VALUE_VIP then
            palyer._VIPLevel = value 
        elseif type == G_VALUE_RECRUIT_INDEX1 then
            GetGlobalData()._RecruitList[1] = value 
        elseif type == G_VALUE_RECRUIT_INDEX2 then
            GetGlobalData()._RecruitList[2] = value 
        elseif type == G_VALUE_RECRUIT_INDEX3 then
            GetGlobalData()._RecruitList[3] = value 
        elseif type == G_VALUE_RECRUIT_INDEX4 then
            GetGlobalData()._RecruitList[4] = value 
        elseif type == G_VALUE_RECRUIT_INDEX5 then
            GetGlobalData()._RecruitList[5] = value 
        elseif type == G_VALUE_STAGE then
            if value == 0 then
                value = 1000
            end
            palyer._MaxLevel = value - 999
           
            if palyer._MaxLevel >= 600 then
                palyer._MaxLevel = 600
            elseif palyer._MaxLevel <= 1 then
                palyer._MaxLevel = 1
            end
            
            for i, v in pairs(GameGlobal:GetTechnologyDataManager()) do
                GameGlobal:GetServerTechnologyDataManager():UpdateTechnology(i)
            end
        elseif type == G_VALUE_MORDERS then
            palyer._Energy = value 
            print("palyer._Energy",palyer._Energy)
        elseif type == G_VALUE_FORMATION_PVE then
             
        elseif type == G_VALUE_FORMATION_PVP then
        elseif type == G_VALUE_FORMATION_ARENA then
        elseif type == G_VALUE_TIGER_USE_TIMES then
            GetPlayer()._NeedHuFuTimes = value
        elseif type == G_VALUE_SUPPLEMENT then
            GameGlobal:GetGuoZhanServerDataManager()._HuiFuCount = value
        elseif type == G_VALUE_SHADOW then
            GetPlayer()._ShadowNum = value
        elseif type == G_VALUE_CHALLENGE then
            palyer._CanTianZhanCount = value 
--        elseif type == G_VALUE_ARENA_AWARD_DAY then
--            palyer._ShaChangReward = value 
        elseif type == G_VALUE_SCORE then
            palyer._BattleValue = value
        elseif type ==  G_VALUE_APPEARANCE  then
            palyer._HeadId = value
        elseif type == G_VALUE_MEXP  then
            GameGlobal:GetGuoZhanServerDataManager()._GongXunValue = math.floor(value / 100)
        end
    end
end

--包处理
function SCValueNotifyPacket:Execute()
    print(self.__cname)  
    DispatchEvent(GameEvent.GameEvent_MyselfInfoChange, "")
    DispatchEvent(GameEvent.GameEvent_UIStore_Update, "")
    DispatchEvent(GameEvent.GameEvent_UIWarriorStore_Update, "")
    DispatchEvent(GameEvent.GameEvent_SweepEnergy_Succeed, "")
    DispatchEvent(GameEvent.GameEvent_GuoZhan_UpdateMap)
end

--不要忘记最后的return
return SCValueNotifyPacket