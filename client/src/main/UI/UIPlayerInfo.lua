----
-- 文件名称：UIPlayerInfo.lua
-- 功能描述：玩家信息
-- 文件说明：玩家信息
-- 作       者：秦宝
-- 创建时间：2015-11-02
-- 修改

require("cocos.ui.DeprecatedUIEnum")
require("cocos.extension.ExtensionConstants")
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
require("src.cocos.ui.GuiConstants")
local UISystem =  GameGlobal:GetUISystem()
local GamePlayerDataManager = GameGlobal:GetGamePlayerDataManager()
local vipDataManager = GameGlobal:GetVipDataManager()
local expDataManager = GameGlobal:GetExpDataManager()
local characterServerDataManager = GameGlobal:GetCharacterServerDataManager()
local B_STATE_CLOSE = -1
local B_STATE_SET = 4
local B_STATE_GONGGAO = 2
local B_STATE_RETURN = 3
local B_STATE_FIXED = 1

local UIPlayerInfo = class("UIPlayerInfo", UIBase)

function UIPlayerInfo:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_PlayerInfo
    self._ResourceName = "UIPlayerInfo.csb"  
end

function UIPlayerInfo:Load()
    UIBase.Load(self)
    --关闭
    local closeButton = self:GetWigetByName("Button_Close")
    if closeButton ~= nil then
        closeButton:setTag(B_STATE_CLOSE)
        closeButton:addTouchEventListener(self.TouchEvent)
    end
    --底部三个按钮
    for i = 1, 4 do
        local btn = self:GetWigetByName("Button_"..i)
        btn:setTag(i)
        btn:addTouchEventListener(self.TouchEvent)
    end
    --名称
    self._PlayerName = self:GetWigetByName("Text_Name")
    --国家
    self._PlayerCountry = self:GetWigetByName("Text_Country")
    --ID
    self._PlayerID = self:GetWigetByName("Text_ID")
    --Level
    self._PlayerLevel = self:GetWigetByName("Text_Level")
    --经验
    self._PlayerExp = self:GetWigetByName("Text_Exp")
    --战力
    self._PlayerBattleValue = self:GetWigetByName("Text_BattleValue")
    --军令
    self._PlayerJunLingCount = self:GetWigetByName("Text_JunLing")
    --铜钱
    self._PlayerTongQian = self:GetWigetByName("Text_TongQian")
    --元宝
    self._PlayerYuanBao = self:GetWigetByName("Text_YuanBao")
    --头像
    self._PlayerHeadIcon = self:GetWigetByName("Image_Icon")
    --进度条
    self._LoadingPer = self:GetWigetByName("Image_Loading")
end

function UIPlayerInfo:Unload()
    UIBase:Unload()
end

function UIPlayerInfo:Open()
    UIBase.Open(self)
    self:InitPlayerData()
end

function UIPlayerInfo:Close()
    UIBase.Close(self)
end

function UIPlayerInfo:InitPlayerData()
    local myselfData = GamePlayerDataManager:GetMyselfData()
    self._PlayerName:setString(myselfData._UserName)
    self._PlayerCountry:setString(GetCountryChinese(g_CountryID))
    self._PlayerID:setString(gUid)
    self._PlayerLevel:setString("LV  "..myselfData._Level)
    self._PlayerBattleValue:setString(myselfData._BattleValue)
    self._PlayerExp:setString(myselfData._Exp.."/"..expDataManager[myselfData._Level]["selfExp"])
    --进度条
    local per = (myselfData._Exp / expDataManager[myselfData._Level]["selfExp"])*100
    local progressBar = seekNodeByName(self._LoadingPer, "LoadingBar_1_0")
    progressBar:setPercent(per) 
    --军令
    local junLingText = myselfData._Energy .. "/" .. vipDataManager[myselfData._VIPLevel]["tilimax"]
    self._PlayerJunLingCount:setString(junLingText)
    self._PlayerTongQian:setString(myselfData._Silver)
    self._PlayerYuanBao:setString(myselfData._Gold)
    --头像
    local HeadIcon = seekNodeByName(self._PlayerHeadIcon, "Image_1")
    local warrior = characterServerDataManager:GetLeader(myselfData._HeadId)
    if warrior ~= nil then
        local headName = warrior._CharacterData["headName"]
        HeadIcon:loadTexture(GetWarriorHeadPath(headName))
    end
end

function UIPlayerInfo.TouchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
        if tag == B_STATE_CLOSE then
            UISystem:CloseUI(UIType.UIType_PlayerInfo)
        elseif tag == B_STATE_SET then
            UISystem:OpenUI(UIType.UIType_Setting)
        elseif tag == B_STATE_GONGGAO then
        
        elseif tag == B_STATE_RETURN then
             GameGlobal:GetNetSystem():CloseConnect()
            for k, v in pairs(GlobalCSB) do
                if gAllCsbNodeList[v] then
                    gAllCsbNodeList[v] = nil
                end
            end
            UISystem:OpenUI(UIType.UIType_LoginUI)
        elseif tag == B_STATE_FIXED then
            
        end 
    end
end

return UIPlayerInfo