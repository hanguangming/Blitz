----
-- 文件名称：UIBag.lua
-- 功能描述：UIBag
-- 文件说明：UIBag
-- 作    者：田凯
-- 创建时间：2015-6-27
--  修改
--  
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
require("cocos.ui.DeprecatedUIEnum")
require("cocos.extension.ExtensionConstants")
local WarriorDataManager = require("main.ServerData.CharacterServerDataManager")
local B_STATE_ITEM = 1
local B_STATE_EQUIP = 2
local B_STATE_WARRIOR_FRAME = 3
local B_STATE_BEAST = 5
local B_STATE_CLOSE = 6
local B_STATE_COMMAND = 7
local CELL_COL_ROW = 5
local CELL_SIZE_WIDTH = 320
local CELL_SIZE_HEIGHT = 85
local UISystem = GameGlobal:GetUISystem()

local UIBag = class("UIBag", UIBase)
local _Instance = nil 

function UIBag:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_BagUI
    self._ResourceName = "UIBag.csb"  
end

function UIBag:Load()
    UIBase.Load(self)
    _Instance = self
    self._Buttons = {}
    self._TabText = {}
    self._Slider = nil

    -- tableView 
    local center = seekNodeByName(self._RootPanelNode, "Panel_Center")
    self._GridView = CreateTableView_(-385, -242, 420, 425, cc.TABLEVIEW_FILL_BOTTOMUP, self)
    center:addChild(self._GridView)
--    seekNodeByName(seekNodeByName(self._RootPanelNode, "Title"), "Text_1"):enableOutline(cc.c4b(77, 39, 18, 250), 2)
    self._SelectFrame = display.newSprite("meishu/ui/gg/UI_gg_zhuangbeikuang_xuanzhong.png", 0, 800, {scale9 = true, capInsets = cc.rect(40, 40, 20, 20), rect = cc.rect(0, 0, 111, 111)})
    self._SelectFrame:retain()
    self._SelectFrame:setPreferredSize(cc.size(130, 130))
    self._SelectFrame:setAnchorPoint(0.5, 0.5)
    self._SelectFrame:ignoreAnchorPointForPosition(false)
    self._SelectFrame:setPosition(57, 58)
    self._GridView:addChild(self._SelectFrame, 10)
    
    self._Slider = self:GetWigetByName("Slider_2")
    self._Slider:setVisible(false)
    self._ItemTagIndex = 1
    local close = self:GetWigetByName("Close")
    close:setTag(6)
    close:addTouchEventListener(self.TouchEvent)
    self._Buttons[1] = self:GetWigetByName("Tab_1")
    self._Buttons[2] = self:GetWigetByName("Tab_2")
    self._Buttons[3] = self:GetWigetByName("Tab_3")
    self._Buttons[1]:setTag(1)
    self._Buttons[2]:setTag(2)
    self._Buttons[3]:setTag(3)
    self._Buttons[1]:addTouchEventListener(self.TouchEvent)
    self._Buttons[2]:addTouchEventListener(self.TouchEvent)
    self._Buttons[3]:addTouchEventListener(self.TouchEvent)
    for i = 1, 3 do
        self._TabText[i] = seekNodeByName(self._Buttons[i], "name_"..i)
    end
    self._ItemIcon = self:GetWigetByName("ItemIcon")
    self._ItemName = self:GetWigetByName("ItemName")
    self._ItemDes = self:GetUIByName("Text_Des")
    self._ItemPrice = self:GetWigetByName("ItemPrice")
    self._PriceFontText = self:GetWigetByName("Text_PriceFont")
    self._PriceBgDi = self:GetWigetByName("Image_PriceDi")
    
    self._ButtonCommed = self:GetWigetByName("Button_Commed")
    self._ButtonCommedText = seekNodeByName(self._ButtonCommed, "Text_4")
    self._TextT = self:GetWigetByName("Text_2")
    self._ImageI = self:GetWigetByName("Image_9")
--    self._ButtonCommed:getTitleRenderer():enableOutline(cc.c4b(253, 206, 58, 250), 1)
--    self._ButtonCommed:getTitleRenderer():setPositionY(26)
    self._ButtonCommed:setTag(B_STATE_COMMAND)
    self._ButtonCommed:addTouchEventListener(self.TouchEvent)
    self._ItemData1 = seekNodeByName(self._RootPanelNode, "Node_11")
    self._ItemData2 = seekNodeByName(self._RootPanelNode, "Node_12")
    self._ItemInfo = {}
    for i = 1, 6 do
        self._ItemInfo[i] = cc.Label:createWithTTF("", "fonts/msyh.ttf", BASE_FONT_SIZE)
--        self._ItemInfo[i] = cc.Label:create()
        self._ItemInfo[i]:setAnchorPoint(cc.p(0, 1))
        self._ItemInfo[i]:setColor(cc.c3b(121,  76,  53))
--        self._ItemInfo[i]:setSystemFontSize(BASE_FONT_SIZE)
        self._ItemData1:addChild(self._ItemInfo[i], 10)
    end
    local name ={GameGlobal:GetTipDataManager(UI_BUTTON_NAME_37), GameGlobal:GetTipDataManager(UI_BUTTON_NAME_38), GameGlobal:GetTipDataManager(UI_BUTTON_NAME_39)}
    --CreateBaseUIAction(self._RootPanelNode, -200, 222, 6, GameGlobal:GetTipDataManager(UI_BUTTON_NAME_66), name, 3, self.TouchEvent, self.EndCallBack)
end

function UIBag.EndCallBack(value)
    _Instance._Buttons = value
    _Instance._Buttons[1]:setTag(1)
    _Instance._Buttons[2]:setTag(2)
    _Instance._Buttons[3]:setTag(3)
end


function UIBag:Unload()
    UIBase.Unload(self)
    self._ResourceName = nil
    self.Type = nil
end

function UIBag:Open()
    UIBase.Open(self)
    self:OpenUISucceed()
    -- 上下箭头 初始化    下显上不显
    self._ImageUp = self:GetWigetByName("Image_Up")
    self._ImageUp:setLocalZOrder(1)
    self._ImageUp:setVisible(false)
    self._ImageDown = self:GetWigetByName("Image_Down")
    self._ImageDown:setLocalZOrder(1)
    self.OpenUISucceedCallBack = AddEvent(GameEvent.GameEvent_UIBag_Succeed, self.UpdateBag)
end

function UIBag:Close()
    UIBase.Close(self)
    if self.OpenUISucceedCallBack ~= nil then
        RemoveEvent(self.OpenUISucceedCallBack)
        self.OpenUISucceedCallBack = nil
    end
end

function UIBag:ScrollViewDidScroll(view)
    local point = view:getContentOffset()
    local len = view:getContentSize().height - view:getViewSize().height
    local percent = - (point.y / len)
    if percent >= 1 and self._ImageUp and self._ImageDown then
        self._ImageUp:setVisible(false)
        self._ImageDown:setVisible(true)
    elseif percent <= 0 and len > 0 then
        self._ImageUp:setVisible(true)
        self._ImageDown:setVisible(false)
    end
end

function UIBag:NumberOfCellsInTableView()
    local len = 0
    if self._PropIndex == nil then
        return 0
    end
    if self._ItemTagIndex == B_STATE_ITEM then
        len = #self._PropIndex % CELL_COL_ROW == 0 and math.floor(#self._PropIndex /CELL_COL_ROW) or math.floor(#self._PropIndex / CELL_COL_ROW) + 1
    end
    
    if self._ItemTagIndex == B_STATE_EQUIP then
        len = #self._EquipIndex % CELL_COL_ROW == 0 and math.floor(#self._EquipIndex /CELL_COL_ROW) or math.floor(#self._EquipIndex / CELL_COL_ROW) + 1
    end
    
    if self._ItemTagIndex == B_STATE_WARRIOR_FRAME then
        len = #self._WarriorFrameIndex % CELL_COL_ROW == 0 and math.floor(#self._WarriorFrameIndex /CELL_COL_ROW) or math.floor(#self._WarriorFrameIndex / CELL_COL_ROW) + 1
    end
    if len == 0 then
        len = 1
    end
    if len < 5 then
        len = 5
    end
    return len
end

function UIBag:TableCellTouched(view, cell)
    self._ItemIndex = cell:getIdx() * CELL_COL_ROW + self._CurCellTag
    self:ShowItemInfoPanel()
end

function UIBag:CellSizeForTable(view, idx)
    return CELL_SIZE_WIDTH, CELL_SIZE_HEIGHT
end

function UIBag:TableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
    end
    cell:removeAllChildren(true)
    local layout = cc.CSLoader:createNode("csb/ui/BagItem.csb")
    local page = tolua.cast(layout, "ccui.Layout")
    for i =1 , CELL_COL_ROW do
        local btn = ccui.Helper:seekWidgetByName(layout, "Btn_"..i)
        btn:setTitleText("")
        btn:setTag(i)
        ccui.Helper:seekWidgetByName(btn, "Image_"..i):setVisible(false)
        btn:setSwallowTouches(false)  
    end

    page:setPosition(cc.p(0, 0))
    cell:addChild(page, 0, idx)

    self:InitCell(cell, idx)

    return cell
end

function UIBag:InitCell(cell, idx)
    local layout = cell:getChildByTag(idx)
    local curList = _Instance:GetCurBagList()
    for i = 1 ,CELL_COL_ROW do
        local btn = ccui.Helper:seekWidgetByName(layout, "Btn_"..i)
        if  idx * CELL_COL_ROW + i <= #curList then
            btn:addTouchEventListener(handler(self, self.TableViewItemTouchEvent))
            local item = curList[ idx * CELL_COL_ROW + i]
--            ccui.Helper:seekWidgetByName(btn, "Image"):loadTexture("meishu/ui/gg/"..tonumber(item._PropData["quality"])..".png")
            local icon = ccui.Helper:seekWidgetByName(btn, "Image_"..i)
            icon:setVisible(true)
            local iconid =  GetPropPath(item._ItemTableID)
            
            if _Instance._ItemTagIndex == 3 then
                if tonumber(item._ItemTableID) > 15002 then
                    iconid = GetWarriorPath(GetPropDataManager()[tonumber(item._ItemTableID)]["icon"])
                end
            end
            icon:loadTexture(iconid, UI_TEX_TYPE_LOCAL)
            
            local image = ccui.Helper:seekWidgetByName(btn, "Image")
            image:setVisible(true)
            
            self._SelectFrame:setVisible(true)
--
--            local name = ccui.Helper:seekWidgetByName(btn, "Text_1")
            --name:setString(item._PropData["name"])
--            name:setFontName(FONT_SIMHEI)
--            name:setFontSize(BASE_FONT_SIZE)
--            name:enableOutline(cc.c4b(0, 0, 0, 250), 1)
--            name:setVisible(true)
--            local color = GetQualityColor(tonumber(item._PropData["quality"]))
--            name:setColor(color)
            
            local num = ccui.Helper:seekWidgetByName(btn, "Text_2")
            if self._ItemTagIndex ~= 2 then
                num:setPosition(100, 20)
                num:setString(item._CurrentItemCount)
            else
                num:setPosition(100, 94)
                num:setString("lv"..item._ItemEquipLevel)
            end
--            num:setFontName("fonts/msyh.ttf")
--            num:setTextColor(cc.c3b(121, 76, 53))
--            num:enableOutline(cc.c4b(0, 0, 0, 250), 1)
            num:setVisible(true)
            --]]
        else
            local icon = ccui.Helper:seekWidgetByName(btn, "Image_"..i)
            icon:setVisible(false)
            local name = ccui.Helper:seekWidgetByName(btn, "Text_1")
            name:setVisible(false)
            local num = ccui.Helper:seekWidgetByName(btn, "Text_2")
            num:setVisible(false)
            --分页栏为空，选中框不显示
            if idx * CELL_COL_ROW + i == 1 then
                self._SelectFrame:setVisible(false)
            end
        end
    end
end


-- record cell index to col or row TableViewItemTouchEvent
function UIBag:TableViewItemTouchEvent(sender, eventType)
     if eventType == ccui.TouchEventType.ended then
        self._SelectFrame:removeFromParent(false)
        sender:addChild(self._SelectFrame, 10)
        self._SelectFrame:setPosition(57, 58)
        self._CurCellTag = sender:getTag()
        
        -- open flag
        self._ShowInfo = true
    end
end

function UIBag.SceneCallBackEvent(self)
    if type(self) == "number" then
        tag = self
    else
        tag = self:getTag()
    end
    if tag == -1 then
        _Instance._RootUINode:removeChildByTag(101, true)
    else
        if tag == 2 then
            PlaySound(Sound_31)   
        end
        _Instance.CommitTipButton(tag)
--        _Instance._RootUINode:removeChildByTag(101, true)
--        local tip =  UISystem:OpenUI(UIType.UIType_TipUI)
--        tip:RegisteDelegate(_Instance.CommitTipButton, tag)
    end
end

function UIBag.CommitTipButton(tag)
    if tag == 1 then
        print(_Instance._IsMoenyGift)
        if _Instance._IsMoenyGift then 
            if GetPlayer()._Level >= _Instance._CurItem._PropData["lv"] then
                SendMsg(PacketDefine.PacketDefine_UseItem_Send, {_Instance._CurItem._ItemServerID, _Instance._CurItem._CurrentItemCount})
            else
                local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                UITip:SetStyle(1, "等级不足，无法开启！")
            end
        end
    elseif tag == 2 then
        if true then
            CreateTipAction(self._RootUINode, "暂未开放，敬请期待！", cc.p(480, 270))
            return
        end
        local UITip =  GameGlobal:GetUISystem():OpenUI(UIType.UIType_TipUI)
        UITip:SetStyle(0, "是否出售该道具")
        UITip:RegisteDelegate(_Instance.ItemSellCommit, 1)
    elseif tag == 3 then   
        local id,_ = string.gsub(_Instance._CurItem._PropData["val1"], "[%(-%)]", "")
       
        if WarriorDataManager:GetLeader(tonumber(id)) ~= nil then
            CreateTipAction(_Instance._RootUINode, ChineseConvert["UITitle_6"], cc.p(480, 320))
            return
        end
        
        if _Instance._CurItem._CurrentItemCount - 10 >= 0 then
            SendMsg(PacketDefine.PacketDefine_UseItem_Send, {_Instance._CurItem._ItemServerID, 10})
        else
            local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
            UITip:SetStyle(1, "所需道具不足")
        end
    end
    _Instance:ChangeTabState(_Instance._ItemTagIndex)
end

function UIBag:ItemSellCommit()
    SendMsg(PacketDefine.PacketDefine_SellItem_Send, {_Instance._CurItem._ItemServerID})
end

-- show item detail info
function UIBag:ShowItemInfoPanel()
    if _Instance._ItemIndex > #_Instance:GetCurBagList() then
        _Instance._ImageI:setVisible(false)
        _Instance._TextT:setVisible(false)
        _Instance._ItemPrice:setVisible(false)
        _Instance._ButtonCommed:setVisible(false)
        _Instance._PriceFontText:setVisible(false)
        _Instance._PriceBgDi:setVisible(false)
        return
    end
    if _Instance._ItemName:getString() == "" then
        _Instance._ImageI:setVisible(false)
        _Instance._TextT:setVisible(false)
        _Instance._ButtonCommed:setVisible(false)
        _Instance._ItemPrice:setVisible(false)
        _Instance._PriceFontText:setVisible(false)
        _Instance._PriceBgDi:setVisible(false)
    else
        _Instance._ImageI:setVisible(true)
--        _Instance._TextT:setVisible(true)
        _Instance._ButtonCommed:setVisible(true)
        _Instance._ItemPrice:setVisible(true)
        _Instance._PriceFontText:setVisible(true)
        _Instance._PriceBgDi:setVisible(true)
    end
    local item = _Instance:GetCurBagList()[_Instance._ItemIndex]
    if _Instance._ItemTagIndex == B_STATE_EQUIP and item._PropData["name"] ~= "" then
        _Instance._ItemData1:setVisible(true)
    else
        _Instance._ItemData1:setVisible(false)
    end
    _Instance._CurItem = item
    if _Instance._ItemTagIndex == 3 then
        if item._ItemTableID == 15002 or item._ItemTableID == 15001 then
            _Instance._ItemIcon:loadTexture(GetPropPath(item._ItemTableID))
        else
            _Instance._ItemIcon:loadTexture(GetWarriorPath(GetPropDataManager()[tonumber(item._ItemTableID)]["icon"]), UI_TEX_TYPE_LOCAL)
        end
    else
        _Instance._ItemIcon:loadTexture(GetPropPath(item._ItemTableID))
    end
    _Instance._ItemName:setString(item._PropData["name"])
    if item._PropData["name"] == "" then
        _Instance._ButtonCommed:setVisible(false)
    else
        _Instance._ButtonCommed:setVisible(true)
    end
    _Instance._ItemDes:setString(item._PropData["desc"])
--    _Instance._ItemName:enableOutline(cc.c4b(70, 35, 15, 250), 1)
    
    if item._PropData["sell"] == 0 then
        _Instance._ImageI:setVisible(false)
        _Instance._TextT:setVisible(false)
        _Instance._ItemPrice:setVisible(false)
        _Instance._PriceFontText:setVisible(false)
        _Instance._ButtonCommed:setVisible(false)
        _Instance._PriceBgDi:setVisible(false)
    else
        _Instance._ItemPrice:setString(item._PropData["sell"])
        _Instance._ButtonCommed:setVisible(true)
        _Instance._ImageI:setVisible(true) 
        _Instance._ItemPrice:setVisible(true)
        _Instance._PriceFontText:setVisible(true)
        _Instance._PriceBgDi:setVisible(true)
    end
    
--    local color = GetQualityColor(tonumber(item._PropData["quality"]))
--    _Instance._ItemName:setColor(color)
    local panel = CreateStopTouchScene(_Instance.SceneCallBackEvent)
    local x = 480 
    local y = 80 
    local w = 280
    local h = 180
    local style = 0
    local posOffX =  _Instance._CurCellTag % 13 >= 7 and _Instance._CurCellTag - 10 or _Instance._CurCellTag - 4
    local posOffY =  _Instance._CurCellTag / 7 >= 1 and 1 or 0
    x = 540 + posOffX * 128
    y = y + posOffY * 50
    local itype = tonumber(item._PropData["subtype"])
    _Instance._ButtonCommed:setVisible(true)
    if itype == 12 or (itype >= 19 and itype <= 21) then
        style = 1
        _Instance._IsMoenyGift = true
--        _Instance._ButtonCommed:getTitleRenderer():setString(ChineseConvert["UITitle_11"])
        _Instance._ButtonCommedText:setString(ChineseConvert["UITitle_11"])
    end
    if _Instance._ItemTagIndex == 2 then
        style = 2
        h = 410
        if item._PropData["quality"] >=4 then
            style = -1
            h = 330
        end
        style = -1
        if item._PropData["sell"] == 0 then
            _Instance._ButtonCommed:setVisible(false)
        end
--        _Instance._ButtonCommed:getTitleRenderer():setString(ChineseConvert["UITitle_12"])
        _Instance._ButtonCommedText:setString(ChineseConvert["UITitle_12"])
--        _Instance._ButtonCommed:setVisible(false)
    elseif _Instance._ItemTagIndex == 3 then 
        style = 3
--        _Instance._ButtonCommed:getTitleRenderer():setString(ChineseConvert["UITitle_13"])
        _Instance._ButtonCommedText:setString(ChineseConvert["UITitle_13"])
    end
    
    if style == 0 then
        h = 100
        _Instance._ButtonCommed:setVisible(false)
    end
 
--    local  bg = CreateInfoBack(x ,y, w, h, _Instance.SceneCallBackEvent, style, _Instance._ItemTagIndex)  

    local base = {ChineseEquipDetail[1], ChineseEquipDetail[17]}
    local baseValue = {item._PropData["name"], item._PropData["desc"]}
    if _Instance._ItemTagIndex == 2 then
        local posname = ChineseConvert["UIEquip_"..GetPropDataManager()[item._ItemTableID]["subtype"]]
        print(posname)
        local quality = GetPropDataManager()[item._ItemTableID]["star"]..ChineseEquip[8]            
--        local equipsData = {
--            item._PropData["name"], posname, item._ItemEquipLevel,item._EquipAtk, item._EquipHp, item._EquipSpeed, quality, 
--            "   ("..GetPropDataManager()[item._ItemTableID]["star"].."/50)", 
--        }
        local equipsData = {
            posname, item._ItemEquipLevel, quality, item._EquipAtk, item._EquipHp, item._EquipSpeed
        }
        local size = 16
        
        if style == -1 then
            size = 15
        end
        
        local hpNum = 0
        local atkNum = 0
        if GetPropDataManager()[item._ItemTableID]["star"] >= 50 then
            hpNum = 20
            atkNum = 36
        elseif GetPropDataManager()[item._ItemTableID]["star"] >= 30 then
            hpNum = 20
            atkNum = 20
        elseif GetPropDataManager()[item._ItemTableID]["star"] >= 25 then
            hpNum = 12
            atkNum = 12
        elseif GetPropDataManager()[item._ItemTableID]["star"] >= 20 then
            hpNum = 7
            atkNum = 7
        end 
        atkNum = string.format(ChineseEquip[14], atkNum)
        hpNum = string.format(ChineseEquip[15], hpNum)
        
      for i = 1, 3 do
        _Instance._ItemInfo[i]:setPosition(cc.p(97, -24 - 30 * (i - 1)))
        _Instance._ItemInfo[i]:setString(equipsData[i])
      end
--        _Instance._ItemInfo[8]:setString(equipsData[8])
--        _Instance._ItemInfo[8]:setPosition(cc.p(280, 0))
      for i = 4, 6 do
        _Instance._ItemInfo[i]:setPosition(cc.p(220, -24 - 30 * (i - 1 - 3)))
        _Instance._ItemInfo[i]:setString(equipsData[i])
      end
    end
--    _Instance._ShowInfo = false
end

-- get list by tab
function UIBag:GetCurBagList()
    if self._ItemTagIndex == B_STATE_ITEM then
        return _Instance._PropIndex
    elseif self._ItemTagIndex == B_STATE_EQUIP then
        return self._EquipIndex
    elseif self._ItemTagIndex == B_STATE_WARRIOR_FRAME then
        return self._WarriorFrameIndex
    end
    return self._PropIndex
end

function UIBag:OpenUISucceed()
    _Instance._PropIndex = {}
    _Instance._WarriorFrameIndex = {}
    _Instance._EquipIndex = {}
    local ItemDataManager = GameGlobal:GetItemDataManager() 
    local count = ItemDataManager._ItemCount
    
    for i,v in pairs(ItemDataManager._AllItemTable) do
        local item = ItemDataManager:GetItem(i)
        local type = tonumber(item._PropData["subtype"])
 
        if type  == 1 or type  == 0 then
            table.insert(_Instance._WarriorFrameIndex, item)
        elseif type  >= 2 and type  <= 9 and item._ItemTableData == 0  then
            table.insert(_Instance._EquipIndex, item) 
        elseif item._ItemTableData == 0  then
            if item._PropData.subtype ~= 12 then
                table.insert(_Instance._PropIndex, item)
            end
        end
    end
    
    table.sort(_Instance._WarriorFrameIndex, function(a, b)
        local equip1 = a
        local equip2 = b
        if equip1._ItemTableID == equip2._ItemTableID then
            if equip1._PropData.quality > equip2._PropData.quality then
                return false
            else
                return equip1._PropData.quality > equip2._PropData.quality
            end
        else
            return equip1._ItemTableID < equip2._ItemTableID
        end
    end)

    table.sort(_Instance._PropIndex, function(a, b)
        local prop1 = a
        local prop2 = b
        if prop1._PropData.type == prop2._PropData.type then
            if prop1._PropData.quality == prop2._PropData.quality then
                return prop1._PropData.id < prop2._PropData.id
            else
                return prop1._PropData.quality < prop2._PropData.quality
            end
        else
            return prop1._PropData.type > prop2._PropData.type
        end
    end)
   
   local tick = 1
   
    for i,v in pairs(ItemDataManager._AllItemTable) do
        local item = ItemDataManager:GetItem(i)
        local type = tonumber(item._PropData["subtype"])
        if item._PropData.subtype == 12 then
            table.insert(_Instance._PropIndex, tick, item)
            tick = tick + 1
        end
    end
    
   for i, v in pairs(_Instance._PropIndex) do
        if v._PropData.type == 12 then
            table.remove(_Instance._PropIndex,pos)
            table.insert(_Instance._PropIndex, tick, v)
        end
   end
    
    
    table.sort(_Instance._EquipIndex, function(a, b)
        local equip1 = a
        local equip2 = b
        if equip1._ItemTableID == equip2._ItemTableID then
            if equip1._ItemEquipLevel == equip2._ItemEquipLevel then
                return false
            else
                return equip1._ItemEquipLevel > equip2._ItemEquipLevel
            end
        else
            return equip1._ItemTableID > equip2._ItemTableID
        end
    end)
    
    _Instance:ChangeTabState(1)
end

function UIBag:UpdateBag()
    _Instance._PropIndex = {}
    _Instance._WarriorFrameIndex = {}
    _Instance._EquipIndex = {}
    local ItemDataManager = GameGlobal:GetItemDataManager() 
    local count = ItemDataManager._ItemCount

    for i,v in pairs(ItemDataManager._AllItemTable) do
        local item = ItemDataManager:GetItem(i)
        local type = tonumber(item._PropData["subtype"])

        if type  == 1 or type  == 0 then
            table.insert(_Instance._WarriorFrameIndex, item)
        elseif type  >= 2 and type  <= 9 and item._ItemTableData == 0  then
            table.insert(_Instance._EquipIndex, item) 
        elseif item._ItemTableData == 0  then
            if type ~= 12 then
                table.insert(_Instance._PropIndex, item)
            end
        end
    end

    table.sort(_Instance._WarriorFrameIndex, function(a, b)
        local equip1 = a
        local equip2 = b
        if equip1._ItemTableID == equip2._ItemTableID then
            if equip1._PropData.quality > equip2._PropData.quality then
                return false
            else
                return equip1._PropData.quality > equip2._PropData.quality
            end
        else
            return equip1._ItemTableID < equip2._ItemTableID
        end
    end)

    table.sort(_Instance._PropIndex, function(a, b)
        local prop1 = a
        local prop2 = b
        if prop1._PropData.type == prop2._PropData.type then
            if prop1._PropData.quality == prop2._PropData.quality then
                return prop1._PropData.id < prop2._PropData.id
            else
                return prop1._PropData.quality < prop2._PropData.quality
            end
        else
            return prop1._PropData.type > prop2._PropData.type
        end
    end)

    local tick = 1
    for i,v in pairs(ItemDataManager._AllItemTable) do
        local item = ItemDataManager:GetItem(i)
        local type = tonumber(item._PropData["subtype"])
        if item._PropData.subtype == 12 then
            table.insert(_Instance._PropIndex, tick, item)
            tick = tick + 1
        end
    end
    
    table.sort(_Instance._EquipIndex, function(a, b)
        local equip1 = a
        local equip2 = b
        if equip1._ItemTableID == equip2._ItemTableID then
            if equip1._ItemEquipLevel == equip2._ItemEquipLevel then
                return false
            else
                return equip1._ItemEquipLevel > equip2._ItemEquipLevel
            end
        else
            return equip1._ItemTableID > equip2._ItemTableID
        end
    end)
    
    _Instance._GridView:reloadData()
    
    _Instance._ItemIndex = 1
    _Instance:ShowItemInfoPanel()
end

function UIBag:ChangeTabState(index)
    if self._TabIndex == index then
        return
    end
    _Instance._ItemName:setString("")
    _Instance._ItemIcon:loadTexture("meishu/ui/gg/null.png")
    _Instance._ItemDes:setString("")
    --[[
    for i =  1, 3 do
        self._Buttons[i]:setBrightStyle(1)
        seekNodeByName(self._Buttons[i], "name_"..i):setColor(cc.c3b(36, 47, 13))
        seekNodeByName(self._Buttons[i], "name_"..i):enableOutline(cc.c4b(36, 47, 13, 50), 1)
    end
    self._Buttons[index]:setBrightStyle(0)
    seekNodeByName(self._Buttons[index], "name_"..index):setColor(cc.c3b(253, 228, 136))
    --]]
    for i = 1, 3 do
        if index == i then
            _Instance._Buttons[i]:setLocalZOrder(3)
            _Instance._Buttons[i]:loadTextures("meishu/ui/gg/UI_gg_yeqian_01.png", UI_TEX_TYPE_LOCAL)
            _Instance._Buttons[i]:setPositionX(414)
            _Instance._TabText[i]:setPositionX(27)
            _Instance._Buttons[i]:setTouchEnabled(false)
        else
            _Instance._Buttons[i]:setLocalZOrder(-1)
            _Instance._Buttons[i]:loadTextures("meishu/ui/gg/UI_gg_yeqian_02.png", UI_TEX_TYPE_LOCAL)
            _Instance._Buttons[i]:setPositionX(420)
            _Instance._TabText[i]:setPositionX(17)
            _Instance._Buttons[i]:setTouchEnabled(true)
        end
    end
    
    self._ItemTagIndex = index
    if self._ItemTagIndex == 2 then
        self._ItemData1:setVisible(true)
        self._ItemData2:setVisible(false)
    else
        self._ItemData1:setVisible(false)
        self._ItemData2:setVisible(true)
    end
    self._GridView:reloadData()
    self._ItemIndex = 1
    self._CurCellTag = 1
    local cell = _Instance._GridView:cellAtIndex(0)
    if cell ~= nil then
        local panel = cell:getChildByTag(0)
        local button = ccui.Helper:seekWidgetByName(panel, "Btn_1")
        SimulateClickButton(button, handlers(self, self.TableViewItemTouchEvent, 2))
    end
    _Instance._ItemData1:setVisible(false)
    self:ShowItemInfoPanel()
end

function UIBag:TouchEvent(eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = self:getTag()
        if tag == B_STATE_CLOSE then
            UISystem:CloseUI(UIType.UIType_BagUI)
        elseif tag == B_STATE_ITEM then
            _Instance:ChangeTabState(tag)     
        elseif tag == B_STATE_GIFT then
            _Instance:ChangeTabState(tag)
        elseif tag == B_STATE_EQUIP then
            _Instance:ChangeTabState(tag)
        elseif tag == B_STATE_WARRIOR_FRAME then
            _Instance:ChangeTabState(tag)
        elseif tag == B_STATE_BEAST then
            _Instance:ChangeTabState(tag)
        elseif tag == B_STATE_COMMAND then
            _Instance.CommitTipButton(_Instance._ItemTagIndex)
        end
    end
end

return UIBag