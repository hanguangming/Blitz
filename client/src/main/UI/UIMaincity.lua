----
-- 文件名称：UIMaincity.lua
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
local GamePlayerDataManager = GameGlobal:GetGamePlayerDataManager()
local TalkDataManager = GameGlobal:GetTalkDataManager()
local CharacterServerDataManager = GameGlobal:GetCharacterServerDataManager()
local NetSystem = GameGlobal:GetNetSystem()
local UISystem = GameGlobal:GetUISystem()
local UIMaincity = class("UIMaincity", UIBase)
local tostring = tostring
local stringFormat = string.format
local tableInsert = table.insert
--获取经验表数据
local ExpDataManager = GameGlobal:GetExpDataManager()
--虎符id
local HuFu = 30019
local self = nil 
--右底Button 类型
local RIGHT_BOTTOM_BUTTON_TYPE = 
{
    --商城
    RIGHT_BOTTOM_BUTTON_SHANGCHENG = 1,
    --征战
    RIGHT_BOTTOM_BUTTON_ZHENGZHAN = 11,
    --展开
    RIGHT_BOTTOM_BUTTON_ZHANKAI = 12,
    --关卡地图
    RIGHT_BOTTOM_BUTTON_CUSTOM = 13,
    --攻城掠地
    RIGHT_BOTTOM_BUTTON_GCLD = 14,
    --英雄榜
    BUTTON_HEROTOP = 15,
    --聊天
    Button_RightBottom_Talk = 16,
    
    --图鉴
     BUTTON_TuJian = 17,
    --王宫
     BUTTON_WangGong = 18,
    --寄售行
     BUTTON_JiShouHang = 19
    
}
--右底Button按钮名称 
local RIGHT_BOTTOM_BUTTON_NAMELIST = 
{
    --商城
    [1] = "Button_RightBottom_ShangCheng",
    --征战
    [11] = "Button_RightBottom_ZhengZhan",
    --展开按钮
    [12] = "Button_RightBottom_Zhankai",
    --关卡地图
    [13] = "Button_RightBottom_ZhengZhan",
    --攻城
    [14] = "Button_RightBottom_Map", 
    [15] = "Button_Center_YingXiongBang",
    [16] = "Button_RightBottom_Talk"
}

local RIGHT_TOP_BUTTON_TYPE = 
{
    RIGHT_TOP_BUTTON_RICHANG = 1,
    RIGHT_TOP_BUTTON_ChENGZHANG = 2,
    LEFT_TOP_BUTTON_RECHARGE = 3,
    RIGHT_TOP_BUTTON_STORE = 4
}

local RIGHT_TOP_BUTTON_NAMELIST = 
{
    [1] = "Button_RightTop_RiChang",
    [2] = "Button_RightTop_ChengZhang",
    [3] = "Recharge",
    [4] = "Button_RightTop_Store"
}

local RIGHT_BOTTOM_BUTTON_NUMBER = 16
local RIGHT_TOP_BUTTON_NUMBER = 4

local LEFT_BOTTOM_BUTTON_TYPE = 
{
    LEFT_BOTTOM_BUTTON_HUOYUE = 11,
    LEFT_BOTTOM_BUTTON_TASK = 12,
}

local NPC = {"daoshi", "nongmin", "tufu", "danfu", "nongminyugou", "gouyunongmin", "xiaocui", "chunli"}
--local NPCTIME ={ 40, 55, 50, 60, 10, 35, 45, 30}
local NPCTIME ={ 80, 110, 100, 120, 40, 70, 90, 60}
local NPCMAX = 6
--local WARRIORTIME = 20
local WARRIORTIME = 60
local WARRIORMAX = 3
local MoveDistance = 2700
--local BattleTipFlag = 0

local MAINCITY_CIRCLE_BTN_EFFECT    = "csb/texiao/ui/T_u_ZJM_renwu_1.csb"
local MAINCITY_TASK_ITEM_EFFECT     = "csb/texiao/ui/T_u_ZJM_renwu_2.csb"

local TIPSMESSAGE = "暂未开放，敬请期待！"

--构造函数
function UIMaincity:ctor()
    --
    UIBase.ctor(self)
    self._Type = UIType.UIType_MaincityUI
    self._ResourceName =  "UIMaincity.csb"
    --右底功能按钮ButtonList
    self._RightBottomButtonList = nil
    --信息变化回调
    self._InfoChangeCallBack = nil
    --测试回调
    self._TestCallBack = nil

    --测试用，布阵编辑器选择的关卡
    self._TestLevelID = 0

    --任务圆形按钮特效
    self._CurTaskCircleBtnEffect = nil
    --活跃度圆形按钮特效
    self._CurActivenessCircleBtnEffect = nil
    --首条任务特效
    self._CurTaskTopTileEffect = nil
    --首条活跃度特效
    self._CurActivenessTopTileEffect = nil
end

--------------------------------------------------所有UI必须实现的四个接口，且必须放在最前面  begin -------------------------------------------------------
--加载
function UIMaincity:Load()
    UIBase.Load(self)
    self._RightBottomButtonList = {}
    self._RightTopButtonList = {}
    
    --公告滚屏用
    self._GongGaoPanel = ccui.Layout:create() 
    self._GongGaoPanel:setBackGroundImage("meishu/ui/guozhanditu/UI_gzdt_touminglan2.png")
    self._GongGaoPanel:setBackGroundImageScale9Enabled(true)
    self._GongGaoPanel:setClippingEnabled(true)
    self._GongGaoPanel:setVisible(false)
    self._GongGaoPanel:setContentSize(cc.size(300, 45))
    self._GongGaoPanel:setPosition(480, 400)
    self._GongGaoPanel:setAnchorPoint(cc.p(0.5, 0.5))
    self._RootPanelNode:addChild(self._GongGaoPanel)
    self:GongGaoGunPing()
    
    --按钮列表
    for i = 1, RIGHT_BOTTOM_BUTTON_NUMBER do
        self._RightBottomButtonList[i] = self:GetUIByName(RIGHT_BOTTOM_BUTTON_NAMELIST[i])
        if self._RightBottomButtonList[i] ~= nil then
            self._RightBottomButtonList[i]:setPressedActionEnabled(true)
            self._RightBottomButtonList[i]:setTag(i)
            self._RightBottomButtonList[i]:addTouchEventListener(handler(self, self.OnMaincityRightBottomButtonClick))
        end
    end
    
    for i = 1, RIGHT_TOP_BUTTON_NUMBER do
        self._RightTopButtonList[i] = self:GetUIByName(RIGHT_TOP_BUTTON_NAMELIST[i])
        if self._RightTopButtonList[i] ~= nil then
            self._RightTopButtonList[i]:setPressedActionEnabled(true)
            self._RightTopButtonList[i]:setTag(i)
            self._RightTopButtonList[i]:addTouchEventListener(handler(self, self.OnMaincityRightTopButtonClick))
        end
    end
    
    --官职
    local guanDiButton = self:GetUIByName("Button_Center_WangGong") 
    if guanDiButton ~= nil then
        guanDiButton:addTouchEventListener(handler(self, self.OnGuanDiClick))
    end
    --当前关卡
    self._CurrentCustom = self:GetUIByName("Button_RightBottom_MapTxt")
    self._CurrentCustom:setVisible(false)
    local leftBottom = self:GetUIByName("Panel_LeftBottom")
    --任务相关
    self._TaskPanel = seekNodeByName(leftBottom, "Panel_Task")
    self._TaskPanel:setTag(12)
    self._TaskPanel:addTouchEventListener(handler(self, self.OnMaincityLeftBottomButtonClick))
    self._SuoZhanBtnTask = seekNodeByName(leftBottom, "Button_SuoZhan_Task")
    self._SuoZhanBtnTask:setTag(1)
    self._SuoZhanBtnTask:addTouchEventListener(handler(self, self.OnMaincityLeftBottomButtonClick))
    self._MainTaskText = seekNodeByName(self._TaskPanel, "Text_MainTask")
    
    --活跃相关
    self._HuoYuePanel = seekNodeByName(leftBottom, "Panel_HuoYue")
    self._HuoYuePanel:setTag(11)
    self._HuoYuePanel:addTouchEventListener(handler(self, self.OnMaincityLeftBottomButtonClick))
    self._SuoZhanBtnHuoYue = seekNodeByName(leftBottom, "Button_SuoZhan_HuoYue")
    self._SuoZhanBtnHuoYue:setTag(2)
    self._SuoZhanBtnHuoYue:addTouchEventListener(handler(self, self.OnMaincityLeftBottomButtonClick))
    
    ------------------视差节点ParallaxNode begin -------------------------
    --设置吞噬false以保证滑动有效
    local rightTopPanel = self:GetWigetByName("Panel_RightTop")
    rightTopPanel:setSwallowTouches(false)
    local rightBottomPanel = self:GetWigetByName("Panel_RightBottom")
    rightBottomPanel:setSwallowTouches(false)
    local listView2 = seekNodeByName(rightBottomPanel, "ListView_2")
    listView2:setSwallowTouches(false)
    
    --获取相关节点
    local center = self:GetWigetByName("Panel_Center")
    --获取滚动ScrollView组件
    local scrollView = seekNodeByName(center, "ScrollView_1")
    local itemPancel = cc.CSLoader:createNode("csb/ui/MaincityItem.csb")
    scrollView:setScrollBarOpacity(0)

    --获取天空节点
    local skyNode = seekNodeByName(itemPancel, "Image_BgSky"):clone()
    --获取云节点
    local cloudNode = seekNodeByName(itemPancel, "Image_BgCloud"):clone()
    --获取山节点
    local mountainNode = seekNodeByName(itemPancel, "Image_BgMountain"):clone()
    --获取建筑
    local jianZhuNode = seekNodeByName(itemPancel, "Image_JianZhu"):clone()
    --获取麦田（远处）
    local maiTianYuanNode = seekNodeByName(itemPancel, "Image_MaiTian_Yuan"):clone()
    --获取麦田（近处）
    local maiTianJinNode = seekNodeByName(itemPancel, "Image_MaiTian_Jin"):clone()
    --获取陆地节点
    local landNode = seekNodeByName(itemPancel, "Image_BgLand"):clone()
    landNode:setSwallowTouches(false)
    seekNodeByName(landNode, "Panel_Land"):setSwallowTouches(false)
    seekNodeByName(landNode, "Panel_House_Yuan"):setSwallowTouches(false)
    --获取房子（近处）
    local houseJinNode = seekNodeByName(itemPancel, "Image_House_Jin"):clone()
    seekNodeByName(houseJinNode, "Panel_House_Jin"):setSwallowTouches(false)
    --获取树林节点
    local treeNode = seekNodeByName(itemPancel, "Image_BgTree"):clone()
    
    --沙场 点兵
    self._ShaChangButton = seekNodeByName(jianZhuNode, "Button_4")
    self._ShaChangButton:setSwallowTouches(false)
    if self._ShaChangButton ~= nil then
        self._ShaChangButton:addTouchEventListener(handler(self, self.OnShaChangClick))
    end
    
    --这里应该是图鉴,王宫和寄售行
    self._Tujian = seekNodeByName(jianZhuNode, "Button_5")
    self._Tujian:setSwallowTouches(false)
    if self._Tujian ~= nil then
        self._Tujian:setPressedActionEnabled(true)
        self._Tujian:setTag(RIGHT_BOTTOM_BUTTON_TYPE.BUTTON_TuJian)
        self._Tujian:addTouchEventListener(handler(self, self.OnMaincityRightBottomButtonClick))
    end

    
    self._Wanggong = seekNodeByName(jianZhuNode, "Button_7")
    self._Wanggong:setSwallowTouches(false)
    if self._Wanggong ~= nil then
        self._Wanggong:setPressedActionEnabled(true)
        self._Wanggong:setTag(RIGHT_BOTTOM_BUTTON_TYPE.BUTTON_WangGong)
        self._Wanggong:addTouchEventListener(handler(self, self.OnMaincityRightBottomButtonClick))
    end
    
    self._Jishouhang = seekNodeByName(jianZhuNode, "Button_8")
    self._Jishouhang:setSwallowTouches(false)
    if self._Jishouhang ~= nil then
        self._Jishouhang:setPressedActionEnabled(true)
        self._Jishouhang:setTag(RIGHT_BOTTOM_BUTTON_TYPE.BUTTON_JiShouHang)
        self._Jishouhang:addTouchEventListener(handler(self, self.OnMaincityRightBottomButtonClick))
    end
    
    --英雄榜
    self._HeroBang = seekNodeByName(jianZhuNode, "Button_6")
    self._HeroBang:setSwallowTouches(false)
    if self._HeroBang ~= nil then
        self._HeroBang:setPressedActionEnabled(true)
        self._HeroBang:setTag(RIGHT_BOTTOM_BUTTON_TYPE.BUTTON_HEROTOP)
        self._HeroBang:addTouchEventListener(handler(self, self.OnMaincityRightBottomButtonClick))
    end
    
    --创建视差节点
    local parallaxNode = cc.ParallaxNode:create()
    --加入视差节点
    local x = 0
    cloudNode:setSwallowTouches(false)
    mountainNode:setSwallowTouches(false)
    jianZhuNode:setSwallowTouches(false)
    maiTianYuanNode:setSwallowTouches(false)
    maiTianJinNode:setSwallowTouches(false)
    landNode:setSwallowTouches(false)
    parallaxNode:addChild(skyNode, 1, cc.p(0.4, 0), cc.p(x, 540))
    parallaxNode:addChild(cloudNode, 2, cc.p(0.5, 0), cc.p(x, 370 - 50))
    parallaxNode:addChild(mountainNode, 3, cc.p(0.6, 0), cc.p(x, 170 - 50))
    parallaxNode:addChild(jianZhuNode, 4, cc.p(0.7, 0), cc.p(x, -23 - 50))
    parallaxNode:addChild(maiTianYuanNode, 5, cc.p(0.8, 0), cc.p(x, 243 - 50))
    parallaxNode:addChild(maiTianJinNode, 6, cc.p(0.9, 0), cc.p(x, 213 - 50))
    parallaxNode:addChild(landNode, 7, cc.p(1, 0), cc.p(x, -50))
    parallaxNode:addChild(houseJinNode, 8, cc.p(1.2, 0), cc.p(x, 54 - 50))
    parallaxNode:addChild(treeNode, 9, cc.p(1.4, 0), cc.p(x, -50))
  
    --将parallaxNode加入scrollView中
    scrollView:addChild(parallaxNode, 10)
--    scrollView:jumpToRight()
    
    ------------------视差节点ParallaxNode end -------------------------
    
    local ANI_PATH = "csb/texiao/ui/"
    g_AnimationList = {}
    g_AnimationList[1] = CreateAnimationObject(480, 250, "csb/texiao/ui/T_u_ziti_goumai.csb")
    g_AnimationList[2] = CreateAnimationObject(480, 260, "csb/texiao/ui/T_u_ziti_renwu.csb")
    g_AnimationList[3] = CreateAnimationObject(83,21,"csb/texiao/ui/T_u_RW_lingqu.csb")
    g_AnimationList[4] = CreateAnimationObject(83,21,"csb/texiao/ui/T_u_keji_luzi_1.csb")
    

    CreateAnimation(skyNode, 0, -190, ANI_PATH.."T_u_zhujiemian_yun.csb", "animation0", true, 0, 0.3)
    self._GroundNode = seekNodeByName(landNode, "Sprite_LuDi_0")
    self._GroundNode:setSwallowTouches(false)
    CreateAnimation( self._RightBottomButtonList[13], 40, 40, ANI_PATH.."T_u_ZJM_zhandoukaishi.csb", "animation0", false, 10, 1, self.FrameEndCallBack)
--    CreateAnimation( self._RightBottomButtonList[14], 40, 40, ANI_PATH.."T_u_ZJM_gongchengluedi.csb", "animation0", false, 10, 1, self.FrameEndCallBack)
    self._RightBottomButtonList[14]:loadTextures("meishu/ui/zhujiemian/UI_ZJM_Icon/UI_zjm_gongcheng_01.png", "meishu/ui/zhujiemian/UI_ZJM_Icon/UI_zjm_gongcheng_01.png")
    self._FistOpen = false
    self._MoveNode_2 = self:GetUIByName("MoveNode_2")
    self._MoveNode = self:GetUIByName("MoveNode")
    
    --测试代码begin，给编辑器用
    local layer = self._RootUINode

    local function onKeyReleased(keyCode, event)
        if keyCode == cc.KeyCode.KEY_F1 then
            local game = GameGlobal:GetGameInstance()
            game:SetGameState(GameState.GameState_SkillEditor)
        elseif keyCode == cc.KeyCode.KEY_F2  then
            local CharacterServerDataManager = GameGlobal:GetCharacterServerDataManager()
            CharacterServerDataManager:BackupBeforeBuZhenEditor()
            UISystem:OpenUI(UIType.UIType_BuZhenEditor)
        elseif keyCode == cc.KeyCode.KEY_F4 then
            UISystem:OpenUI(UIType.UIType_WorldMapEditor)
        end
    end
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )

    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
end

function UIMaincity:CreateEffects()
    local size = self._SuoZhanBtnTask:getContentSize()
    self._CurTaskCircleBtnEffect = CreateAnimation(self._SuoZhanBtnTask, size.width / 2, size.height / 2 + 2, MAINCITY_CIRCLE_BTN_EFFECT, "animation0", true, 1, 1)

    local size = self._SuoZhanBtnHuoYue:getContentSize()
    self._CurActivenessCircleBtnEffect = CreateAnimation(self._SuoZhanBtnHuoYue, size.width / 2, size.height / 2 + 2, MAINCITY_CIRCLE_BTN_EFFECT, "animation0", true, 1, 1)

    local targetNode = seekNodeByName(self._TaskPanel, "Image_12")
    local size = targetNode:getContentSize()
    self._CurTaskTopTileEffect = CreateAnimation(targetNode, size.width / 2, size.height / 2, MAINCITY_TASK_ITEM_EFFECT, "animation0", true, 1, 1)

    local targetNode = seekNodeByName(self._HuoYuePanel, "Image_12")
    local size = targetNode:getContentSize()
    self._CurActivenessTopTileEffect = CreateAnimation(targetNode, size.width / 2, size.height / 2, MAINCITY_TASK_ITEM_EFFECT, "animation0", true, 1, 1)
end

function UIMaincity:ReleaseEffects()
    removeNodeAndRelease(self._CurTaskCircleBtnEffect)
    removeNodeAndRelease(self._CurActivenessCircleBtnEffect)
    removeNodeAndRelease(self._CurTaskTopTileEffect)
    removeNodeAndRelease(self._CurActivenessTopTileEffect)

    self._CurTaskCircleBtnEffect = nil
    self._CurActivenessCircleBtnEffect = nil
    self._CurTaskTopTileEffect = nil
    self._CurActivenessTopTileEffect = nil
end


function UIMaincity:FrameEndCallBack(frame)
    local time = math.random(1, 10)
    performWithDelay(self, self.ResetFramePaly, time)
    self._usedata:gotoFrameAndPause(self._usedata:getEndFrame())
    self._delay = time
end

function UIMaincity:ResetFramePaly()
    self._usedata:gotoFrameAndPlay(0, false)
    performWithDelay(self, self.FrameEndCallBack, self._delay)
end

function UIMaincity:InitWarrior()
    local WarriorManager = GameGlobal:GetDataTableManager():GetCharacterDataManager()
    local WarriorList = GameGlobal:GetCharacterServerDataManager()._LeaderIDList
    local SoldierList = GameGlobal:GetCharacterServerDataManager()._SoldierIDList
    math.randomseed(os.time())
    self._RunWarriorId = {}
    local wnum = #WarriorList >= 3 and 3 or #WarriorList
    for i = 1, wnum do
        local flip = 1
        if math.random(0, 1) == 0 then
            flip = -1
        end
    
        local y = i * 10 + 110
        local offx = math.random(150, 250)
        local x =  math.random(offx + 200 * i, 1900)
        local index = math.random(1, #WarriorList)
        while (self._RunWarriorId[WarriorList[index]]) do
            index = math.random(1, #WarriorList)
        end
        local people = CreateAnimation(self._GroundNode, x, y, GetWarriorCsbPath(WarriorManager[WarriorList[index]]["resName"]), "Walk", true, 180 - y, 1)
        people:setScaleX(flip)
        people._id = WarriorList[index]
        self._RunWarriorId[people._id] = 1
        local dis = x + offx
        if flip == 1 then
            dis = MoveDistance - x - offx
        end
        local snum = math.random(3, 5)
        local index = math.random(1, #SoldierList)
        for j = 1, snum do
            local solider = CreateAnimation(self._GroundNode, x + flip * -10 - flip * 30 * j, y, GetSoldierCsbPath(WarriorManager[SoldierList[index]]["resName"]), "Walk", true, 180 - y, 1)
            solider:setScaleX(flip)
            MoveStartAction(solider, self.RemoveWarriorCallBack, flip * -dis, WARRIORTIME * dis / MoveDistance, 0, 0, self) 
        end
        local normal = display.newSprite("meishu/ui/gg/null.png", 0, 0, {scale9 = true, capInsets = cc.rect(0, 0, 2, 2), rect = cc.rect(0, 0, 2, 2)})
        normal:setPreferredSize(cc.size(80, 80))
        
        MoveStartAction(people, self.ResetWarriorCallBack, flip * -dis, WARRIORTIME * dis / MoveDistance , 0, 0, self) 
    end 
end

function UIMaincity:RemoveWarriorCallBack(sender)
    sender:removeFromParent(true)
end

function UIMaincity:ResetWarriorCallBack(sender)
    local x = sender:getPositionX()
    local y = sender:getPositionY()
    local flip = 1
    local WarriorManager = GameGlobal:GetDataTableManager():GetCharacterDataManager()
    local WarriorList = GameGlobal:GetCharacterServerDataManager()._LeaderIDList
    local SoldierList = GameGlobal:GetCharacterServerDataManager()._SoldierIDList
    local index = math.random(1, #WarriorList)
    if x > 960 then
        flip = -1
    end
    local delay = math.random(0.5, 2.5)
    self._RunWarriorId[sender._id] = nil
    while (self._RunWarriorId[WarriorList[index]]) do
        index = math.random(1, #WarriorList)
    end
    
    local people = CreateAnimation(self._GroundNode, x, y, GetWarriorCsbPath(WarriorManager[WarriorList[index]]["resName"]), "Walk", true, 180 - y, 1)
    people:setScaleX(flip)
    people._id = WarriorList[index]
    self._RunWarriorId[WarriorList[index]] = 1
    MoveStartAction(people, self.ResetWarriorCallBack, flip * -MoveDistance, WARRIORTIME, 0, delay, self) 
    local snum = math.random(3, 5)
    local index = math.random(1, #SoldierList) 
    for j = 1, snum do
        local solider = CreateAnimation(self._GroundNode, x + flip * -10 - flip * 30 * j, y, GetSoldierCsbPath(WarriorManager[SoldierList[index]]["resName"]), "Walk", true, 180 - y, 1)
        solider:setScaleX(flip)
        MoveStartAction(solider, self.RemoveWarriorCallBack, flip * -MoveDistance, WARRIORTIME, 0, delay, self) 
    end
    
    local normal = display.newSprite("meishu/ui/gg/null.png", 0, 0, {scale9 = true, capInsets = cc.rect(0, 0, 2, 2), rect = cc.rect(0, 0, 2, 2)})
    normal:setPreferredSize(cc.size(80, 80))
    sender:removeFromParent(true)
end

function UIMaincity:InitNpc()
    math.randomseed(os.time())
    local num = math.random(3, 5)
    self._NpcNum = num
    for i = 1, num do
        local flip = 1  
        if math.random(0, 1) == 0 then
            flip = -1
        end
        local y = (i % 2) * 10 + 100
        local offx = math.random(50, 150)
        local x =  math.random(offx + 150 * i, 1900)
        local index = math.random(1, 8)
        local dis = x + offx
        if flip == 1 then
            dis = MoveDistance - x - offx
        end
        local normal = display.newSprite("meishu/ui/gg/null.png.png", 0, 0, {scale9 = true, capInsets = cc.rect(0, 0, 2, 2), rect = cc.rect(0, 0, 2, 2)})
        normal:setPreferredSize(cc.size(80, 80))
        local btn = CreateButton(self._GroundNode, x, y, index, normal, normal, handler(self, self.TouchNpc), 2, 220 - y)
        
        local people = CreateAnimation(btn, 50, 40, GameGlobal:GetNpcDataManager()[index]["csb"], "Walk", true, 1, 1)
        people:setScaleX(flip)
        people:setTag(11)
        MoveStartAction(btn, self.ResetNpcCallBack, flip * -1 * dis, NPCTIME[index] * dis / MoveDistance, 0, 0, self) 
        
    end 
end

function UIMaincity:ResetNpcCallBack(sender)
    local num = math.random(1, 2)
    local x = sender:getPositionX()
    local y = sender:getPositionY()
    local flip = 1
    if self._NpcNum > NPCMAX then
        num = 0
    end
    for i = 1, num do
        local index = math.random(1, 8)
        local delay = math.random(i, 5)
        if x > 960 then
            flip = -1
        end
        
        local normal = display.newSprite("meishu/ui/gg/null.png.png", 0, 0, {scale9 = true, capInsets = cc.rect(0, 0, 2, 2), rect = cc.rect(0, 0, 2, 2)})
        normal:setPreferredSize(cc.size(80, 80))
        local btn = CreateButton(self._GroundNode, x, y, index, normal, normal, handler(self, self.TouchNpc), 2, 220 - y)
        
        local people = CreateAnimation(btn, 50, 40, GameGlobal:GetNpcDataManager()[index]["csb"], "Walk", true, 1, 1)
        people:setTag(11)
        people:setScaleX(flip)
        MoveStartAction(btn, self.ResetNpcCallBack, flip * -MoveDistance, NPCTIME[index], 0, delay, self) 
    end
    self._NpcNum = self._NpcNum + num 
    self._NpcNum = self._NpcNum - 1 
    sender:removeFromParent(true)
end

function UIMaincity:TouchNpc(_, btn)
    local flip = btn:getChildByTag(11):getScaleX()
    local tag = btn:getTag()
    if tag ~= 6 then
        btn:getChildByTag(11)._usedata:play("Attack", true)
    end
    
    if tonumber(GameGlobal:GetNpcDataManager()[tag]["isdia"]) == 1 and btn._usedata == nil then
        btn:pause()
        performWithDelay(btn:getChildByTag(11), self.ResumeCallBack,  tonumber(GameGlobal:GetNpcDataManager()[tag]["time"])/1000)
        local diag = SplitSet2(GameGlobal:GetNpcDataManager()[tag]["dia"])
        local aniNode = CreateAnimation(btn, -480, -200, "csb/texiao/ui/T_u_zhujiemianxiaoren.csb", "anim", false, 1, 1)
        aniNode:setScale(1)
        local talk = cc.Label:createWithTTF("", FONT_SIMHEI, 12)
        --talk:setScale(0.65)
        talk:setPosition(cc.p(500 , 295))
        talk:setDimensions(98, 60)
        talk:setString(diag[math.random(1, #diag)])
        talk:setAnchorPoint(cc.p(0, 0.5))
        talk:setColor(cc.c3b(0, 0, 0))
        aniNode:addChild(talk, 1000)
        performWithDelay(aniNode, handler(self, self.RemoveWarriorCallBack), GameGlobal:GetNpcDataManager()[tag]["time"]/1000)
        btn._usedata = 1
    end
end

function UIMaincity:ResumeCallBack()
    self:getParent():resume()
    self._usedata:play("Walk", true)
    self:getParent()._usedata = nil
end

function UIMaincity:MoveCallBack(_IsShowBottom)
    if not _IsShowBottom then
        --多个动画-回弹效果
        MoveStartAction(self._MoveNode_2, self.MoveBackCallBack, -10, 0.1, 1, 0, self)
        MoveStartAction(self._MoveNode_2, self.MoveBackCallBack, 110, 0.1, 1, 0.1, self)
        MoveStartAction(self._MoveNode_2, self.MoveBackCallBack, -10, 0.1, 1, 0.2, self)
    else
        MoveStartAction(self._MoveNode_2, self.MoveBackCallBack, 10, 0.1, 1, 0, self)
        MoveStartAction(self._MoveNode_2, self.MoveBackCallBack, -110, 0.1, 1, 0.1, self)
        MoveStartAction(self._MoveNode_2, self.MoveBackCallBack, 10, 0.1, 1, 0.2, self)
    end
end

function UIMaincity:MoveBackCallBack()
    
end

--卸载
function UIMaincity:Unload()
    UIBase.Unload(self)
--    self._NameLabel = nil
--    self._CopperCoinLabel = nil
--    self._YuanBaoLabel = nil
--    self._BattleValueLabel = nil
--    self._ShengWangLabel = nil
--    self._TouXiangImage = nil
--    self._LevelLabel = nil
    for i = 1 , RIGHT_BOTTOM_BUTTON_NUMBER do
        if self._RightBottomButtonList[i] ~= nil then
            self._RightBottomButtonList[i] = nil
        end
    end
    
    for i = 1 , RIGHT_TOP_BUTTON_NUMBER do
        if self._RightTopButtonList[i] ~= nil then
            self._RightTopButtonList[i] = nil
        end
    end
end

--打开UI
function UIMaincity:Open()
    UIBase.Open(self)
    PlayMusic(Sound_10, true)
    PlaySound(Sound_11, true)
    self:RefreshLeftTopInfo()
    
    -- 创建特效
    self:CreateEffects()
    performWithDelay(self._RootPanelNode, self.OpenBottomList, 0)
    self:addEvent(GameEvent.GameEvent_MainCity_Notify, self.OpenUISucceed)
    self:addEvent(GameEvent.GameEvent_MyselfInfoChange, self.OnInfoChange)
    self:addEvent(GameEvent.GameEvent_CommonTest, self.OnTest)
end

function UIMaincity:OpenBottomList()
    UISystem:OpenUI(UIType.UIType_BottomList)
end

--关闭UI
function UIMaincity:Close()
    UIBase.Close(self)
    --移除特效
    self:ReleaseEffects()
    
    self._FistOpen = false
    self._GroundNode:removeAllChildren(true)
end

function UIMaincity:OpenUISucceed()
    if not self._FistOpen then
        self._FistOpen = true
        self:InitNpc()
        self:InitWarrior()
    end
    --找一主线任务并显示
    local TaskDataManager = GameGlobal:GetTaskDataManager()
    local taskList = GetGlobalData()._TaskData
    for i = 1, #taskList do
        if tonumber(TaskDataManager[taskList[i][1]]["type"]) == 2 then
            self._MainTaskText:setString(TaskDataManager[taskList[i][1]]["name"])
        end
    end
end

--------------------------------------------------所有UI必须实现的四个接口，且必须放在最前面  end -------------------------------------------------------
--刷新左上角玩家信息
function UIMaincity:RefreshLeftTopInfo()
    local myselfData = GamePlayerDataManager:GetMyselfData()
    if myselfData ~= nil then
        if self._CurrentCustom ~= nil and myselfData._MaxLevel ~= nil then
            self._CurrentCustom:setString("第"..myselfData._MaxLevel.."关")
        end
    end
   
end


-- 右下角Button点击处理
function UIMaincity:OnMaincityRightBottomButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if sender ~= nil then
            local tag = sender:getTag()
            -- 征战点击
            if tag == RIGHT_BOTTOM_BUTTON_TYPE.RIGHT_BOTTOM_BUTTON_ZHENGZHAN then
                --temp
                local myselfData = GamePlayerDataManager:GetMyselfData()
                
                if myselfData._Energy > 0 then  --判断军令数量
                    self:EnterBattle()
                elseif GameGlobal:GetItemDataManager():GetItemCount(30019) >= math.floor(GetPlayer()._NeedHuFuTimes / GameGlobal:GetParameterDataManager()["tiger_times"].value) + 1 then
                    UISystem:OpenUI(UIType.UIType_UseHuFu)
                    UISystem:GetUIInstance(UIType.UIType_UseHuFu):SetBattleType(false, GetPlayer()._MaxLevel)
                else --购买虎符
                    UISystem:OpenUI(UIType.UIType_BuyItem)
                    local uiInstance = UISystem:GetUIInstance(UIType.UIType_BuyItem)
                    local num = math.floor(GetPlayer()._NeedHuFuTimes / GameGlobal:GetParameterDataManager()["tiger_times"].value) + 1 - GameGlobal:GetItemDataManager():GetItemCount(30019)
                    uiInstance:OpenItemInfoNotifiaction(HuFu, num)
                end
            -- 关卡地图
            elseif tag == RIGHT_BOTTOM_BUTTON_TYPE.RIGHT_BOTTOM_BUTTON_CUSTOM then
                UISystem:CloseAllUI()
                UISystem:OpenUI(UIType.UIType_CustomMap)
            elseif tag == RIGHT_BOTTOM_BUTTON_TYPE.BUTTON_HEROTOP then
                UISystem:OpenUI(UIType.UIType_HeroTop)
                SendMsg(PacketDefine.PacketDefine_SoldierRankingList_Send, {1, 100})
            elseif tag == RIGHT_BOTTOM_BUTTON_TYPE.BUTTON_TuJian then --图鉴
                CreateTipAction(self._RootUINode, TIPSMESSAGE, cc.p(480, 270))
            elseif tag == RIGHT_BOTTOM_BUTTON_TYPE.BUTTON_WangGong then --王宫
                CreateTipAction(self._RootUINode, TIPSMESSAGE, cc.p(480, 270))
            elseif tag == RIGHT_BOTTOM_BUTTON_TYPE.BUTTON_JiShouHang then --寄售行
                CreateTipAction(self._RootUINode, TIPSMESSAGE, cc.p(480, 270))
            elseif tag == RIGHT_BOTTOM_BUTTON_TYPE.RIGHT_BOTTOM_BUTTON_GCLD then
                UISystem:CloseAllUI()
                UISystem:OpenUI(UIType.UIType_WorldMap)
                UISystem:OpenUI(UIType.UIType_BottomList)
           --聊天
           elseif tag == RIGHT_BOTTOM_BUTTON_TYPE.Button_RightBottom_Talk then
               UISystem:OpenUI(UIType.UIType_TalkUI)
           end
         end
    end
end

function UIMaincity:OnMaincityLeftBottomButtonClick(sender, eventType)
     if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
        if tag == LEFT_BOTTOM_BUTTON_TYPE.LEFT_BOTTOM_BUTTON_HUOYUE then
            CreateTipAction(self._RootUINode, TIPSMESSAGE, cc.p(480, 270))
            --UISystem:OpenUI(UIType.UIType_EveryTask)
        elseif tag == LEFT_BOTTOM_BUTTON_TYPE.LEFT_BOTTOM_BUTTON_TASK then
            UISystem:OpenUI(UIType.UIType_Task)
        --主线任务缩展
        elseif tag == 1 then
            self._TaskPanel:setVisible(true)
            self._SuoZhanBtnTask:setTouchEnabled(false)
            --收缩状态
            if self._TaskPanel:getPositionX() < -50 then
                MoveStartAction(self._TaskPanel, self.TaskHuoMoveCallBack, -130, 0.1, 0, 0, self)
                MoveStartAction(self._SuoZhanBtnTask, self.MoveCallBackNull, -130, 0.1, 0, 0, self)
            --展开状态
            else
                MoveStartAction(self._TaskPanel, self.TaskHuoMoveCallBack, 130, 0.1, 0, 0, self)
                MoveStartAction(self._SuoZhanBtnTask, self.MoveCallBackNull, 130, 0.1, 0, 0, self)
            end
        --活跃缩展
        elseif tag == 2 then
            self._HuoYuePanel:setVisible(true)
            self._SuoZhanBtnHuoYue:setTouchEnabled(false)
            --收缩状态
            if self._HuoYuePanel:getPositionX() < -50 then
                MoveStartAction(self._HuoYuePanel, self.TaskHuoMoveCallBack, -130, 0.1, 0, 0, self)
                MoveStartAction(self._SuoZhanBtnHuoYue, self.MoveCallBackNull, -130, 0.1, 0, 0, self)
                --展开状态
            else
                MoveStartAction(self._HuoYuePanel, self.TaskHuoMoveCallBack, 130, 0.1, 0, 0, self)
                MoveStartAction(self._SuoZhanBtnHuoYue, self.MoveCallBackNull, 130, 0.1, 0, 0, self)
            end
        end
     end
end

function UIMaincity:TaskHuoMoveCallBack()
    --print("TaskPanel2 positionX", self._TaskPanel2:getPositionX())
    self._SuoZhanBtnTask:setTouchEnabled(true)
    --收缩状态
    if self._TaskPanel:getPositionX() < -50 then
        self._TaskPanel:setVisible(false)
        self._SuoZhanBtnTask:loadTextures("meishu/ui/zhujiemian/UI_zjm_jiantou02_01.png", "meishu/ui/zhujiemian/UI_zjm_jiantou02_02.png", UI_TEX_TYPE_LOCAL)
    --展开状态
    else
        self._SuoZhanBtnTask:loadTextures("meishu/ui/zhujiemian/UI_zjm_jiantou01_01.png", "meishu/ui/zhujiemian/UI_zjm_jiantou01_02.png", UI_TEX_TYPE_LOCAL)
    end
    
    self._SuoZhanBtnHuoYue:setTouchEnabled(true)
    --收缩状态
    if self._HuoYuePanel:getPositionX() < -50 then
        self._HuoYuePanel:setVisible(false)
        self._SuoZhanBtnHuoYue:loadTextures("meishu/ui/zhujiemian/UI_zjm_jiantou02_01.png", "meishu/ui/zhujiemian/UI_zjm_jiantou02_02.png", UI_TEX_TYPE_LOCAL)
    --展开状态
    else
        self._SuoZhanBtnHuoYue:loadTextures("meishu/ui/zhujiemian/UI_zjm_jiantou01_01.png", "meishu/ui/zhujiemian/UI_zjm_jiantou01_02.png", UI_TEX_TYPE_LOCAL)
    end
end

function UIMaincity:MoveCallBackNull()
end

function UIMaincity:OnMaincityRightTopButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
        if tag == RIGHT_TOP_BUTTON_TYPE.RIGHT_TOP_BUTTON_RICHANG then
            CreateTipAction(self._RootUINode, TIPSMESSAGE, cc.p(480, 270))
  --        UISystem:OpenUI(UIType.UIType_UIActivity)
        elseif tag == RIGHT_TOP_BUTTON_TYPE.RIGHT_TOP_BUTTON_ChENGZHANG then
            UISystem:OpenUI(UIType.UIType_VipUI)
        elseif tag == RIGHT_TOP_BUTTON_TYPE.LEFT_TOP_BUTTON_RECHARGE then
            UISystem:OpenUI(UIType.UIRecharge)
        elseif tag == RIGHT_TOP_BUTTON_TYPE.RIGHT_TOP_BUTTON_STORE then
            UISystem:OpenUI(UIType.UIType_StoreUI)
        end
    end
end

function UIMaincity:DelayCallBack()
    local myselfData = GamePlayerDataManager:GetMyselfData()
    DispatchEvent(GameEvent.GameEvent_UIUseHuFu_Succeed, myselfData._MaxLevel)
end
--进入战斗
function UIMaincity:EnterBattle()
    local myselfData = GamePlayerDataManager:GetMyselfData()
    SendMsg(PacketDefine.PacketDefine_Stage_Send, {GameGlobal:GetCustomDataManager()[myselfData._MaxLevel]["id"]})
    GameGlobal:GetUISystem():OpenUI(UIType.UIType_BattleUI, myselfData._MaxLevel)
end

--沙场点兵点击
function UIMaincity:OnShaChangClick(sender, eventType)
    if type(eventType) == "table" then
        eventType = eventType["eventType"]
    end
    if eventType == ccui.TouchEventType.ended then
        --条件判定，当前通关的最大关卡
        local myselfData = GamePlayerDataManager:GetMyselfData()
        if myselfData._MaxLevel <= 10 then
            
        end
        --UI 
        UISystem:OpenUI(UIType.UIType_ShaChangDianBing)

        --发包
        SendMsg(PacketDefine.PacketDefine_ArenaList_Send)
    end
end
--官邸点击
function UIMaincity:OnGuanDiClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then

    end
end

--公告滚屏函数
function UIMaincity:GongGaoGunPing()
    local talkData = TalkDataManager:GetTalkDataManager()
    if (talkData._NewestSystemInfoIndex + 1) <= #talkData._SystemList then
        talkData._NewestSystemInfoIndex = talkData._NewestSystemInfoIndex + 1
        self:GongGaoAction()
    end
end

--公告滚动
function UIMaincity:GongGaoAction()
    self._GongGaoPanel:setVisible(true)
    local talkData = TalkDataManager:GetTalkDataManager()

    local textShow = ""
    local richTextWidth = 0
    local richText = ccui.RichText:create()
    --    richText:ignoreContentAdaptWithSize(false)  
    if talkData._SystemList[talkData._NewestSystemInfoIndex].type == 3 then
        textShow = talkData._SystemList[talkData._NewestSystemInfoIndex].text
        richTextWidth = CalculateStringWidth(textShow, 14)
        local re1 = ccui.RichElementText:create( 1, cc.c3b(255,79,77), 255, textShow, "fonts/SIMHEI.TTF", 14 )     
        richText:pushBackElement(re1)
    else
        for i = 1, 10 do
            local flagText = "text" .. i
            if talkData._SystemList[talkData._NewestSystemInfoIndex][flagText] ~= nil then
                textShow = textShow .. talkData._SystemList[talkData._NewestSystemInfoIndex][flagText]
                local flagText1 = "re" .. i
                local color = nil
                if i == 1 then
                    color = cc.c3b(255, 255, 255)
                elseif i == 2 then
                    color = cc.c3b(50, 161, 255)
                elseif i == 3 then
                    color = cc.c3b(255, 255, 255)
                elseif i == 4 then
                    color = cc.c3b(151, 104, 200)
                end
                flagText1 = ccui.RichElementText:create( 1, color, 255, talkData._SystemList[talkData._NewestSystemInfoIndex][flagText], "fonts/SIMHEI.TTF", 14 )     
                richText:pushBackElement(flagText1)
            else
                richTextWidth = CalculateStringWidth(textShow, 14)
                break
            end
        end
    end
    richText:setAnchorPoint(cc.p(0.5, 0.5))
    richText:setPosition(richTextWidth / 2, self._GongGaoPanel:getContentSize().height / 2)
    self._GongGaoPanel:addChild(richText, 100)
    self._GongGaoPanel:setContentSize(cc.size(richTextWidth, self._GongGaoPanel:getContentSize().height))
    --公告的移动速度
    local speedGongGao = 50
    local time = richTextWidth / speedGongGao
    transition.moveBy(richText, {x = -richTextWidth, y = 0, time = time, delay = 3, removeSelf = true})
    local delay = cc.DelayTime:create(time + 3)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(function()
        self._GongGaoPanel:setVisible(false)
        self:GongGaoGunPing() 
    end))
    self._RootPanelNode:runAction(sequence)
end
------------------------------------逻辑事件处理------------------------------------

--信息改变的回调
function UIMaincity.OnInfoChange(event)
    local maincityUI = UISystem:GetUIInstance(UIType.UIType_MaincityUI)
    if maincityUI ~= nil then
        maincityUI:RefreshLeftTopInfo()
    end
end
--测试
function UIMaincity.OnTest(event)
    local maincityUI = UISystem:GetUIInstance(UIType.UIType_MaincityUI)
    if maincityUI ~= nil then
        local levelID = event._usedata.levelID
        if levelID ~= nil then
            maincityUI._TestLevelID =  levelID
        end
    end
end

return UIMaincity