----
-- 文件名称：UICustoMap.lua
-- 功能描述：大关卡界面
-- 文件说明：大关卡界面
-- 作    者：刘胜勇
-- 创建时间：2015-7-13
--  修改

require("main.UI.UIBase")
require("main.UI.UITypeDefine") 

local UISystem = GameGlobal:GetUISystem() 
local UICustomMap = class("UICustomMap", UIBase)

-- 获取本地玩家数据
local GamePlayerDataManager = GameGlobal:GetGamePlayerDataManager()
-- 获取关卡表数据
local CustomDataManager = GameGlobal:GetCustomDataManager()

function UICustomMap:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_CustomMap
    self._ResourceName = "UICustomMap.csb"  
end

-- 加载UI 
function UICustomMap:Load()
    UIBase.Load(self)

    -- 创建地图TableView
    self._gridView = CreateTableView_(-380, -170, 960 * 6, 540 * 2, 0, self)
    self:GetUIByName("Panel_Center"):addChild(self._gridView, 0, 0)
    
    -- 设置滚动条透明度
    seekNodeByName(self._RootPanelNode, "ScrollView_1"):setScrollBarOpacity(0)
    
    -- 关闭按钮
    local closeBtn = seekNodeByName(self._RootPanelNode, "Close") 
    closeBtn:setTag(-1)
    closeBtn:setLocalZOrder(1)

    -- 创建一个展开按钮，用来打开和关闭CustomSelcet与EnmeyInfo，放在最上层
    local zhankai = seekNodeByName(self._RootPanelNode,"Btn_Zhankai")
    local clonez = zhankai:clone()
    clonez:setPosition(cc.p(905,520))
    clonez:setTag(3)
    clonez:setVisible(true)
    UISystem:GetUIRootNode():addChild(clonez,10)
    self._zhankaiBtn = clonez
    zhankai:setVisible(false)
    
    -- 关闭与展开按钮注册触摸监听事件
    closeBtn:addTouchEventListener(handler(self, self.touchEvent))
    clonez:addTouchEventListener(handler(self, self.touchEvent))
    
end

-- UI卸载
function UICustomMap:Unload()
    UIBase.Unload()
end

-- UI打开
function UICustomMap:Open()
    UIBase.Open(self)

    -- 初始化自己的关卡数据
    self._myselfData = GetPlayer()
    
    -- 当前选中地图上的大关卡
    self._mapLevelId = nil
    
    -- 初始化展开按钮状态
    self._isShowInfoAndSelcetUI = false
    
    -- 展开按钮负责打开和关闭CustomSelectUI与CustomEnmeyInfoUI，默认打开
    self._zhankaiBtn:setVisible(true)
    self._zhankaiBtn:loadTextures("meishu/ui/guanqia/UI_gq_shouqi_01.png", "meishu/ui/guanqia/UI_gq_shouqi_02.png", UI_TEX_TYPE_LOCAL)

    -- 加载地图大关卡信息
    self:delayLoadCustom()
    self._gridView:reloadData()
    
    -- 初始化展开按钮层级，放在上层
    self._zhankaiBtn:setLocalZOrder(1)
    
    -- 大关卡选择监听事件
    performWithDelay(self._RootPanelNode, handler(self, self.openCustomSelect), 0)
    
end

-- UI关闭
function UICustomMap:Close()
    UIBase.Close(self)
    removeNodeAndRelease(self._aniNode,true)
    self._mapLevelId = nil
    self._zhankaiBtn:setVisible(false)
    self._Index = 0
end

function UICustomMap:delayLoadCustom()
    for i = 0, 5 do 
        local center = seekNodeByName(self._RootPanelNode, "Panel_Center"..(i + 1))
        if math.floor((self._myselfData._MaxLevel - 1) / 100) < i then
            ccui.Helper:seekWidgetByName(center, "NodePath"):setVisible(false)
        else
            local custom = math.ceil((self._myselfData._MaxLevel - math.floor((self._myselfData._MaxLevel - 1) / 100) * 100) / 10)
            custom = custom > 1 and custom - 1 or custom
            for z = custom, 10 do
                for k = 1, 20 do
                    local point = ccui.Helper:seekWidgetByName(center, "p"..z.."_"..k)
                    if point ~= nil then
                        point:setVisible(false)
                    end
                end
            end
        end
        center:setSwallowTouches(false)
        -- 处理文本和按钮事件
        for j = 1, 10 do
            local panel = seekNodeByName(center, "Text_"..j) 

            if CustomDataManager[i * 100 + j * 10]["levelStage"] == j + i * 10 then
                local str = self:luaStringSplit(CustomDataManager[i * 100 + j * 10]["name"],"-")[1] 
                panel:setString(str)
            end
            if j <= math.ceil((self._myselfData._MaxLevel - i * 100) / 10) then
                local btn = seekNodeByName(center, "Button_"..j) 
                btn:setTag(i * 10 + j)
                btn:setBright(true)
                btn:setTouchEnabled(true)
                btn:addTouchEventListener(handler(self, UICustomMap.onClick))
            else
                local btn = seekNodeByName(center, "Button_"..j)
                btn:setBright(false)
                btn:setTouchEnabled(false)
            end
            
            if self._myselfData._MaxLevel<= 0 then
                self._myselfData._MaxLevel = 1
            end
            if tonumber(GameGlobal:GetCustomDataManager()[GetPlayer()._MaxLevel].levelStage) == j and math.floor((self._myselfData._MaxLevel - 1) / 100) == i then
                panel:getParent():setLocalZOrder(1000)
                self._aniNode = panel:getParent():getChildByTag(99)
                if self._aniNode == nil then
                    self._aniNode = CreateAnimation(panel:getParent(), -490, -240, "csb/texiao/ui/T_u_xiaofangzi.csb", "Walk", false, 1110, 1)
                    self._aniNode:setTag(99)
                    self._aniNode:retain()
                else
                    self._aniNode:setVisible(true)
                    self._aniNode._usedata:gotoFrameAndPause(0)
                    self._aniNode._usedata:play("Walk", false)
                    self._aniNode._usedata:setTimeSpeed(1)
                    self._aniNode:runAction(self._aniNode)
                end
            end
        end
        center:setTag(i + 1)
        local custom = math.floor((self._myselfData._MaxLevel - 1) / 100)
        if custom == i then
            self._gridView._usedata = center
        end
        
    end
    local tag = math.floor((self._myselfData._MaxLevel - 1) / 100) + 1
    local layout = self._gridView._usedata
    local custom = math.ceil((self._myselfData._MaxLevel - math.floor((self._myselfData._MaxLevel - 1) / 100) * 100) / 10)
    for z = custom - 1, custom - 1 do
        for k = 1, 20 do
            local point = ccui.Helper:seekWidgetByName(layout, "p"..z.."_"..k) 
            if point ~= nil then
                point:setVisible(true)
                point:setOpacity(0)
                local actions = {cc.FadeTo:create(0, 0), cc.DelayTime:create(0.1 * k), cc.FadeTo:create(0, 250)}
                point:runAction(transition.sequence(actions))
            end
        end
    end
end

function UICustomMap:TableCellTouched(view, cell)
    local index = cell:getIdx()
end

function UICustomMap:CellSizeForTable(view, idx)
    return 960, 460
end

function UICustomMap:NumberOfCellsInTableView()
    return 6
end

function UICustomMap:TableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
    end
    return cell
end

-- 大关卡监听回调事件，打开每个大关卡对应的选择小关卡UI
function UICustomMap:openCustomSelect()
    UISystem:OpenUI(UIType.UIType_CustomSelect)
    self._isShowInfoAndSelcetUI = true
    self._mapLevelId = GetPlayer()._MaxLevel % 10 == 0 and math.floor(GetPlayer()._MaxLevel / 10) or math.floor(GetPlayer()._MaxLevel / 10) + 1
    performWithDelay(UISystem:GetUIRootNode(), handler(self, self.delayCallBack), 0)
    self._zhankaiBtn:setLocalZOrder(0)
end

-- 大关卡点击回调事件
function UICustomMap:onClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if sender ~= nil then
            local tag = sender:getTag()
            --大关卡标记
            self._mapLevelId = tag
            performWithDelay(UISystem:GetUIRootNode(), handler(self, self.delayCallBack),0)
        end
    end
end

-- 发送选择关卡事件
function UICustomMap:delayCallBack()
    if self._mapLevelId ~= nil then
        DispatchEvent(GameEvent.GameEvent_UICustomSelect_Succeed, self._mapLevelId)
    end
end

-- 触摸监听事件处理
function UICustomMap:touchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
        if tag == -1 then
            UISystem:CloseUI(UIType.UIType_CustomMap)
            UISystem:CloseUI(UIType.UIType_CustomSelect)
            UISystem:CloseUI(UIType.UIType_CustomEnmeyInfo)
            UISystem:OpenUI(UIType.UIType_MaincityUI)
        elseif tag == 3 then
            -- 点击展开按钮，按钮图片切换
            if not self._isShowInfoAndSelcetUI then
                self._isShowInfoAndSelcetUI  = true
                self._zhankaiBtn:loadTextures("meishu/ui/guanqia/UI_gq_shouqi_01.png", "meishu/ui/guanqia/UI_gq_shouqi_02.png", UI_TEX_TYPE_LOCAL)
                UISystem:OpenUI(UIType.UIType_CustomSelect)
                UISystem:OpenUI(UIType.UIType_CustomEnmeyInfo) 
                self._zhankaiBtn:setLocalZOrder(0)
            else
                self._isShowInfoAndSelcetUI  = false
                self._zhankaiBtn:loadTextures("meishu/ui/guanqia/UI_gq_zhankai_01.png", "meishu/ui/guanqia/UI_gq_zhankai_02.png", UI_TEX_TYPE_LOCAL)
                UISystem:CloseUI(UIType.UIType_CustomSelect)
                UISystem:CloseUI(UIType.UIType_CustomEnmeyInfo)
                self._zhankaiBtn:setLocalZOrder(1)
            end
            performWithDelay(UISystem:GetUIRootNode(), handler(self, self.delayCallBack), 0)
        end
    end
end


-- 参数:待分割的字符串,分割字符
-- 返回:子串表.(含有空串)
function UICustomMap:luaStringSplit(str, split_char)
    local sub_str_tab = {};
    while (true) do
        local pos = string.find(str, split_char);
        if (not pos) then
            sub_str_tab[#sub_str_tab + 1] = str;
            break
        end
        local sub_str = string.sub(str, 1, pos - 1);
        sub_str_tab[#sub_str_tab + 1] = sub_str;
        str = string.sub(str, pos + 1, #str);
    end

    return sub_str_tab;
end

return UICustomMap