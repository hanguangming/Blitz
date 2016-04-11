-- 文件名称：UIloading.lua
-- 功能描述：资源预加载 
-- 文件说明：资源预加载
-- 作    者：盛绍斌
-- 创建时间：2015-11-26

require "main.UI.UIBase"
require("main.UI.UITypeDefine")
require("main.ServerData.GlobalDataManager")
require("main.GameGlobal")
require("main.UI.UIHelper")

local UILoading = class("UILoading",UIBase)
local UISystem =  GameGlobal:GetUISystem()

function UILoading:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_LoadingUI
    self._ResourceName = "UILoading.csb"  
end

function UILoading:Load()
    UIBase.Load(self)
    self._progressbar = seekNodeByName(self._RootPanelNode, "LoadingBar")
end

function UILoading:Unload()
    UIBase.Unload()
    self._ResourceName = nil
    self.Type = nil
end

function UILoading:Open()
    UIBase.Open(self)
    self._list = {}

    local steps = 0;
    self._count = 0
    for k, v in pairs(GlobalCSB) do
        if not gAllCsbNodeList[v] then
            steps = steps + 1;
        end
    end

    for k, v in pairs(GlobalCSB) do
        if not gAllCsbNodeList[v] then
            self:addStep(
                function()
                    UISystem:preloadUI(k)
                end, 95 / steps);
        end
    end

    self:addStep(
        function()
            GameGlobal:GetGuoZhanServerDataManager():Init()
            GameGlobal:GetCharacterServerDataManager():UpdateSoldier()
            GameGlobal:GetCharacterServerDataManager():UpdateLeader()
        end, 5);
    self._step = 1
    self._progress = 0;
    self._progressbar:setPercent(self._progress)
    idle_run(function() self:load() end);
end

function UILoading:Close()
    UIBase.Close(self)
    self._count = 0
end
 
function UILoading:addStep(func, progress)
    if not self._count then
        self._count = 0
    end
    self._count = self._count + 1;

    local step = {}
    step.handler = func;
    step.progress = progress;
    self._list[self._count] = step;
end

function UILoading:load()
    if not self._step then
    end

    local progress = self._progress;
    while (self._step <= self._count) do
        local step = self._list[self._step]
        self._step = self._step + 1

        step.handler();
        progress = progress + step.progress;
        if (math.floor(progress) - math.floor(self._progress) >= 2) then
            self._progress = progress;
            break;
        end
    end

    if self._step > self._count then
        self._progressbar:setPercent(100)
        idle_run(function() self:finish() end);
    else
        self._progressbar:setPercent(math.floor(self._progress))
        idle_run(function() self:load() end);
    end
end

function UILoading:finish()
    for i = 1, 6 do
        g_customPass[i] = gAllCsbNodeList["customPass".. i ..".csb"];
    end

    require("main.Game.GameMaincity"):Enter();
    self:closeUI();
end

return UILoading