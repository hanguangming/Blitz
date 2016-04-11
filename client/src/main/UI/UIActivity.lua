----
-- 文件名称：UITest.lua
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

local UIActivity = class("UIActivity", UIBase)
local g_ActivityName = {"月卡", "在线", "招财", "任务", "签到", "VIP"}

--构造函数
function UIActivity:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_UIActivity
    self._ResourceName =  "UIActivity.csb"
end

--Load
function UIActivity:Load()
    UIBase.Load(self)
    self._GridView =  CreateTableView(80, 90, 200, 330, cc.TABLEVIEW_FILL_BOTTOMUP, self)
    self:addChild(self._GridView, 0, 0)
    self._GridView:reloadData()
    local close = self:GetWigetByName("Close")
    close:setTag(-1)
    close:addTouchEventListener(self.TouchEvent)
end

--Unload
function UIActivity:Unload()
    UIBase.Unload(self)

end

--打开
function UIActivity:Open()
    UIBase.Open(self)
end

--关闭
function UIActivity:Close()
    UIBase.Close(self)
end

function UIActivity:TouchEvent(eventType)
    if eventType == ccui.TouchEventType.ended then
        if self:getTag() == -1 then
            UISystem:CloseUI(UIType.UIType_UIActivity)
        end
    end
end


function UIActivity.TableCellTouched(view, cell)
    local idx = cell:getIdx()

    if idx == 0 then
        UISystem:OpenUI(UIType.UIType_MonthCardUI)
    elseif idx == 1 then
    elseif idx == 2 then
        UISystem:OpenUI(UIType.UIType_EveryReward)
    elseif idx == 3 then    
        
    elseif idx == 4 then
        UISystem:OpenUI(UIType.UIType_SignInUI)
    elseif idx == 5 then
        UISystem:OpenUI(UIType.UIType_VipUI)
    end
end

function UIActivity.CellSizeForTable(view, idx)
    return 117, 55
end

function UIActivity.NumberOfCellsInTableView()
    return 6
end

function UIActivity.TableCellAtIndex(view, idx)
    local cell = view:dequeueCell()

    if not cell then
        cell = cc.TableViewCell:new()
        cell:retain()
    end
    cell:removeAllChildren(true)
    local layout = cc.CSLoader:createNode("csb/ui/ActivityItem.csb")
    seekNodeByName(layout , "Button_1"):getTitleRenderer():setString(g_ActivityName[idx + 1])
    seekNodeByName(layout , "Button_1"):setSwallowTouches(false)
    -- setSwallowTouches false
    layout:setPosition(cc.p(0, 0))
    cell:addChild(layout, 0, idx)
    return cell
end

return UIActivity
