----
-- 文件名称：UIBuy.lua
-- 功能描述:用于商城外单个物品的购买
-- 文件说明：用于商城外单个物品的购买
-- 作    者：lsy
-- 创建时间：2015-7-20
--  修改
--  
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
require("cocos.ui.DeprecatedUIEnum")
require("cocos.extension.ExtensionConstants")

--确认
local I_STATE_BUY = 1
--取消
local I_STATE_CANLL = 2
--增加
local I_STATE_ADD = 3
--减少
local I_STATE_DEL = 4
--按住数量一直增加使用到的变量
local clickTimer = 1
local scheduler = nil
local myupdate = nil

local UISystem = GameGlobal:GetUISystem()
local _Instance = nil 
local UIBuy = class("UIBuy", UIBase)
local gScheduler
local gSchedulerId

function UIBuy:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_BuyItem
    self._ResourceName = "BuyInfo.csb"  
end

function UIBuy:Load()
    UIBase.Load(self)
    self._RootUINode:setPosition(0, 0)
    self._RootUINode:setAnchorPoint(cc.p(0, 0))
    _Instance = self
    _Instance._InfoData = {}
    _Instance._InfoText = {}
    _Instance._BuyNum = 1
    self._CallBack = nil
end


function UIBuy:Unload()
    UIBase:Unload()
end

function UIBuy:Open()
    UIBase.Open(self)
    self._BuyNum = 1
end

function UIBuy:Close()
    UIBase.Close(self)
end
------------
--公用数据接口
--propId 传入的物品
--------
function UIBuy:OpenItemInfoNotifiaction(propId, num)
    _Instance._CurPropID = propId
    local layout = cc.CSLoader:createNode("csb/ui/BuyInfo.csb")
    seekNodeByName(layout, "Panel_1"):setSwallowTouches(true) 
    seekNodeByName(layout, "Panel_1"):setTag(-1) 
    seekNodeByName(layout, "Panel_1"):addTouchEventListener(_Instance.SceneCallBackEvent)
    seekNodeByName(layout, "Button_Close"):addTouchEventListener(_Instance.SceneCallBackEvent)
    local panel = seekNodeByName(layout, "Panel_2") 
    panel:setSwallowTouches(true) 
    for i = 1, 5 do
        if i~= 5 then
            local btn = ccui.Helper:seekWidgetByName(panel, "Button_"..i)
            btn:setTag(i)
            if i == 3 or i == 4 then
                btn:addTouchEventListener(_Instance.PressContinue)
            else
                btn:addTouchEventListener(_Instance.StoreBuyInfo)
            end
        end
        if i == 2 then
            _Instance._InfoData[i] = cc.Label:createWithTTF("", FONT_MSYH, BASE_FONT_SIZE)
            _Instance._InfoData[i]:setAnchorPoint(cc.p(0, 0.5))
            _Instance._InfoData[i]:setPosition(cc.p(260, 320 - 30 * i))
            panel:addChild(_Instance._InfoData[i])
        end
        local text = ccui.Helper:seekWidgetByName(panel, "Text_"..i)
        _Instance._InfoText [i] = text
    end
    
    local text = ccui.Helper:seekWidgetByName(panel, "Text_7")
    _Instance._InfoText[7] = text
    local text = ccui.Helper:seekWidgetByName(panel, "Text_8")
    _Instance._InfoText[8] = text
    local btn = ccui.Helper:seekWidgetByName(panel, "Button_Close")
    btn:setTag(-1)
    btn:addTouchEventListener(_Instance.StoreBuyInfo)
    _Instance._InfoData[6] = seekNodeByName(panel, "Text_6")
    _Instance._InfoData[6]:setString(GetPlayer()._Gold)
    local icon = ccui.Helper:seekWidgetByName(panel, "icon")
    icon:loadTexture(GetPropPath(GetPropDataManager()[propId]["icon"]), UI_TEX_TYPE_LOCAL)
    _Instance._InfoText[7]:setString( GetPropDataManager()[propId]["name"])
    _Instance._CurItemPrice = GameGlobal:GetItemDataManager():GetItemPrice(propId)
    _Instance._InfoText[8]:setString(GameGlobal:GetItemDataManager():GetItemPrice(propId))
    _Instance._InfoText[5]:setString( GetPropDataManager()[propId]["desc"])
    _Instance._RootPanelNode:addChild(layout, 1100, 102)
    
    if num ~= nil then
        _Instance._BuyNum = num
        _Instance._InfoText[4]:setString(_Instance._BuyNum)
    end
end

function UIBuy:SceneCallBackEvent(eventType)
    if eventType == ccui.TouchEventType.ended then
        _Instance._RootPanelNode:removeChildByTag(102, true)
    end
end

function UIBuy:sendTrainMessage(tag)
    if clickTimer == 1 then
        if tag == I_STATE_ADD then
            _Instance._BuyNum = _Instance._BuyNum + 1 
            if _Instance._BuyNum >= 99 then
                _Instance._BuyNum = 99
            end
            _Instance._InfoText[8]:setString(_Instance._BuyNum * _Instance._CurItemPrice)
            _Instance._InfoText [4]:setString(_Instance._BuyNum)
        elseif tag == I_STATE_DEL then
            _Instance._BuyNum = _Instance._BuyNum - 1
            if _Instance._BuyNum <= 1 then
                _Instance._BuyNum = 1
            end
            _Instance._InfoText[8]:setString(_Instance._BuyNum * _Instance._CurItemPrice)
            _Instance._InfoText[4]:setString(_Instance._BuyNum)
        end
    else
        if scheduler ~= nil then
            scheduler:unscheduleScriptEntry(myupdate)
            scheduler = nil
        end
    end
end

function UIBuy:setItemNum(num)
    _Instance._BuyNum = num
    _Instance._InfoText[4]:setString(_Instance._BuyNum)
end

function UIBuy.PressContinue(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        if scheduler ~= nil then
            scheduler:unscheduleScriptEntry(myupdate)
            scheduler = nil
        end
        local tag = sender:getTag()
        clickTimer = 1
        local function update(dt)
            _Instance:sendTrainMessage(tag)
        end
        scheduler = cc.Director:getInstance():getScheduler()
        _Instance:sendTrainMessage(tag)
        myupdate = scheduler:scheduleScriptFunc(update, 0.2, false)
    elseif eventType == ccui.TouchEventType.canceled then
        clickTimer = 0
    elseif eventType == ccui.TouchEventType.ended then
        clickTimer = 0
    end
end

function UIBuy:StoreBuyInfo(eventType)
    local tag = self:getTag()
    if eventType == ccui.TouchEventType.began then
        if tag == I_STATE_ADD or tag == I_STATE_DEL then
            local function update()
                if tag == I_STATE_ADD then
                    _Instance._BuyNum = _Instance._BuyNum + 1 
                    if _Instance._BuyNum >= 99 then
                        _Instance._BuyNum = 99
                    end
                    _Instance._InfoText[8]:setString(_Instance._BuyNum * _Instance._CurItemPrice)
                    _Instance._InfoText [4]:setString(_Instance._BuyNum)
                elseif tag == I_STATE_DEL then
                    _Instance._BuyNum = _Instance._BuyNum - 1
                    if _Instance._BuyNum <= 1 then
                        _Instance._BuyNum = 1
                    end
                    _Instance._InfoText[8]:setString(_Instance._BuyNum * _Instance._CurItemPrice)
                    _Instance._InfoText[4]:setString(_Instance._BuyNum)
                end
            end
            gScheduler = cc.Director:getInstance():getScheduler()
            gSchedulerId = gScheduler:scheduleScriptFunc(update, 0.05, false)
        end
    elseif eventType == ccui.TouchEventType.ended then
        if tag == I_STATE_BUY then
            local gamePlayerDataManager = GameGlobal:GetGamePlayerDataManager()
            local roleInfo = gamePlayerDataManager:GetMyselfData()

            if roleInfo._Gold >=  (GameGlobal:GetItemDataManager():GetItemPrice(_Instance._CurPropID) * _Instance._BuyNum) then
                SendMsg(PacketDefine.PacketDefine_ShopBuy_Send, {_Instance._CurPropID, _Instance._BuyNum, 1})
                if _Instance._CallBack ~= nil then
                    _Instance._CallBack()
                    _Instance._CallBack = nil
                end
                UISystem:CloseUI(UIType.UIType_BuyItem)
            else
                local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                UITip:SetStyle(0, GameGlobal:GetTipDataManager(UI_sc_01)..",请去充值")
                UITip:RegisteDelegate(UIBuy.OnQuickConfirm, 1)
            end
        elseif tag == -1 then
            UISystem:CloseUI(UIType.UIType_BuyItem)
        elseif tag == I_STATE_CANLL then
            _Instance._BuyNum = math.floor(GetPlayer()._Gold / _Instance._CurItemPrice)
            if _Instance._BuyNum >= 99 then
                _Instance._BuyNum = 99
            end
            _Instance._InfoText[8]:setString(_Instance._BuyNum * _Instance._CurItemPrice)
            _Instance._InfoText[4]:setString(_Instance._BuyNum)
        elseif tag == I_STATE_ADD then
            if gScheduler ~= nil then
                gScheduler:unscheduleScriptEntry(gSchedulerId)
                gScheduler = nil
            end
        elseif tag == I_STATE_DEL then
            if gScheduler ~= nil then
                gScheduler:unscheduleScriptEntry(gSchedulerId)
                gScheduler = nil
            end
        end
    end
end

function UIBuy:OnQuickConfirm()
    UISystem:OpenUI(UIType.UIType_UIRecharge)
end

return UIBuy