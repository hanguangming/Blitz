----
-- 文件名称：UIWorldMapEditor.lua
-- 功能描述：世界地图编辑器
-- 文件说明：世界地图编辑器
-- 作    者：王雷雷
-- 创建时间：2015-8-4
--  修改

local AStar = require("main.Utility.AStar")
local UIWorldMapEditor = class("UIWorldMapEditor", UIBase)
local UISystem = GameGlobal:GetUISystem()
local mathCeil = math.ceil
local stringFormat = string.format
local tableInsert = table.insert

--需要导出数据结构

--tileWidth
--tileHeight
--widthTiles
--heightTiles
--多个元素数据
--所用图片
--image
--相邻
--idXiangLin
--status
--row
--col
--id
--parent
--type
--name
--belong
--路径
--paths

--考虑到编辑器不会移植，中文暂时写死在这
--据点类型
local JuDianType = 
{
    [1] = "城市",
    [2] = "关口",
    [3] = "野外",
    [4] = "都城",
}
--据点地形
local JuDianDiTing = 
{
    [1] = "城池",
    [2] = "平原",
    [3] = "水域", 
}
local JuDianBelong = 
{
    [1] = "魏国",
    [2] = "吴国",
    [3] = "蜀国",
    [4] = "蛮族",
    [5] = "黄巾",
}
--由字符串求索引
local function GetJuDianTypeNumber(typeStr)
    for k, v in pairs(JuDianType)do
        if v == typeStr then
            return k
        end
    end
    return nil
end

local function GetJuDianDiTingNumber(typeStr)
    for k, v in pairs(JuDianDiTing)do
        if v == typeStr then
            return k
        end
    end
    return nil
end

local function GetJuDianBelongNumber(typeStr)
    for k, v in pairs(JuDianBelong)do
        if v == typeStr then
            return k
        end
    end
    return nil
end

local JuDianData = class("JuDianData")
function JuDianData:ctor()
    --据点名称
    self._JuDianName = ""
    --据点类型
    self._JuDianType = 1
    --据点地形
    self._JuDianDiXing = 1
    --据点归属
    self._JuDianBelong = 1
    --据点素材
    self._JuDianSuCai = 1
    --行列
    self._Row = 1
    self._Col = 1
    --相邻的据点
    self._NearJuDian = {}
    --UI控件 
    self._UIImage = nil
    --Name label 
    self._NameLabel = nil
end
--------------------------------------------------------------------------------------------------
--构造
function UIWorldMapEditor:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_WorldMapEditor
    self._ResourceName =  "UIWorldMapEditor.csb"
    ----------UI控件 ----------
    --地图Sprite
    self._MapSpriteList = nil
    --世界背景
    self._WorldBgPanel = nil
    --设定面板
    self._SetupPanel = nil
    --Tile面板
    self._TilePanel = nil
    --据点面板
    self._Panel_Home = nil
    --格子Layer
    self._TileLayer = nil
    --寻路面板
    self._FindPathPanel = nil
    --寻路起始ID
    self._TextFieldFindPathStartID = nil
    self._TextFieldFindPathEndID = nil
    self._TextFieldCloseJuDian = nil
    --宽度
    self._TextField_MapWidth = nil
    self._TextField_MapHeight = nil
    self._TextField_TileWidth = nil
    self._TextField_TileHeight = nil
    self._TileRootNode = nil
    --据点面板
    self._TextField_JuDianName = nil
    self._ListView_JuDianType = nil
    self._ListView_JuDianDiXing = nil
    self._ListView_JuDianBelong = nil
    self._ListView_JuDianSuCai = nil
    self._Text_Tilenfo = nil
    --编辑路径模式
    self._CheckBox_PathEditMode = nil
    --保存按钮
    self._Button_Save = nil
    --格子
    self._MapTileTagData = {}
    --
    
    ----------变量----------
    --单个TileWidth
    self._TileWidth = 0
    --单个TileHeight
    self._TileHeight = 0
    --横向Tile数
    self._MapTileCountWidth = 0
    --纵向Tile数
    self._MapTileCountHeight = 0
    --相邻数据表
    self._XiangLinTable = 0
    --图片列表
    self._ImageList = {}
    --地图数据（0:可通行, 1：不可通行）
    self._MapData = {}
    --Map Tile Data(据点信息)
    self._MapTileData = {}
    --当前选择的Tile Row Col
    self._CurrentSelectRow = 0
    self._CurrentSelectCol = 0
    self._CurrentJuDianType = 0
    self._CurrentJuDianDiXing = 0
    self._CurrentJuDianBelong = 0
    self._CurrentJuDianSuCai = 0
    self._CurrentJuDianName = ""
    --路径编辑
    self._IsPathEdit = false
    --是否是移动TilePanel
    self._IsMoveTilePanel = false
    --上次MovePosition
    self._LastMovePosition = nil
end

--Load
function UIWorldMapEditor:Load()
    UIBase.Load(self)
    self._SetupPanel = self:GetUIByName("Panel_SetMap")
    self._TilePanel = self:GetUIByName("Panel_Tile")
    self._MapSpriteList = {}
    for i = 1, 9 do
        local mapSpriteName = stringFormat("Sprite_Map_%d", i)
        local mapSprite = self:GetUIByName(mapSpriteName)
        tableInsert(self._MapSpriteList, mapSprite)
    end
    self._TextField_MapWidth = self:GetUIByName("TextField_MapWidth")
    self._TextField_MapHeight = self:GetUIByName("TextField_MapHeight")
    self._TextField_TileWidth = self:GetUIByName("TextField_TileWidth")
    self._TextField_TileHeight = self:GetUIByName("TextField_TileHeight")
    self._TileRootNode = self:GetUIByName("TileRootNode")
    self._TextField_MapWidth:setString("128")
    self._TextField_MapHeight:setString("72")
    self._TextField_TileWidth:setString("30")
    self._TextField_TileHeight:setString("30")
    --按钮事件
    local setupOkButton = self:GetUIByName("Button_OK")
    setupOkButton:addTouchEventListener(self.OnSetupOkButton)
    local setupCancelButton = self:GetUIByName("Button_Cancel")
    setupCancelButton:addTouchEventListener(self.OnSetupCancelButton)
    local newMapButton = self:GetUIByName("Button_NewMap")
    newMapButton:addTouchEventListener(self.OnButtonNewMap)
    self._TilePanel:addTouchEventListener(self.OnTilePanel)
    --据点信息面板控
    self._Panel_Home = self:GetUIByName("Panel_Home")
    self._TextField_JuDianName = self:GetUIByName("TextField_JuDianName")
    self._ListView_JuDianType = self:GetUIByName("ListView_JuDianType")
    self._ListView_JuDianDiXing = self:GetUIByName("ListView_JuDianDiXing")
    self._ListView_JuDianBelong = self:GetUIByName("ListView_JuDianBelong")
    self._ListView_JuDianSuCai = self:GetUIByName("ListView_JuDianSuCai")
    self._Text_Tilenfo = self:GetUIByName("Text_Tilenfo")
    self._CheckBox_PathEditMode = self:GetUIByName("CheckBox_PathEditMode")
    self._CheckBox_PathEditMode:addEventListener(self.OnPathEditCheckBox)
    local addJuDianButton = self:GetUIByName("Button_JuDianAdd")
    addJuDianButton:addTouchEventListener(self.OnJuDianAdd)
    local removeJuDianButton = self:GetUIByName("Button_JuDianRemove")
    removeJuDianButton:addTouchEventListener(self.OnJuDianRemove)
    local openButton = self:GetUIByName("Button_Open")
    openButton:addTouchEventListener(self.OnOpenButton)
    self._Button_Save = self:GetUIByName("Button_Save")
    self._Button_Save:addTouchEventListener(self.OnSave)
    local quitButton = self:GetUIByName("Button_Quit")
    quitButton:addTouchEventListener(self.OnQuit)
    local findPathButton = self:GetUIByName("Button_FindPath")
    findPathButton:addTouchEventListener(self.OnFindPathButton)
    self._CurrentJuDianName = self._TextField_JuDianName:getString()
    self._FindPathPanel = self:GetUIByName("Panel_FindPath")
    local startPathButton = self:GetUIByName("Button_StartPath")
    startPathButton:addTouchEventListener(self.OnStartPathButton)
    self._TextFieldFindPathStartID = self:GetUIByName("TextField_StartPathID")
    self._TextFieldFindPathEndID = self:GetUIByName("TextField_EndPathID")
    self._TextFieldCloseJuDian = self:GetUIByName("TextField_CloseList")
    self._FindPathPanel:setVisible(false)
    --初始化据点面板内容
    for i = 1, #JuDianType do
        local newText = ccui.Text:create()
        local showStr = JuDianType[i]
        newText:setString(showStr)
        newText:setFontSize(15)
        newText:setTouchEnabled(true)
        newText:addTouchEventListener(UIWorldMapEditor.OnJuDianType)
        local custom_item = ccui.Layout:create()
        custom_item:setContentSize(newText:getContentSize())
        custom_item:addChild(newText)
        newText:setTag(i)
        newText:setName(tostring(i))
        custom_item:setTag(i)
        newText:setPosition(cc.p(custom_item:getContentSize().width / 2.0, custom_item:getContentSize().height / 2.0))
        self._ListView_JuDianType:pushBackCustomItem(custom_item)
    end
    --
    for i = 1, #JuDianDiTing do
        local newText = ccui.Text:create()
        local showStr = JuDianDiTing[i]
        newText:setString(showStr)
        newText:setFontSize(15)
        newText:setTouchEnabled(true)
        newText:addTouchEventListener(UIWorldMapEditor.OnJuDianDiXing)
        local custom_item = ccui.Layout:create()
        custom_item:setContentSize(newText:getContentSize())
        custom_item:addChild(newText)
        newText:setTag(i)
        newText:setName(tostring(i))
        custom_item:setTag(i)
        newText:setPosition(cc.p(custom_item:getContentSize().width / 2.0, custom_item:getContentSize().height / 2.0))
        self._ListView_JuDianDiXing:pushBackCustomItem(custom_item)
    end
    
    for i = 1, #JuDianBelong do
        local newText = ccui.Text:create()
        local showStr = JuDianBelong[i]
        newText:setString(showStr)
        newText:setFontSize(15)
        newText:setTouchEnabled(true)
        newText:addTouchEventListener(UIWorldMapEditor.OnJuDianBelong)
        local custom_item = ccui.Layout:create()
        custom_item:setContentSize(newText:getContentSize())
        custom_item:addChild(newText)
        newText:setTag(i)
        newText:setName(tostring(i))
        custom_item:setTag(i)
        newText:setPosition(cc.p(custom_item:getContentSize().width / 2.0, custom_item:getContentSize().height / 2.0))
        self._ListView_JuDianBelong:pushBackCustomItem(custom_item)
    end
    --lfs C++中的lfs
    local fullPath = cc.FileUtils:getInstance():fullPathForFilename("meishu/ui/guozhanditu/judianSuCai/UI_gzdt_cheng1.png")
    print(fullPath)
    local dotPosStart,_ = string.find(fullPath, "UI_gzdt_cheng1.png")
    fullPath = string.sub(fullPath, 1,  dotPosStart - 2)
    print(fullPath)
    local currentIndex = 0
    for file in lfs.dir(fullPath) do 
        print(file)
        if file ~= ".." and file ~= "." then
            currentIndex = currentIndex + 1
            self._ImageList[currentIndex]  = file
        end
    end
    
    for i = 1, # self._ImageList do
        local newText = ccui.Text:create()
        local showStr = self._ImageList[i]
        newText:setString(showStr)
        newText:setFontSize(15)
        newText:setTouchEnabled(true)
        newText:setTag(i)
        newText:addTouchEventListener(UIWorldMapEditor.OnJuDianSuCai)
        local custom_item = ccui.Layout:create()
        custom_item:setContentSize(newText:getContentSize())
        custom_item:addChild(newText)
        newText:setName(tostring(i))
        custom_item:setTag(i)
        newText:setPosition(cc.p(custom_item:getContentSize().width / 2.0, custom_item:getContentSize().height / 2.0))
        self._ListView_JuDianSuCai:pushBackCustomItem(custom_item)   
    end

    self._IsPathEdit = self._CheckBox_PathEditMode:isSelected()  
    ----
    self._SetupPanel:setVisible(false)
    self._Panel_Home:setVisible(false)
end

--unload
function UIWorldMapEditor:Unload()
    UIBase.Unload(self)
    
end

--Open
function UIWorldMapEditor:Open()
    UIBase.Open(self)
    local GuoZhanServerDataManager = GameGlobal:GetGuoZhanServerDataManager() 
    GuoZhanServerDataManager:Init()
    GuoZhanServerDataManager:GetMoveCityListByJuDian(1090132, 130026)
    --[[
    --测试代码
    print("start getCityList ", os.clock())
    local GuoZhanServerDataManager = GameGlobal:GetGuoZhanServerDataManager() 
    GuoZhanServerDataManager:Init()
    GuoZhanServerDataManager:GetMoveCityList(53, 17, 106, 125)
    print("end getCityList", os.clock())
    ]]--
end

--Close
function UIWorldMapEditor:Close()
    UIBase.Close(self)
    
end
--------------------------------------------------------------------------------------------------
--求图片索引
function UIWorldMapEditor:GetJuDianImageIndex(imageStr)
    for i = 1, #self._ImageList do
        if self._ImageList[i] == imageStr then
            return i
        end
    end
    print("GetJuDianImageIndex ", imageStr)
    return nil
end
--构建地图
function UIWorldMapEditor:BuildMap()
    --参数是否设定
    if self._TileWidth == nil or self._TileHeight == nil or self._MapTileCountWidth == nil or self._MapTileCountHeight == nil then
        return
    end
    --地图数据（0:可通行, 1：不可通行）
    self._MapData = {}
    self._MapTileData = {}
    for row = 1, self._MapTileCountHeight do
        self._MapData[row] = {}
        self._MapTileData[row] = {}
        for col = 1, self._MapTileCountWidth do
            self._MapData[row][col] = 1
            self._MapTileData[row][col] = nil
        end
    end
    --网格绘制
    --创建Layer行不通，好卡，数量太多的缘故吧
    --[[
    local newLayer = createLayer(cc.c4b(0, 0, 0, 100))
    newLayer:setContentSize(contentSize)
    newLayer:setAnchorPoint(0, 0)
    self._TilePanel:addChild(newLayer)
    newLayer:setPosition(cc.p((col - 1) * self._TileWidth, (row - 1) * self._TileHeight))
    print("new", row, col)
    ]]--
    
    local createLayer = display.newLayer
    local newLayer = cc.Layer:create()
    
    --目前只能加在根节点，加在其它节点，drawLine会不显示，目前不清楚原因
    self._RootUINode:addChild(newLayer)
    self._TileLayer = newLayer
    --绘制横线
    local contentSize = cc.size(self._TileWidth, self._TileHeight)
     for row = 1, self._MapTileCountHeight do
        local newNode = cc.DrawNode:create()
        newLayer:addChild(newNode, 10)
        
        local startPosition = cc.p(0, (row - 1) * self._TileHeight)
        local endPosition = cc.p(self._MapTileCountWidth * self._TileWidth, (row - 1) * self._TileHeight)
        local color = cc.c4f(1,1,1,0.4)
        newNode:drawLine( startPosition, endPosition, color)
     end
     --绘制 竖线
    for col = 1, self._MapTileCountWidth do
        local newNode = cc.DrawNode:create()
        newLayer:addChild(newNode, 10)

        local startPosition = cc.p((col - 1) * self._TileWidth, 0 )
        local endPosition = cc.p((col - 1) * self._TileWidth, self._MapTileCountHeight * self._TileHeight)
        local color = cc.c4f(1,1,1,0.4)
        newNode:drawLine( startPosition, endPosition, color)
    end
    --位置校正到 tilePanel的左下
    local newWorldPosition = self._TilePanel:convertToWorldSpace(cc.p(0, 0))
    local tileLayerParentNode = self._TileLayer:getParent()
    local localPosition = tileLayerParentNode:convertToNodeSpace(newWorldPosition)
    self._TileLayer:setPosition(localPosition)
    
    self._MapTileTagData = {}
    for row = 1, self._MapTileCountHeight do
        self._MapTileTagData[row] = {}
        for col = 1, self._MapTileCountWidth do
            self._MapTileTagData[row][col] = ccui.Text:create()
            self._MapTileTagData[row][col]:retain()
            --self._MapTileTagData[row][col]:setAnchorPoint(0.5, 0.5)
            --self._MapTileTagData[row][col]:setString("1")
            local x = (col - 1) * self._TileWidth + 0.5 * self._TileWidth 
            local y = (row - 1) * self._TileHeight + 0.5 * self._TileWidth 
            self._MapTileTagData[row][col]:setPosition(x, y)
            --self._TilePanel:addChild(self._MapTileTagData[row][col])
        end
    end
end

--打开地图
function UIWorldMapEditor:OpenFile()
    local fileUtils = cc.FileUtils:getInstance()
    local data = fileUtils:getStringFromFile("Data/worldmap.jason")
    --local fd,err = io.open("res/Data/worldmap.jason","rb")
    --if not fd then
        --print("OpenFile err", err)
        --return nil,err
   -- end
    --local data = fd:read("*all")
    
    if data ~= nil then
        local worldData = decodejson(data)
        self._TileWidth = worldData.tileWidth
        self._TileHeight = worldData.tileHeight
        self._MapTileCountWidth = worldData.widthTiles  
        self._MapTileCountHeight = worldData.heightTiles
        self:BuildMap()
        --据点数据
        local homeCount = #worldData.homes
        for i = 1, homeCount do
            local homeData = worldData.homes[i]
            local curRow = homeData.row
            local curCol = homeData.col
            local juDianData = self._MapTileData[curRow][curCol] 
            if juDianData == nil then
                juDianData = JuDianData:new()
                self._MapTileData[curRow][curCol]   = juDianData
            end
            juDianData._JuDianName = homeData.name
            local indexType = GetJuDianTypeNumber(homeData.type)
            local indexDiXing = GetJuDianDiTingNumber(homeData.dixing)
            local indexBelong = GetJuDianBelongNumber(homeData.belong)
            local indexImage = self:GetJuDianImageIndex(homeData.img)
            juDianData._JuDianType = indexType
            juDianData._JuDianDiXing = indexDiXing
            juDianData._JuDianBelong = indexBelong
            juDianData._JuDianSuCai = indexImage
            juDianData._Row = curRow
            juDianData._Col = curCol
            if juDianData._UIImage == nil then
                juDianData._UIImage = ccui.ImageView:create()
                juDianData._UIImage:setScale9Enabled(false)
            end
            if juDianData._NameLabel == nil then
                juDianData._NameLabel = cc.Label:createWithTTF("", FONT_SIMHEI, BASE_FONT_SIZE)
                --print("juDianData._JuDianName", juDianData._JuDianName)
                juDianData._NameLabel:setString(juDianData._JuDianName)
            end
            juDianData._UIImage:ignoreContentAdaptWithSize(true)
            --print("juDianData._JuDianSuCai", juDianData._JuDianSuCai)
            local imageName = "meishu/ui/guozhanditu/judianSuCai/" .. self._ImageList[juDianData._JuDianSuCai]
            juDianData._UIImage:loadTexture(imageName)
            local parentNode = juDianData._UIImage:getParent()
            if parentNode == nil then
                self._TilePanel:addChild(juDianData._UIImage)
                juDianData._UIImage:ignoreAnchorPointForPosition(false)
                juDianData._UIImage:setAnchorPoint(0.5, 0.5)
                local x = (curCol - 1 ) * self._TileWidth + 0.5 *  self._TileWidth
                local y = (curRow - 1 ) * self._TileHeight + 0.5 *  self._TileHeight
                juDianData._UIImage:setPosition(cc.p(x, y))
            end
            local parentLabelNode = juDianData._NameLabel:getParent()
            if parentLabelNode == nil then
                self._TilePanel:addChild(juDianData._NameLabel)
                local x = (curCol - 1 ) * self._TileWidth + 0.5 *  self._TileWidth
                local y = (curRow - 3 ) * self._TileHeight + 0.5 *  self._TileHeight
                juDianData._NameLabel:setPosition(cc.p(x, y))
                juDianData._NameLabel:setColor(cc.c4b(255,0,0,255))
            end
        end
        --Paths
        local pathCount = #worldData.paths
        for i = 1, pathCount do
            local tilePathData = worldData.paths[i]
            if tilePathData ~= nil then
                local row = tilePathData[1]
                local col = tilePathData[2]
                self._MapData[row][col] = 0
                
                local currentMapTileTag =  self._MapTileTagData[row][col]
                local parentNode = currentMapTileTag:getParent()
                if parentNode == nil then
                    self._TilePanel:addChild(self._MapTileTagData[row][col])
                end
                parentNode = currentMapTileTag:getParent()
                parentNode:reorderChild(currentMapTileTag, 1000)
                if self._MapData[row][col] == 1 then
                    currentMapTileTag:setString("")
                else
                    currentMapTileTag:setColor(cc.c4b(0,255,0,255))
                    currentMapTileTag:setString("0")
                end
                --如果是据点特殊标识
                local juDianData = self._MapTileData[row][col] 
                
            end
        end
    end
    --fd:close()
end
---
function UIWorldMapEditor:InitMapJuDian(juDianData, row, col)
    local juDianType = 1
    local juDianDiXing = 1
    local juDianBelong = 1
    local juDianSuCai = 1
    local juDianName = "据点"
    if juDianData ~= nil then
        juDianType = juDianData._JuDianType
        juDianDiXing = juDianData._JuDianDiXing
        juDianBelong = juDianData._JuDianBelong
        juDianSuCai = juDianData._JuDianSuCai
        juDianName = juDianData._JuDianName
    end
    self._TextField_JuDianName:setString(juDianName)
    local showString = stringFormat("%d %d", row, col)
    self._Text_Tilenfo:setString(showString)
    self._Text_Tilenfo:setColor(cc.c4b(255,0,0,255))
    self:SetCurrentSelectJuDianType(juDianType)
    self:SetCurrentSelectJuDianDiXing(juDianDiXing)
    self:SetCurrentSelectJuDianBelong(juDianBelong)
    self:SetCurrentSelectJuDianSuCai(juDianSuCai)
end
--设置当前选择的据点类型
function UIWorldMapEditor:SetCurrentSelectJuDianType(tag)
    self._CurrentJuDianType = tag
    local listview = self._ListView_JuDianType
    local itemCount = table.getn(listview:getItems())
    for i = 1, itemCount do
        local item = listview:getItem(i - 1)
        if item ~= nil then
            local label = item:getChildByName(tostring(i))
            if tag == i then
                label:setColor(cc.c4b(255,0,0,255))
            else
                label:setColor(cc.c4b(255,255,255,255))
            end
        end
    end
end
--设置当前选择的据点地形
function UIWorldMapEditor:SetCurrentSelectJuDianDiXing(tag)
    self._CurrentJuDianDiXing = tag
    local listview = self._ListView_JuDianDiXing
    local itemCount = table.getn(listview:getItems())
    for i = 1, itemCount do
        local item = listview:getItem(i - 1)
        if item ~= nil then
            local label = item:getChildByName(tostring(i))
            if tag == i then
                label:setColor(cc.c4b(255,0,0,255))
            else
                label:setColor(cc.c4b(255,255,255,255))
            end
        end
    end
end
--设置当前选择的据点归属
function UIWorldMapEditor:SetCurrentSelectJuDianBelong(tag)
    self._CurrentJuDianBelong = tag
    local listview = self._ListView_JuDianBelong
    local itemCount = table.getn(listview:getItems())
    for i = 1, itemCount do
        local item = listview:getItem(i - 1)
        if item ~= nil then
            local label = item:getChildByName(tostring(i))
            if tag == i then
                label:setColor(cc.c4b(255,0,0,255))
            else
                label:setColor(cc.c4b(255,255,255,255))
            end
        end
    end
end
--设置当前选择的据点素材
function UIWorldMapEditor:SetCurrentSelectJuDianSuCai(tag)
    self._CurrentJuDianSuCai = tag
    local listview = self._ListView_JuDianSuCai
    local itemCount = table.getn(listview:getItems())
    for i = 1, itemCount do
        local item = listview:getItem(i - 1)
        if item ~= nil then
            local label = item:getChildByName(tostring(i))
            if tag == i then
                label:setColor(cc.c4b(255,0,0,255))
            else
                label:setColor(cc.c4b(255,255,255,255))
            end
        end
    end
end

--修改数据（5*5）
function UIWorldMapEditor:ChangeJuDianDataTo1(currentJuDianData)
    for startRow = -2, 2 do
        for startCol = -2, 2 do
            local currentRow = currentJuDianData._Row + startRow
            local currentCol =  currentJuDianData._Col + startCol
            self._MapData[currentRow][currentCol] = 1
        end
    end
end

--路径
function UIWorldMapEditor:ChangeJuDianDataToOri(currentJuDianData, oldData)
    for startRow = -2, 2 do
        for startCol = -2, 2 do
            local currentRow = currentJuDianData._Row + startRow
            local currentCol =  currentJuDianData._Col + startCol
            self._MapData[currentRow][currentCol] = oldData[currentRow][currentCol]
        end
    end
end
--修改非src的据点的数据
function UIWorldMapEditor:ChangeOtherJuDianDataTo1(allJuDianData, srcJuDian)
    for k, v in pairs(allJuDianData)do
        if v ~= srcJuDian then
            self:ChangeJuDianDataTo1(v)
        end
    end
end

--计算相邻数据(废弃的接口)
function UIWorldMapEditor:CalcXiangLinDataOld()
    --save old
    local oldMapData = clone(self._MapData)
    print("UIWorldMapEditor:CalcXiangLinData")
    local allJuDianData = {}
    
    for row = 1, self._MapTileCountHeight do
        for col = 1, self._MapTileCountWidth do
            if self._MapTileData[row][col] ~= nil then
                local currentJuDianData = self._MapTileData[row][col]
                self:ChangeJuDianDataTo1(currentJuDianData)
                self._MapData[currentJuDianData._Row][currentJuDianData._Col] = 1
                table.insert(allJuDianData, currentJuDianData)
            end
        end
    end

    --遍历据点，据点间有路径可达时为相邻据点
    local count = #allJuDianData
    for i = 1, count do
        local currentJuDianData = allJuDianData[i]
        self:ChangeJuDianDataToOri(currentJuDianData, oldMapData)
        print("CalcXiangLinData......", i, count)
        currentJuDianData._NearJuDian = {}
        for j = 1, count do
            if j~= i then
                local isHave = false
                local destJuDianData = allJuDianData[j]
                self:ChangeJuDianDataTo1(destJuDianData)
                for startRow = -2, 2 do
                    for startCol = -2, 2 do
                        local currentRow = destJuDianData._Row + startRow
                        local currentCol =  destJuDianData._Col + startCol
                        local start = {row = currentJuDianData._Row, col = currentJuDianData._Col}
                        local dest = {row = currentRow, col = currentCol}
                        local destJuDianID = destJuDianData._Row * 10000 + destJuDianData._Col
                        AStar:init(self._MapData, start, dest,  false)
                        local path = AStar:searchPath()
                        if path ~= nil then
                            isHave = true
                            tableInsert(currentJuDianData._NearJuDian, destJuDianID)
                            local currentCount = #currentJuDianData._NearJuDian
                            if currentCount > 5 then
                                print("near juDian error:", currentJuDianData._JuDianName)
                            end
                            --print("(%d %d)-->(%d %d) find path", currentJuDianData._Row, currentJuDianData._Col, destJuDianData._Row, destJuDianData._Col)
                            --[[
                            for i = 1, #path do
                                print("tile: %d %d", path[i].row, path[i].col)
                            end
                            ]]--
                            break
                        end
                    end
                    
                    if isHave == true then
                        break
                    end
                end
            end
        end
    end
    --还原据点Tile数据
    for row = 1, self._MapTileCountHeight do
        for col = 1, self._MapTileCountWidth do
            if self._MapTileData[row][col] ~= nil then
                local currentJuDianData = self._MapTileData[row][col]
                self._MapData[currentJuDianData._Row][currentJuDianData._Col] = 0
                table.insert(allJuDianData, currentJuDianData)
            end
        end
    end
    self._MapData = clone(oldMapData)

end

--计算相邻数据
function UIWorldMapEditor:CalcXiangLinData()
    --save old
    local oldMapData = clone(self._MapData)
    print("UIWorldMapEditor:CalcXiangLinData")
    local allJuDianData = {}

    for row = 1, self._MapTileCountHeight do
        for col = 1, self._MapTileCountWidth do
            if self._MapTileData[row][col] ~= nil then
                local currentJuDianData = self._MapTileData[row][col]
                self:ChangeJuDianDataTo1(currentJuDianData)
                self._MapData[currentJuDianData._Row][currentJuDianData._Col] = 1
                table.insert(allJuDianData, currentJuDianData)
            end
        end
    end
    
    --遍历据点，据点间有路径可达时为相邻据点
    LogSystem:Clear()
    local count = #allJuDianData
    for i = 1, count do
        local currentJuDianData = allJuDianData[i]
        self:ChangeJuDianDataToOri(currentJuDianData, oldMapData)
        print("CalcXiangLinData......", i, count, os.clock())
        self:ChangeOtherJuDianDataTo1(allJuDianData, currentJuDianData)
        local nameList = ""
        currentJuDianData._NearJuDian = {}
        for j = 1, count do
            if j ~= i then
                local destJuDianData = allJuDianData[j]
                self:ChangeJuDianDataToOri(destJuDianData, oldMapData)
                local start = {row = currentJuDianData._Row, col = currentJuDianData._Col}
                local dest = {row = destJuDianData._Row, col = destJuDianData._Col}
                local destJuDianID = destJuDianData._Row * 10000 + destJuDianData._Col
                AStar:init(self._MapData, start, dest,  false)
                local path = AStar:searchPath()
                if path ~= nil then
                    nameList = nameList ..  "   " .. destJuDianData._JuDianName
                    tableInsert(currentJuDianData._NearJuDian, destJuDianID)
                    local currentCount = #currentJuDianData._NearJuDian
                    if currentCount > 5 then
                        print("near juDian error:", currentJuDianData._JuDianName)
                    end
                end
                self:ChangeJuDianDataTo1(destJuDianData)
            end
        end
        local logInfo = string.format("%s(%d,%d)----->%s", currentJuDianData._JuDianName, currentJuDianData._Row, currentJuDianData._Col, nameList)
        LogSystem:WriteLog(logInfo)
    end

    --还原据点Tile数据
    for row = 1, self._MapTileCountHeight do
        for col = 1, self._MapTileCountWidth do
            if self._MapTileData[row][col] ~= nil then
                local currentJuDianData = self._MapTileData[row][col]
                self._MapData[currentJuDianData._Row][currentJuDianData._Col] = 0
            end
        end
    end
    self._MapData = clone(oldMapData)
    LogSystem:WriteLog("---------------------------------------------------------------------------")
    --比较现在的.txt文件
    local worldMapTableDataManager = GameGlobal:GetDataTableManager():GetWorldMapTableDataManager()
    local count = #allJuDianData
    for i = 1, count do
        local currentJuDianData = allJuDianData[i]
        local tableID = currentJuDianData._Row * 10000 + currentJuDianData._Col
        local currentCount = #currentJuDianData._NearJuDian
        local txtData = worldMapTableDataManager[tableID]
        if txtData ~= nil then

            local str = txtData.xiangling
            if str ~= nil then
                local strValue = string.gsub(str, "%[","")
                local strValue = string.gsub(str, "%]","")
                local nearList = Split(strValue, ",")
                if nearList ~= nil then
                    if #nearList ~= currentCount then
                        local editNear = ""
                        for i = 1, #currentJuDianData._NearJuDian do
                            editNear = editNear .. tostring(currentJuDianData._NearJuDian[i]) .. " "
                        end
                        print("not same ", currentJuDianData._JuDianName, tableID, "txt:", txtData.xiangling, "editor:", editNear)
                        LogSystem:WriteLog("not same %s %d txt: %s editor:%s ", currentJuDianData._JuDianName, tableID, txtData.xiangling, editNear)
                    end
                end
            else
                dump(txtData, "no xiangling")
            end
        else
            print("txt no juDian: ", tableID)
            LogSystem:WriteLog("txt no juDian:  %d", tableID)
        end
    end
    LogSystem:Output()
end

--保存数据
function UIWorldMapEditor:SaveData()
    --数据结构
    local saveData = {}
    saveData.tileWidth = self._TileWidth
    saveData.tileHeight = self._TileHeight
    saveData.widthTiles = self._MapTileCountWidth
    saveData.heightTiles = self._MapTileCountHeight
    saveData.homes = {}
    for row = 1, self._MapTileCountHeight do
        for col = 1, self._MapTileCountWidth do
            local v = self._MapTileData[row][col]
            if v ~= nil then
                local newJuDianData = {}
                newJuDianData.img = self._ImageList[v._JuDianSuCai] 
                newJuDianData.dixing = JuDianDiTing[v._JuDianDiXing]
                newJuDianData.row = v._Row
                newJuDianData.col = v._Col
                newJuDianData.id = v._Row * 10000 + v._Col
                newJuDianData.name = v._JuDianName
                newJuDianData.type = JuDianType[v._JuDianType]
                newJuDianData.belong = JuDianBelong[v._JuDianBelong]
                newJuDianData.xiangling = {}
                for i = 1, #v._NearJuDian do
                    tableInsert(newJuDianData.xiangling, v._NearJuDian[i])
                end
                tableInsert( saveData.homes, newJuDianData)
            end
        end
    end
    --保存Path
    saveData.paths ={}
    for row = 1, self._MapTileCountHeight do
        for col = 1, self._MapTileCountWidth do
            local tileTag = self._MapData[row][col]
            if tileTag == 0 then
                local newPath = {}
                tableInsert(newPath, row)
                tableInsert(newPath, col)
                tableInsert(saveData.paths, newPath)
            end
        end
    end
    --
    local jasonStr = encodejson(saveData)
    --print("jasonStr", jasonStr)
    local fileName = cc.FileUtils:getInstance():fullPathForFilename("res/Data/worldmap.jason")
    local file = io.open(fileName, "wb")
    file.write(file, jasonStr)
    io.close(file)
end

--点击了行列 
function UIWorldMapEditor:OnClickTile(row, col)
    if row <= self._MapTileCountHeight and col <= self._MapTileCountWidth then
        if self._IsPathEdit == false then
            self._CurrentSelectRow = row
            self._CurrentSelectCol = col
            print("OnClickTile ", row, col)
            self._Panel_Home:setVisible(true)
            local mapTileData = self._MapTileData[row][col]
            self:InitMapJuDian(mapTileData, row, col)    
        else
            local currentMapTileTag =  self._MapTileTagData[row][col]
            local parentNode = currentMapTileTag:getParent()
            if parentNode == nil then
                self._TilePanel:addChild(self._MapTileTagData[row][col])
            end
            parentNode = currentMapTileTag:getParent()
            parentNode:reorderChild(currentMapTileTag, 1000)
            --通行
           if  self._MapData[row][col] == 0 then
                self._MapData[row][col] = 1
           else
                self._MapData[row][col] = 0
           end
           if self._MapData[row][col] == 1 then
                currentMapTileTag:setString("")
           else
                currentMapTileTag:setColor(cc.c4b(0,255,0,255))
                currentMapTileTag:setString("0")
           end
        end
    end
end

--新建地图
function UIWorldMapEditor.OnButtonNewMap(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local uiInstance = UISystem:GetUIInstance(UIType.UIType_WorldMapEditor)   
        if uiInstance ~= nil then
            uiInstance._SetupPanel:setVisible(true)
        end
    end
end
--打开地图
function UIWorldMapEditor.OnOpenButton(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local uiInstance = UISystem:GetUIInstance(UIType.UIType_WorldMapEditor)   
        if uiInstance ~= nil then
           uiInstance:OpenFile()
        end
    end
end

--设定面板 确定
function UIWorldMapEditor.OnSetupOkButton(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local uiInstance = UISystem:GetUIInstance(UIType.UIType_WorldMapEditor)
        if uiInstance ~= nil then
            local mapWidth =  tonumber(uiInstance._TextField_MapWidth:getString())
            local mapHeight = tonumber(uiInstance._TextField_MapHeight:getString())
            local tileWidth = tonumber(uiInstance._TextField_TileWidth:getString())
            local tileHeight = tonumber(uiInstance._TextField_TileHeight:getString())

            if mapWidth ~= nil then
                uiInstance._MapTileCountWidth = mapWidth
            end
            if mapHeight ~= nil then
                uiInstance._MapTileCountHeight = mapHeight
            end
            if tileWidth ~= nil then
                uiInstance._TileWidth = tileWidth
            end
            if tileHeight ~= nil then
                uiInstance._TileHeight = tileHeight
            end
            uiInstance:BuildMap()
            uiInstance._SetupPanel:setVisible(false)
        end
    end
end

--设定面板 取消
function UIWorldMapEditor.OnSetupCancelButton(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local uiInstance = UISystem:GetUIInstance(UIType.UIType_WorldMapEditor)
        if uiInstance ~= nil then
            uiInstance._SetupPanel:setVisible(false)
        end
    end
end

--Tile的事件处理
function UIWorldMapEditor.OnTilePanel(sender, eventType)
    --print("UIWorldMapEditor.OnTilePanel", sender, eventType)
    if eventType  == ccui.TouchEventType.began then
        local uiInstance = UISystem:GetUIInstance(UIType.UIType_WorldMapEditor)
        uiInstance._IsMoveTilePanel = false
        uiInstance._LastMovePosition = sender:getTouchBeganPosition()
    elseif eventType == ccui.TouchEventType.ended then
        local worldPosition = sender:getTouchEndPosition()
        local uiInstance = UISystem:GetUIInstance(UIType.UIType_WorldMapEditor)
        if uiInstance ~= nil then
            if uiInstance._IsMoveTilePanel == false then
                local tileSpacePosition = uiInstance._TilePanel:convertToNodeSpace(worldPosition)
                local tileRow = mathCeil(tileSpacePosition.y / uiInstance._TileHeight) 
                local tileCol = mathCeil(tileSpacePosition.x / uiInstance._TileWidth)
                uiInstance:OnClickTile(tileRow, tileCol)
            end
        end
    elseif eventType == ccui.TouchEventType.moved then
        local uiInstance = UISystem:GetUIInstance(UIType.UIType_WorldMapEditor)
        if uiInstance ~= nil then
            local movePosition =  sender:getTouchMovePosition()
            local worldPosOffset = cc.pSub(movePosition, uiInstance._LastMovePosition)
            local tilePanelParentNode = uiInstance._TilePanel:getParent()
            if tilePanelParentNode ~= nil then
                local positionX, positionY =  uiInstance._TilePanel:getPosition()
                local worldPosition = tilePanelParentNode:convertToWorldSpace(cc.p(positionX, positionY))
                local newWorldPosition = cc.pAdd(worldPosition, worldPosOffset)
                local localPosition = tilePanelParentNode:convertToNodeSpace(newWorldPosition)
                uiInstance._TilePanel:setPosition(localPosition)
            end
            if uiInstance._TileLayer ~= nil then
                local tileLayerParentNode = uiInstance._TileLayer:getParent()
                if tileLayerParentNode ~= nil then
                    local positionX, positionY =  uiInstance._TileLayer:getPosition()
                    local worldPosition = tileLayerParentNode:convertToWorldSpace(cc.p(positionX, positionY))
                    local newWorldPosition = cc.pAdd(worldPosition, worldPosOffset)
                    local localPosition = tileLayerParentNode:convertToNodeSpace(newWorldPosition)
                    uiInstance._TileLayer:setPosition(localPosition)
                end            
            end
            uiInstance._LastMovePosition = movePosition
            uiInstance._IsMoveTilePanel = true 
        end
    end
end

--据点类型选择
function UIWorldMapEditor.OnJuDianType(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local uiInstance = UISystem:GetUIInstance(UIType.UIType_WorldMapEditor)
        if uiInstance ~= nil then
            uiInstance:SetCurrentSelectJuDianType(sender:getTag())
        end
    end
end
--据点地形选择
function UIWorldMapEditor.OnJuDianDiXing(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local uiInstance = UISystem:GetUIInstance(UIType.UIType_WorldMapEditor)
        if uiInstance ~= nil then
            uiInstance:SetCurrentSelectJuDianDiXing(sender:getTag())
        end
    end

end
--据点归属
function UIWorldMapEditor.OnJuDianBelong(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local uiInstance = UISystem:GetUIInstance(UIType.UIType_WorldMapEditor)
        if uiInstance ~= nil then
            uiInstance:SetCurrentSelectJuDianBelong(sender:getTag())
        end
    end
end
--据点素材
function UIWorldMapEditor.OnJuDianSuCai(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local uiInstance = UISystem:GetUIInstance(UIType.UIType_WorldMapEditor)
        if uiInstance ~= nil then
            uiInstance:SetCurrentSelectJuDianSuCai(sender:getTag())
        end
    end
end
--据点添加按钮
function UIWorldMapEditor.OnJuDianAdd(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local uiInstance = UISystem:GetUIInstance(UIType.UIType_WorldMapEditor)
        if uiInstance ~= nil then
            local juDianData = uiInstance._MapTileData[uiInstance._CurrentSelectRow][uiInstance._CurrentSelectCol] 
            if juDianData == nil then
                juDianData = JuDianData:new()
                uiInstance._MapTileData[uiInstance._CurrentSelectRow][uiInstance._CurrentSelectCol]  = juDianData
            end
            uiInstance._CurrentJuDianName = uiInstance._TextField_JuDianName:getString()
            juDianData._JuDianName = uiInstance._CurrentJuDianName
            juDianData._JuDianType = uiInstance._CurrentJuDianType
            juDianData._JuDianDiXing = uiInstance._CurrentJuDianDiXing
            juDianData._JuDianBelong = uiInstance._CurrentJuDianBelong
            juDianData._JuDianSuCai = uiInstance._CurrentJuDianSuCai
            juDianData._Row = uiInstance._CurrentSelectRow
            juDianData._Col = uiInstance._CurrentSelectCol
            if juDianData._UIImage == nil then
                juDianData._UIImage = ccui.ImageView:create()
                juDianData._UIImage:setScale9Enabled(false)
            end
            juDianData._UIImage:ignoreContentAdaptWithSize(true)
            local imageName = "meishu/ui/guozhanditu/judianSuCai/" ..uiInstance._ImageList[juDianData._JuDianSuCai]
            juDianData._UIImage:loadTexture(imageName)
            local parentNode = juDianData._UIImage:getParent()
            if parentNode == nil then
                uiInstance._TilePanel:addChild(juDianData._UIImage)
                juDianData._UIImage:ignoreAnchorPointForPosition(false)
                juDianData._UIImage:setAnchorPoint(0.5, 0.5)
                local x = (uiInstance._CurrentSelectCol - 1 ) * uiInstance._TileWidth + 0.5 *  uiInstance._TileWidth
                local y = (uiInstance._CurrentSelectRow - 1 ) * uiInstance._TileHeight + 0.5 *  uiInstance._TileHeight
                print("OnJuDianAdd", x, y, uiInstance._CurrentSelectRow, uiInstance._CurrentSelectCol)
                juDianData._UIImage:setPosition(cc.p(x, y))
            end
            
            uiInstance._Panel_Home:setVisible(false)
        end
    end
end
--据点移除按钮
function UIWorldMapEditor.OnJuDianRemove(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local uiInstance = UISystem:GetUIInstance(UIType.UIType_WorldMapEditor)
        if uiInstance ~= nil then
            local juDianData = uiInstance._MapTileData[uiInstance._CurrentSelectRow][uiInstance._CurrentSelectCol] 
            if juDianData ~= nil then
                if juDianData._UIImage ~= nil then
                    juDianData._UIImage:removeFromParent(true)
                end
                uiInstance._MapTileData[uiInstance._CurrentSelectRow][uiInstance._CurrentSelectCol]  = nil
            end
            uiInstance._Panel_Home:setVisible(false)
        end
    end
end

--路径编辑
function UIWorldMapEditor.OnPathEditCheckBox(sender, eventType)
    local uiInstance = UISystem:GetUIInstance(UIType.UIType_WorldMapEditor)
    if eventType == ccui.CheckBoxEventType.selected then
        uiInstance._IsPathEdit = true
       
        for i = 1, #uiInstance._MapSpriteList do
          -- GrayNode(uiInstance._MapSpriteList[i]) 
            uiInstance._MapSpriteList[i]:setColor(cc.c3b(128,128,128))
        end
        --突显据点
        for row = 1, uiInstance._MapTileCountHeight do
            for col = 1, uiInstance._MapTileCountWidth do

                if uiInstance._MapTileData[row][col] ~= nil then
                    local uiImage = uiInstance._MapTileData[row][col]._UIImage
                    if uiImage ~= nil then
                        uiImage:setColor(cc.c3b(128,128,128))
                    end
                    uiInstance._MapTileTagData[row][col]:setScale(2)
                    uiInstance._MapTileTagData[row][col]:setColor(cc.c4b(255,0,0,255))
                end
            end
        end
        
    elseif eventType == ccui.CheckBoxEventType.unselected then
        uiInstance._IsPathEdit = false
        
        --还原状态
        for i = 1, #uiInstance._MapSpriteList do
            --local defaultShader = cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor_noMVP");
            --uiInstance._MapSpriteList[i]:setGLProgram(defaultShader)
            uiInstance._MapSpriteList[i]:setColor(cc.c3b(255,255,255))
        end
        
        for row = 1, uiInstance._MapTileCountHeight do
            for col = 1, uiInstance._MapTileCountWidth do
                if uiInstance._MapTileData[row][col] ~= nil then
                    local uiImage = uiInstance._MapTileData[row][col]._UIImage
                    if uiImage ~= nil then
                        uiImage:setColor(cc.c3b(255,255,255))
                    end
                    uiInstance._MapTileTagData[row][col]:setScale(1)
                    uiInstance._MapTileTagData[row][col]:setColor(cc.c4b(0,255,0,255))
                end
            end
        end
    end
end

--保存
function UIWorldMapEditor.OnSave(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local uiInstance = UISystem:GetUIInstance(UIType.UIType_WorldMapEditor)
        uiInstance:CalcXiangLinData()
        uiInstance:SaveData()
    end
end

--退出
function UIWorldMapEditor.OnQuit(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        UISystem:CloseUI(UIType.UIType_WorldMapEditor)
    end
end
--寻路
function UIWorldMapEditor.OnFindPathButton(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
         local uiInstance = UISystem:GetUIInstance(UIType.UIType_WorldMapEditor)
        local isVisible = uiInstance._FindPathPanel:isVisible()
        uiInstance._FindPathPanel:setVisible(not isVisible)
    end
end
--开始寻路
function UIWorldMapEditor.OnStartPathButton(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local uiInstance = UISystem:GetUIInstance(UIType.UIType_WorldMapEditor)
        local startID = tonumber(uiInstance._TextFieldFindPathStartID:getString())
        local endID =  tonumber(uiInstance._TextFieldFindPathEndID:getString())
        local closeList = uiInstance._TextFieldCloseJuDian:getString()
        local GuoZhanServerDataManager = GameGlobal:GetGuoZhanServerDataManager() 
        GuoZhanServerDataManager:Init()
        local idList = {}
        if closeList ~= nil then
            local idList = Split(closeList, ",")
            if idList ~= nil then
                for k, v in pairs(idList)do
                    local tableID = tonumber(v)
                    local judianData = GuoZhanServerDataManager:GetJuDianData(tableID)
                    if judianData ~= nil then
                        print("close ", tableID)
                        GuoZhanServerDataManager:ChangeJuDianMapDataTo1(judianData)
                    else
                        print("not close id ", tableID)
                    end
                end
            end
        end
        if startID ~= nil and endID ~= nil then
            local worldMapTableDataManager = GameGlobal:GetDataTableManager():GetWorldMapTableDataManager()
            local startData = worldMapTableDataManager[startID]
            local endData = worldMapTableDataManager[endID]
            if startData == nil then
                print("not have startData", startID)
                return
            end
            if endData == nil then
                print("not have endData", endID)
                return
            end
            local startTime = os.clock()
            GuoZhanServerDataManager:GetMoveCityList(startData.row, startData.col, endData.row, endData.col)
            local endTime = os.clock()
            local useTime = endTime - startTime
            print("findPath useTime(s): ", useTime)
        end
        if closeList ~= nil then
            local idList = Split(closeList, ",")
            if idList ~= nil then
                for k, v in pairs(idList)do
                    local tableID = tonumber(v)
                    local judianData = GuoZhanServerDataManager:GetJuDianData(tableID)
                    if judianData ~= nil then
                        print("restore ", tableID)
                        GuoZhanServerDataManager:ChangeJuDianMapDataToOri(judianData)
                    end
                end
            end
        end
    end
end

return UIWorldMapEditor
