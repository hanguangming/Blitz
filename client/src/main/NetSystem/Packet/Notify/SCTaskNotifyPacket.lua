----
-- 文件名称：SCTaskNotifyPacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local SCTaskNotifyPacket = class("SCTaskNotifyPacket", PacketBase)
SCTaskNotifyPacket._PacketID = PacketDefine.PacketDefine_TaskNotify
--构造函数

local G_TASK_STATE_NOREADY = 0
local G_TASK_STATE_ACCEPTED = 1
local G_TASK_STATE_FINISHED = 2
local G_TASK_STATE_REMOVED = 3
local G_TASK_STATE_END = 4
local G_TASK_STATE_UNKNOWN = 5


function SCTaskNotifyPacket:ctor()
    self.super.ctor(self)
    self._PacketID = SCTaskNotifyPacket._PacketID
end

function SCTaskNotifyPacket:init(data)
end

function SCTaskNotifyPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function SCTaskNotifyPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._Count = byteStream:readInt()

    if self._Count > 0 then
        for i = 1, self._Count do
            local data = {}
            self._guid = byteStream:readInt()
            self._state = byteStream:readByte()
            data[1] = self._guid
            data[2] = self._state
            if data[2] == 3 then
                GetGlobalData():removeTaskByID(data[1])
            else
                GetGlobalData():updateTaskByID(data)
            end
        end
    end
end

--包处理
function SCTaskNotifyPacket:Execute()
    print(self.__cname, self._Count)  
end

--不要忘记最后的return
return SCTaskNotifyPacket