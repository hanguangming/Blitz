----
-- 文件名称：UICustomSweep.lua
-- 功能描述：关卡打扫界面
-- 文件说明：关卡扫荡界面
-- 作    者：刘胜勇
-- 创建时间：2015-7-21
--  修改

require("main.UI.UIBase")
require("main.UI.UITypeDefine") 

local UISystem = GameGlobal:GetUISystem() 
local UICustomSweep = class("UICustomSweep", UIBase)
 
-- 玩家信息
local GamePlayerDataManager = GameGlobal:GetGamePlayerDataManager()
-- 物品信息
local ItemDataManager = GameGlobal:GetItemDataManager()
-- 获取关卡表数据
local CustomDataManager = GameGlobal:GetCustomDataManager()
-- 关卡奖励表
local CustomRewardDataManager = GameGlobal:GetCustomRewardDataManager()

function UICustomSweep:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_CustomSweep
    self._ResourceName = "UICustomSweep.csb"  
end

-- 加载UI
function UICustomSweep:Load()
    UIBase.Load(self)
    
    -- 扫荡按钮
    local sweetBtn = self:GetUIByName("StartBtn")
    sweetBtn:setTag(1)

    -- 取消按钮
    local cancelBtn = self:GetUIByName("CloseBtn")
    cancelBtn:setTag(-1)

    -- 关闭按钮
    local closeBtn = self:GetUIByName("Close")
    closeBtn:setTag(-1)

    -- 减少按钮
    local delBtn = self:GetUIByName("DelBtn")
    delBtn:setTag(2)
    
    -- 增加按钮
    local addBtn = self:GetUIByName("AddBtn")
    addBtn:setTag(3)

    -- 扫荡次数
    self._sweetNumText = self:GetUIByName("NumTxt")
    
    -- 军令数量
    self._junLingNumText = self:GetUIByName("TxtJunLing")
   
    -- 注册按钮监听事件
    sweetBtn:addTouchEventListener(handler(self, self.touchEvent))
    cancelBtn:addTouchEventListener(handler(self, self.touchEvent))
    closeBtn:addTouchEventListener(handler(self, self.touchEvent))
    delBtn:addTouchEventListener(handler(self, self.touchEvent))
    addBtn:addTouchEventListener(handler(self, self.touchEvent))
    
end

-- UI卸载
function UICustomSweep:Unload()
    UIBase.Unload()
end

-- UI打开
function UICustomSweep:Open()
    UIBase.Open(self)
    
    -- 当前所要扫荡的关卡
    self._level = nil
    
    -- 初始化扫荡次数
    self._sweepNum = 1
    self._sweetNumText:setString(self._sweepNum)
    
    -- 初始化军令数量
    self._junLingNumText:setString(GetPlayer()._Energy)
    
    -- 注册关卡扫荡显示与更新军令数量监听事件
    self:addEvent(GameEvent.GameEvent_UICustomSweep_Succeed,self.sweepSuccessListener)
    self:addEvent(GameEvent.GameEvent_SweepEnergy_Succeed,self.updateEnergyListener)
end

-- UI关闭
function UICustomSweep:Close()
    UIBase.Close(self) 
end

-- 监听回调事件,UI成功打开,加载掉落数据信息
function UICustomSweep:sweepSuccessListener(event)
    self._level = event._usedata
    local RewardDataManager = GameGlobal:GetCustomRewardDataManager()
    local data = CustomRewardDataManager[tonumber(CustomDataManager[self._level]["rewardid"])]
    local layout = seekNodeByName(self._RootPanelNode, "Panel_1") 
    for i = 1, 5 do
        local item = seekNodeByName(layout, "item"..i)
        if data[i + 1] ~= nil then
            if tonumber(data[i + 1].p1) > 10 then
                item:loadTexture("meishu/ui/gg/"..GetPropDataManager()[tonumber(data[i + 1].p1)]["quality"]..".png", UI_TEX_TYPE_LOCAL)
                local txt = seekNodeByName(item, "num")
                txt:setString("")
            else
                item:loadTexture("meishu/ui/gg/1.png", UI_TEX_TYPE_LOCAL)
                local txt = seekNodeByName(item, "num")
                txt:setString(data[i + 1].l1)
            end
            local icon = seekNodeByName(item, "icon1")
            icon:loadTexture(GetPropPath(data[i + 1].p1), UI_TEX_TYPE_LOCAL)
            
        else 
            item:loadTexture("meishu/ui/gg/1.png", UI_TEX_TYPE_LOCAL)
            local icon = seekNodeByName(item, "icon1")
            icon:loadTexture("meishu/ui/gg/null.png", UI_TEX_TYPE_LOCAL)
            local txt = seekNodeByName(item, "num")
            txt:setString("")
        end
    end
end

-- 监听军令数量更新回调事件
function UICustomSweep:updateEnergyListener()
    self._junLingNumText:setString(GetPlayer()._Energy)
end

-- 触摸监听事件处理
function UICustomSweep:touchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
        if tag == -1 then
            UISystem:CloseUI(UIType.UIType_CustomSweep)
        elseif tag == 1 then --进入扫荡
            if GetPlayer()._Energy >= self._sweepNum then
                SendMsg(PacketDefine.PacketDefine_StageBatch_Send, {GameGlobal:GetCustomDataManager()[self._level]["id"], self._sweepNum})
            else
                local num = 0
                for i = 0, self._sweepNum - GetPlayer()._Energy - 1 do
                    num = num + math.floor((GetPlayer()._NeedHuFuTimes + i) / GameGlobal:GetParameterDataManager()["tiger_times"].value) + 1
                end
                
                if GameGlobal:GetItemDataManager():GetItemCount(30019) >= num then
                    local UITip =  GameGlobal:GetUISystem():OpenUI(UIType.UIType_TipUI)
                    UITip:SetStyle(0, "军令不足，是否消耗"..num.."虎符进行战斗？")
                    UITip:RegisteDelegate(self.sweetCommit, 1)
                else
                    UISystem:OpenUI(UIType.UIType_BuyItem)
                    local uiInstance = UISystem:GetUIInstance(UIType.UIType_BuyItem)
                    uiInstance:OpenItemInfoNotifiaction(30019, num - GameGlobal:GetItemDataManager():GetItemCount(30019))
                end
            end
        elseif tag == 2 then
            self._sweepNum = self._sweepNum - 1 
            if self._sweepNum <= 1 then
                self._sweepNum = 1
            end
            self._sweetNumText:setString(self._sweepNum)
        elseif tag == 3 then
            self._sweepNum = self._sweepNum + 1
            if self._sweepNum >= 30 then
               self._sweepNum = 30
            end
            self._sweetNumText:setString(self._sweepNum)
        end
    end
end

-- 军令不足，打开使用虎符界面
function UICustomSweep:sweetCommit()
    UISystem:OpenUI(UIType.UIType_UseHuFu)
    UISystem:GetUIInstance(UIType.UIType_UseHuFu):SetBattleType(true, self._level)
end

return UICustomSweep