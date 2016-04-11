----
-- 文件名称：UIRebornWarriorList.lua
-- 功能描述：warriorList
-- 文件说明：warriorList
-- 作    者：田凯
-- 创建时间：2015-6-26
--  修改
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
require("cocos.ui.DeprecatedUIEnum")
require("cocos.extension.ExtensionConstants")
local CharacterServerDataManager = require("main.ServerData.CharacterServerDataManager")
local ItemDataManager = GameGlobal:GetItemDataManager() 
local UISystem = GameGlobal:GetUISystem()
local _Instance = nil 

local UIRebornWarriorList = class("UIRebornWarriorList", UIBase)
 
function UIRebornWarriorList:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_RebornWarriorListUI
    self._ResourceName = "warriors.csb"  
end

function UIRebornWarriorList:Load()
    UIBase.Load(self)
    _Instance = self
    -- tableView 
    self._RootPanelNode:setSwallowTouches(true) 
    local close = tolua.cast(self._RootPanelNode:getChildByTag(95), "Button")
    close:setTag(-1)
    close:addTouchEventListener(self.TouchEvent)
    self._ConfirmBtn = self:GetWigetByName("Button_3")
    self._ConfirmBtn:setTag(-2)
    self._ConfirmBtn:addTouchEventListener(self.TouchEvent)
    
end

function UIRebornWarriorList.ScrollViewDidScroll()

end

function UIRebornWarriorList.NumberOfCellsInTableView()
    return #_Instance:GetWarriorList() % 5 == 0 and math.floor(#_Instance:GetWarriorList() / 5 ) or math.floor(#_Instance:GetWarriorList() / 5 + 1)
end

function UIRebornWarriorList.TableCellTouched(view, cell)
    local index = cell:getIdx()
    _Instance._CurSelectWarriorID = _Instance:GetWarriorList()[index + 1]
   
    --DispatchEvent(GameEvent.GameEvent_UIRebornListSelect_Succeed, _Instance._CurSelectWarriorID)
    --_Instance:OpenWarriorInfo()
end

function UIRebornWarriorList.CellSizeForTable(view, idx)
    return 450, 100
end

function UIRebornWarriorList.TableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
    end
    cell:removeAllChildren(true)
    local layout = cc.CSLoader:createNode("csb/ui/CheckLayer.csb")
    cell:addChild(layout, 0, idx)
    
    _Instance:InitCell(cell, idx)
    return cell
end

function UIRebornWarriorList:CheckBoxEvent(eventType)
     
    if eventType == ccui.TouchEventType.ended then
        local state = 0
        print(seekNodeByName(self, "check"):isVisible())
        if seekNodeByName(self, "check"):isVisible() then
            state = 1
        end
        local reborn = UISystem:GetUIInstance(UIType.UIType_RebornUI)
        if state == 0 then
            local count = 1
            for i = 2 ,6 do
                if reborn._CurSelectList[i] ~= nil then
                    count = count + 1
                end
                if _Instance._WarriorSelectTable[i] ~= nil then
                    count = count + 1
                end
            end
            if count < 6 then
                seekNodeByName(self, "check"):setVisible(true)
                if _Instance._WarriorSelectTable[reborn._CurFrameIndex] == nil then
                    _Instance._WarriorSelectTable[reborn._CurFrameIndex] = self:getTag()
                    return
                end
                for i = 2 ,6 do
                    if reborn._CurSelectList[i] == nil and reborn._CurFrameIndex ~= i and _Instance._WarriorSelectTable[i] == nil then
                        _Instance._WarriorSelectTable[i] = self:getTag()
                        return
                    end
                end
                print(seekNodeByName(self, "check"):isVisible())
                
            else
                seekNodeByName(self, "check"):setVisible(false)
                CreateTipAction(_Instance._RootUINode, ChineseConvert["UIReBornSelectM"], cc.p(480, 270))
                local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                UITip:SetStyle(1, "只需要5名材料武将")
            end
        else
            seekNodeByName(self, "check"):setVisible(false)
            for i = 2 ,6 do
                if _Instance._WarriorSelectTable[i] == self:getTag() then
                    _Instance._WarriorSelectTable[i] = nil
                    return
                end
            end
        end
    end
end

function UIRebornWarriorList:InitCell(cell, idx)
    local layout = cell:getChildByTag(idx)
    
    for i = 1, 5 do
        local panel = seekNodeByName(layout, "Panel_"..i)
        panel:setSwallowTouches(false) 
        if idx * 5 + i <= #_Instance:GetWarriorList() then
--            local button = ccui.Helper:seekWidgetByName(panel, "CheckBox_1")
--            button:setSwallowTouches(false) 
            local star = ccui.Helper:seekWidgetByName(panel, "star")
            star:setSwallowTouches(false) 
            local warrior = CharacterServerDataManager:GetLeader(_Instance:GetWarriorList()[idx * 5 + i])
            local add = true
            local reborn = UISystem:GetUIInstance(UIType.UIType_RebornUI)
            for j = 2, 6 do
                if reborn._CurSelectList[j] == _Instance:GetWarriorList()[idx * 5 + i] then
                    add = false
                end
            end
            if add then
                seekNodeByName(star, "check"):setVisible(false)
                --button:setSelected(false)
            else
                seekNodeByName(star, "check"):setVisible(true)
                --button:setSelected(true)
            end
            star:loadTexture("meishu/ui/gg/"..warrior._CharacterData["quality"]..".png")
            
            
            --button:setTag(tonumber(_Instance:GetWarriorList()[idx * 5 + i]))
            --button:addEventListener(self.CheckBoxEvent)
            star:setTag(tonumber(_Instance:GetWarriorList()[idx * 5 + i]))
            star:addTouchEventListener(self.CheckBoxEvent)
            
            local icon = ccui.Helper:seekWidgetByName(panel, "icon")
            icon:setSwallowTouches(false)  
            local text = ccui.Helper:seekWidgetByName(panel, "Text_1")

            local color = GetQualityColor(tonumber(warrior._CharacterData["quality"]))
            text:setString(warrior._CharacterData["name"])
            text:setTextColor(color)
            
            local num = ccui.Helper:seekWidgetByName(panel, "Text_2")
            num:setString("Lv"..warrior._Level)
            
            icon:loadTexture(GetWarriorHeadPath(warrior._CharacterData["headName"]), UI_TEX_TYPE_LOCAL)

            ccui.Helper:seekWidgetByName(panel, "Flag"):setVisible(false)
        else
            panel:setVisible(false)
        end
    end
    
end

function UIRebornWarriorList:Unload()
    UIBase:Unload()
    self._ResourceName = nil
    self._Type = nil
    self._EquipID11 = nil
    self._EquipID12 = nil 
    self._EquipID13 = nil
    self._EquipID14 = nil
    self._EquipID15 = nil
    self._EquipID16 = nil
end

function UIRebornWarriorList:Open()
    UIBase.Open(self)
    self._WarriorSelectTable = {}
    self._GridView = CreateTableView(270, 200, 400, 200, 1, self)
    self._GridView:setOpacity(0)
    self._RootPanelNode:addChild(self._GridView)

    self.OpenCallBack = AddEvent(GameEvent.GameEvent_UIRebornList_Succeed, self.OpenUISucceed)
end

function UIRebornWarriorList:Close()
    UIBase.Close(self)
    if self.OpenCallBack ~= nil then
        RemoveEvent(self.OpenCallBack)
        self.OpenCallBack = nil
    end
    self._GridView:removeFromParent(true)
end

function UIRebornWarriorList:OpenUISucceed()
    _Instance._RebornWarriorList = {}
    
    local quality = self._usedata
    local reborn = UISystem:GetUIInstance(UIType.UIType_RebornUI)

    for i,v in pairs(CharacterServerDataManager._OwnLeaderList) do
        if v._CharacterData["quality"] == quality and reborn._RebornID ~= i  then
            local add = true
--            for j = 2, 6 do
--                if reborn._CurSelectList[j] == i then
--                    add = false
--                end
--            end
            if add then 
                table.insert( _Instance._RebornWarriorList, i)
            end
        end
    end
    table.sort(_Instance._RebornWarriorList, function(a, b)
       local w1 = CharacterServerDataManager:GetLeader(a)
       local w2 = CharacterServerDataManager:GetLeader(b)
       return w1._Level < w2._Level
    end)
    
    if #_Instance._RebornWarriorList > 0 then
        _Instance._GridView:reloadData() 
    end
end

function UIRebornWarriorList:GetWarriorList()
   return self._RebornWarriorList
end

function UIRebornWarriorList:OpenWarriorInfo()
    local UITip = require("main.UI.UITip") 
    UITip:OpenEquipInfo(480, 50, equip, self.TakeEquip, _Instance._TakeType)
end

function UIRebornWarriorList:TouchEvent(eventType, x, y)
    if eventType == ccui.TouchEventType.ended then
        local tag = self:getTag()
        if tag == -1 then
            UISystem:CloseUI(UIType.UIType_RebornWarriorListUI) 
        elseif tag == -2 then
            local reborn = UISystem:GetUIInstance(UIType.UIType_RebornUI)
            for i = 2 ,6 do
                if reborn._CurSelectList[i] == nil and _Instance._WarriorSelectTable[i] ~= nil then
                    reborn._CurSelectList[i] = _Instance._WarriorSelectTable[i]
                end
            end
            DispatchEvent(GameEvent.GameEvent_UIRebornListSelect_Succeed, _Instance._CurSelectWarriorID) 
        end
    end
end

function UIRebornWarriorList:TakeEquip()
    
    local equip = ItemDataManager:GetItem(_Instance._CurSelectEquipID)

    if _Instance._TakeType ~= -1 then
        SendMsg(PacketDefine.PacketDefine_TakeEquip_Send)
        if _Instance._TakeType == 1 then
            DispatchEvent(GameEvent.GameEvent_UIWarrior_Equip_TakeOn, ItemDataManager:GetItem(_Instance._CurSelectEquipID))
        else
            DispatchEvent(GameEvent.GameEvent_UIWarrior_Equip_TakeOff, ItemDataManager:GetItem(_Instance._CurSelectEquipID))
        end
    end
end

return UIRebornWarriorList