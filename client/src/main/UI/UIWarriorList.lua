----
-- 文件名称：UIWarriorList.lua
-- 功能描述：warriorList
-- 文件说明：warriorList
-- 作    者：田凯
-- 创建时间：2015-6-26
--  修改
--  
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
require("cocos.ui.DeprecatedUIEnum")
require("cocos.extension.ExtensionConstants")

local ItemDataManager = GameGlobal:GetItemDataManager() 
local UISystem = GameGlobal:GetUISystem()
local UIWarriorList = class("UIWarriorList", UIBase)

local EQUIP_NAMES = {"", "武器", "护腕", "头盔", "胸甲", "鞋子", "披风", "", ""}

function UIWarriorList:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_WarriorListUI
    self._ResourceName = "Equips.csb"  
end

function UIWarriorList:Load()
    UIBase.Load(self)
    
    -- 创建装备列表TableView
    self._gridView = CreateTableView_(239, 120, 200, 286, 1, self)
    self:addChild(self._gridView, 0, 0)

    -- 图标与提示,显示的装备具体信息
    self._equipIcon = self:GetUIByName("equip")
    self._textTip = self:GetUIByName("Text_Tip")
    self._equipInfo = self:GetUIByName("EquipInfo")
    self._equipName = self:GetUIByName("equipname")
    self._equipPos = self:GetUIByName("pos")
    self._equipHP = self:GetUIByName("hp")
    self._equipLevel = self:GetUIByName("level")
    self._equipStarLevel = self:GetUIByName("starlevel")
    self._equipAttack = self:GetUIByName("attack")
    self._equipAttackSpeed = self:GetUIByName("attackspeed")

    -- 装备(卸下)按钮
    self._equipButton = self:GetUIByName("EquipButton")
    self._equipButton:setTag(20)
    self._equipButton:addTouchEventListener(handler(self, self.touchEvent))

    -- 关闭按钮
    local close = self._RootPanelNode:getChildByTag(95)
    close:setTag(-1)
    close:addTouchEventListener(handler(self, self.touchEvent))
end

function UIWarriorList:Unload()
    UIBase.Unload()  
end

function UIWarriorList:Open()
    UIBase.Open(self)
    -- 武器
    self._equipWeaponId = {}
    -- 护腕
    self._equipCuffId = {}
    -- 头盔
    self._equipHelmetId = {}
    -- 胸甲
    self._equipCuirassId = {}
    -- 鞋子
    self._equipShoeId = {}
    -- 披风
    self._equipCapeId = {}
    
    -- 初始化装备状态
    self._takeType = -1
    
    -- 选中框
    self._selectFrame = display.newSprite("meishu/ui/gg/UI_gg_zhuangbeikuang_xuanzhong.png", 0, 800, 
        { scale9 = true, 
            capInsets = cc.rect(36,36, 36, 36), 
            rect = cc.rect(0, 0, 111, 111)
        })
    self._selectFrame:retain()
    self._selectFrame:setPreferredSize(cc.size(103, 103))
    self._gridView:addChild(self._selectFrame, 10)

    -- 成功打开UI,加载信息
    self:openUISucceed()
end

function UIWarriorList:Close()
    UIBase.Close(self)

    self._equipWeaponId = nil 
    self._equipCuffId = nil
    self._equipHelmetId = nil
    self._equipCuirassId = nil
    self._equipShoeId = nil
    self._equipCapeId = nil
    
    removeNodeAndRelease(self._selectFrame,true)
end

function UIWarriorList:openUISucceed()
    local warrior = UISystem:GetUIInstance(UIType.UIType_WarriorUI) 
    for i,v in pairs(ItemDataManager._AllItemTable) do
        local isEquip = true
        if v._ItemTableData == 1 then
            if i ~= warrior._equipGuid then
                isEquip = false
            end
        end
        if isEquip then
            if v._PropData["subtype"] == 2 then
                table.insert(self._equipWeaponId, i)
            elseif v._PropData["subtype"] == 3 then
                table.insert(self._equipCuffId, i)
            elseif v._PropData["subtype"] == 4 then
                table.insert(self._equipHelmetId, i)
            elseif v._PropData["subtype"] == 5 then
                table.insert(self._equipCuirassId, i)
            elseif v._PropData["subtype"] == 6 then
                table.insert(self._equipShoeId, i)
            elseif v._PropData["subtype"] == 7 then
                table.insert(self._equipCapeId, i)
            end
        end
    end
    if #self:getEquipList() > 0 then
        self._gridView:reloadData()
        self._curSelectEquipID = self:getEquipList()[1]
        self:simulateClickButton(0, self._curSelectEquipID) 
        -- 有装备，显示图标、详细信息,隐藏提示
        self._textTip:setVisible(false) 
        self._equipIcon:setVisible(true)  
        self._equipInfo:setVisible(true)
        self._equipButton:setVisible(true) 
    else
        -- 无装备，隐藏图标、详细信息,显示提示
        self._equipIcon:setVisible(false)    
        self._textTip:setVisible(true)
        self._equipInfo:setVisible(false)
        self._equipButton:setVisible(false)  
        self._textTip:setString(string.format("你的仓库中没有%s", ChineseConvert["UIEquip_"..warrior._equipType]))
        self._gridView:reloadData() 
    end
end

-- 模拟触摸响应事件
function UIWarriorList:simulateClickButton(idx, tag)
    local cell = self._gridView:cellAtIndex(idx)
    if cell ~= nil then
        local layout = cell:getChildByTag(idx)
        local panel = seekNodeByName(layout, "Panel_1")
        local button = seekNodeByName(panel, "Button_1")
        if button ~= nil then
            SimulateClickButton(button, handlers(self, self.touchEvent, 2))  
        end
    end
end

function UIWarriorList:NumberOfCellsInTableView()
    local equipListCount = #self:getEquipList()
    local num = equipListCount % 2 == 0 and equipListCount / 2 or (equipListCount / 2 + 1)
    if num < 3 then
        num = 3
    end
    return num
end

function UIWarriorList:TableCellTouched(view, cell)
    local index = cell:getIdx()

end

function UIWarriorList:CellSizeForTable(view, idx)
    return 200, 95
end

function UIWarriorList:TableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
        cell:retain()
    end
    cell:removeAllChildren(true)
    local layout = cc.CSLoader:createNode("csb/ui/EquipList.csb")
    cell:addChild(layout, 0, idx)
    self:InitCell(cell, idx)
    return cell
end

function UIWarriorList:InitCell(cell, idx)
    local layout = cell:getChildByTag(idx)
    local equipListCount = #self:getEquipList()
    for i = 1, 2 do
        local panel = seekNodeByName(layout, "Panel_"..i)
        panel:setSwallowTouches(false) 
        if idx * 2 + i <= equipListCount then
            local button = ccui.Helper:seekWidgetByName(panel, "Button_1")
            button:setSwallowTouches(false)
            button:setTag(self:getEquipList()[idx * 2  + i])
            button:addTouchEventListener(handler(self, self.touchEvent)) 
            -- 显示物品是否已装备
            ccui.Helper:seekWidgetByName(panel, "Flag"):setVisible(false)
            local item = ItemDataManager:GetItem(self:getEquipList()[idx * 2  + i])
            if item._ItemTableData ~= 0 then
                ccui.Helper:seekWidgetByName(panel, "Flag"):setVisible(true)
            end
            -- 显示图标
            local icon = ccui.Helper:seekWidgetByName(panel, "icon")
            icon:setSwallowTouches(false) 
            icon:loadTexture(GetPropPath(item._PropData["icon"]), UI_TEX_TYPE_LOCAL)
            -- 品质框隐藏
--            local star = ccui.Helper:seekWidgetByName(panel, "star") 
--            star:setSwallowTouches(false) 
--            star:loadTexture("meishu/ui/gg/"..item._PropData["quality"]..".png")
            -- 名字隐藏
--            local text = ccui.Helper:seekWidgetByName(panel, "Text_1")
--            local color = GetQualityColor(tonumber(item._PropData["quality"])) 
--            text:setString(item._PropData["name"])
--            text:setFontName(FONT_FZLTTHJW) 
--            text:enableOutline(BASE_FONT_OUTCOLOR, 1)
--            text:setColor(color)
            -- 等级隐藏
--            local num = ccui.Helper:seekWidgetByName(panel, "Text_2") 
--            num:setString("lv"..item._ItemEquipLevel)
--            num:setFontName(FONT_FZLTTHJW) 
--            num:enableOutline(BASE_FONT_OUTCOLOR, 1)
        else
            if equipListCount < 6 then
                ccui.Helper:seekWidgetByName(panel, "Flag"):setVisible(false)
                ccui.Helper:seekWidgetByName(panel, "Text_1"):setVisible(false)
                ccui.Helper:seekWidgetByName(panel, "Text_2"):setVisible(false)
            else
                panel:setVisible(false) 
            end
        end
    end
end

-- 得到装备列表信息
function UIWarriorList:getEquipList()
    local warrior = UISystem:GetUIInstance(UIType.UIType_WarriorUI)
    local list = {}
    if warrior._equipType == 2 then
        list = self._equipWeaponId
    elseif warrior._equipType == 3 then
        list = self._equipCuffId
    elseif warrior._equipType == 4 then
        list = self._equipHelmetId
    elseif warrior._equipType == 5 then
        list = self._equipCuirassId
    elseif warrior._equipType == 6 then
        list = self._equipShoeId
    elseif warrior._equipType == 7 then
        list = self._equipCapeId
    end
    
    table.sort(list,function(a, b)
        local equip1 = ItemDataManager:GetItem(a)
        local equip2 = ItemDataManager:GetItem(b)
        
        if equip1._ItemTableData == equip2._ItemTableData then
            if equip1._PropData.quality == equip2._PropData.quality then
                if equip1._ItemEquipLevel == equip2._ItemEquipLevel then
                    return false
                else
                    return equip1._ItemEquipLevel > equip2._ItemEquipLevel
                end
            else
                return equip1._PropData.quality > equip2._PropData.quality
            end
        else
            return equip1._ItemTableData > equip2._ItemTableData
        end
        
    end)
    return list
end

-- 显示选中装备具体信息
function UIWarriorList:openItemInfo()
    local warrior = UISystem:GetUIInstance(UIType.UIType_WarriorUI)
    local equip = ItemDataManager:GetItem(self._curSelectEquipID)
    if warrior._equipGuid == self._curSelectEquipID then
        self._takeType = 2
    elseif equip._ItemTableData == 0 then
        self._takeType = 1
    else
        self._takeType = -1
    end
    local equip = ItemDataManager:GetItem(self._curSelectEquipID)
    self._equipIcon:loadTexture(GetPropPath(equip._PropData["icon"]), UI_TEX_TYPE_LOCAL)
    self._equipName:setString(equip._PropData["name"])
    local posname = GetPropDataManager()[equip._ItemTableID]["subtype"] 
    self._equipPos:setString(EQUIP_NAMES[posname])
    self._equipHP:setString(string.format("%d", equip._EquipHp)) 
    self._equipLevel:setString(string.format("%d", equip._ItemEquipLevel)) 
    self._equipStarLevel:setString(string.format("%d", warrior._CurWarriorStar)) 
    self._equipAttack:setString(string.format("%d", equip._EquipAtk)) 
    self._equipAttackSpeed:setString(string.format("%d", equip._EquipSpeed))
    if self._takeType == 1 then
        -- 按钮文字显示卸下  
        self._equipButton:setTitleText(GameGlobal:GetTipDataManager(UI_BUTTON_NAME_4))
    elseif self._takeType == 2 then
        -- 按钮文字显示装备  
        self._equipButton:setTitleText(GameGlobal:GetTipDataManager(UI_BUTTON_NAME_5))
    else
        self._equipButton:setVisible(false)
    end
end

-- 触摸响应事件
function UIWarriorList:touchEvent(sender, eventType)
    if type(eventType) == "table" then
        eventType = eventType.eventType
    end 
    if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
        if tag == -2  then
        elseif tag == -1  then
            UISystem:CloseUI(UIType.UIType_WarriorListUI) 
            UISystem:GetUIRootNode():removeChildByTag(101, true)
        elseif tag == 20 then
            self:takeEquip()
        else
            self._selectFrame:setVisible(true)
            self._selectFrame:removeFromParent(false)
            self._selectFrame:setAnchorPoint(0.5, 0.5)
            self._selectFrame:ignoreAnchorPointForPosition(false)
            sender:addChild(self._selectFrame)
            self._selectFrame:setPosition(45, 45)
            self._curSelectEquipID = tag
            self:openItemInfo()
        end
    end
end

-- 点击装备（卸下）发送消息给服务器
function UIWarriorList:takeEquip(cid)
    if cid == -1 then
        return
    end
    local equip = ItemDataManager:GetItem(self._curSelectEquipID)
    local warrior = UISystem:GetUIInstance(UIType.UIType_WarriorUI)
    SendMsg(PacketDefine.PacketDefine_EquipUse_Send, {warrior._curWarriorId, self._curSelectEquipID})
    UISystem:CloseUI(UIType.UIType_WarriorListUI)
end

return UIWarriorList