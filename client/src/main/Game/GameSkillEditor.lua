----
-- 文件名称：GameSkillEditor.lua
-- 功能描述：游戏流程状态：技能编辑器
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-6-26
--  修改：
--  


require("main.DataPool.TableDataManager")
require("main.DataPool.DataConstDefine")
require("main.GameEvent.GameEvent")
require("main.ServerData.CharacterServerDataManager")
require("main.Logic.GameLevel")
local NetSystem = require("main.NetSystem.NetSystem")
local SkillManager = require("main.Logic.SkillManager")
local GameSkillEditor = class("GameBattle")
local UISystem = require("main.UI.UISystem")
--构造
function GameSkillEditor:ctor()
    --根scene
    self._RootScene = nil
    --当前关卡
    self._CurrentNewLevel = nil
end

--进入
function GameSkillEditor:Enter()

    print("GameBattle enter...")
    local director = cc.Director:getInstance()
    local currentScene = director:getRunningScene()
    local newScene = display.newScene()
    display.runScene(newScene)
    self._RootScene = newScene
    self._RootScene:retain()

    --创建战斗关卡
    self._CurrentNewLevel = GameLevel.Create(1)
    self._CurrentNewLevel:Init()
    self._CurrentNewLevel._Finished = true
    local rootLevelNode = self._CurrentNewLevel:GetRootNode()
    self._RootScene:addChild(rootLevelNode)
    printf("scene childCount = %d", newScene:getChildrenCount())
    --dump(newScene, "GameBattle running scene ")
    --加载UI
    UISystem:CloseUI(UIType.UIType_LoginUI)
    UISystem:CloseUI(UIType.UIType_MaincityUI)
    UISystem:OpenUI(UIType.UIType_SkillEditor)
   
    local uiRootNode = UISystem:GetUIRootNode()
    if uiRootNode ~= nil then  
        uiRootNode:removeFromParent(false)
        self._RootScene:addChild(uiRootNode)
    end
end

--离开
function GameSkillEditor:Leave()
    if self._RootScene ~= nil then
        self._RootScene:release()
        self._RootScene = nil
    end
    if self._CurrentNewLevel ~= nil then
        self._CurrentNewLevel:Destroy()
        self._CurrentNewLevel = nil
    end
    UISystem:CloseUI(UIType.UIType_SkillEditor)
    print("GameBattle leave...")

end

--根节点
function GameSkillEditor:GetRootScene()
    return self._RootScene
end
--游戏关卡
function GameSkillEditor:GetGameLevel()
    return self._CurrentNewLevel
end

--更新
function GameSkillEditor:Update(deltaTime)
    if self._CurrentNewLevel ~= nil then
        self._CurrentNewLevel:Update(deltaTime)
        SkillManager:Update(deltaTime)
    end
    if NetSystem ~= nil then
       -- NetSystem:Update(deltaTime)
    end
end

local newGameBattle = GameSkillEditor.new()
return newGameBattle