----
-- 文件名称：UIShangChangRank.lua
-- 功能描述：沙场排行
-- 文件说明: 沙场排行
-- 作    者：王雷雷
-- 创建时间：2015-7-28
--  修改
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
require("src.cocos.ui.GuiConstants")

local TableDataManager = GameGlobal:GetDataTableManager()
local UISystem =  GameGlobal:GetUISystem()
local BattleServerDataManager = GameGlobal:GetBattleServerDataManager()
-- 冠军
local UI_RANK_ONE_EFFECT    = "csb/texiao/ui/T_u_SC_guanjun.csb"
-- 亚军
local UI_RANK_TWO_EFFECT    = "csb/texiao/ui/T_u_SC_yajun.csb"
-- 季军
local UI_RANK_THREE_EFFECT    = "csb/texiao/ui/T_u_SC_jijun.csb"

local B_STATE_ITEM = 1
local B_STATE_RongYu = 2
local B_STATE_Rank = 3
local B_STATE_CLOSE = -1

local UIShangChangRank = class("UIShangChangRank", UIBase)

function UIShangChangRank:ctor()
    UIBase.ctor(self)
    self.Type = UIType.UIType_ShaChangRank
    self._ResourceName = "UIShaChangRank.csb"  
end

function UIShangChangRank:Load()
    UIBase.Load(self)

    local closeButton = self:GetWigetByName("Button_Close")
    closeButton:setTag(B_STATE_CLOSE)
    closeButton:addTouchEventListener(handler(self, self.TouchEvent))
    local bgPanel = self:GetWigetByName("Panel_DataPanel")
    local contentSize = bgPanel:getContentSize()
    self._TableView  = CreateTableView_(0, 0, contentSize.width, contentSize.height, cc.TABLEVIEW_FILL_BOTTOMUP, self)
    bgPanel:addChild(self._TableView, 10)
    self._Buttons = {}
    for i = 1, 3 do
        self._Buttons[i] = self:GetWigetByName("Button_"..i)
        self._Buttons[i]:setTag(i)
        self._Buttons[i]:addTouchEventListener(handler(self, self.TouchEvent))
    end
    for i= 2, 5 do
        local labelName = string.format("Text_%d",i)
        local textLabel = self:GetWigetByName(labelName)
    end
    self:changeTabState(3)
end

function UIShangChangRank:Open()
    UIBase.Open(self)
    self:addRankEffects()
    self:addEvent(GameEvent.GameEvent_UIShaChangRank_RefreshRank, self.refreshRankData)
end

function UIShangChangRank:Close()
    UIBase.Close(self)
    self:releaseRankEffects()
end

-- 刷新Rank数据
function UIShangChangRank:refreshRankData()
    self._TableView:reloadData()
    for i = 2, 4 do
        local rankData = BattleServerDataManager._ShaChangRankData[i - 1]
        if rankData ~= nil then
            local panel = self:GetWigetByName("Panel_"..i)
            seekNodeByName(panel, "Text_Level"):setString(rankData._Level)
            seekNodeByName(panel, "Text_ZhuGong"):setString(rankData._Name)
            seekNodeByName(panel, "Text_BattleValue"):setString(rankData._BattleValue)
            if i ~= 3 then
                local imageBg = seekNodeByName(panel, "Image_ImageBg")
                imageBg:setVisible(false)
            end
        end
    end
end

function UIShangChangRank:InitCell(cell, idx)
    if cell == nil then
        return
    end
    local layout = cell:getChildByTag(tonumber(idx))
    local realIndex = tonumber(idx) + 4
    local rankData = BattleServerDataManager._ShaChangRankData[realIndex] 
    if rankData ~= nil then
        local paiMingText = seekNodeByName(layout, "Text_PaiMing")
        local bg = seekNodeByName(layout, "Image_Bg")
        if paiMingText ~= nil then
            paiMingText:setString("第 "..tostring(rankData._Rank).." 名")
            if idx % 2 == 0 then
                bg:setVisible(false)
            end
        end
        local levelText = seekNodeByName(layout, "Text_Level")
        if levelText ~= nil then
            levelText:setString(tostring(rankData._Level))
        end
        local playerText = seekNodeByName(layout, "Text_ZhuGong")
        if playerText ~= nil then
            --
            if rankData._VIP == 0 then
                if rankData._Country == 0 then
                    rankData._Country = 1
                end
                local country = GetCountryChinese(rankData._Country)
                local showStr = string.format("[%s]%s",country, rankData._Name)
                playerText:setString(showStr)
            else
                if rankData._Country == 0 then
                    rankData._Country = 1
                end
                local country = GetCountryChinese(rankData._Country)
                local showStr = string.format("v%d[%s]%s",rankData._VIP, country, rankData._Name)
                playerText:setString(showStr)
            end
        end
        local battleText = seekNodeByName(layout, "Text_BattleValue")
        if battleText ~= nil then
            battleText:setString(tostring(rankData._BattleValue))
        end
    end
end

function UIShangChangRank:CellSizeForTable(view, idx)
    return 678, 35
end

function UIShangChangRank:TableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
        local layout = cc.CSLoader:createNode("csb/ui/UIShaChangRankItem.csb")
        cell:addChild(layout, 0, idx)
    else
        cell:removeAllChildren(true)
        local layout = cc.CSLoader:createNode("csb/ui/UIShaChangRankItem.csb")
        cell:addChild(layout, 0, idx)
    end
    self:InitCell(cell, idx)
    return cell
end

function UIShangChangRank:NumberOfCellsInTableView()
    local ranks = BattleServerDataManager._ShaChangRankData or {}
    if #ranks > 0 then
        return #ranks
    end
    return 0
end

function UIShangChangRank:TouchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
        if tag == B_STATE_CLOSE then
            UISystem:CloseUI(UIType.UIType_ShaChangRank)
        elseif tag == B_STATE_ITEM then
            UISystem:OpenUI(UIType.UIType_ShaChangDianBing)   
            UISystem:CloseUI(UIType.UIType_ShaChangRank) 
        elseif tag == B_STATE_RongYu then
            UISystem:OpenUI(UIType.UIType_RongYuShop)
            UISystem:CloseUI(UIType.UIType_ShaChangRank)
        elseif tag == B_STATE_Rank then
--            UISystem:OpenUI(UIType.UIType_ShaChangRank)
        end 
    end
end

function UIShangChangRank:changeTabState(index)
    for i =  1, 3 do
        seekNodeByName(self._Buttons[i], "Text_1"):setTextColor(cc.c3b(36, 47, 13))
        seekNodeByName(self._Buttons[i], "Text_1"):enableOutline(cc.c4b(36, 47, 13, 50), 1)
    end
    seekNodeByName(self._Buttons[index], "Text_1"):setTextColor(cc.c3b(255, 230, 142))
end

function UIShangChangRank:addRankEffects()
    local oneEffect = self:GetWigetByName("Image_3")
    local size = oneEffect:getContentSize()
    self._RankOneEffect = CreateAnimation(oneEffect, size.width / 2,  size.height / 2 - 6, UI_RANK_ONE_EFFECT, "animation0", true, 1, 1)
   
    local twoEffect = self:GetWigetByName("Image_7")
    size = twoEffect:getContentSize()
    self._RankTwoEffect = CreateAnimation(twoEffect, size.width / 2,  size.height / 2 - 6, UI_RANK_TWO_EFFECT, "animation0", true, 1, 1)
    
    local threeEffect = self:GetWigetByName("Image_4")
    size = threeEffect:getContentSize()
    self._RankThreeEffect = CreateAnimation(threeEffect, size.width / 2,  size.height / 2 - 6, UI_RANK_THREE_EFFECT, "animation0", true, 1, 1)
end

function UIShangChangRank:releaseRankEffects()
    removeNodeAndRelease(self._RankOneEffect)
    removeNodeAndRelease(self._RankTwoEffect)
    removeNodeAndRelease(self._RankThreeEffect)

    self._RankOneEffect = nil
    self._RankTwoEffect = nil
    self._RankThreeEffect = nil
end

return UIShangChangRank