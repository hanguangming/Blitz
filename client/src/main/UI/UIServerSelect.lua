
----
-- 文件名称：UIServerSelect.lua
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
local _Instance = nil
local UIServerSelect = class("UIServerSelect", UIBase)

--构造函数
function UIServerSelect:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_Server
    self._ResourceName =  "UIServerList.csb"
end

--Load
function UIServerSelect:Load()
    UIBase.Load(self)
    _Instance = self
    local center = self:GetWigetByName("Panel_Center")
    self._GridView =  CreateTableView(-200, -210, 400, 240, cc.TABLEVIEW_FILL_BOTTOMUP, self)
    center:addChild(self._GridView, 0, 0)
end

--Unload
function UIServerSelect:Unload()
    UIBase.Unload(self)

end

--打开
function UIServerSelect:Open(loginUI)
    UIBase.Open(self)

    self._loginUI = loginUI;

    self._GridCount = #loginUI._serverList - 4

    if self._GridCount < 0 then 
        self._GridCount = 0 
    end
    self._GridView:reloadData()
    self._ServerButton = {}
    for i = 1, 4 do
        if i <= #loginUI._serverList then
            self._ServerButton[i] = self:GetWigetByName("Button_"..i)
            seekNodeByName(self._ServerButton[i], "Text_2"):setString(loginUI._serverList[i].name)
            seekNodeByName(self._ServerButton[i], "Text_1"):setString(i.."服")
            self._ServerButton[i]:setTag(i)
            self._ServerButton[i]:addTouchEventListener(function(...) self:TouchEvent(loginUI._serverList[i].id, ...) end)
        else
            self:GetWigetByName("Button_"..i):setVisible(false)
        end
    end

end

--关闭
function UIServerSelect:Close()
    UIBase.Close(self)
end

function UIServerSelect.ScrollViewDidScroll()
end

function UIServerSelect.TableCellTouched(view, cell)
    _Instance._CurCellIdx = cell:getIdx()

end

function UIServerSelect.CellSizeForTable(view, idx)
    return 192, 71
end

function UIServerSelect.NumberOfCellsInTableView()
    return _Instance._GridCount % 2 == 0 and _Instance._GridCount / 2 or math.floor(_Instance._GridCount) / 2 + 1
end

function UIServerSelect:TableViewItemTouchEvent(value)
    local eventType = value
    if type(value) == "table" then
        eventType = value.eventType
    end
    if eventType == ccui.TouchEventType.ended then
        local tag = self:getTag()
       
    end
end

function UIServerSelect.TableCellAtIndex(view, idx)
    local cell = view:dequeueCell()

    if not cell then
        cell = cc.TableViewCell:new()
        cell:retain()
    end
    cell:removeAllChildren(true)
    local layout = cc.CSLoader:createNode("csb/ui/ServerItem.csb")
    -- setSwallowTouches false

    local button = seekNodeByName(layout, "Button_1")
    button:addTouchEventListener(_Instance.TableViewItemTouchEvent)
    button:setTag(idx)
    button:setSwallowTouches(false)
    
    local button = seekNodeByName(layout, "Button_2")
    button:addTouchEventListener(_Instance.TableViewItemTouchEvent)
    button:setTag(idx)
    button:setSwallowTouches(false)
    
    layout:setPosition(cc.p(0, 0))
    cell:addChild(layout, 0, idx)
    _Instance:InitCell(cell, idx)
    return cell
end

function UIServerSelect:InitCell(cell, idx)

end

function UIServerSelect:TouchEvent(i, e, eventType)
    if eventType == ccui.TouchEventType.ended then
        self._loginUI:setServer(i);
        self._loginUI = nil;
        self:closeUI();
    end
end
    
return UIServerSelect
