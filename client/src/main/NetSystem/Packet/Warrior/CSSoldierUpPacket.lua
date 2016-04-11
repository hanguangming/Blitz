----
-- 文件名称：CSSoldierUpPacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local CSSoldierUpPacket = class("CSSoldierUpPacket", PacketBase)
CSSoldierUpPacket._PacketID = PacketDefine.PacketDefine_SoldierUp_Send
--构造函数

function CSSoldierUpPacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSSoldierUpPacket._PacketID
end

function CSSoldierUpPacket:init(data)
    self._guid = data[1]
end

function CSSoldierUpPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    self._ContentStream:writeInt(self._guid)
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSSoldierUpPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._IntResult = byteStream:readInt()
end

--包处理
function CSSoldierUpPacket:Execute()
    print(self.__cname, self._IntResult) 
    if self._IntResult == 0 then
        local UISystem = GameGlobal:GetUISystem()
        local uiInstance = UISystem:GetUIInstance(UIType.UIType_AdvancedUI)
        uiInstance:AdvancedSucceed()
    
        DispatchEvent(GameEvent.GameEvent_UIAdvanced_Succeed, GetGlobalData()._CurWarror)
    end
end

--不要忘记最后的return
return CSSoldierUpPacket