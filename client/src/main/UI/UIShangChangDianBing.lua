----
-- 文件名称：UIShangChangDianBing.lua
-- 功能描述：沙场点兵UI
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-7-21
-- 修改 ：

require("main.UI.UIBase")
require("main.UI.UITypeDefine")
require("cocos.ui.GuiConstants")

local UISystem = GameGlobal:GetUISystem()
local NetSystem = GameGlobal:GetNetSystem()

local GamePlayerDataManager = GameGlobal:GetGamePlayerDataManager()
local CharacterServerDataManager = GameGlobal:GetCharacterServerDataManager()
local CharacterDataManager = GameGlobal:GetDataTableManager():GetCharacterDataManager()
local MailServerDataManager = GameGlobal:GetMailServerDataManager()
local TableDataManager = GameGlobal:GetDataTableManager()

--其它玩家信息的UI
local PLAYERINFO_ITEM_CSB_NAME = "csb/ui/UIShaChangPlayer.csb"
local B_STATE_ITEM = 1
local B_STATE_RongYu = 2
local B_STATE_Rank = 3
local B_STATE_CLOSE = -1

local REWARD_TYPE = 23

local LeftTopButton_Type = 
{
    LeftTopButton_JiangLi = 100,
    LeftTopButton_PaiHang = 101,
    LeftTopButton_RongYuShop = 102,    
}

local UIShangChangDianBing = class("UIShangChangDianBing", UIBase)

local rewardTime = 0

-------------------------------------------必须的接口begin-------------------------------------------
--构造函数
function UIShangChangDianBing:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_ShaChangDianBing
    self._ResourceName =  "UIShaChangDianBing.csb"
end

--Load
function UIShangChangDianBing:Load()
    UIBase.Load(self)
    --事件
    local closeButton = self:GetWigetByName("Button_Close")
    closeButton:setTag(B_STATE_CLOSE)
    closeButton:addTouchEventListener(handler(self, self.TouchEvent))
    self._PlayerUIRootNode = self:GetUIByName("Node_PlayerNode")
    self:GetUIByName("Panel_MainBottom"):setSwallowTouches(false)
    self._RankPlayerRootNode = self:GetUIByName("Node_Top3Player")
    seekNodeByName(seekNodeByName(self._RootPanelNode, "Image_37"), "Text_23")
    self._Buttons = {}
    for i = 1, 3 do
        self._Buttons[i] = self:GetWigetByName("Button_"..i)
        self._Buttons[i]:setTag(i)
        self._Buttons[i]:addTouchEventListener(handler(self, self.TouchEvent))
    end
    self._MyRankLabel = self:GetWigetByName("Text_MyRank")
    self._MyLevelLabel = self:GetWigetByName("Text_Level")
    self._MyPlayerIcon = self:GetWigetByName("Image_PlayerIcon")
    self._MyRongYuLabel = self:GetWigetByName("Text_RongYu")
    self._TiaoZhanLabel = self:GetWigetByName("Text_TianZhanCiShu")
    self._RewardCoinLabel = self:GetWigetByName("Text_JiangLiTongQian")
    self._RewardRongYuLabel = self:GetWigetByName("Text_JiangLiRongYu")
    self._RewardTime = self:GetWigetByName("Text_16")
    self._ZhanBaoBtn = self:GetWigetByName("Button_ZhanBao")

    --阵型选择按钮
    local zhenXingSelectButton = self:GetWigetByName("Button_ZhenXingSelect")
    zhenXingSelectButton:addTouchEventListener(handler(self, self.OnZhenXingSelectButtonClick))
    self._ZhenXingSelect = seekNodeByName(zhenXingSelectButton, "Text_21")
    self._ZhenXingSelectTouchPanel = self:GetWigetByName("Panel_ToucZhenXinghPanel")
    self._ZhenXingSelectTouchPanel:setSwallowTouches(true)
    self._ZhenXingSelectTouchPanel:addTouchEventListener(handler(self, self.OnZhenXingSelectClose))
    
    --领取奖励
    self._TakeRewardButton = self:GetWigetByName("Button_TakeReward")
    self._TakeRewardButton:addTouchEventListener(handler(self, self.OnTakeReward))
    
    --三个按钮
    local jiangliListButton = self:GetWigetByName("Button_RewardList")
    local paiHangButton = self:GetWigetByName("Button_Rank")
    local rongYuShopButton = self:GetWigetByName("Button_YongYuShop")
    jiangliListButton:addTouchEventListener(handler(self, self.OnLeftTopButtonEvent))
    jiangliListButton:setTag(LeftTopButton_Type.LeftTopButton_JiangLi)
    paiHangButton:addTouchEventListener(handler(self, self.OnLeftTopButtonEvent))
    paiHangButton:setTag(LeftTopButton_Type.LeftTopButton_PaiHang)
    rongYuShopButton:addTouchEventListener(handler(self, self.OnLeftTopButtonEvent))
    rongYuShopButton:setTag(LeftTopButton_Type.LeftTopButton_RongYuShop)

    for i = 1, 3 do
        local buttonName = string.format("Button_ZhenXing_%d", i)
        local zhenXingButton = self:GetWigetByName(buttonName)
        if zhenXingButton ~= nil then
            zhenXingButton:addTouchEventListener(handler(self, self.OnZhenXingButtonClick))
            zhenXingButton:setTag(60 + i)
        end
    end
    self._ZhenXingSelectPanel = self:GetWigetByName("Panel_SelectZhenXing")
    self:ChangeTabState(1)
    --保存当前阵型
    self._CurFormationIndex = nil
end

--打开
function UIShangChangDianBing:Open()
    UIBase.Open(self)

    self._ZhanBaoDataList = {}
    self._ShaChangRewardList = {}

    local rewardDataList =  TableDataManager:GetCustomRewardDataManager()
    for k, v in pairs(rewardDataList)do
        if v.type == REWARD_TYPE then
            self._ShaChangRewardList[tonumber(v.name)] = v
        end
    end

    self._ZhenXingSelectTouchPanel:setVisible(false)
    self:RefreshPlayerInfo()
    self:RefreshZhanBaoInfo()
    self:RewardTimeLabel()

    self:addEvent(GameEvent.GameEvent_MyselfInfoChange, self.OnRongYuListener)
    --@BUG:这个通知没有分发
    self:addEvent(GameEvent.GameEvent_UIShaChang_RefreshPlayer, self.OnRefreshPlayerInfo)
    self:addEvent(GameEvent.GameEvent_MailInfo_Notify, self.OnRefreshZhanBaoInfo)
end

function UIShangChangDianBing:TouchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
        if tag == B_STATE_CLOSE then
            self:closeUI()
        elseif tag == B_STATE_ITEM then

        elseif tag == B_STATE_RongYu then
            UISystem:OpenUI(UIType.UIType_RongYuShop) 
            self:closeUI()
        elseif tag == B_STATE_Rank then
            UISystem:OpenUI(UIType.UIType_ShaChangRank)
            SendMsg(PacketDefine.PacketDefine_AppeaRankingList_Send)
            self:closeUI()
        end 
    end
end

function UIShangChangDianBing:ChangeTabState(index)
    for i =  1, 3 do
        seekNodeByName(self._Buttons[i], "Text_1"):setTextColor(cc.c3b(36, 47, 13))
        seekNodeByName(self._Buttons[i], "Text_1"):enableOutline(cc.c4b(36, 47, 13, 50), 1)
    end
    seekNodeByName(self._Buttons[index], "Text_1"):setTextColor(cc.c3b(255, 230, 142))
end

--单个玩家信息
function UIShangChangDianBing:RefreshOnePlayerInfo(parentNode, playerData, num)
    if parentNode == nil then
        return 
    end
    
    local touchImage = seekNodeByName(parentNode, "Image_1")
    local bodyImage = seekNodeByName(parentNode, "Image_Body")
    local nameLabel = seekNodeByName(parentNode, "Text_Name")
    local paiMingLabel = seekNodeByName(parentNode, "Text_PaiMing")
    local vipLabel = seekNodeByName(parentNode, "Sprite_1")
    if playerData == nil then
        bodyImage:setVisible(false)
        return
    end
    
    bodyImage:setSwallowTouches(false)
    bodyImage:setVisible(true)
    print("nameLabel", nameLabel)
    if nameLabel ~= nil then
        nameLabel:setString(playerData._Name)
    end
    if paiMingLabel ~= nil then
        paiMingLabel:setString("排名: "..tostring(playerData._Rank))
    end
    if vipLabel ~= nil then
        local showName = string.format("meishu/ui/vip/UI_vip_%d.png", playerData._VIPLevel)
        vipLabel:setTexture(showName)
    end
    if bodyImage ~= nil then
        local soldierID = playerData._HeadId
        if soldierID ~= nil and soldierID ~= 0 then
            local soldierData = CharacterDataManager[soldierID]
            if soldierData ~= nil then
                print(GetWarriorBodyPath(soldierData.bodyImage))
                bodyImage:loadTexture(GetWarriorBodyPath(soldierData.bodyImage))
            else
                bodyImage:setVisible(false)
            end
        else
            bodyImage:setVisible(false)
        end
    end
    return touchImage 
end

function UIShangChangDianBing:OnTimeChange()
    if rewardTime <= 0 then
        self._RewardTime:setVisible(true)
        self._RewardTime:setTextColor(cc.c3b(56, 253, 0))
        self._RewardTime:setString(ChineseConvert["UIRewardOK"])
        return
    end
    rewardTime = rewardTime - 1
    self:setString(CreateTimeString(rewardTime + os.time()).."后可领奖")
end

function UIShangChangDianBing:RewardTimeLabel()
    local myselfData = GamePlayerDataManager:GetMyselfData()
    local isCanTake = (myselfData._ShaChangReward ~= 0)
    self._TakeRewardButton:setEnabled(isCanTake)
    if isCanTake then
        self._RewardTime:setVisible(true)
        self._RewardTime:setTextColor(cc.c3b(56, 253, 0))
        self._RewardTime:setString(ChineseConvert["UIRewardOK"])
    else
        self._RewardTime:setTextColor(cc.c3b(199, 150, 70))
    end
    local time = 24*3600 - (os.date("%H", os.time())*3600 + os.date("%M", os.time())*60 + os.date("%S", os.time()))
    self._RewardTime:setString(CreateTimeString(time + os.time()).."后可领奖")
    rewardTime = time
    schedule(self._RewardTime, self.OnTimeChange, 1)
end

--刷新沙场玩家数据
function UIShangChangDianBing:RefreshPlayerInfo()
    local selfData = GamePlayerDataManager:GetMyselfData()
    --我的数据刷新
    if self._MyRankLabel ~= nil then
        self._MyRankLabel:setString(tostring(selfData._MyShaChangRank))
    end
    if self._MyRongYuLabel ~= nil then
        self._MyRongYuLabel:setString(tostring(selfData._RongYuZhi))
    end
    if self._TiaoZhanLabel ~= nil then
        self._TiaoZhanLabel:setString(tostring(selfData._CanTianZhanCount))
    end
    if self._MyLevelLabel ~= nil then
        self._MyLevelLabel:setString("lv."..selfData._Level)
    end
    local characterServerDataManager = GameGlobal:GetCharacterServerDataManager()
    if self._MyPlayerIcon ~= nil then
        local HeadIcon = seekNodeByName(self._PlayerHeadIcon, "Image_1")
        local warrior = characterServerDataManager:GetLeader(selfData._HeadId)
        if warrior ~= nil then
            local headName = warrior._CharacterData["headName"]
            self._MyPlayerIcon:loadTexture(GetWarriorHeadPath(headName))
        end
    end

    --奖励数据刷新
    local rewardID = selfData._ShaChangReward 
    local rewardData = self._ShaChangRewardList[rewardID]
    if rewardData ~= nil then
        if self._RewardCoinLabel ~= nil then
            self._RewardCoinLabel:setString(tostring(rewardData.minsilver))
        end
        if self._RewardRongYuLabel ~= nil then
            self._RewardRongYuLabel:setString(tostring(rewardData.rongyu))
        end
    else
        if self._RewardCoinLabel ~= nil then
            self._RewardCoinLabel:setString(tostring(0))
        end
        if self._RewardRongYuLabel ~= nil then
            self._RewardRongYuLabel:setString(tostring(0))
        end
    end

   local currentIndex = 1
   local dataTable = GamePlayerDataManager._OtherShaChangPlayerTable
    
    --排行榜前三玩家
    local rankDataTable = GamePlayerDataManager._ShaChangTop5Info
    local function sortFunction(a, b)
        if a ~= nil and b ~= nil then
            return a._Rank < b._Rank
        end
    end
    
    if rankDataTable ~= nil then
        table.sort(rankDataTable, sortFunction)
        for i = 1, 3 do
            local rankData = rankDataTable[i]
            local nodeName = string.format("Node_Player_%d", i) 
            local parentNode  = seekNodeByName(self._RankPlayerRootNode, nodeName)
            parentNode:removeAllChildren(false)
            
            local newPlayerUINode = cc.CSLoader:createNode(PLAYERINFO_ITEM_CSB_NAME)
            local bodyImage = self:RefreshOnePlayerInfo(newPlayerUINode, rankData, 1)
            parentNode:addChild(newPlayerUINode, 0)
        end
    end

    --要挑战的玩家信息
    self._PlayerUIRootNode:removeAllChildren()
    if dataTable ~= nil then
        local currentIndex = 1
        for k, v in pairs(dataTable)do
            if currentIndex > 5 then
                return
            end
            local playerData = v
            local newPlayerUINode = cc.CSLoader:createNode(PLAYERINFO_ITEM_CSB_NAME)
            local bodyImage = self:RefreshOnePlayerInfo(newPlayerUINode, playerData, 1)
            if bodyImage ~= nil then
                bodyImage:setTag(k)
                bodyImage:addTouchEventListener(handler(self, self.OnShaChangPlayerClick))
            end
            self._PlayerUIRootNode:addChild(newPlayerUINode, 0)
            local positionX, positionY = 0, -10
            local width = newPlayerUINode:getContentSize().width
            --间隔
            local intervalWidth = 15
            positionX = (currentIndex - 1) * width + (currentIndex - 1) * intervalWidth
            newPlayerUINode:setPosition(positionX, positionY)
            currentIndex = currentIndex + 1
        end
    end

end
--战报刷新
function UIShangChangDianBing:RefreshZhanBaoInfo()
    self._ZhanBaoDataList = {}
    for k, v in pairs(MailServerDataManager._MailList)do
        if v._Type == MailType.MailType_ZhanBao then
            table.insert(self._ZhanBaoDataList, v)
        end
    end
end

function UIShangChangDianBing:InitCell(cell, idx)
    if cell == nil then
        return
    end
    local layout = cell:getChildByTag(tonumber(idx))
    local zhanBaoText = seekNodeByName(layout, "Text_ZhanBao")
    local realIndex = tonumber(idx) + 1
    local mailData = self._ZhanBaoDataList[realIndex]
    if mailData ~= nil then
        local contentSize = self._ZhanBaoTableview:getContentSize()
        zhanBaoText:ignoreContentAdaptWithSize(true)
        zhanBaoText:setTextAreaSize(cc.size(contentSize.width - 10 , 0))
        zhanBaoText:setString(mailData._Content)
        
        contentSize = zhanBaoText:getContentSize()
        zhanBaoText:ignoreContentAdaptWithSize(false)
        zhanBaoText:setTextAreaSize(cc.size(contentSize.width , contentSize.height))
        zhanBaoText:setString(mailData._Content)

        local textContentSize = zhanBaoText:getContentSize()
        if layout ~= nil then
            layout:setContentSize(textContentSize)
        end
        
        mailData._ContentSize = textContentSize
    end
end

function UIShangChangDianBing:CellSizeForTable(view, idx)
    local realIndex = tonumber(idx) + 1
    local mailData = self._ZhanBaoDataList[realIndex] 
    if mailData ~= nil then
        return  mailData._ContentSize.height, mailData._ContentSize.width    --return 50, 50 
    end
    return 0, 0
end

function UIShangChangDianBing:OnRongYuListener()
    local selfData = GamePlayerDataManager:GetMyselfData()
    self._MyRongYuLabel:setString(tostring(selfData._RongYuZhi))
end

function UIShangChangDianBing:TableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
        local layout = cc.CSLoader:createNode("csb/ui/UIShaChangZhanBaoItem.csb")
        cell:addChild(layout, 0, idx)
    else
        cell:removeAllChildren(true)
        local layout = cc.CSLoader:createNode("csb/ui/UIShaChangZhanBaoItem.csb")
        cell:addChild(layout, 0, idx)
    end
    self:InitCell(cell, idx)
    return cell
end

function UIShangChangDianBing:NumberOfCellsInTableView()
    return #self._ZhanBaoDataList
end

--事件：刷新沙场玩家数据
function UIShangChangDianBing:OnRefreshPlayerInfo(event)
    self:RefreshPlayerInfo()
end
--事件：刷新战报
function UIShangChangDianBing:OnRefreshZhanBaoInfo(event)
    self:RefreshZhanBaoInfo()
end

--要点击的玩家
function UIShangChangDianBing:OnShaChangPlayerClick(sender, eventType)
     if eventType == ccui.TouchEventType.ended then

        if not self._CurFormationIndex then
            local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
            UITip:SetStyle(1, "请先选择阵型。")
            return
        end

        local playerId = sender:getTag()
        --当前次数判定
        local selfData = GamePlayerDataManager:GetMyselfData()
        if selfData._CanTianZhanCount <= 0 then
            print("_CanTianZhanCount count <= 0")
            local ItemDataManager = GameGlobal:GetItemDataManager()
            local currentItemCount =  ItemDataManager:GetItemCount(30020)
            if currentItemCount <= 0 then
                local buyShop = UISystem:OpenUI(UIType.UIType_BuyItem)
                buyShop:OpenItemInfoNotifiaction(30020)
                return
            else
                local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                UITip:SetStyle(0, GameGlobal:GetTipDataManager(UI_scdb_01))
                UITip:RegisteDelegate(function()
                    self:ChallengeInfoSend(playerId)
                end, 1)
                return
            end
        end
        self:ChallengeInfoSend(playerId)
     end
end
--将挑战玩家发送信息提取出来（加了一个是否使用挑战令的判断）
function UIShangChangDianBing:ChallengeInfoSend(playerId)
    local dataTable = GamePlayerDataManager._OtherShaChangPlayerTable
    if dataTable ~= nil then
        local playerData = dataTable[playerId]
        SendMsg(PacketDefine.PacketDefine_ArenaChallenge_Send, {playerData._WuJiangTableID})
    end
end

function UIShangChangDianBing:OnZhenXingSelectButtonClick(sender, eventType)
    if eventType ~= ccui.TouchEventType.ended then
        return
    end

    self._ZhenXingSelectTouchPanel:setVisible(true)

    for i = 1, 3 do
        local zhenXingData = CharacterServerDataManager:GetZhenXingData(i)
        local isHaveData = false
        if zhenXingData ~= nil then
            for k, v in pairs(zhenXingData)do
                isHaveData = true 
                break
            end
        end
        local buttonName = string.format("Button_ZhenXing_%d", i)
        local currentButton = seekNodeByName(self._ZhenXingSelectPanel,buttonName)
        if currentButton ~= nil then
            currentButton:setEnabled(isHaveData)
        end
    end
end

--阵型按钮
function UIShangChangDianBing:OnZhenXingButtonClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self._CurFormationIndex = sender:getTag() - 60
        self._ZhenXingSelectTouchPanel:setVisible(false)
        self._ZhenXingSelect:setString(ChineseConvert["UITitle_"..(self._CurFormationIndex + 13)])
        SendMsg(PacketDefine.PacketDefine_FormationUse_Send, {2, self._CurFormationIndex - 1}) 
    end
end

--阵型选择面板关闭
function UIShangChangDianBing:OnZhenXingSelectClose(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self._ZhenXingSelectTouchPanel:setVisible(false)       
    end
end

--领取奖励
function UIShangChangDianBing:OnTakeReward(sender, eventType)
   --是否可领取
   if eventType == ccui.TouchEventType.ended then
       SendMsg(PacketDefine.PacketDefine_ArenaAward_Send)
   end
end

--左上Button
function UIShangChangDianBing:OnLeftTopButtonEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
        if tag == LeftTopButton_Type.LeftTopButton_JiangLi then
            UISystem:OpenUI(UIType.UIType_ShaChangRewardList)
        elseif tag == LeftTopButton_Type.LeftTopButton_PaiHang then
            UISystem:OpenUI(UIType.UIType_ShaChangRank)
            SendMsg(PacketDefine.PacketDefine_AppeaRankingList_Send)
        elseif tag == LeftTopButton_Type.LeftTopButton_RongYuShop then
            UISystem:OpenUI(UIType.UIType_RongYuShop)
        end
    end
end

return UIShangChangDianBing
