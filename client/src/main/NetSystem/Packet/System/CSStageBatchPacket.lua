----
-- 文件名称：CSStageBatchPacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

local G_ITYPE_SOUL1       =   0
local G_ITYPE_SOUL2       =   1
local G_ITYPE_EQUIP_BEGIN =   2
local G_ITYPE_EQUIP_END   =   9
local G_ITYPE_BOX         =   12
local G_ITYPE_COIN        =   19
local G_ITYPE_MONEY       =   20
local G_ITYPE_EXP         =   21

--包定义
local CSStageBatchPacket = class("CSStageBatchPacket", PacketBase)
CSStageBatchPacket._PacketID = PacketDefine.PacketDefine_StageBatch_Send
--构造函数

function CSStageBatchPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSStageBatchPacket._PacketID
end

function CSStageBatchPacket:init(data)
    self._guid = data[1]
    self._times = data[2]
end

function CSStageBatchPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeInt(self._guid)
    self._ContentStream:writeByte(self._times)
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSStageBatchPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    GetGlobalData()._RewardList = {}
    self._IntResult = byteStream:readInt()
    local num = byteStream:readInt()
    for i = 1, num do
        local tmp = {}
        tmp[1] = byteStream:readInt()
        tmp[2] = byteStream:readInt()
        if tmp[1] > 100 then
            table.insert(GetGlobalData()._RewardList,tmp)
        end
    end
end

--包处理
function CSStageBatchPacket:Execute()
    print(self.__cname, self._IntResult) 
    if  #GetGlobalData()._RewardList > 0 then
        GameGlobal:GetUISystem():OpenUI(UIType.UIType_CustomReward)
    end
end

--不要忘记最后的return
return CSStageBatchPacket