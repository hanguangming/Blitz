----
-- 文件名称：UIMonthCard.lua
-- 功能描述：UIMonthCard
-- 文件说明：
-- 作    者：
-- 创建时间：2015-8-5
-- 修改 ：
-- 
--
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
local UISystem = require("main.UI.UISystem")

local UIMonthCard = class("UIMonthCard", UIBase)

--构造函数
function UIMonthCard:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_MonthCardUI
    self._ResourceName = "UIMonthCard.csb" 
end

--Load
function UIMonthCard:Load()
    UIBase.Load(self)
    _Instance = self
    local center = seekNodeByName(self._RootPanelNode, "Panel_Center")
    local panel_left = seekNodeByName(center, "Panel_left")
    self._ButtonList = {}
    local btn = seekNodeByName(panel_left, "Button_buy")
    btn:setTag(1)
    btn:addTouchEventListener(self.TouchEvent)
    self._ButtonList[1] = btn
    local panel_right = seekNodeByName(center, "Panel_right")
    btn = seekNodeByName(panel_right, "Button_buy")
    btn:setTag(2)
    btn:addTouchEventListener(self.TouchEvent)
    self._ButtonList[2] = btn
    local cancel = self:GetUIByName("Close")
    cancel:setTag(-1)
    cancel:addTouchEventListener(self.TouchEvent)
--    local CustomRewardDataManager = GameGlobal:GetCustomRewardDataManager()
--    local str = CustomRewardDataManager[3142]["prop"]
--    local data = {}
--    data= SplitSet(str)
--    for i = 1, #data do
--        local icon = seekNodeByName(panel_left, "icon_"..i)
--        if data[i][1] ~= nil then
--            icon:setTexture("meishu/ui/gg/"..GetPropDataManager()[tonumber(data[i][1])]["quality"]..".png")
--            seekNodeByName(icon, "Image_1"):loadTexture(GetPropDataManager()[tonumber(data[i][1])]["icon"])
--            seekNodeByName(icon, "Text_1"):setString(tonumber(data[i][3]))
--        end
--    end
--    local str = CustomRewardDataManager[3143]["prop"]
--    local data = {}
--    data= SplitSet(str)
--    for i = 1, #data do
--        local icon = seekNodeByName(panel_right, "icon_"..i)
--        if data[i][1] ~= nil then
--            icon:setTexture("meishu/ui/gg/"..GetPropDataManager()[tonumber(data[i][1])]["quality"]..".png")
--            seekNodeByName(icon, "Image_1"):loadTexture(GetPropDataManager()[tonumber(data[i][1])]["icon"])
--            seekNodeByName(icon, "Text_1"):setString(tonumber(data[i][3]))
--        end
--    end
    self._day1 = seekNodeByName(panel_left, "day")
    self._day2 = seekNodeByName(panel_right, "day")
end

--Unload
function UIMonthCard:Unload()
    UIBase.Unload(self)
end

--打开
function UIMonthCard:Open()
    UIBase.Open(self)
    local roleInfo = GetPlayer()
    self.OpenCallBack = AddEvent(GameEvent.GameEvent_UIMonthCard_Succeed, self.OpenUISuccess)
    SendMsg(PacketDefine.PacketDefine_GetRewardInfo_Send, {0, 3})
    SendMsg(PacketDefine.PacketDefine_GetRewardInfo_Send, {0, 4})
end

--关闭
function UIMonthCard:Close()
    UIBase.Close(self)
    RemoveEvent(self.OpenCallBack)
    self.OpenCallBack = nil
end

function UIMonthCard:OpenUISuccess()
    local tag = 0
    if self._usedata[2] == 3 then
        tag = 1
        print(self._usedata[3])
        _Instance._day1:setString(self._usedata[3])
    else
        tag = 2
        _Instance._day2:setString(self._usedata[3])
    end
    _Instance._ButtonList[tag]._state = self._usedata[1]
    _Instance._ButtonList[tag]:setBright(true)
    _Instance._ButtonList[tag]:setTouchEnabled(true)
    if self._usedata[1] == 0 then
        _Instance._ButtonList[tag]:getTitleRenderer():setString(GameGlobal:GetTipDataManager(UI_BUTTON_NAME_51))
    elseif self._usedata[1] == 1 then
        _Instance._ButtonList[tag]:getTitleRenderer():setString(GameGlobal:GetTipDataManager(UI_BUTTON_NAME_43))
    elseif self._usedata[1] == 2 then
        _Instance._ButtonList[tag]:getTitleRenderer():setString(ChineseConvert["UITitle_5"])
        _Instance._ButtonList[tag]:setBright(false)
        _Instance._ButtonList[tag]:setTouchEnabled(false)
    end
end

function UIMonthCard:TouchEvent(eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = self:getTag()
        if tag == -1 then
            UISystem:CloseUI(UIType.UIType_MonthCardUI) 
        elseif tag == 1 then
            if self._state == 0 then
                SendMsg(PacketDefine.PacketDefine_MonthCard_Send, {1})
            elseif self._state == 1 then
                SendMsg(PacketDefine.PacketDefine_GetRewardInfo_Send, {1, 3})
            end
        elseif tag == 2 then
            if self._state == 0 then
                SendMsg(PacketDefine.PacketDefine_MonthCard_Send, {2})
            elseif self._state == 1 then
                SendMsg(PacketDefine.PacketDefine_GetRewardInfo_Send, {1, 4})
            end
        end
    end
end

return UIMonthCard
