----
-- 文件名称：GameBatle.lua
-- 功能描述：游戏流程状态：游戏主城
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-6-17
--  修改：
--  

local NetSystem = require("main.NetSystem.NetSystem")
local GameMaincity = class("GameMaincity")
local UISystem =  GameGlobal:GetUISystem()
local GuoZhanMapPlayerManager = require("main.Logic.GuoZhanMapPlayerManager")
--构造
function GameMaincity:ctor()
    --根scene
    self._RootScene = nil
end

--必须实现的 overwrite
function GameMaincity:Enter()
    local newScene = display.newScene()
    display.runScene(newScene)
    self._RootScene = newScene
    self._RootScene:retain()

    local uiRootNode = UISystem:GetUIRootNode()
    if uiRootNode ~= nil then  
        uiRootNode:removeFromParent(false)
        self._RootScene:addChild(uiRootNode, 0)
    end
    UISystem:CloseUI(UIType.UIType_LoginUI)
    UISystem:OpenUI(UIType.UIType_MaincityUI)
    performWithDelay(self._RootScene, self.initNpc, 0)
end

function GameMaincity:initNpc()
    DispatchEvent(GameEvent.GameEvent_MainCity_Notify, "")
end

--必须实现的 overwrite
function GameMaincity:Leave()
    UISystem:CloseUI(UIType.UIType_MaincityUI)
    if self._RootScene ~= nil then
        self._RootScene:removeAllChildren()
        self._RootScene:release()
        self._RootScene = nil
    end
    --display.removeUnusedSpriteFrames()
end

--必须实现的 overwrite
function GameMaincity:Update(deltaTime)
    if GuoZhanMapPlayerManager ~= nil then
        GuoZhanMapPlayerManager:Update(deltaTime)
    end
    NetSystem:Update(deltaTime)
end

--必须实现的 overwrite
function GameMaincity:GetRootScene()
    return self._RootScene
end
local newGameMaincity = GameMaincity.new()
return newGameMaincity
