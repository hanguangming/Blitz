----
-- 文件名称：UISoldier.lua
-- 功能描述：士兵
-- 文件说明：士兵
-- 作    者：王峰
-- 创建时间：2015-6-15
--  修改
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
require("src.cocos.ui.GuiConstants")

local UISystem = require("main.UI.UISystem")
local SoldierData = require("main.ServerData.CharacterServerDataManager")
local ExpData = require("main.DataPool.TableDataManager") 
local stringFormat = string.format
local UISoldier = class("UISoldier", UIBase) 
local COLS_NUMBER = 5
local CELL_COL_ROW = 1   
local CELL_SIZE_WIDTH = 120
local CELL_SIZE_HEIGHT = 85

function UISoldier:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_SoldierUI
    self._ResourceName = "UISoldierPanel.csb"  
end

function UISoldier:Load()
    UIBase.Load(self)
    
    for i = 1, 10 do
        local text = self:GetWigetByName("Text_"..i)
    end
    self._Slider = self:GetWigetByName("Slider_1")
    self._ItemIndex = 1
    local center = seekNodeByName(self._RootPanelNode, "Panel_Center")
    self._GridView = CreateTableView_(-410, -235, 200, 430, 1, self)
    self:simulateClickButton(0, 1)
    center:addChild(self._GridView)
    self._NameLabel = self:GetWigetByName("Text_Name")
    self._LevelLabel = self:GetWigetByName("Text_Level")
    self._ProfessionLabel = self:GetWigetByName("Text_SoldierType")
    self._AtkTypeLabel = self:GetWigetByName("Text_ATK_Type")
    self._HpLabel = self:GetWigetByName("Text_HP_Value")
    self._AtkLabel = self:GetWigetByName("Text_ATk_Value")
    self._AtkSpeedLabel = self:GetWigetByName("Text_ATK_Speed")
    self._MoveSpeedLabel = self:GetWigetByName("Text_Move_Speed")
    self._PopulationLabel = self:GetWigetByName("Text_Population")
    self._LbExp = self:GetWigetByName("Text_LB_Exp")
    self._AnimParentNode = self:GetUIByName("Node_Small")
    self._ExpLodingBar  = self:GetWigetByName("LoadingBar_Exp")
    self._BodyImage = self:GetWigetByName("Image_QuanShen")
    self._BodyStarImage = self:GetUIByName("Star_Bg")
    self._AtkJuli = self:GetWigetByName("Text_ATK_JuLi")
    self._JumpToTrainBtn = self:GetWigetByName("Button_Train")
    self._JumpToTrainBtn:addTouchEventListener(handler(self, self.touchEvent))
    self._JumpToTrainBtn:setTag(1)
    self._AdvanceBtn = self:GetWigetByName("Button_Advance")
    self._AdvanceBtn:addTouchEventListener(handler(self, self.touchEvent))
    self._AdvanceBtn:setTag(2)
    self._LockBtn = self:GetWigetByName("Button_Lock")
    self._LockBtn:addTouchEventListener(handler(self, self.touchEvent))
    self._LockBtn:setTag(3)
    local close = self:GetWigetByName("Close")
    close:addTouchEventListener(handler(self, self.touchEvent))
    close:setTag(-1)  
end

function UISoldier:Open()
    UIBase.Open(self)
    -- 加入选择框
    self._SelectFrame = self:createSelectFrame()
    self._GridView:addChild(self._SelectFrame)
    self._SelectFrame:retain()
    local all = GameGlobal:GetSoliderIDList()
    local WarriorManager = GameGlobal:GetDataTableManager():GetCharacterDataManager()
    self._SolderID = {}
    self._SolderUnOpenID = {}

    for i, v in pairs(SoldierData._OwnSolderList) do
        table.insert(self._SolderID, i)
    end

    table.sort(self._SolderID, function(a, b)
        if WarriorManager[a]["quality"] == WarriorManager[b]["quality"] then
            local l1 = SoldierData:GetSoldier(a)._Level
            local l2 = SoldierData:GetSoldier(b)._Level
            return l1 > l2
        else
            return WarriorManager[a]["quality"] > WarriorManager[b]["quality"]
        end
    end)

    for i, v in pairs(all) do
        local str = table.concat(self._SolderID, ",")
        local notin = true
        if notin then
            if v % 10 == 6 and v > 10055 then
                for _, v1 in pairs(self._SolderID) do
                    if math.abs(tonumber(v1) - v) < 10 and WarriorManager[v]["type1"] == WarriorManager[v1]["type1"] then
                        v = v1
                    end
                end
                table.insert(self._SolderUnOpenID, v)
            elseif v % 10 == 1 and v < 10055 then
                for _, v1 in pairs(self._SolderID) do
                    if math.abs(tonumber(v1) - v) < 10 and WarriorManager[v]["type1"] == WarriorManager[v1]["type1"] then
                        v = v1
                    end
                end
                table.insert(self._SolderUnOpenID, v)
            end
        end
    end

    table.sort(self._SolderUnOpenID, function(a, b)
        return tonumber(a) < tonumber(b)
    end)
    self._ListLen = #self._SolderUnOpenID 

    -- 上下箭头 初始化    下显上不显
    self._ImageUp = self:GetWigetByName("Image_Up")
    self._ImageUp:setLocalZOrder(1)
    self._ImageUp:setVisible(false)
    self._ImageDown = self:GetWigetByName("Image_Down")
    self._ImageDown:setLocalZOrder(1)
    self._GridView:reloadData()
    -- 打开UI时就刷新UI内容
    self:updateUI(self._SolderUnOpenID[1])
    self:addEvent(GameEvent.GameEvent_UISoldier_Update,self.update)
end

function UISoldier:Close()
    UIBase.Close(self)
    removeNodeAndRelease(self._SelectFrame, true)    
    -- 士兵小动画
    self._AnimParentNode:removeAllChildren(true)
end

function UISoldier:ScrollViewDidScroll(view)
    local point = view:getContentOffset()
    local len = view:getContentSize().height - view:getViewSize().height
    local percent = - (point.y / len)
    if self._Slider ~= nil then
        if view:isDragging() then
            self._Slider:setVisible(true)
            self._Slider:getParent():setVisible(true)
        else
            self._Slider:getParent():setVisible(false)
            self._Slider:setVisible(false)
        end
        self._Slider:setPercent((1 - percent)*100)
    end
    if percent >= 1 then
        self._ImageUp:setVisible(false)
        self._ImageDown:setVisible(true)
    elseif percent <= 0 and len > 0 then
        self._ImageUp:setVisible(true)
        self._ImageDown:setVisible(false)
    end
end

function UISoldier:NumberOfCellsInTableView()
    local len = 0
    local curTabIDList = self._ListLen
    len = curTabIDList % CELL_COL_ROW == 0 and math.floor(curTabIDList / CELL_COL_ROW) or math.floor(curTabIDList / CELL_COL_ROW) + 1
    return len
end

function UISoldier:TableCellTouched(view, cell)
    local layout = cell:getChildByTag(tonumber(cell:getIdx()))
    local panel = seekNodeByName(layout, "Panel_1")
    -- cell缩放动画
    local actionTo = cc.ScaleTo:create(0.1, 0.9)
    local actionTo2 = cc.ScaleTo:create(0.1, 1.0)
    panel:runAction(cc.Sequence:create(actionTo, actionTo2)) 
    
    if  self._ItemIndex ~= cell:getIdx() + 1 then
        self:selectAnimation(panel)
    end
    
    self._ItemIndex = (cell:getIdx() * CELL_COL_ROW) + 1
    local index = nil
    
    for j = 1, #self._SolderID do
        if self._SolderUnOpenID[self._ItemIndex] == self._SolderID[j] then
            index = j
        end
    end
    
    if index ~= nil then
        self._ItemIndex = index
        self:updateUI(self._SolderID[self._ItemIndex])
    else
        self:updateUI(self._SolderUnOpenID[self._ItemIndex], 1)
    end
end

function UISoldier:CellSizeForTable(view, idx)
    return CELL_SIZE_WIDTH, CELL_SIZE_HEIGHT
end

function UISoldier:TableViewItemTouchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self._CurCellTag = sender:getTag()
        self._ItemIndex = self._CurCellTag + 1
        local index = 20
        
        for j = 1, #self._SolderID do
            if self._SolderUnOpenID[self._ItemIndex] == self._SolderID[j] then
                index = j
            end
        end
      
        if index <= #self._SolderID then
            self._ItemIndex = index
            self:updateUI(self._SolderID[self._ItemIndex])
        else
            self:updateUI(self._SolderUnOpenID[self._ItemIndex], 1)
        end
    end
end

function UISoldier:TableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
    end
    cell = self:clearCell(cell, idx) 
    return cell
end

function UISoldier:clearCell(cell, idx) 
    cell:removeAllChildren(true)
    local layout = cc.CSLoader:createNode("csb/ui/WarriorItem.csb")
    local panel = seekNodeByName(layout, "Panel_1")
    panel:setSwallowTouches(false)
    local button = seekNodeByName(panel, "Button_2")
    button:setSwallowTouches(false)
    seekNodeByName(panel, "Image_2"):setSwallowTouches(false)
    layout:setPosition(cc.p(0, 0))
    cell:addChild(layout, 0, idx)
    self:initCell(cell, idx)
    return cell
end

function UISoldier:initCell(cell, idx) 
    local layout = cell:getChildByTag(tonumber(idx))
    local panel = seekNodeByName(layout, "Panel_1")
    local head = seekNodeByName(panel, "Image_2")
    local name = seekNodeByName(panel, "Text_1")
    local level = seekNodeByName(panel, "Text_2")
    local battleImage = seekNodeByName(panel, "Image_Battle")
    local TypeImage = seekNodeByName(panel, "Image_Type")
    local trainImage = seekNodeByName(panel, "Image_TrainIcon")
    local headDiColorImage = seekNodeByName(panel, "Image_35")
    local button = seekNodeByName(panel, "Button_2")
    panel:setVisible(false)
    
    if idx * CELL_COL_ROW + 1 <= self._ListLen then 
        panel:setVisible(true)
        local WarriorManager = GameGlobal:GetDataTableManager():GetCharacterDataManager()
        local actor = WarriorManager[self._SolderUnOpenID[idx * CELL_COL_ROW + 1]]
        head:loadTexture(GetSoldierHeadPath(actor["headName"])) 
        battleImage:setVisible(false)
        trainImage:setVisible(false)
        button:setBright(true)
        TypeImage:loadTexture(GetSoldierProperty(actor.soldierType))
        local isOpen = false
        for j = 1, #self._SolderID do
            if self._SolderUnOpenID[idx * CELL_COL_ROW + 1] == self._SolderID[j] then
                isOpen = true
            end
        end
        headDiColorImage:loadTexture(GetHeadColorImage(actor.quality))
--        headDiColorImage:loadTexture("meishu/ui/gg/"..actor.quality..".png")
        
        if not isOpen then
            button:setBright(false)
            headDiColorImage:loadTexture("meishu/ui/gg/UI_gg_touxiangpinzhi_01.png")
            seekNodeByName(panel, "Image_1"):setVisible(false)
            local TypeImage = seekNodeByName(panel, "Image_Suo")
            TypeImage:setVisible(true)
            name:setTextColor(cc.c3b(59, 59, 59))
            level:setTextColor(cc.c3b(59, 59, 59))
        else
            local soldier = SoldierData:GetSoldier(self._SolderUnOpenID[idx * CELL_COL_ROW + 1])
            if soldier._Time ~= 0 then
                trainImage:setVisible(true)
            end
            level:setString("lv"..soldier._Level)
        end
        name:setString(actor["name"])
     end
     
    if 0 ==  idx then
        self:selectAnimation(panel)
    end
end

function UISoldier:touchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if sender:getTag() == -1 then
            UISystem:CloseUI(UIType.UIType_AdvancedUI)
            UISystem:CloseUI(UIType.UIType_TrainUI) 
            UISystem:CloseUI(UIType.UIType_SoldierUI) 
        elseif sender:getTag() == 1 then
            UISystem:CloseUI(UIType.UIType_SoldierUI)
            local train = UISystem:OpenUI(UIType.UIType_TrainUI)
            train:ChangeTabState(2)
        elseif sender:getTag() == 2 then
            UISystem:OpenUI(UIType.UIType_AdvancedUI)
            performWithDelay(sender, self.delayCallBack, 0)
        elseif sender:getTag() == 3 then
            UISystem:OpenUI(UIType.UIType_Technology)
        end
    end
end

function UISoldier:updateSolider()
    self._SolderID = {}
    for i, v in pairs(SoldierData._OwnSolderList) do
        table.insert(self._SolderID, i)
    end 
    self._GridView:reloadData()
    SoldierData._TrainSoldierID = self._SolderID[self._ItemIndex]
end

function UISoldier:delayCallBack()
    DispatchEvent(GameEvent.GameEvent_UIAdvanced_Succeed, SoldierData:GetSoldier(SoldierData._TrainSoldierID))
end

function UISoldier:updateUI(ID, type)
    local soldierData
    if type == nil then
        SoldierData._TrainSoldierID = ID
        soldierData = SoldierData:GetSoldier(ID)
    else
        soldierData = SoldierData:NewSoldier(ID)
    end

    if soldierData == nil then
        return
    end

    if self._NameLabel then
        self._NameLabel:setColor(GetQualityColor(tonumber(soldierData._CharacterData.quality)))
        self._NameLabel:setString(soldierData._CharacterData.name)
    end

    if self._LevelLabel then
        self._LevelLabel:setString(soldierData._Level)
    end

    if  self._ProfessionLabel then
        self._ProfessionLabel:setString(GetSoldierType(soldierData._CharacterData.soldierType))
    end

    if self._AtkTypeLabel then
        self._AtkTypeLabel:setString(GetSoldierAttackType(soldierData._CharacterSkillData1["zoneType"]))
    end

    if  self._HpLabel then
        local hpValueString = stringFormat("%d(%d)",
            soldierData._Hp,
            soldierData._CharacterData.hpup)
        self._HpLabel:setString(hpValueString)
    end

    if  self._AtkLabel then
        local atkValueString = stringFormat("%d(%d)",
            soldierData._Attack,
            soldierData._CharacterData.attackup)
        self._AtkLabel:setString(atkValueString)
    end

    if  self._AtkSpeedLabel then

        self._AtkSpeedLabel:setString(soldierData._AtkSpeed)
    end

    if  self._MoveSpeedLabel then
        self._MoveSpeedLabel:setString(soldierData._MoveSpeed)
    end

    if self._ConsumeLabel then
        self._ConsumeLabel:setString(soldierData._Consume)
    end

    if self._PopulationLabel then
        self._PopulationLabel:setString(soldierData._Population)
    end

    if self._Output then
        self._Output:setString(soldierData._Output)
    end

    local expData = ExpData:GetExpDataManager()
    local expMax = expData[soldierData._Level].soldierExp
    if self._LbExp then
        local lbExpString = stringFormat("%d/%d",soldierData._Exp,expMax)
        self._LbExp:setString(lbExpString)
    end

    if self._ExpLodingBar then
        local percent = tonumber(soldierData._Exp)/tonumber(expMax) *100
        self._ExpLodingBar:setPercent(percent)
    end

    if self._BodyImage then
        self._BodyImage:loadTexture(GetSoldierBodyPath(soldierData._CharacterData.bodyImage))
    end

    if self._AtkJuli then
        self._AtkJuli:setString(soldierData._CharacterData.maxAttackDistance)
    end

    -- 士兵动画
    self._AnimParentNode:removeAllChildren()
    local animNode = cc.CSLoader:createNode(GetSoldierCsbPath(soldierData._CharacterData.resName))
    local anim = cc.CSLoader:createTimeline(GetSoldierCsbPath(soldierData._CharacterData.resName))
    self._AnimParentNode:addChild(animNode)
    anim:play("Walk",true)
    animNode:runAction(anim)

    local soldierQuality = tonumber(soldierData._CharacterData["quality"])
    if soldierQuality ~= 1 and soldierQuality ~= 2 and soldierQuality ~= 3 then
        self._BodyStarImage:setVisible(true)
        ccui.Helper:seekWidgetByName(self._BodyStarImage, "Star_1"):loadTexture(GetWarriorStarImage(soldierData._CharacterData["quality"]))
    else
        self._BodyStarImage:setVisible(false)
    end
end

function UISoldier:update()
    self:updateUI(self._SolderID[1])
end

function UISoldier:simulateClickButton(idx, tag)
    local cell = self._GridView:cellAtIndex(idx)
    if cell ~= nil then
        local layout = cell:getChildByTag(idx)
        local panel = seekNodeByName(layout, "Soldier_Panel_"..tag)
        local button = seekNodeByName(panel, "Button_1")
        if button ~= nil then
            SimulateClickButton(button, handlers(self, self.tableViewItemTouchEvent, 2)) 
        end
    end
end

function UISoldier:selectAnimation(node)
    self._SelectFrame:removeFromParent(true)
    node:addChild(self._SelectFrame, 50)
    local actionBy = cc.RotateBy:create(1.5, -360)
    self._SelectFrame:runAction(cc.RepeatForever:create(actionBy)) 
end

function UISoldier:createSelectFrame()
    local selectFrame = display.newSprite("meishu/ui/gg/UI_gg_xuanzhongguangquan.png", 0, 800, 
        {
            scale9 = true, 
            capInsets = cc.rect(40, 40, 20, 20), 
            rect = cc.rect(0, 0, 200, 200)
        })
    selectFrame:setAnchorPoint(0.5, 0.5)
    selectFrame:ignoreAnchorPointForPosition(false)
    selectFrame:setPosition(40, 40)
    selectFrame:setScale(0.55)
    return selectFrame
end

return UISoldier