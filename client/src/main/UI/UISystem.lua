----
-- 文件名称：UISystem
-- 功能描述：UI的管理类，加载UI与卸载UI
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-4-21
--  修改：
--  TODO: 管理所有UI的Zorder，是否卸载资源,在表格中配置
-- 
-- 

require("main.UI.UIHelper")
require("main.UI.UITypeDefine")
local UISystem = class("UISystem")
local stringFormat = string.format
local resourcePrefix = "csb/ui/"

function UISystem:ctor()
    self._UITable = {}
    self._UIRootNode = cc.Node:create()
    local drawNode = cc.DrawNode:create() 
    self._UIRootNode:addChild(drawNode, 10000)
    local off = (cc.Director:getInstance():getWinSizeInPixels().height - 540) / 2
    drawNode:drawSolidRect(cc.p(0, off), cc.p(960, -off), cc.c4f(0.17,0.7,0.8,1))
    drawNode:drawSolidRect(cc.p(0, 540 + off), cc.p(960, 540 + 2 * off), cc.c4f(0.17,0.7,0.8,1))
    self._UIRootNode:retain()
    self._PreUIType = nil
    local layer = display.newLayer(cc.c3b(0,0,0)) 
    layer:setOpacity(100)
    layer:setTouchEnabled(true) 
end

function UISystem:preloadUI(resName)
    local csbName = GlobalCSB[resName];
    if not gAllCsbNodeList[csbName] then
        print(csbName)
        gAllCsbNodeList[csbName] = cc.CSLoader:createNode(resourcePrefix .. csbName);
        gAllCsbNodeList[csbName]:retain();
    end
end

--加载
function UISystem:LoadUI(uiType)
    if self._UITable[uiType] == nil then
        local scriptPath = stringFormat("main.UI.%s", UIScriptData[uiType])
        local NewUI = require(scriptPath)
        local newUIInstance = NewUI.new()
        newUIInstance:Load()
        self._UITable[uiType] = newUIInstance
        --add
        self._UIRootNode:addChild(newUIInstance:GetUIRootNode())
    end
end

function UISystem:LoadUIList(list)
    if not list._index then
        list._index = 1;
    end

    if not list[list._index] then
        return;
    end

    self:LoadUI(list[list._index]);
    list._index = list._index + 1;
    return true;
end

--卸载
function UISystem:UnloadUI(uiType)
    local newInstance = self._UITable[uiType]
    if newInstance ~= nil then
        self._PreUIType = newInstance._ParentType
        --[[
        local currentUIRootNode = newInstance:GetUIRootNode()
        if currentUIRootNode ~= nil then
            currentUIRootNode:removeFromParent(true)
        end
       newInstance:Unload()
       ]]--
       --modify by leileiw 
       newInstance:Unload()
       local currentUIRootNode = newInstance:GetUIRootNode()
       if currentUIRootNode ~= nil then
            currentUIRootNode:removeFromParent(true)
            currentUIRootNode:removeAllChildren(true)
       end
       self._UITable[uiType] = nil
    end
end

--打开
function UISystem:OpenUI(uiType, ...)
    local currentUI = self._UITable[uiType]
    if currentUI == nil then
        self:LoadUI(uiType)
    end
    
    currentUI = self._UITable[uiType]
    print(currentUI._openState)
    if currentUI._openState then
        return self._UITable[uiType]
    end
    currentUI:Open(...)
    print(currentUI._openState)
    --节点挂接
    local currentUIRootNode = currentUI:GetUIRootNode()
    if currentUIRootNode ~= nil then
        currentUIRootNode:removeFromParent(false)
        self._UIRootNode:addChild(currentUIRootNode)
    end
    
    if self._PreUIType ~= nil then
        self._UITable[uiType]._ParentType = self._PreUIType
    end
    
    self._PreUIType = uiType

    return self._UITable[uiType]
end

--关闭
function UISystem:CloseUI(uiType)
    local currentUI = self._UITable[uiType]
    if currentUI ~= nil then
        currentUI:Close()
        self._PreUIType = currentUI._ParentType
        local currentUIRootNode = currentUI:GetUIRootNode()
        currentUIRootNode:removeFromParent(false)
    end
end
--进入战斗关闭所有UI
function UISystem:CloseAllUI()
    for i, v in pairs(self._UITable) do
        if v._PreUIType ~= UIType.UIType_BattleUI then
            local currentUI = v
            if currentUI ~= nil then
                currentUI:Close()
                self._PreUIType = currentUI._ParentType
                local currentUIRootNode = currentUI:GetUIRootNode()
                currentUIRootNode:removeFromParent(false)
            end
        end
    end
end

--获取UI根
function UISystem:GetUIRootNode()
    return self._UIRootNode
end

--获取UI
function UISystem:GetUIInstance(uiType)
    return self._UITable[uiType]
end

function UISystem:SetVisible(uiType, hide)
    self._UITable[uiType]:GetUIRootNode():setVisible(hide)
end

function UISystem:IsForefront(type)
    return self._PreUIType == type
end

local UISystemInstance = UISystem.new()

return UISystemInstance