----
-- 文件名称：UICustomSelect.lua
-- 功能描述：关卡选择界面
-- 文件说明：关卡选择界面控制
-- 作    者：刘胜勇
-- 创建时间：2015-7-15
-- 
--  修改

require("main.UI.UIBase")
require("main.UI.UITypeDefine") 

local UISystem = GameGlobal:GetUISystem() 
local UICustomSelcet = class("UICustomSelect.lua", UIBase)

local GamePlayerDataManager = GameGlobal:GetGamePlayerDataManager()
local CustomDataManager = GameGlobal:GetCustomDataManager()

-- 所有关卡的容器
local PANEL_NAMELIST = 
    {
        --小关卡1容器
        [1] = "Panel_10",
        --小关卡2容器
        [2] = "Panel_11",
        --小关卡3容器
        [3]= "Panel_12",
        --小关卡4容器
        [4] = "Panel_13",
        --小关卡5容器
        [5] = "Panel_14",
        --小关卡6容器
        [6] = "Panel_15",
        --小关卡7容器
        [7] = "Panel_16",
        --小关卡8容器
        [8] = "Panel_17",
        --小关卡9容器
        [9] = "Panel_18",
        --小关卡10容器
        [10] = "Panel_19",
    }

function UICustomSelcet:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_CustomSelect
    self._ResourceName = "UICustomSelect.csb"  
end

-- 加载UI 
function UICustomSelcet:Load()
    UIBase.Load(self)
    
    -- 标记关卡的位置三角与大关卡名字资源加载
    self._loadingArrow = self:GetWigetByName("Image_arrow")
    self._levelName = self:GetWigetByName("Level_Name")
    
end

-- 卸载UI
function UICustomSelcet:Unload()
    UIBase.Unload()
end

-- UI打开
function UICustomSelcet:Open()
    UIBase.Open(self)

    -- 大关卡数据
    self._mapLevelData = {}
    -- 初始化大关卡
    self._mapLevelId = nil
    -- 得到每个小关卡的位置(x, y坐标),方便三角Sprite的定位
    self._panelPosList = {}
    -- 初始化小关卡
    self._littleLevelId = nil
    
    -- 选中框
    self._selectFrame = display.newSprite("meishu/ui/guanqia/UI_gq_xuanzhongkuang.png", 30, 30)
    self._selectFrame:retain()

    -- 注册大关卡选择监听事件
    self:addEvent(GameEvent.GameEvent_UICustomSelect_Succeed,self.selectSuccessListener)
    
end

-- UI关闭
function UICustomSelcet:Close()
    UIBase.Close(self)
    
    self._mapLevelData = nil
    self._mapLevelId = nil
    self._panelPosList = nil
    self._littleLevelId = nil
    removeNodeAndRelease(self._selectFrame,true)
end

-- 小关卡选择监听事件回调
function UICustomSelcet:selectSuccessListener(event)
    -- 表示通过的大关卡,得到其中小关卡的数据
    self._mapLevelId = event._usedata
    self._mapLevelData = GameGlobal:GetTypeCustomDataManager(self._mapLevelId)
    -- 显示信息
    self:controlShow()
    -- 打开对应的CustomEnmeyInfoUI
    self:openCustomEnmeyInfo()
end

function UICustomSelcet:openCustomEnmeyInfo()

    -- 关掉上次打开的CustomEnmeyInfoUI
    UISystem:CloseUI(UIType.UIType_CustomEnmeyInfo)
    
    -- 打开所选中的CustomEnmeyInfoUI
    local tmp = GetPlayer()._MaxLevel - self._mapLevelData[1]["index"] + 1 
    if tmp > 10 then   
        tmp = 10
    end
    if tmp % 10 == 0 then
        self._littleLevelId = self._mapLevelId * 10
    else
        self._littleLevelId = GetPlayer()._MaxLevel
    end
    UISystem:OpenUI(UIType.UIType_CustomEnmeyInfo)
    
    performWithDelay(UISystem:GetUIRootNode(), handler(self, self.delayCallBack), 0)
end

-- 控制UI显示及事件的添加
function UICustomSelcet:controlShow()
    local player = GetPlayer()
    if self._mapLevelData == nil then
        return
    end
    for i = 1, 10 do
        local layout = seekNodeByName(self._RootPanelNode, PANEL_NAMELIST[i])
        if self._mapLevelData[i]["index"] < player._MaxLevel then
--            -- 目前尚无评星系统，临时都显示3星
--            for j = 1,3 do
--                local star = seekNodeByName(layout, "star"..j)
--                star:setVisible(true)
--            end
        else 
            for j = 1, 3 do
                local star = seekNodeByName(layout, "star"..j)
                star:setVisible(false)
            end
        end

        -- 将所有小关卡的坐标存到panelPosList中
        local panelPos = {}
        panelPos.x = layout:getPositionX()
        panelPos.y = layout:getPositionY()
        self._panelPosList[i] = panelPos

        local levelBtn = seekNodeByName(layout, "bgBtn") 

        if self._mapLevelData[i]["index"] < player._MaxLevel then --通过的小关卡底框图片改变(深色框)
            levelBtn:setBright(true)
            levelBtn:setTag(self._mapLevelData[i]["index"])
            levelBtn:setTouchEnabled(true)
            levelBtn:addTouchEventListener(handler(self, self.touchEvent))
            levelBtn:loadTextures("meishu/ui/guanqia/UI_gq_guanqia01_01.png", "meishu/ui/guanqia/UI_gq_guanqia01_02.png", UI_TEX_TYPE_LOCAL)
        elseif self._mapLevelData[i]["index"] == player._MaxLevel then
            levelBtn:setBright(true)
            levelBtn:setTag(self._mapLevelData[i]["index"])
            levelBtn:setTouchEnabled(true)
            levelBtn:addTouchEventListener(handler(self, self.touchEvent))
            levelBtn:loadTextures("meishu/ui/guanqia/UI_gq_guanqia01_01.png", "meishu/ui/guanqia/UI_gq_guanqia01_02.png", UI_TEX_TYPE_LOCAL)
        else
            levelBtn:setTouchEnabled(false)
            levelBtn:loadTextures("meishu/ui/guanqia/UI_gq_guanqia02_01.png", "meishu/ui/guanqia/UI_gq_guanqia02_02.png", UI_TEX_TYPE_LOCAL)
        end

    end
    
    local tmp = player._MaxLevel - self._mapLevelData[1]["index"] + 1 --标记关卡位置

    if tmp > 10 then   
        tmp = 10
    end

    -- 标记三角位置，停留在将要打的关卡,返回已通关的大关卡时，停留在最后一关
    self._loadingArrow:setPosition(cc.p(self._panelPosList[tmp].x + 30, self._panelPosList[tmp].y))

    self._levelName:setString(self._mapLevelData[tmp]["name"])
    self._levelName:setColor(cc.c3b(115, 74, 18))
    
    if self._selectFrame ~= nil then
        self._selectFrame:removeFromParent()
    end
    
    local layout = seekNodeByName(self._RootPanelNode, PANEL_NAMELIST[tmp])
    local levelBtn = seekNodeByName(layout, "bgBtn")
    levelBtn:addChild(self._selectFrame)
    
end

-- 触摸监听事件回调
function UICustomSelcet:touchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
        if tag == -1 then
            UISystem:CloseUI(UIType.UIType_CustomSelect)
        else 
            -- 关掉上次打开的CustomEnmeyInfoUI
            UISystem:CloseUI(UIType.UIType_CustomEnmeyInfo)
            self._littleLevelId = tag
            GetPlayer()._CurCustom = self._littleLevelId
            self._selectFrame:removeFromParent()
            sender:addChild(self._selectFrame)
            -- 打开当前CustomEnmeyInfoUI
            UISystem:OpenUI(UIType.UIType_CustomEnmeyInfo)
            performWithDelay(UISystem:GetUIRootNode(), handler(self, self.delayCallBack), 0)
        end
    end
end

-- 发送查看小关卡信息事件
function UICustomSelcet:delayCallBack()
    if self._littleLevelId ~= nil then
        DispatchEvent(GameEvent.GameEvent_UICustomEnmeyInfo_Succeed, self._littleLevelId)
    end
end

return UICustomSelcet