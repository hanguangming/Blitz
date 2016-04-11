----
-- 文件名称：CSRecruitPacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local CSRecruitPacket = class("CSRecruitPacket", PacketBase)
CSRecruitPacket._PacketID = PacketDefine.PacketDefine_Recruit_Send
--构造函数

function CSRecruitPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSRecruitPacket._PacketID
end

function CSRecruitPacket:init(data)
    self._Index = data[1]
    GetGlobalData()._RecruitList = {}
end

function CSRecruitPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeByte(self._Index)
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSRecruitPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
end

--包处理
function CSRecruitPacket:Execute()
    print(self.__cname, self._IntResult) 
    if self._IntResult == 0 then
        DispatchEvent(GameEvent.GameEvent_UIRecruitOpen_Succeed)
        DispatchEvent(GameEvent.GameEvent_UIRecruit_Succeed)
    end
end

--不要忘记最后的return
return CSRecruitPacket