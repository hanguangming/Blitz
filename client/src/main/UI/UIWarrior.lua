----
-- 文件名称：UIWarrior.lua
-- 功能描述：warrior
-- 文件说明：warrior
-- 作    者：田凯
-- 创建时间：2015-6-24
--  修改
require("main.UI.UIBase")
require("main.UI.UITypeDefine") 

local UISystem = GameGlobal:GetUISystem() 
local UIWarrior = class("UIWarrior", UIBase)

-- 服务器返回角色数据信息
local CharacterServerDataManager = require("main.ServerData.CharacterServerDataManager")
-- 物品信息数据
local ItemDataManager = GameGlobal:GetItemDataManager()
-- 经验表数据 
local ExpData = GameGlobal:GetExpDataManager()
-- 武将表数据
local SoldierData = require("main.ServerData.CharacterServerDataManager")

-- 武将装备tag
-- 武器
local W_STATE_WEAPON = 2
-- 护腕
local W_STATE_CUFF = 3
-- 头盔
local W_STATE_HELMET = 4
-- 胸甲
local W_STATE_CUIRASS =5
-- 鞋子
local W_STATE_SHOE = 6
-- 披风
local W_STATE_CAPE = 7

-- 招募
local W_STATE_RECRUIT = 10 
-- 训练
local W_STATE_TRAIN = 11
-- 转生   
local W_STATE_REBORN = 12
-- 出战  
local W_STATE_FIGTING = 13
-- 关闭 
local W_STATE_CLOSE = 14   

-- 对应武将品质的特效
local WARRIOR_STAR_MAP = {
    [4] = "csb/texiao/ui/T_u_WJ_biaoshi_1.csb",--一流 
    [5] = "csb/texiao/ui/T_u_WJ_biaoshi_2.csb",--传奇
    [6] = "csb/texiao/ui/T_u_WJ_biaoshi_3.csb",--无双
    [7] = "csb/texiao/ui/T_u_WJ_biaoshi_4.csb" --  神
}

-- 装备位置及其对应名字
local EQUIP_POS = {2, 5, 6, 4, 3, 7 ,8 ,9, 10, 11}

local EQUIP_NAME = { ChineseConvert["UIEquip_2"], 
                     ChineseConvert["UIEquip_5"],
                     ChineseConvert["UIEquip_6"],
                     ChineseConvert["UIEquip_4"],
                     ChineseConvert["UIEquip_3"], 
                     ChineseConvert["UIEquip_7"] 
                    }
                    
function UIWarrior:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_WarriorUI
    self._ResourceName = "UIWarrior.csb"  
end

function UIWarrior:Load()
    UIBase.Load(self)
    
    -- 初始化装备与品质资源
    self._bodyEquip = {}
    self._starEquip = {}
    
    -- 三个页签并注册监听触摸事件(1信息, 2招募--tab = 10, 3训练-- tag = 11)
    self._tabButtonList = {}
    for i = 1, 3 do 
        if i == 1 then
            local tabBtn1 = self:GetWigetByName("ButtonTab1")
            self._tabButtonList[1] = tabBtn1
        end
        local tabBtn = self:GetWigetByName("ButtonTab"..i)
        tabBtn:setTag(8 + i)
        self._tabButtonList[i] = tabBtn
        if i == 3 then
            tabBtn:setBrightStyle(1)
        end 
        tabBtn:addTouchEventListener(handler(self, self.touchEvent))
    end

    -- 候战(tag = 13)和转生(tag = 12)按钮，并注册监听触摸事件
    for i = 2, 3 do
        local btn = self:GetWigetByName("btn_"..i)
        btn:setTag(10 + i)
        if i == 2 then
            self._rebornButton = btn
        end
        if i == 3 then
            self._embattleButton = btn
            self._embattleText =  seekNodeByName(seekNodeByName(self._RootPanelNode, "btn_3"), "name_2")
        end
        btn:addTouchEventListener(handler(self, self.touchEvent))
    end 

    for i = 1, 8 do
        local equip =  self:GetWigetByName("equip_"..i)
        equip:setTag(EQUIP_POS[i])
        equip:addTouchEventListener(handler(self, self.touchEvent))
        equip:setUserObject(self._RootUINode)
        self._bodyEquip[EQUIP_POS[i]] = seekNodeByName(equip, "Image_1") 
        self._bodyEquip[EQUIP_POS[i]]:loadTexture("meishu/ui/gg/null.png", UI_TEX_TYPE_LOCAL)
        self._starEquip[EQUIP_POS[i]] = equip
    end
    
    -- 武将显示基本信息的文本资源
    self._warriorData = {}
    for i = 1, 10 do
        local label =  self:GetWigetByName("Text_"..i)
        local label1 =  self:GetWigetByName("Text_"..i.."_0")
        if label ~= nil then
            self._warriorData[i] = label1
        end
    end
    
    -- 经验显示文本
    self._lbExpText = self:GetWigetByName("Text_LB_Exp")
    
    -- 初始化列表容器资源
    self._pageview = self:GetWigetByName("PageView")
    
    -- 显示技能信息的父节点资源
    self._skillDataPanel = seekNodeByName(self._RootPanelNode, "Panel_4")
    self._skillDataPanel:setSwallowTouches(false)
    self._skillDataPanel:setTag(21)
    self._skillDataPanel:addTouchEventListener(handler(self, self.touchEvent))
    
    -- 显示武将基本信息的父节点资源
    self._baseInfoPanel = seekNodeByName(self._RootPanelNode, "Panel_info")
    self._baseInfoPanel:setSwallowTouches(false)
    self._baseInfoPanel:setTag(22)
    self._baseInfoPanel:addTouchEventListener(handler(self, self.touchEvent))
    
    -- 技能具体信息资源
    -- 技能图标icon 
    self._skillIcon = self:GetWigetByName("skillTip")
    -- 技能名
    self._skillName = self:GetWigetByName("skillNameTip")
    -- 二段伤害信息父节点
    self._skillStage2Panel = seekNodeByName(self._skillDataPanel, "Panel_11")
    -- 三段伤害信息父节点
    self._skillStage3Panel = seekNodeByName(self._skillDataPanel, "Panel_12")
    -- 二三段技能为空时显示未开启
    self._skillStage2Null = self:GetWigetByName("Text_25")
    self._skillStage3Null = self:GetWigetByName("Text_26")
    -- 技能一、二、三段的伤害与距离
    self._skillHurtOne = self:GetWigetByName("Text_1_SkillHurt")
    self._skillRangeOne = self:GetWigetByName("Text_1_SkillRange")
    self._skillHurtTwo = self:GetWigetByName("Text_2_SkillHurt")
    self._skillRangeTwo = self:GetWigetByName("Text_2_SkillRange")
    self._skillHurtThree = self:GetWigetByName("Text_3_SkillHurt")
    self._skillRangeThree = self:GetWigetByName("Text_3_SkillRange")
    
    -- 详细（技能）按钮，点击后出现技能、详细信息
    self._skillBtn = self:GetWigetByName("skill")
    self._skillBtn:setTag(21)
    self._skillBtn:addTouchEventListener(handler(self, self.touchEvent))
    
    -- 解雇按钮
    self._fireWarriorBtn = self:GetWigetByName("removeWarrior")
    self._fireWarriorBtn:setTag(18)
    self._fireWarriorBtn:addTouchEventListener(handler(self, self.touchEvent))
    
    -- 武将列表数字显示
    self._pageLabel = self:GetWigetByName("Label_1")
    self._pageLabel:setString("0/20")
    self._pageLabel:setTag(-2)
    self._pageLabel:addTouchEventListener(handler(self, self.touchEvent))
    
    -- 武将全身像
    self._warriorBodyImage = seekNodeByName(seekNodeByName(self._RootPanelNode, "Panel_5"), "bodyImage")
    self._warriorBodyImage:loadTexture("meishu/wujiang/quanshenxiang/Q_baosanniang.png", UI_TEX_TYPE_LOCAL)
    self._warriorBodyImage:setVisible(false)
    
    -- 武将品质图标
    self._warriorStarImage = self:GetUIByName("Star_1")
    self._warriorStarImage:setVisible(false)
   
    -- 血量成长
    self._hpUpLabel = self:GetWigetByName("Text_3_0_0")
    -- 攻击成长
    self._attackUpLabel = self:GetWigetByName("Text_3_0_0_0")
    -- 装备血量加成
    self._equipHpLabel = self:GetWigetByName("Text_4_0_0")
    -- 装备攻击加成
    self._equipAtkLabel = self:GetWigetByName("Text_4_0_1")
    -- 装备攻击速度加成
    self._equipAtkSpeedLabel = self:GetWigetByName("Text_4_0_2")
    
    
    -- 设置经验进度条
    self._expProgress = seekNodeByName(self:GetWigetByName("Loading"), "LoadingBar")
    self._expProgress:setPercent(0)

    -- 创建武将列表及滑动条
    self._gridView =  CreateTableView_(4, 8, 200, 428, cc.TABLEVIEW_FILL_BOTTOMUP, self)
    self._pageview:addChild(self._gridView)
    self._slider = self:GetWigetByName("Slider_1")
    self._slider:setVisible(false)
    self._slider:getParent():setVisible(false)

    self._warriorData[11] = self:GetWigetByName("Text_11")
    self._warriorData[16] = self:GetWigetByName("Name")
    -- 武将等级
    self._warriorData[17] = self:GetWigetByName("Data_15")
    
    self._RootPanelNode:setSwallowTouches(true)
    self:GetWigetByName("Panel_2"):setSwallowTouches(false)
    
    -- 滚动列表添加上下显示箭头
    self._pageListUp = self:GetWigetByName("pageListUp")
    self._pageListDown = self:GetWigetByName("pageListDown")
    
    local closeBtn = self:GetWigetByName("Close")
    closeBtn:setTag(14)
    closeBtn:addTouchEventListener(handler(self, self.touchEvent))
end

function UIWarrior:Unload()
    UIBase.Unload()
end

function UIWarrior:Open()
    UIBase.Open(self)
    
    -- 初始化武将作战状态,(默认侯战0，出战1)
    self._emBattleState = 0
    
    -- 标记选中的武将(默认第一个)
    self._curWarriorIndex = 1
    
    -- 初始化选中武将ID
    self._curWarriorId = -1
    
    -- 初始化武将数量
    self._warriorCount = 0
    self._warriorCells = 0
    
    -- 初始化当前拥有的武将
    self._warrior = nil
    
    -- 初始化拥有的武将Id
    self._warriorId = {}
    
    -- 装备类型
    self._equipType = 1

    -- pve可出战最大武将数
    self._maxPveWarriorCount = 0
    -- 记录切换武将操作前的武将ID
    self._previousWarrriorID = -1
    
    -- 当前武将效果
    self._curWarriorStarEffect = nil
    
    -- 选中光圈特效
    self._selectFrame = self:createSelectFrame()
    self._selectFrame:retain()
    self._gridView:addChild(self._selectFrame)
    
    self._pageListUp:setVisible(false)
    self._pageListDown:setVisible(true)

    -- 初始化UI信息
    self:openUISucceedListener()
    
    self:addEvent(GameEvent.GameEvent_UIWarrior_Succeed, self.openUISucceedListener)
    self:addEvent(GameEvent.GameEvent_UIWarrior_Embattle, self.emBattleSucceedListener)
    self:addEvent(GameEvent.GameEvent_UIWarrior_Equip_Take, self.takeEquipListener)
    self:addEvent(GameEvent.GameEvent_UIWarrior_Update, self.updateWarriorInfoListener)
    
end

function UIWarrior:Close()
    UIBase.Close(self)
 
    removeNodeAndRelease(self._curWarriorStarEffect,false)
    removeNodeAndRelease(self._selectFrame,true)
end

-- 成功打开UI,加载武将相关信息
function UIWarrior:openUISucceedListener()

    -- 列表中cell标记重置为0
    self._curCellIdx = 0
    self._warriorId = {}
    
    local ownleaderList = CharacterServerDataManager._OwnLeaderList
    -- 得到拥有的武将
    self._warrior = ownleaderList
    -- 得到武将数量
    self._warriorCount = table.nums(ownleaderList) 
    self._warriorCells = self._warriorCount
    
    if GetPlayer()._VIPLevel <= 12 then
        self._pageLabel:setString(self._warriorCount.."/"..GameGlobal:GetVipDataManager()[GetPlayer()._VIPLevel].heromax)
    end

    -- 保存已拥有武将的Id到_warriorId
    for i,v in pairs(self._warrior) do
        table.insert(self._warriorId, i) 
    end

    -- 重新排序武将列表
    self:resortWarriorList()
    -- 刷新列表
    self._gridView:reloadData()
    -- 刷新武将信息界面
    self:refreshWarriorInfo(1)
    
    self:simulateClickButton(0, 1)
    
    -- pve武将出战数量
    self._maxPveWarriorCount = GetGlobalData()._TechnologyList[2][2]
    for i = 5, 7 do
        if tonumber(self._maxPveWarriorCount) == i then
            self._maxPveWarriorCount = self._maxPveWarriorCount - 2
            break
        end
    end
    if tonumber(self._maxPveWarriorCount) == 0 then
        self._maxPveWarriorCount = 2
    end
end

-- 更新武将信息
function UIWarrior:updateWarriorInfoListener(event)
    local warrior = event._usedata
    
    self._equipAtkSpeedLabel:setString("")
    self._equipHpLabel:setString("")
    self._equipAtkLabel:setString("")
    
    self._warriorData[4]:setString((warrior._Hp + warrior._EquipHp))
    if tonumber(warrior._EquipHp) ~= 0 then
        self._equipHpLabel:setString("( +"..warrior._EquipHp.." )")
    end
    self._warriorData[5]:setString((warrior._Attack + warrior._EquipAtk))
    if tonumber(warrior._EquipAtk) ~= 0 then
        self._equipAtkLabel:setString("( +"..warrior._EquipAtk.." )")
    end
    self._warriorData[6]:setString((warrior._AtkSpeed + warrior._EquipAtkSpeed))
    if tonumber(warrior._EquipAtkSpeed) ~= 0 then
        self._equipAtkSpeedLabel:setString("( +"..warrior._EquipAtkSpeed.. " )")
    end
    
    self._hpUpLabel:setString(warrior._CharacterData["hpup"])
    self._attackUpLabel:setString(warrior._CharacterData["attackup"])
    
    for j = 4, 6 do
        local size2, _ = string.find(self._warriorData[j]:getString(), ' ')
        local start, _ = string.find(self._warriorData[j]:getString(), ')')
        for i = 0, start  do
            local letter = self._warriorData[j]:getLetter(tonumber(i))
            letter:setColor(cc.c3b(250,255,250))
        end
        for i = start, size2 - 2  do
            local letter = self._warriorData[j]:getLetter(tonumber(i))
            letter:setColor(cc.c3b(0,255,0))
        end
    end
    
end

-- 穿上或脱下装备，刷新武将基本信息
function UIWarrior:takeEquipListener()
    self:refreshWarriorInfo(self._curWarriorIndex)
end

-- 模拟点击事件
function UIWarrior:simulateClickButton(idx, tag)
    local cell = self._gridView:cellAtIndex(idx)
    if cell ~= nil then
        local layout = cell:getChildByTag(idx)
        local panel
        if tag == 1 then                 
            panel = seekNodeByName(layout, "Panel_1")
        else
            panel = seekNodeByName(layout, "Panel_2")
        end
        local button = seekNodeByName(panel, "Button_2")
        if button ~= nil then
            SimulateClickButton(button, handlers(self, self.TableViewItemTouchEvent, 2)) 
        end
    end
end

function UIWarrior:ScrollViewDidScroll(view)
    local point = view:getContentOffset()
    local len = view:getContentSize().height - view:getViewSize().height
    local percent = - (point.y / len)

    if percent >= 1 then
        self._pageListUp:setVisible(false)
        self._pageListDown:setVisible(true)
    elseif percent <= 0 and len >=0  then
        self._pageListUp:setVisible(true)
        self._pageListDown:setVisible(false)
    end
end

function UIWarrior:TableCellTouched(view, cell)
    local tag = cell:getIdx()
    self._cellType = tag
    self._curCellIdx = tag
    self._curWarriorIndex = tag + 1
    
    -- 刷新武将信息界面
    self:refreshWarriorInfo(self._curWarriorIndex)

    local layout = cell:getChildByTag(tonumber(self._curWarriorIndex - 1))
    local panel = seekNodeByName(layout, "Panel_1")
    
    -- cell缩放动画
    local actionTo = cc.ScaleTo:create(0.1, 0.9)
    local actionTo2 = cc.ScaleTo:create(0.1, 1.0)
    panel:runAction(cc.Sequence:create(actionTo, actionTo2)) 
   
    -- 选中动画
    if self._previousWarrriorID ~= self._curWarriorId then
        self:runSelectAnimation(panel)
    end
    
    self._previousWarrriorID = self._warriorId[tonumber(self._curWarriorIndex)]
end

function UIWarrior:CellSizeForTable(view, idx)
    return 120, 85
end

function UIWarrior:NumberOfCellsInTableView()
    return self._warriorCells
end

function UIWarrior:TableViewItemTouchEvent(value)
    local eventType = value
    if type(value) == "table" then
        eventType = value.eventType
    end
    if eventType == ccui.TouchEventType.ended then
    end
end

function UIWarrior:TableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
    end
    cell:removeAllChildren(true)
    local layout = cc.CSLoader:createNode("csb/ui/WarriorItem.csb")
    local panel = seekNodeByName(layout, "Panel_1")
    local button = seekNodeByName(panel, "Button_2")
    button:addTouchEventListener(self.TableViewItemTouchEvent)
    button:setTag(idx)
    panel:setSwallowTouches(false)
    button:setSwallowTouches(false)
    seekNodeByName(panel, "Image_2"):setSwallowTouches(false)
    layout:setPosition(cc.p(0, 0))
    cell:addChild(layout, 0, idx) 
    self:InitCell(cell, idx)
    return cell
end

-- 初始化武将列表中武将头像信息
function UIWarrior:InitCell(cell, idx)
    local layout = cell:getChildByTag(tonumber(idx))
    local panel = seekNodeByName(layout, "Panel_1")
    -- 头像
    local head1 = seekNodeByName(panel, "Image_2")
    -- 名字
    local name1 = seekNodeByName(panel, "Text_1")
    -- 等级
    local level = seekNodeByName(panel, "Text_2")
    -- 作战状态
    local battleImage = seekNodeByName(panel, "Image_Battle")
    -- 类型图标
    local typeImage = seekNodeByName(panel, "Image_Type")
    -- 训练图标
    local trainImage = seekNodeByName(panel, "Image_TrainIcon")
    -- 武将品质底框
    local headDiColorImage = seekNodeByName(panel, "Image_35")
--    local warriorId = -1
    if idx + 1 <= self._warriorCount then
--        warriorId = self._warriorId[idx + 1]
        local warrior = CharacterServerDataManager:GetLeader(self._warriorId[idx + 1])
         print(warrior._CharacterData["name"])
        local head1Name = warrior._CharacterData["headName"]
        head1:setVisible(true)
        level:setString("lv"..warrior._Level)
        head1:loadTexture(GetWarriorHeadPath(head1Name), UI_TEX_TYPE_LOCAL)
        print(warrior._CharacterData["soldierType"])
        print(GetSoldierProperty(warrior._CharacterData["soldierType"]))
        typeImage:loadTexture(GetSoldierProperty(warrior._CharacterData["soldierType"]))
        name1:setString(warrior._CharacterData["name"])
       
        battleImage:setVisible(false)
        seekNodeByName(panel, "Image_1"):setVisible(false)
        if warrior._CurrentState == 1 then
            battleImage:setVisible(true)
        end
        headDiColorImage:loadTexture(GetHeadColorImage(warrior._CharacterData["quality"]))
        trainImage:setVisible(false)
        if warrior._Time ~= 0 then
            trainImage:setVisible(true)
        end
    end

    local warriorId = self._warriorId[idx + 1]
    if warriorId ~= -1 then
        if self._previousWarrriorID == -1 then
            self._previousWarrriorID = warriorId
        end
        if self._previousWarrriorID == warriorId then
            self:runSelectAnimation(panel)
        end
    end
end

function UIWarrior:touchEvent(sender, eventType)
    if type(eventType) == "table" then
        eventType = eventType.eventType
    end
    if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
        if tag == W_STATE_WEAPON then
            self:openEquipList(tag)
        elseif tag == W_STATE_CUIRASS then
            self:openEquipList(tag)
        elseif tag == W_STATE_SHOE then
            self:openEquipList(tag)
        elseif tag == W_STATE_HELMET then
            self:openEquipList(tag)
        elseif tag == W_STATE_CUFF then
            self:openEquipList(tag)
        elseif tag == W_STATE_CAPE then
            local warrior = CharacterServerDataManager:GetLeader(self._curWarriorId)
            local quality = warrior._CharacterData["quality"]
            if quality >= 4 then
                self:openEquipList(tag)
            end
            -- 招募
        elseif tag == W_STATE_RECRUIT then
            local recruit = UISystem:OpenUI(UIType.UIType_UIRecruit)
            recruit:EnterPlayAnimation(true)
            SendMsg(PacketDefine.PacketDefine_RecruitStore_Send)
            -- 训练
        elseif tag == W_STATE_TRAIN then
            if not self:checkWarriorNull() then
                return
            end
            UISystem:CloseUI(UIType.UIType_WarriorUI)
            local  train = UISystem:OpenUI(UIType.UIType_TrainUI)
            train:ChangeTabState(1)
            -- 转生
        elseif tag == W_STATE_REBORN then
            if not self:checkWarriorNull() then
                return
            end
            local warrior = CharacterServerDataManager:GetLeader(self._curWarriorId)
            local warriorID = warrior._CharacterData["uphero"]
            if warriorID ~= 0 and self:quickCheckWarrior() then
                UISystem:OpenUI(UIType.UIType_RebornUI)
                performWithDelay(sender, handler(self, self.delayCallBack), 0)
            else
                local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_zs_05))
            end
            -- 出战
        elseif tag == W_STATE_FIGTING then
            if not self:checkWarriorNull() then
                return
            end
            if self._emBattleState == 0 then
                SendMsg(PacketDefine.PacketDefine_HeroUse_Send, {self._curWarriorId, self._emBattleState})
            else
                if self._maxPveWarriorCount > self:getCurrentFightWarriorCount() then
                    SendMsg(PacketDefine.PacketDefine_HeroUse_Send, {self._curWarriorId, self._emBattleState})
                else
                    CreateTipAction(self._RootUINode, ChineseConvert["UIWarriorPveNumLimit"], cc.p(480, 200))
                    sender:setBrightStyle(1)
                end
            end
        elseif tag == W_STATE_CLOSE then
            UISystem:CloseUI(UIType.UIType_WarriorUI) 
            UISystem:CloseUI(UIType.UIType_TrainUI) 
        elseif tag == 17 then
            self._skillDataPanel:setVisible(true)
            -- 解雇
        elseif tag == 18 then
            local UITip =  GameGlobal:GetUISystem():OpenUI(UIType.UIType_TipUI)
            UITip:SetStyle(0, "是否解雇该武将？")
            UITip:RegisteDelegate(handler(self, self.sendFireWarriorMessage), 1)
        elseif tag == 21 or tag == 22 then
            if self._warriorCount < 0 then
                return
             end
            if self._skillDataPanel:isVisible() then
                self._baseInfoPanel:setVisible(true)
                self._skillDataPanel:setVisible(false)
                seekNodeByName(self._skillBtn, "Text_18"):setString("详细")
            else
                self._baseInfoPanel:setVisible(false)
                self._skillDataPanel:setVisible(true)
                seekNodeByName(self._skillBtn, "Text_18"):setString("技能")
            end
        end
    end
end

-- 发送解雇武将消息
function UIWarrior:sendFireWarriorMessage()
    SendMsg(PacketDefine.PacketDefine_HeroEmploy_Send, {self._curWarriorId, 0})
end

-- 检查武将转生条件
function UIWarrior:quickCheckWarrior()
    local rebornWarriorList = {}
    local warrior = CharacterServerDataManager:GetLeader(self._curWarriorId)
    for i, v in pairs(CharacterServerDataManager._OwnLeaderList) do
        if v._CharacterData["quality"] > 3 then
            return true
        end 
        if v._CharacterData["quality"] == warrior._CharacterData["quality"] then
            table.insert( rebornWarriorList, i)
        end
    end
    return #rebornWarriorList >= 5
end

function UIWarrior:delayCallBack()
    local warrior = CharacterServerDataManager:GetLeader(self._curWarriorId)
    DispatchEvent(GameEvent.GameEvent_UIReborn_Succeed, warrior)
end

-- 检查武将是否为空
function UIWarrior:checkWarriorNull()
    if self._warriorCount > 0 then
        return true
    end
    return false
end

-- 打开装备列表
function UIWarrior:openEquipList(tag)
    if self:checkWarriorNull() then
        self._equipType = tag 
        self._equipGuid = 0
        local warrior = CharacterServerDataManager:GetLeader(self._curWarriorId)       
        for i = 1, 8 do
            if warrior._Equip[i] ~= 0 then 
                local tmpequip = ItemDataManager:GetItem(warrior._Equip[i]) 
                if tmpequip ~= nil then
                    if tmpequip._PropData["subtype"] == self._equipType then
                          self._equipGuid = warrior._Equip[i] 
                    end
                end
            end
        end 
        UISystem:OpenUI(UIType.UIType_WarriorListUI)
    end
end

function UIWarrior:emBattleSucceedListener(event)
    local state = event._usedata
    local warrior = CharacterServerDataManager:GetLeader(self._curWarriorId)
    warrior._CurrentState = state
    
    if  self._emBattleState == 0 then
        self._emBattleState = 1
        self._embattleText:setString(GameGlobal:GetTipDataManager(UI_BUTTON_NAME_1))
    else
        self._emBattleState = 0
        self._embattleText:setString(GameGlobal:GetTipDataManager(UI_BUTTON_NAME_2))
    end
   
    self:resortWarriorList(self._curWarriorId)
    self._gridView:reloadData()
    self:refreshWarriorInfo(self._curWarriorIndex)
    self:simulateClickButton(self._curCellIdx, self._cellType)
    
end

-- 获得当前出战武将数
function UIWarrior:getCurrentFightWarriorCount()
    local currentFightWarriorCount = 0
    for k,v in pairs(self._warrior) do
        if v._CurrentState == 1 then
            currentFightWarriorCount = currentFightWarriorCount + 1
        end
    end
    return currentFightWarriorCount
end

-- 重新排序武将列表
function UIWarrior:resortWarriorList(id)
        table.sort(self._warriorId, function(a, b)
        local warrior1 = CharacterServerDataManager:GetLeader(a)
        local warrior2 = CharacterServerDataManager:GetLeader(b)
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
    
    if id ~= nil then
        for i, v in pairs(self._warriorId) do
            if v == id then
                self._curWarriorIndex = i
                self._curCellIdx = math.floor((i - 1) / 2)
                self._cellType = i % 2
            end
        end 
   end
end

-- 检查转生
function UIWarrior:CheckRebornWarrior(wid)
    for _, i in pairs(self._warriorId) do
        if i == wid then   
            return true
        end
    end
    return false
end

-- 得到最高军阶
function UIWarrior:getWarriorMaxIntelligent(warrior)
    local intelligent = warrior._CharacterData["intelligent"]
    if intelligent == 3 then
        intelligent = 0
    elseif intelligent == 5 then
        intelligent = 4
    elseif intelligent == 7 then
        intelligent = 6
    elseif intelligent == 8 then
        intelligent = 7
    elseif intelligent == 6 then
        intelligent = 5
    elseif intelligent == 4 then
        intelligent = 3
    end
    return intelligent
end

-- 刷新武将信息
function UIWarrior:refreshWarriorInfo(index)
    if self._warriorCount > 0 then
        local warrior = CharacterServerDataManager:GetLeader(self._warriorId[index])
        if warrior == nil then
            return
        end
        if warrior._CurrentState == 1 then
            self._emBattleState = 0
            self._embattleText:setString(GameGlobal:GetTipDataManager(UI_BUTTON_NAME_2))
            self._embattleButton:setBrightStyle(0)
        else
            self._emBattleState = 1
            self._embattleText:setString(GameGlobal:GetTipDataManager(UI_BUTTON_NAME_1))
            if self._maxPveWarriorCount <= self:getCurrentFightWarriorCount() then
                self._embattleButton:setBrightStyle(1)
            else
                self._embattleButton:setBrightStyle(0)
            end
        end
        
        if warrior._CharacterData["quality"] < 4 then
            self._fireWarriorBtn:setVisible(true)
            self._embattleButton:setPositionX(390)
        else
            self._fireWarriorBtn:setVisible(false)
        end
        
        local warriorID
        if GameGlobal:GetChangeDataManager()[self._warriorId[index]] == nil then
            warriorID = 0
        else
            warriorID = GameGlobal:GetChangeDataManager()[self._warriorId[index]]["newid"]
        end
        self._rebornButton:setVisible(true)
        if warriorID == 0 or self:CheckRebornWarrior(warriorID) then
             if warrior._CharacterData["quality"] >= 4 then
                self._embattleButton:setPositionX(480)
             end
            self._rebornButton:setVisible(false)
        else
            self._fireWarriorBtn:setVisible(false)
            self._embattleButton:setPositionX(390)
        end
        
        local bodyName = GetWarriorBodyPath(warrior._CharacterData["bodyImage"])
        self._curWarriorId = self._warriorId[index]
        self._warriorBodyImage:loadTexture(bodyName, UI_TEX_TYPE_LOCAL)
        self._warriorBodyImage:setVisible(true)
        self._warriorStarImage:setVisible(true)
        self._skillIcon:loadTexture(GetSkillPath(warrior._CharacterData["skillicon"]))
        self._skillName:setString(warrior._CharacterSkillData2["name"])
        self._skillHurtOne:setString(math.floor(warrior._CharacterData["skill2"] * warrior._CharacterData["skill2damage"] / 100))
        self._skillRangeOne:setString(warrior._CharacterSkillData2["zoneShowString"])
        if tonumber(warrior._CharacterData["skill3"]) ~= 0 then
            self._skillStage2Panel:setVisible(true)
            self._skillStage2Null:setVisible(false)
            self._skillHurtTwo:setString(math.floor(warrior._CharacterData["skill3"] * warrior._CharacterData["skill3damage"] / 100))
            self._skillRangeTwo:setString(warrior._CharacterSkillData2["zoneShowString"])
        else
            self._skillStage2Panel:setVisible(false)
            self._skillStage2Null:setVisible(true)
        end
        if tonumber(warrior._CharacterData["skill4"]) ~= 0 then
            self._skillStage3Panel:setVisible(true)
            self._skillStage3Null:setVisible(false)
            self._skillHurtThree:setString(math.floor(warrior._CharacterData["skill4"] * warrior._CharacterData["skill4damage"] / 100))
            self._skillRangeThree:setString(warrior._CharacterSkillData2["zoneShowString"])
        else
            self._skillStage3Panel:setVisible(false)
            self._skillStage3Null:setVisible(true)
        end
        
        local soldierData = SoldierData:GetLeader(self._warriorId[index])
        local expMax = ExpData[soldierData._Level]["soldierExp"]
        self._expProgress:setPercent(tonumber(warrior._Exp) / tonumber(expMax) * 100)
        local lbExpString = string.format("%d/%d", warrior._Exp, expMax)
        self._lbExpText:setString(lbExpString)
        self._warriorData[1]:setString(warrior._CharacterData["name"])
        self._warriorData[2]:setString(GetSoldierType(warrior._CharacterData["soldierType"]))
        self._warriorData[3]:setString(GetSoldierAttackType(tonumber(warrior._CharacterSkillData1["zoneType"])))
        self._equipAtkSpeedLabel:setString("")
        self._equipHpLabel:setString("")
        self._equipAtkLabel:setString("")
        self._warriorData[4]:setString((warrior._Hp + warrior._EquipHp))
        if tonumber(warrior._EquipHp) ~= 0 then
            self._equipHpLabel:setString("( +"..warrior._EquipHp.." )")
        end
        self._warriorData[5]:setString((warrior._Attack + warrior._EquipAtk))
        if tonumber(warrior._EquipAtk) ~= 0 then
            self._equipAtkLabel:setString("( +"..warrior._EquipAtk.." )")
        end
        self._warriorData[6]:setString((warrior._AtkSpeed + warrior._EquipAtkSpeed))
        if tonumber(warrior._EquipAtkSpeed) ~= 0 then
            self._equipAtkSpeedLabel:setString("( +"..warrior._EquipAtkSpeed.." )")
        end
        
        self._hpUpLabel:setString(warrior._CharacterData["hpup"])
        self._attackUpLabel:setString(warrior._CharacterData["attackup"])
        self._CurWarriorStar = 0
        for i = 1, 7 do
            if warrior._Equip[i] ~= 0 then 
                local equip = ItemDataManager:GetItem(warrior._Equip[i]) 
                self._CurWarriorStar = self._CurWarriorStar + GetPropDataManager()[equip._ItemTableID]["star"]
            end
        end
        self._warriorData[7]:setString(warrior._CharacterData["maxAttackDistance"]) 
        self._warriorData[8]:setString(warrior._MoveSpeed)
        self._warriorData[9]:setString(GetWarriorQuality(warrior._CharacterData["intelligent"]))
        local intelligent = self:getWarriorMaxIntelligent(warrior)
        self._warriorData[11]:setString(warrior._CharacterSkillData2["zoneShowString"])
        self._warriorData[16]:setString(warrior._CharacterData["name"])
        self._warriorData[16]:setColor(GetQualityColor(warrior._CharacterData["quality"]))
        self._warriorData[17]:setString(warrior._Level)
        self._warriorStarImage:loadTexture(GetWarriorStarImage(warrior._CharacterData["quality"]), UI_TEX_TYPE_LOCAL)

        for i = 1 , 8 do
            if EQUIP_NAME[i] ~= nil then
                self._starEquip[EQUIP_POS[i]]:setTitleText(EQUIP_NAME[i])
            end
            self._bodyEquip[EQUIP_POS[i]]:loadTexture("meishu/ui/gg/null.png", UI_TEX_TYPE_LOCAL)
        end
        
        for i = 1 , 8 do
            if warrior._Equip[i] ~= 0 then 
                local equip = ItemDataManager:GetItem(warrior._Equip[i]) 
                if equip ~= nil then
                    self._starEquip[equip._PropData["subtype"]]:setTitleText("")
                    self._bodyEquip[equip._PropData["subtype"]]:loadTexture(GetPropPath(equip._PropData["icon"]), UI_TEX_TYPE_LOCAL)
                end
            end
        end
        
        -- 改变武将星级特效
        self:changeWarriorStarEffect(warrior)
    else
        -- 没有武将
    end
end

-- 改变武将星级特效
function UIWarrior:changeWarriorStarEffect(warrior)
    if self._curWarriorStarEffect ~= nil  and not tolua.isnull(self._curWarriorStarEffect) then
        self._curWarriorStarEffect:removeFromParent(true)  
    end    
    local quality = warrior._CharacterData["quality"]
    local effectPath = WARRIOR_STAR_MAP[quality]
    if effectPath then
        local parentNode = self:GetUIByName("Star_Bg")
        local parentSize = parentNode:getContentSize()
        local aniNode = CreateAnimation(parentNode, parentSize.width / 2 + 2, parentSize.height / 2 - 5, effectPath, "animation0", true, 1, 1);
        self._curWarriorStarEffect = aniNode
    end
end

function UIWarrior:createSelectFrame()
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

function UIWarrior:runSelectAnimation(node)
    self._selectFrame:removeFromParent(true)
    node:addChild(self._selectFrame, 50)
    local actionBy = cc.RotateBy:create(1.5, -360)
    self._selectFrame:runAction(cc.RepeatForever:create(actionBy)) 
end


return UIWarrior