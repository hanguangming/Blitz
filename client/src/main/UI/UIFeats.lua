----
-- 文件名称：UIFeats.lua
-- 功能描述：UIFeats
-- 文件说明：
-- 作    者：
-- 创建时间：2015-8-5
-- 修改 ：
-- 
--
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
local UISystem = require("main.UI.UISystem")
local NetSystem = GameGlobal:GetNetSystem()
local UIFeats = class("UIFeats", UIBase)
local _Instance = nil
--构造函数
function UIFeats:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_Feats
    self._ResourceName = "UIFeats.csb" 
end

--Load
function UIFeats:Load()
    UIBase.Load(self)
    _Instance = self
    local btn = self:GetUIByName("FinishBtn")
    btn:setTag(1)
    btn:addTouchEventListener(self.TouchEvent)
    btn:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 250), 2)
    btn:getTitleRenderer():setPositionY(33)
    
    local btn = self:GetUIByName("Button_icon")
    btn:setTag(2)
    btn:addTouchEventListener(self.TouchEvent)
    btn:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 250), 2)
    btn:getTitleRenderer():setPositionY(33)
    
    local btn = self:GetUIByName("Button_Top")
    btn:setTag(3)
    btn:addTouchEventListener(self.TouchEvent)
    btn:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 250), 2)
    btn:getTitleRenderer():setPositionY(33)
    
    self._FeatsLabelData = {}
    for i = 1, 4 do
        self._FeatsLabelData[i] = seekNodeByName(self:GetUIByName("feats"..i), "Text_1")
    end
    self:GetUIByName("Text_2"):enableOutline(cc.c4b(0, 0, 0, 250), 2)
    self:GetUIByName("Text_3"):enableOutline(cc.c4b(0, 0, 0, 250), 2)
    self:GetUIByName("Label_4"):enableOutline(cc.c4b(0, 0, 0, 250), 2)
    self:GetUIByName("Label_5"):enableOutline(cc.c4b(0, 0, 0, 250), 2)
    self._FeatsLabelData[5] = self:GetUIByName("Label_8")
    self._FeatsLabelData[6] = self:GetUIByName("iconnum")
    self._FeatsLabelData[7] = self:GetUIByName("Label_7")
    self._LoadingBar = self:GetUIByName("LoadingBar_1"):setPercent(20)
    local cancel = self:GetUIByName("Close")
    cancel:setTag(-1)
    cancel:addTouchEventListener(self.TouchEvent)
end

--Unload
function UIFeats:Unload()
    UIBase.Unload(self)
end

--打开
function UIFeats:Open()
    UIBase.Open(self)
    local roleInfo = GetPlayer()
    local NetSystem = GameGlobal:GetNetSystem()
    self._UpdateTopCallBack = AddEvent(GameEvent.GameEvent_GuoZhan_UpdateFeatTop, self.UpdateFeatTopData)
    self._UpdateCallBack = AddEvent(GameEvent.GameEvent_GuoZhan_UpdateFeat, self.UpdateFeatData)
    local guanZhanPacket = NetSystem:CreateToSendPacket(PacketDefine.PacketDefine_GuoZhan_Request_Send)
    guanZhanPacket._Param = 4
    guanZhanPacket._DestJuDianID = 0
    NetSystem:SendPacket(guanZhanPacket)
    
    local NetSystem = GameGlobal:GetNetSystem()
    local guanZhanPacket = NetSystem:CreateToSendPacket(PacketDefine.PacketDefine_GuoZhan_Request_Send)
    guanZhanPacket._Param = 5
    guanZhanPacket._DestJuDianID = 0
    NetSystem:SendPacket(guanZhanPacket)
end

--关闭
function UIFeats:Close()
    UIBase.Close(self)
end

function UIFeats:UpdateFeatTopData()
    GetPlayer()._GongXunTop = self._usedata
    if GetPlayer()._GongXunTop[0] == 0 then
        _Instance._FeatsLabelData[7]:setString(ChineseConvert["UITitle_7"])
    else
        _Instance._FeatsLabelData[7]:setString(GetPlayer()._GongXunTop[0])
    end
end

function UIFeats:UpdateFeatData()
    GetPlayer()._GongXun = self._usedata
    for i = 1, 5 do
        if _Instance._FeatsLabelData ~= nil then
            _Instance._FeatsLabelData[i]:setString(self._usedata[i])
        end
    end
    _Instance._FeatsLabelData[6]:setString("X"..self._usedata[6])
    for i, v in pairs(GameGlobal:GetFeatDataManager()) do
        if GetPlayer()._Level >= tonumber(v["lvmin"]) and GetPlayer()._Level <= tonumber(v["lvmax"]) then
            _Instance._LoadingBar:setPercent(self._usedata[5]/tonumber(v["expmax"]))
        end
    end
end

function UIFeats:TouchEvent(eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = self:getTag()
        if tag == -1 then
            UISystem:CloseUI(UIType.UIType_Feats) 
        elseif tag == 1 then
            local guanZhanPacket = NetSystem:CreateToSendPacket(PacketDefine.PacketDefine_GuoZhan_Request_Send)
            guanZhanPacket._Param = 18
            guanZhanPacket._DestJuDianID = 0
            NetSystem:SendPacket(guanZhanPacket)
        elseif tag == 2 then
            local guanZhanPacket = NetSystem:CreateToSendPacket(PacketDefine.PacketDefine_GuoZhan_Request_Send)
            guanZhanPacket._Param = 7
            guanZhanPacket._DestJuDianID = 0
            NetSystem:SendPacket(guanZhanPacket)
        elseif tag == 3 then
            UISystem:OpenUI(UIType.UIType_FeatsTop)
        elseif tag == 4 then
        end
    end
end

return UIFeats
