----
-- 文件名称：GameLoadingBattle.lua
-- 功能描述：游戏流程状态：战斗Loading
-- 文件说明：战斗前的预加载资源
-- 作    者：王雷雷
-- 创建时间：2015-9-2
--  修改：
--  


local GameLoadingBattle = class("GameLoadingBattle")
local UISystem =  GameGlobal:GetUISystem()

--
local LoadState = 
{
    --默认
    LoadState_None = 0,
    --计算Loading资源列表
    LoadState_Calc = 1,
    --Loading每个资源
    LoadState_Loading = 2,
}

--构造
function GameLoadingBattle:ctor()
    --根scene
    self._RootScene = nil
    --战斗类型
    self._CurrentLoadingBattleType = 0
    --要加载的资源列表
    self._CurrentLoadingResourceList = nil
    --当前状态
    self._CurrentState = LoadState.LoadState_None
end

--必须实现的 overwrite
function GameLoadingBattle:Enter()
    local newScene = display.newScene()
    display.runScene(newScene)
    self._RootScene = newScene
    self._RootScene:retain()

    local uiRootNode = UISystem:GetUIRootNode()
    if uiRootNode ~= nil then  
        uiRootNode:removeFromParent(false)
        self._RootScene:addChild(uiRootNode)
    end
    
    --分析当前关卡所需加载的资源
    
end

--必须实现的 overwrite
function GameLoadingBattle:Leave()
    if self._RootScene ~= nil then
        self._RootScene:release()
        self._RootScene = nil
    end
end

--必须实现的 overwrite
function GameLoadingBattle:Update(deltaTime)
    
end

--必须实现的 overwrite
function GameLoadingBattle:GetRootScene()
    return self._RootScene
end

local newGameLoadingBattle = GameLoadingBattle.new()
return newGameLoadingBattle
