----
-- 文件名称：UIBattle
-- 功能描述：战斗场景的UI
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-4-21
-- 修改 ：
--  当前UI动态资源：战斗结果图片：res\demoArt\UI\battleUI_Result_Lose.png   res\demoArt\UI\battleUI_Result_Win.png
--动画csb "texiao/ui/T_u_zhandoushengli.csb"
--
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
require("cocos.ui.GuiConstants")
require("main.Utility.ChineseConvert")
local CharacterServerDataManager = require("main.ServerData.CharacterServerDataManager")
local CharacterManager = require("main.Logic.CharacterManager")
local stringFormat = string.format
local UISystem = require("main.UI.UISystem")
local GameBattle = require("main.Game.GameBattle")
local GameLevelLua = require("main.Logic.GameLevel")
local CharacterDataManager = GetCharacterDataManager()
local shareDirector = cc.Director:getInstance()
local mathCeil = math.ceil
local GuoZhanServerDataManager = GameGlobal:GetGuoZhanServerDataManager()
local battleWinCSBName = "csb/texiao/ui/T_u_zhandoushengli.csb"
local battleLoseCSBName = "csb/texiao/ui/T_u_zhandoushibai.csb"
local battleStartCSBName = "csb/texiao/ui/T_u_zhandoukaishi.csb"
local countOnePage = 6
local leftBottomPositionX = 0
local leftBottomPositionY = 0
local rightTopPositionX = 0
local rightTopPositionY = 0
local smallMapWidth = 0
local smallMapHeight = 0

-- 拖拽的红框大小
local dragSmallMapWidth = 400
local dragSmallMapHeight = 200

-- 武将UI信息
local WuJiangUIInfo = class("WuJiangUIInfo")
function WuJiangUIInfo:ctor()
  
end

-- 士兵UI信息
local SoldierUIInfo = class("SoldierUIInfo")
function SoldierUIInfo:ctor()
    -- 士兵tableID
    self._SoldierTableID = -1
    -- 士兵选中的特效节点
    self._SoldierSelectedNode = 0
    -- 士兵选中的特效动画
    self._SoldierSelectAnim = 0
end


local gtouchsMovedStart = {}
local gstartlen
local gIsTouchs = false 
local gActionEnd = false 

local UIBattle = class("UIBattle", UIBase)

-- 构造
function UIBattle:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_BattleUI
    self._ResourceName =  "UIBattleTest.csb"
end

function onNodeEvent(event, touchs)
    if event=="began" then 
        if touchs[3] == 0 then
            gtouchsMovedStart[1] = touchs
        elseif touchs[3] == 1 then
            gIsTouchs = true 
            gtouchsMovedStart[2] = touchs 
            local x, y, id = gtouchsMovedStart[1][1],gtouchsMovedStart[1][2],gtouchsMovedStart[1][3]
            local x1, y1, id1 = gtouchsMovedStart[2][1],gtouchsMovedStart[2][2],gtouchsMovedStart[2][3]
            gstartlen = math.pow(math.abs((x - x1)), 2) + math.pow(math.abs((y - y1)), 2)
        end
    elseif event=="moved" then 
        if not gIsTouchs or #touchs<=3 then
            return
        end

        local x, y = touchs[1],touchs[2]
        local x1, y1 = touchs[4],touchs[5]
        local endLen = math.pow((x - x1), 2) + math.pow((y - y1), 2)
        local offscale = endLen / gstartlen - 1
        
        if math.abs(endLen - gstartlen) < 60 then
            offscale = 0
        end
        local scaletmp = GameBattle:GetGameLevel():GetRootNode():getScale() + offscale
        if scaletmp >= 2 then 
            scaletmp = 2
        elseif scaletmp <= 0.67 then
            scaletmp = 0.67
        end
        gstartlen = endLen
       
        GameBattle:GetGameLevel():UpdateX(scaletmp)
        GameBattle:GetGameLevel():GetRootNode():setScale(scaletmp)
       
    elseif event=="ended" then 
        gstartlen = 0
        gtouchsMovedStart = {}
        gIsTouchs = false
    end
end

-- 加载
function UIBattle:Load()
    UIBase.Load(self)
    -- 控件列表
    self._checkBoxList = {}
    -- 头像列表
    self._headImageList = {}
    
    self._currentSkillZoneType = 0
    -- 武将UI信息列表
    self._wuJiangUIInfoList = {}
    -- 小兵UI信息列表
    self._soldierUIInfoList = {}

    self._pvpBtnList = {}
    
    self._UIAnim = cc.CSLoader:createTimeline(self._RealResourceName)
    self._UIAnim:retain()
    self._WuJiangScrollView = self:GetUIByName("WuJiangScrollview")
    self._XiaoBingListView = self:GetUIByName("ListView_XiaoBing")
    self._XiaoBingListView:setScrollBarWidth(0)
    self._WuJiangScrollView:setScrollBarEnabled(false)

    self._SmallMapLeftBottom = self:GetUIByName("Node_SmallMapLeftBottom")
    self._SmallMapRightTop = self:GetUIByName("Node_SmallMapRightTop")
    -- 空白Panel触发事件 
    self._BlankPanel = self:GetUIByName("BlankPanel")
    self._RootPanelNode:setSwallowTouches(true) 
    self._BlankPanel:setTouchEnabled(true)
    self._BlankPanel:addTouchEventListener(OnBlankPanelClicked)
    self._XiaoBingListView:addEventListener(self.OnXiaoBingListView)
    
    self._RoundLabel = self:GetUIByName("RoundLabel")
    self._SelfHPProgressBar = self:GetUIByName("HP_SelfHome")
    self._EnemyProgressBar = self:GetUIByName("HP_EnemyHome")
    self._SelfHomeHPLabel = self:GetUIByName("SelfHomeHP")
    self._EnemyHomeHPLabel = self:GetUIByName("EnemyHomeHP")
    self._TimerLabel = self:GetUIByName("BMPLabel_Timer")
    self._LeftTopPeopleLabel = self:GetUIByName("PeopleCountLabel")
    self._BattleResultImage = self:GetUIByName("BattleResultImage")
    local rightBottomPanel = self:GetUIByName("Panel_RightBottom")
    self._LeftArrowButton = seekNodeByName(rightBottomPanel, "Button_LeftArrow")
    self._RightArrowButton = seekNodeByName(rightBottomPanel, "Button_RightArrow")
    self._LeftTopPVEPanel = self:GetUIByName("Panel_LeftTop_PVE")
    self._LeftTopPVPPanel = self:GetUIByName("Panel_LeftTop_PVP")
    self._RightTopPVEPanel = self:GetUIByName("Panel_RightTop_PVE")
    self._RightTopPVPPanel = self:GetUIByName("Panel_RightTop_PVP")
    self._RightBottomPVEPanel = self:GetUIByName("Panel_RightBottom_PVE")
    self._RightBottomPVPPanel = self:GetUIByName("Panel_RightBottom_PVP")
    self._DanJinLiangJueImage = self:GetUIByName("Image_DanJinLiangJue")
    self._LeftGuoZhanTeamPanel = self:GetUIByName("Panel_LeftMiddlePVP")
    self._RightGuoZhanTeamPanel = self:GetUIByName("Panel_RightMiddlePVP")
    self._TopCenterInfoPanel = self:GetUIByName("Panel_TopCenter_Info")
    self._TopCenterTime = seekNodeByName(self._TopCenterInfoPanel, "Time")
    self._TopCenterFlag = seekNodeByName(self._TopCenterInfoPanel, "Image_2")
    
    self._LeftGuoZhanPlayerListPanel = seekNodeByName(self._LeftGuoZhanTeamPanel,"Panel_LeftBg")
    self._RightGuoZhanPlayerListPanel = seekNodeByName(self._RightGuoZhanTeamPanel,"Panel_LeftBg")
    
    self._GridView1 =  CreateTableView_(8, 5, 220, 210, cc.TABLEVIEW_FILL_BOTTOMUP, self)
    self._LeftGuoZhanPlayerListPanel:addChild(self._GridView1)
    self._GridView2 =  CreateTableView_(8, 5, 220, 210, cc.TABLEVIEW_FILL_BOTTOMUP, self)
    self._RightGuoZhanPlayerListPanel:addChild(self._GridView2)
    self._GridView1:setTag(1)
    self._GridView2:setTag(2)

    local teamArrowButton = seekNodeByName(self._LeftGuoZhanTeamPanel, "Button_Team") 
    local teamArrowBg = seekNodeByName(self._LeftGuoZhanTeamPanel, "Image_LeftMiddle_Team")
    local teamArrowRightButton = seekNodeByName(self._RightGuoZhanTeamPanel, "Button_Team") 
    local teamArrowRightBg = seekNodeByName(self._RightGuoZhanTeamPanel, "Image_LeftMiddle_Team")
    -- Tag: 1为左   2为右
    teamArrowButton:setTag(1)
    teamArrowButton:addTouchEventListener(handler(self, UIBattle.onTeamArrowClick))
    teamArrowBg:setTag(1)
    teamArrowBg:setTouchEnabled(true)
    teamArrowBg:addTouchEventListener(handler(self, UIBattle.onTeamArrowClick))
    
    teamArrowRightButton:setTag(2)
    teamArrowRightButton:addTouchEventListener(handler(self, UIBattle.onTeamArrowClick))
    
    teamArrowRightBg:setTag(2)
    teamArrowRightBg:setTouchEnabled(true)
    teamArrowRightBg:addTouchEventListener(handler(self, UIBattle.onTeamArrowClick))
 
    for i = 5, 9 do
        self._pvpBtnList[i] = seekNodeByName(self._RightBottomPVPPanel,"Button_"..i)
        self._pvpBtnList[i]:setTag(i)
        self._pvpBtnList[i]:addTouchEventListener(handler(self, self.PvpToucnClicked))
    end
   
    self._returnPVPButton =  self:GetUIByName("Button_ReturnPVP")
    local quitButton = self:GetUIByName("Button_Quit")
    quitButton:addTouchEventListener(handler(self, UIBattle.OnQuitClicked))
    self._returnPVPButton:addTouchEventListener(handler(self, UIBattle.OnQuickQuitClicked))
    self._BlankPanel:setSwallowTouches(false)
    self._RootPanelNode:setSwallowTouches(false)
    local layer=display.newLayer(cc.c3b(0,0,0)) 
    layer:setOpacity(0)
    layer:setTouchMode(cc.TOUCHES_ALL_AT_ONCE) 
    layer:setTouchEnabled(true) 
    layer:registerScriptTouchHandler(onNodeEvent, true)
    self._BlankPanel:addChild(layer, 1)
    if self._PVESmallMapDrawNode == nil then
        self._PVESmallMapDrawNode = cc.DrawNode:create()
        if self._PVESmallMapTouchPanel ~= nil then
            self._PVESmallMapTouchPanel:addChild(self._PVESmallMapDrawNode)
        end
        self._PVESmallMapDrawNode:setVisible(false)
        self._PVESmallMapDrawNode:drawRect(cc.p(0, 0), cc.p(dragSmallMapWidth, dragSmallMapHeight), cc.c4f(1,0,0,1))
    end
end

-- 卸载
function UIBattle:Unload()
    UIBase.Unload(self)
    removeNodeAndRelease(self._UIAnim, true)
    self._checkBoxList = nil
    self._headImageList = nil
    self._BlankPanel = nil
    self._SelfHomeHPLabel = nil
    self._EnemyHomeHPLabel = nil
    self._LeftTopPeopleLabel = nil
    self._BattleResultImage = nil
    self._SkillAnimSpriteList = nil
    self._SkillProgressBarList = nil
    self._LeftTopPVEPanel = nil
    self._LeftTopPVPPanel = nil
    self._RightBottomPVEPanel = nil
    self._RightBottomPVPPanel = nil
    self._RightTopPVEPanel = nil
    self._RightTopPVPPanel = nil
end

-- 打开UI
function UIBattle:Open(levelTableID)
    UIBase.Open(self)
    
    -- 创建战斗关卡
    if levelTableID == -2 then
        local GameLevelPVP = require("main.Logic.GameLevelPVP")
        self._CurrentNewLevel = GameLevelPVP.Create(levelTableID, true)
        self._CurrentNewLevel:Init()
    elseif levelTableID == -1 then
        local GameLevelPVP = require("main.Logic.GameLevelPVP")
        self._CurrentNewLevel = GameLevelPVP.Create(levelTableID, true)
        self._CurrentNewLevel:Init()
    else
        self._CurrentNewLevel = GameLevel.Create(levelTableID)
        self._CurrentNewLevel:Init()
    end
    
    gGameLevel = self._CurrentNewLevel

    local rootLevelNode = self._CurrentNewLevel:GetRootNode()
    self._RootUINode:addChild(rootLevelNode, -1)
    self._CurrentNewLevel:FixLevelPosition()
    
    self._CurrentClickedLeaderTableID = -1
    self._checkBoxList = {}
    self._SkillAnimSpriteList = {}
    self._SkillProgressBarList = {}
    self._SkillZoneNodeList = {}
    self._SkillZoneNodeAnimList = {}
    self._headImageList = {}
    self:RefreshWuJiangInfo()
    self:RefreshXiaoBingInfo()
    
    -- UI事件响应
    -- 注册响应函数
    for k, v in pairs(self._checkBoxList)do 
        v:addEventListener(handler(self, self.SelectedStateEvent))
    end
    for k, v in pairs(self._headImageList)do
        v:addTouchEventListener(handler(self, self.OnImageViewClicked))
    end
 
    -- UI表现初始化
    self._SelfHPProgressBar:setPercent(100)
    self._EnemyProgressBar:setPercent(100)
    self._LeftTopPVEPanel:setVisible(false)
    local showRoundStr = stringFormat(ChineseConvert["UIBattleText_Round"], 1)
    self._RoundLabel:setString(showRoundStr)
    local showRoundStr = stringFormat("%d", 3)
    self._TimerLabel:setString(showRoundStr)
    
    local currentLevel =  GameGlobal:GetGameLevel()
    if currentLevel ~= nil then
        local topCenterPanel = self:GetUIByName("Panel_TopCenter")
        topCenterPanel:setScale(1)
        self._RightBottomPVPPanel:setVisible(false)
        if self._DanJinLiangJueImage ~= nil then
            self._DanJinLiangJueImage:setVisible(false)
        end
        if currentLevel._LevelLogicType == LevelLogicType.LevelLogicType_PVE then
            if TEST_AUTO_BATTLE == true then
                self:AutoBattle()
            end
            self._LeftTopPVEPanel:setVisible(true)
            self._RightBottomPVEPanel:setVisible(true)
            self._LeftGuoZhanTeamPanel:setVisible(false)
            self._RightGuoZhanTeamPanel:setVisible(false)
            self._TopCenterTime:setVisible(false)
            self._TopCenterFlag:setVisible(false)
            self._TimerLabel:setVisible(true)
            self._RoundLabel:setVisible(true)
            self._LeftTopPVPPanel:setVisible(false)
            self._LeftTopPeopleLabel:setString("0")
            self._RightTopPVEPanel:setVisible(true)
            self._RightTopPVPPanel:setVisible(false)
            
            if  currentLevel._SelfBattleBuildingID ~= nil then
                local building = CharacterManager:GetCharacterByClientID(currentLevel._SelfBattleBuildingID)
                if building ~= nil then
                    local totalHP = building._TotalHP
                    self._SelfHomeHPLabel:setString("")
                end
            end
            if currentLevel._EnemyBattleBuildingID ~= nil then
                local building = CharacterManager:GetCharacterByClientID(currentLevel._EnemyBattleBuildingID)
                if building ~= nil then
                    local totalHP = building._TotalHP
                    self._EnemyHomeHPLabel:setString("")
                end
            end
            self._WuJiangScrollView:setVisible(true)
            self._XiaoBingListView:setVisible(true)
        elseif currentLevel._LevelLogicType == LevelLogicType.LevelLogicType_PVE_PVP
             or currentLevel._LevelLogicType == LevelLogicType.LevelLogicType_PVP then
            if  self._RightTopPVEPanel ~= nil then
                self._RightTopPVEPanel:setVisible(false)
            end
            if  self._RightTopPVEPanel ~= nil then
                self._RightTopPVEPanel:setVisible(true)
            end
            
            self._RightTopPVPPanel:setVisible(true)
            self._LeftTopPVPPanel:setVisible(true)
            self._LeftGuoZhanTeamPanel:setVisible(false)
            self._RightGuoZhanTeamPanel:setVisible(false)
            self._SelfHomeHPLabel:setString("")
            self._EnemyHomeHPLabel:setString("")
            self._RoundLabel:setString("")
            self._TimerLabel:setString("")
            self:addEvent(GameEvent.GameEvent_BattleHPChange, self.OnBattleHPChange)
            self:addEvent(GameEvent.GameEvent_PVPTotalHP, self.OnBattleTotalHPNotity)
             
            self._WuJiangScrollView:setVisible(false)
            self._XiaoBingListView:setVisible(false)
            self._RightBottomPVEPanel:setVisible(false)
        elseif currentLevel._LevelLogicType == LevelLogicType.LevelLogicType_GuoZhanPVP then
            self._SelfHomeHPLabel:setString("")
            self._EnemyHomeHPLabel:setString("")
            self._RoundLabel:setString("")
            self._TimerLabel:setString("")
            self:addEvent(GameEvent.GameEvent_BattleHPChange, self.OnBattleHPChange)
            self:addEvent(GameEvent.GameEvent_PVPTotalHP, self.OnBattleTotalHPNotity)
            self._WuJiangScrollView:setVisible(false)
            self._XiaoBingListView:setVisible(false)
            self._RightBottomPVEPanel:setVisible(false)
            if  self._RightTopPVEPanel ~= nil then
                self._RightTopPVEPanel:setVisible(false)
            end 
            self._RightTopPVPPanel:setVisible(true)
            self._LeftTopPVPPanel:setVisible(true)
            self._LeftGuoZhanTeamPanel:setVisible(true)
            self._RightGuoZhanTeamPanel:setVisible(true)
            self._TopCenterTime:setVisible(true)
            self._TopCenterFlag:setVisible(true)
            self._TimerLabel:setVisible(false)
            self._RoundLabel:setVisible(false)
            self._LeftGuoZhanPlayerListPanel:setVisible(false)
            self._RightGuoZhanPlayerListPanel:setVisible(false)
            self._RightBottomPVPPanel:setVisible(true)
            self._CurrentShowAttackerPageIndex = 1
            self._CurrentShowDefenderPageIndex = 1
            for i = 5, 9 do
                self._pvpBtnList[i]:setVisible(false)
            end
            
            topCenterPanel:setScale(0.8)
        end
    end  
    
    if GameGlobal:GlobalLevelState() == LevelLogicType.LevelLogicType_PVP then
        self._LeftGuoZhanTeamPanel:setVisible(false)
        self._RightGuoZhanTeamPanel:setVisible(false)
        self._RightBottomPVPPanel:setVisible(false)
        self._RightTopPVPPanel:setVisible(true)
        self._LeftTopPVPPanel:setVisible(true)
    end
    
    if  self._BattleResultImage ~= nil then
        self._BattleResultImage:setVisible(false)
    end
    if self._WuJiangScrollView ~= nil then
        self._WuJiangScrollView:jumpToLeft()
    end
    if self._XiaoBingListView ~= nil then
        self._XiaoBingListView:jumpToLeft()
    end
    
    -- 技能使用时的提示动画
    local TableDataManager = GameGlobal:GetDataTableManager()
    local skillPosDataManager = TableDataManager:GetSkillPosDataManager()
    for k, v in pairs(skillPosDataManager)do
        local tableData = v
        if tableData.csb ~= "" and tableData.csb ~= nil then
            local realName = "csb/texiao/ui/" ..tableData.csb
            self._SkillZoneNodeList[k] = cc.CSLoader:createNode(realName)
            self._SkillZoneNodeList[k]:retain()
            self._SkillZoneNodeAnimList[k] = cc.CSLoader:createTimeline(realName) 
            self._SkillZoneNodeAnimList[k]:retain()
            local animName = ""
            if tableData.type == 1 then
                animName = "jinengguangquan1"
            elseif tableData.type == 2 then
                 animName = "jinengguangquan2"
                self._SkillZoneNodeList[k]:setRotation(90)
            elseif tableData.type == 3 then
                animName = "jinengguangquan2"
            end
            self._SkillZoneNodeAnimList[k]:play(animName, true)
            self._SkillZoneNodeList[k]:runAction(self._SkillZoneNodeAnimList[k])
        end  
    end
    
    -- 第三段技能动画
    self._ThirdSkillAnim = cc.CSLoader:createTimeline("csb/texiao/ui/T_u_zhandouguochang.csb") 
    self._ThirdSkillAnim:retain()
    self._ThirdSkillAnimNode = cc.CSLoader:createNode("csb/texiao/ui/T_u_zhandouguochang.csb")
    self._ThirdSkillAnimNode:retain()
    self._ThirdSkillAnimNode:runAction(self._ThirdSkillAnim)
    self._ThirdSkillAnim:play("guochang", false)

    self._RootUINode:addChild(self._ThirdSkillAnimNode)
    self._ThirdSkillAnimNode:setPosition(cc.p(480, 270))
    self._ThirdSkillAnimNode:setVisible(false)
    self._ThirdSkillWuJiangSprite = seekNodeByName(self._ThirdSkillAnimNode, "T_u_wyjiang_6")
    self._ThirdSkillWuJiangSprite2 = seekNodeByName(self._ThirdSkillAnimNode, "T_u_wyjiang_6_0")
    self._ThirdSkillSprite = seekNodeByName(self._ThirdSkillAnimNode, "T_u_SKILL_name_4")
  
    -- 武将出生
    self:addEvent(GameEvent.GameEvent_OutLeader, self.OnLeaderOut)
    -- 武将死亡
    self:addEvent(GameEvent.GameEvent_LeaderDie, self.OnLeaderDie)
    -- 城池血量 变化
    self:addEvent(GameEvent.GameEvent_BuildHPChange, self.OnCityHPChange)
    -- 回合数刷新
    self:addEvent(GameEvent.GameEvent_UIBattle_RefreshRound, self.OnRoundRefresh)
    -- 回合倒计时刷新
    self:addEvent(GameEvent.GameEvent_UIBattle_RefreshRoundTimer, self.OnRoundTimeRefresh)
    -- 人口改变
    self:addEvent(GameEvent.GameEvent_UIBattle_PeopleChange, self.OnRoundPeopleChange)
    self:addEvent(GameEvent.GameEvent_UIBattle_BattleResult, self.OnBattleResult)
    self:addEvent(GameEvent.GameEvent_LevelStateChange, self.OnLevelStateChange)
    self:addEvent(GameEvent.GameEvent_GuoZhan_BattlePlayerList, self.OnRefreshPVPPlayerList)
    self:addEvent(GameEvent.GameEvent_GuoZhan_RefreshPlayer, self.OnRefreshGuoZhanPlayerInfo)
end

--关闭UI
function UIBattle:Close()
    UIBase.Close(self)
    if GameGlobal:GetGameLevel() then
        GameGlobal:GetGameLevel():Destroy()
    end
    self._CurrentClickedLeaderTableID = -1
    removeNodeAndRelease(self._BattleResultAnimNode, true)
    self._BattleResultAnimNode = nil
    
    local TimerManager = GameGlobal:GetTimerManager()
    if self._BattleStartTimerID ~= nil then
        TimerManager:RemoveTimer(self._BattleStartTimerID)
        self._BattleStartTimerID = nil
    end
   
    self._BattleResultAnimNode = nil
    self._CurrentShowAttackerPageIndex = 1
    self._CurrentShowDefenderPageIndex = 1
    
    if self._SkillZoneNodeList ~= nil then
        for k,v in pairs(self._SkillZoneNodeList)do
            if v ~= nil then
                removeNodeAndRelease(v, true)
            end
        end
        self._SkillZoneNodeList = nil
    end
    if self._SkillZoneNodeAnimList ~= nil then
        for k,v in pairs(self._SkillZoneNodeAnimList)do
            if v ~= nil then
                v:release()
            end
        end
        self._SkillZoneNodeAnimList = nil
    end
    removeNodeAndRelease(self._ThirdSkillAnimNode, true)
    self._ThirdSkillAnimNode = nil
    
    self._ThirdSkillWuJiangSprite = nil
    if self._ThirdSkillAnim ~= nil then
        self._ThirdSkillAnim:release()
        self._ThirdSkillAnim = nil
    end
    
    -- 武将刷新
    if self._wuJiangUIInfoList ~= nil then
        for k, v in pairs(self._wuJiangUIInfoList)do
            if v._TimeLineAnim ~= nil then
                v._TimeLineAnim:release()
            end
        end
    end
    
    self._wuJiangUIInfoList = nil
    self._soldierUIInfoList = nil
    
    removeNodeAndRelease(self._BattleStartAnimNode, true)
    self._BattleStartAnimNode = nil
    
    self._WuJiangScrollView:removeAllChildren()
    self._XiaoBingListView:removeAllChildren()
    if self._ThirdStageSkillTimerList ~= nil then
        for k, v in pairs(self._ThirdStageSkillTimerList)do
            TimerManager:RemoveTimer(k)
        end
        self._ThirdStageSkillTimerList = nil
    end
    gGameLevel = nil
end

--测试用，自动打，以测试手机性能
function UIBattle:AutoBattle()
    local currentLevel = GameGlobal:GetGameLevel()
    if currentLevel == nil then
        return
    end
    
    --默认选中武将
    local battleLeaderList = CharacterServerDataManager._OwnLeaderList
    if battleLeaderList ~= nil then
        for k, v in pairs(battleLeaderList)do
            local leaderData = v
            if leaderData._CurrentState == 1 then
                currentLevel:SetSelected(k, true)
            end
        end
    end
    --小兵随机选中
    local soldierList = CharacterServerDataManager._OwnSolderList
    if soldierList == nil then
        return
    end
    local currentCount = 0
    for k, v in pairs(soldierList)do
        local randomNum = math.random(0, 1)
        if randomNum == 1 then
            currentLevel:SetSelected(k, true)
        else
            currentLevel:SetSelected(k, false)
        end
    end
end

--更新 武将信息
function UIBattle:RefreshWuJiangInfo()
    print("RefreshWuJiangInfo")
    --初始化左下武将列表 scrollview
    self._wuJiangUIInfoList = {}
    --遍历已出战的武将列表,刷新左下角武将信息
    self._WuJiangScrollView:removeAllChildren()
    --dump(CharacterServerDataManager, "UIBattle:RefreshWuJiangInfo")
    local battleLeaderList = CharacterServerDataManager._OwnLeaderList--CharacterServerDataManager._OwnBattleLeaderList
    if battleLeaderList == nil then
        return
    end
    for k, v in pairs(battleLeaderList)do
        local leaderData = v
        if leaderData._CurrentState == 1 then
            -- printInfo("leader Data: %d %d", k, leaderData._TableID)
            local newWuJiangInfoUI = cc.CSLoader:createNode(UIBase.GetResourcePath() .. "UIBattleWuJiangItemNew.csb")
            local currentAnim = cc.CSLoader:createTimeline(UIBase.GetResourcePath() .. "UIBattleWuJiangItemNew.csb")
            newWuJiangInfoUI:retain()
            local newWuJiangSelectAnimNode = cc.CSLoader:createNode("csb/texiao/ui/T_u_XBtouxiang_tx1.csb")
            local newWuJiangSelectAnim = cc.CSLoader:createTimeline("csb/texiao/ui/T_u_XBtouxiang_tx1.csb")
            local newWuJiangSkillCanPutAnimNode = cc.CSLoader:createNode("csb/texiao/ui/T_u_WJtouxiang_tx1.csb")
            local newWuJiangSkillCanPutAnim = cc.CSLoader:createTimeline("csb/texiao/ui/T_u_WJtouxiang_tx1.csb")
            local newWuJiangLowSkillAnimNode = cc.CSLoader:createNode("csb/texiao/ui/T_u_WJtouxiang_tx2.csb")
            local newWuJiangLowSkillAnim = cc.CSLoader:createTimeline("csb/texiao/ui/T_u_WJtouxiang_tx2.csb")
            local newWuJiangHighSkillAnimNode = cc.CSLoader:createNode("csb/texiao/ui/T_u_WJtouxiang_tx3.csb")
            local newWuJiangHighSkillAnim = cc.CSLoader:createTimeline("csb/texiao/ui/T_u_WJtouxiang_tx3.csb")
            local newWuJiangHighSkillAnimNode2 =  cc.CSLoader:createNode("csb/texiao/ui/T_u_WJtouxiang_tx4.csb")
            local newWuJiangHighSkillAnim2 = cc.CSLoader:createTimeline("csb/texiao/ui/T_u_WJtouxiang_tx4.csb")
            
            if newWuJiangInfoUI ~= nil then
                local children = newWuJiangInfoUI:getChildren()
                local newLayout = ccui.Layout:create()
                local contentSize = newWuJiangInfoUI:getContentSize()
                newLayout:setContentSize(contentSize)
                --将item的根layer去掉，会阻止scrollview的滚动,添加到新建的newLayout上
                if children ~= nil then
                    local i = 1
                    local len = table.getn(children)
                    for i = 1, len do
                        local childControl = children[i]
                        local refcount = childControl:getReferenceCount()
                        childControl:retain()
                        newWuJiangInfoUI:removeChild(childControl, false)
                        newLayout:addChild(childControl)
                        childControl:release()
                    end
                end
                self._WuJiangScrollView:pushBackCustomItem(newLayout)
                --初始化UI表现
                local headImage = newLayout:getChildByName("Image_Head")
                local checkBox = newLayout:getChildByName("CheckBox_Head")
                local progressBar = newLayout:getChildByName("LoadingBar_SkillCD")
                local animSprite = newLayout:getChildByName("Sprite_TipAnim")
                local nameLabel = seekNodeByName(newLayout,"Text_Name")
                local image_NameBg = newLayout:getChildByName("Image_NameBg")
                local skillStageBar = seekNodeByName(newLayout,"SkillStageBar")
                local image_SkillStageBg = newLayout:getChildByName("Image_SkillStageBg")
                local image_SkillStageFront = seekNodeByName(newLayout, "Image_SkillStageFront")
                local yixishengNode = seekNodeByName(newLayout,"Image_BaiTui")
                local selectedNode = newLayout:getChildByName("Node_SelectEffect")
                local lowSkillNode = newLayout:getChildByName("Node_LowSkillEffect")
                local highSkillNode = newLayout:getChildByName("Node_HighSkillEffect")
                local skillWillPutNode = newLayout:getChildByName("Node_SkillWillPut")
                local highSkillNode2 = newLayout:getChildByName("Node_HighSkillEffect2")
                
                --createProgress(headImage, progressBar, 34.5, 34.5, 0, 0)
                animSprite:setVisible(false)
                if nameLabel ~= nil then
                    local name = leaderData._CharacterData.name
                    nameLabel:setString(name)
                end
                if progressBar ~= nil then
                    progressBar:setVisible(false)
                    self._SkillProgressBarList[k] = progressBar
                end
                if headImage ~= nil then
                    local headIcon = GetArmyIconName(leaderData._CharacterData)
                    headImage:loadTexture(headIcon)
                    headImage:runAction(transition.sequence({cc.ScaleTo:create(0, 0.3), cc.ScaleTo:create(0.3, 1.6), cc.ScaleTo:create(0.3, 1.2)}))
                    self._headImageList[k] = headImage
                    headImage:setTag(k)
                    headImage:setTouchEnabled(false)
                end
                checkBox:setTag(k)
                checkBox:setSelected(false)
                self._checkBoxList[k] = checkBox
                local animControlNode = newLayout:getChildByName("Node_SkillAnimNode")
                --关于动画信息的保存
                local newWuJiangUIInfo = WuJiangUIInfo:new()
                if newWuJiangUIInfo ~= nil then
                    --武将key
                    newWuJiangUIInfo._WuJiangIDKey = k
                    --动画
                    newWuJiangUIInfo._AnimSprite = nil
                    --动画节点
                    newWuJiangUIInfo._AnimRootNode = newWuJiangInfoUI
                    --动画
                    newWuJiangUIInfo._TimeLineAnim = currentAnim
                    --动画控制节点
                    newWuJiangUIInfo._AnimControlNode = animControlNode
                    --
                    newWuJiangUIInfo._NameNode = image_NameBg
                    newWuJiangUIInfo._SkillControlNode = image_SkillStageBg
                    newWuJiangUIInfo._SkillStageProgressNode = skillStageBar
                    newWuJiangUIInfo._XiShengNode = yixishengNode
                    animControlNode:setVisible(false)
                    newWuJiangUIInfo._XiShengNode:setVisible(false)
                    newWuJiangUIInfo._NameNode:setVisible(true)
                    newWuJiangUIInfo._SkillControlNode:setVisible(false)
                    newWuJiangUIInfo._TimeLineAnim:retain()
                    --新添加的动画
                    selectedNode:addChild(newWuJiangSelectAnimNode)
                    newWuJiangSelectAnimNode:runAction(newWuJiangSelectAnim)
                    lowSkillNode:addChild(newWuJiangLowSkillAnimNode)
                    newWuJiangLowSkillAnimNode:runAction(newWuJiangLowSkillAnim)
                    skillWillPutNode:addChild(newWuJiangSkillCanPutAnimNode)
                    newWuJiangSkillCanPutAnimNode:runAction(newWuJiangSkillCanPutAnim)
                    highSkillNode:addChild(newWuJiangHighSkillAnimNode)
                    newWuJiangHighSkillAnimNode:runAction(newWuJiangHighSkillAnim)
                    highSkillNode2:addChild(newWuJiangHighSkillAnimNode2)
                    newWuJiangHighSkillAnimNode2:runAction(newWuJiangHighSkillAnim2)
                    
                    newWuJiangSelectAnimNode:setVisible(false)
                    newWuJiangLowSkillAnimNode:setVisible(false)
                    newWuJiangSkillCanPutAnimNode:setVisible(false)
                    newWuJiangHighSkillAnimNode:setVisible(false)
                    newWuJiangHighSkillAnimNode2:setVisible(false)
                    
                    newWuJiangUIInfo._SelectedEffectNode = newWuJiangSelectAnimNode
                    newWuJiangUIInfo._SelectedEffectAnim = newWuJiangSelectAnim
                    newWuJiangUIInfo._LowSkillAnimNode = newWuJiangLowSkillAnimNode
                    newWuJiangUIInfo._LowSkillAnim = newWuJiangLowSkillAnim
                    newWuJiangUIInfo._SkillPutAnimNode = newWuJiangSkillCanPutAnimNode
                    newWuJiangUIInfo._SkillPutAnim = newWuJiangSkillCanPutAnim
                    newWuJiangUIInfo._HighSkillAnimNode = newWuJiangHighSkillAnimNode
                    newWuJiangUIInfo._HighSkillAnim = newWuJiangHighSkillAnim
                    newWuJiangUIInfo._HighSkillAnimNode2 = newWuJiangHighSkillAnimNode2
                    newWuJiangUIInfo._HighSkillAnim2 = newWuJiangHighSkillAnim2
                    newWuJiangUIInfo._SkillStageFront = image_SkillStageFront
                    self._wuJiangUIInfoList[k] = newWuJiangUIInfo
                    
                end
            end            
        end
    end
end

--刷新小兵UI
function  UIBattle:RefreshXiaoBingInfo()
    if self._XiaoBingListView == nil then
        return
    end
    self._soldierUIInfoList = {}
    self._XiaoBingListView:removeAllChildren()
    local soldierList = CharacterServerDataManager._OwnSolderList
    if soldierList == nil then
        return
    end
    
    for k, v in pairs(soldierList)do
        local newSoldierInfoUI = cc.CSLoader:createNode(UIBase.GetResourcePath() .. "UIBattleXiaoBingItemNew.csb")
        local newSelectEffectNode = cc.CSLoader:createNode("csb/texiao/ui/T_u_XBtouxiang_tx1.csb")
        local newSelectEffectAnim = cc.CSLoader:createTimeline("csb/texiao/ui/T_u_XBtouxiang_tx1.csb")
        
        --local currentAnim = cc.CSLoader:createTimeline(UIBase.GetResourcePath() .. "UIBattleXiaoBingItemNew.csb")
        local soldierData = v
        local newSoldierUIInfo = SoldierUIInfo:new()
        if newSoldierInfoUI ~= nil then
            local children = newSoldierInfoUI:getChildren()
            local newLayout = ccui.Layout:create()
            local contentSize = newSoldierInfoUI:getContentSize()
            newLayout:setContentSize(contentSize)
            --将item的根layer去掉，会阻止scrollview的滚动,添加到新建的newLayout上
            if children ~= nil then
                local i = 1
                local len = table.getn(children)
                for i = 1, len do
                    local childControl = children[i]
                    local refcount = childControl:getReferenceCount()
                    childControl:retain()
                    newSoldierInfoUI:removeChild(childControl, false)
                    newLayout:addChild(childControl)
                    childControl:release()
                end
            end
            self._XiaoBingListView:pushBackCustomItem(newLayout)
            --UI内容刷新
            local headImage = newLayout:getChildByName("Image_Head")
            local checkBoxHead = newLayout:getChildByName("CheckBox_Head")
            local selectNode = newLayout:getChildByName("Node_SelectEffect")
            if selectNode ~= nil then
                selectNode:addChild(newSelectEffectNode)
                newSelectEffectNode:runAction(newSelectEffectAnim)
                newSelectEffectNode:setVisible(false)
            end
            newSoldierUIInfo._SoldierTableID = k
            newSoldierUIInfo._SoldierSelectedNode = newSelectEffectNode
            newSoldierUIInfo._SoldierSelectAnim = newSelectEffectAnim
            checkBoxHead:setTag(k)
            newLayout:setTag(k)
            checkBoxHead:setSelected(false)
            newLayout:setTouchEnabled(true)
            checkBoxHead:setTouchEnabled(false)
            self._checkBoxList[k] = checkBoxHead
            local soldierHeadName =  GetArmyIconName(soldierData._CharacterData)
            headImage:loadTexture(soldierHeadName)
            self._soldierUIInfoList[k] = newSoldierUIInfo
        end
    end

end

function UIBattle:ValueCalculate()
    leftBottomPositionX = GameGlobal:GetGameLevel()._LevelLeftBottomPositionX
    leftBottomPositionY = GameGlobal:GetGameLevel()._LevelLeftBottomPositionY
    rightTopPositionX = GameGlobal:GetGameLevel()._LevelRightTopPositionX
    rightTopPositionY = GameGlobal:GetGameLevel()._LevelRightTopPositionY
    smallMapWidth = self._SmallMapRightTop:getPositionX() - self._SmallMapLeftBottom:getPositionX()
    smallMapHeight = self._SmallMapRightTop:getPositionY() - self._SmallMapLeftBottom:getPositionY()
end

--国战事件回调
function UIBattle:OnRefreshPVPPlayerList(event)
    self._GridView1:reloadData()
    self._GridView2:reloadData()
    
    local pageLabel = seekNodeByName(self._RightGuoZhanTeamPanel,"Text_17")
    local dnum = #GuoZhanServerDataManager._GuoZhanDefenderPlayerInfoList
    local anum = #GuoZhanServerDataManager._GuoZhanAttackerPlayerInfoList
    if pageLabel ~= nil then
        pageLabel:setString(string.format("队伍：%d", #GuoZhanServerDataManager._GuoZhanDefenderPlayerInfoList))
    end
    local pageLabel = seekNodeByName(self._LeftGuoZhanTeamPanel,"Text_17")
    if pageLabel ~= nil then
        pageLabel:setString(string.format("队伍：%d", #GuoZhanServerDataManager._GuoZhanAttackerPlayerInfoList))
    end
    
    if dnum == 0 or anum == 0 then
        UISystem:CloseUI(UIType.UIType_BattleUI)
        UISystem:OpenUI(UIType.UIType_BottomList)
        GuoZhanServerDataManager._GuoZhanAttackerPlayerInfoList = {}
        GuoZhanServerDataManager._GuoZhanDefenderPlayerInfoList = {} 
    end
end


--刷新国战玩家列表
function UIBattle:RefreshGuoZhanPlayerListInfo(panel, info, index1, dataIndex)
    local panelName = stringFormat("Panel_PlayerListItem_%d", index1)
    local childPanel = panel:getChildByName(panelName)
    if childPanel ~= nil then
        
        local indexLabel = childPanel:getChildByName("TextIndex") 
        local countryLabel = childPanel:getChildByName("Text_Country") 
        local nameLabel = childPanel:getChildByName("Text_25") 
        local stateLabel = childPanel:getChildByName("Text_26")
        local index = ""
        if info ~= nil then
            index = tostring(dataIndex)
        end
        indexLabel:setString(index)
        local country = ""
        if info ~= nil then
            country = stringFormat("[%s]", GetGuoZhanBelongChinese(info._Country))
            countryLabel:setColor(GetJudianColor(info._Country))
        end
        countryLabel:setString(country)
        local name = ""
        if info ~= nil then
            if info._Type == 0 then
                name = info._PlayerName
            elseif info._Type == 1 then
                name = "(影)"..info._PlayerName
            elseif info._Type == 2 then
                name = "守城军"
            end
            nameLabel:setColor(GetJudianColor(info._Country))
        end
        nameLabel:setString(name)
       
        if nameLabel:getStringLength() > 4 then
            print(string.sub(name, 0, 4).."...")
            nameLabel:setString(string.sub(name, 0, 12).."...")
        end
        
        local state = {"等待", "上阵"}
        local stateColor = {cc.c3b(0,250,0), cc.c3b(250,0,0)}
        
        if info ~= nil then
            if info._State < 2 then
                stateLabel:setString(state[info._State + 1])
                stateLabel:setTextColor(stateColor[info._State + 1])
            end
        else
            stateLabel:setString("")
        end
    end
end

--刷新国战双方信息回调
function UIBattle:OnRefreshGuoZhanPlayerInfo()
    local battleUI = UISystem:GetUIInstance(UIType.UIType_BattleUI)
    if battleUI ~= nil then
        battleUI:RefreshGuoZhanPlayerInfo()
    end
end

--更新国战攻防双方玩家信息
function UIBattle:UpdateUIPlayerInfo(panel, info)

    local name = ""
    local level = ""
    local guanZhi = ""
    local vip = 0
    local headIcon = "meishu/wujiang/touxiang/"
    if info ~= nil then
        name = info.name
        level = stringFormat("Lv:%d", info.uid)
        guanZhi = ""
        vip = info.vip
        headIcon = headIcon.."5001.png"
    end
    
    local nameLabel = seekNodeByName(panel, "Text_Info_Name")
    if nameLabel ~= nil then
        nameLabel:setString(name)
    end
    local levelLabel = seekNodeByName(panel, "Text_Info_Level")
    if levelLabel ~= nil then
        levelLabel:setString(level)
    end
    local guanZhiLabel = seekNodeByName(panel, "Text_Info_GuanZhi")
    if guanZhiLabel ~= nil then
        guanZhiLabel:setString(guanZhi)
    end
    local vipLabel =  seekNodeByName(panel, "Sprite_Info_V")
    if vipLabel ~= nil then
        vipLabel:loadTexture(string.format("meishu/ui/vip/UI_vip_%d.png", vip))
    end
    
    local head =  seekNodeByName(panel, "head")
    if head ~= nil then
        head:loadTexture(headIcon)
    end
     
end
--刷新国战双方信息
function UIBattle:RefreshGuoZhanPlayerInfo()
    local attackInfo = G_FightInfo["attacker"]
    if self._LeftTopPVPPanel ~= nil then
        self:UpdateUIPlayerInfo(self._LeftTopPVPPanel, attackInfo)
    end 
    local defenceInfo = G_FightInfo["defender"]
    if self._RightTopPVPPanel ~= nil then
        self:UpdateUIPlayerInfo(self._RightTopPVPPanel, defenceInfo)
    end 
end

-- 国战 Team箭头点击 
function UIBattle:onTeamArrowClick(sender, eventType)
   if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
        if tag == 1 then
            local isUIVisible = self._LeftGuoZhanPlayerListPanel:isVisible()
            self._LeftGuoZhanPlayerListPanel:setVisible(not isUIVisible)
            self._CurrentShowAttackerPageIndex = 1
        else
            local isUIVisible = self._RightGuoZhanPlayerListPanel:isVisible()
            self._RightGuoZhanPlayerListPanel:setVisible(not isUIVisible)
            self._CurrentShowDefenderPageIndex = 1
        end
    end
end

--更新技能CD
function UIBattle:UpdateSkillCD(leaderTableID, percent, skillInfo)
    if leaderTableID ~= nil then
        if percent == 0 then
           print("--------------")
         
            self:ShowSkillCanUseAnim(leaderTableID)
            print("--------------")
            --设置成下一段的数据
            local nextTableID = skillInfo._SkillTableIDList[skillInfo._CurrentSkillStage]
            if nextTableID ~= nil and nextTableID ~= 0 then
                local SkillTableDataManager = GameGlobal:GetDataTableManager():GetSkillDataManager()
                local skillData =  SkillTableDataManager[nextTableID]
                if skillData ~= nil then
                    local headImage = self._headImageList[leaderTableID]
                    if headImage ~= nil then
                        local icon = GetSkillIcon(skillData)
                        headImage:loadTexture(icon)
                    end
                end
            end
            if skillInfo._CurrentSkillStage == 1 then
                self:ShowLowSkillAnim(leaderTableID, true)
            else
                --
                self:ShowLowSkillAnim(leaderTableID, true)
                if skillInfo._CurrentSkillStage == skillInfo._SkillStageCount then
                    self:ShowLowSkillAnim(leaderTableID, false)
                    self:ShowHighSkillAnim(leaderTableID, true)
                end
            end
        else
            self:ShowSkillAnimNode(leaderTableID, false)
        end
        
        local progressBar = self._SkillProgressBarList[leaderTableID]
        if progressBar ~= nil then
            --self._headImageList[leaderTableID]:getChildByTag(1001):setPercentage(percent)
        end
        --计算成总的比例
       
        local uiInfo = self._wuJiangUIInfoList[leaderTableID]
        if uiInfo ~= nil then
            if uiInfo._SkillStageProgressNode ~= nil then
                local skillCD = skillInfo._SkillCDList[1]
                local flapsedTime = skillInfo._CurrentSkillStage * skillCD + (skillCD * (100-percent)/100)
                local newPercent = flapsedTime / skillInfo._SkillTotalCD * 100
                uiInfo._SkillStageProgressNode:setPercent(newPercent)
            end
        end
    end
end

--显示战斗开始动画
function UIBattle:ShowBattleStartAnim(isShow)
    if isShow == true then
        if self._BattleStartAnimNode ~= nil then
            self._BattleStartAnimNode:removeFromParent()
            self._BattleStartAnimNode:removeAllChildren()
            self._BattleStartAnimNode = nil
        end
        self._BattleStartAnimNode = cc.CSLoader:createNode(battleStartCSBName)
        self._BattleStartAnimNode:retain()
        self._BattleStartTimeLineAnim = cc.CSLoader:createTimeline(battleStartCSBName)
        local animName = "zhandoukaishi"
        if self._BattleStartAnimNode ~= nil then
            self._BattleStartAnimNode:runAction( self._BattleStartTimeLineAnim)
            self._BattleStartTimeLineAnim:play(animName, false)
            if self._BattleStartTimeLineAnim:IsAnimationInfoExists(animName) == true then
                local animInfo = self._BattleStartTimeLineAnim:getAnimationInfo(animName)
                if animInfo ~= nil  then
                    local animLength = (animInfo.endIndex - animInfo.startIndex) / 60
                    local TimerManager = GameGlobal:GetTimerManager()
                    self._BattleStartTimerID = TimerManager:AddTimer(animLength, UIBattle.OnBattleStartTimerEnd, self)
                end
            end
            
            self._BattleStartAnimNode:setPosition(display.width / 2, display.height / 2)
            self._RootUINode:addChild(self._BattleStartAnimNode)
        end
    else
        if self._BattleStartAnimNode ~= nil then
            self._BattleStartAnimNode:setVisible(false)
        end
    end
end

-- 动画结束处理
function UIBattle:OnBattleStartAnimEnd()
    self:ShowBattleStartAnim(false)
    local TimerManager = GameGlobal:GetTimerManager()
    if self._BattleStartTimerID ~= nil then
        TimerManager:RemoveTimer(self._BattleStartTimerID)
        self._BattleStartTimerID = nil
    end
  
    local currentLevel = GameGlobal:GetGameLevel()
    if currentLevel._LevelLogicType == LevelLogicType.LevelLogicType_GuoZhanPVP then
        --SendMsg(PacketDefine.PacketDefine_MapCitySubscribe_Send, {gcity})
    end
end

-- 开始动画结束
function UIBattle.OnBattleStartTimerEnd(self, id)
    self:OnBattleStartAnimEnd()
end

-- 显示武将选中动画
function UIBattle:ShowWuJiangSelectAnim(leaderTableID, isSelect)
    local uiInfo = self._wuJiangUIInfoList[leaderTableID]
    if uiInfo == nil then
        return
    end
    local selectNode = uiInfo._SelectedEffectNode
    if selectNode ~= nil then
        selectNode:setVisible(isSelect)
        if isSelect == true then
            uiInfo._SelectedEffectAnim:play("XBtouxiangtexiao_1", true)
        end
    end
end

--显示小兵选中的动画
function UIBattle:ShowSoldierSelectAnim(soldierTableID, isSelect)
    local uiInfo = self._soldierUIInfoList[soldierTableID]
    if uiInfo == nil then
        return
    end
    local selectNode = uiInfo._SoldierSelectedNode
    if selectNode ~= nil then
        selectNode:setVisible(isSelect)
        if isSelect == true then
            uiInfo._SoldierSelectAnim:play("XBtouxiangtexiao_1", true)
        end
    end
end

-- 显示武将技能将放置的动画
function UIBattle:ShowSkillWillPutAnim(leaderTableID, isVisible)
    local uiInfo =  self._wuJiangUIInfoList[leaderTableID]
    if uiInfo == nil then
        return
    end
    local animNode = uiInfo._SkillPutAnimNode
    if animNode ~= nil then
        animNode:setVisible(isVisible)
        if isVisible == true then
            uiInfo._SkillPutAnim:play("WJtouxiangtexiao_1", true)
        end
    end
end

-- 显示武将技能 低段技能可使用动画
function UIBattle:ShowLowSkillAnim(leaderTableID, isVisible)
    local uiInfo =  self._wuJiangUIInfoList[leaderTableID]
    if uiInfo == nil then
        return
    end
    local animNode = uiInfo._LowSkillAnimNode
    if animNode ~= nil then
        animNode:setVisible(isVisible)
        if isVisible == true then
            uiInfo._LowSkillAnim:play("WJtouxiangtexiao_2", true)
        end
    end
end

-- 显示武将技能高段技能可使用动画
function UIBattle:ShowHighSkillAnim(leaderTableID, isVisible)
    local uiInfo =  self._wuJiangUIInfoList[leaderTableID]
    if uiInfo == nil then
        return
    end
    local animNode = uiInfo._HighSkillAnimNode
    if animNode ~= nil then
        animNode:setVisible(isVisible)
        if isVisible == true then
            uiInfo._HighSkillAnim:play("WJtouxiangtexiao_3", true)
        end
    end
    local animNode2 = uiInfo._HighSkillAnimNode2
    if animNode2 ~= nil then
        animNode2:setVisible(isVisible)
        if isVisible == true then
            uiInfo._HighSkillAnim2:play("WJtouxiangtexiao_4", true)
        end
    end
end

-- 显示技能范围动画
function UIBattle:ShowSkillZoneAnim(currentTableID, isVisible)
     local currentLevel =  GameBattle:GetGameLevel()
     if currentLevel == nil then
        return
     end
    local currentInfo = currentLevel:GetLeaderSkillInfo(currentTableID)
    if currentInfo == nil then
        return
    end
    local skillTableID = currentInfo._SkillTableIDList[currentInfo._CurrentSkillStage]
    if  skillTableID == nil then
        return
    end
    local TableDataManager = GameGlobal:GetDataTableManager()
    local SkillDataManager = TableDataManager:GetSkillDataManager()
    local SkillPosDataManager = TableDataManager:GetSkillPosDataManager()
    local skillData = SkillDataManager[skillTableID]
    if skillData == nil then
        print("error ShowSkillZoneAnim", skillTableID)
        return
    end
    local skillPosData = SkillPosDataManager[skillData.zoneType]
    if skillPosData == nil then
        return
    end
    self._currentSkillZoneType = skillData.zoneType

    for k, v in pairs(self._SkillZoneNodeList)do
        v:setVisible(false)
    end
    
    local currentSelectNode =  self._SkillZoneNodeList[self._currentSkillZoneType]
    currentSelectNode:setVisible(true)
    local anim = self._SkillZoneNodeAnimList[self._currentSkillZoneType]
    local parentNode = currentSelectNode:getParent()
    if parentNode == nil then
        currentLevel:GetRootNode():addChild(currentSelectNode)
        local actionNumber  = currentSelectNode:getNumberOfRunningActions()
        if actionNumber == 0 then
            currentSelectNode:runAction(anim) 
        end
    end
end

-- 更新技能位置
function UIBattle:UpdateSkillZonePosition(worldPosition)
    local currentSelectNode =  self._SkillZoneNodeList[self._currentSkillZoneType]
    if currentSelectNode == nil then
        return
    end
    local parentNode = currentSelectNode:getParent()
    if parentNode == nil then
        return
    end
    local nodePosition = parentNode:convertToNodeSpace(worldPosition)
    currentSelectNode:setPosition(nodePosition)
end

-- 隐藏当前的技能范围动画
function UIBattle:HideSkillZoneAnim()
    local currentSelectNode =  self._SkillZoneNodeList[self._currentSkillZoneType]
    if currentSelectNode == nil then
        return
    end
    currentSelectNode:setVisible(false)
end

-- 显示技能可以使用的动画
function UIBattle:ShowSkillCanUseAnim(currentTableID, isVisible)
    if isVisible == nil then
        isVisible = true
    end
    local uiInfo =  self._wuJiangUIInfoList[currentTableID]
    if uiInfo ~= nil then
        local animNode = uiInfo._AnimRootNode
        local controlNode = uiInfo._AnimControlNode
        local anim = uiInfo._TimeLineAnim
        controlNode:setVisible(isVisible)
        if animNode ~= nil and anim ~= nil then
            local numAction = animNode:getNumberOfRunningActions()
            if numAction == 0 then
                animNode:runAction(anim)
            end
            anim:play("animation0", true)
        end
    end
end

-- 显示技能放置的动画
function UIBattle:ShowSkillCanPutAnim(currentTableID, isVisible)
    if isVisible == nil then
        isVisible = true
    end
    local uiInfo =  self._wuJiangUIInfoList[currentTableID]
    if uiInfo ~= nil then
        local animNode = uiInfo._AnimRootNode
        local controlNode = uiInfo._AnimControlNode
        local anim = uiInfo._TimeLineAnim
        controlNode:setVisible(isVisible)
        if animNode ~= nil and anim ~= nil then
            local numAction = animNode:getNumberOfRunningActions()
            if numAction == 0 then
                animNode:runAction(anim)
            end
            anim:play("animation1", true)
        end
    end
end

function UIBattle:PvpToucnClicked(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
        if tag == 5 then
            UISystem:OpenUI(UIType.UIType_UIChallenge)
            SendMsg(PacketDefine.PacketDefine_MapPvp_Send)
        elseif tag == 6 then
            EndFight() 
            g_Retreat = 1
            GameGlobal:GetUISystem():OpenUI(UIType.UIType_WorldMap)
            GameGlobal:GetUISystem():OpenUI(UIType.UIType_BottomList)
        elseif tag == 7 then
            EndFight() 
            g_Retreat = 2
            GameGlobal:GetUISystem():OpenUI(UIType.UIType_WorldMap)
            GameGlobal:GetUISystem():OpenUI(UIType.UIType_BottomList)
        elseif tag == 8 then
            if GetPlayer()._ShadowNum > 0 or GetPlayer()._Gold >= 100 then
                SendMsg(PacketDefine.PacketDefine_Shadow_Send)
            else
            
            end
        end
    end
end

-- 设置动画节点的显示与隐藏
function UIBattle:ShowSkillAnimNode(currentTableID, isVisible)
    local uiInfo =  self._wuJiangUIInfoList[currentTableID]
    if uiInfo ~= nil then
        local controlNode = uiInfo._AnimControlNode
        controlNode:setVisible(isVisible)
    end
end

-- 左箭头点击
function UIBattle:OnLeftArrowClick()
    
    if self._XiaoBingListView ~= nil then
        local contentSize = self._XiaoBingListView:getInnerContainerSize()
        local innerContainer = self._XiaoBingListView:getInnerContainer()
        local scrollviewSize = self._XiaoBingListView:getContentSize()
        if contentSize ~= nil and scrollviewSize ~= nil then
            --print("OnLeftArrowClick", contentSize.width, scrollviewSize.width)
            local nowPositionX,_ = innerContainer:getPosition()
            local moveZoneWidth = contentSize.width - scrollviewSize.width
            if moveZoneWidth <= 0 then
                return
            end
            local offsetX = nowPositionX - scrollviewSize.width
            local percent = -offsetX / moveZoneWidth   * 100
            --print("left ..", percent, offsetX, moveZoneWidth)
            self._XiaoBingListView:jumpToPercentHorizontal(percent)
        end
    end
    
end

-- 右箭头点击
function UIBattle:OnRightArrowClick()
    if self._XiaoBingListView ~= nil then
        local contentSize = self._XiaoBingListView:getInnerContainerSize()
        local innerContainer = self._XiaoBingListView:getInnerContainer()
        local scrollviewSize = self._XiaoBingListView:getContentSize()
        if contentSize ~= nil and scrollviewSize ~= nil then
            --print("OnRightArrowClick", contentSize.width, scrollviewSize.width)
            local nowPositionX,_ = innerContainer:getPosition()
            local moveZoneWidth = contentSize.width - scrollviewSize.width
            if moveZoneWidth <= 0 then
                return
            end
            local offsetX = nowPositionX + scrollviewSize.width
            local percent = -offsetX / moveZoneWidth   * 100
            if percent < 0 then
                percent = 0
            end
            --print("right ..", percent, offsetX, moveZoneWidth)
            self._XiaoBingListView:jumpToPercentHorizontal(percent)
        end
    end
end

--[[--------------------------------事件处理-------------------------------------------]]

-- 武将出
function UIBattle:OnLeaderOut(event)
    local battleUI = UISystem:GetUIInstance(UIType.UIType_BattleUI)
    local currentTableID = event._usedata

    local leaderList = CharacterServerDataManager._OwnLeaderList
    local leaderData = leaderList[currentTableID]
    local headImage = battleUI._headImageList[currentTableID]
    local checkBox = battleUI._checkBoxList[currentTableID]
    if  leaderData ~= nil  then
        -- 将当前对应的头像设为武将技能图标
        if headImage ~= nil then
            local skillData = leaderData._CharacterSkillData2
            if skillData ~= nil then
                headImage:runAction(cc.ScaleTo:create(0.2, 1))
                local icon = GetSkillIcon(skillData)
                headImage:loadTexture(icon)
                if battleUI._SelectFrame ~= nil then
                    battleUI._SelectFrame:removeFromParent(false)
                    headImage:addChild(battleUI._SelectFrame)
                end
            end
            battleUI:ShowWuJiangSelectAnim(currentTableID, false)
            headImage:setTouchEnabled(true)
        end
        if checkBox ~= nil then
            checkBox:setTouchEnabled(false)
        end
    end
   
    local currentLevel = GameGlobal:GetGameLevel()
    
    local wuJiangUIInfo = battleUI._wuJiangUIInfoList[currentTableID]
    if wuJiangUIInfo ~= nil then
        wuJiangUIInfo._NameNode:setVisible(false)
        wuJiangUIInfo._SkillControlNode:setVisible(true)
        local textureName = "meishu/ui/zhandou/UI_zd_bishtiao_03.png"
        local frontTextureName = "meishu/ui/zhandou/UI_zd_bishtiao_02.png"
        if currentLevel ~= nil then
            local skillInfo = currentLevel._LeaderSkillInfoList[currentTableID]
            if skillInfo ~= nil then
                if skillInfo._SkillStageCount == 2 then
                    textureName = "meishu/ui/zhandou/UI_zd_bishtiao_04.png"
                    frontTextureName = "meishu/ui/zhandou/UI_zd_bishtiao_06.png"
                elseif skillInfo._SkillStageCount == 3 then
                    textureName = "meishu/ui/zhandou/UI_zd_bishtiao_05.png"
                    frontTextureName = "meishu/ui/zhandou/UI_zd_bishtiao_07.png"
                end
            end
        end
        wuJiangUIInfo._SkillStageProgressNode:loadTexture(textureName)
        wuJiangUIInfo._SkillStageFront:loadTexture(frontTextureName)
    end
    battleUI:ShowLowSkillAnim(currentTableID, true)
end

-- 武将死亡事件的处理
function UIBattle:OnLeaderDie(event)
    local battleUI = UISystem:GetUIInstance(UIType.UIType_BattleUI)
    local currentTableID = event._usedata.tableID
    local isEnemy = event._usedata.isEnemy
    if isEnemy == true then
        return
    end
    if currentTableID ~= nil then
        local headImage = battleUI._headImageList[currentTableID]
        if headImage ~= nil then
            local leaderList = CharacterServerDataManager._OwnLeaderList
            local leaderData = leaderList[currentTableID]
            if  leaderData ~= nil  then
                headImage:setTouchEnabled(false)
            end
        end
        local leaderCheckbox = battleUI._checkBoxList[currentTableID]
        if leaderCheckbox ~= nil then
            leaderCheckbox:setSelected(false)
        end
        local animSprite = battleUI._SkillAnimSpriteList[currentTableID]
        local progressBar = battleUI._SkillProgressBarList[currentTableID]
        if animSprite ~= nil then
            animSprite:setVisible(false)
        end
        if progressBar ~= nil then
            progressBar:setVisible(false)
        end
        battleUI:ShowSkillAnimNode(currentTableID, false)
        battleUI:ShowLowSkillAnim(currentTableID, false)
        battleUI:ShowHighSkillAnim(currentTableID, false)
        battleUI:ShowWuJiangSelectAnim(currentTableID, false)
        battleUI:ShowSkillWillPutAnim(currentTableID, false)
        local uiInfo = battleUI._wuJiangUIInfoList[currentTableID]
        if uiInfo ~= nil then
            uiInfo._XiShengNode:setVisible(true)
        end
    end
end


-- 城池血量变化
function UIBattle:OnCityHPChange(event)
    local buildingGUID = event._usedata.guid
    if buildingGUID ~= nil and buildingGUID < 3 then
        local currentHP = event._usedata.Hp
        if currentHP < 0 then
            currentHP = 0
        end
        local totalHP =  event._usedata.maxHp
        local percent =  mathCeil(currentHP / totalHP * 100)
        local hpString = tostring(currentHP ) .. "/" .. tostring(totalHP)
        self._SelfHomeHPLabel:setString("")
        self._EnemyHomeHPLabel:setString("")
        if buildingGUID == 1 then
            self._SelfHPProgressBar:setPercent(percent)
        else
            self._EnemyProgressBar:setPercent(percent)
        end
    end
end

-- 战斗HP改变
function UIBattle:OnBattleHPChange(event)
    local isEnemy = event._usedata.isEnemy
    local hpChange = event._usedata.hpChange
    if isEnemy == nil or hpChange == nil then
        return
    end
 
    if isEnemy == false then
        self._CurrentPVPSelfTotalHP = self._CurrentPVPSelfTotalHP - hpChange
        local percent = mathCeil(battleUI._CurrentPVPSelfTotalHP / self._PVPSelfTotalHP * 100)
        self._SelfHPProgressBar:setPercent(percent)
    else
        self._CurrentPVPEnemyTotalHP =  self._CurrentPVPEnemyTotalHP - hpChange
        local percent = mathCeil(elf._CurrentPVPEnemyTotalHP / self._PVPEnemyTotalHP * 100)
        self._EnemyProgressBar:setPercent(percent)
    end

end

-- PVP战斗总血量初始化
function UIBattle:OnBattleTotalHPNotity(event)
    local selfHP = event._usedata.selfHP
    local enemyHP = event._usedata.enemyHP
    if selfHP == nil or enemyHP == nil then
        return
    end
    
    self._PVPSelfTotalHP = selfHP
    self._PVPEnemyTotalHP = enemyHP
    self._CurrentPVPSelfTotalHP = selfHP
    self._CurrentPVPEnemyTotalHP = enemyHP
end

-- 回合数刷新
function UIBattle:OnRoundRefresh(event)
    local currentRound = event._usedata.round
    if currentRound ~= nil then
        local showRoundStr = stringFormat(ChineseConvert["UIBattleText_Round"], currentRound)
        self._RoundLabel:setString(showRoundStr)
        -- 第十回合弹出 弹尽粮绝
        if currentRound == 10 then
            self._DanJinLiangJueImage:setVisible(true)
            self._DanJinLiangJueImage:setOpacity(0)
            local showAction = transition.sequence({cc.FadeTo:create(1.0, 255), cc.DelayTime:create(1), cc.FadeTo:create(1.0, 0)})
            self._DanJinLiangJueImage:runAction(showAction)
        end
    end
end

-- 回合倒计时刷新
function UIBattle:OnRoundTimeRefresh(event)
    local currentRoundTime = event._usedata.roundTime
    if currentRoundTime ~= nil then
        --目前字体里用字符0表示的"十"
        if currentRoundTime == 10 then
            currentRoundTime = 0
        end     
        local showRoundStr = stringFormat("%d", currentRoundTime)
        self._TimerLabel:setString(showRoundStr)
    end
end

-- 人口改变
function UIBattle:OnRoundPeopleChange(event)
    local currentRoundPeople = event._usedata.roundPeople
    if currentRoundPeople ~= nil then
        local showRoundStr = stringFormat("%d", currentRoundPeople)
        self._LeftTopPeopleLabel:setString(showRoundStr)
    end
end

-- 关卡状态改变
function UIBattle:OnLevelStateChange(event)
    local currentState = event._usedata.levelState
    if currentState == LevelState.LevelState_WillStart then
        self:ShowBattleStartAnim(true)
        self._SelfHPProgressBar:setPercent(100)
        self._EnemyProgressBar:setPercent(100)
    -- 关卡状态：等待服务器回应
    elseif currentState == LevelState.LevelState_WaitServerInfo then
       
    end
end

-- 战斗结果
function UIBattle:OnBattleResult(event)
    --战斗结果
    local battleResult = event._usedata.battleResult
    --战斗回合数
    local battleNums = event._usedata.round
    
    --PVE
    local currentLevel =  GameGlobal:GetGameLevel()
    if currentLevel ~= nil then
        --非PVPi
        if currentLevel._LevelLogcType == LevelLogicType.LevelLogicType_PVE then
            --战斗结束将PVE小地图list中数据清空
            if battleResult == 1 then
                SendMsg(PacketDefine.PacketDefine_StageEnd_Send, {1})
            else 
                local reward = UISystem:OpenUI(UIType.UIType_BattleResUI)
                reward:OpenUISucceed(0, 0, 0, {})
                SendMsg(PacketDefine.PacketDefine_StageEnd_Send, {0})
            end
        else
            local reward = UISystem:OpenUI(UIType.UIType_BattleResUI)
            local rewardTableID = CharacterServerDataManager._CurrentShaChangBattleAwardTableID
            local RewardDataManager = GameGlobal:GetCustomRewardDataManager()
            local rewardData = RewardDataManager[tonumber(rewardTableID)] 
            reward:OpenUISucceed(0, 1, battleResult, rewardData)
        end
    end
end

-- 事件响应函数    TODO：能否是个local的函数,且能统一代码风格
function UIBattle:SelectedStateEvent(sender, eventType)
    if eventType == ccui.CheckBoxEventType.selected then
        local currentLevel =  GameGlobal:GetGameLevel()
        currentLevel:SetSelected(sender:getTag(), true)
        self:ShowWuJiangSelectAnim(sender:getTag(), true)
        self:ShowSoldierSelectAnim(sender:getTag(), true)
    elseif eventType == ccui.CheckBoxEventType.unselected then
        local currentLevel =  GameGlobal:GetGameLevel()
        currentLevel:SetSelected(sender:getTag(), false)
        self:ShowWuJiangSelectAnim(sender:getTag(), false)
        self:ShowSoldierSelectAnim(sender:getTag(), false)
    end
end

-- imageView事件 技能图标
function UIBattle:OnImageViewClicked(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local oldSelect =  self._CurrentClickedLeaderTableID
        local nowSelect =  sender:getTag()
        if self._SelectFrame ~=nil then
            self._SelectFrame:removeFromParent(false)
            sender:addChild(self._SelectFrame)
        end
        local currentLevel =  GameGlobal:GetGameLevel()
        print(currentLevel)
        if currentLevel ~= nil then
            local currentInfo = currentLevel:GetLeaderSkillInfo(nowSelect)
            dump(currentInfo)
            if currentInfo ~= nil then
                if currentInfo._CurrentSkillStage < 1 then
                    return
                end
                -- 老的选中的
                if oldSelect ~= -1 then
                    local senderID = CharacterManager:GetLeaderByTableID(oldSelect)
                    local currentCharacter = CharacterManager:GetCharacterByClientID(senderID)
                    if currentCharacter ~= nil then
                        local oldSelectInfo = currentLevel:GetLeaderSkillInfo(oldSelect)
                        if oldSelectInfo ~= nil then
                            self:ShowSkillWillPutAnim(oldSelect, false)
                        end
                    end
                end
                if oldSelect ~= nowSelect then
                    self._CurrentClickedLeaderTableID = nowSelect
                    self:ShowSkillWillPutAnim(nowSelect, true)
                else
                    self._CurrentClickedLeaderTableID = -1
                end
            end
        end
    end
end

-- 退出点击
function UIBattle:OnQuitClicked(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
        UITip:SetStyle(0, GameGlobal:GetTipDataManager(UI_battle_quit))
        UITip:RegisteDelegate(self.OnQuitConfirm, 1, nil, self)
    end
end

function UIBattle:OnQuickQuitClicked(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self.OnQuitConfirm(self, 1)
    end
end

-- 退出确认
function UIBattle.OnQuitConfirm(self, tag)
    -- 战斗结果
    local battleResult = BattleResult.BattleResult_Lose
    -- 战斗回合数
    local battleNums = 2
    -- PVE
    local currentLevel =  GameGlobal:GetGameLevel()
    if currentLevel ~= nil then
        -- 非PVP
        if currentLevel._LevelLogicType == LevelLogicType.LevelLogicType_PVE or  
            currentLevel._LevelLogicType == LevelLogicType.LevelLogicType_PVE_PVP then
            -- 战斗结束将PVE小地图list中数据清空
            SendMsg(PacketDefine.PacketDefine_StageEnd_Send, {0, 1})
            EndFight() 
            UISystem:CloseUI(UIType.UIType_BattleUI)
            require("main.Game.GameMaincity"):Enter()
        else
            EndFight() 
            if currentLevel._LevelLogicType == LevelLogicType.LevelLogicType_GuoZhanPVP then
                  UISystem:CloseUI(UIType.UIType_BattleUI)
                  UISystem:OpenUI(UIType.UIType_WorldMap)
                  UISystem:OpenUI(UIType.UIType_BottomList)
                  local GuoZhanServerDataManager = GameGlobal:GetGuoZhanServerDataManager()
                  GuoZhanServerDataManager._GuoZhanAttackerPlayerInfoList = {}
                  GuoZhanServerDataManager._GuoZhanDefenderPlayerInfoList = {} 
                  SendMsg(PacketDefine.PacketDefine_MapCitySubscribe_Send, {0})
            else
                UISystem:CloseUI(UIType.UIType_BattleUI)
            end
        end
    end
end

-- 空白处点击
function OnBlankPanelClicked(sender, eventType)
    if gIsTouchs then
        return
    end

    local battleUI = UISystem:GetUIInstance(UIType.UIType_BattleUI)
    if eventType == ccui.TouchEventType.began then
        local beginPositon = sender:getTouchBeganPosition()
        battleUI._LastClickPosition = beginPositon
        print(battleUI._CurrentClickedLeaderTableID)
        if battleUI._CurrentClickedLeaderTableID ~= nil and battleUI._CurrentClickedLeaderTableID ~= -1 then
            battleUI:ShowSkillZoneAnim(battleUI._CurrentClickedLeaderTableID, true, beginPositon)
            battleUI:UpdateSkillZonePosition(beginPositon)
        end
    elseif eventType == ccui.TouchEventType.ended then
        if battleUI._CurrentClickedLeaderTableID ~= nil and battleUI._CurrentClickedLeaderTableID ~= -1 then
            battleUI:HideSkillZoneAnim()
            local worldPosition = sender:getTouchEndPosition()
            local currentLevel =  GameGlobal:GetGameLevel()
            if currentLevel ~= nil then
                local senderID = CharacterManager:GetLeaderByTableID(battleUI._CurrentClickedLeaderTableID)
                local currentCharacter = CharacterManager:GetCharacterByClientID(senderID)
                if currentCharacter ~= nil then
                    local currentInfo = currentLevel:GetLeaderSkillInfo(battleUI._CurrentClickedLeaderTableID)
                    if currentInfo ~= nil then
                        local currentSkillStage = currentInfo._CurrentSkillStage
                        --第三段技能时特殊处理
                        
                        if currentSkillStage == 1 then
                             local currentSkillTableID = currentInfo:GetCanUseSkillTableID()
                             if currentSkillTableID ~= 0 then
                                currentLevel:Pause(true)
                                Fight:setPvePause(true)
                                currentLevel:DarkLevel(currentCharacter)
                                --武将形象 
                                local  pDirector = cc.Director:getInstance()
                                pDirector:getActionManager():resumeTarget(battleUI._ThirdSkillAnimNode)
                                local hurtFactor = currentLevel:GetCurrentLeaderSkillHurtFactor(battleUI._CurrentClickedLeaderTableID)
                                local TimerManager = GameGlobal:GetTimerManager()
                                local userData = {}
                                userData.currentSkillTableID = currentSkillTableID
                                userData.senderID = senderID
                                userData.worldPosition = worldPosition
                                userData.hurtFactor = hurtFactor
                                userData.unit = currentCharacter._unit
                                local animInfo = battleUI._ThirdSkillAnim:getAnimationInfo("guochang")
                                local animLength = 2
                                if animInfo ~= nil  then
                                    animLength = (animInfo.endIndex - animInfo.startIndex) / 60
                                end
                                local timerID = TimerManager:AddTimer(animLength, UIBattle.UseThirdStageSkill, userData)
                                if battleUI._ThirdStageSkillTimerList == nil then
                                    battleUI._ThirdStageSkillTimerList = {}
                                end
                                battleUI._ThirdStageSkillTimerList[timerID] = timerID
                                currentLevel:ResetLeaderSkill(battleUI._CurrentClickedLeaderTableID)
                                currentInfo._IsEnable = true
                                battleUI._ThirdSkillAnimNode:setVisible(true)
                                
                                
                                local bodyImage = "meishu/wujiang/quanshenxiang/" .. tostring(currentCharacter._CharacterData.cardImage) .. ".png" --"meishu/wujiang/quanshenxiang/5001.png"
                                if battleUI._ThirdSkillWuJiangSprite ~= nil then
                                    battleUI._ThirdSkillWuJiangSprite:setTexture(bodyImage)
                                end
                                if battleUI._ThirdSkillWuJiangSprite2 ~= nil then
                                    battleUI._ThirdSkillWuJiangSprite2:setTexture(bodyImage)
                                end
                                battleUI._ThirdSkillSprite:setTexture(bodyImage)
                                battleUI._ThirdSkillAnim:gotoFrameAndPlay(0, 114, false)
                            end
                         else
                            local currentSkillTableID = currentInfo:GetCanUseSkillTableID()
                            -- print("add skill tableID", currentSkillTableID)
                            if currentSkillTableID ~= 0 then
                                local hurtFactor = currentLevel:GetCurrentLeaderSkillHurtFactor(battleUI._CurrentClickedLeaderTableID)
                                currentLevel:AddLeaderSkill(currentSkillTableID, senderID, worldPosition, hurtFactor, currentCharacter._unit)
                                currentLevel:ResetLeaderSkill(battleUI._CurrentClickedLeaderTableID)
                                currentInfo._IsEnable = true
                            end
                        end

                        -- 重置技能图标
                        local nextTableID = currentInfo._SkillTableIDList[1]
                        if nextTableID ~= nil and nextTableID ~= 0 then
                            local SkillTableDataManager = GameGlobal:GetDataTableManager():GetSkillDataManager()
                            local skillData =  SkillTableDataManager[nextTableID]
                            if skillData ~= nil then
                                local headImage = battleUI._headImageList[battleUI._CurrentClickedLeaderTableID]
                                if headImage ~= nil then
                                    local icon = GetSkillIcon(skillData)
                                    headImage:loadTexture(icon)
                                end
                            end
                        end
                    end
                    -- 动画隐藏
                    battleUI:ShowSkillWillPutAnim(battleUI._CurrentClickedLeaderTableID, false)
                    battleUI:ShowLowSkillAnim(battleUI._CurrentClickedLeaderTableID, false)
                    battleUI:ShowHighSkillAnim(battleUI._CurrentClickedLeaderTableID, false)
                    currentLevel:Pause(false) 
                    battleUI._CurrentClickedLeaderTableID = -1
                end
                battleUI._CurrentClickedLeaderTableID = -1
            end
        end
        battleUI._LastClickPosition = nil
    elseif eventType == ccui.TouchEventType.moved then
        local movePosition =  sender:getTouchMovePosition()

        if battleUI._CurrentClickedLeaderTableID ~= nil and battleUI._CurrentClickedLeaderTableID ~= -1 then
            battleUI:UpdateSkillZonePosition(movePosition)
        else
            if battleUI._LastClickPosition ~= nil then
                local moveDeltaX = movePosition.x - battleUI._LastClickPosition.x
                local currentLevel =  GameGlobal:GetGameLevel()
                if currentLevel ~= nil then
                    currentLevel:MoveX(moveDeltaX)
                end
                battleUI._LastClickPosition = movePosition
            end
        end
    end
    
end

-- 使用第三段技能
function UIBattle.UseThirdStageSkill(userData, timerID)
    
    local currentLevel =  GameGlobal:GetGameLevel()
    local currentSkill =  currentLevel:AddLeaderSkill(userData.currentSkillTableID, userData.senderID, userData.worldPosition, userData.hurtFactor, userData.unit)
    if timerID ~= nil then
        local battleUI = UISystem:GetUIInstance(UIType.UIType_BattleUI)
        local TimerManager = GameGlobal:GetTimerManager()
        TimerManager:RemoveTimer(timerID)
        battleUI._ThirdStageSkillTimerList[timerID] = nil
        currentLevel:SetCurrentWuJiangSkill(currentSkill:GetClientID())
    end
    local currentCharacter = CharacterManager:GetCharacterByClientID(userData.senderID)
    if currentCharacter ~= nil then
        
    end
end

-- 小兵listview
function UIBattle.OnXiaoBingListView(sender, eventType)
    if eventType == ccui.ListViewEventType.ONSELECTEDITEM_START then
    elseif eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
        local selectedItemIndex = sender:getCurSelectedIndex()
        local selectedItem = sender:getItem(selectedItemIndex)
        local battleUI = UISystem:GetUIInstance(UIType.UIType_BattleUI)
        if selectedItem ~= nil then
            local soldierTableID = selectedItem:getTag()
            
            local currentLevel = GameGlobal:GetGameLevel()
           
            if currentLevel == nil then
                return
            end
            if currentLevel._SelectedSoldiersTable ~= nil then
               local isSelected =  currentLevel._SelectedSoldiersTable[soldierTableID]
               if isSelected == nil or isSelected == false then
                    currentLevel:SetSelected(soldierTableID, true)
                    local soldierCheck = battleUI._checkBoxList[soldierTableID]
                    if soldierCheck ~= nil then
                        soldierCheck:setSelected(true)
                        battleUI:ShowSoldierSelectAnim(soldierTableID, true)
                    end
               else
                    currentLevel:SetSelected(soldierTableID, false)
                    local soldierCheck = battleUI._checkBoxList[soldierTableID]
                    if soldierCheck ~= nil then
                        soldierCheck:setSelected(false)
                        battleUI:ShowSoldierSelectAnim(soldierTableID, false)
                    end
               end
            end
        end
    end
end

function UIBattle:CellSizeForTable(view, idx)
    return 210, 35
end

function UIBattle:NumberOfCellsInTableView(view)
    if view:getTag() == 1 then
        return #GuoZhanServerDataManager._GuoZhanAttackerPlayerInfoList
    else
        return #GuoZhanServerDataManager._GuoZhanDefenderPlayerInfoList
    end
end

function UIBattle:TableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
    end
    cell:removeAllChildren(true)
    local layout = cc.CSLoader:createNode("csb/ui/PvpItem.csb") 
    
    -- setSwallowTouches false
    seekNodeByName(layout,"Panel_PlayerListItem_1"):setSwallowTouches(false)
    cell:addChild(layout, 0, idx)
    if view:getTag() == 1 then
        self:initCell1(cell, idx)
    else    
        self:initCell2(cell, idx)
    end
    return cell
end

function UIBattle:initCell1(cell, idx)
    local layout = cell:getChildByTag(tonumber(idx))
    self:RefreshGuoZhanPlayerListInfo(layout, GuoZhanServerDataManager._GuoZhanAttackerPlayerInfoList[idx + 1], 1, idx + 1)
end

function UIBattle:initCell2(cell, idx)
    local layout = cell:getChildByTag(tonumber(idx))
    self:RefreshGuoZhanPlayerListInfo(layout, GuoZhanServerDataManager._GuoZhanDefenderPlayerInfoList[idx + 1], 1, idx + 1)
end

return UIBattle