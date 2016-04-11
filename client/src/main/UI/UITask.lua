----
-- 文件名称：UITask.lua
-- 功能描述：测试UI
-- 文件说明：
-- 作    者：田凯
-- 创建时间：2015-7-27
-- 修改 ：
--
--
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
local UISystem = require("main.UI.UISystem")
local TaskDataManager = GameGlobal:GetTaskDataManager()
local RewardDataManager = GameGlobal:GetCustomRewardDataManager()
local UITask = class("UITask", UIBase)

-- 构造函数
function UITask:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_Task
    self._ResourceName =  "UITask.csb"
end

-- Load
function UITask:Load()
    UIBase.Load(self)
    self._RewardIcon = {}
    self._RewardData = {}
    local center = seekNodeByName(self._RootPanelNode, "Panel_Center")
    self._GridView = CreateTableView_(-295, -120, 270, 375, 1, self)
    self._Slider = self:GetUIByName("Slider_1")
    center:addChild(self._GridView)
    self._TaskDesc = seekNodeByName(center, "Text_des1")
    self._TaskDesc:setFontSize(BASE_FONT_SIZE)
    for i = 1, 5 do 
        self._RewardIcon[i] = seekNodeByName(self:GetUIByName("Reward"..i), "icon")
        self._RewardData[i] = seekNodeByName(self:GetUIByName("Reward"..i), "Text_1")
    end
    self._Rect2 = seekNodeByName(center, "Rect_1")
    self._FinishBtn = self:GetUIByName("FinishBtn")
    self._FinishBtn:setTag(1)
    self._FinishBtn:addTouchEventListener(handler(self, self.touchEvent))
    self._CurTaskIndex = 0
    local close = self:GetUIByName("Close")
    close:setTag(-1)
    close:addTouchEventListener(handler(self, self.touchEvent))
end

-- 打开
function UITask:Open()
    UIBase.Open(self)
    self:openUISucessed()
    self:addEvent(GameEvent.GameEvent_UITask_Succeed, self.taskSucessed)
    self:addEvent(GameEvent.GameEvent_UITaskUpdate_Succeed, self.openUISucessed)
end

-- 关闭
function UITask:Close()
    UIBase.Close(self)
end

function UITask:Unload()
    UIBase.Unload(self)
end

function UITask:simulateClickButton(idx)
    local cell = self._GridView:cellAtIndex(idx)
    if cell ~= nil then
        if idx == 0 then
            local button = seekNodeByName(cell, "Button_2")
            button:loadTextures("meishu/ui/renwu/UI_rw_renwukuanglashen_03.png", UI_TEX_TYPE_LOCAL)
        end
        self:changeTask(idx)
    end
end

function UITask:taskSucessed()
    playAnimationObject(self._RootPanelNode, 2, 480, 260, "animation0")
end

function UITask:openUISucessed()
    self._TaskList = GetGlobalData()._TaskData 
    table.sort(self._TaskList, function(a, b)
        if a[2] == b[2] then
            if a[1] == b[1] then
                return false
            else
                return a[1] < b[1]
            end
        else
            return a[2] > b[2]
        end

    end)
    self._CurTaskIndex = 0
    self._GridView:reloadData()
    self:simulateClickButton(self._CurTaskIndex)
end

function UITask:changeTask(index)
    local id = self._TaskList[index + 1][1]
    self._Rect2:removeAllChildren(true)
    if id ~= 0 then
        local rid = RewardDataManager[TaskDataManager[id]["rewardid"]]
        local prop = GetPropDataManager()
        for i = 1, 5 do
            self._RewardIcon[i]:getParent():loadTexture("meishu/ui/gg/UI_gg_zhuangbeikuang_02.png")
            self._RewardIcon[i]:loadTexture("meishu/ui/gg/null.png")
            self._RewardData[i]:setString("")
        end
        for i = 1, #rid - 1 do
            self._RewardIcon[i]:getParent():loadTexture("meishu/ui/gg/UI_gg_zhuangbeikuang_01.png")
            self._RewardIcon[i]:loadTexture(GetPropPath(rid[i + 1]["p1"]))
            if tonumber(rid[i + 1]["p1"]) >= 25001 and tonumber(rid[i + 1]["p1"]) <= 25065 then
                self._RewardData[i]:setPositionX(58)
                self._RewardData[i]:setString("LV"..rid[i + 1]["l1"])
            else
                self._RewardData[i]:setString(rid[i + 1]["l1"])
            end
        end
        self._TaskDesc:setString(TaskDataManager[id]["desc"])
        if self._TaskList[index + 1][2] == 2 then
            self._FinishBtn:setVisible(true)
            playAnimationObject(self._FinishBtn, 3, 60 ,21, "animation0", true)
        else
            self._FinishBtn:setVisible(false)
        end
        local num = 0
        for s in string.gfind(TaskDataManager[id]["desc2"], "(.-</p>)") do
            local v,_ = string.gsub(s, '(</p>)', "")
            local v,_ = string.gsub(v, '(<P>)', "")
            local label = cc.Label:createWithTTF("", FONT_MSYH, BASE_FONT_SIZE)
            label:setPosition(0, - num * 25)-- -40
            label:setAnchorPoint(0, 1)
            v = string.gsub(v, '({0})', math.max(TaskDataManager[id]["taskvalue"] - 1000 - GetPlayer()._MaxLevel + 1, 0))
            local _, e = string.find(v, '<red>')
            local s, _ = string.find(v, '</red>')
            local label1 = cc.Label:createWithTTF(string.sub(v, e + 1, s - 1), FONT_MSYH, 1)
            local size1 = label1:getStringLength()
            local label2 = cc.Label:createWithTTF(string.sub(v, 0, e), FONT_MSYH, 1)
            local size2 = label2:getStringLength()
            local start = size2 - 6
            local v1,_ = string.gsub(v, '(</red>)', "")
            local v1,_ = string.gsub(v1, '(<red>)', "")
            
            label:setString(v1)
            label:setTextColor(cc.c3b(144,54,1))
            for i = 1, size1, 1 do
                local letter = label:getLetter(tonumber(start + i))
                letter:setColor(cc.c3b(255,0,0))
                letter:setScale(1.1)
                letter:setPositionY(letter:getPositionY()+1)
            end
            
            label:setString(v1)
            self._Rect2:addChild(label)
            num = num + 1
        end
    end
end

function UITask:NumberOfCellsInTableView()
    if self._TaskList == nil then
        return  0
    end
    return #self._TaskList
end

function UITask:TableCellTouched(view, cell)    
    local index = cell:getIdx()
    self._CurTaskIndex = index
    
    if index ~= 0 then
        local firstCell = self._GridView:cellAtIndex(0)
        local button = seekNodeByName(firstCell, "Button_2")
        button:loadTextures("meishu/ui/renwu/UI_rw_renwukuanglashen_01.png", UI_TEX_TYPE_LOCAL)
    end
    
    if self._preCell then
        local button = seekNodeByName(self._preCell, "Button_2")
        button:loadTextures("meishu/ui/renwu/UI_rw_renwukuanglashen_01.png", UI_TEX_TYPE_LOCAL)
    end
    
    local button = seekNodeByName(cell, "Button_2")
    button:loadTextures("meishu/ui/renwu/UI_rw_renwukuanglashen_03.png", UI_TEX_TYPE_LOCAL)
    self:changeTask(index)
    self._preCell = cell
end

function UITask:CellSizeForTable(view, idx)
    return 135, 56
end

function UITask:TableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
    end
    cell:removeAllChildren(true)
    local layout 
    if self._TaskList[idx + 1][1] ~= 0 then
        if TaskDataManager[self._TaskList[idx + 1][1]]["type"] == 2 then
            layout = cc.CSLoader:createNode("csb/ui/taskItem1.csb")
        else
            layout = cc.CSLoader:createNode("csb/ui/taskItem1.csb")
        end
        layout:setPositionY(-5)
        cell:addChild(layout, 0, idx)
    end
    self:initCell(cell, idx)
    return cell
end

function UITask:initCell(cell, idx)
    local layout = cell:getChildByTag(idx)
    local panel = seekNodeByName(layout, "Button_2")
    panel:addTouchEventListener(handler(self, self.tableViewItemTouchEvent))
    panel:setSwallowTouches(false)
    seekNodeByName(panel, "flag2"):setVisible(false)
    if self._TaskList[idx + 1][1] ~= 0 then
        seekNodeByName(panel, "Text_1"):setString(TaskDataManager[self._TaskList[idx + 1][1]]["name"])
        if tonumber(TaskDataManager[self._TaskList[idx + 1][1]]["type"]) == 2 then
            seekNodeByName(panel, "flag1"):setString("【主】")
        else
            seekNodeByName(panel, "flag1"):setString("【支】")
        end
        if self._TaskList[idx + 1][2] == 2 then
            seekNodeByName(panel, "flag2"):setVisible(true)
            local cellNode = CreateAnimation(panel,113,24,"csb/texiao/ui/T_u_RW_jiemian.csb","animation0", true, 0, 1)
            cellNode:setScaleX(0.93)
        end
    end
end

function UITask:tableViewItemTouchEvent(value)
    local eventType = value
    if type(value) == "table" then
        eventType = value.eventType
    end
    if eventType == ccui.TouchEventType.ended then
    end
end

function UITask:touchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if sender:getTag() == -1 then
            UISystem:CloseUI(UIType.UIType_Task)
        elseif sender:getTag() == 1 then
            local id = self._TaskList[self._CurTaskIndex + 1][1]
            SendMsg(PacketDefine.PacketDefine_TaskFinish_Send, {id})
        end
    end
end

return UITask
