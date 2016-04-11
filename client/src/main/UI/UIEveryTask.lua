----
-- 文件名称：UIEveryTask.lua
-- 功能描述：
-- 文件说明：每日任务
-- 作       者：秦宝
-- 创建时间：2015-11-05
-- 修改

require("cocos.ui.DeprecatedUIEnum")
require("cocos.extension.ExtensionConstants")
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
require("src.cocos.ui.GuiConstants")
local UISystem =  GameGlobal:GetUISystem()

local B_STATE_CLOSE = -1

local IMAGE_TASK_BG = "meishu/ui/richangrenwu/UI_rcrw_renwukuang_02.png"

local EVERY_TASK_COUNT = 8

local UIEveryTask = class("UIEveryTask", UIBase)

function UIEveryTask:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_EveryTask
    self._ResourceName = "UIEveryTask.csb"
    --每个任务名称
    self._TaskNameList = nil
    --每个任务获得的活跃度
    self._TaskHuoYueList = nil
    --每个任务进度（如：1/3）
    self._TaskProgressList = nil
    --每个任务的前往按钮
    self._TaskButtonList = nil
    --每个任务已完成图片
    self._TaskAchieveImageList = nil
    --每个任务背景图片的获取
    self._TaskBgImageList = nil
    --箱子按钮
    self._BoxButtonList = nil
    --可开始箱子的背景发光图片
    self._BoxOKBgImageList = nil
end

function UIEveryTask:Load()
    UIBase.Load(self)
    self._TaskNameList = {}
    self._TaskHuoYueList = {}
    self._TaskProgressList = {}
    self._TaskButtonList = {}
    self._TaskAchieveImageList = {}
    self._TaskBgImageList = {}
    self._BoxButtonList = {}
    self._BoxOKBgImageList = {}
    --关闭
    local closeButton = self:GetWigetByName("Button_Close")
    if closeButton ~= nil then
        closeButton:setTag(B_STATE_CLOSE)
        closeButton:addTouchEventListener(self.TouchEvent)
    end
    --8个任务的各种UI的获取
    for i = 1, EVERY_TASK_COUNT do
        local task = self:GetWigetByName("Task_"..i)
        --任务描述（名称）
        self._TaskNameList[i] = seekNodeByName(task, "taskdes")
        --每个任务活跃度
        self._TaskHuoYueList[i] = seekNodeByName(task, "taskreward")
        --进度（1/3）
        self._TaskProgressList[i] = seekNodeByName(task, "taskpro")
        --前往按钮
        self._TaskButtonList[i] = seekNodeByName(task, "Button_Go")
        --"已完成"图片
        self._TaskAchieveImageList[i] = seekNodeByName(task, "Flag")
        --每个任务背景图片
        self._TaskBgImageList[i] = task
    end
    --今日活跃度数值
    self._HuoYueValue = self:GetWigetByName("Text_HuoYueValue")
    --5个箱子按钮的获取
    for i = 1, 5 do
        self._BoxButtonList[i] = self:GetWigetByName("Button_"..i)
    end
    --进度条的获取
    local progressLoading = self:GetWigetByName("Load_bg")
    self._ProgressLoading = seekNodeByName(progressLoading, "LoadingBar_1")
    --箱子可领取时的背景光图片的获取（默认隐藏）
    for i = 1, 5 do
        self._BoxOKBgImageList[i] = seekNodeByName(progressLoading, "Image_"..i)
    end
end

--箱子状态
function UIEveryTask:BoxStateShow(index)
    --1可领取  2已领取  3不可领取
    if index == 1 then
        --可领取光显示
        self._BoxOKBgImageList[i]:setVisible(true)
    elseif index == 2 then
        --加载箱子已打开状态
        self._BoxButtonList[index]:loadTextures(string.format("meishu/ui/liaotian/UI_gg_baoxiang0%d_03.png", index), UI_TEX_TYPE_LOCAL)
    elseif index == 3 then
    end
end

--任务标记完成时调用
function UIEveryTask:TaskAchieveState(index)
    --背景图片换成深色
    self._TaskBgImageList[index]:loadTexture(IMAGE_TASK_BG)
    --前往按钮隐藏
    self._TaskButtonList[index]:setVisible(false)
    --任务进度隐藏
    self._TaskProgressList[index]:setVisible(false)
    --"已完成"图片显示
    self._TaskAchieveImageList[index]:setVisible(true)
    --任务描述（名称）颜色及描边变化
    self._TaskNameList[index]:setTextColor(cc.c4b(204, 195, 188, 255))
    self._TaskNameList[index]:enableOutline(cc.c4b(84, 56, 34, 250), 1)
    --每个任务活跃度颜色变化
    self._TaskHuoYueList[index]:setTextColor(cc.c4b(193, 180, 171, 255))
end

function UIEveryTask:Open()
    UIBase.Open(self)
end

function UIEveryTask:Unload()
    UIBase:Unload()
    for i = 1, EVERY_TASK_COUNT do
        self._TaskNameList[i] = nil
        self._TaskHuoYueList[i] = nil
        self._TaskProgressList[i] = nil
        self._TaskButtonList[i] = nil
        self._TaskAchieveImageList[i] = nil
        self._TaskBgImageList[i] = nil
    end
    for i = 1, 5 do
        self._BoxButtonList[i] = nil
        self._BoxOKBgImageList[i] = nil
    end
end

function UIEveryTask:Close()
    UIBase.Close(self)
end

function UIEveryTask.TouchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
        if tag == B_STATE_CLOSE then
            UISystem:CloseUI(UIType.UIType_EveryTask)
        end 
    end
end

return UIEveryTask