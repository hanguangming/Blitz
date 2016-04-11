----
-- 文件名称：SCCooldownNotify.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local SCCooldownNotify = class("SCCooldownNotify", PacketBase)
SCCooldownNotify._PacketID = PacketDefine.PacketDefine_CooldownNotify
--构造函
local G_CD_FORGE_LOW     = 0
local G_CD_FORGE_MIDDLE   = 1
local G_CD_FORGE_HIGH     = 2
local G_CD_RECRUIT_LOW    = 3
local G_CD_RECRUIT_MIDDLE = 4
local G_CD_RECRUIT_HIGH   = 5
        
function SCCooldownNotify:ctor()
    self.super.ctor(self)
    self._PacketID = SCCooldownNotify._PacketID
end

function SCCooldownNotify:init(data)

end

function SCCooldownNotify:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function SCCooldownNotify:Read(byteStream)
    self.super.Read(self, byteStream)
    local num = byteStream:readInt()
    for i = 1, num do
        self._id = byteStream:readShort()
        self._time = byteStream:readInt()
        if self._id <= 2 then
            GetGlobalData()._SmeltTime[self._id + 1] = math.floor(self._time / 1000) + os.time()
        else
            GetGlobalData()._RecruitTime[self._id + 1] = math.floor(self._time / 1000) + os.time()
        end
    end
end

--包处理
function SCCooldownNotify:Execute()
    print(self.__cname) 
    DispatchEvent(GameEvent.GameEvent_UIRecruitOpen_Succeed)
    DispatchEvent(GameEvent.GameEvent_UIEquipSmelt_Succeed)
end

--不要忘记最后的return
return SCCooldownNotify