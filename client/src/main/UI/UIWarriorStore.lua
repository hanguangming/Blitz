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

local B_STATE_WARRIOR = 1
local B_STATE_HUN = 2
local B_STATE_CLOSE = 4

local I_STATE_BUY = 1
local I_STATE_CANLL = 2
local I_STATE_ADD = 3
local I_STATE_DEL = 4
local CELL_COL_ROW = 5

--按住数量一直增加使用到的变量
local clickTimer = 1
local scheduler = nil
local myupdate = nil

local CELL_SIZE = cc.size(770, 190)
local ItemDataManager = GameGlobal:GetItemDataManager()
local CharacterDataManager =  GameGlobal:GetCharacterDataManager()
local propDataManager =  GameGlobal:GetPropDataManager()

local UISystem = GameGlobal:GetUISystem()
local _Instance = nil 
local UIWarriorStore = class("UIWarriorStore", UIBase)

function UIWarriorStore:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_WarriorStore
    self._ResourceName = "UIWarriorStore.csb"
end

function UIWarriorStore:Load()
    UIBase.Load(self)
    _Instance = self
    self._Buttons = {}
    self._CellType = 1
    self._Slider = nil
    for i = 1, 4 do
        local btn = self:GetUIByName("btn_"..i)
        btn:setTag(i)
        btn:addTouchEventListener(self.TouchEvent)
        self._Buttons[i] = btn
        self._Buttons[i]:retain()
    end 
    self. _GoldText = self:GetUIByName("Text_1")
    seekNodeByName(seekNodeByName(self._RootPanelNode, "TitleImage"), "TitleName")
    -- tableView 
    local center = seekNodeByName(self._RootPanelNode, "Panel_Center")
    self._GridView = CreateTableView(-350, -217, 750, 380, 1, self)
    center:addChild(self._GridView, 0, 99)
    self._SelectFrame = display.newSprite("meishu/ui/gg/UI_gg_zhuangbeikuang_xuanzhong.png", 0, 800, {scale9 = true, capInsets = cc.rect(10, 10, 58, 58), rect = cc.rect(0, 0, 89, 89)})
    --    self._SelectFrame:retain()
    self._SelectFrame:setPreferredSize(cc.size(144, 125))

    --    self._GridView:addChild(self._SelectFrame, 10)
    --    self._SelectFrame:retain()

    self._Slider = self:GetUIByName("Slider_2")

    self._CurPropID = 0
    self._BuyNum = 0
    self._RootUINode:retain()

    self._WarriorList = {}
    self._HunList = {}

    self:OpenUISucceed()
    _Instance:ChangeTabState(1)
    self._TabIndex = 1
    
--    local name ={GameGlobal:GetTipDataManager(UI_BUTTON_NAME_37), GameGlobal:GetTipDataManager(UI_BUTTON_NAME_48), GameGlobal:GetTipDataManager(UI_BUTTON_NAME_49)}
    --    CreateBaseUIAction(self._RootPanelNode, -200, 220, 4, GameGlobal:GetTipDataManager(UI_BUTTON_NAME_71), name, 3, self.TouchEvent, self.EndCallBack)
end

function UIWarriorStore.EndCallBack(value)
    _Instance._Buttons = value
    _Instance._Buttons[1]:setTag(1)
    _Instance._Buttons[2]:setTag(2)
    _Instance._Buttons[3]:setTag(3)
end  

function UIWarriorStore:Unload()
    UIBase:Unload()
    self._ResourceName = nil
    self.Type = nil
    self._ItemList = nil
    self._GiftList = nil
    self._OtherList = nil
    self._RootUINode:removeChildByTag(99, true)
    self._GridView = nil
end

function UIWarriorStore:Open()
    UIBase.Open(self)
    self.UpdateInfoCallBack = AddEvent(GameEvent.GameEvent_UIWarriorStore_Update, self.UpdateStoreInfo)
    self.BuySucceedCallBack = AddEvent(GameEvent.GameEvent_UIWarriorStoreBuy_Update, self.BugSucceed)
end

function UIWarriorStore:Close()
    UIBase.Close(self)
    RemoveEvent(self.UpdateInfoCallBack)
    RemoveEvent(self.BuySucceedCallBack)
    self.BuySucceedCallBack = nil
    self.UpdateInfoCallBack = nil
end

function UIWarriorStore:OpenUISucceed()
    local shopDataManager = GameGlobal:GetShopDataManager()
    for k, v in pairs(shopDataManager) do
        if tonumber(v.type1) == 3 then
            if tonumber(v.type) == 2 then
                table.insert(self._HunList, v)
            end
            if tonumber(v.type) == 1 then
                table.insert(self._WarriorList, v)
            end
        end
    end
    _Instance._GridView:reloadData()
--    _Instance:UpdateStoreInfo()
end

function UIWarriorStore:UpdateStoreInfo()
    local gamePlayerDataManager = GameGlobal:GetGamePlayerDataManager()
    local roleInfo = gamePlayerDataManager:GetMyselfData()
    _Instance._GoldText:setString(roleInfo._Gold)
end

function UIWarriorStore.ScrollViewDidScroll(view)
    local point = view:getContentOffset()
    local len = view:getContentSize().height - view:getViewSize().height
    local percent = - (point.y / len)
    if _Instance._Slider ~= nil then
        _Instance._Slider:setPercent((1 - percent)*100)
    end
end

function UIWarriorStore.NumberOfCellsInTableView()
    local len = 0
    if _Instance._TabIndex == B_STATE_WARRIOR then
        len = math.ceil(#_Instance._WarriorList / CELL_COL_ROW)
    elseif _Instance._TabIndex == B_STATE_HUN then
        len = math.ceil(#_Instance._HunList / CELL_COL_ROW)
    end
    return len
end

function UIWarriorStore.TableCellTouched(view, cell)
    _Instance._CurStoreIndex = cell:getIdx() * CELL_COL_ROW + _Instance._CellType
    _Instance._CurItemPrice = _Instance:getCurPropList(_Instance._TabIndex)[_Instance._CurStoreIndex]["price3"]
    _Instance._InfoText = {}
    _Instance:OpenItemInfoNotifiaction()
end

function UIWarriorStore.CellSizeForTable(view, idx)
    return 770, 190
end

function UIWarriorStore:SimulateClickButton(idx, id)
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

function UIWarriorStore:TableViewItemTouchEvent(value)
    local eventType = value
    if type(value) == "table" then
        eventType = value.eventType
    end
    if eventType == ccui.TouchEventType.ended then
        _Instance._InfoData = {}
        _Instance._BuyNum = 1
        _Instance._OpenInfo = true
        --        _Instance._SelectFrame:removeFromParent(false)
        --        self:addChild(_Instance._SelectFrame, 10)
        --        _Instance._SelectFrame:setPosition(72, 61)
        _Instance._CellType = self:getTag()
    end
end

function UIWarriorStore.TableCellAtIndex(view, idx)
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

function UIWarriorStore:InitCell(cell, idx)
    local layout = cell:getChildByTag(idx)
    local tabList =  _Instance:getCurPropList(_Instance._TabIndex)
    for i = 1 ,CELL_COL_ROW do
        local btn = seekNodeByName(layout, "Btn_"..i) 
        local buyBtn = seekNodeByName(layout, "Btn_"..i.."_0")
        local icon = seekNodeByName(btn, "Image_"..i)
        seekNodeByName(btn, "icon"):setTexture("meishu/ui/gg/UI_gg_zhaomuzhi .png")
        icon:setVisible(true)
        if idx * CELL_COL_ROW + i<= #tabList then
            
            local warriorQuality
            local warriorName 
            local warriorDes
            local warriorIconId
            if tabList[i]["type"] == 2 then
                warriorQuality = propDataManager[tabList[idx * CELL_COL_ROW + i]["id2"]]["quality"]
                warriorName = propDataManager[tabList[idx * CELL_COL_ROW + i]["id2"]]["name"]
                warriorDes = propDataManager[tabList[idx * CELL_COL_ROW + i]["id2"]]["desc"]
                warriorIconId = propDataManager[tabList[idx * CELL_COL_ROW + i]["id2"]]["icon"]
            else
                warriorQuality = CharacterDataManager[tabList[idx * CELL_COL_ROW + i]["id2"]]["quality"]
                warriorName = CharacterDataManager[tabList[idx * CELL_COL_ROW + i]["id2"]]["name"]
                warriorDes = CharacterDataManager[tabList[idx * CELL_COL_ROW + i]["id2"]]["desc"]
                warriorIconId = CharacterDataManager[tabList[idx * CELL_COL_ROW + i]["id2"]]["headName"]
            end
            
            if _Instance._TabIndex == B_STATE_WARRIOR then
                local path = GetWarriorHeadPath(warriorIconId)
                icon:loadTexture(path, UI_TEX_TYPE_LOCAL)
            else
                local path = GetPropPath(warriorIconId)
                icon:loadTexture(path, UI_TEX_TYPE_LOCAL)
            end

            local color = GetQualityColor(warriorQuality)
            local name = seekNodeByName(btn, "Text_1_0")
            name:setColor(color)
            name:setString(warriorName)
            local warriorPrice = tabList[idx * CELL_COL_ROW + i]["price3"]
            local price = ccui.Helper:seekWidgetByName(btn, "Text_1")
            price:setString(warriorPrice)
        else
            btn:setScale(0)
            seekNodeByName(layout, "Btn_"..i.."_0"):setScale(0)
        end
    end
end

-- show prop item
function UIWarriorStore:OpenItemInfoToBuy()
    print(self:getTag())
    local idx = math.floor(self:getTag() / 100)
    _Instance:SimulateClickButton(idx, self:getTag()- 100 * idx)
end

function UIWarriorStore:OpenItemInfoNotifiaction()
    if not _Instance._OpenInfo then
        return
    end
    local tabList =  _Instance:getCurPropList(_Instance._TabIndex)
    local propId = tabList[_Instance._CurStoreIndex]["id2"]
    
--    local propId = _Instance:getCurPropList(_Instance._TabIndex)[_Instance._CurStoreIndex][1]
    _Instance._CurPropID = propId
    local layout = cc.CSLoader:createNode("csb/ui/BuyInfo.csb")

    seekNodeByName(layout, "Panel_3"):setSwallowTouches(true) 
    seekNodeByName(layout, "Panel_3"):setTag(-1) 
    seekNodeByName(layout, "Panel_3"):addTouchEventListener(_Instance.SceneCallBackEvent)
    seekNodeByName(layout, "Button_Close"):addTouchEventListener(_Instance.SceneCallBackEvent)
    local panel = seekNodeByName(layout, "Panel_2") 
    seekNodeByName(seekNodeByName(panel, "title"), "Text_1")
    panel:setSwallowTouches(false) 
    local warriorQuality
    local warriorName 
    local warriorDes
    local warriorIconId
    seekNodeByName(panel, "Text_6"):setString(GetPlayer()._ZhaoMuValue)
    seekNodeByName(layout, "Image_5"):setContentSize(cc.size(40, 40))
    seekNodeByName(layout, "Image_6"):setContentSize(cc.size(40, 40))
    seekNodeByName(panel, "Image_5"):loadTexture("meishu/ui/gg/UI_gg_zhaomuzhi .png")
    seekNodeByName(panel, "Image_6"):loadTexture("meishu/ui/gg/UI_gg_zhaomuzhi .png")
    if tabList[_Instance._CurStoreIndex]["type"] == 2 then
         warriorQuality = propDataManager[propId]["quality"]
         warriorName = propDataManager[propId]["name"]
         warriorDes = propDataManager[propId]["desc"]
         warriorIconId = propDataManager[propId]["icon"]
    else
        warriorQuality = CharacterDataManager[propId]["quality"]
        warriorName = CharacterDataManager[propId]["name"]
        warriorDes = CharacterDataManager[propId]["desc"]
        warriorIconId = CharacterDataManager[propId]["headName"]
    end
    
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
        local text = ccui.Helper:seekWidgetByName(panel, "Text_"..i)
        
        if i == 1 then
            _Instance._InfoData[i] = seekNodeByName(panel, "Text_7")
            local color = GetQualityColor(warriorQuality)
            _Instance._InfoData[i]:setTextColor(color)
            _Instance._InfoData[i]:enableOutline(cc.c4b(77, 39, 18, 250), 1)
        end
        if i == 2 then
            _Instance._InfoData[i] = seekNodeByName(panel, "Text_8")
        end
        _Instance._InfoText[i] = text
    end
    local path
    if _Instance._TabIndex == B_STATE_WARRIOR then
        path = GetWarriorHeadPath(warriorIconId)
    else
        path = GetPropPath(warriorIconId)
    end
    local icon = ccui.Helper:seekWidgetByName(panel, "icon")
    icon:loadTexture(path, UI_TEX_TYPE_LOCAL)
    _Instance._InfoData[1]:setString(warriorName)
    _Instance._InfoData[2]:setString(tabList[_Instance._CurStoreIndex]["price3"])
    _Instance._InfoText[5]:setString(warriorDes)
    _Instance._RootPanelNode:addChild(layout, 1100, 101)
    _Instance._OpenInfo = false
end

function UIWarriorStore:sendTrainMessage(tag)
    if clickTimer == 1 then
        if tag == I_STATE_ADD then
            if _Instance._TabIndex == B_STATE_WARRIOR then
                _Instance._BuyNum = 1
                _Instance._InfoText[4]:setString(_Instance._BuyNum)
                return
            end
            _Instance._BuyNum = _Instance._BuyNum + 1 
            if _Instance._BuyNum >= 99 then
                _Instance._BuyNum = 99
            end
            _Instance._InfoText [4]:setString(_Instance._BuyNum)
        elseif tag == I_STATE_DEL then
            if _Instance._TabIndex == B_STATE_WARRIOR then
                _Instance._BuyNum = 1
                _Instance._InfoText[4]:setString(_Instance._BuyNum)
                return
            end
            _Instance._BuyNum = _Instance._BuyNum - 1
            if _Instance._BuyNum <= 1 then
                _Instance._BuyNum = 1
            end
            _Instance._InfoText[4]:setString(_Instance._BuyNum)
        end
    else
        if scheduler ~= nil then
            scheduler:unscheduleScriptEntry(myupdate)
            scheduler = nil
        end
    end
end

function UIWarriorStore.PressContinue(sender, eventType)
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

function UIWarriorStore:BugSucceed()
    playAnimationObject(UISystem:GetUIRootNode(), 1, 480, 270, "animation0")
    DispatchEvent(GameEvent.GameEvent_UIRecruitWarrior_Succeed)
end

function UIWarriorStore:StoreBuyInfo(eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = self:getTag()
        if tag == I_STATE_BUY then
            local gamePlayerDataManager = GameGlobal:GetGamePlayerDataManager()
            local roleInfo = gamePlayerDataManager:GetMyselfData()
            if roleInfo._ZhaoMuValue >=  _Instance._CurItemPrice * _Instance._BuyNum then
                _Instance._RootPanelNode:removeChildByTag(101, true)
                 if _Instance._TabIndex == B_STATE_WARRIOR then
                    if GameGlobal:GetCharacterServerDataManager():GetLeader(_Instance._CurPropID) == nil then
                        if GameGlobal:GetCharacterServerDataManager():GetLeaderCount() <  GameGlobal:GetVipDataManager()[GetPlayer()._VIPLevel].heromax then
                            SendMsg(PacketDefine.PacketDefine_ShopBuy_Send, {_Instance._CurPropID, _Instance._BuyNum, 3})
                        else
                            local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                            UITip:SetStyle(1, "武将数量已达上限！")
                        end
                    else
                        local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                        UITip:SetStyle(1, "已有重复武将，无法购买！")
                    end
                else
                    SendMsg(PacketDefine.PacketDefine_ShopBuy_Send, {_Instance._CurPropID, _Instance._BuyNum, 3})
                end
            else
                CreateTipAction(_Instance._RootUINode, ChineseConvert["UIWarriorZMValueM"], cc.p(480, 270))
            end
        elseif tag == I_STATE_CANLL then
            _Instance._RootPanelNode:removeChildByTag(101, true)
        end
    end
end

function UIWarriorStore:SceneCallBackEvent(eventType)
    if eventType == ccui.TouchEventType.ended then
        _Instance._RootPanelNode:removeChildByTag(101, true)
    end
end

function UIWarriorStore:getCurPropList(tab)
    local tabList
    if tab == B_STATE_WARRIOR then
        tabList = self._WarriorList
    elseif tab == B_STATE_HUN then
        tabList = self._HunList
    end
    return tabList
end

function UIWarriorStore:ChangeTabState(index)
    if self._TabIndex == index then
        return
    end
    for i = 1, 2 do
        if index == i then
            self._Buttons[i]:setLocalZOrder(3)
            self._Buttons[i]:setBrightStyle(0)
            self._Buttons[i]:setPositionX(440)
            seekNodeByName(self._Buttons[i], "Text_1"):setPositionX(27)
            self._Buttons[i]:setTouchEnabled(false)
        else
            self._Buttons[i]:setLocalZOrder(-1)
            self._Buttons[i]:setBrightStyle(1)
            self._Buttons[i]:setPositionX(437)
            seekNodeByName(self._Buttons[i], "Text_1"):setPositionX(27)
            self._Buttons[i]:setTouchEnabled(true)
        end
    end
    
    self._TabIndex = index
    self._GridView:reloadData()
end

function UIWarriorStore:TouchEvent(eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = self:getTag()
        if tag == B_STATE_CLOSE then
            UISystem:CloseUI(UIType.UIType_WarriorStore)
        elseif tag == B_STATE_WARRIOR then
            _Instance:ChangeTabState(tag)     
        elseif tag == B_STATE_HUN then
            _Instance:ChangeTabState(tag)
        end
    end
end

return UIWarriorStore
--]]