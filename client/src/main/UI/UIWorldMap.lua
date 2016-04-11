----
-- 文件名称：UIWorldMap.lua
-- 功能描述：世界地图
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-8-12
-- 修改 ：
--
--
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
local scheduler = require("cocos.framework.scheduler")

local TableDataManager = GameGlobal:GetDataTableManager()
local WorldMapTableDataManager = TableDataManager:GetWorldMapTableDataManager()
local CharacterServerDataManager = require("main.ServerData.CharacterServerDataManager")
local GuoZhanServerDataManager = GameGlobal:GetGuoZhanServerDataManager()
local GuoZhanMapPlayerManager = require("main.Logic.GuoZhanMapPlayerManager")
local UISystem = require("main.UI.UISystem")

local charMgr = TableDataManager:GetCharacterDataManager()
local sqrt = math.sqrt
local worldMap = require("main.worldmap")
local UIWorldMap = class("UIWorldMap", UIBase)
local stringFormat = string.format

function UIWorldMap:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_WorldMap
    self._ResourceName = "UIWorldMap.csb"
end

function UIWorldMap:Load()
    UIBase.Load(self)
     -- init data
     self._buildButtonList = {}
     self._mapBtn = {}
     
     self._touchPanel = self:FindNode("Panel_TouchPanel")
     self._closeLayout = cc.CSLoader:createNode("csb/ui/UIWorldMapTip.csb")
     self._closeLayout:setVisible(false)
     self._closeLayout:retain()
     self._buildLayout = cc.CSLoader:createNode("csb/ui/UIMapBuildInfo.csb")
     self._buildLayout:retain()
     self._closePanel = seekNodeByName(self._closeLayout, "Panel_JuDianTanChu")
     self._buildInfo = seekNodeByName(self._buildLayout, "Panel_1")
     self._showContent = ccui.Helper:seekWidgetByName(self._buildInfo, "Text_ShowContent")
     self._buildName = ccui.Helper:seekWidgetByName(self._buildInfo, "Text_JuDianName")
     self._warPanel = ccui.Helper:seekWidgetByName(self._buildInfo, "Panel_war")
     self._closePanel:addTouchEventListener(handler(self, self.TouchEvent))
     self._closePanel:setTag(-1)
     
     -- 前往 观站 攻击按钮，按钮的位置及处理的逻辑随城池不同而不同
     
     local panel = self._buildInfo
     for i = 1, 6 do
         local buttonName = stringFormat("Button_%d", i)
         self._buildButtonList[i] = panel:getChildByName(buttonName)
         self._buildButtonList[i]:setTag(i)
         self._buildButtonList[i]:addTouchEventListener(handler(self, self.TouchBuildEvent))
     end
    
    self._PanelLeftCenter = self:GetUIByName("Panel_LeftCenter")
    self._SoldierCountLabel = seekNodeByName(self._PanelLeftCenter, "Text_1")
    self._MuBingLingLabel = seekNodeByName(self._PanelLeftCenter, "Text_1_1")
    self._headIcon = seekNodeByName(self._PanelLeftCenter, "head")
    self._headIcon:setTag(7)
    self._headIcon:addTouchEventListener(handler(self, self.TouchEvent))
    self._mapBtn[0] = self:GetWigetByName("Zhenxin")
    self._mapBtn[1] = self:GetWigetByName("Zhenxin_1")
    self._mapBtn[2] = self:GetWigetByName("Zhenxin_2")
    self._mapBtn[3] = self:GetWigetByName("Zhenxin_3")
    self._mapBtn[4] = self:GetWigetByName("Button_add")
    self._mapBtn[5] = self:GetWigetByName("Button_feats")
    self._mapBtn[6] = self:GetWigetByName("Button_HuiCheng")
    for i = 0 , 6 do
        self._mapBtn[i]:setTag(i)
        self._mapBtn[i]:addTouchEventListener(handler(self, self.TouchEvent))
    end
    self._mapBtn[0]:setSwallowTouches(true)
end

function UIWorldMap:Open()
    UIBase.Open(self)
    -- init data
    self._players = {}
    self._cities = {}
    self._move_list = {}
    self._move_list.next = self._move_list
    self._move_list.prev = self._move_list
    --self._timer = scheduler.scheduleGlobal(function() self:update() end, 0.1)
    
    self:createMap()
    self:createCities()
    self:addPlayer(gUid, GetPlayer()._HeadId, gcity, 10000, true)
    
    local characterData = charMgr[GetPlayer()._HeadId]
    -- GetWarriorHeadPath(characterData.headName)
    self._headIcon:loadTextures(GetWarriorHeadPath(5495), GetWarriorHeadPath(5495))
    
    self:moveMapToSelf()
    self:updateMapDataListener()
    
    -- add event
    self:addEvent(GameEvent.GameEvent_GuoZhan_UpdateMap, self.updateMapDataListener)
    self:addEvent(GameEvent.GameEvent_UIMap_Move, self.handlerMoveListener)
    self:addEvent(GameEvent.GameEvent_UIMap_Move_City, self.moveToCityListener)
    self:addEvent(GameEvent.GameEvent_UIMap_Add_Player, self.updatePlayerListener)
    
end

function UIWorldMap:Close()
    UIBase.Close(self)
    --scheduler.unscheduleGlobal(self._timer)
    self._touchPanel:removeAllChildren(true)
    self._players = nil
    self._cities = nil
    self._move_list = nil
    self._timer = nil
end

function UIWorldMap:Unload()
    UIBase.Unload(self)
    self._buildButtonList = nil
    self._mapBtn = nil
    self._SoldierCountLabel = nil
    self._MuBingLingLabel = nil
    self._headIcon = nil
    removeNodeAndRelease(self._buildLayout, true)
    removeNodeAndRelease(self._closeLayout, true)
end

function UIWorldMap:createMap()
    self._mapLayer = cc.Layer:create();
    self._mapLayer:onTouch(function(...) self:onTouchMap(...) end, false, true);

    for k, v in ipairs(worldMap._blocks) do
        local node = cc.Sprite:createWithTexture(v.image.texture);
        node:setAnchorPoint(cc.p(0, 0));
        node:setPosition(cc.p(v.x, v.y));
        self._mapLayer:addChild(node);
    end 
    
    self._mapLayer:addChild(self._closeLayout)
    
    self._pathLayer1 = cc.Node:create()
    self._mapLayer:addChild(self._pathLayer1)
    
    self._pathLayer = cc.Node:create()
    self._mapLayer:addChild(self._pathLayer)
    
    self._cityLayer = cc.Node:create();
    self._mapLayer:addChild(self._cityLayer)

    self._sideLayer = {}
    for i = 1, 6 do
        self._sideLayer[i] = cc.Node:create();
        self._mapLayer:addChild(self._sideLayer[i])
    end

    self._nameLayer = cc.Node:create();
    self._mapLayer:addChild(self._nameLayer)

    self._stateLayer = cc.Node:create();
    self._mapLayer:addChild(self._stateLayer)

    self._moveLayer = cc.Node:create()
    self._mapLayer:addChild(self._moveLayer)

    self._touchPanel:setScrollBarEnabled(false)
    self._touchPanel:addChild(self._mapLayer);
end

function UIWorldMap:createCities()
    for _, image in ipairs(worldMap._images) do
        if image.city_count and image.city_count > 0 then
            for _, city in ipairs(image.cities) do 
                local obj = {}
                local node = cc.Sprite:createWithTexture(image.texture);
                node:setAnchorPoint(cc.p(0.5, 0.5));
                node:setPosition(cc.p(city.ix, city.iy));
                self._cityLayer:addChild(node);

                obj.nameLabel = cc.Label:createWithTTF(city.name, "fonts/msyh.ttf", 14);
                obj.nameLabel:setAnchorPoint(cc.p(0.5, 0.5));
                obj.nameLabel:setPosition(cc.p(city.nx, city.ny));
                obj.nameLabel:enableOutline(cc.c4b(0, 0, 0, 250), 1)
                obj.nameLabel:setColor(cc.c4b(255, 255, 255, 255));
                self._nameLayer:addChild(obj.nameLabel);

                obj.stateNode = cc.Sprite:createWithTexture(worldMap._cityStateTexture)
                obj.stateNode:setAnchorPoint(cc.p(0.5, 0.5));
                obj.stateNode:setPosition(cc.p(city.sx, city.sy));
                self._stateLayer:addChild(obj.stateNode)
                obj.stateNode:setVisible(false)
                obj.state = false;
                obj.base = city
                obj.side = 0
                obj.id = city.id
                self._cities[city.id] = obj
                if GetGlobalData()._BuidId[city.id] == nil then
                    self:updateCitySide(city.id, city.side)
                else
                    self:updateCitySide(city.id, GetGlobalData()._BuidId[city.id][2] + 1)
                    self:updateCityState(city.id, GetGlobalData()._BuidId[city.id][3])
                end
            end
        end
    end
end

function UIWorldMap:updateCitySide(city, side)
    city = self._cities[city];
    if city.side == side then
        return
    end
    city.side = side;

    if city.sideNode then
        city.sideNode:removeFromParent()
    end
    city.sideNode = cc.Sprite:createWithTexture(worldMap._sideTexture[side])
    city.sideNode:setAnchorPoint(cc.p(0.5, 0.5));
    city.sideNode:setPosition(cc.p(city.base.bx, city.base.by));
    self._sideLayer[side]:addChild(city.sideNode);
    
-- end

function UIWorldMap:updateCityState(city, state)
    city = self._cities[city];

    if city.state == state then
        return
    end
    
    city.state = state;
    
    if state == 1 then
        city.stateNode:setVisible(true)
    else
        city.stateNode:setVisible(false)
    end
end

function UIWorldMap:updateCityInfo(city)
    if self._buildLayout:getParent() then
        self._buildLayout:removeFromParent()
    end
    self._buildLayout:setAnchorPoint(0.5, 0.5)
    self._buildLayout:setPosition(city.base.ix, city.base.iy)
    self._moveLayer:addChild(self._buildLayout, 100)
    self._buildName:setString(city.base.name)
    if city.state == 1 then
        self._showContent:setVisible(false)
        self._warPanel:setVisible(true)
        for i = 1, 6 do
            if i == 2 or i == 1 then
                self._buildButtonList[i]:setVisible(true)
            else
                self._buildButtonList[i]:setVisible(false)
            end
        end
    else
        self._showContent:setVisible(true)
        self._warPanel:setVisible(false)
        for i = 1, 6 do
            if i == 3 then
                if city.side - 1 == g_CountryID then
                    self._buildButtonList[i]:getTitleRenderer():setString("前往")
                else
                    self._buildButtonList[i]:getTitleRenderer():setString("攻击")
                end
                self._buildButtonList[i]:setVisible(true)
            else
                self._buildButtonList[i]:setVisible(false)
            end
        end
    end
end

function UIWorldMap:initMoveInfo(info, from, to)
    info.from = from
    info.to = to
    info.tx = from.x
    info.ty = from.y
    info.path = info.from.joins[info.to.id].path
    info.path_index = 0
    info.last = nil
    info.distance = 0

    local x = from.x
    local y = from.y
-- end

    local i = 1
    while (info.path[i]) do
        local pt = info.path[i]
        local dx = pt.x - x
        local dy = pt.y - y
        local len = sqrt(dx * dx + dy * dy)
        info.distance = info.distance + len
        x = pt.x
        y = pt.y
        i = i + 1
    end

    local dx = to.x - x
    local dy = to.y - y
    local len = sqrt(dx * dx + dy * dy)
    info.distance = info.distance + len

    return self:initNextLine(info)
end

function UIWorldMap:initNextLine(info)
    if info.last then
        return
    end
    info.path_index = info.path_index + 1
    local tx, ty
    if not info.path[info.path_index] then
        tx = info.to.x
        ty = info.to.y
        info.last = true
    else
        local pt = info.path[info.path_index]
        tx = pt.x
        ty = pt.y
    end
    self:initLine(info, info.tx, info.ty, tx, ty)
    return true
end

function UIWorldMap:initLine(info, from_x, from_y, to_x, to_y)
    info.x = from_x
    info.y = from_y
    info.tx = to_x
    info.ty = to_y

    local dx = to_x - from_x
    local dy = to_y - from_y
    local len = sqrt(dx * dx + dy * dy)
    info.len = len
    info.dx = dx / len
    info.dy = dy / len
    info.pos = 0

function UIWorldMap:moveNext(info, size)
    while (size > 0) do
        local len = info.len - info.pos
        if len >= size then
            info.pos = info.pos + size
            return info.x + info.dx * info.pos, info.y + info.dy * info.pos
        end
        size = size - len
        if not self:initNextLine(info) then
            break
        end
    end
end

function UIWorldMap:removePlayer(id)
    local player = self._players[id]
    if not player then
        return
    end

    if player.node then
        player.node:removeFromParent(true)
    end

    self._players[id] = nil
end

function UIWorldMap:addPlayer(id, resid, city, speed, is_self)
    local player = self._players[id]
    if player then
        self:removePlayer(id)
    end
    city = self._cities[city]
    player = {}
    player._move_list = {}
    player._move_list.next = player._move_list
    player._move_list.prev = player._move_list
    
    player.resid = resid
    player.id = id
    player.city = city
    player.speed = speed / 100
    player.dir = true
    self._players[id] = player

    if is_self then
        self._player = player
    end

    local characterData = charMgr[resid]
    if characterData ~= nil then
        player.node = cc.CSLoader:createNode(GetWarriorCsbPath(characterData.resName))
        player.action = cc.CSLoader:createTimeline(GetWarriorCsbPath(characterData.resName))
        player.action:play("Walk", true)
        player.node:runAction(player.action)
        player.node:setPosition(cc.p(city.base.x, city.base.y))
        if is_self then
            self._moveLayer:addChild(player.node)
        end
        schedule(player.node, handlers(self, self.update, id), 0.1)
    end
end

function UIWorldMap:installAllPathDisplay(to)
    if self._player.city.id == to then
        return
    end
    
    if self._player.display then
        for i = self._player.path_index + 1, #self._player.display do 
            for j = 1, # self._player.display[i].display do  
                self._player.display[i].display[j].node:removeFromParent()
            end
            self._player.display[i].display = {}
        end
    end
    local path = worldMap:getPath(self._player.city.id, to)
    local step_size = 30
    local base = self._player.city.base
    self._pathLayer1:removeAllChildren()
    local display_index = 0
    for _, next_city in ipairs(path.cities) do
        local info = {}
        info.display = {}
        self:initMoveInfo(info, base, next_city)
        local pos = 0
        local index = 0
        while (true) do
            local x, y = self:moveNext(info, step_size)
            if not x then
                break
            end
            local node = cc.Sprite:createWithTexture(worldMap._pathTexture)
            node:setAnchorPoint(cc.p(0.5, 0.5));
            node:setPosition(cc.p(x, y));
            self._pathLayer1:addChild(node);
            pos = pos + step_size
            index = index + 1
            local dp = {}
            dp.pos = pos
            dp.node = node
        end
        display_index = display_index + 1
        base = next_city
    end
end

function UIWorldMap:installPathDisplay(to)
    if self._player.city.id == to then
        return
    end
    local path = worldMap:getPath(self._player.city.id, to)
    local step_size = 30
    local base = self._player.city.base
    self._pathLayer:removeAllChildren()
    self._pathLayer1:removeAllChildren()
    self._player.display = {}
    local display_index = 0
    for _, next_city in ipairs(path.cities) do
        local info = {}
        info.display = {}
        self:initMoveInfo(info, base, next_city)
        
        local pos = 0
        local index = 0
        while (true) do
            local x, y = self:moveNext(info, step_size)
            if not x then
                break
            end
            local node = cc.Sprite:createWithTexture(worldMap._pathTexture)
            node:setAnchorPoint(cc.p(0.5, 0.5));
            node:setPosition(cc.p(x, y));
            self._pathLayer:addChild(node);
            pos = pos + step_size
            index = index + 1
            local dp = {}
            dp.pos = pos
            dp.node = node
            info.display[index] = dp
        end
        display_index = display_index + 1
        self._player.display[display_index] = info
        base = next_city
    end
end

function UIWorldMap:moveTo(id, to)
    local player = self._players[id]
    if not player then
        return
    end
    if player.city.id == to then
        return
    end
    local path = worldMap:getPath(player.city.id, to)
    
    player.path = {}
    player.path_index = 1
    local path_index = 0

    local base = player.city.base
    for _, next_city in ipairs(path.cities) do
        local info = {}
        self:initMoveInfo(info, base, next_city)
        path_index = path_index + 1
        player.path[path_index] = info
        base = next_city
    end
    self:moveStart(id)
end

function UIWorldMap:moveStart(id)
    local player = self._players[id]
    if not player then
        return
    end

    player.pos = 0

    if player.next then
        return
    end

    local path = player.path[1]
    if not path then
        return
    end
    info.path_index = info.path_index + 1
    local tx, ty
    if not info.path[info.path_index] then
        tx = info.to.x
        ty = info.to.y
        info.last = true
    else
        local pt = info.path[info.path_index]
        tx = pt.x
        ty = pt.y
    end
    self:initLine(info, info.tx, info.ty, tx, ty)
    return true
end

    player.step = path.distance / player.speed
    player.next = player._move_list.next;
    player.prev = player._move_list
    player._move_list.next.prev = player;
    player._move_list.next = player;

    if player ~= self._player then
        self._moveLayer:addChild(player.node)
    end
end

function UIWorldMap:moveStop(id)
    local player = self._players[id]
    if not player then
        return
    end
    if not player.next then
        return
    end
    player.next.prev = player.prev
    player.prev.next = player.next
    player.prev = nil
    player.next = nil
    if player ~= self._player then
        self:removePlayer(id)
    end
end

function UIWorldMap:update(node, id)
    if not self._players[id] then
        return
    end
    
    local list = self._players[id]._move_list;
    local player = list.next
    local tmp
    while (player ~= list) do
        tmp = player.next
        local path = player.path[player.path_index]
        if path then
            if player.city.base ~= path.to then
                player.city = self._cities[path.to.id]
            end
            local step = path.distance / player.speed
            local x, y = self:moveNext(path, step)
            if x then
                player.pos = player.pos + step
                if player.display then
                    local info = player.display[1]
                    if info then
                        while (true) do
                            local display = info.display[1]
                            if not display then
                                break;
                            end
                            if player.pos < display.pos then
                                break;
                            end
                            display.node:removeFromParent()
                            table.remove(info.display, 1)
                        end
                    end
                end
                local dir = path.dx >= 0
                if dir ~= player.dir then
                    player.dir = dir
                    if dir then
                        player.node:setScaleX(1)
                    else
                        player.node:setScaleX(-1)
                    end
                end
                player.node:setPosition(cc.p(x, y))
            else
                player.path_index = player.path_index + 1
                player.pos = 0
                if player.display and player.display[1] then
                    table.remove(player.display, 1)
                end
            end
        else
            self:moveStop(player.id)
        end
        player = tmp
    end

    self._players[id] = nil
end

function UIWorldMap:handlerMoveListener(event)
    local path = event._usedata
    if path.isSelf then
        gcity = path.to
        self:installPathDisplay(self._curCity.id)
        self:moveTo(self._player.id, path.to) 
    else
        self:moveTo(path.guid, path.to) 
    end
 
function UIWorldMap:updateMapDataListener(event)
     if event ~= nil then
        if GuoZhanServerDataManager._CurrentSoldierCount == GuoZhanServerDataManager._TotalSoldierCount then
            self._mapBtn[0]:setVisible(true)
            
            for i = 1, #CharacterServerDataManager._AllZhenXingTable do
                 local currentZhenXingData = CharacterServerDataManager:GetZhenXingData(i)
                 if table.maxn(currentZhenXingData) == 0 then
                    self._mapBtn[i]:setBright(false)
                    self._mapBtn[i]:setTouchEnabled(false)
                 else
                    self._mapBtn[i]:setBright(true)
                    self._mapBtn[i]:setTouchEnabled(true)
                 end
            end
        end
     end
     self._SoldierCountLabel:setString(GuoZhanServerDataManager._CurrentSoldierCount.."/"..GuoZhanServerDataManager._TotalSoldierCount)
     self._MuBingLingLabel:setString(GuoZhanServerDataManager._HuiFuCount)
end
 
function UIWorldMap:TouchBuildEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
         local tag = sender:getTag()
  
         if tag == 3 then
             -- 当前兵力判定
             if  GuoZhanServerDataManager._CurrentSoldierCount <= 0 then
                 local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                 UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_gz_move_binglibuzu))
                 return  
             end
             -- 当前状态判定(战斗状态不能移动)
             if GuoZhanServerDataManager._CurrentState == GuoZhanSelfState.GuoZhanSelfState_Battle then
                local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_gz_move_zhandou))
                return 
            end
            self._curCity = self._curCityClick
            local city = self._curCity
            self:installAllPathDisplay(city.id)
            print(self._player.city.id, city.id)
            local path = worldMap:getPath(self._player.city.id, city.id)
            local paths = {}
            if path and path.cities then
                local size = #path.cities
                for i = 1, size do
                    paths[i] = path.cities[i].id
                end
                self:hideUI(false)
                SendMsg(PacketDefine.PacketDefine_MapMove_Send, {0, paths})
            end
         -- 观战
         elseif tag == 1 then
             self:hideUI(false)
             UISystem:CloseUI(UIType.UIType_BottomList)
             GameGlobal:GlobalLevelState(4)
             UISystem:OpenUI(UIType.UIType_BattleUI, -2)
             UISystem:OpenUI(UIType.UIType_UIChallenge)
             SendMsg(PacketDefine.PacketDefine_MapCitySubscribe_Send, {self._curCity.id})
         --攻击
         elseif tag == 2 then
             -- 当前兵力判定
           
             if  GuoZhanServerDataManager._CurrentSoldierCount <= 0 then
                 local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                 UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_gz_move_binglibuzu))
                 return 
             end
            -- 当前状态判定(战斗状态不能移动)
            if GuoZhanServerDataManager._CurrentState == GuoZhanSelfState.GuoZhanSelfState_Battle then
                local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_gz_move_zhandou))
                return 
            end
            self._curCity = self._curCityClick
            local city = self._curCity
            self:installAllPathDisplay(city.id)
            local path = worldMap:getPath(self._player.city.id, city.id)
            local paths = {}
            if path and path.cities then
                local size = #path.cities
                for i = 1, size do
                    paths[i] = path.cities[i].id
                end
                self:hideUI(false)
                SendMsg(PacketDefine.PacketDefine_MapMove_Send, {0, paths})
            end
         end
     end
 end
 
function UIWorldMap:TouchEvent(sender, eventType)
     if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
        if tag == -1 then
            self:hideUI(false)
        elseif tag == 4 then
             if GuoZhanServerDataManager._HuiFuCount > 0 or GameGlobal:GetItemDataManager():GetItemCount(30021) > 0 then
                 if GuoZhanServerDataManager._CurrentSoldierCount < GuoZhanServerDataManager._TotalSoldierCount or GuoZhanServerDataManager._CurrentSoldierCount == 0 then
                    SendMsg(PacketDefine.PacketDefine_Supplement_Send)
                 end
             else
                 local uiInstance = UISystem:OpenUI(UIType.UIType_BuyItem)
                 uiInstance:OpenItemInfoNotifiaction(30021, 1)
             end
        elseif tag == 5 then
             UISystem:OpenUI(UIType.UIType_Feats)
        elseif tag == 6 then
             UISystem:CloseAllUI()
             UISystem:CloseUI(UIType.UIType_WorldMap)
             UISystem:OpenUI(UIType.UIType_MaincityUI)
             UISystem:CloseUI(UIType.UIType_BottomList)
             UISystem:OpenUI(UIType.UIType_BottomList)
        elseif tag == 7 then   
            self:moveMapToSelf()
        else
            self._mapBtn[0]:setVisible(false)
             --发送当前选择阵型数据
             if GuoZhanServerDataManager._CurrentZhenXing ~= tag then
                 --当前兵力必须等于总兵力--才可选择阵型
                 if GuoZhanServerDataManager._CurrentSoldierCount == GuoZhanServerDataManager._TotalSoldierCount then
                    SendMsg(PacketDefine.PacketDefine_QueryCorps_Send)
                 else
                     local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                     UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_gz_zhenXingSelect_sildierCount))
                 end
             end
        end
     end
    if player.city.id == to then
        return
    end
    local path = worldMap:getPath(player.city.id, to)

    player.path = {}
    player.path_index = 1
    local path_index = 0

    local base = player.city.base
    for _, next_city in ipairs(path.cities) do
        local info = {}
        self:initMoveInfo(info, base, next_city)
        path_index = path_index + 1
        player.path[path_index] = info
        base = next_city
    end
    self:moveStart(id)
end

function UIWorldMap:onTouchMap(event)
    if event.name == "began" then
        local offset = self._touchPanel:getInnerContainerPosition()
        local city = worldMap:getCityByPos(event.x - offset.x, event.y - offset.y);
        print(self._player)
        if city and self._player then
            self._curCityClick = city
            self:updateCityInfo(self._cities[city.id])
            self:hideUI(true)
        end
    end
end

function UIWorldMap:moveToCityListener(event)
    local id = event._usedata
    if self._player.next == nil then
        if id == 500009 or id == 110137 or id == 1090132 then
            self._player.city = self._cities[id]
            self._player.city.id = id
            gcity = id
            self._player.node:setPosition(cc.p(self._cities[id].base.ix , self._cities[id].base.iy))
            self:moveMapToSelf()
        end
    end

    local path = player.path[1]
    if not path then
        return
    end

    player.step = path.distance / player.speed
    player.next = self._move_list.next;
    player.prev = self._move_list
    self._move_list.next.prev = player;
    self._move_list.next = player;

    if player ~= self._player then
        self._moveLayer:addChild(player.node)
    end
end

function UIWorldMap:updatePlayerListener(event)
    local guid = event._usedata.guid
    local headId = event._usedata.headId
    local city = event._usedata.city
   
    if guid ~= gUid then
        self:addPlayer(guid, headId, city, 10000, false)
    end
    if not player.next then
        return
    end
    player.next.prev = player.prev
    player.prev.next = player.next
    player.prev = nil
    player.next = nil
    if player ~= self._player then
        self:removePlayer(id)
    end
end

function UIWorldMap:hideUI(isshow)
    if isshow then
        self._closeLayout:setVisible(true)
        self._buildLayout:setVisible(true)
        self._PanelLeftCenter:setVisible(false)
        UISystem:SetVisible(UIType.UIType_BottomList, false)
    else
        self._closeLayout:setVisible(false)
        self._buildLayout:setVisible(false)
        self._PanelLeftCenter:setVisible(true)
        UISystem:SetVisible(UIType.UIType_BottomList, true)
        player = tmp
    end
end

function UIWorldMap:moveMapToSelf()
    local x = 0
    local y = 0
    
    if self._player.city.base.x - 480 > 0 then
        x = math.max(480 - self._player.city.base.x, 960 - 4200)
    else 
        x = math.min(480 - self._player.city.base.x, 0)
    end
   
    if self._player.city.base.y - 270 > 0 then
        y = math.max(270 - self._player.city.base.y, 540 - 2520)
    else
        x = math.min(270 - self._player.city.base.x, 0)
    end
    
    self._touchPanel:setInnerContainerPosition(cc.p(x, y))
end

return UIWorldMap