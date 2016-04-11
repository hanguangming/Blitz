----
-- 文件名称：UISignIn.lua
-- 功能描述：UISignIn
-- 文件说明：
-- 作    者：
-- 创建时间：2015-8-5
-- 修改 ：
-- 
--
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
local UISystem = require("main.UI.UISystem")

local UISignIn = class("UISignIn", UIBase)

--构造函数
function UISignIn:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_SignInUI
    self._ResourceName =  "UISignIn.csb" 
end

--Load
function UISignIn:Load()
    UIBase.Load(self)
    for i = 0, 5 do
        --self:GetUINodeByName("Tip"..i):enableOutline(cc.c4b(0, 0, 0, 250), 2)
        if i > 0 then
--            local reward = self:GetUINodeByName("Image_5_"..i)
--            local CustomRewardDataManager = GameGlobal:GetCustomRewardDataManager()
--            local str = CustomRewardDataManager[1452 + i]["prop"]
--            local data = {}
--            data= SplitSet(str)
--            for j = 1, #data do
--                seekNodeByName(reward, "Image_"..j):loadTexture(GetPropDataManager()[tonumber(data[j][1])]["icon"])
--                seekNodeByName(reward, "Image_"..j):setScale(0.75)
--                seekNodeByName(reward, "Image_"..j):setPositionY(20)
--            end
--            seekNodeByName(reward, "Text_1"):enableOutline(cc.c4b(0, 0, 0, 250), 1)
--            local btn = self:GetUINodeByName("GetReward"..i) 
--            btn:setTag(i)
--            btn:addTouchEventListener(self.TouchEvent)
--            btn:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 250), 2)
--            btn:getTitleRenderer():setPositionY(32)
        end
    end
    local btn = self:GetUINodeByName("SignInBtn")
    btn:setTag(0)
    btn:addTouchEventListener(self.TouchEvent)
    btn:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 250), 2)
    btn:getTitleRenderer():setPositionY(32)
    
    local close = self:GetUINodeByName("Close")
    close:setTag(-1)
    close:addTouchEventListener(self.TouchEvent)
end

--Unload
function UISignIn:Unload()
    UIBase.Unload(self)
end

--打开
function UISignIn:Open()
    UIBase.Open(self)
    SendMsg(PacketDefine.PacketDefine_SignInfo_Send)
end

--关闭
function UISignIn:Close()
    UIBase.Close(self)
end

function UISignIn:TouchEvent(eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = self:getTag()
        if tag == -1 then
            UISystem:CloseUI(UIType.UIType_SignInUI) 
        elseif tag == 0 then
            local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
            UITip:SetStyle(1, "")
            UITip:GetUIByName("title"):setVisible(false)
            local layout = cc.CSLoader:createNode("csb/ui/ReSignInfo.csb")
            local t1 = seekNodeByName(layout, "Text_1")
            local t1str = string.gsub(t1:getString(), "@day", 12, 1)
            t1str = string.gsub(t1str, "@num", 2, 1)
            t1:setString(t1str)
            local t2 = seekNodeByName(layout, "Text_2")
            local t2str = string.gsub(t2:getString(), "@num", 3, 1)
            t2:setString(t2str)
            local t3 = seekNodeByName(layout, "Text_3")
            t3:setString("t3")
            local t4 = seekNodeByName(layout, "Text_4")
            local t4str = string.gsub(t4:getString(), "@num", 13, 1)
            t4:setString(t4str)
            local icon = seekNodeByName(layout, "icon")
            layout:setPosition(290, 160)
            UITip:addChild(layout, 0, 0)
        end
    end
end

return UISignIn
