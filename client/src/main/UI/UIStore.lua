--
-- 文件名称：UIStore.lua
-- 功能描述：UIStore
-- 文件说明：UIStore
-- 作    者：田凯
-- 创建时间：2015-6-29
--  修改
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
require("cocos.ui.DeprecatedUIEnum")
require("cocos.extension.ExtensionConstants")

local B_STATE_ITEM = 1
local B_STATE_GIFT = 2
local B_STATE_WARRIOR = 3
local B_STATE_CLOSE = 4
local B_STATE_STORE = 5

local I_STATE_BUY = 1
local I_STATE_CANLL = 2
local I_STATE_ADD = 3
local I_STATE_DEL = 4
local CELL_COL_ROW = 5

--按住数量一直增加使用到的变量
local clickTimer = 1
local scheduler = nil
local myupdate = nil

local CELL_SIZE = cc.size(770, 200)
local ItemDataManager = GameGlobal:GetItemDataManager()

local UISystem = GameGlobal:GetUISystem()
local _Instance = nil 
local UIStore = class("UIStore", UIBase)

function UIStore:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_StoreUI
    self._ResourceName = "UIStore.csb"  
end

function UIStore:Load()
    UIBase.Load(self)
    _Instance = self
    self._Buttons = {}
    self._TabText = {}
    self._Slider = nil
    for i = 1, 5 do
        local btn = self:GetUIByName("btn_"..i)
        btn:setTag(i)
        btn:addTouchEventListener(handler(self, self.TouchEvent))
        self._Buttons[i] = btn
    end 
    for i = 1, 3 do
        self._TabText[i] = seekNodeByName(self._Buttons[i], "Text_1")
    end
    self. _GoldText = self:GetUIByName("Text_YuanBao")
    -- tableView 
    local center = seekNodeByName(self._RootPanelNode, "Panel_Center")
    self._GridView = CreateTableView(-373, -238, 770, 385, 1, self)
    center:addChild(self._GridView, 0, 99)
    self._SelectFrame = display.newSprite("meishu/ui/gg/UI_gg_zhuangbeikuang_xuanzhong.png", 0, 800, {scale9 = true, capInsets = cc.rect(10, 10, 58, 58), rect = cc.rect(0, 0, 89, 89)})
    self._SelectFrame:setPreferredSize(cc.size(144, 125))

    self._Slider = self:GetUIByName("Slider_2")
    self._CellType = 1
    self._TabIndex = 0
    self._CurPropID = 0
    self._BuyNum = 0
    self._RootUINode:retain()
     
    local StoreList = ItemDataManager:GetStoreListByType(1)
    ItemDataManager._ItemList = {}
    ItemDataManager._GiftList = {}
    ItemDataManager._OtherList = {}
    for i =  1, #StoreList do
        local data = {}
        data[1] = tonumber(StoreList[i].id2)  -- id
        data[2] = StoreList[i].num      -- num
        data[3] = 0
        local type = StoreList[i].type
        data[4] = StoreList[i].price1  -- price
        data[5] = StoreList[i].vipprice  -- vprice  
        if tonumber(data[1])< 20000 and tonumber(data[1])> 15002 then
            data[6] = GetWarriorPath(GetPropDataManager()[tonumber(data[1])]["icon"])
            print(data[6])
        else
            data[6] = GetPropPath(data[1])  -- vprice
        end
        
        data[7] = StoreList[i].viplv  -- vprice
        data[8] = StoreList[i].star  -- vprice
        if type == 1 then
            table.insert(ItemDataManager._ItemList, data)
        elseif type == 2 then
            table.insert(ItemDataManager._GiftList, data)
        elseif type == 3 then
            table.insert(ItemDataManager._OtherList, data)
        end
    end
    
    table.sort(ItemDataManager._ItemList, function(a, b)
       return a[8] > b[8]
    end)
    
    self._ItemList = ItemDataManager:GetStoreItem()
    self._GiftList = ItemDataManager:GetStoreGift()
    self._OtherList = ItemDataManager:GetStoreOther()
    self:OpenUISucceed()
    self:ChangeTabState(1)
end

function UIStore:Unload()
    UIBase:Unload()
    self._ResourceName = nil
    self.Type = nil
    self._ItemList = nil
    self._GiftList = nil
    self._OtherList = nil
    self._RootUINode:removeChildByTag(99, true)
    self._GridView = nil
end

function UIStore:Open()
    UIBase.Open(self)
    self:addEvent(GameEvent.GameEvent_UIStore_Succeed, self.OpenUISucceed)
    self:addEvent(GameEvent.GameEvent_UIStore_Update, self.UpdateStoreInfo)
    self:addEvent(GameEvent.GameEvent_UIStoreBuy_Succeed, self.BugSucceed)
end

function UIStore:Close()
    UIBase.Close(self)
end

function UIStore:OpenUISucceed(event)
    if self._CurPropID == 0 then
        self._GridView:reloadData()
        self:SimulateClickButton(0, 1)
    else
        local state = event._usedata
        if state == 0 then
            local pos = self._SelectFrame:convertToWorldSpace(cc.p(72, 0))
            CreateTipAction(self._RootUINode, ChineseConvert["UITitle_8"], pos)
            RemoveMsg(PacketDefine.PacketDefine_ShopBuy)
        end
    end
    self:UpdateStoreInfo()
end

function UIStore:UpdateStoreInfo()
    local gamePlayerDataManager = GameGlobal:GetGamePlayerDataManager()
    local roleInfo = gamePlayerDataManager:GetMyselfData()
    _Instance._GoldText:setString(roleInfo._Gold)
end

function UIStore.ScrollViewDidScroll(view)
    local point = view:getContentOffset()
    local len = view:getContentSize().height - view:getViewSize().height
    local percent = - (point.y / len)
    if _Instance._Slider ~= nil then
        _Instance._Slider:setPercent((1 - percent)*100)
    end
end

function UIStore.NumberOfCellsInTableView()
    local len = 0
    if _Instance._TabIndex == B_STATE_ITEM then
        len = #_Instance._ItemList%CELL_COL_ROW == 0 and math.floor(#_Instance._ItemList/CELL_COL_ROW) or math.floor(#_Instance._ItemList/CELL_COL_ROW) + 1
    elseif _Instance._TabIndex == B_STATE_GIFT then
        len = #_Instance._GiftList%CELL_COL_ROW == 0 and math.floor(#_Instance._GiftList/CELL_COL_ROW) or math.floor(#_Instance._GiftList/CELL_COL_ROW) + 1
    elseif _Instance._TabIndex == B_STATE_WARRIOR then
        len = #_Instance._OtherList%CELL_COL_ROW == 0 and math.floor(#_Instance._OtherList/CELL_COL_ROW) or math.floor(#_Instance._OtherList/CELL_COL_ROW) + 1
    end
    return len
end

function UIStore.TableCellTouched(view, cell)
    _Instance._CurStoreIndex = cell:getIdx() * CELL_COL_ROW + _Instance._CellType
    _Instance._CurItemPrice = _Instance:getCurPropList(_Instance._TabIndex)[_Instance._CurStoreIndex][4]
    _Instance:OpenItemInfoNotifiaction()
end

function UIStore.CellSizeForTable(view, idx)
    return 770, 195
end

function UIStore:SimulateClickButton(idx, id)
    local cell = self._GridView:cellAtIndex(idx)
    if cell ~= nil then
        local layout = cell:getChildByTag(idx)
        local panel = seekNodeByName(layout, "Panel_1")
        local button = seekNodeByName(layout, "Btn_"..id)
        if button ~= nil then
            SimulateClickButton(button, handlers(self, self.TableViewItemTouchEvent, 2)) 
        end
    end
end

function UIStore:TableViewItemTouchEvent(value)
    local eventType = value
    if type(value) == "table" then
        eventType = value.eventType
    end
    if eventType == ccui.TouchEventType.ended then
        _Instance._BuyNum = 1
        _Instance._OpenInfo = true
--        _Instance._SelectFrame:removeFromParent(false)
--        self:addChild(_Instance._SelectFrame, 10)
--        _Instance._SelectFrame:setPosition(72, 61)
        _Instance._CellType = self:getTag()
    end
end

function UIStore.TableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
        cell:retain()
    end
    cell:removeAllChildren(true)
    local layout = cc.CSLoader:createNode("csb/ui/StoreItem.csb")
    for i = 1 , CELL_COL_ROW do
        local btn = seekNodeByName(layout, "Btn_"..i)
        btn:setTitleText("")
        btn:setTag(i)
        btn:addTouchEventListener(_Instance.TableViewItemTouchEvent)
        seekNodeByName(btn, "Image_"..i):setVisible(false)
        btn:setSwallowTouches(false)  
    end

    for i = 1 , CELL_COL_ROW do
        local btn = seekNodeByName(layout, "Btn_"..i.."_0")
        --btn:setTitleText("")
        btn:setTag((idx * 100) + i)
        btn:addTouchEventListener(_Instance.OpenItemInfoToBuy)
        btn:setSwallowTouches(false)  
    end
    layout:setPosition(cc.p(0, 0))
    cell:addChild(layout, 0, idx)
    _Instance:InitCell(cell, idx)

    return cell
end

function UIStore:InitCell(cell, idx)
    local layout = cell:getChildByTag(idx)
    local tabList =  _Instance:getCurPropList(_Instance._TabIndex)
    
    for i = 1 ,CELL_COL_ROW do
        local btn = seekNodeByName(layout, "Btn_"..i) 
        local buyBtn = seekNodeByName(layout, "Btn_"..i.."_0")
        buyBtn:setScale(1)
        btn:setScale(1)
        local icon = seekNodeByName(btn, "Image_"..i)
        icon:setVisible(true)
        if idx * CELL_COL_ROW + i<= # tabList then
            if GetPlayer()._VIPLevel >= tabList[idx * CELL_COL_ROW + i][7]  then
                local propId = tabList[idx * CELL_COL_ROW + i][1]
                local prop = ItemDataManager:GetItem(propId)
                local iconId = tabList[idx * CELL_COL_ROW + i][6]
                icon:loadTexture(iconId, UI_TEX_TYPE_LOCAL)
--                local color = GetQualityColor(GetPropDataManager()[propId]["quality"])
                  
                local name = seekNodeByName(btn, "Text_1_0")
--                name:setTextColor(color)
                name:setString(GetPropDataManager()[propId]["name"])
--                name:enableOutline(cc.c4b(78, 41, 12, 5), 1)
                local price = ccui.Helper:seekWidgetByName(btn, "Text_1")
                price:setString(tabList[idx * CELL_COL_ROW + i][4])
--                price:enableOutline(cc.c4b(0, 0, 0, 250), 1)
            else
                btn:setScale(0)
                seekNodeByName(layout, "Btn_"..i.."_0"):setScale(0)
            end
        else
            btn:setScale(0)
            seekNodeByName(layout, "Btn_"..i.."_0"):setScale(0)
        end
    end
end

-- show prop item
function UIStore:OpenItemInfoToBuy()
    print(self:getTag())
    local idx = math.floor(self:getTag() / 100)
    _Instance:SimulateClickButton(idx, self:getTag()- 100 * idx)
end

function UIStore:OpenItemInfoNotifiaction()
    if not self._OpenInfo then
        return
    end
    self._InfoData = {}
    self._InfoText = {}
    local propId = self:getCurPropList(self._TabIndex)[self._CurStoreIndex][1]
    self._CurPropID = propId
    local layout = cc.CSLoader:createNode("csb/ui/BuyInfo.csb")
    seekNodeByName(layout, "Panel_3"):setSwallowTouches(true) 
    seekNodeByName(layout, "Panel_3"):setTag(-1) 
    --seekNodeByName(layout, "Panel_3"):addTouchEventListener(_Instance.SceneCallBackEvent)
    seekNodeByName(layout, "Button_Close"):addTouchEventListener(self.SceneCallBackEvent)
    local panel = seekNodeByName(layout, "Panel_2") 
    seekNodeByName(seekNodeByName(panel, "title"), "Text_1"):enableOutline(cc.c4b(77, 39, 18, 250), 2)
    panel:setSwallowTouches(true) 
    for i = 1, 5 do
        if i~= 5 then
            local btn = ccui.Helper:seekWidgetByName(panel, "Button_"..i)
            btn:setTag(i)
            if i == 3 or i == 4 then
                btn:addTouchEventListener(self.PressContinue)
            elseif i == 2 then
                btn:addTouchEventListener(handler(self, self.StoreBuyInfo))
            else
                btn:addTouchEventListener(handler(self, self.StoreBuyInfo))
            end
        end
        local text = ccui.Helper:seekWidgetByName(panel, "Text_"..i)
        if i == 1 then
            self._InfoData[i] = seekNodeByName(panel, "Text_7")
            local color = GetQualityColor(GetPropDataManager()[propId]["quality"])
            self._InfoData[i]:setTextColor(color)
            self._InfoData[i]:enableOutline(cc.c4b(77, 39, 18, 250), 1)
        end
        if i == 2 then
            self._InfoData[i] = seekNodeByName(panel, "Text_8")
        end
        self._InfoText[i] = text
    end
    
    self._InfoData[6] = seekNodeByName(panel, "Text_6")
    self._InfoData[6]:setString(GetPlayer()._Gold)
    local icon = ccui.Helper:seekWidgetByName(panel, "icon")
    icon:loadTexture(self:getCurPropList(self._TabIndex)[self._CurStoreIndex][6], UI_TEX_TYPE_LOCAL)
    self._InfoData[1]:setString( GetPropDataManager()[propId]["name"])
    self._InfoData[2]:setString( self:getCurPropList(self._TabIndex)[self._CurStoreIndex][4])
    self._InfoText[5]:setString( GetPropDataManager()[propId]["desc"])
    self._RootPanelNode:addChild(layout, 1100, 101)
    self._OpenInfo = false
end

function UIStore:sendTrainMessage(tag)
    if clickTimer == 1 then
        if tag == I_STATE_ADD then
            _Instance._BuyNum = _Instance._BuyNum + 1 
            if _Instance._BuyNum >= 99 then
                _Instance._BuyNum = 99
            end
            _Instance._InfoData[2]:setString(_Instance._BuyNum * _Instance._CurItemPrice)
            _Instance._InfoText[4]:setString(_Instance._BuyNum)
        elseif tag == I_STATE_DEL then
            _Instance._BuyNum = _Instance._BuyNum - 1
            if _Instance._BuyNum <= 1 then
                _Instance._BuyNum = 1
            end
            _Instance._InfoData[2]:setString(_Instance._BuyNum * _Instance._CurItemPrice)
            _Instance._InfoText[4]:setString(_Instance._BuyNum)
        end
    else
        if scheduler ~= nil then
            scheduler:unscheduleScriptEntry(myupdate)
            scheduler = nil
        end
    end
end

function UIStore.PressContinue(sender, eventType)
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
        myupdate = scheduler:scheduleScriptFunc(update, 0.05, false)
    elseif eventType == ccui.TouchEventType.canceled then
        clickTimer = 0
    elseif eventType == ccui.TouchEventType.ended then
        clickTimer = 0
    end
end

function UIStore:BugSucceed()
    playAnimationObject(UISystem:GetUIRootNode(), 1, 480, 250, "animation0")
end

function UIStore:StoreBuyCommit(eventType)
    _Instance._RootPanelNode:removeChildByTag(101, true)
    SendMsg(PacketDefine.PacketDefine_ShopBuy_Send, {_Instance._CurPropID, _Instance._BuyNum, 1})
end

function UIStore:StoreBuyInfo(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
        if tag == I_STATE_BUY then
            local gamePlayerDataManager = GameGlobal:GetGamePlayerDataManager()
            local roleInfo = gamePlayerDataManager:GetMyselfData()
            if roleInfo._Gold >=  self._CurItemPrice * self._BuyNum  then
                local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                UITip:SetStyle(0, string.format("总共花费%s元宝，是否确认购买", self._CurItemPrice * self._BuyNum))
                UITip:RegisteDelegate(self.StoreBuyCommit, 1)
            else
                OpenRechargeTip()
            end
        elseif tag == I_STATE_CANLL then
            self._BuyNum = math.floor(GetPlayer()._Gold / self._CurItemPrice)
            if self._BuyNum >= 99 then
                self._BuyNum = 99
            end
            self._InfoData[2]:setString(self._BuyNum * self._CurItemPrice)
            self._InfoText[4]:setString(self._BuyNum)
        end
    end
end

function UIStore:SceneCallBackEvent(eventType)
    if eventType == ccui.TouchEventType.ended then
         _Instance._RootPanelNode:removeChildByTag(101, true)
    end
end

function UIStore:getCurPropList(tab)
    local tabList
    if tab == B_STATE_ITEM then
        tabList = self._ItemList
    elseif tab == B_STATE_GIFT then
        tabList = self._GiftList
    elseif tab == B_STATE_WARRIOR then
        tabList = self._OtherList
    end
    return tabList
end

function UIStore:ChangeTabState(index)

    if self._TabIndex == index then
        return
    end
    if B_STATE_WARRIOR == index then
        CreateTipAction(_Instance._RootUINode, "暂未开放，敬请期待！", cc.p(480, 270))
        return
    end

    for i = 1, 3 do
        if index == i then
            self._Buttons[i]:setLocalZOrder(3)
            self._Buttons[i]:loadTextures("meishu/ui/gg/UI_gg_yeqian_01.png", UI_TEX_TYPE_LOCAL)
            self._Buttons[i]:setPositionX(414)
            self._TabText[i]:setPositionX(27)
            self._Buttons[i]:setTouchEnabled(false)
        else
            self._Buttons[i]:setLocalZOrder(-1)
            self._Buttons[i]:loadTextures("meishu/ui/gg/UI_gg_yeqian_02.png", UI_TEX_TYPE_LOCAL)
            self._Buttons[i]:setPositionX(420)
            self._TabText[i]:setPositionX(17)
            self._Buttons[i]:setTouchEnabled(true)
        end
    end
    self._TabIndex = index
    self._GridView:reloadData()
end

function UIStore:TouchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
            print(tag)
        if tag == B_STATE_CLOSE then
            UISystem:CloseUI(UIType.UIType_StoreUI)
        elseif tag == B_STATE_ITEM then
            self:ChangeTabState(tag)     
        elseif tag == B_STATE_GIFT then
            self:ChangeTabState(tag)
        elseif tag == B_STATE_WARRIOR then
            self:ChangeTabState(tag)
        elseif tag == B_STATE_STORE then
            PlaySound(Sound_27)   
            UISystem:OpenUI(UIType.UIType_UIRecharge)
        end 
    end
end

return UIStore