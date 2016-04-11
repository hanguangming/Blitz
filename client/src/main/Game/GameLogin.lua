----
-- 文件名称：GameLogin.lua
-- 功能描述：游戏流程状态： 登录逻辑   唯一实例
-- 文件说明：登录scene
-- 作    者：王雷雷
-- 创建时间：2015-6-10
--  修改：
--  


local GameLogin = class("GameLogin")
local UISystem =  GameGlobal:GetUISystem()
local NetSystem = require("main.NetSystem.NetSystem")
--构造
function GameLogin:ctor()
    --根scene
    self._RootScene = nil
    --
    
end

--必须实现的 overwrite
function GameLogin:Enter()
    local newScene = display.newScene()
    display.runScene(newScene)
    self._RootScene = newScene
    self._RootScene:retain()
    
    local uiRootNode = UISystem:GetUIRootNode()
    if uiRootNode ~= nil then  
        uiRootNode:removeFromParent(false)
        self._RootScene:addChild(uiRootNode)
    end
    UISystem:OpenUI(UIType.UIType_LoginUI)
    --测试
    --require("main.UI.UIBase")
    --UISystem:OpenUI(UIType.UIType_WorldMapEditor)
end

--必须实现的 overwrite
function GameLogin:Leave()
    if self._RootScene ~= nil then
        self._RootScene:release()
        self._RootScene = nil
    end
end

--必须实现的 overwrite
function GameLogin:Update(deltaTime)
    NetSystem:Update(deltaTime)
end

--必须实现的 overwrite
function GameLogin:GetRootScene()
    return self._RootScene
end
local newGameLogin = GameLogin.new()
return newGameLogin
