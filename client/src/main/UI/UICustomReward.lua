----
-- 文件名称：UICustomReward.lua
-- 功能描述：关卡打扫界面
-- 文件说明：关卡扫荡界面
-- 作    者：刘胜勇
-- 创建时间：2015-7-21
--  修改

require("main.UI.UIBase")
require("main.UI.UITypeDefine") 

local UISystem = GameGlobal:GetUISystem() 
local UICustomReward = class("UICustomReward", UIBase)

-- 物品信息
local ItemDataManager = GameGlobal:GetItemDataManager()

function UICustomReward:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_CustomReward
    self._ResourceName = "UICustomReward.csb"  
end

-- 加载UI 
function UICustomReward:Load()
    UIBase.Load(self)

    -- 确认按钮
    local confirmBtn = self:GetUIByName("CloseBtn")
    confirmBtn:setTag(-1)

    -- 关闭按钮
    local closeBtn = self:GetUIByName("Close")
    closeBtn:setTag(-1)

    -- 注册按钮监听事件
    confirmBtn:addTouchEventListener(handler(self, self.touchEvent))
    closeBtn:addTouchEventListener(handler(self, self.touchEvent))
     
end

-- 卸载UI
function UICustomReward:Unload()
    UIBase.Unload()
end

-- UI打开
function UICustomReward:Open()
    UIBase.Open(self)
    self:openUISuccess()
end

-- UI关闭
function UICustomReward:Close()
    UIBase.Close(self)
end

-- 初始化掉落UI信息
function UICustomReward:openUISuccess()
   
    local layout = seekNodeByName(self._RootPanelNode, "Panel_1") 
    for i = 1, 5 do
        local item = seekNodeByName(layout, "item"..i)
        if GetGlobalData()._RewardList[i] ~= nil then
            
            if tonumber(GetGlobalData()._RewardList[i][1]) > 100 then
                print(GetGlobalData()._RewardList[i][1])
                item:loadTexture("meishu/ui/gg/"..GetPropDataManager()[tonumber(GetGlobalData()._RewardList[i][1])]["quality"]..".png", UI_TEX_TYPE_LOCAL)
            else
                item:loadTexture("meishu/ui/gg/1.png", UI_TEX_TYPE_LOCAL)
            end
            local itemNum = seekNodeByName(item, "num")
            itemNum:setString(GetGlobalData()._RewardList[i][2])
            local icon = seekNodeByName(item, "icon1")
            icon:loadTexture(GetPropPath(GetGlobalData()._RewardList[i][1]), UI_TEX_TYPE_LOCAL)

        else 
            item:loadTexture("meishu/ui/gg/1.png", UI_TEX_TYPE_LOCAL)
            local icon = seekNodeByName(item, "icon1")
            icon:loadTexture("meishu/ui/gg/null.png", UI_TEX_TYPE_LOCAL)
            local itemNum = seekNodeByName(item, "num")
            itemNum:setString("")
        end
    end
end

-- 触摸监听事件处理
function UICustomReward:touchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
        if tag == -1 then
            UISystem:CloseUI(UIType.UIType_CustomReward)
        end
    end
end

return UICustomReward