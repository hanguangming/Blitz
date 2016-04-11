----
-- 文件名称：SCMapCityPresendPacket.lua
-- 功能描述：物品使用
-- 文件说明：物品使用
-- 作    者：田凯
-- 创建时间：2015-9-23
--  修改


--包定义
local SCMapCityPresendPacket = class("SCMapCityPresendPacket", PacketBase)
SCMapCityPresendPacket._PacketID = PacketDefine.PacketDefine_MapCityPresendNotify

local G_CITY_PEACE = 0
local G_CITY_FIGHT = 1
        
--构造函数
function SCMapCityPresendPacket:ctor()
    self.super.ctor(self)
    self._PacketID = SCMapCityPresendPacket._PacketID
end

function SCMapCityPresendPacket:init(data)

end

function SCMapCityPresendPacket:Write()
    self:WritePacketContentID()
    --包的其它字段
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function SCMapCityPresendPacket:Read(byteStream)
    self.super.Read(self, byteStream)
    self._Num = byteStream:readInt()
    self._BuildIdState = {}
    for i = 1 , self._Num do
        local id = byteStream:readInt()
        local side = byteStream:readByte()
        local state = byteStream:readByte()
        local tmp = {}
        tmp[1] = id
        tmp[2] = side
        tmp[3] = state
        GetGlobalData()._BuidId[id] = tmp
        local map = GameGlobal:GetUISystem():GetUIInstance(UIType.UIType_WorldMap)
       
        if  map ~= nil and map._openState then
            map:updateCitySide(id, side + 1)
            map:updateCityState(id, state)
        end
--      table.insert(self._BuildIdState, id)       
    end
end

function SCMapCityPresendPacket:Execute()
    print(self.__cname, self._Num) 
--    DispatchEvent(GameEvent.GameEvent_GuoZhan_JuDianStateRefresh, self._BuildIdState)
    
end

return  SCMapCityPresendPacket