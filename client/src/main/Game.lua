----
-- 文件名称：Game.lua
-- 功能描述：兵来将挡游戏逻辑入口
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-4-21
--  修改：

require("main.UI.UITypeDefine")
require("main.UI.ResourceCsb")
require("main.UI.UIBase")
require("main.GameGlobal")

local resourcePrefix = "csb/ui/"
local UISystem = GameGlobal:GetUISystem();

--游戏主流程控制
local Game = class("Game")
--
function Game:ctor()
    self._scene = display.newScene();
    display.runScene(self._scene);
    self._scene:addChild(UISystem:GetUIRootNode());

    UISystem:preloadUI("UILoginGame");
    UISystem:preloadUI("UILoading");
    UISystem:preloadUI("UIServerList");
    UISystem:preloadUI("UICountry");

    UISystem:OpenUI(UIType.UIType_LoginUI);
end

local newGame = Game.new()
--帧更新

--调试帧率
local isEnableProfile = false
local profileLabel = nil
local stringFormat = string.format
testTime = os.clock()
lastTestTime = nil
useTime = 0
local director = cc.Director:getInstance()
local winSize = director:getWinSizeInPixels()
local TimerManager = GameGlobal:GetTimerManager()
--是否在UI显示内存信息
local isEnableMemory = false

local DELTA_TIME = 30

director:setAnimationInterval(1 / DELTA_TIME)

local function Update(deltaTime)
    --deltaTime = DELTA_TIME
    local currentTime = os.clock()
    --newGame._scene:Update(deltaTime)
    TimerManager:Update(deltaTime)
    useTime = os.clock() - currentTime
    local frameTime = 0
    if lastTestTime ~= nil then
        frameTime =  currentTime - lastTestTime
       -- print("frameTime ", frameTime, "logic useTime", useTime)
    end
    lastTestTime = currentTime
    if isEnableProfile == true then
        if profileLabel == nil then
            profileLabel = cc.Label:createWithTTF("test", "fonts/arial.ttf", 20)
            profileLabel:retain()
            profileLabel:setPosition(cc.p(winSize.width/2, winSize.height / 3))
        end
        local currentScene = director:getRunningScene()
        if currentScene ~= nil then
            local labelParent = profileLabel:getParent()
            if labelParent == nil then
                currentScene:addChild(profileLabel)
            end
            local pfofileInfo = stringFormat("frame:%.03f lua:%.03f", frameTime, useTime)
            profileLabel:setString(pfofileInfo)
        end
    end
end

--显示调试的内存信息
local stringFind = string.find
local testMemoryLabel = nil
function UpdateDebugMemoryInfo(deltaTime)
    --print("UpdateDebugMemoryInfo ")
    --C++中的接口 getSystemInfo
    if getSystemInfo ~= nil then
        local showInfo = "test"
        local systemInfo = getSystemInfo()
        print("UpdateDebugMemoryInfo ", systemInfo)
        if systemInfo ~= nil then
            showInfo = systemInfo
            systemInfo = string.gsub(systemInfo, "\r", "")
            local infoList = Split(systemInfo, "\n")
            if infoList ~= nil then
                showInfo = ""
                for k, v in pairs(infoList)do
                    print("loop ", k, v)
                    local startPos,_ = stringFind(v, "Vm")
                    if startPos ~= nil then
                        print("new showInfo", showInfo)
                        showInfo = showInfo .. v .. "\t"
                    end
                end
            end
        end

        if testMemoryLabel == nil then
            testMemoryLabel = cc.Label:createWithTTF("test", "fonts/arial.ttf", 20)
            testMemoryLabel:retain()
            testMemoryLabel:setAnchorPoint(cc.p(0,0))
            testMemoryLabel:setPosition(cc.p(0, 200))
            testMemoryLabel:setDimensions(960, 300)
        end
        local currentScene = director:getRunningScene()
        if currentScene ~= nil then
            local labelParent = testMemoryLabel:getParent()
            if labelParent == nil then
                currentScene:addChild(testMemoryLabel)
            end
            if showInfo ~= nil then
                testMemoryLabel:setString(showInfo)
            end
        end
   end
end

local sharedScheduler = cc.Director:getInstance():getScheduler()
sharedScheduler:scheduleScriptFunc(Update, 0, false)
if isEnableMemory == true then
    sharedScheduler:scheduleScriptFunc(UpdateDebugMemoryInfo, 2, false)
end

--给txt转换工具使用的全局接口
function ConvertTxtToLuaScript()
   local TableDataManager = GameGlobal:GetDataTableManager()
   TableDataManager:ConvertTxtToLuaScript()
end

return newGame