----
-- 文件名称：UICountrySelect.lua
-- 功能描述：测试UI
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-6-16
-- 修改 ：
--  测试UI动画的支持情况
--
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
local UISystem = require("main.UI.UISystem")

local UIRecharge = class("UIRecharge", UIBase)
local _Instance = nil 

--构造函数
function UIRecharge:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_UIRecharge
    self._ResourceName =  "UIRecharge.csb"
end

--Load
function UIRecharge:Load()
    UIBase.Load(self)
    self._CountryButton = {}
    for i = 1, 5 do
        local recharge = self:GetWigetByName("Recharge_"..i)
        self._CountryButton[i] = seekNodeByName(recharge, "Button_1")
        seekNodeByName(recharge, "Text_2"):setString(GameGlobal:GetRechargeDataManager()[i].rmb)
        seekNodeByName(recharge, "Text_3"):setString(GameGlobal:GetRechargeDataManager()[i].yuanbao.."+"..GameGlobal:GetRechargeDataManager()[i].addyuanbao)
        self._CountryButton[i]:setTag(i)
        self._CountryButton[i]:addTouchEventListener(self.TouchEvent)
    end
    self:GetWigetByName("Close"):setTag(-1)
    self:GetWigetByName("Close"):addTouchEventListener(self.TouchEvent)
    _Instance = self
end

--Unload
function UIRecharge:Unload()
    UIBase.Unload(self)
    
end

--打开
function UIRecharge:Open()
    UIBase.Open(self)
end

--关闭
function UIRecharge:Close()
    UIBase.Close(self)
end

function UIRecharge:TouchEvent(eventType)
    if type(eventType) == "table" then
        eventType = eventType.eventType
    end
    if eventType == ccui.TouchEventType.ended then
        if self:getTag() == -1 then
            UISystem:CloseUI(UIType.UIType_UIRecharge)
        else
            SendMsg(PacketDefine.PacketDefine_Recharge_Send, {self:getTag()})
        end
    end
end

return UIRecharge
