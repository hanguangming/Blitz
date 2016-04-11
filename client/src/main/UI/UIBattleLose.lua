----
-- 文件名称：UIBattleLose.lua
-- 功能描述：战斗失败显示控制
-- 文件说明：战斗失败显示控制
-- 作    者：刘胜勇
-- 创建时间：2015-7-10
--  修改

require("main.UI.UIBase")
require("main.UI.UITypeDefine") 
--ui基类
local UISystem = GameGlobal:GetUISystem() 
local UIBattleLose = class("UIBattleLose", UIBase)
local _Instance = nil 

function UIBattleLose:ctor()
    UIBase.ctor(self)
    self.Type = UIType.UIType_BattleLoseUI
    self._ResourceName = "UIBattleLose.csb"  
end
--加载UI 类似UI初始化
function UIBattleLose:Load()
    UIBase.Load(self)
    --[[
--  --招募    
--    self. _ZMText = self:GetUIByName("Text_2")
--    self._ZMText:setTag(1)
--    self._ZMText:addClickEventListener(self.TouchEvent)
    --
    local _ZmBtn = self:GetUIByName("Button_1")
    _ZmBtn:setTag(1)
    _ZmBtn:addTouchEventListener(self.TouchEvent)
    --强化装备    
--    self. _QHText = self:GetUIByName("Text_3")
--    self._QHText:setTag(2)
--    self._QHText:addClickEventListener(self.TouchEvent)
    local _QhBtn = self:GetUIByName("Button_2")
    _QhBtn:setTag(2)
    _QhBtn:addTouchEventListener(self.TouchEvent)
    --武将训练 
--    self. _WJText = self:GetUIByName("Text_4")
--    self._WJText:setTag(3)
--    self._WJText:addClickEventListener(self.TouchEvent)
    local _WJBtn = self:GetUIByName("Button_3")
    _WJBtn:setTag(3)
    _WJBtn:addTouchEventListener(self.TouchEvent)
    --士兵训练 
--    self. _SBText = self:GetUIByName("Text_5")
--    self._SBText:setTag(4)
--    self._SBText:addClickEventListener(self.TouchEvent)
    local _SBBtn = self:GetUIByName("Button_4")
    _SBBtn:setTag(4)
    _SBBtn:addTouchEventListener(self.TouchEvent)
    --关闭按钮
    local _CLoseBtn = self:GetUIByName("Close")
    _CLoseBtn:setTag(-1)
    _CLoseBtn:addTouchEventListener(self.TouchEvent)
    --]]
    --武将训练
    local warriorTrainButton = self:GetWigetByName("Button_1")
    warriorTrainButton:setTag(1)
    warriorTrainButton:addTouchEventListener(self.TouchEvent)
    --士兵训练
    local soldierTrainButton = self:GetWigetByName("Button_2")
    soldierTrainButton:setTag(2)
    soldierTrainButton:addTouchEventListener(self.TouchEvent)
    --招募武将
    local recruitWarriorButton = self:GetWigetByName("Button_3")
    recruitWarriorButton:setTag(3)
    recruitWarriorButton:addTouchEventListener(self.TouchEvent)
    --装备强化
    local equipStrengButton = self:GetWigetByName("Button_4")
    equipStrengButton:setTag(4)
    equipStrengButton:addTouchEventListener(self.TouchEvent)
    --关闭按钮
    local closeButton = self:GetWigetByName("Close")
    closeButton:setTag(-1)
    closeButton:addTouchEventListener(self.TouchEvent)
    
    _Instance = self
end
--UI卸载
function UIBattleLose:Unload()
    UIBase:Unload()
    self._ResourceName = nil
    self.Type = nil  
end
--UI打开
function UIBattleLose:Open()
    UIBase.Open(self)
end
--UI关闭 
function UIBattleLose:Close()
    UIBase.Close(self)
end
--事件处理
function UIBattleLose:TouchEvent(eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = self:getTag()
        if tag == -1 then
            UISystem:CloseUI(UIType.UIType_BattleLoseUI)
        elseif tag == 1 then
            local  train = UISystem:OpenUI(UIType.UIType_TrainUI)
            train:ChangeTabState(1)
        elseif tag == 2 then
            local  train = UISystem:OpenUI(UIType.UIType_TrainUI)
            train:ChangeTabState(2)
        elseif tag == 3 then
            UISystem:OpenUI(UIType.UIType_UIRecruit)
        elseif tag == 4 then
            UISystem:OpenUI(UIType.UIType_EquipUI)
        end
    end
end
return UIBattleLose