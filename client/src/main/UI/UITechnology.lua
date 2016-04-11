----
-- 文件名称：UITechnology.lua
-- 功能描述：keji
-- 文件说明：
-- 作    者：田凯
-- 创建时间：2015-7-22
-- 修改 ：
--
--
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
local UISystem = require("main.UI.UISystem")
local TechnologyData = GameGlobal:GetTechnologyDataManager()
local GamePlayerDataManager = GameGlobal:GetGamePlayerDataManager()
local UITechnology = class("UITechnology", UIBase)

-- 构造函数
function UITechnology:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_Technology
    self._ResourceName =  "UITechnology.csb"
end

-- Load
function UITechnology:Load()
    UIBase.Load(self)

    self._TagButton = {}
    for i = 1, 3 do
        local icon = self:GetUIByName("Button_"..i)
        icon:setTag(i)
        icon:addTouchEventListener(handler(self, self.touchEvent))
        self._TagButton[i] = icon
    end
    
    self._TechDesc = seekNodeByName(self._RootPanelNode, "Text_Des")
    self._TechSilver = seekNodeByName(self._RootPanelNode, "Sliver")
    self._TechSilverIcon = seekNodeByName(self._RootPanelNode, "icon")
    self._FrameIcon = seekNodeByName(self._RootPanelNode, "Frame_icon")
    self._FrameName = seekNodeByName(self._RootPanelNode, "Frame_name")
    self._LoadingBar = seekNodeByName(self._RootPanelNode, "LoadingBar")
    self._Progress = seekNodeByName(self._RootPanelNode, "progress")
    self._MoneyPanel = seekNodeByName(self._RootPanelNode, "UI_Money")
    self._Time = seekNodeByName(self._RootPanelNode, "Time")
    self._TimeTip = seekNodeByName(self._RootPanelNode, "TimeTip")
    local close = self:GetUIByName("Close")
    close:setTag(-1)
    close:addTouchEventListener(handler(self, self.touchEvent))
    self._researchFinish = CreateAnimation(self._Progress, 103, 103, "csb/texiao/ui/T_u_keji_luzi_0.csb", "animation0", false, 0, 1)
    self._researching = CreateAnimation(self._FrameIcon, 39, 39, "csb/texiao/ui/T_u_KJ_jiemian.csb", "animation0", true, 0, 1) 
    self._researching1 = CreateAnimation (self._FrameIcon, 39, 39, "csb/texiao/ui/T_u_keji_luzi.csb", "animation0", true, 0, 1) 
    local scrollView = seekNodeByName(self._RootPanelNode, "ScrollView_1")
    scrollView:setSwallowTouches(false) 
    scrollView:setScrollBarOpacity(0)
    local techLayer = cc.CSLoader:createNode("csb/ui/TechnologyItem.csb")
    self._PanelList = seekNodeByName(techLayer, "PanelList")
    self._PanelList:setSwallowTouches(false) 
    scrollView:addChild(techLayer, 1000)

    scrollView:addEventListener(handler(self, self.scrollViewDidScroll))
    
    self._shader = {}
    self._CurSelectIndex = 5

    -- UI scrollview 上下箭头 初始化 下显上不显
    self._ImageUp = self:GetWigetByName("Image_Up")
    self._ImageUp:setLocalZOrder(1)
    self._ImageUp:setVisible(false)
    self._ImageDown = self:GetWigetByName("Image_Down")
    self._ImageDown:setLocalZOrder(1)
    self:openUISucceed()
end

function UITechnology:Open()
    UIBase.Open(self)
    -- 上下箭头 初始化    下显上不显
    self._ImageUp:setVisible(false)
    self._ImageDown:setVisible(true)
    -- 初始化选中框
    self:createSelectFrame()
    self:addEvent(GameEvent.GameEvent_UITechnology_Open, self.openUISucceed)
end

function UITechnology:Close()
    UIBase.Close(self)
    removeNodeAndRelease(self._SelectFrame, true)
end

function UITechnology:openUISucceed()
    for i = 1 , 34 do
        local layout = seekNodeByName(self._PanelList, "Panel_"..i)
        self:initListCell(layout, i)
    end
    self:updateInfo(self._CurSelectIndex)
end

function UITechnology:listItemTouched(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local index = sender:getTag()
        self._CurSelectIndex = index
        self._SelectFrame:removeFromParent(false)
        sender:addChild(self._SelectFrame, 10)
        self._SelectFrame:setPosition(50, 75)
        self:updateInfo(index)
    end
end

function UITechnology:initListCell(layout, id)
    local panel = layout
    panel:setSwallowTouches(false) 
    panel:setTag(id)
    panel:addTouchEventListener(handler(self, self.listItemTouched))

    local list = GameGlobal:GetServerTechnologyDataManager()._AllTechnologyTable
    local item = list[id]  
    seekNodeByName(panel, "Image_1"):setSwallowTouches(false)
    seekNodeByName(panel, "Flag1"):setVisible(false)
    seekNodeByName(panel, "Flag2"):setVisible(false)
    
    local icon = ccui.Helper:seekWidgetByName(panel, "Frame")
    icon:setSwallowTouches(false) 

    local head = seekNodeByName(icon, "head")
    if TechnologyData[id].valtype ~= 4 then
        head:setTexture(item._TableData.icon) 
    else
        head:setTexture(GetSoldierHeadPath(item._TableData.icon)) 
    end
    if self._shader[id] == nil then
        self._shader[id] = head:getGLProgram()
    end
    head:setGLProgram(self._shader[id])
    if item._State == 3 then
        seekNodeByName(panel, "Flag1"):setVisible(true)
    elseif item._State == 2 then
        seekNodeByName(panel, "Flag2"):setVisible(false)
        seekNodeByName(panel, "Flag2"):loadTexture("meishu/ui/keji/UI_kj_yanjiuzhong.png")
    elseif item._State == 1 then
        seekNodeByName(panel, "Flag2"):setVisible(true)
        seekNodeByName(panel, "Flag2"):loadTexture("meishu/ui/keji/UI_kj_kezhuzi.png")
    elseif item._State == 4 then
        GrayNode(head)
    elseif item._State == 0 then
        seekNodeByName(panel, "Flag2"):setVisible(true)
        seekNodeByName(panel, "Flag2"):loadTexture("meishu/ui/keji/UI_kj_kezhuzi.png")
    end
    
    local time = ccui.Helper:seekWidgetByName(panel, "Text_1")
    time:setVisible(false)
    local text = ccui.Helper:seekWidgetByName(icon, "Text_1")
    text:setString(item._TableData["name"])
end

function UITechnology:updateInfo(index)
    local objtech = GameGlobal:GetServerTechnologyDataManager()._AllTechnologyTable[index]
    local obj = TechnologyData[objtech._TableID]
   
    self._TechDesc:setString(obj["desc"])
    if obj["silver"] > 0 then
        self._TechSilver:setString(obj["silver"])
        self._TechSilverIcon:setTexture("meishu/ui/gg/UI_gg_tongqian_01.png")
    else   
        self._TechSilver:setString(obj["yb"])
        self._TechSilverIcon:setTexture("meishu/ui/gg/UI_gg_yuanbao_01.png")
    end
    seekNodeByName(g_AnimationList[4], "T_u_keji_luzi_p_3"):setTexture(obj["icon"])
    local layout = seekNodeByName(self._PanelList, "Panel_"..objtech._TableID)
    self:initListCell(layout, objtech._TableID)
    self._FrameIcon:loadTexture(obj["icon"])
    self._FrameName:setString(obj["name"])
    local num = obj["count"]
    local name = ""
    self._TagButton[1]:setVisible(true)
    self._Progress:setVisible(true) 
    self._MoneyPanel:setVisible(true)
    self._researching:setVisible(false)
    self._researching1:setVisible(false)
    self._researchFinish:setVisible(false)
    self._MoneyPanel:setVisible(false)
    self._TimeTip:setVisible(false)
    self._Time:setVisible(false)
    print("objtech._State", objtech._State)
    if objtech._State == 0 then
        self._MoneyPanel:setVisible(true)
        name = GameGlobal:GetTipDataManager(UI_BUTTON_NAME_45)
        self._LoadingBar:setPercent(100 - objtech._Count / num * 100)
    elseif objtech._State == 2 then
        name = GameGlobal:GetTipDataManager(UI_BUTTON_NAME_47)
        self._researching:setVisible(true)
        self._researching1:setVisible(true)
        self._researchFinish:setVisible(true)
        self._LoadingBar:setPercent(0)
        self._TimeTip:setVisible(true)
        self._Time:setVisible(true)
        self._timeEnd = objtech._timeEnd
        self._Time:setString(CreateTimeString(objtech._timeEnd))
        schedule(self._Time, handler(self, self.onTimeChange), 1)
    elseif objtech._State == 1 then
        self._MoneyPanel:setVisible(true)
        name = GameGlobal:GetTipDataManager(UI_BUTTON_NAME_46)
        self._researchFinish:setVisible(true)
        self._LoadingBar:setPercent(0)
    elseif objtech._State == 3 then
        self._researchFinish:setVisible(true)
        self._TagButton[1]:setVisible(false)
        self._LoadingBar:setPercent(0)
    elseif objtech._State == 4 then
        self._MoneyPanel:setVisible(true)
        self._TagButton[1]:setVisible(false)
        self._LoadingBar:setPercent(0)
        if tonumber(obj["untype1"]) == 1 then
            self._TechDesc:setString(string.format(ChineseConvert["UITechnologyText1"] ,obj["unval1"]))
        else
            self._TechDesc:setString(string.format(ChineseConvert["UITechnologyText2"] ,GameGlobal:GetCustomDataManager()[tonumber(obj["unval1"]) - 1000].name))
        end
    end
    self._TagButton[1]:getTitleRenderer():setString(name)
end

function UITechnology:onTimeChange(sender)
    local idx = sender:getTag()
    local timeStr =  CreateTimeString(self._timeEnd)
    sender:setString(timeStr)
    if self._timeEnd - os.time() <= 0 then
        self:stopAllActions()
        playAnimationObject(self._Progress, 4, 103, 103, "animation0")
    end
end

function UITechnology:touchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
        
        if tag == -1 then
            UISystem:CloseUI(UIType.UIType_Technology)
        elseif tag == 1 then
            local list = GameGlobal:GetServerTechnologyDataManager()._AllTechnologyTable
            local id = list[self._CurSelectIndex]._TableID
            local type = list[self._CurSelectIndex]._State
            local time =  list[self._CurSelectIndex]._time
            if type == 2 then
                local  cost = math.floor(time / 600)
                cost =  tonumber(time) % 600 > 0 and cost + 1 or cost 
                if GetPlayer()._Gold < cost then
                      OpenRechargeTip()
                else
                    local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                    UITip:SetStyle(0, string.gsub(GameGlobal:GetTipDataManager(UI_kj_01).."。每10分钟1元宝", "@number", cost, 1))
                    UITip:RegisteDelegate(handler(self, self.commitTipButton), 1)
                end
            elseif type < 2 then
                if type == 0 then
                    if GetPlayer()._Silver < TechnologyData[id]["silver"] and TechnologyData[id]["silver"] > 0 then
                        local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                        UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_kj_02))
                        return
                    elseif GetPlayer()._Gold < TechnologyData[id]["yb"] and TechnologyData[id]["yb"] > 0 then
                        OpenRechargeTip()
                        return
                    end
                end
                if id >= 32 then
                    CreateTipAction(self._RootUINode, "暂未开放，敬请期待！", cc.p(480, 270))
                else
                    SendMsg(PacketDefine.PacketDefine_TechResearch_Send, {id})
                end
            end
        end
    end
end

function UITechnology:commitTipButton(sender)
    local list = GameGlobal:GetServerTechnologyDataManager()._AllTechnologyTable
    local id = list[self._CurSelectIndex]._TableID
    playAnimationObject(self._Progress, 4, 103, 103, "animation0")
    if id >= 32 then
        CreateTipAction(self._RootUINode, "暂未开放，敬请期待！", cc.p(480, 270))
    else
        SendMsg(PacketDefine.PacketDefine_TechResearch_Send, {id})
    end
end

function UITechnology:createSelectFrame()
    self._SelectFrame = display.newSprite("meishu/ui/gg/UI_gg_zhuangbeikuang_xuanzhong.png", 0, 800, 
    {
        scale9 = true, 
        capInsets = cc.rect(10, 10, 98, 98), 
        rect = cc.rect(0, 0, 111, 111)
    })
    self._SelectFrame:setPreferredSize(cc.size(110, 105))
    self._SelectFrame:retain()
end

function UITechnology:scrollViewDidScroll(sender, eventType)
    if eventType == 0 or eventType == 5 then 
        -- 底部 or 回滚
        self._ImageUp:setVisible(false)
        self._ImageDown:setVisible(true)
    elseif eventType == 1 or eventType == 6 then
        -- 顶部 or 回滚
        self._ImageUp:setVisible(true)
        self._ImageDown:setVisible(false)
    end
end

return UITechnology
