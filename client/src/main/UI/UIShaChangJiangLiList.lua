----
-- 文件名称：UIShaChangJiangLiList.lua
-- 功能描述：沙场奖励列表
-- 文件说明: 沙场奖励列表
-- 作    者：王雷雷
-- 创建时间：2015-7-27
--  修改
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
require("src.cocos.ui.GuiConstants")
local TableDataManager = GameGlobal:GetDataTableManager()
local GamePlayerDataManager = GameGlobal:GetGamePlayerDataManager()
local UISystem =  GameGlobal:GetUISystem()

local RANK_LIST_ITEM_CSB = "csb/ui/UIShaChangJiangLiItem.csb"

local UIShaChangJiangLiList = class("UIShaChangJiangLiList", UIBase)

function UIShaChangJiangLiList:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_ShaChangRewardList
    self._ResourceName = "UIShaChangJiangLiList.csb"  
end

function UIShaChangJiangLiList:Load()
    UIBase.Load(self)

    local closeButton = self:GetWigetByName("Button_Close")
    closeButton:addTouchEventListener(handler(self, self.OnCloseButton))
    
    local bgPanel = self:GetWigetByName("Panel_DataPanel")
    local contentSize = bgPanel:getContentSize()
    self._TableView  = CreateTableView_(35, -20, contentSize.width, contentSize.height, cc.TABLEVIEW_FILL_BOTTOMUP, self)
    self._TableView:setBounceable(false)
    bgPanel:addChild(self._TableView)
end

function UIShaChangJiangLiList:Open()
    UIBase.Open(self)

    self._JiangLiDataList = {}
    self._JiangLiDataList =  TableDataManager:GetPveRewardDataManager()    
    self._TableView:reloadData()
end

function UIShaChangJiangLiList:getMyRankCellId()
    local myRankCellID = 1
    --获取我的排名-计算对应cell
    local selfData = GamePlayerDataManager:GetMyselfData()
    local myShaChangRank = selfData._MyShaChangRank
    local cellNum = {[1] = 1, [2] = 2, [3] = 3, [4] = 10, [5] = 50, [6] = 100, [7] = 200, [8] = 0}
    for i = 1, #cellNum do
        if myShaChangRank <= cellNum[i] or cellNum[i] == 0 then
            myRankCellID = i
            break
        end
    end
    return myRankCellID
end

function UIShaChangJiangLiList:InitCell(cell, idx)
    if cell == nil then
        return
    end
    local layout = cell:getChildByTag(tonumber(idx))
    local realIndex = tonumber(idx) + 1
    local rewardData = self._JiangLiDataList[realIndex] 
    if rewardData ~= nil then
        local paiMingText = seekNodeByName(layout, "Text_PaiMing")
        if paiMingText ~= nil then
            paiMingText:setString(tostring(rewardData.rank)..":")
        end
        local yuanBaoText = seekNodeByName(layout, "Text_JiangLiYuanBao")
        if yuanBaoText ~= nil then
            yuanBaoText:setString(tostring(rewardData.p1))
        end
        local tongQianText = seekNodeByName(layout, "Text_TongQian")
        if tongQianText ~= nil then
            tongQianText:setString(tostring(rewardData.p2))
        end
        if self:getMyRankCellId() == idx + 1 then
            local myRankIcon = seekNodeByName(layout, "Image_Icon")
            myRankIcon:setVisible(true)
            myRankIcon:setPositionX(paiMingText:getPositionX() + paiMingText:getContentSize().width)
        end
    end
end

function UIShaChangJiangLiList:CellSizeForTable(view, idx)
    return 380, 37
end

function UIShaChangJiangLiList:TableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
        local layout = cc.CSLoader:createNode(RANK_LIST_ITEM_CSB)
        cell:addChild(layout, 0, idx)
    else
        cell:removeAllChildren(true)
        local layout = cc.CSLoader:createNode(RANK_LIST_ITEM_CSB)
        cell:addChild(layout, 0, idx)
    end
    self:InitCell(cell, idx)
    return cell
end

function UIShaChangJiangLiList:NumberOfCellsInTableView()
    local list = self._JiangLiDataList or {}
    return #list
end

--关闭按钮
function UIShaChangJiangLiList:OnCloseButton(sender, eventType)
     if eventType == ccui.TouchEventType.ended then
        self:closeUI()
     end
end
return UIShaChangJiangLiList