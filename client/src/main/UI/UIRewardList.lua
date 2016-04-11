----
-- 文件名称：UIRewardList.lua
-- 功能描述：warriorList
-- 文件说明：warriorList
-- 作    者：田凯
-- 创建时间：2015-6-26
--  修改
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
require("cocos.ui.DeprecatedUIEnum")
require("cocos.extension.ExtensionConstants")
local ItemDataManager = GetPropDataManager()
local UISystem = GameGlobal:GetUISystem()
local _Instance = nil 

local UIRewardList = class("UIRewardList", UIBase)

function UIRewardList:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_RewardUI
    self._ResourceName = "warriors.csb"  
end

function UIRewardList:Load()
    UIBase.Load(self)
    _Instance = self
    -- tableView 
    self._GridView = CreateTableView(205, 180, 535, 160, 0, self)
    self._RootPanelNode:addChild(self._GridView)
    self._RootPanelNode:setSwallowTouches(true) 
    self._RootPanelNode:setTag(-1)
    self._RootPanelNode:setSwallowTouches(true) 
    self._RootPanelNode:addTouchEventListener(self.TouchEvent)
    local close = tolua.cast(self._RootPanelNode:getChildByTag(95), "Button")
    close:setTag(-1)
    close:addTouchEventListener(self.TouchEvent)
end

function UIRewardList.ScrollViewDidScroll()

end

function UIRewardList.NumberOfCellsInTableView()
    return #_Instance._RewardList
end

function UIRewardList.TableCellTouched(view, cell)
    local index = cell:getIdx()
end

function UIRewardList.CellSizeForTable(view, idx)
    return 155, 135
end

function UIRewardList.TableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
        local layout = cc.CSLoader:createNode("csb/ui/ListPage.csb")
        cell:addChild(layout, 0, idx)
    else
        cell:removeAllChildren(true)
        local layout = cc.CSLoader:createNode("csb/ui/ListPage.csb")
        cell:addChild(layout, 0, idx)
    end
    _Instance:InitCell(cell, idx)
    return cell
end

function UIRewardList:InitCell(cell, idx)
    local layout = cell:getChildByTag(idx)
    local panel = seekNodeByName(layout, "Panel_1")
    if panel ~= nil then
        panel:setSwallowTouches(false) 
        if idx < #_Instance._RewardList then
            local item = ItemDataManager[_Instance._RewardList[idx + 1][1]]     
            
            local button = ccui.Helper:seekWidgetByName(panel, "Button_1")
            button:setSwallowTouches(false) 
            local icon = ccui.Helper:seekWidgetByName(panel, "icon")
            icon:setSwallowTouches(false) 
            local star = ccui.Helper:seekWidgetByName(panel, "star")
            star:setSwallowTouches(false) 
            star:loadTexture("meishu/ui/gg/"..item["quality"]..".png")
            
            local text = ccui.Helper:seekWidgetByName(panel, "Text_1")
            local num = ccui.Helper:seekWidgetByName(panel, "Text_2")
            local color = GetQualityColor(tonumber(item["quality"]))
            text:setString(item["name"])
            text:setFontName(FONT_SIMHEI) 
            text:setFontSize(BASE_FONT_SIZE) 
            text:enableOutline(cc.c4b(0, 0, 0, 250), 1)
            text:setColor(color)
            icon:loadTexture(item["icon"], UI_TEX_TYPE_LOCAL)
            num:setString(_Instance._RewardList[idx + 1][2])
            num:setFontName(FONT_SIMHEI) 
            num:setFontSize(BASE_FONT_SIZE) 
            num:enableOutline(cc.c4b(0, 0, 0, 250), 1)
            ccui.Helper:seekWidgetByName(panel, "Flag"):setVisible(false)
        end
    end
end

function UIRewardList:Unload()
    UIBase:Unload()
    self._ResourceName = nil
    self._Type = nil
end

function UIRewardList:Open()
    UIBase.Open(self)
    PlaySound(Sound_30)
end

function UIRewardList:Close()
    UIBase.Close(self)
end

function UIRewardList:OpenUISucceed(data)
    _Instance._RewardList = data
    _Instance._GridView:reloadData() 
end

function UIRewardList:TouchEvent(eventType, x, y)
    if eventType == ccui.TouchEventType.ended then
        local tag = self:getTag()
        if tag == -2  then
        elseif tag == -1  then
            UISystem:CloseUI(UIType.UIType_RewardUI) 
        end
    end
end

return UIRewardList