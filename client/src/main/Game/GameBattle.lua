----
-- 文件名称：GameBatle.lua
-- 功能描述：游戏流程状态：战斗状态  唯一实例
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-4-21
--  修改：
--  

require("main.DataPool.TableDataManager")
require("main.DataPool.DataConstDefine")
require("main.GameEvent.GameEvent")
require("main.ServerData.CharacterServerDataManager")
require("main.Logic.GameLevel")
local NetSystem = require("main.NetSystem.NetSystem")
local GuoZhanMapPlayerManager = require("main.Logic.GuoZhanMapPlayerManager")
local GameBattle = class("GameBattle")
local UISystem =  GameGlobal:GetUISystem()
--构造
function GameBattle:ctor()
    --根scene
    self._RootScene = nil
    --当前关卡
    self._CurrentNewLevel = nil
    --是否固定逻辑帧
    self._IsFixLogic = false
    --固定战斗逻辑帧率(20帧)      --改变战斗逻辑帧率，保持一个固定的逻辑帧，使得客户端同服务器的逻辑帧一致
    self._FixLogicFrame = 0.05
    --
    self._CurrentDeltaTime = 0
end

--进入
function GameBattle:Enter(param)
    local levelTableID = nil
    if param ~= nil then
        levelTableID = param.levelTableID
    end
--    local director = cc.Director:getInstance()
--    local currentScene = director:getRunningScene()
--    local newScene = display.newScene()
--    display.runScene(newScene)
--    self._RootScene = newScene
--    self._RootScene:retain()
    
    --创建战斗关卡
    if levelTableID == nil then
        levelTableID = 20
    end
    if levelTableID == -2 then
        local GameLevelPVP = require("main.Logic.GameLevelPVP")
        self._CurrentNewLevel = GameLevelPVP.Create(levelTableID, true)
        self._CurrentNewLevel:Init()
    elseif levelTableID == -1 then
        local GameLevelPVP = require("main.Logic.GameLevelPVP")
        self._CurrentNewLevel = GameLevelPVP.Create(levelTableID, true)
        self._CurrentNewLevel:Init()
    else
        self._CurrentNewLevel = GameLevel.Create(levelTableID)
        self._CurrentNewLevel:Init()
    end

    local rootLevelNode = self._CurrentNewLevel:GetRootNode()
    self._RootScene:addChild(rootLevelNode)
    self._CurrentNewLevel:FixLevelPosition()
    --dump(newScene, "GameBattle running scene ")
    --加载UI
    UISystem:CloseUI(UIType.UIType_LoginUI)
    UISystem:CloseUI(UIType.UIType_MaincityUI)
    UISystem:OpenUI(UIType.UIType_BattleUI)
    local uiRootNode = UISystem:GetUIRootNode()
    if uiRootNode ~= nil then  
        uiRootNode:removeFromParent(false)
        self._RootScene:addChild(uiRootNode)
    end
    UISystem:SetVisible(UIType.UIType_BottomList, false)
end

--离开
function GameBattle:Leave()
    
    UISystem:SetVisible(UIType.UIType_BottomList, true)
    UISystem:CloseUI(UIType.UIType_BattleUI)
    if self._CurrentNewLevel ~= nil then
        self._CurrentNewLevel:Destroy()
        self._CurrentNewLevel = nil
    end
    if self._RootScene ~= nil then
        self._RootScene:removeAllChildren()
        self._RootScene:release()
        self._RootScene = nil
    end
    local GuoZhanServerDataManager = GameGlobal:GetGuoZhanServerDataManager()
    GuoZhanServerDataManager._GuoZhanAttackerPlayerInfoList = {}
    GuoZhanServerDataManager._GuoZhanDefenderPlayerInfoList = {}
    --display.removeUnusedSpriteFrames()
    --collectgarbage("collect")
end

--根节点
function GameBattle:GetRootScene()
    return self._RootScene
end
--游戏关卡
function GameBattle:GetGameLevel()
    return self._CurrentNewLevel
end

--设置固定逻辑帧
function GameBattle:SetFixedLogicFrame(isFixed)
    self._IsFixLogic = isFixed
end
--更新 
function GameBattle:Update(deltaTime)
    deltaTime = 0.033
    if self._IsFixLogic == true then
        if self._CurrentNewLevel ~= nil then
            self._CurrentNewLevel:Update(deltaTime)
        end
    else
        if self._CurrentNewLevel ~= nil then
            self._CurrentNewLevel:Update(deltaTime)
        end
    end
    if GuoZhanMapPlayerManager ~= nil then
        GuoZhanMapPlayerManager:Update(deltaTime)
    end
    if NetSystem ~= nil then
        NetSystem:Update(deltaTime)
    end
end
local newGameBattle = GameBattle.new()
return newGameBattle
