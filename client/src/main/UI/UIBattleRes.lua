----
-- 文件名称：UIBattleRes.lua
-- 功能描述：战斗结果显示控制
-- 文件说明：战斗结果显示控制
-- 作    者：刘胜勇
-- 创建时间：2015-7-9
--  修改

require("main.UI.UIBase")
require("main.UI.UITypeDefine") 
local TimerManager = require("main.Utility.Timer")
require("cocos.ui.DeprecatedUIEnum")
require("cocos.extension.ExtensionConstants")
local ItemDataManager = GetPropDataManager()
--ui基类
local UISystem = GameGlobal:GetUISystem() 
local UIBattleRes = class("UIBattleRes", UIBase)
local MAXTime
local gFightResultType = 0
local battleWinCSBName = "csb/texiao/ui/T_u_zhandoushengli.csb"
local battleLoseCSBName = "csb/texiao/ui/T_u_zhandoushibai.csb"

function UIBattleRes:ctor()
    UIBase.ctor(self)
    self.Type = UIType.UIType_BattleResUI
    self._ResourceName = "UIBattleRes.csb"  
end
--加载UI 类似UI初始化
function UIBattleRes:Load()
    UIBase.Load(self)
    --经验    
    self. _ExpText = self:GetUIByName("Text_1")
    self. _ExpText:setString("")
    --金钱    
    self. _GoldText = self:GetUIByName("Text_2")
    self. _GoldText:setString("")
    
    self. _ExpText1 = self:GetUIByName("Text_11")
    self. _ExpText1:setString("")
    --金钱    
    self. _GoldText1 = self:GetUIByName("Text_12")
    self. _GoldText1:setString("")
    
    --倒计时  
    self. _TimeText = self:GetUIByName("Text_3")
    MAXTime = 6
    self._TimeText:setString(MAXTime)
    self._TimeId = nil
    -- tableView 
    self._GridView = CreateTableView_(400, 50, 600, 160, 0, self)
    self._RootPanelNode:addChild(self._GridView)
    self._RootPanelNode:setPosition(0, 0)
    self._RootPanelNode:setSwallowTouches(true) 
    
    self._HuodePropTxt = self:GetUIByName("Text_5")
    self._HuodePropTxt:enableOutline(cc.c4b(0, 0, 0, 250), 2)
    
    --确定按钮
    self._okBtn = self:GetUIByName("okBtn")
    self._okBtn:setTag(-1)
    self._okBtn:addTouchEventListener(handler(self, self.TouchEvent))
    
    self._Nextlevle = self:GetUIByName("NextLevel")
    self._Nextlevle:setTag(1)
    self._Nextlevle:addTouchEventListener(handler(self, self.TouchEvent))
    
    if self._TimeId == nil then
       self._TimeId = TimerManager:AddTimer(1, self.OnTimer, self)
    end
    
    self._winPanel = self:GetUIByName("Panel_2")
    self._failPanel = self:GetUIByName("Panel_3")
    self._WinRewardPanel = self:GetUIByName("Panel_RewardInfo")
    self._ShaChangRewardPanel = self:GetUIByName("Panel_ShaChangReward")
    self._TxtRongYuValue = self:GetUIByName("Text_RongYuValue")
    self._RootUINode:setLocalZOrder(1001)
end

function UIBattleRes.ScrollViewDidScroll()

end

function UIBattleRes:NumberOfCellsInTableView()
    return #self._RewardList
end

function UIBattleRes:TableCellTouched(view, cell)
    local index = cell:getIdx()
end

function UIBattleRes:CellSizeForTable(view, idx)
    return 80, 90
end

function UIBattleRes:TableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
        cell:retain()
    end
    cell:removeAllChildren(true)
    local layout = cc.CSLoader:createNode("csb/ui/ItemPanel.csb")
    cell:addChild(layout, 0, idx)
    layout:setPositionX(50)
    self:InitCell(cell, idx)
    return cell
end

function UIBattleRes:InitCell(cell, idx)
    local layout = cell:getChildByTag(idx)
    local panel = seekNodeByName(layout, "Panel_1")
    if panel ~= nil then
        panel:setSwallowTouches(false) 
        ccui.Helper:seekWidgetByName(panel, "Flag"):setVisible(false)
        if idx < #self._RewardList  then
            local item = ItemDataManager[tonumber(self._RewardList[idx + 1][1])]     
   
            local button = ccui.Helper:seekWidgetByName(panel, "Button_1")
            button:setSwallowTouches(false) 
            button:setVisible(false)
            local icon = ccui.Helper:seekWidgetByName(panel, "icon")
            icon:setSwallowTouches(false) 
            local star = ccui.Helper:seekWidgetByName(panel, "star")
            star:setSwallowTouches(false) 
            star:loadTexture("meishu/ui/gg/"..item["quality"]..".png")

            local text = ccui.Helper:seekWidgetByName(panel, "Text_1")
            local num = ccui.Helper:seekWidgetByName(panel, "Text_2")
            local color = GetQualityColor(tonumber(item["quality"]))
            text:setString(item["name"])
            text:enableOutline(cc.c4b(0, 0, 0, 250), 1)
            text:setColor(color)
            icon:loadTexture( GetPropPath(self._RewardList[idx + 1][1]), UI_TEX_TYPE_LOCAL)
            
            num:setString(self._RewardList[idx + 1][2])
            if item["subtype"] >= 11 and item["subtype"] <= 11 then
                num:setPosition(100, 110)
            else
                num:setPosition(50, 110)
            end
        end
    end
end

function UIBattleRes:OpenUISucceed(exp,pvp,result,data)
    self._RewardList = {}

    local csbName = ""
    if result == 1 then
        csbName = battleWinCSBName
        self._GridView:setVisible(true)
    elseif result == 0 then
        csbName = battleLoseCSBName
        self._GridView:setVisible(false)
    end
    gFightResultType = pvp
    if pvp == 1 then
        self._okBtn:setPositionX(0)
        self._Nextlevle:setVisible(false)
        self._ShaChangRewardPanel:setVisible(true)
        self._WinRewardPanel:setVisible(false)
        self._failPanel:setVisible(false)
        self._TxtRongYuValue:setString("")
        if data ~= nil then
            for i, v in pairs(data) do
                if v["p1"] == RewardType.RewardType_RongYu then
                    self._TxtRongYuValue:setString("+" ..  v["l1"])
                    break
                end
            end
        end 
    else
        self._ShaChangRewardPanel:setVisible(false)
        if data ~= nil then 
            for i,v in pairs(data) do
                if v[1] > 10 then
                    table.insert(self._RewardList, v)
                elseif v[1] == RewardType.RewardType_TongQian then
                    self._GoldText:setString(v[2])
                    self._GoldText1:setString(v[2])
                elseif v[1] == RewardType.RewardType_Exp then
                    self._ExpText:setString(v[2])
                    self._ExpText1:setString(v[2])
                end
            end
        end
    end
    
    if result< 5 then
        local battleResultAnimNode = cc.CSLoader:createNode(csbName)
        local battleResultTimeLineAnim = cc.CSLoader:createTimeline(csbName)
        if battleResultAnimNode ~= nil then
            battleResultAnimNode:runAction(battleResultTimeLineAnim)
            if result == 1 then
                if pvp == 0 then
                    self._winPanel:setVisible(true)
                    self._failPanel:setVisible(false)
                end
                battleResultTimeLineAnim:play("zhandoushengli", false)
                battleResultAnimNode:setPosition(580, 440)
            else
                if pvp == 0 then
                    self._winPanel:setVisible(fasle)
                    self._failPanel:setVisible(true)
                end
                local rightLabel = seekNodeByName(self._Nextlevle, "Text_23")
                rightLabel:setString("再来一次")
                battleResultTimeLineAnim:play("zhandoushibai", false)
                battleResultAnimNode:setPosition(490, 400)
            end
            
            self._RootUINode:addChild(battleResultAnimNode, 0, 101)
        end
    end
    self._GridView:reloadData() 
end

function UIBattleRes:Unload()
    UIBase.Unload()
    self._ResourceName = nil
    self.Type = nil
end

function UIBattleRes:Open()
    UIBase.Open(self)
end

function UIBattleRes:Close()
    UIBase.Close(self)
    if self._TimeId ~= nil then
        TimerManager:RemoveTimer(self._TimeId)
        self._TimeId = nil
    end
    self._RootUINode:removeChildByTag(101)
end

function UIBattleRes:TouchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
        if tag == -1 then
            self:Destroy()
        elseif tag == 1 then
            self:OnContinueBattle()
        end
     end
end

--继续征战
function UIBattleRes:OnContinueBattle()
    UISystem:CloseUI(UIType.UIType_BattleResUI)
    if self._TimeId ~= nil then
        TimerManager:RemoveTimer(self._TimeId)
        self._TimeId = nil
    end
    
    if GetPlayer()._Energy > 0 then  --判断军令数量
        SendMsg(PacketDefine.PacketDefine_Stage_Send, {GameGlobal:GetCustomDataManager()[GetPlayer()._MaxLevel]["id"]})
        UISystem:CloseUI(UIType.UIType_BattleUI)
        UISystem:OpenUI(UIType.UIType_BattleUI, GetPlayer()._MaxLevel)
    else
        if GameGlobal:GetItemDataManager():GetItemCount(30019) >= math.floor(GetPlayer()._NeedHuFuTimes / GameGlobal:GetParameterDataManager()["tiger_times"].value) + 1 then
            UISystem:OpenUI(UIType.UIType_UseHuFu)
            UISystem:GetUIInstance(UIType.UIType_UseHuFu):SetBattleType(false, GetPlayer()._MaxLevel)
        else
            local buyObj = UISystem:OpenUI(UIType.UIType_BuyItem)
            local num = math.floor(GetPlayer()._NeedHuFuTimes / GameGlobal:GetParameterDataManager()["tiger_times"].value) + 1 - GameGlobal:GetItemDataManager():GetItemCount(30019)
            buyObj:OpenItemInfoNotifiaction(30019, num)
            buyObj._CallBack = self.ContinueBattle
        end       
    end 
end

function UIBattleRes:ContinueBattle()
    UISystem:OpenUI(UIType.UIType_UseHuFu)
    UISystem:GetUIInstance(UIType.UIType_UseHuFu):SetBattleType(false, GetPlayer()._MaxLevel)
end

function UIBattleRes:Destroy()
    UISystem:CloseUI(UIType.UIType_BattleResUI)
    if self._TimeId ~= nil then
        TimerManager:RemoveTimer(self._TimeId)
        self._TimeId = nil
    end
   
    if gFightResultType == 1 then 
        if GameGlobal:GlobalLevelState() == 3 then
            EndFight() 
            UISystem:SetVisible(UIType.UIType_BottomList, true)
            UISystem:CloseUI(UIType.UIType_BattleUI)
            UISystem:CloseUI(UIType.UIType_ShaChangDianBing)
            local main = UISystem:GetUIInstance(UIType.UIType_MaincityUI)
            SimulateClickButton(main._ShaChangButton, handlers(self, main.OnShaChangClick, 2))
        elseif GameGlobal:GameLevelState() == 1 then
            UISystem:OpenUI(UIType.UIType_MaincityUI)
        end
    else
        UISystem:OpenUI(UIType.UIType_MaincityUI)
    end
end

function UIBattleRes:OnTimer(id)
    MAXTime = MAXTime - 1
    self._TimeText:setString(MAXTime)
    if MAXTime == 0 then
        self:Destroy()
    end
    if TEST_AUTO_BATTLE == true then
        if MAXTime == 2 then
            self:OnContinueBattle()
        end
    end
end

return UIBattleRes