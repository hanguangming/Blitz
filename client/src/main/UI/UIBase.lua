 
-- 文件名称：UIBase
-- 功能描述：UI基类，
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-4-21
--  修改：
-- 根结点下挂Panel,Tag:1

--Load接口：初始化本UI需要操作的控件变量，不做其它逻辑
--Unload接口：将UI控件变量赋nil
--Open(): UI显示时的内容初始化 UI事件的注册
--Close(): UI事件移除 ，其它逻辑

require("main.UI.UIHelper")
require("main.UI.UITipConst")
require("main.UI.SoundConst")
require("cocos.ui.DeprecatedUIEnum")
require("cocos.extension.ExtensionConstants")
require("cocos.framework.extends.UIWidget") 
local UISystem = require("main.UI.UISystem")

FONT_SIMHEI = "fonts/SIMHEI.TTF"
FONT_JINZHUANG = "fonts/jinzhuang.TTF"
FONT_HUALANG = "fonts/huakang.TTC"
FONT_FZLTTHJW = "fonts/FZLTTHJW.TTF"
FONT_MSYH = "fonts/msyh.ttf"

BASE_FONT_SIZE = 16
BASE_FONT_SIZE_MIN = 14
BASE_FONT_SIZE_MID = 20

BASE_FONT_INCOLOR = cc.c3b(252, 242, 209)
BASE_FONT_OUTCOLOR = cc.c4b(95, 63, 25, 250)
UIBase = class("UIBase", Widget)
--UIcsb 目录
local resourcePrefix = "csb/ui/"  
local ANI_PATH = "csb/texiao/ui/"
local ccDirector = cc.Director:getInstance()
local mathAbs = math.abs
local mathMin = math.min
local mathMax = math.max

--构造
function UIBase:ctor()
    self._Type = 0
    self._ResourceName = ""
    self._RealResourceName = "" 
    self._RootUINode = nil
    self._RootPanelNode = nil
    self._ParentType = nil
    --边角的node
    self._Panel_Center = nil
    self._openState = false
end

--------------------------------------------------所有UI必须实现的四个接口，且必须放在最前面  begin -------------------------------------------------------
--加载
function UIBase:Load()
    --cc.Director:getInstance():setDepthTest(true)
    if self._RootUINode == nil then
        local realResourceName = resourcePrefix .. self._ResourceName
        self._RealResourceName = realResourceName
        --从存储csb数组中获取
        self._RootUINode = gAllCsbNodeList[self._ResourceName]
      --  self._RootUINode = cc.CSLoader:createNode(realResourceName) --ccs.GUIReader:getInstance():widgetFromBinaryFile(realResourceName)
        self._RootUINode:retain()
        self._RootPanelNode = self._RootUINode:getChildByTag(1)
    end

    --如果目前的适配方案是 FIXED_HEIGHT,修正位置
    if CC_DESIGN_RESOLUTION.autoscale == "FIXED_WIDTH" then
        self._RootUINode:setPositionY((cc.Director:getInstance():getWinSizeInPixels().height - 540) / 2)
        local leftBottomPanel = self:GetUIByName("Panel_LeftBottom")
        local rightBottomPanel = self:GetUIByName("Panel_RightBottom")
        local centerPanel = self:GetUIByName("Panel_Center")
        local leftTopPanel = self:GetUIByName("Panel_LeftTop")
        local rightTopPanel = self:GetUIByName("Panel_RightTop")
        local topCenterPanel = self:GetUIByName("Panel_TopCenter")
        self._Panel_Center = centerPanel

--        local scaleSize = CC_DESIGN_RESOLUTION.height / display.sizeInPixels.height
--        local rate = display.sizeInPixels.width / display.sizeInPixels.height
--        if rate >=   1.7 then
--            scaleSize = 1
--        else
--            scaleSize = mathMin(scaleSize, 1)
--            scaleSize = mathMax(scaleSize, 0.6)
--            print("UIBase scaleSize ", scaleSize)
--        end
--
--        --print("scaleSize ", scaleSize)
--        if leftBottomPanel ~= nil then
--            leftBottomPanel:setPosition(display.left_bottom)
--            leftBottomPanel:setScale(scaleSize)
--        end
--        if rightBottomPanel ~= nil then
--            rightBottomPanel:setPosition(display.right_bottom)
--            rightBottomPanel:setScale(scaleSize)
--        end
--        if centerPanel ~= nil then
--            centerPanel:setPosition(display.center)
--            centerPanel:setScale(scaleSize)
--        end
--        if leftTopPanel ~= nil then
--            leftTopPanel:setPosition(display.left_top)
--            leftTopPanel:setScale(scaleSize)
--        end
--        if rightTopPanel ~= nil then
--            rightTopPanel:setPosition(display.right_top)
--            rightTopPanel:setScale(scaleSize)
--        end
--        if topCenterPanel ~= nil then
--            topCenterPanel:setPosition(display.top_center)
--            topCenterPanel:setScale(scaleSize)
--        end
    end

end

--卸载
--覆盖方法一定要释放自定义的所有node，这已经是资源清理的最后一步了，以后再也没机会了！！！
function UIBase:Unload()
    self:Close()

    if self._RootUINode ~= nil then
        self._RootUINode:release()
        self._RootUINode = nil
    end

    self._Type = 0
    self._ResourceName = ""
    self._RealResourceName = "" 
    self._RootUINode = nil
    self._RootPanelNode = nil
    self._ParentType = nil
    --边角的node
    self._Panel_Center = nil
end

--打开UI

function UIBase:Open()
    PlaySound(Sound_20)
    self._openState = true
end

--关闭UI

function UIBase:Close()
    PlaySound(Sound_21)
    self._openState = false 
    if self._events then
        for k, v in pairs(self._events) do
            if v then
                RemoveEvent(v);
            end
        end
    end
end

--------------------------------------------------所有UI必须实现的四个接口，且必须放在最前面  end -------------------------------------------------------

function UIBase.GetResourcePath()
    return resourcePrefix
end

function UIBase:FindNode(name)
    if self._RootPanelNode == nil then
        print("UIBase:GetUIByName _RootPanelNode nil")
    end
    --return ccui.Helper:seekWidgetByName(self._RootPanelNode, name)
    --由于上面这行代码查找Node找不到，暂时改成下面的代码
    return seekNodeByName(self._RootPanelNode, name)
end

--这个接口后面会改动，获取接口勿必走下面这个,除非个别情况
function UIBase:GetUIByName(name)
    if self._RootPanelNode == nil then
        print("UIBase:GetUIByName _RootPanelNode nil")
    end
    --return ccui.Helper:seekWidgetByName(self._RootPanelNode, name)
    --由于上面这行代码查找Node找不到，暂时改成下面的代码
    return seekNodeByName(self._RootPanelNode, name)
end

function UIBase:GetWigetByName(name)
    if self._RootPanelNode == nil then
        print("UIBase:GetUIByName _RootPanelNode nil")
    end
    return ccui.Helper:seekWidgetByName(self._RootPanelNode, name)
end

--这个接口
function UIBase:GetUINodeByName(name)
    print("name:",name)
    if self._RootPanelNode == nil then
        print("UIBase:GetUIByName _RootPanelNode nil")
    end
    return seekNodeByName(self._RootPanelNode, name)
        --return seekNodeByName(self._RootUINode, name)
end

function UIBase:addChild(node, index, tag)
    self._RootPanelNode:addChild(node, index, tag)
end

function UIBase:removeChild(node)
    self._RootPanelNode:removeChild(node);
end

--获取根结点
function UIBase:GetUIRootNode()
    return self._RootUINode
end

function UIBase:closeUI()
    UISystem:CloseUI(self._Type)
end

function UIBase:addEvent(eventName, listener)
    if not eventName or not listener then
        print("UIBase:addEvent(", eventName, listener, ")")
    end

    if not self._events then
        self._events = {}
    end

    if self._events[eventName] then
        RemoveEvent(self._events[eventName])
    end
    self._events[eventName] = AddEvent(eventName, function(...) listener(self, ...) end)
end 

function UIBase:RemoveEvent(eventName)
    if self._events[eventName] then
        RemoveEvent(self._events[eventName])
        self._events[eventName] = nil;
    end
end