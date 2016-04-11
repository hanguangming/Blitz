----
-- 文件名称：UICountrySelect.lua
-- 功能描述：测试UI
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-6-16
-- 修改 ：
--  测试UI动画的支持情况
--
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
local UISystem = require("main.UI.UISystem")
local G_SIDE_SHU                  = 0
local G_SIDE_WEI                  = 1
local G_SIDE_WU                   = 2

local UICountrySelect = class("UICountrySelect", UIBase)

--构造函数
function UICountrySelect:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UICountrySelect
    self._ResourceName =  "UICountry.csb"
end

--Load
function UICountrySelect:Load()
    UIBase.Load(self)
    self._CountryButton = {}
    
    local layout = cc.CSLoader:createNode("csb/ui/Dialog.csb")
    self:addChild(layout, 0, 0)
    for i = 1, 12 do
        if i ~= 5 and i ~= 6 then
            self._CountryButton[i] = self:GetWigetByName("Button_"..i)
            self._CountryButton[i]:setTag(i)
            if i >= 4 then
                self._CountryButton[i]:addTouchEventListener(handler(self, self.TouchEvent))
            else
                self._CountryButton[i]:setVisible(false)
            end
        end
    end
end

--Unload
function UICountrySelect:Unload()
    UIBase.Unload(self)
end

--打开
function UICountrySelect:Open()
    UIBase.Open(self)
end

--关闭
function UICountrySelect:Close()
    UIBase.Close(self)
end

function UICountrySelect:TouchEvent(sender, eventType)
    if type(eventType) == "table" then
        eventType = eventType.eventType
    end
    if eventType == ccui.TouchEventType.ended then
        if sender:getTag() == -1 then
            self._CountryButton[g_CountryID]:setVisible(false)
            self._RootPanelNode:removeChildByTag(101)
        elseif sender:getTag() == 13 then
            self._RandomName = self._RandomNameField:getString()
            g_PlayerName = self._RandomName
            if self._RandomName ~= nil then
                self._RootPanelNode:removeChildByTag(102)
                UISystem:CloseUI(UIType.UIType_Country)
                local loginUI = UISystem:GetUIInstance(UIType.UIType_LoginUI)
                SendLoginMsg(PacketDefine.PacketDefine_Register_Send, {loginUI._user, loginUI._pwd, 0})
            end
        elseif sender:getTag() == 6 then
            local name1 = math.random(1, 113)
            local name2 = math.random(1, 264)
            local name3 = math.random(1, 445)
            local name = ""
            name = name..GameGlobal:GetRandomNameDataManager()[name1].prefix
            name = name..GameGlobal:GetRandomNameDataManager()[name2].firstname
            name = name..GameGlobal:GetRandomNameDataManager()[name3].lastname
            self._RandomNameField:setString(name)
        elseif sender:getTag() == 5 then
            self._RootPanelNode:removeChildByTag(101)
            self:RandomName()
        else
            g_CountryID = sender:getTag()
            self:SelectCountry(sender:getTag())
        end
    end
end

function UICountrySelect:SelectCountry()
   
    if g_CountryID > 4 and g_CountryID < 9 then
        g_CountryID = 1
    elseif  g_CountryID > 4 and g_CountryID < 11 then
        g_CountryID = 3
    elseif  g_CountryID > 4 and g_CountryID < 13 then
        g_CountryID = 2
    end
    performWithDelay(self._RootPanelNode, handler(self, self.ShowCountryInfo) , 0.2)
    if g_CountryID < 4 then
        self._CountryButton[g_CountryID]:setVisible(true)
    end
end

function UICountrySelect:ShowCountryInfo()
    local layout = cc.CSLoader:createNode("csb/ui/CountryItem.csb")
    local close = seekNodeByName(layout, "Close")
    close:setTag(-1)
    close:addTouchEventListener(handler(self, self.TouchEvent))

    local commit = seekNodeByName(layout, "Button_1")
    commit:setTag(5)
    commit:addTouchEventListener(handler(self, self.TouchEvent))

    local cRole = {"UI_xg_liubei_01.png", "UI_xg_caocao_01.png",  "UI_xg_sunquan_01.png", "UI_xg_yinying_01.png"}
    local cName = {"UI_xg_mingcheng_01.png", "UI_xg_mingcheng_02.png",  "UI_xg_mingcheng_03.png"}
    local cNameDes = {"UI_xg_jieshao_01.png", "UI_xg_jieshao_02.png",  "UI_xg_jieshao_03.png"}
    local role = seekNodeByName(layout, "Image_5")
    local name = seekNodeByName(layout, "Image_4")
    local roleDes = seekNodeByName(layout, "Image_3")
    local roleBack = seekNodeByName(layout, "Image_7")
    
    if g_CountryID < 4 then
        role:loadTexture("meishu/ui/xuanguo/"..cRole[g_CountryID], 0)
        name:loadTexture("meishu/ui/xuanguo/"..cName[g_CountryID], 0)
        roleDes:loadTexture("meishu/ui/xuanguo/"..cNameDes[g_CountryID], 0)
        if g_CountryID == 1 then
            roleBack:setVisible(true)
        else
            roleBack:setVisible(false)
        end
        seekNodeByName(layout, "Image_8"):setVisible(false)
        role:setContentSize(role:getVirtualRendererSize())
        roleDes:setContentSize(roleDes:getVirtualRendererSize())
    else
        role:setVisible(false)
        name:setVisible(false)
        seekNodeByName(layout, "Image_8"):setVisible(true)
        roleBack:loadTexture("meishu/ui/xuanguo/"..cRole[g_CountryID], 0)
        g_CountryID = math.random(1, 3)
    end

    self._RootPanelNode:addChild(layout, 1100, 101)
end

function UICountrySelect:RandomName()
    local layout = cc.CSLoader:createNode("csb/ui/RandomName.csb")

    local random = seekNodeByName(layout, "Button_1")
    random:setTag(6)
    random:addTouchEventListener(handler(self, self.TouchEvent))
    
    local commit = seekNodeByName(layout, "Button_2")
    commit:setTag(13)
    commit:addTouchEventListener(handler(self, self.TouchEvent))
    
    self._RandomNameField = seekNodeByName(layout, "TextField_1")
    
    self._RootPanelNode:addChild(layout, 1100, 102)

end

return UICountrySelect
