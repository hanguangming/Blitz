----
-- 文件名称：UITrain.lua
-- 功能描述：训练
-- 文件说明：背包
-- 作    者：王峰
-- 创建时间：2015-6-19
--  修改
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
require("src.cocos.ui.GuiConstants")
require("cocos.extension.ExtensionConstants")

local UISystem = GameGlobal:GetUISystem()
local UITrain = class("UITrain", UIBase)
local SoldierData = require("main.ServerData.CharacterServerDataManager")
local ItemDataManager = GameGlobal:GetItemDataManager()
local ExpData = GameGlobal:GetExpDataManager() 
local stringFormat = string.format
local localMathMod = math.mod
local TimerManager = require("main.Utility.Timer")
local CELL_COL_ROW = 1 
local CELL_SIZE_WIDTH = 120
local CELL_SIZE_HEIGHT = 85

--武将训练特效
local WARRIOR_TRAIN_EFFECT = "csb/texiao/ui/T_u_ziti_wujiangxunlian.csb"

function UITrain:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_TrainUI
    self._ResourceName = "UITrain.csb"
end

function UITrain:Load()
    UIBase.Load(self)
    local center = seekNodeByName(self._RootPanelNode, "Panel_Center")
    self._GridView = CreateTableView_(-308, -137, 200, 415, 1, self)
    center:addChild(self._GridView)
    self._PeopleLabel = self:GetUIByName("PeopleLabel")
    self._Slider = self:GetUIByName("Slider_1")
    self._ProfessionLabel = self:GetUIByName("Text_SoldierType")
    self._AtkTypeLabel = self:GetUIByName("Text_ATK_Type")
    self._HpLabel = self:GetUIByName("Text_HP_Value")
    self._AtkLabel = self:GetUIByName("Text_ATk_Value")
    self._AtkSpeedLabel = self:GetUIByName("Text_ATK_Speed")
    self._MoveSpeedLabel = self:GetUIByName("MoveSpeedLabel")
    self._MoveSpeedData = self:GetUIByName("Text_Move_Speed")
    self._ConsumeLabel = self:GetUIByName("Text_Consume")
    self._ConsumeName = self:GetUIByName("Text_ConsumeLabel")

    self._PopulationLabel = self:GetUIByName("Text_Population")
    self._Output = self:GetUIByName("Text_Output")
    self._OutputLabel = self:GetUIByName("Text_OutputLabel")
    self._LbExp = self:GetUIByName("Text_LB_Exp")
    self._AnimParentNode = self:GetUIByName("Node_Small")
    self._ExpLodingBar  = self:GetUIByName("LoadingBar_Exp")
    self._BodyStarImage = self:GetUIByName("Star_Bg")
    self._BodyImage = self:GetUIByName("Image_QuanShen")
    self._AtkJuli = self:GetUIByName("Text_ATK_JuLi")
    self._TuFeiBtn = self:GetUIByName("Button_TuFei")
    self._TuFeiBtn:setTag(1)
    self._TuFeiBtn:addTouchEventListener(handler(self, self.tuFeiBtnCallBack))
    self._TuFeiBtn1 = self:GetUIByName("Button_TuFei_10")
    self._TuFeiBtn1:setTag(10)
    self._TuFeiBtn1:addTouchEventListener(handler(self, self.tuFeiBtnCallBack))

    self._ShengYuTuFeiLabel = self:GetUIByName("Text_ShengYuTuFei")
    self._Data_Queue = self:GetUIByName("Data_Queue")

    self._TrainNormalBtn = self:GetUIByName("Button_Train_PuTong")
    self._TrainQiangHuaBtn = self:GetUIByName("Button_Train_QiangHua")
    self._TrainZhuanJiaBtn = self:GetUIByName("Button_Train_ZhuanJia")
    self._TrainNormalBtn:setTag(1)
    self._TrainNormalBtn:addTouchEventListener(handler(self, self.trainBtnCallBack))
    self._TrainQiangHuaBtn:setTag(2)
    self._TrainQiangHuaBtn:addTouchEventListener(handler(self, self.trainBtnCallBack))
    self._TrainZhuanJiaBtn:setTag(3)
    self._TrainZhuanJiaBtn:addTouchEventListener(handler(self, self.trainBtnCallBack))

    self._TrainTab = {}
    self._CurTabIndex = 1
    self._TrainTab[3] = self:GetUIByName("Button_8")

    self._SkillImage = self:GetUIByName("Image_skill")
    self._SkillImage:setTag(10)
    self._SkillImage:addTouchEventListener(handler(self, self.touchEvent))
    self._SkillName = self:GetUIByName("Skill_Name")
    self._SkillNameImage = self:GetUIByName("Image_25")
    self._Time_1 = self:GetUIByName("Text_Time_1")
    self._Time_2 = self:GetUIByName("Text_Time_2")
    self._Time_3 = self:GetUIByName("Text_Time_3")

    self._TrainImageIng_1 = ccui.Helper:seekWidgetByName(self._TrainNormalBtn, "Text_16")
    self._TrainImageIng_2 = ccui.Helper:seekWidgetByName(self._TrainQiangHuaBtn, "Text_15")
    self._TrainImageIng_3 = ccui.Helper:seekWidgetByName(self._TrainZhuanJiaBtn, "Text_14")

    self._TrainInfo_1 = ccui.Helper:seekWidgetByName(self._TrainNormalBtn, "Panel_11")
    self._TrainInfo_2 = ccui.Helper:seekWidgetByName(self._TrainQiangHuaBtn, "Panel_11")
    self._TrainInfo_3 = ccui.Helper:seekWidgetByName(self._TrainZhuanJiaBtn, "Panel_11")

    self._TrainTab[1] = self:GetUIByName("Button_6")
    self._TrainTab[1]:setTag(1)
    self._TrainTab[1]:addTouchEventListener(handler(self, self.touchEvent))
    self._TrainTab[1]:setBrightStyle(1)

    for i = 1, 1 do
        self:GetUIByName("Text_Title"..i):enableOutline(cc.c4b(73, 58, 43, 250), 1)
    end

    local close = self:GetWigetByName("Close")
    close:setTag(-1)
    close:addTouchEventListener(handler(self, self.touchEvent))
    -- UI scrollview 上添加上下箭头
    self._ImageUp = self:GetWigetByName("Image_Up")
    self._ImageUp:setLocalZOrder(1)
    self._ImageUp:setVisible(false)
    self._ImageDown = self:GetWigetByName("Image_Down")
    self._ImageDown:setLocalZOrder(1)
end

function UITrain:Open()
    UIBase.Open(self)
    self._SolderID = {}
    self._WarriorID = {}
    self._BEastID = {}
    self._CellIndex = 0
    self.currenttrainQueueNum = 0
    -- 按住一直突飞用
    self.gScheduler = nil
    self.gSchedulerID = nil
    self.gTuFeiFlag = 0
    self.gTuFeiTick = 0
    -- 记录切换武将操作前的武将ID
    self._PreviousWarrriorID = -1
    
    for i, v in pairs(SoldierData._OwnSolderList) do
        table.insert(self._SolderID, i)
    end

    for i, v in pairs(SoldierData._OwnLeaderList) do
        table.insert(self._WarriorID, i)
    end
    self:reSortWarrior()
    self:reSortSoldier() 
    self:updateUI(SoldierData._TrainSoldierID)
    
    self.gScheduler = cc.Director:getInstance():getScheduler()
    
    self._ItemIndex = 1
    self._CurWarrriorIndex = -1
    self._CurWarrriorId = -1
    self._CurWarrriorIdF = -1

    -- 加入选择框
    self._SelectFrame = self:createSelectFrame()
    self._SelectFrame:retain()
    self._GridView:addChild(self._SelectFrame)
    
    self._ImageUp:setVisible(false)
    self._ImageDown:setVisible(true)
    
    -- 加载武将已训练特效
    self._trainSuccessNode = cc.CSLoader:createNode(WARRIOR_TRAIN_EFFECT)
    self._trainSuccessAnim = cc.CSLoader:createTimeline(WARRIOR_TRAIN_EFFECT) 
    self._trainSuccessNode:runAction(self._trainSuccessAnim)
    self._trainSuccessNode:retain()
    self._trainSuccessAnim:retain()
    
    self:addEvent(GameEvent.GameEvent_UITrain_Update, self.update)
    self:addEvent(GameEvent.GameEvent_UITrainSuccess_Update, self.trainSuccessUpdate)
    self:addEvent(GameEvent.GameEvent_UITrain_UpdateItemNum, self.updateItemNum)
end

function UITrain:Close()
    UIBase.Close(self)
    if self._TrainTimeTimerID ~= nil then
        TimerManager:RemoveTimer(self._TrainTimeTimerID)
        self._TrainTimeTimerID = nil
    end
    removeNodeAndRelease(self._SelectFrame, true)
    -- 士兵小动画
    self._AnimParentNode:removeAllChildren(true)
    
    -- 释放武将训练特效
    removeNodeAndRelease(self._trainSuccessNode, true)
    if self._trainSuccessAnim ~= nil then
        self._trainSuccessAnim:release()
        self._trainSuccessAnim = nil
    end
end

-- 播放武将已训练特效
function UITrain:playTrainSuccessAnim()
    local parentNode =self._trainSuccessNode:getParent()
    if parentNode == nil then
        self._trainSuccessNode:setPosition(cc.p(480, 270))
        self._RootUINode:addChild(self._trainSuccessNode)
    end
    if self._trainSuccessAnim ~= nil then
        self._trainSuccessAnim:play("animation0", false)
    end
end

function UITrain:trainSuccessUpdate()
     if self._ActorData._Level == GetPlayer()._Level then
        local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
        UITip:SetStyle(1, "武将等级不可超过主公等级")
     end
end

function UITrain:reSortWarrior()
    table.sort(self._WarriorID, function(a, b)
        local warrior1 = SoldierData:GetLeader(a)
        local warrior2 = SoldierData:GetLeader(b)

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

function UITrain:reSortSoldier()
    table.sort(self._SolderID, function(a, b)
        local warrior1 = SoldierData:GetSoldier(a)
        local warrior2 = SoldierData:GetSoldier(b)
        if warrior1._CharacterData.quality == warrior2._CharacterData.quality then
            if warrior1._Level > warrior2._Level then
                return true
            else
                return false
            end
        else
            return warrior1._CharacterData.quality > warrior2._CharacterData.quality
        end
    end)
end

-- 刷新训练时间显示
function UITrain:refreshTrainTime()
    local soldierData 
    
    if self._CurTabIndex == 2 then
        soldierData = SoldierData:GetSoldier(SoldierData._TrainSoldierID)
    else
        soldierData = SoldierData:GetLeader(SoldierData._TrainSoldierID)
    end
    
    if soldierData ~= nil then
        local timeStr = ""
        local offTime = soldierData._TimeEnd - os.time()
        local isShow = true
        if offTime < 0 then
            offTime = 0
            isShow = false
        end
        -- 时
        local hour =  math.floor(math.mod(offTime / 3600, 24))
        -- 分
        local minute = math.floor(math.mod((offTime - hour * 3600) / 60, 60)) 
        -- 秒
        local second = math.mod(offTime, 60)  
        local timeStr = string.format("剩余%02d:%02d:%02d", hour, minute, second)
        if soldierData._TrainType == 1 then
            self._Time_1:setString(timeStr)
            self._Time_1:setVisible(isShow)
            if not isShow then
                self._TrainInfo_1:setVisible(true)
                self._TrainImageIng_1:setString("8小时训练")
            end
        elseif soldierData._TrainType == 2 then
            self._Time_2:setString(timeStr)
            self._Time_2:setVisible(isShow)
            if not isShow then
                self._TrainInfo_2:setVisible(true)
                self._TrainImageIng_2:setString("12小时训练")
            end
        elseif soldierData._TrainType == 3 then
            self._Time_3:setString(timeStr)
            self._Time_3:setVisible(isShow)
            if not isShow then
                self._TrainInfo_3:setVisible(true)
                self._TrainImageIng_3:setString("24小时训练")
            end  
        end
    end
end

-- 时间改变
function UITrain:onTrainTimeChange(sender)
     local soldierUIInstance = UISystem:GetUIInstance(UIType.UIType_TrainUI)
     if soldierUIInstance ~= nil then
        soldierUIInstance:refreshTrainTime()
     end
end

local itemCountTuFei = 0
function UITrain:sendTrainMessage()
    local soldierData = self:getCurObjectByID(self._CurTabIndex, SoldierData._TrainSoldierID)
    local itemCount = ItemDataManager:GetItemCount(30007)
    if soldierData == nil then 
        return
    elseif itemCount <= 0 then
        CreateTipAction(self._RootUINode, ChineseConvert["UITuFeiNotEnough"], cc.p(480, 270))
        return
    elseif soldierData._Level >= GetPlayer()._Level then
        local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
        if self._CurTabIndex == 1 then 
            UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_xl_05))
        else
            UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_xl_04))
        end
        return
    end
    
    if itemCount >= 1 then
        if self.gTuFeiTick == 1 then
            local itemCount = ItemDataManager:GetItemCount(30007)
            itemCountTuFei = itemCount - 1
            self._ShengYuTuFeiLabel:setString("( 剩余"..stringFormat(ChineseConvert.UITrainText_ShengYuTuFei, itemCountTuFei).."突飞令 )")
        elseif self.gTuFeiTick ~= 4 then
            itemCountTuFei = itemCountTuFei - 1
            self._ShengYuTuFeiLabel:setString("( 剩余"..stringFormat(ChineseConvert.UITrainText_ShengYuTuFei, itemCountTuFei).."突飞令 )")
        end
        CreateTipAction(self._RootUINode, ChineseConvert["UITuFeiSuccess"], cc.p(480, 200))
    end
    if itemCount >= math.floor(self.gTuFeiTick) and math.floor(self.gTuFeiTick) > 3 then
        PlaySound(Sound_26)
        SendMsg(PacketDefine.PacketDefine_ExpUp_Send, {SoldierData._TrainSoldierID, math.floor(self.gTuFeiTick)})
        self.gTuFeiTick = 0
    elseif itemCount < 4 then
        PlaySound(Sound_26)
        SendMsg(PacketDefine.PacketDefine_ExpUp_Send, {SoldierData._TrainSoldierID, 1})
    end
end

local anTime = 0 -- 按住时间
function UITrain:tuFeiBtnCallBack(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        self.gTuFeiTick = 0
        self.gTuFeiFlag = 1
        anTime = 0
        -- 用于判断是单次点击还是长按
        local function schedulerUpdate(dt)
            anTime = anTime + 0.2
            -- 长按
            if anTime > 1.0 then
                self.gTuFeiTick = self.gTuFeiTick + 1
                self:sendTrainMessage()
            end
        end
        self.gSchedulerID = self.gScheduler:scheduleScriptFunc(schedulerUpdate, 0.1, false)
    elseif eventType == ccui.TouchEventType.canceled then
        self:tuFeiAn()
    elseif eventType == ccui.TouchEventType.ended then
        self:tuFeiAn()
    end
end

function UITrain:tuFeiAn()
    self.gTuFeiTick = 0
    self.gTuFeiFlag = 0
    self.gScheduler:unscheduleScriptEntry(self.gSchedulerID)
    local soldierData = self:getCurObjectByID(self._CurTabIndex, SoldierData._TrainSoldierID)
    local itemCount = ItemDataManager:GetItemCount(30007)
    if soldierData == nil then 
        return
    elseif itemCount <= 0 then
        CreateTipAction(self._RootUINode, ChineseConvert["UITuFeiNotEnough"], cc.p(480, 270))
        return
    elseif soldierData._Level >= GetPlayer()._Level then
        local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
        if self._CurTabIndex == 1 then 
            UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_xl_05))
        else
            UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_xl_04))
        end
        return
    end
    
    -- 鼠标松开连续单次点击
    if anTime < 1.0 and self.gTuFeiFlag == 0 then
        if  itemCount >= 1 then
            CreateTipAction(self._RootUINode, ChineseConvert["UITuFeiSuccess"], cc.p(480, 200))
            PlaySound(Sound_26)
            SendMsg(PacketDefine.PacketDefine_ExpUp_Send, {SoldierData._TrainSoldierID, 1})
        end
    end
    anTime = 0
end

function UITrain:ChangeTabState(tag)
    self._CurTabIndex = tag
    local name
    local title
    if tag == 2 then
        name ={ChineseConvert["UITitle_1"], GameGlobal:GetTipDataManager(UI_BUTTON_NAME_6), GameGlobal:GetTipDataManager(UI_BUTTON_NAME_8)}
        title = GameGlobal:GetTipDataManager(UI_BUTTON_NAME_10)
    else
        name ={ChineseConvert["UITitle_1"], GameGlobal:GetTipDataManager(UI_BUTTON_NAME_22), GameGlobal:GetTipDataManager(UI_BUTTON_NAME_6)} 
        title = GameGlobal:GetTipDataManager(UI_BUTTON_NAME_9)
    end
    self._GridView:reloadData()
    SoldierData._TrainSoldierID = self:getCurObjectList(self._CurTabIndex)[1]
    self:updateUI(SoldierData._TrainSoldierID)
    local cell = self._GridView:cellAtIndex(0)
    if cell ~= nil then
        local panel = cell:getChildByTag(0)
        local button = seekNodeByName(panel, "Button_2")
        if button ~= nil then
            SimulateClickButton(button, handlers(self, self.tableViewItemTouchEvent, 2)) 
        end
    end
    self:updateTeamNum()
end

function UITrain:updateTeamNum()
    local num = 0
    if self._CurTabIndex == 2 then
        for i, v in pairs(SoldierData._OwnSolderList) do
            if v._Time > 0 then
                num = num + 1
            end
        end
    elseif self._CurTabIndex == 1 then
        for i, v in pairs(SoldierData._OwnLeaderList) do
            if v._Time > 0 then
                num = num + 1
            end
        end
    end
    if GetPlayer()._VIPLevel > 0 and GetPlayer()._VIPLevel <= 12 then
        self._Data_Queue:setString(num.."/"..GameGlobal:GetVipDataManager()[GetPlayer()._VIPLevel]["trainnum"])
    else
        self._Data_Queue:setString(num.."/4")
    end
    self.currenttrainQueueNum = num
end

function UITrain:touchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
        if tag == -1 then
            UISystem:CloseUI(UIType.UIType_AdvancedUI)
            UISystem:CloseUI(UIType.UIType_SoldierUI) 
            UISystem:CloseUI(UIType.UIType_WarriorUI) 
            UISystem:CloseUI(UIType.UIType_TrainUI) 
        elseif tag == 1 then
            UISystem:CloseUI(UIType.UIType_TrainUI)
            if self._CurTabIndex == 1 then
                local warrior = UISystem:OpenUI(UIType.UIType_WarriorUI)
--                warrior:EnterPlayAnimation(true)
            else
                UISystem:OpenUI(UIType.UIType_SoldierUI)
            end
        elseif tag == 2 then
            if self._CurTabIndex == 1 then
                UISystem:CloseUI(UIType.UIType_TrainUI)
                local recruit = UISystem:OpenUI(UIType.UIType_UIRecruit)  
                recruit:EnterPlayAnimation(true)
                SendMsg(PacketDefine.PacketDefine_RecruitStore_Send)
            end
        elseif tag == 3 then
            if self._CurTabIndex == 2 then
                local soldier = UISystem:GetUIInstance(UIType.UIType_SoldierUI)
                SimulateClickButton(soldier._AdvanceBtn,  handlers(self, soldier.touchEvent, 2))
            end
        elseif tag == 10 then
            local UITip = require("main.UI.UITip") 
            UITip:OpenSkillInfo(480, 300, self._ActorData._CharacterSkillData2)
        end
    end
end

function UITrain:trainBtnCallBack(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        trainClick = 1
        local soldierData
        if self._CurTabIndex == 1 then 
            soldierData = SoldierData:GetLeader(SoldierData._TrainSoldierID)
        elseif self._CurTabIndex == 2 then 
            soldierData = SoldierData:GetSoldier(SoldierData._TrainSoldierID)
        else 
            return
        end
    
        if GetPlayer()._VIPLevel < 1 and sender:getTag() == 3 then
            local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
            UITip:SetStyle(1, "VIP等级不足，无法使用专家级训练")
            return
        end
        if GetPlayer()._Level == 1 then
            local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
            UITip:SetStyle(1, "武将等级不可超过主公等级")
            return
        end
        if sender:getTag() == soldierData._TrainType and soldierData._Time > 0 then
            local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
            -- 加速训练时间元宝花费
            self._accelerateCost = math.floor(soldierData._Time / 120 )
            UITip:RegisteDelegate(handler(self, self.commitTipButton), 1, "确认花费"..math.floor(soldierData._Time / 120 ).."元宝清除训练CD？")
        elseif soldierData._Time == 0 then
            if self.currenttrainQueueNum >= tonumber(GameGlobal:GetVipDataManager()[GetPlayer()._VIPLevel]["trainnum"]) then
                local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                UITip:SetStyle(1, "训练队列已满")
                return
            else
                -- 播放武将已训练特效
                 if self._CurTabIndex == 1 then 
                    self:playTrainSuccessAnim()
                 end
            end
            local silver = {}
            silver[1] = ExpData[soldierData._Level]["lowCost"]
            silver[2] = ExpData[soldierData._Level]["middleCost"]
            silver[3] = ExpData[soldierData._Level]["highCost"]
            
            local itemCount = ItemDataManager:GetItemCount(30008)
            if itemCount == 0 and sender:getTag() == 3 then
                local uiInstance = UISystem:OpenUI(UIType.UIType_BuyItem)
                uiInstance:OpenItemInfoNotifiaction(30008)
                return
            end
            if sender:getTag() ~= 3 then
                if GetPlayer()._Silver < silver[sender:getTag()] then
                    local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                    UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_xl_01))
                    return
                end
            end
            SendMsg(PacketDefine.PacketDefine_Train_Send, {SoldierData._TrainSoldierID, sender:getTag()})
            return
        end
    end
end

function UITrain:commitTipButton(tag)
    if tag == 1 then
        -- 判断元宝是否足够加速时间的花费
        if GetPlayer()._Gold < self._accelerateCost then
            CreateTipAction(self._RootUINode, "元宝不足，请充值", cc.p(480, 270))
        else
            SendMsg(PacketDefine.PacketDefine_TrainCancel_Send, {SoldierData._TrainSoldierID})
        end
    end
end


function UITrain:ScrollViewDidScroll(view)
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
    elseif percent <= 0 and len >=0  then
        self._ImageUp:setVisible(true)
        self._ImageDown:setVisible(false)
    end
end

function UITrain:NumberOfCellsInTableView(view)
    local len = 0
    local curTabIDList = self:getCurObjectList(self._CurTabIndex)
    len = #curTabIDList % CELL_COL_ROW == 0 and math.floor(#curTabIDList / CELL_COL_ROW) or math.floor(#curTabIDList / CELL_COL_ROW) + 1 
    return len
end

function UITrain:TableCellTouched(view, cell)
    self._CellIndex = cell:getIdx()
    self._ItemIndex = (cell:getIdx() * CELL_COL_ROW) + self._CurCellTag
    self:updateUI(self:getCurObjectList(self._CurTabIndex)[self._ItemIndex])  
    
    self._CurWarrriorIndex = cell:getIdx() + 1
    local tag = cell:getIdx()
    self._CellType = tag
    local layout = cell:getChildByTag(tonumber(self._CurWarrriorIndex - 1))
    local panel = seekNodeByName(layout, "Panel_1")
    self._CurWarrriorIdF = self:getCurObjectList(self._CurTabIndex)[self._ItemIndex]

    -- cell缩放动画
    local actionTo = cc.ScaleTo:create(0.1, 0.9)
    local actionTo2 = cc.ScaleTo:create(0.1, 1.0)
    panel:runAction(cc.Sequence:create(actionTo, actionTo2)) 
    if self._PreviousWarrriorID ~= self._CurWarrriorID then
        self:selectAnimation(panel)
    end
end

function UITrain:CellSizeForTable(view, idx)
    return CELL_SIZE_WIDTH, CELL_SIZE_HEIGHT
end

function UITrain:tableViewItemTouchEvent(sender, value)
    local eventType = value
    if type(value) == "table" then
        eventType = value.eventType
    end
    
    if eventType == ccui.TouchEventType.ended then
        self._CurCellTag = sender:getTag()
    end
end

function UITrain:TableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
    end
    cell:removeAllChildren(true)
    self:createCell(cell, idx) 
    self:initCell(cell, idx)
    return cell
end

function UITrain:createCell(cell, idx)
    local layout = cc.CSLoader:createNode("csb/ui/WarriorItem.csb")
    local panel = seekNodeByName(layout, "Panel_1")
    panel:setSwallowTouches(false)
    local button = ccui.Helper:seekWidgetByName(panel, "Button_2")
    button:setTag(1)
    button:addTouchEventListener(handler(self, self.tableViewItemTouchEvent))
    button:setSwallowTouches(false)
    ccui.Helper:seekWidgetByName(panel, "Image_2"):setSwallowTouches(false)
    cell:addChild(layout, 0, idx)  
    return cell
end

function UITrain:initCell(cell, idx)
    local layout = cell:getChildByTag(tonumber(idx))
    local panel = seekNodeByName(layout, "Panel_1")
    local head1 = ccui.Helper:seekWidgetByName(panel, "Image_2")
    local name1 = ccui.Helper:seekWidgetByName(panel, "Text_1")
    local level = seekNodeByName(layout, "Text_2")
    local battleImage = seekNodeByName(panel, "Image_Battle")
    local TypeImage = seekNodeByName(panel, "Image_Type")
    local trainImage = seekNodeByName(panel, "Image_TrainIcon")
    local headDiColorImage = seekNodeByName(panel, "Image_35")
    
    local curTabIDList = self:getCurObjectList(self._CurTabIndex)
    local warriorId = -1
    if idx * CELL_COL_ROW + 1 <= #curTabIDList then
        local soldier =  self:getCurObject(self._CurTabIndex, idx, 1) 
        name1:setString(soldier._CharacterData.name)
        warriorId = self:getCurObjectList(self._CurTabIndex)[idx + 1]
        level:setString("lv"..soldier._Level)
        trainImage:setVisible(false)
        if soldier._Time ~= 0 then
            trainImage:setVisible(true)
        end
        head1:setVisible(true)
        headDiColorImage:loadTexture(GetHeadColorImage(soldier._CharacterData["quality"]))
        if self._CurTabIndex == 2 then
            seekNodeByName(panel, "Image_1"):setVisible(false)
            head1:loadTexture(GetSoldierHeadPath(soldier._CharacterData.headName), UI_TEX_TYPE_LOCAL)
            battleImage:setVisible(false)
            if soldier._CurrentState == 1 then
                battleImage:setVisible(true)
            end
            TypeImage:loadTexture(GetSoldierProperty(soldier._CharacterData.soldierType))
        else
            TypeImage:loadTexture(GetSoldierProperty(soldier._CharacterData.soldierType))
            if soldier._CurrentState == 1 then
                seekNodeByName(panel, "Image_1"):setVisible(false)
            else
                seekNodeByName(panel, "Image_1"):setVisible(false)
            end
            head1:loadTexture(GetWarriorPath(soldier._CharacterData.headName), UI_TEX_TYPE_LOCAL)
            battleImage:setVisible(false)
            if soldier._CurrentState == 1 then
                battleImage:setVisible(true)
            end
        end
        head1:setAnchorPoint(0.5, 0.5)
    end
    if warriorId ~= -1 then
        if self._PreviousWarrriorID == -1 then
            self._PreviousWarrriorID = warriorId
        end
        if self._PreviousWarrriorID == warriorId then
            self:selectAnimation(panel)
        end
    end
end

function UITrain:updateItemNum()
    CreateAnimation(self._RootPanelNode, 480, 250, "csb/texiao/ui/T_u_ziti_goumai.csb", "animation0", false, 0, 1)
    local itemNum = ItemDataManager:GetItemCount(30008)
    ccui.Helper:seekWidgetByName(self._TrainInfo_3, "Text_2"):setString(itemNum)
end

function UITrain:getCurObjectList(tab)
    if tab == 1 then
        return self._WarriorID
    elseif tab == 2 then
        return self._SolderID
    elseif tab == 3 then
        return self._BEastID
    end
end

function UITrain:getCurObject(tab, idx, index)
    if tab == 1 then
        return SoldierData:GetLeader(self._WarriorID[idx * CELL_COL_ROW + index])
    elseif tab == 2 then
        return SoldierData:GetSoldier(self._SolderID[idx * CELL_COL_ROW + index])
    end
end

function UITrain:getCurObjectByID(tab, id)
    if tab == 1 then
        return SoldierData:GetLeader(id)
    elseif tab == 2 then
        return SoldierData:GetSoldier(id)
    end
end

-- 刷新训练描述
function UITrain:updateUI(id)
    if id == nil then
        return
    end

    SoldierData._TrainSoldierID = id
    local soldierData =  self:getCurObjectByID(self._CurTabIndex, id)

    if soldierData == nil then
        return
    end

    self._ActorData = soldierData
    local expMax
    expMax = ExpData[soldierData._Level]["soldierExp"]
    self._ProfessionLabel:setString(GetSoldierType(soldierData._CharacterData.soldierType))
    self._AtkTypeLabel:setString(GetSoldierAttackType(soldierData._CharacterSkillData1["zoneType"]))

    -- 利用富文本显示血量
    local richText = ccui.RichText:create()
    local equipHp = 0

    if soldierData._EquipHp == nil then
        equipHp = 0
    else
        equipHp = soldierData._EquipHp
    end 

    local re1 = ccui.RichElementText:create(1, cc.c3b(255, 255, 255), 255, (soldierData._Hp - equipHp), "", 16)
    richText:pushBackElement(re1)

    if equipHp ~= 0 then
        local re2 = ccui.RichElementText:create(1, cc.c3b(0, 255, 0), 255, ("+"..equipHp), "", 16) 
        richText:pushBackElement(re2)
    end

    richText:setAnchorPoint(cc.p(0, 0.5))
    richText:setPosition(0, 162)
    -- 利用富文本显示攻击力
    local richText1 = ccui.RichText:create()
    local equipAtk = 0

    if soldierData._EquipAtk == nil then
        equipAtk = 0
    else
        equipAtk = soldierData._EquipAtk
    end

    local re3 = ccui.RichElementText:create(1, cc.c3b(255, 255, 255), 255, (soldierData._Attack - equipAtk), "", 16)
    richText1:pushBackElement(re3)

    if equipAtk ~= 0 then
        local re4 = ccui.RichElementText:create(1, cc.c3b(0, 255, 0), 255, ("+"..equipAtk), "", 16) 
        richText1:pushBackElement(re4)
    end

    richText1:setAnchorPoint(cc.p(0, 0.5))
    richText1:setPosition(0, 127)
    self._AtkSpeedLabel:setString(soldierData._AtkSpeed)
    self._MoveSpeedData:setString(soldierData._CharacterData.moveSpeed)
    local lbExpString = stringFormat("%d/%d", soldierData._Exp, expMax)
    self._LbExp:setString(lbExpString)
    local percent = tonumber(soldierData._Exp)/tonumber(expMax) *100 
    self._ExpLodingBar:setPercent(percent)
    self._BodyStarImage:setVisible(false)

    if  self._CurTabIndex == 1 then
        self._SkillNameImage:setVisible(false)
        self._SkillImage:setVisible(false)self._BodyImage:loadTexture(GetWarriorBodyPath(soldierData._CharacterData.bodyImage))
        self._BodyStarImage:setVisible(true)
        ccui.Helper:seekWidgetByName(self._BodyStarImage, "Star_1"):loadTexture(GetWarriorStarImage(soldierData._CharacterData["quality"]))
        self._BodyStarImage:setFlippedX(false)
        ccui.Helper:seekWidgetByName(self._BodyStarImage, "Star_1"):setFlippedX(false)
    else
        self._SkillNameImage:setVisible(false)
        self._BodyImage:loadTexture(GetSoldierBodyPath(soldierData._CharacterData.bodyImage))
        local soldierQuality = tonumber(soldierData._CharacterData["quality"])
        if soldierQuality ~= 1 and soldierQuality ~= 2 and soldierQuality ~= 3 then
            self._BodyStarImage:setVisible(true)
            ccui.Helper:seekWidgetByName(self._BodyStarImage, "Star_1"):loadTexture(GetWarriorStarImage(soldierData._CharacterData["quality"]))
        else
            self._BodyStarImage:setVisible(false)
        end
    end

    self._AtkJuli:setString(soldierData._CharacterData.maxAttackDistance)
    local itemCount = ItemDataManager:GetItemCount(30007)
    self._ShengYuTuFeiLabel:setString("( 剩余"..stringFormat(ChineseConvert.UITrainText_ShengYuTuFei, itemCount).."突飞令 )")
    self._Time_1:setVisible(false)
    self._Time_2:setVisible(false)
    self._Time_3:setVisible(false)
    self._TrainInfo_1:setVisible(true)
    self._TrainInfo_2:setVisible(true)
    self._TrainInfo_3:setVisible(true)

    local ItemDataManager = GameGlobal:GetItemDataManager()
    local itemNum = ItemDataManager:GetItemCount(tonumber(ExpData[soldierData._Level]["highCost"]))
    ccui.Helper:seekWidgetByName(self._TrainInfo_1, "Text_1"):setString(ExpData[soldierData._Level]["lowTrain"].."经验")
    ccui.Helper:seekWidgetByName(self._TrainInfo_2, "Text_1"):setString(ExpData[soldierData._Level]["middleTrain"].."经验")
    ccui.Helper:seekWidgetByName(self._TrainInfo_3, "Text_1"):setString(ExpData[soldierData._Level]["highTrain"].."经验")
    ccui.Helper:seekWidgetByName(self._TrainInfo_1, "Text_2"):setString(ExpData[soldierData._Level]["lowCost"])
    ccui.Helper:seekWidgetByName(self._TrainInfo_2, "Text_2"):setString(ExpData[soldierData._Level]["middleCost"])
    ccui.Helper:seekWidgetByName(self._TrainInfo_3, "Text_2"):setString(itemNum)
    ccui.Helper:seekWidgetByName(self._TrainZhuanJiaBtn, "Text_23"):setVisible(false)
    local gamePlayerDataManager = GameGlobal:GetGamePlayerDataManager()
    local myselfData = gamePlayerDataManager:GetMyselfData()

    if myselfData._VIPLevel < 1 then
        self._TrainInfo_3:setVisible(false)
        ccui.Helper:seekWidgetByName(self._TrainZhuanJiaBtn, "Text_23"):setVisible(true)
        self._TrainZhuanJiaBtn:loadTextures("meishu/ui/gg/UI_gg_anniu01__03.png","meishu/ui/gg/UI_gg_anniu01__03.png","", UI_TEX_TYPE_LOCAL)
    end

    if self._TrainTimeTimerID ~= nil then
        TimerManager:RemoveTimer(self._TrainTimeTimerID)
        self._TrainTimeTimerID = nil
    end

    self._TrainNormalBtn:setBrightStyle(0)
    self._TrainQiangHuaBtn:setBrightStyle(0)
    self._TrainQiangHuaBtn:setBright(true)
    self._TrainNormalBtn:setBright(true)

    if GetPlayer()._VIPLevel > 1 then
        self._TrainZhuanJiaBtn:setBrightStyle(0) 
        self._TrainZhuanJiaBtn:setBright(true) 
    end

    if soldierData._TrainType ~= 0 and soldierData._Time > 0 then
        if soldierData._TrainType == 1 then
            self._TrainImageIng_1:setString("点击加速")
            local offTime = soldierData._TimeEnd
            self._Time_1:setString("剩余"..CreateTimeString(offTime))
            self._Time_1:setVisible(true)
            self._TrainInfo_1:setVisible(false)
            self._TrainQiangHuaBtn:setBright(false)
            self._TrainZhuanJiaBtn:setBright(false)
            self._TrainImageIng_2:setString("12小时训练")
            self._TrainImageIng_3:setString("24小时训练")
            self._TrainImageIng_1:setTextColor(cc.c3b(111, 50, 16))
            self._TrainImageIng_2:setTextColor(cc.c3b(80, 80, 80))
            self._TrainImageIng_3:setTextColor(cc.c3b(80, 80, 80))
        elseif soldierData._TrainType == 2 then
            self._TrainImageIng_2:setString("点击加速")
            local offTime = soldierData._TimeEnd
            self._Time_2:setString("剩余"..CreateTimeString(offTime))
            self._Time_2:setVisible(true)
            self._TrainInfo_2:setVisible(false)
            self._TrainNormalBtn:setBright(false)
            self._TrainZhuanJiaBtn:setBright(false)
            self._TrainImageIng_1:setString("8小时训练")
            self._TrainImageIng_3:setString("24小时训练")
            self._TrainImageIng_2:setTextColor(cc.c3b(111, 50, 16))
            self._TrainImageIng_1:setTextColor(cc.c3b(80, 80, 80))
            self._TrainImageIng_3:setTextColor(cc.c3b(80, 80, 80))
        elseif soldierData._TrainType == 3 then
            self._TrainImageIng_3:setString("点击加速")
            local offTime = soldierData._TimeEnd
            self._Time_3:setString("剩余"..CreateTimeString(offTime))
            self._Time_3:setVisible(true)
            self._TrainInfo_3:setVisible(false)
            self._TrainNormalBtn:setBright(false)
            self._TrainQiangHuaBtn:setBright(false)
            self._TrainImageIng_1:setString("8小时训练")
            self._TrainImageIng_2:setString("12小时训练")
            self._TrainImageIng_3:setTextColor(cc.c3b(111, 50, 16))
            self._TrainImageIng_1:setTextColor(cc.c3b(80, 80, 80))
            self._TrainImageIng_2:setTextColor(cc.c3b(80, 80, 80))
        end
        if self._TrainTimeTimerID == nil then
            self._TrainTimeTimerID = TimerManager:AddTimer(1, handler(self, self.onTrainTimeChange))
        end
    else
        self._TrainImageIng_1:setString("8小时训练")
        self._TrainImageIng_2:setString("12小时训练")
        self._TrainImageIng_3:setString("24小时训练")
        self._TrainImageIng_1:setTextColor(cc.c3b(111, 50, 16))
        self._TrainImageIng_2:setTextColor(cc.c3b(111, 50, 16))
        self._TrainImageIng_3:setTextColor(cc.c3b(111, 50, 16))
    end

    self:updateTeamNum()

    -- 士兵动画
    if  self._CurTabIndex == 2 then
        if self._AnimParentNode then
            self._AnimParentNode:removeAllChildren()
            local path = GetWarriorCsbPath(soldierData._CharacterData.resName)
            if  self._CurTabIndex == 2 then
                path = GetSoldierCsbPath(soldierData._CharacterData.resName)
            end
            local animNode = cc.CSLoader:createNode(path)
            local anim = cc.CSLoader:createTimeline(path)
            self._AnimParentNode:addChild(animNode)
            anim:play("Walk",true)
            animNode:runAction(anim)
        end
    elseif self._CurTabIndex == 1 then
        if self._AnimParentNode then
            self._AnimParentNode:removeAllChildren()
        end
    end

    return 
end

function UITrain:update(sender)
    local id = sender._usedata
    self:updateUI(id)

    local cell = self._GridView:cellAtIndex(self._CellIndex)
    local layout = cell:getChildByTag(tonumber(self._CellIndex))
    local panel = seekNodeByName(layout, "Panel_1")
    local level = seekNodeByName(layout, "Text_2")
    local soldier =  self:getCurObject(self._CurTabIndex, self._CellIndex, 1) 
    level:setString("lv"..soldier._Level)
end

function UITrain:createSelectFrame()
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

function UITrain:selectAnimation(node)
    self._SelectFrame:removeFromParent(true)
    node:addChild(self._SelectFrame, 50)
    local actionBy = cc.RotateBy:create(1.5, -360)
    self._SelectFrame:runAction(cc.RepeatForever:create(actionBy)) 
end

return UITrain