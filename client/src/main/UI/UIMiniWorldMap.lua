----
-- 文件名称：UIMiniWorldMap.lua
-- 功能描述：UIMiniWorldMap
-- 文件说明：
-- 作    者：
-- 创建时间：2015-8-5
-- 修改 ：
-- 
--
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
local UISystem = require("main.UI.UISystem")
local GuoZhanServerDataManager = GameGlobal:GetGuoZhanServerDataManager()
local UIMiniWorldMap = class("UIMiniWorldMap", UIBase)
local NetSystem = GameGlobal:GetNetSystem()
local _Instance = nil
g_RectW = 141
g_RectH = 84

--构造函数
function UIMiniWorldMap:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_MiniMap
    self._ResourceName = "UIMiniWorldMap.csb" 
end

--Load
function UIMiniWorldMap:Load()
    UIBase.Load(self)
    _Instance = self
    local touchPanel = seekNodeByName(self._RootPanelNode, "Panel_TouchPanel")
--    self:GetUIByName("Title"):enableOutline(cc.c4b(0, 0, 0, 250), 2)
    local getWarBtn = self:GetUIByName("Button_1")
    getWarBtn:setTag(1)
--    getWarBtn:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 250), 2)
    getWarBtn:addTouchEventListener(self.TouchEvent)
    self._MapWarData = {}
    self._MapWarData[1] = self:GetUIByName("ccnum")
    self._MapWarData[2] = self:GetUIByName("sliver_num")
    self._MapWarData[3] = self:GetUIByName("name")
    self._MapWarData[4] = self:GetUIByName("Text_WarGet")
    
    self._MapWarData[1]:setString("")
    self._MapWarData[3]:setString("")
    
    g_DrawNode = cc.DrawNode:create() 
    local uiInstance = UISystem:GetUIInstance(UIType.UIType_WorldMap)
--    touchPanel:addChild(uiInstance._JuDian3ButtonList[1]:clone():setScale(5), 100)
    local x = math.abs(uiInstance._WorldMapTouchPanel:getPositionX()) / (4200) * 617
    local y = math.abs(uiInstance._WorldMapTouchPanel:getPositionY()) / (2520) * 378
    g_DrawNode:setPosition(250 + x > 867 - g_RectW and 867 - g_RectW or 250 + x, 84 + y > 462 - g_RectH and 462 - g_RectH or  84 + y )
    self._RootPanelNode:addChild(g_DrawNode, 10)
    g_DrawNode:drawRect(cc.p(0, 0), cc.p(g_RectW, g_RectH), cc.c4f(1,0,0,1))
    
    touchPanel:addTouchEventListener(self.OnTouchMap)
    local cancel = self:GetUIByName("Close")
    cancel:setLocalZOrder(11)
    cancel:setTag(-1)
    cancel:addTouchEventListener(self.TouchEvent)
    
    -- 给大地图做圆角
    self:drawNodeRoundRect()
end

--Unload
function UIMiniWorldMap:Unload()
    UIBase.Unload(self)
end

--打开
function UIMiniWorldMap:Open()
    UIBase.Open(self)
    self._OpenCallBack  = AddEvent(GameEvent.GameEvent_GuoZi_Succeed, self.OpenUISuccess)
--    local guanZhanPacket = NetSystem:CreateToSendPacket(PacketDefine.PacketDefine_GuoZhan_Request_Send)
--    guanZhanPacket._Param = 12
--    guanZhanPacket._DestJuDianID = 1
--    NetSystem:SendPacket(guanZhanPacket)
end

--关闭
function UIMiniWorldMap:Close()
    UIBase.Close(self)
end 

function UIMiniWorldMap:OpenUISuccess()
    local guozi = self._usedata
    _Instance._MapWarData[1]:setString("x"..guozi._GuoJiaNum)
    _Instance._MapWarData[2]:setString(guozi._Sliver)
    _Instance._MapWarData[3]:setString(GetCountryChinese(GetPlayer()._Country)..ChineseConvert["UIWorldMap_JuDian_Name"])
    _Instance._MapWarData[4]:setString(guozi._GuoZiDataNum)
end

function UIMiniWorldMap.OnTouchMap(sender, eventType)
    local uiInstance = UISystem:GetUIInstance(UIType.UIType_WorldMap)
    if eventType  == ccui.TouchEventType.began then
        local movePosition =  sender:getTouchBeganPosition()
        local offy = (display.sizeInPixels.height - 540 * display.sizeInPixels.width / 960) / 2

        if movePosition.x<= 250 + g_RectW / 2 then
            movePosition.x = 250 + g_RectW / 2 
        elseif movePosition.x>= 867 - g_RectW / 2  then
            movePosition.x = 867 - g_RectW / 2 
        end
        if movePosition.y<= offy + 84 + g_RectH / 2 then
            movePosition.y = offy + 84 + g_RectH / 2 
        elseif movePosition.y>= offy + 462 - g_RectH / 2 then
            movePosition.y = offy + 462 - g_RectH / 2 
        end
        g_DrawNode:setPosition((movePosition.x - g_RectW / 2  ), (movePosition.y - offy- g_RectH / 2))
        local newPos = { x = -((movePosition.x - 250 - g_RectW / 2) / 617) * (4200), y = - ((movePosition.y - offy - 84 - g_RectH / 2) / 378) * (2520)}
        uiInstance:SetMapWorldPosition(newPos)
        uiInstance._LastMovePosition = newPos
    elseif eventType == ccui.TouchEventType.ended then
       
    elseif eventType == ccui.TouchEventType.moved then
        uiInstance._IsMoveMapTouchPanel = true
        local movePosition =  sender:getTouchMovePosition()
        local offy = (display.sizeInPixels.height - 540 * display.sizeInPixels.width / 960) / 2

        if movePosition.x<= 250 + g_RectW / 2 then
            movePosition.x = 250 + g_RectW / 2 
        elseif movePosition.x>= 867 - g_RectW / 2  then
            movePosition.x = 867 - g_RectW / 2 
        end
        if movePosition.y<= offy + 84 + g_RectH / 2 then
            movePosition.y = offy + 84 + g_RectH / 2
        elseif movePosition.y>= offy + 462 - g_RectH / 2 then
            movePosition.y = offy + 462 - g_RectH / 2 
        end
        g_DrawNode:setPosition((movePosition.x - g_RectW / 2  ), (movePosition.y - offy - g_RectH / 2))
        local newPos = { x = -((movePosition.x - 250 - g_RectW / 2) / 617) * (4200), y = - ((movePosition.y - offy - 84 - g_RectH / 2) / 378) * (2520)}
        uiInstance:SetMapWorldPosition(newPos)
        uiInstance._LastMovePosition = newPos
    end
end

function UIMiniWorldMap:TouchEvent(eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = self:getTag()
        if tag == -1 then
            UISystem:CloseUI(UIType.UIType_MiniMap) 
        elseif tag == 1 then
            if GuoZhanServerDataManager:GetGuoZiData()._Sliver > 0 then
                local guanZhanPacket = NetSystem:CreateToSendPacket(PacketDefine.PacketDefine_GuoZhan_Request_Send)
                guanZhanPacket._Param = 13
                guanZhanPacket._DestJuDianID = 0
                NetSystem:SendPacket(guanZhanPacket)
            end
        end
    end
end

-- 传入DrawNode对象，画圆角矩形
--function drawNodeRoundRect(drawNode, rect, borderWidth, radius, color, fillColor)
function UIMiniWorldMap:drawNodeRoundRect()
    local drawNode = cc.DrawNode:create() 
    drawNode:setPosition(0, 462 - 83 + 2)
    local rect = {x = 247, y = 84, width = 623, height = 384}
    local radius = 10
    local borderWidth = 2
    local fillColor = nil
    local color = cc.c4f(0.65, 0.46, 0.32, 1)
    -- segments表示圆角的精细度，值越大越精细
    local segments    = 100
    local origin      = cc.p(rect.x, rect.y)
    local destination = cc.p(rect.x + rect.width, rect.y - rect.height)
    local points      = {}

    -- 算出1/4圆
    local coef     = math.pi / 2 / segments
    local vertices = {}

    for i=0, segments do
        local rads = (segments - i) * coef
        local x    = radius * math.sin(rads)
        local y    = radius * math.cos(rads)

        table.insert(vertices, cc.p(x, y))
    end

    local tagCenter      = cc.p(0, 0)
    local minX           = math.min(origin.x, destination.x)
    local maxX           = math.max(origin.x, destination.x)
    local minY           = math.min(origin.y, destination.y)
    local maxY           = math.max(origin.y, destination.y)
    local dwPolygonPtMax = (segments + 1) * 4
    local pPolygonPtArr  = {}

    -- 左上角
    tagCenter.x = minX + radius;
    tagCenter.y = maxY - radius;

    for i=0, segments do
        local x = tagCenter.x - vertices[i + 1].x
        local y = tagCenter.y + vertices[i + 1].y

        table.insert(pPolygonPtArr, cc.p(x, y))
    end

    -- 右上角
    tagCenter.x = maxX - radius;
    tagCenter.y = maxY - radius;

    for i=0, segments do
        local x = tagCenter.x + vertices[#vertices - i].x
        local y = tagCenter.y + vertices[#vertices - i].y

        table.insert(pPolygonPtArr, cc.p(x, y))
    end

    -- 右下角
    tagCenter.x = maxX - radius;
    tagCenter.y = minY + radius;

    for i=0, segments do
        local x = tagCenter.x + vertices[i + 1].x
        local y = tagCenter.y - vertices[i + 1].y

        table.insert(pPolygonPtArr, cc.p(x, y))
    end

    -- 左下角
    tagCenter.x = minX + radius;
    tagCenter.y = minY + radius;

    for i=0, segments do
        local x = tagCenter.x - vertices[#vertices - i].x
        local y = tagCenter.y - vertices[#vertices - i].y

        table.insert(pPolygonPtArr, cc.p(x, y))
    end

    if fillColor == nil then
        fillColor = cc.c4f(0, 0, 0, 0)
    end

    drawNode:drawPolygon(pPolygonPtArr, #pPolygonPtArr, fillColor, borderWidth, color)
    self._RootPanelNode:addChild(drawNode, 10)
end

return UIMiniWorldMap
