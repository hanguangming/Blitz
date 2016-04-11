----
-- 文件名称：UIUseHuFu.lua
-- 功能描述：战斗使用虎符界面
-- 文件说明：战斗使用虎符界面
-- 作    者：刘胜勇
-- 创建时间：2015-7-20
--  修改

require("main.UI.UIBase")
require("main.UI.UITypeDefine") 
--ui基类
local UISystem = GameGlobal:GetUISystem() 
local UIUseHuFu = class("UIUseHuFu.lua", UIBase)
local _Instance = nil 
--玩家信息
local GamePlayerDataManager = GameGlobal:GetGamePlayerDataManager()
--物品信息
local ItemDataManager = GameGlobal:GetItemDataManager()
--虎符id
local HuFu = 30019
local passType
local isCustonSweet = false

function UIUseHuFu:ctor()
    UIBase.ctor(self)
    self.Type = UIType.UIType_UseHuFu
    self._ResourceName = "UIUseHuFu.csb"  
end
--加载UI 类似UI初始化
function UIUseHuFu:Load()
    UIBase.Load(self)
    --使用虎符数量    
    self._UseTxt = self:GetUIByName("UseTxt")
    local sweet = UISystem:GetUIInstance(UIType.UIType_CustomSweep)
    local num = 0
    if sweet ~= nil then
        for i = 0, sweet.SweepNum - GetPlayer()._Energy - 1 do
            num = num + math.floor((GetPlayer()._NeedHuFuTimes + i) / GameGlobal:GetParameterDataManager()["tiger_times"].value) + 1
        end
    else
        num =  math.floor((GetPlayer()._NeedHuFuTimes) / GameGlobal:GetParameterDataManager()["tiger_times"].value) + 1
    end
    gCurUseHufuNum = num
    self._UseTxt:setString(num)
    --当前拥有虎符数量 
    self. _CurTxt = self:GetUIByName("CurTxt")
    self. _CurTxt:setString(ItemDataManager:GetItemCount(HuFu))
    
    --使用按钮
    local _UseBtn = self:GetUIByName("UseBtn")
    _UseBtn:setTag(1)
    _UseBtn:addTouchEventListener(self.TouchEvent)
    
    --关闭按钮
    local _CLoseBtn = self:GetUIByName("Close")
    _CLoseBtn:setTag(-1)
    _CLoseBtn:addTouchEventListener(self.TouchEvent)
    
    seekNodeByName(self._RootUINode, "Panel_2"):setSwallowTouches(true) 
    seekNodeByName(self._RootUINode, "Panel_2"):setTag(-1)
    seekNodeByName(self._RootUINode, "Panel_2"):addTouchEventListener(self.TouchEvent)
    
    _Instance = self
end
--UI卸载
function UIUseHuFu:Unload()
    UIBase:Unload()
    self._ResourceName = nil
    self.Type = nil
end

--UI打开
function UIUseHuFu:Open()
    UIBase.Open(self)
    self.SelectCallBack = AddEvent(GameEvent.GameEvent_UIUseHuFu_Succeed, self.SelectSuccess)
end

--UI关闭
function UIUseHuFu:Close()
    UIBase.Close(self)
    if self.SelectCallBack ~= nil then
        RemoveEvent(self.SelectCallBack)
        self.SelectCallBack = nil
    end
end
function UIUseHuFu:SelectSuccess()
    passType = self._usedata
end
--事件处理
function UIUseHuFu:TouchEvent(eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = self:getTag()
        if tag == -1 then
            UISystem:CloseUI(UIType.UIType_UseHuFu)
        elseif tag == 1 then --使用进入战场
            if not isCustonSweet then
                _Instance:EnterBattle()
            else
                UISystem:CloseUI(UIType.UIType_UseHuFu)
                local sweet = UISystem:GetUIInstance(UIType.UIType_CustomSweep)
               
                SendMsg(PacketDefine.PacketDefine_StageBatch_Send, {GameGlobal:GetCustomDataManager()[passType]["id"], sweet.SweepNum})
            end
        end
    end
end

function UIUseHuFu:SetBattleType(value, level)
    isCustonSweet = value
    passType = level 
end

--使用虎符进入战场
function UIUseHuFu:EnterBattle()
    SendMsg(PacketDefine.PacketDefine_Stage_Send, {GameGlobal:GetCustomDataManager()[passType]["id"]})
    UISystem:CloseAllUI()
    GameGlobal:GetUISystem():OpenUI(UIType.UIType_BattleUI, passType)
end

return UIUseHuFu