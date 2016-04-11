----
-- 文件名称：UIShaChangRongYuShop.lua
-- 功能描述：沙场荣誉商店
-- 文件说明：沙场荣誉商店
-- 作    者：王雷雷
-- 创建时间：2015-7-28
--  修改
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
require("cocos.ui.DeprecatedUIEnum")
require("cocos.extension.ExtensionConstants")

local ItemDataManager = GameGlobal:GetItemDataManager()
local TableDataManager = GameGlobal:GetDataTableManager()
local UISystem = GameGlobal:GetUISystem()

local I_STATE_BUY = 1
local I_STATE_CANLL = 2
local I_STATE_ADD = 3
local I_STATE_DEL = 4

local B_STATE_ITEM = 1
local B_STATE_RongYu = 2
local B_STATE_Rank = 3
local B_STATE_CLOSE = -1

--一个Cell的 Item数目
local ITEMCOUNT_ONE_CELL = 5
local CELL_SIZE = cc.size(770, 200)

local scheduler = cc.Director:getInstance():getScheduler()

local UIShaChangRongYuShop = class("UIShaChangRongYuShop", UIBase)

function UIShaChangRongYuShop:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_RongYuShop
    self._ResourceName = "UIShaChangRongYuShop.csb"  
end

function UIShaChangRongYuShop:Load()
    UIBase.Load(self)
    
    self._RongYuText = self:GetWigetByName("Text_RongYu")
    self._Buttons = {}
    for i = 1, 3 do
        self._Buttons[i] = self:GetWigetByName("Button_"..i)
        self._Buttons[i]:setTag(i)
        self._Buttons[i]:addTouchEventListener(handler(self, self.TouchEvent))
    end

    local bgPanel = self:GetWigetByName("Panel_ItemBg")
    self._GridView = CreateTableView_(40, -15, 770, 400, cc.TABLEVIEW_FILL_BOTTOMUP, self)
    bgPanel:addChild(self._GridView, 0, 99)

    local closeButton = self:GetWigetByName("Button_Close")
    closeButton:setTag(B_STATE_CLOSE)
    closeButton:addTouchEventListener(handler(self, self.TouchEvent))
end

function UIShaChangRongYuShop:Open()
    UIBase.Open(self)

    self._CellType = 0
    self._CurrentItemIndex = 0

    self._BuyAmount = 0

    self._InfoData = {}
    self._InfoText = {}

    self:ChangeTabState(2)

    self._GridView:reloadData()
    self:RefreshRongYu()

    --事件注册
    self:addEvent(GameEvent.GameEvent_MyselfInfoChange, self.OnRongYuListener)
    self:addEvent(GameEvent.GameEvent_UIStore_Succeed, function()
        CreateAnimation(self._RootPanelNode, 480, 250, "csb/texiao/ui/T_u_ziti_goumai.csb", "animation0", false, 0, 1)
    end)
end

function UIShaChangRongYuShop:TouchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
        if tag == B_STATE_CLOSE then
            UISystem:CloseUI(UIType.UIType_RongYuShop)
        elseif tag == B_STATE_ITEM then
            UISystem:OpenUI(UIType.UIType_ShaChangDianBing)  
            self:CloseUI()
        elseif tag == B_STATE_RongYu then

        elseif tag == B_STATE_Rank then
            UISystem:OpenUI(UIType.UIType_ShaChangRank)
            self:CloseUI()
        end 
    end
end

function UIShaChangRongYuShop:ChangeTabState(index)
    for i =  1, 3 do
        seekNodeByName(self._Buttons[i], "Text_1"):setTextColor(cc.c3b(36, 47, 13))
        seekNodeByName(self._Buttons[i], "Text_1"):enableOutline(cc.c4b(36, 47, 13, 50), 1)
    end
    seekNodeByName(self._Buttons[index], "Text_1"):setTextColor(cc.c3b(255, 230, 142))
end

----左上荣誉值刷新
function UIShaChangRongYuShop:RefreshRongYu()
    local gamePlayerDataManager = GameGlobal:GetGamePlayerDataManager()
    local roleInfo = gamePlayerDataManager:GetMyselfData()
    self._RongYuText:setString(roleInfo._RongYuZhi)
end

function UIShaChangRongYuShop:NumberOfCellsInTableView()
    local rongYuData = ItemDataManager:GetStoreListByType(2) or {}
    return math.ceil(#rongYuData / ITEMCOUNT_ONE_CELL)
end

function UIShaChangRongYuShop:TableCellTouched(view, cell)
    if self._CellType <= 0 then
        return
    end
    self._CurrentItemIndex = cell:getIdx() * ITEMCOUNT_ONE_CELL + self._CellType
    self:OpenItemInfoNotifiaction()
end

function UIShaChangRongYuShop:CellSizeForTable(view, idx)
    return CELL_SIZE.width, CELL_SIZE.height
end

function UIShaChangRongYuShop:OnShopItemBtnClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self._CellType = sender:getTag()
    end
end

function UIShaChangRongYuShop:TableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
    end
    cell:removeAllChildren(true)
    local layout = cc.CSLoader:createNode("csb/ui/StoreItem.csb")
    for i = 1 , ITEMCOUNT_ONE_CELL do
        local btn = seekNodeByName(layout, "Btn_"..i)
        local btn1 = seekNodeByName(layout, "Btn_"..i.."_0")
        btn1:setSwallowTouches(false)
        btn:setTitleText("")
        btn:setTag(i)
        btn:addTouchEventListener(handler(self, self.OnShopItemBtnClick))
        btn:setSwallowTouches(false)  
    end
    
    layout:setPosition(cc.p(0, 0))
    cell:addChild(layout, 0, idx)
    self:InitCell(cell, idx)
    return cell
end

function UIShaChangRongYuShop:InitCell(cell, idx)
    local layout = cell:getChildByTag(idx)
    local shopItemList = ItemDataManager:GetStoreListByType(2)
    for i = 1 ,ITEMCOUNT_ONE_CELL do
        local currentItemIndex = idx * ITEMCOUNT_ONE_CELL + i
        local btn = seekNodeByName(layout, "Btn_"..i)
        if  currentItemIndex <= #shopItemList then
            local currentShopItemData = shopItemList[currentItemIndex]
            local propDataTable = GetPropDataManager()
            local currentItemData = propDataTable[tonumber(currentShopItemData.id2)]
            local name = seekNodeByName(btn, "Text_1_0")
            name:setString(currentItemData.name)

            local warriorPrice = currentShopItemData.price2
            local price = ccui.Helper:seekWidgetByName(btn, "Text_1")
            price:setString(warriorPrice)

            --图标
            local icon = seekNodeByName(btn, "Image_"..i)
            local iconId = GetPropPath(tonumber(currentShopItemData.id2))
            icon:loadTexture(iconId, UI_TEX_TYPE_LOCAL)
            
            seekNodeByName(btn, "icon"):setTexture("meishu/ui/shachangdianbing/UI_sd_rongyu.png")
            seekNodeByName(btn, "icon"):setScale(0.8)
        else
            btn:setScale(0)
            seekNodeByName(layout, "Btn_"..i.."_0"):setScale(0)
        end
    end
end

function UIShaChangRongYuShop:OnRongYuListener()
    self:RefreshRongYu()
end

--弹出的购买框的关闭
function UIShaChangRongYuShop:SceneCallBackEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        --关闭之后，重置购买项
        self._CellType = 0
        self._RootPanelNode:removeChildByTag(101, true)
    end
end

function UIShaChangRongYuShop:OpenItemInfoNotifiaction()
    local shopItemList = ItemDataManager:GetStoreListByType(2)
    local propDataTable = GetPropDataManager()

    local currentSelectItemData = nil
    if self._CurrentItemIndex >= 0 then
        currentSelectItemData = shopItemList[self._CurrentItemIndex]
    end 
    
    if currentSelectItemData == nil then
        return
    end

    local currentItemData = propDataTable[tonumber(currentSelectItemData.id2)]
    self._BuyAmount = 1
    local layout = cc.CSLoader:createNode("csb/ui/BuyInfo.csb")
    
    seekNodeByName(layout, "Panel_3"):setSwallowTouches(true) 
    seekNodeByName(layout, "Panel_3"):setTag(-1) 
    seekNodeByName(layout, "Panel_3"):addTouchEventListener(handler(self, self.SceneCallBackEvent))
    seekNodeByName(layout, "Button_Close"):addTouchEventListener(handler(self, self.SceneCallBackEvent))
    seekNodeByName(layout, "Image_5"):setContentSize(cc.size(36, 40))
    seekNodeByName(layout, "Image_6"):setContentSize(cc.size(36, 40))
    seekNodeByName(layout, "Image_5"):loadTexture("meishu/ui/shachangdianbing/UI_sd_rongyu.png")
    seekNodeByName(layout, "Image_6"):loadTexture("meishu/ui/shachangdianbing/UI_sd_rongyu.png")
    
    local panel = seekNodeByName(layout, "Panel_2") 
    panel:setSwallowTouches(true) 
    for i = 1, 5 do
        if i~= 5 then
            local btn = ccui.Helper:seekWidgetByName(panel, "Button_"..i)
            btn:setTag(i)
            if i == 3 or i == 4 then
                btn:addTouchEventListener(handler(self, self.PressContinue))
            else
                btn:addTouchEventListener(handler(self, self.StoreBuyInfo))
            end
        end
        local text = ccui.Helper:seekWidgetByName(panel, "Text_"..i)
        if i == 1 then
            self._InfoData[i] = seekNodeByName(panel, "Text_7")
            local color = GetQualityColor(currentItemData.quality)
            self._InfoData[i]:setTextColor(color)
            self._InfoData[i]:enableOutline(cc.c4b(77, 39, 18, 250), 1)
        end
        if i == 2 then
            self._InfoData[i] = seekNodeByName(panel, "Text_8")
        end
        self._InfoText[i] = text
    end
    self._InfoData[6] = seekNodeByName(panel, "Text_6")
    self._InfoData[6]:setString(GetPlayer()._RongYuZhi)
    
    local currentItemData = propDataTable[tonumber(currentSelectItemData.id2)]
    local icon = ccui.Helper:seekWidgetByName(panel, "icon")
    icon:loadTexture(GetPropPath(tonumber(currentSelectItemData.id2)), UI_TEX_TYPE_LOCAL)
    self._InfoData[1]:setString(currentItemData.name)
    self._InfoText[5]:setString(currentItemData.desc)
    self._CurItemPrice = currentSelectItemData.price2
    self._InfoData[2]:setString(currentSelectItemData.price2)
    self._RootPanelNode:addChild(layout, 1100, 101)
end

function UIShaChangRongYuShop:sendTrainMessage(tag)
    if tag == I_STATE_ADD then
        self._BuyAmount = self._BuyAmount + 1 
        if self._BuyAmount >= 99 then
            self._BuyAmount = 99
        end
        self._InfoText [4]:setString(self._BuyAmount)
        self._InfoData[2]:setString(self._BuyAmount * self._CurItemPrice)
    elseif tag == I_STATE_DEL then
        self._BuyAmount = self._BuyAmount - 1
        if self._BuyAmount <= 1 then
            self._BuyAmount = 1
        end
        self._InfoText[4]:setString(self._BuyAmount)
        self._InfoData[2]:setString(self._BuyAmount * self._CurItemPrice)
    end
end

function UIShaChangRongYuShop:PressContinue(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        local tag = sender:getTag()
        local function update(dt)
            self:sendTrainMessage(tag)
        end
        self:sendTrainMessage(tag)
        self._ScheduleId = scheduler:scheduleScriptFunc(update, 0.05, false)
    elseif eventType == ccui.TouchEventType.canceled then
        scheduler:unscheduleScriptEntry(self._ScheduleId)
    elseif eventType == ccui.TouchEventType.ended then
        scheduler:unscheduleScriptEntry(self._ScheduleId)
    end
end

function UIShaChangRongYuShop:StoreBuyInfo(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local shopItemList = ItemDataManager:GetStoreListByType(2)
        
        local currentSelectItemData = nil
        if self._CurrentItemIndex >= 0 then
            currentSelectItemData =  shopItemList[self._CurrentItemIndex]
        end 
        if currentSelectItemData == nil then
            return
        end
       
        local tag = sender:getTag()
        if tag == I_STATE_BUY then
            local gamePlayerDataManager = GameGlobal:GetGamePlayerDataManager()
            local roleInfo = gamePlayerDataManager:GetMyselfData()
            local totalRongYu = currentSelectItemData.price2 * self._BuyAmount
            if roleInfo._RongYuZhi >= totalRongYu  then
                SendMsg(PacketDefine.PacketDefine_ShopBuy_Send, {tonumber(currentSelectItemData.id2), self._BuyAmount, 2})
                self._RootPanelNode:removeChildByTag(101, true)
                print("send PacketDefine_RongYuDuiHuan_Send", currentSelectItemData.prop, self._BuyAmount)
            else
                local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_rysd_RongYuBuZu))
            end
        elseif tag == I_STATE_CANLL then
            self._BuyAmount = math.floor(GetPlayer()._RongYuZhi / self._CurItemPrice)
            if self._BuyAmount >= 99 then
                self._BuyAmount = 99
            end
            self._InfoData[2]:setString(self._BuyAmount * self._CurItemPrice)
            self._InfoText[4]:setString(self._BuyAmount)
            
        elseif tag == I_STATE_ADD then
            self._BuyAmount = self._BuyAmount + 1 
            if self._BuyAmount >= 99 then
                self._BuyAmount = 99
            end
            self._InfoText [4]:setString(self._BuyAmount)
        elseif tag == I_STATE_DEL then
            self._BuyAmount = self._BuyAmount - 1
            if self._BuyAmount <= 1 then
                self._BuyAmount = 1
            end
            self._InfoText[4]:setString(self._BuyAmount)
        end
    end
end

return UIShaChangRongYuShop