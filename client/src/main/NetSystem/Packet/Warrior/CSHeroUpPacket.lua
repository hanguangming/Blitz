----
-- 文件名称：CSHeroUpPacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local CSHeroUpPacket = class("CSHeroUpPacket", PacketBase)
CSHeroUpPacket._PacketID = PacketDefine.PacketDefine_HeroUp_Send
--构造函数

function CSHeroUpPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSHeroUpPacket._PacketID
end

function CSHeroUpPacket:init(data)
    self._guid = data[1]
    self._num = data[2]
    self._useId = data[3] 
    dump(data)
    dump(self._useId)
end

function CSHeroUpPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeInt(self._guid)
    self._ContentStream:writeInt(self._num)
    dump(self._useId)
    for i = 2, self._num + 1 do
        print(self._useId[i])
        self._ContentStream:writeInt(self._useId[i])
    end
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSHeroUpPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
end

--包处理
function CSHeroUpPacket:Execute()
    print(self.__cname, self._IntResult)
    if self._IntResult == 0 then
        DispatchEvent(GameEvent.GameEvent_Reborn_Succeed)
    end
end

--不要忘记最后的return
return CSHeroUpPacket