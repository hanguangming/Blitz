----
-- 文件名称：UICustomEnmeyInfo.lua
-- 功能描述：查看敌方信息
-- 文件说明：查看敌方信息
-- 作    者：刘胜勇
-- 创建时间：2015-7-16
--  修改

require("main.UI.UIBase")
require("main.UI.UITypeDefine") 
require("src.cocos.ui.GuiConstants")
require("main.UI.ResourceCsb")

local UISystem = GameGlobal:GetUISystem() 
local UICustomEnmeyInfo = class("UICustomEnmeyInfo", UIBase)

-- 玩家信息数据
local GamePlayerDataManager = GameGlobal:GetGamePlayerDataManager()
-- 物品信息数据
local ItemDataManager = GameGlobal:GetItemDataManager()
-- 获取关卡表数据
local CustomDataManager = GameGlobal:GetCustomDataManager()
-- 获取角色信息表数据
local CharacterDataManager = GameGlobal:GetCharacterDataManager()
-- 虎符ID
local ITEM_HUFU_ID = 30019
-- 记录奖励物品位置信息
local ICON_POS = {{x = 60, y = 40},{x = 230, y = 40},{x = 35, y = 120},{x = 105, y = 120},{x = 175, y = 120},{x = 245, y = 120},{x = 315, y = 120}}
local ICON_NAME_POS = {{x = 80, y = 40},{x = 250, y = 40},{x = 35, y = 90},{x = 105, y = 90},{x = 175, y = 90},{x = 245, y = 90},{x = 315, y = 90}}

function UICustomEnmeyInfo:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_CustomEnmeyInfo
    self._ResourceName = "UICustomEnmeyInfo.csb"  
end

-- UI加载 
function UICustomEnmeyInfo:Load()
    UIBase.Load(self)

    -- 开始战斗按钮
    self._starBtn = self:GetUIByName("StartBtn")
    self._starBtn:setTag(1)
   
    -- 扫荡按钮
    self._sweetButton = self:GetUIByName("StartSweet")
    self._sweetButton:setTag(3)
    
    -- 增加互选的两个Tab键
    self._infoTabBtn = self:GetUIByName("Btn_1")
    self._infoTabBtn:setTag(4)
    
    self._rewardTabBtn = self:GetUIByName("Btn_2")
    self._rewardTabBtn:setTag(5)
    
    self._center = seekNodeByName(self._RootPanelNode, "Panel_Center")
    
    -- 添加士兵TableView
    self._gridView = CreateTableView_(208, -42, 350, 120, 0, self)
    self._gridView:setTag(6)
    self._center:addChild(self._gridView, 0, 0)
    
    -- 添加奖励物品信息的底板
    self._rewardInfoFrame = display.newLayer(cc.c4b(0, 0, 0, 0), cc.size(370, 200))
    local frame = ccui.Scale9Sprite:create("meishu/ui/gg/UI_gg_shenghuidi_01.png")  
    frame:setContentSize(350, 180)
    frame:setColor(cc.c3b(0, 0, 0))
    frame:setOpacity(200)
    frame:setAnchorPoint(0, 0)
    frame:setVisible(false)
    self._rewardInfoFrame:addChild(frame)
    self._rewardInfoFrame:setPosition(210, -33)
    self._rewardInfoFrame:setVisible(false)
    self._center:addChild(self._rewardInfoFrame)
    
    -- 关闭按钮
    local closeBtn = self:GetUIByName("Close")
    closeBtn:setTag(-1)
    
    -- 注册按钮监听事件
    self._starBtn:addTouchEventListener(handler(self, self.touchEvent))
    self._sweetButton:addTouchEventListener(handler(self, self.touchEvent))
    self._infoTabBtn:addTouchEventListener(handler(self, self.touchEvent))
    self._rewardTabBtn:addTouchEventListener(handler(self, self.touchEvent))
    closeBtn:addTouchEventListener(handler(self, self.touchEvent))
        
end

--UI卸载
function UICustomEnmeyInfo:Unload()
    UIBase.Unload()
end

-- UI打开
function UICustomEnmeyInfo:Open()
    UIBase.Open(self)
    
    -- 记录当前打开的页签
    self._tabIndex = 0
    
    -- 初始化页签值
    self._infoState = 1
    self._rewardSate = 2
    
    -- 初始化当前查看的小关卡
    self._littleLevelId = nil
    
    -- 初始化士兵数据表
    self._soldierData = {}
    
    -- 初始化显示关卡武将和士兵信息
    self:changeTabState(self._rewardSate)
    
    -- 注册关卡信息显示监听事件
    self:addEvent(GameEvent.GameEvent_UICustomEnmeyInfo_Succeed,self.selectSuccessListener)
end

-- UI关闭
function UICustomEnmeyInfo:Close()
    UIBase.Close(self)
  
    self._tabIndex = 0
    -- 移除奖励
    self._rewardInfoFrame:removeAllChildren()   
    -- 移除武将
    local HeroItemLayout = self._center:getChildByTag(100)  
    if HeroItemLayout ~= nil then
        HeroItemLayout:removeFromParent()
    end
    -- 清空士兵数据表
    self._soldierData = nil 
    
end

-- 监听事件回调
function UICustomEnmeyInfo:selectSuccessListener(event)
    self._littleLevelId = event._usedata
    
    -- 武将的数据
    local heroData = {}
    -- 兵的数据
    local bingData = {}
    
    if self._littleLevelId  <= GetPlayer()._MaxLevel then
        if  GetPlayer()._VIPLevel > 0  then 
            -- 如果是VIP,开启扫荡
            self._sweetButton:loadTextures("meishu/ui/guanqia/UI_gq_saodang_01.png", "meishu/ui/guanqia/UI_gq_saodang_02.png", UI_TEX_TYPE_LOCAL)
        else
            -- 如果不是是VIP,扫荡置灰
            self._sweetButton:loadTextures("meishu/ui/guanqia/UI_gq_saodang_03.png", "meishu/ui/guanqia/UI_gq_saodang_03.png", UI_TEX_TYPE_LOCAL)
        end
    else
        self._sweetButton:loadTextures("meishu/ui/guanqia/UI_gq_saodang_03.png", "meishu/ui/guanqia/UI_gq_saodang_03.png", UI_TEX_TYPE_LOCAL)
    end
    
    -- 当前查看的小关卡数据信息
    self._LevelTableData = CustomDataManager[self._littleLevelId]
    
    -- 小关卡包含的武将和士兵数据
    local data= SplitSet(self._LevelTableData["bingList"])
    
    for i = 1, #data do
        local tableID = tonumber(data[i][1])
        local tableData = CharacterDataManager[tableID]
        if tonumber(tableData["type"]) == 1 then --兵
            if bingData[tableID] == nil then
                bingData[tableID] = data[i]
            end
        elseif tonumber(tableData["type"]) == 2 then --武将
            if heroData[tableID] == nil then
                heroData[tableID] = data[i]
            end
        end
    end
    
    -- 刷新士兵数据
    self:refreshSoldierData(bingData)
    
    -- 刷新武将数据
    self:refreshHeroData(heroData)
    
    -- boss关隐藏InfoTabBtn
    if self._littleLevelId % 10 == 0 then   
        self._infoTabBtn:setVisible(false)
    else
        self._infoTabBtn:setVisible(true)
    end
    
    -- 刷新奖励物品信息
    local RewardDataManager = GameGlobal:GetCustomRewardDataManager()
    local rid = RewardDataManager[tonumber(CustomDataManager[self._littleLevelId]["rewardid"])]
    self:refreshRewardInfo(rid)
end

-- 加载士兵信息
function UICustomEnmeyInfo:refreshSoldierData(solderdata)
    for i, v in pairs(solderdata) do
        -- pvp时数据格式同PVE时数据不一致(只有两个数据ID Level)程序校正
        if self._LevelTableData.pvp ~= 0 then
            v[3] = v[2]
        end
        table.insert(self._soldierData, v)
    end

    -- 刷新士兵列表
    local soldierCount = #self._soldierData
    if  soldierCount <= 5 then
        self._gridView:setTouchEnabled(false)
    else
        self._gridView:setTouchEnabled(true)
    end
    self._gridView:reloadData() 
end

-- 加载武将信息
function UICustomEnmeyInfo:refreshHeroData(herodata)
    local heroData = {}
    for i, v in pairs(herodata) do
        -- pvp时数据格式同PVE时数据不一致(只有两个数据ID Level)程序校正
        if self._LevelTableData.pvp ~= 0 then
            v[3] = v[2]
        end
        table.insert(heroData, v)
    end
    local layout = cc.CSLoader:createNode("csb/ui/HeroItem.csb")
    layout:setTag(100)  --标记武将layout,方便移除
    layout:setVisible(false)
    self._center:addChild(layout)
--    if self._littleLevelId  % 10 == 0 then
--        layout:setVisible(false)
--    else
--        layout:setVisible(true)
--    end
    layout:setPosition(202, 60)

    local panel1 = tolua.cast(layout, "ccui.Layout")
    local heroNum = #heroData
    for j = 1, 5 do
        local panel = ccui.Helper:seekWidgetByName(panel1, "Panel_"..j)
        ccui.Helper:seekWidgetByName(panel, "Button_1"):setColor(cc.c3b(250, 250, 250))
        if j <= heroNum then
            panel:setVisible(true)
            local soldier =  CharacterDataManager[tonumber(heroData[j][1])]
            local head = ccui.Helper:seekWidgetByName(panel, "Image_2")
            if soldier ~= nil then
                head:loadTexture(GetWarriorHeadPath(soldier["headName"]), UI_TEX_TYPE_LOCAL)
                local lv = ccui.Helper:seekWidgetByName(panel, "Text_1")
                local level = soldier["lv"]
                if level == nil then
                    level = ""
                end
                lv:setString("lv.".. level)
                lv:setColor(cc.c3b(115, 74, 18))
            end
        end
    end
end

-- 加载奖励信息
function UICustomEnmeyInfo:refreshRewardInfo(items)
    local itemCount = #items - 1
    for i = 1, itemCount do
        local icon = display.newSprite(GetPropPath(items[i + 1]["p1"]),ICON_POS[i].x,ICON_POS[i].y)
        if i > 2 then
            -- 物品Icon的底板
            icon:setScale(0.6)
            local iconframe = ccui.Scale9Sprite:create("meishu/ui/gg/UI_gg_zhuangbeikuang_01.png") 
            iconframe:setContentSize(70,70)
            iconframe:setPosition(cc.p(ICON_POS[i].x,ICON_POS[i].y))
            self._rewardInfoFrame:addChild(iconframe)
        end
        if items[i + 1]["p1"] > 100 then
            local iconName = cc.Label:createWithTTF(GetPropDataManager()[tonumber(items[i + 1]["p1"])]["name"], FONT_SIMHEI, BASE_FONT_SIZE)
            iconName:setAnchorPoint(0.5, 0.5)   
            iconName:setPosition(cc.p(ICON_NAME_POS[i].x, ICON_NAME_POS[i].y))
            --local color = GetQualityColor(tonumber(GetPropDataManager()[tonumber(items[i + 1]["p1"])]["quality"]))
            local color = GetQualityColor(8)
            iconName:setColor(color)
            iconName:setVisible(false)
            self._rewardInfoFrame:addChild(iconName)
        else
            --local iconName = cc.Label:createWithTTF(ChineseConvert["ItemName_"..items[i + 1]["p1"]].." X"..items[i + 1]["l1"], FONT_SIMHEI, BASE_FONT_SIZE)
            local iconName = cc.Label:createWithTTF(items[i + 1]["l1"], FONT_SIMHEI, BASE_FONT_SIZE)
            iconName:setAnchorPoint(0, 0.5)
            iconName:setPosition(cc.p(ICON_NAME_POS[i].x,ICON_NAME_POS[i].y))
            local color = GetQualityColor(8)
            iconName:setColor(color)
            self._rewardInfoFrame:addChild(iconName)
        end
        self._rewardInfoFrame:addChild(icon)
    end
end

function UICustomEnmeyInfo:NumberOfCellsInTableView(view)
    return 10
end

function UICustomEnmeyInfo:TableCellTouched(view, cell)
    local index = cell:getIdx()
end

function UICustomEnmeyInfo:CellSizeForTable(view, idx)
    return 70, 120
end

function UICustomEnmeyInfo:TableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
    end
    cell:removeAllChildren(true)
    local layout = cc.CSLoader:createNode("csb/ui/BingItem.csb")
    local panel = seekNodeByName(layout, "Bing_1")
    panel:setSwallowTouches(false)
    local button = seekNodeByName(panel, "Button_1")
    button:setTag(idx + 1)
    button:setSwallowTouches(false)
    seekNodeByName(panel, "Icon"):setSwallowTouches(false)
    cell:addChild(layout, 0, idx)  
    
    self:InitCell(cell, idx)
    return cell
end

function UICustomEnmeyInfo:InitCell(cell, idx) 
    local layout = cell:getChildByTag(tonumber(idx))
    local panel = seekNodeByName(layout, "Bing_1")
    seekNodeByName(panel, "Button_1"):setColor(cc.c3b(250, 250, 250))
    panel:setVisible(false)
    if idx + 1 <= #self._soldierData then
        panel:setVisible(true)
        local soldier =  CharacterDataManager[tonumber(self._soldierData[idx + 1][1])]
        local head = seekNodeByName(panel, "Icon")
        if soldier ~= nil then
            head:loadTexture(GetSoldierHeadPath(soldier["headName"]))
            local name = seekNodeByName(panel, "Name")
            name:setString(soldier["name"])
            name:enableOutline(cc.c4b(0, 0, 0, 250), 1)
            local property = seekNodeByName(panel, "Shuxing")
            property:loadTexture(GetEnmeyInfoSoldireProperty(soldier["soldierType"]))
            
            local Lv = seekNodeByName(panel, "Lv")
            local level = self._soldierData[idx + 1][3]
            if level == nil then
                level = ""
            end
            Lv:setString("lv.".. level)
            Lv:setColor(cc.c3b(115, 74, 18))
        end
    end
end

-- 触摸监听事件处理
function UICustomEnmeyInfo:touchEvent(sender, eventType)
    local HeroItemLayout = self._center:getChildByTag(100)  
    if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag() 
        if tag == -1 then
            UISystem:CloseUI(UIType.UIType_CustomEnmeyInfo)
        elseif tag == 1 then
            -- 判断军令数量
            if GetPlayer()._Energy > 0 then  
                -- Boss关点进军要打开bossinfo界面
                if self._littleLevelId  ~= nil and self._littleLevelId % 10 == 0 then 
                    UISystem:OpenUI(UIType.UIType_CustomEnmeyBossInfo)
                    local function delayCallBossInfo()  
                        DispatchEvent(GameEvent.GameEvent_UICustomEnmeyBossInfo_Succeed, self._littleLevelId)
                    end
                    performWithDelay(UISystem:GetUIRootNode(), handler(self, delayCallBossInfo), 0)
                    return
                end
                self:enterBattle()   
            else
                if GameGlobal:GetItemDataManager():GetItemCount(ITEM_HUFU_ID) >= math.floor(GetPlayer()._NeedHuFuTimes / GameGlobal:GetParameterDataManager()["tiger_times"].value) + 1 then
                    UISystem:OpenUI(UIType.UIType_UseHuFu)
                    UISystem:GetUIInstance(UIType.UIType_UseHuFu):SetBattleType(false, self._littleLevelId )
                else
                    UISystem:OpenUI(UIType.UIType_BuyItem)
                    local num = math.floor(GetPlayer()._NeedHuFuTimes / GameGlobal:GetParameterDataManager()["tiger_times"].value) + 1 - GameGlobal:GetItemDataManager():GetItemCount(ITEM_HUFU_ID)
                    local uiInstance = UISystem:GetUIInstance(UIType.UIType_BuyItem)
                    uiInstance:OpenItemInfoNotifiaction(ITEM_HUFU_ID, num)
                end       
            end
       elseif tag == 3 then
            if  GetPlayer()._VIPLevel == 0  then  --不是VIP不能扫荡
                OpenRechargeTip("vip1以上可扫荡，是否立即充值？")
                return
            end
            if self._littleLevelId  >= GetPlayer()._MaxLevel then --没有通关的关卡不能扫荡
               -- 给出先通关提示
                CreateTipAction(self._RootUINode, "扫荡前请先通关", cc.p(480, 270))
                return
            end
            UISystem:OpenUI(UIType.UIType_CustomSweep)
            local function delayCallBackSweep()
                DispatchEvent(GameEvent.GameEvent_UICustomSweep_Succeed, self._littleLevelId )
            end
            performWithDelay(UISystem:GetUIRootNode(), delayCallBackSweep, 0)
        elseif tag == 4 then
            -- 点击infoTab，弹出info信息
            self:changeTabState(self._infoState)
--            if self._littleLevelId % 10 == 0 then   --boss关隐藏
--                HeroItemLayout:setVisible(false)
--            elseif HeroItemLayout ~= nil then
--                HeroItemLayout:setVisible(true)
--            end
        elseif tag == 5 then
            -- 点击rewardTab,弹出掉落物品信息
            self:changeTabState(self._rewardSate)
--            if HeroItemLayout ~= nil then
--                HeroItemLayout:setVisible(false)
--            end
       end
    end
end

-- 发送使用虎符监听事件
function UICustomEnmeyInfo:delayCallBack()
    DispatchEvent(GameEvent.GameEvent_UIUseHuFu_Succeed, self._littleLevelId )
end

-- 进入战斗场景
function UICustomEnmeyInfo:enterBattle() --进入战斗
    if self._littleLevelId  ~= nil then
        UISystem:CloseUI(UIType.UIType_CustomEnmeyInfo)
        local gNetSystem = GetNetSystem()
        SendMsg(PacketDefine.PacketDefine_Stage_Send, {CustomDataManager[self._littleLevelId]["id"]})
        UISystem:CloseAllUI()
        GameGlobal:GetUISystem():OpenUI(UIType.UIType_BattleUI,  self._littleLevelId)
     end
end

-- 切换页签状态
function UICustomEnmeyInfo:changeTabState(index)
    local HeroItemLayout = self._center:getChildByTag(100)  
    if self._tabIndex == index then
        return
    end
    if index == self._infoState then
        if HeroItemLayout ~= nil then
            HeroItemLayout:setVisible(true)
        end  
        self._infoTabBtn:setLocalZOrder(3)
        self._rewardTabBtn:setLocalZOrder(-1)
        self._infoTabBtn:loadTextures("meishu/ui/guanqia/UI_gq_biaoqian01_01.png",UI_TEX_TYPE_LOCAL)
        self._rewardTabBtn:loadTextures("meishu/ui/guanqia/UI_gq_biaoqian02_02.png", UI_TEX_TYPE_LOCAL)
        self._gridView:setVisible(true)
        self._rewardInfoFrame:setVisible(false)    
    elseif index == self._rewardSate then
        self._infoTabBtn:setLocalZOrder(-1)
        self._rewardTabBtn:setLocalZOrder(3)
        self._infoTabBtn:loadTextures("meishu/ui/guanqia/UI_gq_biaoqian01_02.png",UI_TEX_TYPE_LOCAL)
        self._rewardTabBtn:loadTextures("meishu/ui/guanqia/UI_gq_biaoqian02_01.png",UI_TEX_TYPE_LOCAL)
        self._rewardInfoFrame:setVisible(true)
        self._gridView:setVisible(false)
        if HeroItemLayout ~= nil then
            HeroItemLayout:setVisible(false)
        end  
    end
    self._tabIndex = index
end

return UICustomEnmeyInfo