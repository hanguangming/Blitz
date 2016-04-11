----
-- 文件名称：CSStageEndPacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local CSStageEndPacket = class("CSStageEndPacket", PacketBase)
CSStageEndPacket._PacketID = PacketDefine.PacketDefine_StageEnd_Send
--构造函数

function CSStageEndPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSStageEndPacket._PacketID
end

function CSStageEndPacket:init(data)
    self._isWin = data[1]
    self._isQuit = data[2]
end

function CSStageEndPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeByte(self._isWin)
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSStageEndPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    GetGlobalData()._RewardList = {}
    self._IntResult = byteStream:readInt()
    local num = byteStream:readInt()
    for i = 1, num do
        local tmp = {}
        tmp[1] = byteStream:readInt()
        tmp[2] = byteStream:readInt()
        table.insert(GetGlobalData()._RewardList,tmp)
    end
end

--包处理
function CSStageEndPacket:Execute()
    print(self.__cname, self._IntResult) 
    for i, v in pairs(GameGlobal:GetTechnologyDataManager()) do
        GameGlobal:GetServerTechnologyDataManager():UpdateTechnology(i)
    end
    if self._isWin == 1 then
        local reward = GameGlobal:GetUISystem():OpenUI(UIType.UIType_BattleResUI)
        reward:OpenUISucceed(0, 0, 1, GetGlobalData()._RewardList)
    else
        if self._isQuit == nil then
            local reward = GameGlobal:GetUISystem():OpenUI(UIType.UIType_BattleResUI)
            reward:OpenUISucceed(0, 0, 0, nil)
        end
    end
end

--不要忘记最后的return
return CSStageEndPacket