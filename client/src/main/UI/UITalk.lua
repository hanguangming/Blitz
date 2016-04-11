----
-- 文件名称：UITalk.lua
-- 功能描述：UITalk
-- 文件说明：UITalk
-- 作    者：秦宝
-- 创建时间：2015-8-25
--  修改
--  

require("cocos.ui.GuiConstants")
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
require("cocos.ui.DeprecatedUIEnum")
require("cocos.extension.ExtensionConstants")
local GamePlayerDataManager = GameGlobal:GetGamePlayerDataManager()
local TalkDataManager = GameGlobal:GetTalkDataManager()
local B_STATE_SYSTEM = 13
local B_STATE_WORLD = 14
local B_STATE_SILIAO = 15
local B_STATE_ZONGHE = 16
local B_STATE_FRIEND = 11
local B_STATE_YUYIN = 9
local B_STATE_CLOSE = 46 
local B_STATE_SEND = 33 

local Talk_Type_SystemInfo = 3
local Talk_Type_GongGao = 5
local Talk_Type_SiLiao = 4
local Talk_Type_World = 1
local Talk_Type_ZongHe = 2
--国家、世界、私聊的标示  
local UI_LiaoTian_Flag = {
    [1] = "meishu/ui/liaotian/UI_lt_shijie.png",
    [2] = "meishu/ui/liaotian/UI_lt_guojia.png",
    [4] = "meishu/ui/liaotian/UI_lt_siliao.png",
}
--锁定某一头像
local ClickHeadIconID = nil
--发送字数限制50
local LimitFontNum = 50

--itemTag = 世界1、系统2、私聊3、综合4   
--itemTag用于判断当前InitPlayerLayout处于哪个listview，其值不要跟聊天类型值混淆
local InfoTagListViewZongHe = 1000  --聊天记录的tag值，用于头像点击
local InfoTagListViewSiLiao = 2000
local InfoTagListViewWorld = 3000

--输入框最多输入50个字
--local TextFieldMaxFontLength = 50

local UISystem = GameGlobal:GetUISystem()

local UITalk = class("UITalk", UIBase)
local _Instance = nil 

function UITalk:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_TalkUI
    self._ResourceName = "UITalk.csb"  
    self.OpenUISucceedCallBack = nil
end
local friendButton = nil

function UITalk:Load()
    UIBase.Load(self)
    _Instance = self
    self._Slider = nil
    self._InputText = self:GetWigetByName("TextField_Kuang")
    self._SendButton = self:GetWigetByName("Button_Send")
    self._SystemButton = self:GetWigetByName("Button_System")
    self._WorldButton = self:GetWigetByName("Button_World")
    self._SiLiaoButton = self:GetWigetByName("Button_SiLiao")
    self._ZongHeButton = self:GetWigetByName("Button_Zonghe")
--    self._FriendButton = self:GetWigetByName("Button_Friend")
    friendButton = self:GetWigetByName("Button_Friend")
    self._FriendIcon = seekNodeByName(seekNodeByName(self._RootPanelNode, "Button_Friend"), "Image_5")
    local closeButton = self:GetWigetByName("Button_Close")
    local yuYinButton = self:GetWigetByName("Button_YuYin")
    self._TextFieldKuang = self:GetWigetByName("TextField_Kuang")
    self._NewestInfoBG = self:GetWigetByName("Image_3")
    self._NewestSiLiaoInfoNum = self:GetWigetByName("Text_Num")
    self._InputBg = self:GetWigetByName("Image_2")
    self._FriendTextLabel = self:GetWigetByName("Text_1")
    self._FriendTextLabel:setString("")
    
    self._FriendHide = self:GetWigetByName("Image_4")
    self._FriendHide:setVisible(false)
    
    --点击聊天界面以外的地方，聊天界面退出
    self:GetWigetByName("Panel_1"):setSwallowTouches(true)
    self:GetWigetByName("Panel_Center"):setSwallowTouches(true)
    self:GetWigetByName("Panel_1"):addTouchEventListener(_Instance.LiaoTianSceneCallBackEvent)

    --最新消息
    self._NewestInfoBG:setVisible(false)
    self._NewestSiLiaoInfoNum:setString("")
    --发送
    if self._SendButton ~= nil then
        self._SendButton:setTag(B_STATE_SEND)
        self._SendButton:addTouchEventListener(self.TouchEvent)
--        self._SendButton:getTitleRenderer():enableOutline(cc.c4b(237, 184, 70, 250), 1)
--        self._SendButton:getTitleRenderer():setPositionY(26)
    end
    --系统
    if self._SystemButton ~= nil then
        self._SystemButton:setTag(B_STATE_SYSTEM)
        self._SystemButton:addTouchEventListener(self.TouchEvent)
--        self._SystemButton:getTitleRenderer():enableOutline(cc.c4b(86, 54, 39, 250), 3)
--        self._SystemButton:getTitleRenderer():setPositionY(23)
    end
    --世界
    if self._WorldButton ~= nil then
        self._WorldButton:setTag(B_STATE_WORLD)
        self._WorldButton:addTouchEventListener(self.TouchEvent)
--        self._WorldButton:getTitleRenderer():enableOutline(cc.c4b(86, 54, 39, 250), 3)
--        self._WorldButton:getTitleRenderer():setPositionY(23)
    end
    --私聊
    if self._SiLiaoButton ~= nil then
        self._SiLiaoButton:setTag(B_STATE_SILIAO)
        self._SiLiaoButton:addTouchEventListener(self.TouchEvent)
--        self._SiLiaoButton:getTitleRenderer():enableOutline(cc.c4b(86, 54, 39, 250), 3)
--        self._SiLiaoButton:getTitleRenderer():setPositionY(23)
    end
    --综合
    if self._ZongHeButton ~= nil then
        self._ZongHeButton:setTag(B_STATE_ZONGHE)
        self._ZongHeButton:addTouchEventListener(self.TouchEvent)
--        self._ZongHeButton:getTitleRenderer():enableOutline(cc.c4b(86, 54, 39, 250), 3)
--        self._ZongHeButton:getTitleRenderer():setPositionY(23)
        self._ZongHeButton:loadTextures("meishu/ui/gg/UI_gg_anniu3_02.png", UI_TEX_TYPE_LOCAL)
    end
    --好友
    if friendButton ~= nil then
        friendButton:setTag(B_STATE_FRIEND)
        friendButton:addTouchEventListener(self.TouchEvent)
    end
    --关闭
    if closeButton ~= nil then
        closeButton:setTag(B_STATE_CLOSE)
        closeButton:addTouchEventListener(self.TouchEvent) 
    end
    --语音
    if yuYinButton ~= nil then
        yuYinButton:setTag(B_STATE_YUYIN)
        yuYinButton:addTouchEventListener(self.TouchEvent)
    end

    --加载私聊listview
    self._ListViewSiLiao = self:GetWigetByName("ListView_SiLiao")
    self._ListViewSiLiao:setScrollBarOpacity(0)
    for i = 1, #TalkDataManager:GetTalkDataManager()._SiLiaoList do
        self._ListViewSiLiao:insertCustomItem(self:InitCell(TalkDataManager:GetTalkDataManager()._SiLiaoList, i, 3), 0)
    end
    self._ListViewSiLiao:setVisible(false)
    if tonumber(TalkDataManager:GetTalkDataManager()._NewestInfoNum) > 0 then
        self._NewestInfoBG:setVisible(true)
        self._NewestSiLiaoInfoNum:setString(TalkDataManager:GetTalkDataManager()._NewestInfoNum)
    end
    --加载系统listview
    self._ListViewSystem = self:GetWigetByName("ListView_System")
    self._ListViewSystem:setScrollBarOpacity(0)
    for i = 1, #TalkDataManager:GetTalkDataManager()._SystemList do
        self._ListViewSystem:insertCustomItem(self:InitCell(TalkDataManager:GetTalkDataManager()._SystemList, i, 2), 0)
    end
    self._ListViewSystem:setVisible(false)
    
    --加载世界listview
    self._ListViewWorld = self:GetWigetByName("ListView_World")
    self._ListViewWorld:setScrollBarOpacity(0)
    for i = 1, #TalkDataManager:GetTalkDataManager()._WorldList do
        self._ListViewWorld:insertCustomItem(self:InitCell(TalkDataManager:GetTalkDataManager()._WorldList, i, 1), 0)
    end
    self._ListViewWorld:setVisible(false)
    
    --加载综合listview
    self._ListViewZongHe = self:GetWigetByName("ListView_ZongHe")
    self._ListViewZongHe:setScrollBarOpacity(0)
    for i = 1, #TalkDataManager:GetTalkDataManager()._ZongHeList do
        self._ListViewZongHe:insertCustomItem(self:InitCell(TalkDataManager:GetTalkDataManager()._ZongHeList, i, 4), 0)
    end
    self._ListViewZongHe:setVisible(true)
    self._ItemTagIndex = B_STATE_ZONGHE
    --不显示好友俩字
    friendButton:setVisible(false)
    self._TextFieldKuang:setPosition(cc.p(73, 494))
    self._TextFieldKuang:setContentSize(cc.size(300, self._TextFieldKuang:getContentSize().height))
end

function UITalk.EndCallBack(value)
end


function UITalk:Unload()
    UIBase:Unload()
    self._ResourceName = nil
    self.Type = nil
    ClickHeadIconID = nil
end

function UITalk:Open()
    UIBase.Open(self)
    self:OpenUISucceed()
    self.OpenUISucceedCallBack = AddEvent(GameEvent.GameEvent_Talk_UpdateTop, self.UpdateTalk)
end

function UITalk:Close()
    UIBase.Close(self)
    if self.OpenUISucceedCallBack ~= nil then
        RemoveEvent(self.OpenUISucceedCallBack)
        self.OpenUISucceedCallBack = nil
    end
    InfoTagListViewZongHe = 1000  --聊天记录的tag值，用于头像点击
    InfoTagListViewSiLiao = 2000
    InfoTagListViewWorld = 3000
end

function UITalk:UpdateTalk()
    --最新的一条记录
    local maxIdData = TalkDataManager:GetTalkDataManager()._ZongHeList[#TalkDataManager:GetTalkDataManager()._ZongHeList]
    local limitNum = TalkDataManager:GetTalkDataManager()._LimitNum
    --1 世界
    if maxIdData.type == Talk_Type_World then
        if #TalkDataManager:GetTalkDataManager()._WorldList >= limitNum then
            _Instance._ListViewWorld:removeItem(#TalkDataManager:GetTalkDataManager()._WorldList - 1)
        end
        _Instance._ListViewWorld:insertCustomItem(_Instance:InitCell(TalkDataManager:GetTalkDataManager()._WorldList, 0, 1), 0)
        --3 系统
    elseif maxIdData.type == Talk_Type_SystemInfo then
        if #TalkDataManager:GetTalkDataManager()._SystemList >= limitNum then
            _Instance._ListViewSystem:removeItem(#TalkDataManager:GetTalkDataManager()._SystemList - 1)
        end
        _Instance._ListViewSystem:insertCustomItem(_Instance:InitCell(TalkDataManager:GetTalkDataManager()._SystemList, 0, 2), 0)
        --4 私聊
    elseif maxIdData.type == Talk_Type_SiLiao then
        --最新私聊消息num
        if _Instance._ItemTagIndex == B_STATE_SILIAO then
            TalkDataManager:GetTalkDataManager()._NewestInfoNum = 0
        end
        if tonumber(TalkDataManager:GetTalkDataManager()._NewestInfoNum) > 0 then
            _Instance._NewestInfoBG:setVisible(true)
            _Instance._NewestSiLiaoInfoNum:setString(TalkDataManager:GetTalkDataManager()._NewestInfoNum)
        end
        if #TalkDataManager:GetTalkDataManager()._SiLiaoList >= limitNum then
            _Instance._ListViewSiLiao:removeItem(#TalkDataManager:GetTalkDataManager()._SiLiaoList - 1)
        end
        _Instance._ListViewSiLiao:insertCustomItem(_Instance:InitCell(TalkDataManager:GetTalkDataManager()._SiLiaoList, 0, 3), 0)
    end
    -- 国家/综合
    if #TalkDataManager:GetTalkDataManager()._ZongHeList >= limitNum then
        _Instance._ListViewZongHe:removeItem(#TalkDataManager:GetTalkDataManager()._ZongHeList - 1)
    end
    _Instance._ListViewZongHe:insertCustomItem(_Instance:InitCell(TalkDataManager:GetTalkDataManager()._ZongHeList, 0, 4), 0)
end

function UITalk:InitPlayerLayout(layout, list, idx, itemTag)
    local vipText = seekNodeByName(layout, "Text_VIP")
    vipText:setString("V"..list[idx].vip)

    local headIconButton = seekNodeByName(layout, "Button_HeadIcon")
    headIconButton:loadTextures(string.format("%s","meishu/wujiang/touxiang/yuan/T_y_liuqi.png"), UI_TEX_TYPE_LOCAL)
    if headIconButton ~= nil then
        if itemTag == 1 then
            headIconButton:setTag(InfoTagListViewWorld)
            InfoTagListViewWorld = InfoTagListViewWorld + 1
        elseif itemTag == 3 then
            headIconButton:setTag(InfoTagListViewSiLiao)
            InfoTagListViewSiLiao = InfoTagListViewSiLiao + 1
        elseif itemTag == 4 then
            headIconButton:setTag(InfoTagListViewZongHe)
            InfoTagListViewZongHe = InfoTagListViewZongHe + 1
        end 
        if InfoTagListViewZongHe == 2000 then
            InfoTagListViewZongHe = 1000
        end
        if InfoTagListViewSiLiao == 3000 then
            InfoTagListViewSiLiao = 2000
        end
        headIconButton:addTouchEventListener(_Instance.TouchEvent)
    end

    local flag = seekNodeByName(layout, "flag")
    flag:loadTexture(string.format("%s",UI_LiaoTian_Flag[list[idx].type]))
    
    local countryText = seekNodeByName(layout, "Text_Country")
    countryText:setString("【" .. GetCountryChinese(list[idx]._Country) .. "】")
    local nameText = seekNodeByName(layout, "Text_Name")
    nameText:setString(list[idx].name)
    if list[idx].id == GamePlayerDataManager:GetMyselfData()._ServerID then
        countryText:setPosition((nameText:getPositionX() - nameText:getContentSize().width), nameText:getPositionY())
    end
    local text1 = seekNodeByName(layout, "Text_1")

    local fontSize = text1:getFontSize()
    local LineWidth = (fontSize + 0.5)*13
    local label, rowNum = _Instance:GetStringSpecial(list[idx].text, fontSize, LineWidth)

    text1:setContentSize(cc.size(LineWidth, rowNum*18))
    text1:setString(label)
    
    local Image_1 = seekNodeByName(layout, "Image_1")
    Image_1:setContentSize(cc.size(text1:getContentSize().width + 18, text1:getContentSize().height + 12))
    Image_1:setSwallowTouches(false)
    
    seekNodeByName(layout, "Panel_1"):setPositionY(0)
    seekNodeByName(layout, "Panel_2"):setPositionY(rowNum*18 - 110)
    seekNodeByName(layout, "Panel_1"):setContentSize(cc.size(400, rowNum*18 + 70))
    seekNodeByName(layout, "Panel_1"):setSwallowTouches(false)  
end
local Talk_Type_SystemInfo = 3
local Talk_Type_GongGao = 5
local Talk_Type_SiLiao = 4
local Talk_Type_World = 1
local Talk_Type_ZongHe = 2
function UITalk:InitSystemLayout(layout, list, idx, itemTag)
    local rowNum = 0
    --系统公告标示（图片）
    local image1 = seekNodeByName(layout, "Image_1")
    local text1 = seekNodeByName(layout, "Text_6")
    if list[idx].type == Talk_Type_SystemInfo then
        local fontSize = text1:getFontSize()
        local LineWidth = (fontSize + 0.5)*21
        local label = ""
        label, rowNum = _Instance:GetStringSpecial(list[idx].text, fontSize, LineWidth)
        text1:setContentSize(cc.size(LineWidth, rowNum*18))
        text1:setString(label)
    elseif list[idx].type == Talk_Type_GongGao then
        image1:loadTexture("meishu/ui/liaotian/UI_lt_gonggao.png")
        text1:setVisible(false)
        
    end

    local fontSize = text1:getFontSize()
    local LineWidth = (fontSize + 0.5)*21
    local label, rowNum = _Instance:GetStringSpecial(list[idx].text, fontSize, LineWidth)
    
    text1:setContentSize(cc.size(LineWidth, rowNum*18))
    text1:setColor(cc.c4b(255,79,77,255))
    text1:setString(label)
    
    
--    self._GongGaoPanel = ccui.Layout:create() 
--    self._GongGaoPanel:setBackGroundImage("meishu/ui/guozhanditu/UI_gzdt_touminglan2.png")
--    self._GongGaoPanel:setBackGroundImageScale9Enabled(true)
--    self._GongGaoPanel:setClippingEnabled(true)
--    self._GongGaoPanel:setVisible(true)
--    self._GongGaoPanel:setContentSize(cc.size(300, 45))
--    self._GongGaoPanel:setPosition(33, 0)
--    self._GongGaoPanel:setAnchorPoint(cc.p(0.5, 0))
----    layout:clone():addChild(self._GongGaoPanel, 1000)
--    
--    tolua.cast(layout, "ccui.Layout"):addChild(self._GongGaoPanel, 1000)
    
    
    seekNodeByName(layout, "Panel_1"):setPositionY(0)
    seekNodeByName(layout, "Panel_2"):setPositionY(rowNum*18 - 30)
    seekNodeByName(layout, "Panel_1"):setContentSize(cc.size(370, rowNum*18))
    seekNodeByName(layout, "Panel_1"):setSwallowTouches(false)
end

function UITalk:InitCell(list, idx, itemTag)   --世界1、系统2、私聊3、综合4
    if idx == 0 then
        idx = #list
    end
    local layout = nil
    --非系统消息
    if list[idx].type == Talk_Type_World or list[idx].type == Talk_Type_ZongHe or list[idx].type == Talk_Type_SiLiao then
        --玩家发言
        if list[idx].id == GamePlayerDataManager:GetMyselfData()._ServerID then
            layout = cc.CSLoader:createNode("csb/ui/TalkItem2.csb")
            self:InitPlayerLayout(layout, list, idx, itemTag)
        --其他人发言
        elseif list[idx].id ~= GamePlayerDataManager:GetMyselfData()._ServerID then
            layout = cc.CSLoader:createNode("csb/ui/TalkItem1.csb")
            self:InitPlayerLayout(layout, list, idx, itemTag)
        end
    --系统消息
    elseif list[idx].type == Talk_Type_SystemInfo or list[idx].type == Talk_Type_GongGao then
        layout = cc.CSLoader:createNode("csb/ui/TalkItem3.csb")
        self:InitSystemLayout(layout, list, idx, itemTag)
    end

    layout:setTag(450)
    local panel_1 = seekNodeByName(layout, "Panel_1"):clone()
    layout:retain()
    return panel_1
end

-----------------------------------好友listview begin-------------------------------------------------
local function ClickFriendsItem(sender, eventType)
    if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
        _Instance:ChangeTabState(B_STATE_SILIAO)
        _Instance._ListViewSiLiao:setVisible(true)
        _Instance._SiLiaoButton:loadTextures("meishu/ui/liaotian/UI_gg_anniu3_01.png", UI_TEX_TYPE_LOCAL)
        ClickHeadIconID = _Instance._FriendIndex[sender:getCurSelectedIndex() + 1]["id"]

--        friendButton:setOpacity(0)
        local label = string.sub(_Instance._FriendIndex[sender:getCurSelectedIndex() + 1]["text"], 0, 6)
        _Instance._FriendTextLabel:setString(label .. "...")
    end
end

function UITalk:SceneCallBackEvent(eventType)
    if eventType == ccui.TouchEventType.ended then
        _Instance._RootPanelNode:removeChildByTag(110, true)
        _Instance._FriendIcon:setScaleY(1)
    end
end

function UITalk:ClickFriendButton()
    local layout = cc.CSLoader:createNode("csb/ui/TalkFriends.csb")
    _Instance._RootPanelNode:addChild(layout, 10, 110)
    seekNodeByName(layout, "Panel_2"):setSwallowTouches(true)
    seekNodeByName(layout, "ListView_1"):setSwallowTouches(true)
    seekNodeByName(layout, "Panel_2"):addTouchEventListener(_Instance.SceneCallBackEvent)
--    seekNodeByName(layout, "ListView_1"):addTouchEventListener(_Instance.SceneCallBackEvent)
    
    _Instance._ListViewFriends = seekNodeByName(layout, "ListView_1")
    for i = 1, #_Instance._FriendIndex do
        _Instance._ListViewFriends:insertCustomItem(_Instance:InitFriendItem(i), i - 1)
    end
    _Instance._ListViewFriends:addEventListener(ClickFriendsItem)
end

function UITalk:InitFriendItem(idx)
    local layout = cc.CSLoader:createNode("csb/ui/TalkFriendsItem.csb")
    _Instance._FriendIcon:setScaleY(-1)
    local text = seekNodeByName(layout, "Text_1")
    text:setString(_Instance._FriendIndex[idx]["text"])
    seekNodeByName(layout, "Panel_1"):setPositionY(0)
    seekNodeByName(layout, "Panel_1"):setSwallowTouches(false)
    seekNodeByName(layout, "Panel_1"):addTouchEventListener(_Instance.SceneCallBackEvent)
    local Panel_1 = seekNodeByName(layout, "Panel_1"):clone()
    layout:retain()
    return Panel_1
end

-----------------------------------好友listview end-------------------------------------------------

function UITalk:HeadCallBackEvent(eventType)
    if eventType == ccui.TouchEventType.ended then
        _Instance._RootPanelNode:removeChildByTag(450, true)
    end
end

local listViewTag
function UITalk.FriendOperator()
    local tag = listViewTag
    local tagList = tag - 3000 + 1
    local list = TalkDataManager:GetTalkDataManager()._WorldList
    ClickHeadIconID = list[tagList].id
    print(",,,,,,,,,,,,,,,,,,,,,,", list[tagList].name)
    friendButton:setTitleText(list[tagList].name)
    _Instance:ChangeTabState(B_STATE_SILIAO)
    _Instance._ListViewSiLiao:setVisible(true)
    _Instance._SiLiaoButton:loadTextures("meishu/ui/liaotian/UI_gg_anniu3_01.png", UI_TEX_TYPE_LOCAL)
end

--local friendPanelFlag = 0  --点击好友按钮弹出好友listview，在此点击消失
function UITalk.TouchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        print("", sender.x)
    
        local tag = sender:getTag()
        --关闭
        if tag == B_STATE_CLOSE then
            UISystem:CloseUI(UIType.UIType_TalkUI)
        --点击头像
        elseif tag >= 1000 then
            local limitNum = TalkDataManager:GetTalkDataManager()._LimitNum
            local list = nil
            local tagList = nil
            local listItem = nil
            --在世界面板时
            if tag >= 3000 then
                if InfoTagListViewWorld >= (3000 + limitNum) then
                    tagList = tag - (InfoTagListViewWorld - limitNum) + 1
                    list = TalkDataManager:GetTalkDataManager()._WorldList
                    listItem = _Instance._ListViewWorld:getItem(#list - tagList)
                else
                    tagList = tag - 3000 + 1
                    list = TalkDataManager:GetTalkDataManager()._WorldList
                    listItem = _Instance._ListViewWorld:getItem(#list - tagList)
                end
            --在私聊面板时
            elseif tag >= 2000 then
                if InfoTagListViewSiLiao >= (2000 + limitNum) then
                    tagList = tag - (InfoTagListViewSiLiao - limitNum) + 1
                    list = TalkDataManager:GetTalkDataManager()._SiLiaoList
                    listItem = _Instance._ListViewSiLiao:getItem(#list - tagList)
                else
                    tagList = tag - 2000 + 1
                    list = TalkDataManager:GetTalkDataManager()._SiLiaoList
                    listItem = _Instance._ListViewSiLiao:getItem(#list - tagList)
                end
            --在综合面板
            elseif tag >= 1000 then
                if InfoTagListViewZongHe >= (1000 + limitNum) then
                    tagList = tag - (InfoTagListViewZongHe - limitNum) + 1
                    list = TalkDataManager:GetTalkDataManager()._ZongHeList
                    listItem = _Instance._ListViewZongHe:getItem(#list - tagList)
                else
                    tagList = tag - 1000 + 1
                    list = TalkDataManager:GetTalkDataManager()._ZongHeList
                    listItem = _Instance._ListViewZongHe:getItem(#list - tagList)
                    
                end
            end
            
            local point = listItem:getPositionY()
            local p = listItem:getParent():convertToWorldSpace(cc.p(0, point))
            
            --点击自己的头像令其没有反应
            if list[tagList].id == GamePlayerDataManager:GetMyselfData()._ServerID then
                return
            end
            ClickHeadIconID = list[tagList].id
            local layout = cc.CSLoader:createNode("csb/ui/TalkClickHead.csb")
            layout:retain()
            _Instance._RootPanelNode:addChild(layout, 200, 450)
            local Panel_1 = seekNodeByName(layout, "Panel_1")
            Panel_1:setPosition(cc.p(0, 0))
            seekNodeByName(layout, "Panel_1"):setSwallowTouches(true)
            seekNodeByName(layout, "Panel_1"):addTouchEventListener(_Instance.HeadCallBackEvent)
            
            local Panel_2 = seekNodeByName(layout, "Panel_2")
            if p.y <= 150 then
                Panel_2:setPosition(cc.p(p.x + 10, p.y - 0))
            else
                Panel_2:setPosition(cc.p(p.x + 10, p.y - 200))
            end

            local siLiaoButton1 = seekNodeByName(layout, "Button_SiLiao")
            if siLiaoButton1 ~= nil then
                siLiaoButton1:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 250), 3)
                siLiaoButton1:getTitleRenderer():setPositionY(24)
                siLiaoButton1:addTouchEventListener(function()
                    _Instance:ChangeTabState(B_STATE_SILIAO)
                    _Instance._ListViewSiLiao:setVisible(true)
                    _Instance._SiLiaoButton:loadTextures("meishu/ui/liaotian/UI_gg_anniu3_01.png", UI_TEX_TYPE_LOCAL)
                        
--                    friendButton:setOpacity(0)
--                    local label = string.sub(list[tagList].name, 0, 6)
                    local label = ""
--                    print("77777777777777777777777777777777string.len(label)", string.len(label))
                    print("ffff", string.sub("ggg", 1, 1))
                    local flag = 0
                    local fontNum = 0
                    local limitNum = 2
                    for i = 1, string.len(list[tagList].name) do
                        if fontNum == limitNum then
                            break
                        end
                        if string.byte(string.sub(list[tagList].name, i, i+1)) > 127 then
                            print(">>>>>>>>>>>>>>>>>>>>>>>>", string.sub(list[tagList].name, i, i))
                            if flag == 0 then
                                local k = string.sub(list[tagList].name, i, i + 2)
                                label = label .. k
                                print("999:", k)
                                fontNum = fontNum + 1
                            end
                            flag = flag + 1
                            if flag >= 3 then
                                flag = 0
                            end
                        else
                            local k = string.sub(list[tagList].name, i, i)
                            label = label .. k
                            print("999:", k)
                            fontNum = fontNum + 1
                            limitNum = 4
                        end
                    end
                    _Instance._FriendTextLabel:setString(label .. "...")
                    ClickHeadIconID = list[tagList].id
                    
                    --遮挡框，将好友俩字遮挡
                    _Instance._FriendHide:setVisible(true)
                    friendButton:setVisible(true)
                    
                    _Instance._RootPanelNode:removeChildByTag(450, true)
                end)
            end
                
            local pingBiButton1 = seekNodeByName(layout, "Button_PingBi")
            if pingBiButton1 ~= nil then
                pingBiButton1:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 250), 3)
                pingBiButton1:getTitleRenderer():setPositionY(24)
                pingBiButton1:addTouchEventListener(function()
                    ClickHeadIconID = list[tagList].id
                    -- 移除当前面板
                    _Instance._RootPanelNode:removeChildByTag(450, true)
                    -- 删除数据
                    for i = #TalkDataManager:GetTalkDataManager()._SiLiaoList, 1, -1 do
                        if TalkDataManager:GetTalkDataManager()._SiLiaoList[i].id == ClickHeadIconID then
                            table.remove(TalkDataManager:GetTalkDataManager()._SiLiaoList, i)
                        end
                    end
                    for i = #TalkDataManager:GetTalkDataManager()._ZongHeList, 1, -1 do
                        if TalkDataManager:GetTalkDataManager()._ZongHeList[i].id == ClickHeadIconID then
                            if TalkDataManager:GetTalkDataManager()._ZongHeList[i].type ~= Talk_Type_World then
                                table.remove(TalkDataManager:GetTalkDataManager()._ZongHeList, i)
                            end 
                        end
                    end
                    _Instance._ListViewSiLiao:removeAllChildren()
                    _Instance._ListViewZongHe:removeAllChildren()
                    InfoTagListViewSiLiao = 2000
                    InfoTagListViewZongHe = 1000
                    -- 重新加载listview
                    for i = 1, #TalkDataManager:GetTalkDataManager()._SiLiaoList do
                        _Instance._ListViewSiLiao:insertCustomItem(_Instance:InitCell(TalkDataManager:GetTalkDataManager()._SiLiaoList, i, 3), 0)
                    end
                    -- 重新加载listview
                    for i = 1, #TalkDataManager:GetTalkDataManager()._ZongHeList do
                        _Instance._ListViewZongHe:insertCustomItem(_Instance:InitCell(TalkDataManager:GetTalkDataManager()._ZongHeList, i, 4), 0)
                    end
                end)
            end
        --好友
        elseif tag == B_STATE_FRIEND then
--            if friendPanelFlag == 0 then
--                friendPanelFlag = friendPanelFlag + 1
                _Instance:ClickFriendButton()
--            else
--                friendPanelFlag = friendPanelFlag - 1
--                _Instance._RootPanelNode:removeChildByTag(110, true)    
--            end
        --系统
        elseif tag == B_STATE_SYSTEM then
            _Instance:ChangeTabState(B_STATE_SYSTEM)
            _Instance._ListViewSystem:setVisible(true)
            _Instance._SystemButton:loadTextures("meishu/ui/gg/UI_gg_anniu3_01.png", UI_TEX_TYPE_LOCAL)
        --世界
        elseif tag == B_STATE_WORLD then
            _Instance:ChangeTabState(B_STATE_WORLD)
            _Instance._ListViewWorld:setVisible(true)
            _Instance._WorldButton:loadTextures("meishu/ui/gg/UI_gg_anniu3_01.png", UI_TEX_TYPE_LOCAL)
        --私聊
        elseif tag == B_STATE_SILIAO then
            _Instance:ChangeTabState(B_STATE_SILIAO)
            _Instance._ListViewSiLiao:setVisible(true)
            _Instance._SiLiaoButton:loadTextures("meishu/ui/gg/UI_gg_anniu3_01.png", UI_TEX_TYPE_LOCAL)
        --综合
        elseif tag == B_STATE_ZONGHE then
            _Instance:ChangeTabState(B_STATE_ZONGHE)
            _Instance._ListViewZongHe:setVisible(true)
            _Instance._ZongHeButton:loadTextures("meishu/ui/gg/UI_gg_anniu3_01.png", UI_TEX_TYPE_LOCAL)
        --发送
        elseif tag == B_STATE_SEND then
            --输入框为空
            if _Instance._InputText:getString() == "" then
                return
            end
            --当前处在系统面板
            if _Instance._ItemTagIndex == B_STATE_SYSTEM then
                return
            --当前处在世界面板
            elseif _Instance._ItemTagIndex == B_STATE_WORLD then
                local text = _Instance:LimitStringNum(_Instance._InputText:getString())
                --玩家将要话费元宝发言   元宝数量判断
                local myselfData = GamePlayerDataManager:GetMyselfData()
                --(每次花费元宝数量待定)
                if myselfData._Gold >5 then
                    SendMsg(PacketDefine.PacketDefine_Char_Send, {1, 0, string.format("%s", text)})
                else
                    --元宝不足
                end
            --当前处在私聊面板
            elseif _Instance._ItemTagIndex == B_STATE_SILIAO then
                --需选中好友
                if ClickHeadIconID ~= nil then
                    local text = _Instance:LimitStringNum(_Instance._InputText:getString())
                    SendMsg(PacketDefine.PacketDefine_Char_Send, {4, ClickHeadIconID, string.format("%s", text)})
                end
            --当前处在综合面板
            elseif _Instance._ItemTagIndex == B_STATE_ZONGHE then
                --可直接发言
                local text = _Instance:LimitStringNum(_Instance._InputText:getString())
               
                SendMsg(PacketDefine.PacketDefine_Char_Send, {2, 0, string.format("%s", text)})
            end
            _Instance._InputText:setString("")
        end
    end
end

--移除聊天界面
function UITalk:LiaoTianSceneCallBackEvent(eventType)
    if eventType == ccui.TouchEventType.ended then
        UISystem:CloseUI(UIType.UIType_TalkUI)
    end
end

--发送字数限制
function UITalk:LimitStringNum(str)
    local label = ""
    local flag = 0
    local fontNum = 0

    for i = 1, string.len(str) do
        if fontNum >= LimitFontNum then
            break
        end
        if string.byte(string.sub(str, i, i+1)) > 127 then
            if flag == 0 then
                local k = string.sub(str, i, i + 2)
                label = label .. k
                fontNum = fontNum + 1
            end
            flag = flag + 1
            if flag >= 3 then
                flag = 0
            end
        else
            local k = string.sub(str, i, i)
            label = label .. k
            fontNum = fontNum + 1
        end
    end
    return label
end

-- 获取带\n的字符串
function UITalk:GetStringSpecial(getText, fontSize, LineWidth)
    local label = ""
    local flag = 0
    --字体大小14，间距0.5，每行13个字
    local FontWidth = 0   --str宽度，用于判断是否换行
    local rowNum = 1
    for i = 1, string.len(getText) do
        if string.byte(string.sub(getText, i, i+1)) > 127 then
            if flag == 0 then
                local k = string.sub(getText, i, i + 2)
                if (CalculateStringWidth(k, fontSize) + FontWidth) > LineWidth*rowNum then
                    label = label .. "\n"
                    rowNum = rowNum + 1
                end
                label = label .. k
                FontWidth = CalculateStringWidth(label, fontSize)
            end
            flag = flag + 1
            if flag >= 3 then
                flag = 0
            end
        else
            local k = string.sub(getText, i, i)
            if (CalculateStringWidth(k, fontSize) + FontWidth) > LineWidth*rowNum then
                label = label .. "\n"
                rowNum = rowNum + 1
            end
            label = label .. k
            FontWidth = CalculateStringWidth(label, fontSize)
        end
    end
    return label, rowNum
end

function UITalk:GetCurBagList()
    if self._ItemTagIndex == B_STATE_SYSTEM then
        return _Instance._SystemIndex
    elseif self._ItemTagIndex == B_STATE_WORLD then
        return _Instance._WorldIndex
    elseif self._ItemTagIndex == B_STATE_SILIAO then
        return self._SiLiaoIndex
    elseif self._ItemTagIndex == B_STATE_ZONGHE then
        return self._ZongHeIndex
    end
    return self._WorldIndex
end

function UITalk:ChangeTabState(index)
    if index == B_STATE_SILIAO then
        TalkDataManager:GetTalkDataManager()._NewestInfoNum = 0
        self._NewestInfoBG:setVisible(false)
        self._NewestSiLiaoInfoNum:setString("")
        friendButton:setVisible(true)
        self._TextFieldKuang:setPosition(cc.p(142, 494))
        self._TextFieldKuang:setContentSize(cc.size(230, self._TextFieldKuang:getContentSize().height))
        _Instance._FriendHide:setVisible(false)
    else
        friendButton:setVisible(false)
        self._TextFieldKuang:setPosition(cc.p(73, 494))
        self._TextFieldKuang:setContentSize(cc.size(300, self._TextFieldKuang:getContentSize().height))
        _Instance._FriendHide:setVisible(false)
    end

    if index == B_STATE_SYSTEM then
        self._TextFieldKuang:setString("系统频道不能发言")
        self._TextFieldKuang:setTouchEnabled(false)
        self._TextFieldKuang:setColor(cc.c4b(255,0,0,255))
        self._TextFieldKuang:setPosition(cc.p(150, 494))
        self._SendButton:setTouchEnabled(false)
        self._InputBg:loadTexture(string.format("meishu/ui/liaotian/UI_lt_zheyankuang.png"))
        self._SendButton:loadTextures(string.format("meishu/ui/liaotian/UI_lt_haoyou_01.png"), UI_TEX_TYPE_LOCAL)
    else
        if self._TextFieldKuang:getString() == "系统频道不能发言" then
            self._TextFieldKuang:setString("")
        end
        self._TextFieldKuang:setTouchEnabled(true)
        self._TextFieldKuang:setColor(cc.c4b(255,255,255,255))
        self._SendButton:setTouchEnabled(true)
        self._InputBg:loadTexture(string.format("meishu/ui/liaotian/UI_lt_shuru.png"))
        self._SendButton:loadTextures(string.format("meishu/ui/gg/UI_gg_anniu3_01.png"), UI_TEX_TYPE_LOCAL)
    end

    friendButton:setTitleText("")
    ClickHeadIconID = nil
    self._FriendTextLabel:setString("")
--    friendButton:setOpacity(255)
    self._ItemTagIndex = index
    self._ListViewWorld:setVisible(false)
    self._ListViewSystem:setVisible(false)
    self._ListViewSiLiao:setVisible(false)
    self._ListViewZongHe:setVisible(false)
    _Instance._SystemButton:loadTextures("meishu/ui/gg/UI_gg_anniu3_02.png", UI_TEX_TYPE_LOCAL)
    _Instance._WorldButton:loadTextures("meishu/ui/gg/UI_gg_anniu3_02.png", UI_TEX_TYPE_LOCAL)
    _Instance._SiLiaoButton:loadTextures("meishu/ui/gg/UI_gg_anniu3_02.png", UI_TEX_TYPE_LOCAL)
    _Instance._ZongHeButton:loadTextures("meishu/ui/gg/UI_gg_anniu3_02.png", UI_TEX_TYPE_LOCAL)
end

function UITalk:OpenUISucceed()
    self._PlayerID = GamePlayerDataManager:GetMyselfData()._ServerID
    _Instance._FriendIndex = {
        [1] = {
            id = "123456789012",
            text = "【吴】[V10]好友姓名1"
        },
        [2] = {
            id = "123456789013",
            text = "【吴】[V10]好友姓名2"
        },
        [3] = { 
            id = "123456789014",
            text = "【吴】[V10]好友姓名3"
        },
        [4] = {
            id = "123456789015",
            text = "【吴】[V10]好友姓名4"
        },
        [5] = {
            id = "123456789016",
            text = "【吴】[V10]好友姓名5"
        },
        [6] = {
            id = "123456789017",
            text = "【吴】[V10]好友姓名6"
        },
    }
end

return UITalk