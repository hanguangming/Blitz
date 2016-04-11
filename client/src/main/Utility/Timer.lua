
-- 文件名称：Timer.lua
-- 功能描述：游戏中的定时器
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-6-24
--  修改：

local Timer = class("Timer")

--构造
function Timer:ctor()
    --计时Timer
    self._TickTime = 0
    --回调函数
    self._CallBack = 0
    --时间间隔
    self._IntervalTime = 0
    --是否开启
    self._IsEnable = false
    --回调参数
    self._CallBackData = nil
    self._ID = -1
end

--帧更新
function Timer:Update(deltaTime)
    if self._IsEnable == false then
        return
    end
    self._TickTime = self._TickTime - deltaTime
    if self._TickTime <= 0 then
        if self._CallBack ~= nil then
            self._CallBack(self._obj, self._ID)
        end
        self._TickTime = self._IntervalTime
    end
end
--开启
function Timer:SetEnable(isEnable)
    self._IsEnable = isEnable
end

local TimerManager = class("TimerManager")

--构造
function TimerManager:ctor()
    --所有定时器
    self._AllTimerTable = {}
    --当前ID
    self._CurrentTimerID = 0
end

--创建定时器 (interval:间隔时间  callBack:回调函数)
function TimerManager:AddTimer(interval, callBack, obj)
    if callBack == nil then
        return
    end
    if type(callBack) ~= "function" then
        return
    end
    self._CurrentTimerID = self._CurrentTimerID + 1
    local newTimer = Timer.new()
    newTimer._TickTime = interval
    newTimer._IntervalTime = interval
    newTimer._CallBack = callBack
    newTimer._obj = obj
    newTimer._ID = self._CurrentTimerID
    self._AllTimerTable[self._CurrentTimerID] = newTimer
    newTimer:SetEnable(true)
    return self._CurrentTimerID
end
--移除Timer
function TimerManager:RemoveTimer(id)
   self._AllTimerTable[id] = nil
end
--帧更新
function TimerManager:Update(deltaTime)
    for k, v in pairs(self._AllTimerTable)do
        v:Update(deltaTime)
    end
end

local globalTimerManager = TimerManager:new()
return globalTimerManager