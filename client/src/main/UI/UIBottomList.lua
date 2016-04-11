----
-- 文件名称：UIBottomList.lua
-- 功能描述：主城场景的UI
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-6-19
-- 修改 ：
--  
--  
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
require("cocos.ui.GuiConstants")
require("main.Utility.ChineseConvert")
local NetSystem = GameGlobal:GetNetSystem()
local UISystem = GameGlobal:GetUISystem()
local UIBottomList = class("UIBottomList", UIBase)
local ExpDataManager = GameGlobal:GetExpDataManager()

--右底Button 类型
local RIGHT_BOTTOM_BUTTON_TYPE = 
{
    --商城
    RIGHT_BOTTOM_BUTTON_SHANGCHENG = 1,
    --科技
    RIGHT_BOTTOM_BUTTON_KEJI = 2,
    --征收
    RIGHT_BOTTOM_BUTTON_CANGKU = 3,
    --战旗
    RIGHT_BOTTOM_BUTTON_ZHANQI = 4,
    --招募
    RIGHT_BOTTOM_BUTTON_RECRUIT = 5,
    --仓库
    RIGHT_BOTTOM_BUTTON_CANGKU = 6,
    --装备
    RIGHT_BOTTOM_BUTTON_ZHUANGBEI = 7,
    --士兵
    RIGHT_BOTTOM_BUTTON_SHIBING = 8,
    --武将
    RIGHT_BOTTOM_BUTTON_WUJIANG = 9,
    --任务
    RIGHT_BOTTOM_BUTTON_RENWU = 10,
    --征战
    RIGHT_BOTTOM_BUTTON_ZHENGZHAN = 11,
    --展开
    RIGHT_BOTTOM_BUTTON_ZHANKAI = 12,
    --关卡地图
    RIGHT_BOTTOM_BUTTON_CUSTOM = 13,
    --攻城掠地
    RIGHT_BOTTOM_BUTTON_GCLD = 14,
    BUTTON_HEROTOP = 15,
    --聊天
    Button_RightBottom_Talk = 16,
}

--右底Button按钮名称 
local RIGHT_BOTTOM_BUTTON_NAMELIST = 
{
    --商城
    [1] = "Button_RightBottom_ShangCheng",
    --科技
    [2] = "Button_RightBottom_KeJi",
    --征收
    [3]= "Button_RightBottom_ZhengShou",
    --战旗
    [4] = "Button_RightBottom_ZhanQi",
    --招募
    [5] = "Button_RightBottom_Zhaomu",
    --仓库
    [6] = "Button_RightBottom_CangKu",
    --装备
    [7] = "Button_RightBottom_ZhuangBei",
    --士兵
    [8] = "Button_RightBottom_ShiBing",
    --武将
    [9] = "Button_RightBottom_WuJiang",
    --任务
    [10] = "Button_RightBottom_RenWu",
    --征战
    [11] = "Button_RightBottom_ZhengZhan",
    --展开按钮
    [12] = "Button_RightBottom_Zhankai",
    --关卡地图
    [13] = "Button_RightBottom_Map",
    --攻城
    [14] = "Button_RightBottom_GCLD", 
    [15] = "Button_Center_YingXiongBang",
    [16] = "Button_RightBottom_Talk"
}

--左上角Button
local LEFT_TOP_BUTTON_TYPE = 
{
    LEFT_TOP_BUTTON_PLAYERINFO = 1,
    LEFT_TOP_BUTTON_PLAYERINFOTWO = 2,
    LEFT_TOP_BUTTON_VIPTEQUAN = 3,
    TIPS_BUTTON_JUNLING = 4,
    TIPS_BUTTON_YUANBAO = 5,
    TIPS_BUTTON_TONGQIAN = 6,
    TIPS_BUTTON_BATTLEVALUE = 7
}

local LEFT_TOP_BUTTON_NAMELIST = 
{
    [1] = "Button_PlayerInfo",
    [2] = "Button_PlayerInfoTwo",
    [3] = "Button_VIPTeQuan",
    [4] = "Button_JunLing",
    [5] = "Button_YuanBao",
    [6] = "Button_TongQian",
    [7] = "Button_BattleValue",
}

local VIP_BTN_EFFECT = "csb/texiao/ui/T_u_ZJM_VIP.csb"
local TECH_BTN_EFFECT = "csb/texiao/ui/T_u_ZJM_keji_1.csb"

local TIPSMESSAGE = "暂未开放，敬请期待！"

local LEFT_TOP_BUTTON_NUMBER = 7
local RIGHT_BOTTOM_BUTTON_NUMBER = 16

function UIBottomList:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_BottomList
    self._ResourceName = "UIBottomButton.csb"
end

function UIBottomList:Load()
    UIBase.Load(self)
    self._RightBottomButtonList = {}
    self._RightBottomButtonList = {}
    self._RightTopButtonList = {}
    self._TipsData = {}
    self._LeftTopButtonList = {}
    self._CountryText = self:GetWigetByName("Text_LeftTop_Country")
    self._HeadImage = self:GetUIByName("HeadImage")
    self._EnergyLabel = self:GetUIByName("Text_LeftTop_Junling")
    --赋值
    self._NameLabel = self:GetUIByName("Text_LeftTop_Name")
    self._CopperCoinLabel = self:GetUIByName("Text_LeftTop_TongBi")
    self._YuanBaoLabel = self:GetUIByName("Text_LeftTop_YuanBao")

    self._BattleValueLabel = self:GetUIByName("Text_LeftTop_BattleValue")
    self._ShengWangLabel = self:GetUIByName("Text_LeftTop_ShengWang")
    self._TouXiangImage = self:GetUIByName("Image_Country")
    self._LevelLabel = self:GetUIByName("Text_LeftTop_Level")
    self._ExpLabel = self:GetUIByName("Text_LeftTop_Exp")

    self._VipLabel = self:GetUIByName("VIP")
    self._ProgressBar = self:GetUIByName("LoadingBar_LeftTop_SelfExp")
    
    for i = 1, LEFT_TOP_BUTTON_NUMBER do
        self._LeftTopButtonList[i] = self:GetWigetByName(LEFT_TOP_BUTTON_NAMELIST[i])
        if self._LeftTopButtonList[i] ~= nil then
            self._LeftTopButtonList[i]:setTag(i)
            self._LeftTopButtonList[i]:setSwallowTouches(true)
            self._LeftTopButtonList[i]:addTouchEventListener(handler(self, self.OnMaincityLeftTopButtonClick))
        end
    end
    local topCenterPanel = self:GetWigetByName("Panel_TopCenter")
    for i = 1, 3 do
        local btn1 = seekNodeByName(topCenterPanel, "Button_"..i)
        local btn = seekNodeByName(btn1, "Button_Chong")
        if btn ~= nil then
            btn:setTag(i + 20)
            btn:addTouchEventListener(handler(self, self.OnMaincityLeftTopButtonClick))
        end
    end
    
    --进度条初始化 
    self._ProgressBar:setPercent(100)
    
    --按钮列表
    for i = 1, RIGHT_BOTTOM_BUTTON_NUMBER do
        self._RightBottomButtonList[i] = self:GetUIByName(RIGHT_BOTTOM_BUTTON_NAMELIST[i])
        if self._RightBottomButtonList[i] ~= nil then
            self._RightBottomButtonList[i]:setPressedActionEnabled(true)
            self._RightBottomButtonList[i]:setTag(i)
            self._RightBottomButtonList[i]:addTouchEventListener(handler(self, self.OnMaincityRightBottomButtonClick))
        end
    end
    self:GetWigetByName("ListView_1"):setSwallowTouches(false)
    self._MoveNode = self:GetUIByName("MoveNode")
    -- self._MoveNode:retain()
end

-- 初始化所有特效
function UIBottomList:CreateEffects()
    -- 初始化VIP按钮特效
    local vipBoard = self:GetUIByName("UI_vip_VIP_1")
    local vipBoardSize = vipBoard:getContentSize()
    self._CurVipBoardEffect = CreateAnimation(vipBoard, vipBoardSize.width / 2, vipBoardSize.height / 2, VIP_BTN_EFFECT, "animation0", true, 1, 1)
    
--    -- 初始化科技特效
--    local techBtn = seekNodeByName(self._MoveNode, "Button_RightBottom_KeJi")
--    local techBtnSize = techBtn:getContentSize()
--    self._CurTechEffect = CreateAnimation(techBtn, techBtnSize.width / 2, techBtnSize.height / 2, TECH_BTN_EFFECT, "animation0", true, 1, 1)
end

-- 初始化所有特效
function UIBottomList:ReleaseEffects()
    removeNodeAndRelease(self._CurVipBoardEffect)
    removeNodeAndRelease(self._CurTechEffect)

    self._CurVipBoardEffect = nil
    self._CurTechEffect = nil
end


--Unload
function UIBottomList:Unload()
    UIBase.Unload(self)
    self._MoveNode:release()
    self._MoveNode = nil
end

--打开
function UIBottomList:Open()
    UIBase.Open(self)
    --self._IsShowBottom = false
    self:RefreshLeftTopInfo()
    self:CreateEffects()
    self:addEvent(GameEvent.GameEvent_MyselfInfoChange, self.OnInfoChange)
end

--信息改变的回调
function UIBottomList.OnInfoChange(event)
    local bottomListUI = UISystem:GetUIInstance(UIType.UIType_BottomList)
    if bottomListUI ~= nil then
        bottomListUI:RefreshLeftTopInfo()
    end
end

--关闭
function UIBottomList:Close()
    UIBase.Close(self)
    self:ReleaseEffects()
end

--刷新左上角玩家信息
function UIBottomList:RefreshLeftTopInfo()
    --print("UIMaincity:RefreshLeftTopInfo")
    local myselfData = GetPlayer()
    if myselfData ~= nil then
        -- vip
        self._VipLabel:loadTexture("meishu/ui/vip/UI_vip_"..myselfData._VIPLevel..".png")
        --名称
        if self._NameLabel ~= nil then
            self._NameLabel:setString(myselfData._UserName)
        end
        --铜币
        if self._CopperCoinLabel ~= nil then
            if myselfData._Silver >= 10000 then
                self._CopperCoinLabel:setString(math.floor(myselfData._Silver/10000).."万")
            else
                self._CopperCoinLabel:setString(tostring(myselfData._Silver))
            end
        end
        --元宝
        if self._YuanBaoLabel ~= nil then
            if myselfData._Gold >= 10000 then
                self._YuanBaoLabel:setString(math.floor(myselfData._Gold/10000).."万")
            else
                self._YuanBaoLabel:setString(tostring(myselfData._Gold))
            end
        end
        --战力
        if self._BattleValueLabel ~= nil then
            if myselfData._BattleValue >= 10000 then
                self._BattleValueLabel:setString(string.format(math.floor(myselfData._BattleValue/10000).."%s","万"))
            else
                self._BattleValueLabel:setString(tostring(myselfData._BattleValue))
            end
        end
        --TODO: 声望 没有值
        if self._ShengWangLabel ~= nil then
        --self._ShengWangLabel:setString(tostring(myselfData._BattleValue))
        end
        -- 头像
        if self._TouXiangImage ~= nil then
            local headIconName = GetCountryIconName(myselfData._Country)
            self._TouXiangImage:loadTexture(headIconName)
        end
        
        local countryFontColor = GetCountryFontColor(g_CountryID)
        local countryText = GetCountryChinese(g_CountryID)
        self._CountryText:setString("["..countryText.."]")
        self._CountryText:setTextColor(countryFontColor)
        if myselfData._HeadId ~= nil then
            local warrior = GameGlobal:GetCharacterServerDataManager():GetLeader(myselfData._HeadId)
            if warrior ~= nil then
                local head1Name = warrior._CharacterData["headName"]
                self._HeadImage:loadTexture(GetWarriorHeadPath(head1Name))
            end
        end
        
        --等级
        if self._LevelLabel ~= nil then
            if myselfData._Level ~= nil then
                local showLevelStr = string.format("lv.%d", myselfData._Level)
                self._LevelLabel:setString(showLevelStr)
            end
        end

        -- 进度条
        if self._ProgressBar ~= nil then
            if(myselfData._Exp ~= nil and myselfData._Level ~= nil) then 
                local per = (myselfData._Exp/ ExpDataManager[myselfData._Level]["selfExp"])*100
                self._ExpLabel:setString(myselfData._Exp.."/"..ExpDataManager[myselfData._Level]["selfExp"])
                self._ProgressBar:setPercent(per)
            end
        end
        if self._CurrentCustom ~= nil and myselfData._MaxLevel ~= nil then
            self._CurrentCustom:setString("第"..myselfData._MaxLevel.."关")
        end
        self._EnergyLabel:setString(tostring(myselfData._Energy))
        --相关Tips数据存储
        local vipDataManager = GameGlobal:GetVipDataManager()
        self._TipsData[1] = myselfData._BattleValue
        self._TipsData[2] = myselfData._Energy
        self._TipsData[3] = vipDataManager[myselfData._VIPLevel]["tilimax"]
        self._TipsData[4] = myselfData._Gold
        self._TipsData[5] = myselfData._Silver
    end
end

function UIBottomList:OnMaincityRightBottomButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if sender ~= nil then
            local tag = sender:getTag()
            --征战点击
            if tag == RIGHT_BOTTOM_BUTTON_TYPE.RIGHT_BOTTOM_BUTTON_ZHENGZHAN then
                --temp
                local myselfData = GamePlayerDataManager:GetMyselfData()

                if myselfData._Energy > 0 then  --判断军令数量
                    self:EnterBattle()
                elseif ItemDataManager:GetItemCount(HuFu) > 0 then --判断虎符数量
                    UISystem:OpenUI(UIType.UIType_UseHuFu)
                    performWithDelay(UISystem:GetUIRootNode(), handler(self, self.DelayCallBack), 0)
                else --购买虎符
                    UISystem:OpenUI(UIType.UIType_BuyItem)
                    local uiInstance = UISystem:GetUIInstance(UIType.UIType_BuyItem)
                    uiInstance:OpenItemInfoNotifiaction(HuFu)
                end

                --士兵
            elseif tag == RIGHT_BOTTOM_BUTTON_TYPE.RIGHT_BOTTOM_BUTTON_SHIBING then
                local uiSystem = GameGlobal:GetUISystem()
                uiSystem:OpenUI(UIType.UIType_SoldierUI)
                --武将
            elseif tag == RIGHT_BOTTOM_BUTTON_TYPE.RIGHT_BOTTOM_BUTTON_WUJIANG then
                local warrior = UISystem:OpenUI(UIType.UIType_WarriorUI) 
                --任务
            elseif tag == RIGHT_BOTTOM_BUTTON_TYPE.RIGHT_BOTTOM_BUTTON_RENWU then
                UISystem:OpenUI(UIType.UIType_Task)
                --仓库
            elseif tag == RIGHT_BOTTOM_BUTTON_TYPE.RIGHT_BOTTOM_BUTTON_CANGKU then
                UISystem:OpenUI(UIType.UIType_BagUI)
                --商城
            elseif tag == RIGHT_BOTTOM_BUTTON_TYPE.RIGHT_BOTTOM_BUTTON_SHANGCHENG then
                UISystem:OpenUI(UIType.UIType_StoreUI)
                --装备
            elseif tag == RIGHT_BOTTOM_BUTTON_TYPE.RIGHT_BOTTOM_BUTTON_ZHUANGBEI then
                UISystem:OpenUI(UIType.UIType_UISmelt)
                --展开按钮
            elseif tag == RIGHT_BOTTOM_BUTTON_TYPE.RIGHT_BOTTOM_BUTTON_ZHANKAI then
                --移动过程中不能被点击
                self._RightBottomButtonList[tag]:setPressedActionEnabled(false)
                local maincityUI = UISystem:GetUIInstance(UIType.UIType_MaincityUI)
                if not self._IsShowBottom then
                    maincityUI:MoveCallBack(self._IsShowBottom)
                    self._IsShowBottom = true
                    --多个动画-回弹效果
                    MoveStartAction(self._MoveNode, self.MoveCallBack, 10, 0.1, 0, 0, self)
                    MoveStartAction(self._MoveNode, self.MoveCallBack, -430, 0.1, 0, 0.1, self)
                    MoveStartAction(self._MoveNode, self.MoveBackCallBack, 10, 0.1, 0, 0.2, self)
                else
                    maincityUI:MoveCallBack(self._IsShowBottom)
                    self._IsShowBottom = false
                    MoveStartAction(self._MoveNode, self.MoveCallBack, -10, 0.1, 0, 0, self)
                    MoveStartAction(self._MoveNode, self.MoveCallBack, 430, 0.1, 0, 0.1, self)
                    MoveStartAction(self._MoveNode, self.MoveBackCallBack, -10, 0.1, 0, 0.2, self)
                end
            elseif tag == RIGHT_BOTTOM_BUTTON_TYPE.RIGHT_BOTTOM_BUTTON_RECRUIT then
                UISystem:OpenUI(UIType.UIType_UIRecruit)
                --科技
            elseif tag == RIGHT_BOTTOM_BUTTON_TYPE.RIGHT_BOTTOM_BUTTON_KEJI then
                UISystem:OpenUI(UIType.UIType_Technology)
                --战旗
            elseif tag == RIGHT_BOTTOM_BUTTON_TYPE.RIGHT_BOTTOM_BUTTON_ZHANQI then
                local CharacterServerDataManager = GameGlobal:GetCharacterServerDataManager()
                CharacterServerDataManager:BackUpZhenXingData()
                UISystem:OpenUI(UIType.UIType_BuZhen)
                --关卡地图
            elseif tag == RIGHT_BOTTOM_BUTTON_TYPE.RIGHT_BOTTOM_BUTTON_CUSTOM then
                UISystem:OpenUI(UIType.UIType_CustomMap)
            elseif tag == RIGHT_BOTTOM_BUTTON_TYPE.BUTTON_HEROTOP then
                UISystem:OpenUI(UIType.UIType_HeroTop)
                SendMsg(PacketDefine.PacketDefine_GetHeroTopList_Send, {1, 1})
                --攻城略地
            elseif tag == RIGHT_BOTTOM_BUTTON_TYPE.RIGHT_BOTTOM_BUTTON_GCLD then
                --请求进入
                CreateTipAction(self._RootUINode, TIPSMESSAGE, cc.p(480, 270))
                  --临时关闭
--                local enterGuoZhanPacket = NetSystem:CreateToSendPacket(PacketDefine.PacketDefine_EnterGuoZhan_Send)
--                enterGuoZhanPacket._EnterType = 1
--                NetSystem:SendPacket(enterGuoZhanPacket)
--                --临时打开UI，正确的应该是收到网络回包后,由于协议需要修改
--                UISystem:OpenUI(UIType.UIType_WorldMap)
                --聊天
            elseif tag == RIGHT_BOTTOM_BUTTON_TYPE.Button_RightBottom_Talk then
                CreateTipAction(self._RootUINode, TIPSMESSAGE, cc.p(480, 270))
                --UISystem:OpenUI(UIType.UIType_TalkUI)
            end
        end
    end
end

--左上角BUTTON及tips
function UIBottomList:OnMaincityLeftTopButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
        local UITip = require("main.UI.UITip")
        local data = {}
        if tag == LEFT_TOP_BUTTON_TYPE.LEFT_TOP_BUTTON_PLAYERINFO or tag == LEFT_TOP_BUTTON_TYPE.LEFT_TOP_BUTTON_PLAYERINFOTWO then
            UISystem:OpenUI(UIType.UIType_PlayerInfo)
        elseif tag == LEFT_TOP_BUTTON_TYPE.LEFT_TOP_BUTTON_VIPTEQUAN then
            CreateTipAction(self._RootUINode, TIPSMESSAGE, cc.p(480, 270))
            --临时关闭
--          UISystem:OpenUI(UIType.UIType_UIActivity)
        elseif tag == LEFT_TOP_BUTTON_TYPE.TIPS_BUTTON_JUNLING then
            --            UITip:OpenEquipInfo(x, y, width, height, data, type)
            data[1] = self._TipsData[2]
            data[2] = self._TipsData[3]
            UITip:OpenTipsInfo(290, 480, 160, 70, data, 1)
        elseif tag == LEFT_TOP_BUTTON_TYPE.TIPS_BUTTON_YUANBAO then
            data[1] = self._TipsData[4]
            UITip:OpenTipsInfo(290, 480, 220, 70, data, 2)
        elseif tag == LEFT_TOP_BUTTON_TYPE.TIPS_BUTTON_TONGQIAN then
            data[1] = self._TipsData[5]
            UITip:OpenTipsInfo(450, 480, 240, 70, data, 3)
        elseif tag == LEFT_TOP_BUTTON_TYPE.TIPS_BUTTON_BATTLEVALUE then
            data[1] = self._TipsData[1]
            UITip:OpenTipsInfo(100, 410, 190, 130, data, 4)
        elseif tag == 21 or tag == 22 or tag == 23 then
            CreateTipAction(self._RootUINode, TIPSMESSAGE, cc.p(480, 270))
            --临时关闭 
--          UISystem:OpenUI(UIType.UIType_UIRecharge)
        end
    end
end

--所有缩放动作完成后“展开-缩放按钮”才能再次被点击

function UIBottomList:MoveCallBack()
end

function UIBottomList:MoveBackCallBack(sender)
    self._RightBottomButtonList[12]:setPressedActionEnabled(true)
    if not self._IsShowBottom then
        --按钮变化
        self._RightBottomButtonList[12]:loadTextures("meishu/ui/zhujiemian/UI_zjm_shensuo01_01.png", "meishu/ui/zhujiemian/UI_zjm_shensuo01_02.png", UI_TEX_TYPE_LOCAL)
    else
        self._RightBottomButtonList[12]:loadTextures("meishu/ui/zhujiemian/UI_zjm_shensuo02_01.png", "meishu/ui/zhujiemian/UI_zjm_shensuo02_02.png", UI_TEX_TYPE_LOCAL)
    end
end

return UIBottomList