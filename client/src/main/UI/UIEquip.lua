----
-- 文件名称：UIEquip.lua
-- 功能描述：测试UI
-- 文件说明：
-- 作    者：田凯
-- 创建时间：2015-7-8
-- 修改 ：
--  测试UI动画的支持情况
--
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
local UISystem =  GameGlobal:GetUISystem()
local UIEquip = class("UIEquip", UIBase)

local WarriorDataManager    = GameGlobal:GetCharacterServerDataManager()
local TableDataManager      = GameGlobal:GetDataTableManager()
local ItemDataManager       = GameGlobal:GetItemDataManager() 

local STRENG_TYPE = 1
local EQUIP_NAMES = {"武器", "护腕", "头盔", "胸甲", "鞋子", "披风", "", ""}

local scheduler = cc.Director:getInstance():getScheduler()

-- 构造函数
function UIEquip:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_EquipUI
    self._ResourceName =  "UIEquip.csb"
end

-- Load
function UIEquip:Load()
    UIBase.Load(self)

    --加入武将选择tableView
    local center = seekNodeByName(self._RootPanelNode, "Panel_Center")
    self._Slider = seekNodeByName(center, "Slider_1")
    self._GridView = CreateTableView_(-406, -242, 200, 425, 1, self)
    center:addChild(self._GridView, 0, 0)

    -- 解析ccs为成员变量
    self._CurBodyEquips = {}
    self._CurStarEquips = {}
    for i = 1, 8 do
        local icon = self:GetUIByName("icon_"..i)
        icon:setTag(i)
        icon:addTouchEventListener(handler(self, self.TouchEvent))
        self._CurStarEquips[i] = icon
        self._CurBodyEquips[i] = ccui.Helper:seekWidgetByName(icon, "Image_1")
    end
    self._TagPageButton = {}
    for i = 1, 3 do
        local icon = self:GetUIByName("Button_"..i)
        if i == 3 then
            icon:setTag(10 + i)
            self._TagPageButton[10 + i] = icon
            self._RecastCostText = seekNodeByName(icon, "Text_1")
        else
            icon:setTag(8 + i)
            self._TagPageButton[8 + i] = icon
        end
        icon:addTouchEventListener(handler(self, self.TouchEvent))
    end
    self._TagPageButton[20] = self:GetUIByName("arrow")
    
    self._SEquips = {}
    for i = 0, 2 do
        local icon1 = self:GetUIByName("icon_5_"..i)
        self._SEquips[i + 1] = seekNodeByName(icon1, "Image_1")
        self._SEquips[i + 1]:loadTexture("meishu/ui/gg/null.png", UI_TEX_TYPE_LOCAL)
    end
    self._CostText3 = seekNodeByName(self._SEquips[3]:getParent(), "Text_1")
    self._NextFlag = self:GetUIByName("nextflag")
    self._RecastNoImage = self:GetUIByName("Image_RecastNo")
    local panel = self:GetUIByName("Panel_2")
    self._StrengTextFront = {}
    self._StrengTextBack = {}
    self._StrengText = {}
    self._StrengText1 = {}
    self._TabText = {}
    for i = 1, 4 do
        self._StrengTextFront [i] = seekNodeByName(panel, "Text_"..i.."_1")
        self._StrengTextBack[i] = seekNodeByName(panel, "Text_"..i.."_2")
        self._StrengText[i] = seekNodeByName(panel, "Text_"..i)
        self._StrengText1[i] = seekNodeByName(panel, "Text_"..i..i)
    end
    self._LevelText = seekNodeByName(panel, "Text_1")
    self._StrengTextFront[5] = seekNodeByName(panel, "Text_7")
    self._StrengTextBack[5] = seekNodeByName(panel, "Text_8")
    self._LineImage = self:GetWigetByName("Image_Name")
    self._CostText1 = seekNodeByName(panel, "Text_5")
    self._CostText2 = seekNodeByName(panel, "Text_6")
    self._GoldText = seekNodeByName(self:GetUIByName("UI_Gold"), "Text_1")
    self._MoneyText = seekNodeByName(self:GetUIByName("UI_Money"), "Text_1")
    self._CurSelectEquipIndex = 1
    self._CurWarrriorIndex = 1
    self._CurWarrriorId = -1
    self._EquipInfoPanle = panel
    self._WarriorNum = self:GetWigetByName("Text_WarriorNum")
    local close = self:GetWigetByName("Close")
    close:setTag(-1)
    close:addTouchEventListener(handler(self, self.TouchEvent))
    
    self._TagPageButton[11] = self:GetWigetByName("Button_5")
    self._TagPageButton[11]:setTag(11)
    self._TagPageButton[11]:addTouchEventListener(handler(self, self.TouchEvent))
    
    self._TagPageButton[12] = self:GetWigetByName("Button_6")
    self._TagPageButton[12]:setTag(12)
    self._TagPageButton[12]:addTouchEventListener(handler(self, self.TouchEvent))
    
    for i = 11, 12 do
        self._TabText[i - 10] = seekNodeByName(self._TagPageButton[i], "Text_1")
    end
    
    self._TagPageButton[14] = self:GetWigetByName("Button_7")
    self._TagPageButton[14]:setTag(14)
    self._TagPageButton[14]:addTouchEventListener(handler(self, self.TouchEvent))
end

function UIEquip:createSelectFrame()
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

function UIEquip:createEquipFrame()
    local equipFrame = display.newSprite("meishu/ui/gg/UI_gg_zhuangbeikuang_xuanzhong.png",  -2, -2, 
        {
            scale9 = true, 
            capInsets = cc.rect(40, 40, 20, 20), 
            rect = cc.rect(0, 0, 120, 120)
        })
    equipFrame:setScale(0.7)
    equipFrame:setAnchorPoint(0.5, 0.5)
    equipFrame:ignoreAnchorPointForPosition(false)
    equipFrame:setPosition(37, 32)
    return equipFrame
end

function UIEquip:HideByTab(bool)
    self._CostText1:setVisible(false)
    self._CostText2:setVisible(bool)
    self._TagPageButton[9]:setVisible(bool)
    self._TagPageButton[10]:setVisible(bool)
    self._TagPageButton[13]:setVisible(not bool)
    self._TagPageButton[20]:setVisible(not bool)
    self._SEquips[2]:getParent():setVisible(not bool) 
    self._SEquips[3]:getParent():setVisible(not bool) 
    if bool then    
        self._SEquips[1]:getParent():setPositionX(710)
        self._NextFlag:setVisible(false)
        self._RecastNoImage:setVisible(false)
        self._NextFlag:setTexture("meishu/ui/zhuangbei/UI_zb_qianghuahou.png")
        self._CurTabIndex = 1
    else
        self._StrengTextFront[5]:setPositionX(55)
        self._SEquips[1]:getParent():setPositionX(610)
        self._NextFlag:setTexture("meishu/ui/zhuangbei/UI_zb_chongzhuhou.png")
        self._CurTabIndex = 2
    end
    self:SelectEquipStreng(self._CurSelectEquipIndex)
end

-- 打开
function UIEquip:Open()
    UIBase.Open(self)

    --初始化状态变量
    self._PreviousWarrriorID = -1
    self._StrengFlag = 0
    self._SchedulerID = nil

    -- 加入武将选择框
    self._SelectFrame = self:createSelectFrame()
    self._GridView:addChild(self._SelectFrame)
    self._SelectFrame:retain()
    
    -- 加入装备选择框
    self._EquipFrame = self:createEquipFrame()
    self._EquipFrame:retain()

    -- 初始化玩家金钱
    self:refreshPlayerGold()
    -- 初始化武将列表
    self:refreshWarriorList()

    -- 初始化装备选中
    self:switchEquipSelectFrame(1)

    -- 加入监听网络事件
    self:addEvent(GameEvent.GameEvent_UIEquipStreng_Succeed, self.StrengSucceedListener)
    self:addEvent(GameEvent.GameEvent_UIEquipRecast_Succeed, self.RecastSucceedListener)
end

-- 关闭
function UIEquip:Close()
    UIBase.Close(self)
    removeNodeAndRelease(self._SelectFrame, true)
    removeNodeAndRelease(self._EquipFrame, true)
end

function UIEquip:refreshPlayerGold()
    self._GoldText:setString(GetPlayer()._Gold)
    self._MoneyText:setString(GetPlayer()._Silver)
end

function UIEquip:switchWarriorSelectFrame(node)
    self._SelectFrame:removeFromParent(true)
    node:addChild(self._SelectFrame, 50)
    local actionBy = cc.RotateBy:create(1.5, -360)
    self._SelectFrame:runAction(cc.RepeatForever:create(actionBy)) 
end

function UIEquip:switchEquipSelectFrame(equipIndex)
    self._CurSelectEquipIndex = equipIndex

    self._EquipFrame:removeFromParent(true)
    self._CurStarEquips[self._CurSelectEquipIndex]:addChild(self._EquipFrame, 10)
end

function UIEquip:refreshWarriorList()
    local CharacterServerDataManager = require("main.ServerData.CharacterServerDataManager")
    self._Count = table.nums(CharacterServerDataManager._OwnLeaderList) 
    
    self._WarriorCells =  self._Count
    self._WarriorIndex = {}

    for i,v in pairs(WarriorDataManager._OwnLeaderList) do
        table.insert(self._WarriorIndex, i) 
    end
    self:ReSortWarrior()
    self:ChangeWarrior(1)
    self:HideByTab(true)
    self._GridView:reloadData()
    local cell = self._GridView:cellAtIndex(0)
    if cell ~= nil then
        local panel = cell:getChildByTag(0)
        local button = seekNodeByName(panel, "Button_2")
        if button ~= nil then
            SimulateClickButton(button, handlers(self, self.TableViewItemTouchEvent, 2))
        end
    end
    --武将数设置
    local gamePlayerDataManager = GameGlobal:GetGamePlayerDataManager()
    local myselfData = gamePlayerDataManager:GetMyselfData()
    if myselfData._VIPLevel <= 12 then
        local curWarriorNum = table.nums(CharacterServerDataManager._OwnLeaderList)
        local maxWarriorNum = GameGlobal:GetVipDataManager()[myselfData._VIPLevel].heromax
        self._WarriorNum:setString(curWarriorNum.."/"..maxWarriorNum)
    end
end

function UIEquip:ReSortWarrior()
    table.sort(self._WarriorIndex, function(a, b)
        local warrior1 = WarriorDataManager:GetLeader(a)
        local warrior2 = WarriorDataManager:GetLeader(b)
        if warrior1._CurrentState == warrior2._CurrentState then
            if warrior1._CharacterData.quality == warrior2._CharacterData.quality then
                if warrior1._Level == warrior2._Level then
                    if a == b then
                        return false
                    else
                        return a > b
                    end
                else
                    return warrior1._Level > warrior2._Level
                end
            else
                if warrior1._CharacterData.quality == 0 then
                    if warrior2._CharacterData.quality == 1 or warrior2._CharacterData.quality == 2 then
                        return true
                    else
                        return false
                    end 
                end
                if warrior2._CharacterData.quality == 0 then
                    if warrior1._CharacterData.quality == 1 or warrior1._CharacterData.quality == 2 then
                        return false
                    else
                        return true
                    end 
                end
                return warrior1._CharacterData.quality > warrior2._CharacterData.quality
            end
        else
            return warrior1._CurrentState > warrior2._CurrentState
        end
    end)
end

function UIEquip:ScrollViewDidScroll(view)
    local point = view:getContentOffset()
    local len = view:getContentSize().height - view:getViewSize().height
    local percent = - (point.y / len)

--    屏蔽掉滑动条
--    if self._Slider ~= nil then
--        if view:isDragging() then
--            self._Slider:setVisible(true)
--            self._Slider:getParent():setVisible(true)
--        else
--            self._Slider:getParent():setVisible(false)
--            self._Slider:setVisible(false)
--        end
--        self._Slider:setPercent((1 - percent) * 100)
--    end
end

function UIEquip:NumberOfCellsInTableView()
    return self._WarriorCells
end

function UIEquip:TableCellTouched(view, cell)
    local index = cell:getIdx()
    self._CurWarrriorIndex = cell:getIdx() + 1
    self:ChangeWarrior(self._CurWarrriorIndex)
    
    local tag = cell:getIdx()
    self._CellType = tag

    local layout = cell:getChildByTag(tonumber(self._CurWarrriorIndex - 1))
    local panel = ccui.Helper:seekWidgetByName(layout, "Panel_1")
    self._CurWarrriorId = self._WarriorIndex[tonumber(self._CurWarrriorIndex)]
    --cell缩放动画
    local actionTo = cc.ScaleTo:create(0.1, 0.9)
    local actionTo2 = cc.ScaleTo:create(0.1, 1.0)
    panel:runAction(cc.Sequence:create(actionTo, actionTo2)) 

    if self._PreviousWarrriorID ~= self._CurWarrriorID then
        self:switchWarriorSelectFrame(panel)
    end

    --切换武将后，默认选中第一件装备
    self:switchEquipSelectFrame(1)
   
    self:SelectEquipStreng(self._CurSelectEquipIndex)
end

function UIEquip:CellSizeForTable(view, idx)
    return 120, 85
end

function UIEquip:TableViewItemTouchEvent(value)
    local eventType = value
    if type(value) == "table" then
        eventType = value.eventType
    end
    if eventType == ccui.TouchEventType.ended then
    end
end

function UIEquip:TableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
    end
    cell:removeAllChildren(true)
    local layout = cc.CSLoader:createNode("csb/ui/WarriorItem.csb")
    tolua.cast(layout, "ccui.Layout")
    -- setSwallowTouches false
    local panel = ccui.Helper:seekWidgetByName(layout, "Panel_1")
    panel:setSwallowTouches(false)
    local button = ccui.Helper:seekWidgetByName(panel, "Button_2")
    button:addTouchEventListener(handler(self, self.TableViewItemTouchEvent))
    button:setSwallowTouches(false)
    button:setTag(idx)
    ccui.Helper:seekWidgetByName(panel, "Image_2"):setSwallowTouches(false)
    layout:setPosition(cc.p(0, 0))
    cell:addChild(layout, 0, idx)
    
    self:InitCell(cell, idx)
    return cell
end

function UIEquip:InitCell(cell, idx)
    local layout = cell:getChildByTag(tonumber(idx))
    local panel = ccui.Helper:seekWidgetByName(layout, "Panel_1")
    local head1 = ccui.Helper:seekWidgetByName(panel, "Image_2")
    local name1 = ccui.Helper:seekWidgetByName(panel, "Text_1")
    local level = seekNodeByName(panel, "Text_2")
    local battleImage = seekNodeByName(panel, "Image_Battle")
    local TypeImage = seekNodeByName(panel, "Image_Type")
    local trainImage = seekNodeByName(panel, "Image_TrainIcon")
    local headDiColorImage = seekNodeByName(panel, "Image_35")

    local warriorId = -1
    if idx + 1 <= self._Count then
        warriorId = self._WarriorIndex[idx + 1]
        local warrior = WarriorDataManager:GetLeader(self._WarriorIndex[idx + 1])
        local head1Name = warrior._CharacterData["headName"]
        head1:setVisible(true)
        head1:loadTexture(GetWarriorHeadPath(head1Name), UI_TEX_TYPE_LOCAL)
        level:setString("lv"..warrior._Level)
        name1:setString(warrior._CharacterData["name"])
        battleImage:setVisible(false)
        if warrior._CurrentState == 1 then
            battleImage:setVisible(true)
        end
        trainImage:setVisible(false)
        if warrior._Time ~= 0 then
            trainImage:setVisible(true)
        end
        TypeImage:loadTexture(GetSoldierProperty(warrior._CharacterData["soldierType"]))
        headDiColorImage:loadTexture(GetHeadColorImage(warrior._CharacterData["quality"]))
    end

    if warriorId ~= -1 then
        if self._PreviousWarrriorID == -1 then
            self._PreviousWarrriorID = warriorId
        end
        if self._PreviousWarrriorID == warriorId then
            self:switchWarriorSelectFrame(panel)
        end
    end
end

function UIEquip:ChangeWarrior(index)
    if self._Count > 0 then
       local warrior = WarriorDataManager:GetLeader(self._WarriorIndex[index])
       self._CurWarrior = warrior
       for i = 1, 8 do  
            self._CurBodyEquips[i]:loadTexture("meishu/ui/gg/null.png", UI_TEX_TYPE_LOCAL)
            
            if warrior._Equip[i] ~= 0 then
                local equip = ItemDataManager:GetItem(warrior._Equip[i])
                self._CurStarEquips[i]:setTitleText("")
                self._CurBodyEquips[i]:loadTexture(GetPropPath(equip._PropData["icon"]), UI_TEX_TYPE_LOCAL)
            else
                self._CurStarEquips[i]:setTitleText(EQUIP_NAMES[i])
            end
            self._CurStarEquips[i]:setContentSize(cc.size(69, 69))
       end
        self:SelectEquipStreng(self._CurSelectEquipIndex)
    end
end

function UIEquip:SelectEquipStreng(tag)
    if self._CurWarrior == nil then
        return
    end
    if self._CurWarrior._Equip[tag] == 0 then
        self._CurEquipGuid = nil
        for i = 1, 3 do
            self._SEquips[i]:loadTexture("meishu/ui/gg/null.png", UI_TEX_TYPE_LOCAL)
        end
        self._NextFlag:setVisible(false)
        self._EquipInfoPanle:setVisible(false)
        self._RecastNoImage:setVisible(false)
        self._CostText3:setString("")
        self._TagPageButton[13]:setBrightStyle(2)
        self._RecastCostText:setString("0")
        return
    end

    local equip = ItemDataManager:GetItem(self._CurWarrior._Equip[tag])
    
    if equip._PropData["quality"] < 4 and self._CurTabIndex == 2 then
        self._CurEquipGuid = nil
        for i = 1, 3 do
            self._SEquips[i]:loadTexture("meishu/ui/gg/null.png", UI_TEX_TYPE_LOCAL)
        end
        self._NextFlag:setVisible(false)
        self._RecastNoImage:setVisible(false)
        self._EquipInfoPanle:setVisible(false)
        self._CostText3:setString("")
        self._TagPageButton[13]:setBrightStyle(2)
        self._RecastCostText:setString("0")
        return
    end
    self._TagPageButton[13]:setBrightStyle(0)
    self._EquipInfoPanle:setVisible(true)
    self._CurSelectEquipIndex = tag
    self._CurEquipGuid = self._CurWarrior._Equip[tag]
    self._CurEquipTableID = equip._ItemTableID
    local level = equip._ItemEquipLevel
    self._CurEquipLevel = level
    self._SEquips[1]:loadTexture(GetPropPath(equip._PropData["icon"]), UI_TEX_TYPE_LOCAL)
    self._StrengTextFront[5]:setString(equip._PropData["name"])
    self._StrengTextFront[1]:setString(equip._ItemEquipLevel)
    for i = 2, 3 do
        self._StrengTextFront[i]:setString(0)
        self._StrengTextBack[i]:setString(0) 
    end
    
    if self._CurTabIndex == 1 then
        self._SEquips[2]:loadTexture(GetPropPath(equip._PropData["icon"]), UI_TEX_TYPE_LOCAL)

        --对等级特殊对待（位置改变）
        self._LevelText:setPositionX(87)
        self._StrengTextFront[1]:setPositionX(115)
        self._StrengTextBack[1]:setVisible(true)
        --用于记录空的属性下标
        local propertyList = {[2] = 0, [3] = 0, [4] = 0}
        local equipLevel = GameGlobal:GetEquipDataManager()[equip._ItemTableID][equip._ItemEquipLevel]
        if equipLevel ~= nil then
            self._StrengTextFront[2]:setString(equipLevel.hp)
            self._StrengTextFront[3]:setString(equipLevel.ap)
            self._StrengTextFront[4]:setString(equipLevel.as)
            --记录值为0的属性
            if tonumber(equipLevel.hp) ~= 0 then
                propertyList[2] = 1
            end
            if tonumber(equipLevel.ap) ~= 0 then
                propertyList[3] = 1
            end
            if tonumber(equipLevel.as) ~= 0 then
                propertyList[4] = 1
            end
        end
        --将值为0的属性信息隐藏
        for i = 2, 4 do
            if tonumber(propertyList[i]) == 0 then
                self._StrengTextFront[i]:setVisible(false)
                self._StrengTextBack[i]:setVisible(false)
                self._StrengText[i]:setVisible(false)
            else
                self._StrengTextFront[i]:setVisible(true)
                self._StrengTextBack[i]:setVisible(true)
                self._StrengText[i]:setVisible(true)
            end
        end
        --所有显示的属性信息的X坐标设置
        local proEquipXList = {[2] = 85, [3] = 52, [4] = 19}
        local curIndex = 2
        for i = 2, 4 do
            if tonumber(propertyList[i]) ~= 0 then
                self._StrengTextFront[i]:setPositionY(proEquipXList[curIndex])
                self._StrengTextBack[i]:setPositionY(proEquipXList[curIndex])
                self._StrengText[i]:setPositionY(proEquipXList[curIndex])
                curIndex = curIndex + 1
            end
        end
        --找出最宽数值-用于右侧绿色数值对齐
        local width = 0
        local maxWidthId = 0
        for i = 1, 4 do
            local curWidth = self._StrengTextFront[i]:getContentSize().width
            if curWidth > width then
                width = curWidth
                maxWidthId = i
            end
        end
        --获取X坐标
        local backPositionX = self._StrengTextFront[maxWidthId]:getPositionX() + self._StrengTextFront[maxWidthId]:getContentSize().width + 20
        --强化数值
        local tableID = GameGlobal:GetEquipDataManager()[equip._ItemTableID]
        if tableID[equip._ItemEquipLevel + 1] ~= nil then
            self._StrengTextBack[1]:setString("+1")
            self._StrengTextBack[2]:setString("+"..(tableID[equip._ItemEquipLevel + 1].hp - tableID[equip._ItemEquipLevel].hp))
            self._StrengTextBack[3]:setString("+"..(tableID[equip._ItemEquipLevel + 1].ap - tableID[equip._ItemEquipLevel].ap))
            self._StrengTextBack[4]:setString("+"..(tableID[equip._ItemEquipLevel + 1].as - tableID[equip._ItemEquipLevel].as))
        end
        --位置设置
        for i = 1, 4 do
            self._StrengTextBack[i]:setPositionX(backPositionX)
        end
    
        if equip ~= nil then
            self._StrengTextBack[5]:setString(equip._PropData["name"])
        end
        local PropDataManager = GetPropDataManager()
        local equipLevel = GameGlobal:GetEquipCostDataManager()[equip._PropData["subtype"]][equip._ItemEquipLevel]
        if equipLevel ~= nil then
            local cost = equipLevel.cost
            self._CostText1:setString(cost)
            self._CostText2:setString(cost)
            
            self._ConstSliver1 = equipLevel.cost
            self._ConstSliver2 = cost
        end
    else
        local path = "meishu/ui/gg/"..(equip._PropData["quality"])..".png"
        self._CurStarEquips[tag]:setContentSize(cc.size(69, 69))
        self._CurBodyEquips[tag]:loadTexture(GetPropPath(equip._PropData["icon"]), UI_TEX_TYPE_LOCAL)
        self._SEquips[3]:loadTexture(GetPropPath(equip._PropData["icon"]), UI_TEX_TYPE_LOCAL)
        local PropDataManager = GetPropDataManager()
        local nextTableID = equip._ItemTableID + 1
        local nextQuality = equip._PropData["quality"] + 1
        if equip._PropData["quality"] >= 5 then
            nextTableID = equip._ItemTableID
            nextQuality = equip._PropData["quality"]
        end
        self._SEquips[2]:loadTexture(GetPropPath(PropDataManager[nextTableID]["icon"]), UI_TEX_TYPE_LOCAL)

        --对等级特殊对待（位置改变）
        self._LevelText:setPositionX(115)
        self._StrengTextFront[1]:setPositionX(143)
        self._StrengTextBack[1]:setVisible(false)
        --用于记录空的属性下标
        local propertyList = {[2] = 0, [3] = 0, [4] = 0}
        --前值设置
        local equipLevel = GameGlobal:GetEquipDataManager()[equip._ItemTableID][equip._ItemEquipLevel]
        if equipLevel ~= nil then
            self._StrengTextFront[2]:setString(equipLevel.hp)
            self._StrengTextFront[3]:setString(equipLevel.ap)
            self._StrengTextFront[4]:setString(equipLevel.as)
            --记录值为0的属性
            if tonumber(equipLevel.hp) ~= 0 then
                propertyList[2] = 1
            end
            if tonumber(equipLevel.ap) ~= 0 then
                propertyList[3] = 1
            end
            if tonumber(equipLevel.as) ~= 0 then
                propertyList[4] = 1
            end
        end
        --将值为0的属性信息隐藏
        for i = 2, 4 do
            if tonumber(propertyList[i]) == 0 then
                self._StrengTextFront[i]:setVisible(false)
                self._StrengTextBack[i]:setVisible(false)
                self._StrengText[i]:setVisible(false)
            else
                self._StrengTextFront[i]:setVisible(true)
                self._StrengTextBack[i]:setVisible(true)
                self._StrengText[i]:setVisible(true)
            end
        end
        --所有显示的属性信息的X坐标设置
        local proEquipXList = {[2] = 85, [3] = 52, [4] = 19}
        local curIndex = 2
        for i = 2, 4 do
            if tonumber(propertyList[i]) ~= 0 then
                self._StrengTextFront[i]:setPositionY(proEquipXList[curIndex])
                self._StrengTextBack[i]:setPositionY(proEquipXList[curIndex])
                self._StrengText[i]:setPositionY(proEquipXList[curIndex])
                curIndex = curIndex + 1
            end
        end
        --找出最宽数值-用于右侧绿色数值对齐
        local width = 0
        local maxWidthId = 0
        for i = 2, 4 do
            local curWidth = self._StrengTextFront[i]:getContentSize().width
            if curWidth > width then
                width = curWidth
                maxWidthId = i
            end
        end
        --获取X坐标
        local backPositionX = self._StrengTextFront[maxWidthId]:getPositionX() + self._StrengTextFront[maxWidthId]:getContentSize().width + 20
        --强化数值
        local recastDataList = TableDataManager:GetRecastDataManager()
        if recastDataList[equip._ItemTableID] ~= nil then
            local recastEquipID = recastDataList[equip._ItemTableID]["recasttarget"]
            local backEquip = GameGlobal:GetEquipDataManager()[recastEquipID][equip._ItemEquipLevel]
            local tableID = GameGlobal:GetEquipDataManager()[equip._ItemTableID]
            if backEquip ~= nil then
                self._StrengTextBack[2]:setString("+"..(backEquip.hp - tableID[equip._ItemEquipLevel].hp))
                self._StrengTextBack[3]:setString("+"..(backEquip.ap - tableID[equip._ItemEquipLevel].ap))
                self._StrengTextBack[4]:setString("+"..(backEquip.as - tableID[equip._ItemEquipLevel].as))
            end
        else
            --武器不能重铸
            self._StrengTextBack[2]:setString("+0")
            self._StrengTextBack[3]:setString("+0")
            self._StrengTextBack[4]:setString("+0")
            self._RecastNoImage:setVisible(true)
        end
        --位置设置
        for i = 2, 4 do
            self._StrengTextBack[i]:setPositionX(backPositionX)
        end

        if PropDataManager[nextTableID] ~= nil then
            self._StrengTextBack[5]:setString(PropDataManager[nextTableID]["name"])
        end
        
        --重铸消耗
        if recastDataList[equip._ItemTableID] ~= nil then
            self._RecastCostText:setString(recastDataList[equip._ItemTableID]["moneycost"])
        else
            self._RecastCostText:setString("0")
        end
        
        local PropDataManager = GetPropDataManager()
        if equip._PropData["quality"] == 4 then
            self._CostText3:setString((ItemDataManager:GetEquipCount(equip._ItemTableID)).."/5")
        else
            self._CostText3:setString((ItemDataManager:GetEquipCount(equip._ItemTableID)).."/1")
        end
    end
end

function UIEquip:TouchEvent(sender, eventType)
     if eventType == ccui.TouchEventType.began then
        if sender:getTag() == 10 then
            if self._CurEquipGuid ~= nil and self._SchedulerID == nil then
                self._StrengFlag = 1
                local function schedulerUpdate(time)
                    self:sendStrengMessage()
                end 
                self._SchedulerID = scheduler:scheduleScriptFunc(schedulerUpdate, 0.25, false)
            end
        end
    elseif eventType == ccui.TouchEventType.canceled then
        self._StrengFlag = 0
    elseif eventType == ccui.TouchEventType.ended then
        self._StrengFlag = 0
        local tag = sender:getTag()
        if tag == -1 then
            UISystem:CloseUI(UIType.UIType_EquipUI)
            UISystem:CloseUI(UIType.UIType_UISmelt) 
        elseif tag >= 1 and tag <= 8 then
            self._EquipFrame:removeFromParent()
            sender:addChild(self._EquipFrame, 1)
            self:SelectEquipStreng(tag)
        elseif tag == 10 then
            if GetPlayer()._Silver >= self._ConstSliver2 then
                if GetPlayer()._Level > self._CurEquipLevel then
                    PlaySound(Sound_26)
                    SendMsg(PacketDefine.PacketDefine_WarriorStreng_Send, {self._CurEquipGuid, 1}) 
                else
                    local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                    UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_zb_03))
                end
            else    
                local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_zb_02))
            end
        elseif tag == 11 then
            self:ChangeTag(1)
        elseif tag == 12 then
            self:ChangeTag(2)
        elseif tag == 13 then
            if self._CurEquipGuid ~= nil then
                if math.floor(self._CurEquipTableID / 100) == 16 then
                    return
                end
                if ItemDataManager:GetEquipCount(self._CurEquipTableID)>= 5 then
                    if GetPlayer()._Silver < 500000 then
                        local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                        UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_zb_05))
                    else
                        local tip =  UISystem:OpenUI(UIType.UIType_TipUI)
                        tip:RegisteDelegate(handler(self, self.sendRecastMessage), 1, GameGlobal:GetTipDataManager(UI_zb_06))
                    end
                else
                    local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                    UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_zb_07))
                end
           end
        elseif tag == 14 then
            UISystem:CloseUI(UIType.UIType_EquipUI)
            UISystem:OpenUI(UIType.UIType_UISmelt)
        end
    end
end

function UIEquip:ChangeTag(num)
    if num == 1 then
        self:HideByTab(true)
    else
        self:HideByTab(false)
    end
    for i = 11, 12 do
        if (num + 10) == i then
            self._TagPageButton[i]:setLocalZOrder(3)
            self._TagPageButton[i]:loadTextures("meishu/ui/gg/UI_gg_yeqian_01.png", UI_TEX_TYPE_LOCAL)
            self._TagPageButton[i]:setPositionX(414)
            self._TabText[i - 10]:setPositionX(27)
            self._TagPageButton[i]:setTouchEnabled(false)
        else
            self._TagPageButton[i]:setLocalZOrder(-1)
            self._TagPageButton[i]:loadTextures("meishu/ui/gg/UI_gg_yeqian_02.png", UI_TEX_TYPE_LOCAL)
            self._TagPageButton[i]:setPositionX(420)
            self._TabText[i - 10]:setPositionX(17)
            self._TagPageButton[i]:setTouchEnabled(true)
        end
    end
end

function UIEquip:sendStrengMessage()
    print(self._StrengFlag)
    if self._StrengFlag == 1 then
        if GetPlayer()._Silver >= self._ConstSliver2 then
            if GetPlayer()._Level > self._CurEquipLevel then
                PlaySound(Sound_26)
                SendMsg(PacketDefine.PacketDefine_WarriorStreng_Send, {self._CurEquipGuid, 1}) 
            else
                local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_zb_03))
            end
        else    
            local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
            UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_zb_02))
        end
    else
        if self._SchedulerID ~= nil then
            scheduler:unscheduleScriptEntry(self._SchedulerID)
            self._SchedulerID = nil
        end
    end
end

function UIEquip:sendRecastMessage()
    PlaySound(Sound_28)
    SendMsg(PacketDefine.PacketDefine_WarriorRecast_Send, {self._CurEquipGuid, ItemDataManager:GetEquipListByLevel(self._CurEquipGuid, self._CurEquipTableID)}) 
end

function UIEquip:RecastSucceedListener()
    CreateTipAction(self._RootUINode, "重铸成功", cc.p(720, 200))
end

function UIEquip:StrengSucceedListener()
    if self._CurTabIndex == 1 then
        self:SelectEquipStreng(self._CurSelectEquipIndex)
        self:refreshPlayerGold()
        PlaySound(Sound_22)
        if STRENG_TYPE == 10 then
            for i = 0, 9 do
                local action = transition.create({}, {delay = 0.2 * i, onComplete = function()
                    CreateTipAction(self._RootUINode, "强化成功", cc.p(720, 200))
                end })
                self._RootUINode:runAction(action)
            end
        else 
            CreateTipAction(self._RootUINode, "强化成功", cc.p(720, 200))
        end
    end
    if self._CurTabIndex == 2 then
        self:SelectEquipStreng(self._CurSelectEquipIndex)
        self:refreshPlayerGold()
    end
end

return UIEquip
