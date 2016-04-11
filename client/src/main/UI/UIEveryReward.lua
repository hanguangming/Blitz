----
-- 文件名称：UIEveryReward.lua
-- 功能描述：UIEveryReward
-- 文件说明：
-- 作    者：
-- 创建时间：2015-8-5
-- 修改 ：
-- 
--
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
local UISystem = require("main.UI.UISystem")

local UIEveryReward = class("UIEveryReward", UIBase)

--构造函数
function UIEveryReward:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_EveryReward
    self._ResourceName = "UIEveryReward.csb" 
end

--Load
function UIEveryReward:Load()
    UIBase.Load(self)
    _Instance = self
   
    local btn = self:GetUIByName("Button_buy")
    btn:setTag(1)
    btn:addTouchEventListener(self.TouchEvent)
    btn:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 250), 2)
    btn:getTitleRenderer():setPositionY(33)
    
    local btn = self:GetUIByName("Button_help")
    btn:setTag(2)
    btn:addTouchEventListener(self.TouchEvent)
    btn:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 250), 2)
    
    self:GetUIByName("Every_Count")
    self:GetUIByName("glod_min")
    self:GetUIByName("glod_max")
    for i = 1, 11 do
        self:GetUIByName("Text_"..i):enableOutline(cc.c4b(0, 0, 0, 250), 1)
    end
    self._LoadingBar = self:GetUIByName("LoadingBar")
    self._LoadingBar:setPercent(100/3)
    local cancel = self:GetUIByName("Close")
    cancel:setTag(-1)
    cancel:addTouchEventListener(self.TouchEvent)
    
end

--Unload
function UIEveryReward:Unload()
    UIBase.Unload(self)
end

--打开
function UIEveryReward:Open()
    UIBase.Open(self)
    local roleInfo = GetPlayer()
    self.OpenCallBack = AddEvent(GameEvent.GameEvent_UIEveryReward_Succeed, self.OpenUISuccess)
    SendMsg(PacketDefine.PacketDefine_GetRewardInfo_Send, {0, 2})
end

--关闭
function UIEveryReward:Close()
    UIBase.Close(self)
end

function UIEveryReward:OpenUISuccess()
    print(self._usedata[1])
end

function UIEveryReward:TouchEvent(eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = self:getTag()
        if tag == -1 then
            UISystem:CloseUI(UIType.UIType_EveryReward) 
        elseif tag == 1 then
            SendMsg(PacketDefine.PacketDefine_BuyGift_Send, { 6 })
        end
    end
end

return UIEveryReward
