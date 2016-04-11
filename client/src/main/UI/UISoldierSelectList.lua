----
-- 文件名称：UISoldierSelectList.lua
-- 功能描述：士兵选择列表(目前布阵中用到)
-- 文件说明：士兵选择列表
-- 作    者：王雷雷
-- 创建时间：2015-7-21
--  修改
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
require("cocos.ui.DeprecatedUIEnum")
require("cocos.extension.ExtensionConstants")

local ItemDataManager = GameGlobal:GetItemDataManager() 
local CharacterServerDataManager = GameGlobal:GetCharacterServerDataManager()
local UISystem = GameGlobal:GetUISystem()
local _Instance = nil
--每行几个cell 
local rowNum = 5

local UISoldierSelectList = class("UISoldierSelectList", UIBase)

function UISoldierSelectList:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_SoldierSelectListUI
    self._ResourceName = "warriors.csb"  
    --tableView
    self._GridView = nil
    --ID列表
    self._SoldiersIDList = nil
    --当前选择的士兵ID
    self._CurrentSelectSoldierID = nil
end
--Load
function UISoldierSelectList:Load()
    UIBase.Load(self)
    --TODO:改掉这些数字的东东
    -- tableView 
    self._GridView = CreateTableView(250, 153, 450, 300, 1, self)
    self._RootPanelNode:addChild(self._GridView)

    local title = seekNodeByName(self._RootPanelNode, "Text_1")
    local confirmButton = seekNodeByName(self._RootPanelNode, "Button_3")
    confirmButton:setVisible(false)
--    title:enableOutline(cc.c4b(77, 39, 18, 250), 2)
    title:setString("兵种选择")
--    title:setPositionY(28)
    local close = self:GetWigetByName("Close")
    close:setTag(-1)
    close:addTouchEventListener(self.TouchEvent)
end

--Unload
function UISoldierSelectList:Unload()
    UIBase:Unload()
    self._GridView = nil
    self._SoldiersIDList = nil
end

--打开
function UISoldierSelectList:Open()
    UIBase.Open(self)
    self:RefreshSoldierList()

end

--关闭
function UISoldierSelectList:Close()
    UIBase.Close(self)
end

--刷新UI士兵列表
function UISoldierSelectList:RefreshSoldierList()
    --士兵数据及排序
    self._SoldiersIDList = {}
    for k, v in pairs(CharacterServerDataManager._OwnSolderList)do
        table.insert(self._SoldiersIDList, k)
    end
    --所有士兵排列规则为品质-等级"
    table.sort(self._SoldiersIDList,function(a, b)
        local soldier1 = CharacterServerDataManager:GetSoldier(a)
        local soldier2 = CharacterServerDataManager:GetSoldier(b)
        if soldier1._CharacterData.quality == soldier2._CharacterData.quality then
            if soldier1._Level == soldier2._Level then
                if soldier1._TableID == soldier2._TableID then
                    return false
                else
                    return soldier1._TableID < soldier2._TableID
                end
            else
                return soldier1._Level > soldier2._Level
            end
        else
            return soldier1._CharacterData.quality > soldier2._CharacterData.quality
        end
        if soldier1 ~= nil and soldier2 ~= nil then
            return soldier1._TableID < soldier2._TableID
        end
    end)
    
    if #self._SoldiersIDList > 0  then
        self._GridView:reloadData() 
    end
end

--设置当前选中的士兵
function UISoldierSelectList:SetCurrentSelectSoldier(selectSoldierTableID)
    self._CurrentSelectSoldierID = selectSoldierTableID
    if #self._SoldiersIDList > 0  then
        self._GridView:reloadData() 
    end
end
------------------------------------------tableview-------------------------------

function UISoldierSelectList.ScrollViewDidScroll()

end

function UISoldierSelectList.NumberOfCellsInTableView()
    local uiInstance = UISystem:GetUIInstance(UIType.UIType_SoldierSelectListUI)
    local num = math.ceil(#uiInstance._SoldiersIDList / rowNum)
    return num
end

function UISoldierSelectList.TableCellTouched(view, cell)
--    local index = cell:getIdx()
--    local uiInstance = UISystem:GetUIInstance(UIType.UIType_SoldierSelectListUI)
--    uiInstance._CurrentSelectSoldierID = uiInstance._SoldiersIDList[index + 1]
--    uiInstance:OnClickCell()
end

function UISoldierSelectList.CellSizeForTable(view, idx)
    return 400, 106
end

function UISoldierSelectList.TableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
        cell:retain()
        local layout = cc.CSLoader:createNode("csb/ui/ListPage.csb")
        cell:addChild(layout, 0, idx)
    else
        cell:removeAllChildren(true)
        local layout = cc.CSLoader:createNode("csb/ui/ListPage.csb")
        cell:addChild(layout, 0, idx)
    end
    local uiInstance = UISystem:GetUIInstance(UIType.UIType_SoldierSelectListUI)
    uiInstance:InitCell(cell, idx)
    return cell
end

function UISoldierSelectList:InitCell(cell, idx)
    local layout = cell:getChildByTag(idx)
--    local title1 = seekNodeByName(seekNodeByName(panel, "title"), "Text_1")
--    title1:enableOutline(cc.c4b(77, 39, 18, 250), 2)
--    title1:setTextColor()
--    title1:setString("兵种选择")
    for i = 1, rowNum do
        local panel = seekNodeByName(layout, "Panel_"..i)
        if panel ~= nil then
            panel:setSwallowTouches(false)
            local soldierItem = CharacterServerDataManager:GetSoldier(self._SoldiersIDList[idx*rowNum + i])
            if soldierItem ~= nil then
                local icon = ccui.Helper:seekWidgetByName(panel, "icon")
                icon:setSwallowTouches(false)
                icon:loadTexture(GetSoldierHeadPath(soldierItem._CharacterData.headName), UI_TEX_TYPE_LOCAL)
                local Button_1 = ccui.Helper:seekWidgetByName(panel, "Button_1")
                Button_1:setSwallowTouches(false)
                Button_1:setTag(idx*rowNum + i + 100)
                Button_1:addTouchEventListener(self.touchSoldier)
--                local width = Button_1:getContentSize().width
--                local height = Button_1:getContentSize().height
--                Button_1:loadTextures("meishu/ui/gg/UI_gg_zhuangbeikuang_zi.png", "meishu/ui/gg/UI_gg_zhuangbeikuang_zi.png", UI_TEX_TYPE_LOCAL)
--                Button_1:setContentSize(cc.size(69, 69))
                local Text_1 = ccui.Helper:seekWidgetByName(panel, "Text_1")
--                Text_1:setTextColor(GetQualityColor(tonumber(soldierItem._CharacterData.quality)))
                Text_1:setString(soldierItem._CharacterData.name)
                local Text_2 = ccui.Helper:seekWidgetByName(panel, "Text_2")
                Text_2:setString("lv."..soldierItem._Level)
--                Text_2:setFontSize(16)
--                Text_2:setAnchorPoint(1, 0.5)

                local flag = ccui.Helper:seekWidgetByName(panel, "Flag")
                --local uiInstance = UISystem:GetUIInstance(UIType.UIType_BuZhen)
                if self._CurrentSelectSoldierID == self._SoldiersIDList[idx*rowNum + i] then
--                    flag:loadTexture("meishu/ui/gg/UI_gg_xuanzhongduigou.png")
--                    flag:setPosition(Button_1:getPositionX(), Button_1:getPositionY())
--                    flag:setContentSize(cc.size(80, 80))
                    flag:setVisible(true)
--                else
--                    flag:setVisible(false)
                end
            else
                panel:setVisible(false)
            end
        end
    end
    
--
--    if panel ~= nil then
--        panel:setSwallowTouches(false) 
--        
--        
--        
--        
--        
--        if idx < #self._SoldiersIDList then
--            local button = ccui.Helper:seekWidgetByName(panel, "Button_1")
--            button:setSwallowTouches(false) 
--            local icon = ccui.Helper:seekWidgetByName(panel, "icon")
--            icon:setSwallowTouches(false) 
--            local text = ccui.Helper:seekWidgetByName(panel, "Text_1")
--            local soldierItem = CharacterServerDataManager:GetSoldier(self._SoldiersIDList[idx + 1])
--            if soldierItem ~= nil then
----                local star = ccui.Helper:seekWidgetByName(panel, "star")
----                star:setSwallowTouches(false) 
----                star:loadTexture("meishu/ui/gg/"..soldierItem._CharacterData.quality..".png")
--                local color = GetQualityColor(tonumber(soldierItem._CharacterData.quality))
--                text:setString(soldierItem._CharacterData.name)
----                text:setFontName(FONT_SIMHEI) 
--                text:enableOutline(cc.c4b(0, 0, 0, 250), 1)
--               -- text:setColor(color)
--                icon:loadTexture(GetSoldierHeadPath(soldierItem._CharacterData.headName), UI_TEX_TYPE_LOCAL)
--                local num = ccui.Helper:seekWidgetByName(panel, "Text_2")
--                num:setString("lv"..soldierItem._Level)
--                num:setFontName(FONT_SIMHEI) 
--                num:enableOutline(cc.c4b(0, 0, 0, 250), 1)
--                ccui.Helper:seekWidgetByName(panel, "Flag"):setVisible(false)
--            end
--        end
--    end
end

function UISoldierSelectList.touchSoldier(sender, eventType)
     if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
        local uiInstance = UISystem:GetUIInstance(UIType.UIType_SoldierSelectListUI)
        uiInstance._CurrentSelectSoldierID = uiInstance._SoldiersIDList[tag - 100]
        uiInstance:OnClickCell()
     end
end

--点击了某士兵
function UISoldierSelectList:OnClickCell()
    local uiInstance = UISystem:GetUIInstance(UIType.UIType_SoldierSelectListUI)
    local soldierItem = CharacterServerDataManager:GetSoldier(self._CurrentSelectSoldierID)
    --不再弹出Tips界面
    --local UITip = require("main.UI.UITip") 
    --UITip:OpenSoldierTips(480, 50, soldierItem, self.OnTipOK)
    DispatchEvent(GameEvent.GameEvent_UIBuZhen_SoldierSelect, {selectSoldierID = self._CurrentSelectSoldierID})
    UISystem:CloseUI(UIType.UIType_SoldierSelectListUI) 
end

--确认士兵
function UISoldierSelectList:ConfirmSoldier()
    DispatchEvent(GameEvent.GameEvent_UIBuZhen_SoldierSelect, {selectSoldierID = self._CurrentSelectSoldierID})
end

function UISoldierSelectList:TouchEvent(eventType, x, y)
    if eventType == ccui.TouchEventType.ended then
        local tag = self:getTag()
        if tag == -2  then
            
        --关闭
        elseif tag == -1  then
            UISystem:CloseUI(UIType.UIType_SoldierSelectListUI) 
        end
    end
end
--Tip按钮回调
function UISoldierSelectList.OnTipOK(num)
    if num == 1 then
        local uiInstance = UISystem:GetUIInstance(UIType.UIType_SoldierSelectListUI)
        uiInstance:ConfirmSoldier()
        UISystem:CloseUI(UIType.UIType_SoldierSelectListUI) 
    end
end

return UISoldierSelectList