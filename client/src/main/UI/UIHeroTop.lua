----
-- 文件名称：UIHeroTop.lua
-- 功能描述：UIHeroTop
-- 文件说明：UIHeroTop
-- 作    者：田凯
-- 创建时间：2015-6-26
--  修改
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
require("cocos.ui.DeprecatedUIEnum")
require("cocos.extension.ExtensionConstants")
local ItemDataManager = GetPropDataManager()
local UISystem = GameGlobal:GetUISystem()
local CharacterServerDataManager = GameGlobal:GetCharacterDataManager()
local _Instance = nil 

local UIHeroTop = class("UIHeroTop", UIBase)

function UIHeroTop:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_HeroTop
    self._ResourceName = "UIHeroTop.csb"  
end

function UIHeroTop:Load()
    UIBase.Load(self)
    _Instance = self
    self._CurTabIndex = 1
    self._TabButton = {}
    self._HeroList = {}
    -- tableView 
    self._GridView = CreateTableView(-145, -200, 560, 350, 1, self)
    self._GridView:setTag(1)
    self._GridView2 = CreateTableView(-370, -235, 200, 380, 1, self)
    self._GridView2:setTag(2)
    
    self:GetUIByName("Panel_Center"):addChild(self._GridView)
    self:GetUIByName("Panel_Center"):addChild(self._GridView2)
    self:GetUIByName("Node_2"):setVisible(false)
    self:GetUIByName("Node_1"):setVisible(true)
    self._TopValue = self:GetUIByName("Top_value")
    for i = 1, 4 do
        self._TabButton[2 + i] = self:GetUIByName("Button_"..i)
        self._TabButton[2 + i]:setTag(2 + i)
        self._TabButton[2 + i]:addTouchEventListener(_Instance.TouchEvent)
        self._TabButton[2 + i]:setBrightStyle(1)
        if i == 1 then
            self._TabButton[2 + i]:setBrightStyle(0)
        end
    end
    self._TabButton[5]:setBrightStyle(0)
    self._TabButton[6]:setLocalZOrder(-1)
    self._TabButton[6]:setBrightStyle(1)
    self._TabButton[6]:setPositionX(434)
    seekNodeByName(self._TabButton[6], "Text_1"):setPositionX(27)
    self._TabButton[6]:setTouchEnabled(true)
    
    self._SelectFrame1 = display.newSprite("meishu/ui/yingxiongbang/UI_yxb_sanjiao_01.png", 0, 8000)
    self._SelectFrame = display.newSprite("meishu/ui/gg/UI_gg_xuanzhongguangquan.png", 0, 800)
    self._SelectFrame:setScale(0.55)
    self._GridView:addChild(self._SelectFrame1, 1000)
    self._GridView2:addChild(self._SelectFrame, 10)
    self._SelectFrame:retain()
    self._SelectFrame1:retain()
    self._CurPageIndex = 1
    self._CurWarriorTabIndex = 3
    local close = self:GetUIByName("Close")
    close:setTag(-1)
    close:addTouchEventListener(self.TouchEvent)
     
    local name ={GameGlobal:GetTipDataManager(UI_BUTTON_NAME_81), GameGlobal:GetTipDataManager(UI_BUTTON_NAME_82)}
    --CreateBaseUIAction(self._RootPanelNode, -80, 220, -1, GameGlobal:GetTipDataManager(UI_BUTTON_NAME_83), name, 2, self.TouchEvent, self.EndCallBack)
    _Instance._SelectRow = 0
end

function UIHeroTop.EndCallBack(value)
    _Instance._TabButton[1] = value[1]
    _Instance._TabButton[2] = value[2]
    _Instance._TabButton[1]:setTag(1)
    _Instance._TabButton[2]:setTag(2)
    _Instance._TabButton[1]:addTouchEventListener(_Instance.TouchEvent)
    _Instance._TabButton[2]:addTouchEventListener(_Instance.TouchEvent)
end

function UIHeroTop.ScrollViewDidScroll()

end

function UIHeroTop.NumberOfCellsInTableView(view)
    if view:getTag() == 1 then
        return #_Instance._HeroList
    else
        if _Instance._CurWarriorTabIndex == 4 then
            return #_Instance._SoliderIndex
        else
            return _Instance._WarriorCount
        end
    end
end

function UIHeroTop.TableCellTouched(view, cell)
    local index = cell:getIdx()
    if view:getTag() == 1 then
       
        SendMsg(PacketDefine.PacketDefine_PlayerSoldierInfo_Send, {_Instance._HeroList[index + 1][1]})
        _Instance._SelectFrame1:removeFromParent(false)
        _Instance._SelectFrame1:setAnchorPoint(0.5, 0.5)
        _Instance._SelectFrame1:ignoreAnchorPointForPosition(false)
        cell:addChild(_Instance._SelectFrame1)
        _Instance._SelectFrame1:setPosition(10, 25)
        _Instance._SelectRow = index
    else
        local UITip = require("main.UI.UITip") 
        local warrior
        if _Instance._CurWarriorTabIndex == 3 then
            warrior = CharacterServerDataManager[_Instance._WarriorIndex[index + _Instance._CellType][1]]
            UITip:OpenWarriorTips(350, 50, warrior, nil, _Instance._WarriorIndex[index  + _Instance._CellType][2])
        else
            warrior = CharacterServerDataManager[_Instance._SoliderIndex[index + _Instance._CellType][1]]
            UITip:OpenWarriorTips(350, 50, warrior, nil, _Instance._SoliderIndex[index + _Instance._CellType][2])
        end
    end
end

function UIHeroTop.CellSizeForTable(view, idx)
    if view:getTag() == 1 then
        return 520, 50
    else
        return 196, 85
    end
end

function UIHeroTop:TableViewItemTouchEvent(value)
    local eventType = value
    if type(value) == "table" then
        eventType = value.eventType
    end
    if eventType == ccui.TouchEventType.ended then
        local tag = self:getTag()
        _Instance._CellType = tag
        _Instance._CurWarrriorIndex = 0
        --CreateAnimation(self, self:getPositionX() - 55 , self:getPositionY(), "csb/texiao/ui/T_u_WJxinxi1.csb", "animation0", false, 0, 1)
        
        _Instance._SelectFrame:removeFromParent(false)
        _Instance._SelectFrame:setAnchorPoint(0.5, 0.5)
        _Instance._SelectFrame:ignoreAnchorPointForPosition(false)
        self:getParent():addChild(_Instance._SelectFrame)
        _Instance:SelectAnimation()
        _Instance._SelectFrame:setPosition(40, 40)
        _Instance._CurButton = self
    end
end

function UIHeroTop:SelectAnimation()
    local actionBy = cc.RotateBy:create(1.5, -360)
    if _Instance._SelectFrame ~= nil then
        _Instance._SelectFrame:runAction(cc.RepeatForever:create(actionBy)) 
    end 
end

function UIHeroTop.TableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
        cell:retain()  
    end
    cell:removeAllChildren(true)
    if view:getTag() == 1 then
        local layout = cc.CSLoader:createNode("csb/ui/HeroItem".._Instance._CurTabIndex..".csb")
        cell:addChild(layout, 0, idx)
        if idx % 2 == 0 then
            seekNodeByName(layout, "Image_1"):loadTexture("meishu/ui/gg/UI_wjxx_kuang_02.png")
        else
            seekNodeByName(layout, "Image_1"):loadTexture("meishu/ui/gg/UI_gg_fengedi_01.png")
        end
        layout:setPositionX(20)
        _Instance:InitCell(cell, idx)
    else
        local layout = cc.CSLoader:createNode("csb/ui/WarriorItem.csb")
        local panel = seekNodeByName(layout, "Panel_1")
        panel:setSwallowTouches(false)
        local button = seekNodeByName(panel, "Button_2")
        button:addTouchEventListener(_Instance.TableViewItemTouchEvent)
        button:setSwallowTouches(false)
        seekNodeByName(panel, "Image_1"):setVisible(false)
        seekNodeByName(panel, "Image_2"):setSwallowTouches(false)
        
        cell:addChild(layout, 0, idx)
        _Instance:InitCell1(cell, idx)
    end
    return cell
end

function UIHeroTop:InitCell1(cell, idx)
    local layout = cell:getChildByTag(idx)
    local panel = seekNodeByName(layout, "Panel_1")
    local head1 = seekNodeByName(panel, "Image_2")
    local name1 = seekNodeByName(panel, "Text_1")
    local level = seekNodeByName(panel, "Text_2")
    local flag1 = seekNodeByName(panel, "Flag")
    local battleImage = seekNodeByName(panel, "Image_Battle")
    local TypeImage = seekNodeByName(panel, "Image_Type")
    local trainImage = seekNodeByName(panel, "Image_TrainIcon")
    local headDiColorImage = seekNodeByName(panel, "Image_35")
    battleImage:setVisible(false)
    trainImage:setVisible(false)
    flag1:setLocalZOrder(100)
    
    local count 
    local list
    if _Instance._CurWarriorTabIndex == 4 then
        count = #_Instance._SoliderIndex
        list = _Instance._SoliderIndex
    else
        count =  _Instance._WarriorCount
        list = _Instance._WarriorIndex
    end
    
    if idx + 1 <= count then
        local warrior = CharacterServerDataManager[list[idx + 1][1]]
        TypeImage:loadTexture(GetSoldierProperty(warrior["soldierType"]))
        headDiColorImage:loadTexture(GetHeadColorImage(warrior["quality"]))
        local head1Name = warrior["headName"]
        if _Instance._CurWarriorTabIndex == 3 then
            flag1:setVisible(true)
            head1:loadTexture(GetWarriorHeadPath(head1Name), UI_TEX_TYPE_LOCAL)
        else    
            flag1:setVisible(false)
            head1:loadTexture(GetSoldierHeadPath(head1Name), UI_TEX_TYPE_LOCAL)
        end
        head1:setVisible(true)
        level:setString("LV"..list[idx + 1][2])
        name1:setString(warrior["name"])
        name1:setColor(GetQualityColor(warrior["quality"]))
        flag1:setVisible(false)
    end
end

function UIHeroTop:InitCell(cell, idx)
    if idx == _Instance._SelectRow then
        _Instance._SelectFrame1:removeFromParent(false)
        _Instance._SelectFrame1:setAnchorPoint(0.5, 0.5)
        _Instance._SelectFrame1:ignoreAnchorPointForPosition(false)
        cell:addChild(_Instance._SelectFrame1)
        _Instance._SelectFrame1:setPosition(10, 25)
    end
    
    local layout = cell:getChildByTag(idx)
    local panel = seekNodeByName(layout, "Image_1")
    panel:setSwallowTouches(false) 
    panel:setVisible(false)
    ccui.Helper:seekWidgetByName(panel, "icon"):setVisible(false)
    if idx < #_Instance._HeroList then 
        panel:setVisible(true)
        if idx < 3 then
            ccui.Helper:seekWidgetByName(panel, "icon"):setVisible(true)
            ccui.Helper:seekWidgetByName(panel, "Text_1"):setVisible(false)
            if idx == 0 then
                ccui.Helper:seekWidgetByName(panel, "icon"):loadTexture("meishu/ui/yingxiongbang/UI_yxb_jin.png")
            elseif idx == 1 then
                ccui.Helper:seekWidgetByName(panel, "icon"):loadTexture("meishu/ui/yingxiongbang/UI_yxb_yin.png")
            else
                ccui.Helper:seekWidgetByName(panel, "icon"):loadTexture("meishu/ui/yingxiongbang/UI_yxb_tong.png")
            end
        end
        
        for i = 1 , (_Instance._CurTabIndex == 1 and 5 or 3) do
            local text = ccui.Helper:seekWidgetByName(panel, "Text_"..i)
            
            if _Instance._CurTabIndex == 2 then
                if i == 1 then
                    text:setString(idx + 1)
                elseif i == 2 then
                    text:setString(_Instance._HeroList[idx + 1][4])
                elseif i == 3 then
                    local city = ccui.Helper:seekWidgetByName(panel, "city")
                    city:loadTexture(GetGuoZhanBelongImage(_Instance._HeroList[idx + 1][7]))
                    --text:setTextColor(GetJudianColor(_Instance._HeroList[idx + 1][7]))
                    text:setString(_Instance._HeroList[idx + 1][3])
                end
            else
                if _Instance._HeroList[idx + 1] == nil then
                    return
                end
                
                if _Instance._HeroList[idx + 1][6] == nil then
                    return
                end
                if i == 1 then
                    text:setString(idx + 1)
                elseif i == 2 then
                    text:setString(_Instance._HeroList[idx + 1][6][3])
                elseif i == 3 then
                    text:setString(_Instance._HeroList[idx + 1][6][2])
                elseif i == 4 then
                    text:setString(_Instance._HeroList[idx + 1][6][1])
                elseif i == 5 then
                    local city = ccui.Helper:seekWidgetByName(panel, "city")
                    city:loadTexture(GetGuoZhanBelongImage(_Instance._HeroList[idx + 1][7]))
                    --text:setTextColor(GetJudianColor(_Instance._HeroList[idx + 1][7]))
                    text:setString(_Instance._HeroList[idx + 1][3])
                end
            end
       end
    end
end

function UIHeroTop:Unload()
    UIBase:Unload()
    self._ResourceName = nil
    self._Type = nil
end

function UIHeroTop:Open()
    UIBase.Open(self)
    self.OpenCallBack = AddEvent(GameEvent.GameEvent_UIHeroTop_Open, self.OpenUISucceed)
    self.GetCallBack = AddEvent(GameEvent.GameEvent_UIHeroGet_Succeed, self.GetWarriorSucceed)
    PlaySound(Sound_30)
end
   
function UIHeroTop:Close()
    UIBase.Close(self)
    RemoveEvent(self.OpenCallBack)
    RemoveEvent(self.GetCallBack)
end

function UIHeroTop:GetWarriorSucceed()
    _Instance._SoliderIndex = {}
    _Instance._WarriorIndex = {}
    _Instance._WarriorIndex[0] = self._usedata[0]
    for i = 1, #self._usedata do
        if tonumber(self._usedata[i][1]) < 10000 then
            table.insert(_Instance._WarriorIndex, self._usedata[i]) 
         else
            table.insert(_Instance._SoliderIndex, self._usedata[i])
         end
    end
    _Instance._WarriorCount = #_Instance._WarriorIndex
    _Instance:ReSortWarrior(_Instance._WarriorIndex)
    _Instance:ReSortWarrior(_Instance._SoliderIndex)
    _Instance._GridView2:reloadData()
    _Instance:SimulateClickButton(0, 2)
end

function UIHeroTop:ReSortWarrior(value)
    table.sort(value, function(a, b)
        local warrior1 = CharacterServerDataManager[a[1]]
        local warrior2 = CharacterServerDataManager[b[1]]
        if warrior1.quality == warrior2.quality then
            if a[2] == b[2] then
                return false
            else
                return a[2] > b[2]
            end
        else
            return warrior1.quality > warrior2.quality
        end
    end)
end

function UIHeroTop:OpenUISucceed(data)
    for i = 1, #self._usedata do
        table.insert(_Instance._HeroList , self._usedata[i])
    end

    if _Instance._HeroList[1] ~= nil then
        SendMsg(PacketDefine.PacketDefine_PlayerSoldierInfo_Send, {_Instance._HeroList[1][1]})
    end
    if self._usedata[0] == 0 then
        _Instance._TopValue:setString("未上榜")
    else
        _Instance._TopValue:setString(self._usedata[0])
    end
    _Instance._GridView:reloadData()  
   
end

function UIHeroTop:SimulateClickButton(idx, tag)
    local cell = self._GridView2:cellAtIndex(idx)
    if cell ~= nil then
        local layout = cell:getChildByTag(idx)
        local panel
        if tag == 1 then                 
            panel = seekNodeByName(layout, "Panel_1")
        else
            panel = seekNodeByName(layout, "Panel_1")
        end
        local button = seekNodeByName(panel, "Button_2")
        if button ~= nil then
            SimulateClickButton(button, handlers(self, self.TableViewItemTouchEvent, 2)) 
        end
    end
end

function UIHeroTop:ChangeState(tab)
    if self._CurTabIndex == tab then
        return
    end
    self._CurTabIndex = tab
    for i = 5, 6 do
        if tab + 4 == i then
            self._TabButton[i]:setLocalZOrder(3)
            self._TabButton[i]:setBrightStyle(0)
            self._TabButton[i]:setPositionX(437)
            seekNodeByName(self._TabButton[i], "Text_1"):setPositionX(27)
            self._TabButton[i]:setTouchEnabled(false)
        else
            self._TabButton[i]:setLocalZOrder(-1)
            self._TabButton[i]:setBrightStyle(1)
            self._TabButton[i]:setPositionX(434)
            seekNodeByName(self._TabButton[i], "Text_1"):setPositionX(27)
            self._TabButton[i]:setTouchEnabled(true)
        end
    end
--    for i = 5, 6 do
--        seekNodeByName(self._TabButton[i], "Text_1"):setTextColor(cc.c3b(36, 47, 13))
--    end
--    seekNodeByName(self._TabButton[4 + tab], "Text_1"):setTextColor(cc.c3b(253, 228, 136))
    self:GetUIByName("Node_1"):setVisible(false)
    self:GetUIByName("Node_2"):setVisible(false)
    if tab == 1 then
        self:GetUIByName("Node_1"):setVisible(true)
    else
        self:GetUIByName("Node_2"):setVisible(true)
    end
    _Instance._HeroList = {}
    if tab == 1 then
        SendMsg(PacketDefine.PacketDefine_SoldierRankingList_Send, {1, 100})
    else
        SendMsg(PacketDefine.PacketDefine_ScoreRankingList_Send, {1, 100})
    end
    
    _Instance._GridView:reloadData() 
    _Instance._SelectRow = 0
end

function UIHeroTop:TouchEvent(eventType, x, y)
    if eventType == ccui.TouchEventType.ended then
        local tag = self:getTag()
        if tag == -2  then
        elseif tag == -1  then
            UISystem:CloseUI(UIType.UIType_HeroTop) 
        elseif tag == 5  then
            _Instance:ChangeState(1)  
        elseif tag == 6  then
            _Instance:ChangeState(2)
        elseif tag == 3  then
            _Instance._TabButton[4]:setBrightStyle(1)
            self:setBrightStyle(0)
            _Instance._CurWarriorTabIndex = 3
            _Instance._GridView2:reloadData()
            _Instance:SimulateClickButton(0, 2)
        elseif tag == 4  then
            _Instance._TabButton[3]:setBrightStyle(1)
            _Instance._CurWarriorTabIndex = 4
            _Instance._GridView2:reloadData()
            _Instance:SimulateClickButton(0, 2)
            self:setBrightStyle(0)
        end
    end
end

return UIHeroTop