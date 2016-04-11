----
-- 文件名称：UIBuZhenEditor
-- 功能描述：布阵编辑器UI
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-7-28
-- 修改 ：

local buZhenItemResourceName = "UIBuZhenItem.csb"
local stringFormat = string.format
local tableInsert = table.insert
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
require("cocos.ui.GuiConstants")
local image_name_right = "meishu/ui/buzhen/UI_bz_lv.png"
local image_name_wrong = "meishu/ui/buzhen/UI_bz_hong.png"
local image_name_null = "meishu/ui/gg/null.png"
local mathCeil = math.ceil
local mathFloor = math.floor
local UISystem = GameGlobal:GetUISystem()
local CharacterServerDataManager = GameGlobal:GetCharacterServerDataManager()
local TableDataManager = GameGlobal:GetDataTableManager()
local UIBuZhen = class("UIBuZhen", UIBase)
local NetSystem = GameGlobal:GetNetSystem()
--单个CELL武将数目
local ITEMCOUNT_ONECELL = 1
local CELL_SIZE_WIDTH = 120
local CELL_SIZE_HEIGHT = 120
--标识
--空的格子
local TILE_EMPTY = -1
--被占用的格子
local TILE_USED = 0
--放置了单位的格子
local TILE_HAVE_UNIT = 1

--布阵格子
local TILE_ROW_COUNT = 25
local TILE_COL_COUNT = 40
--单位格子
local TILE_UNIT_ROW_COUNT = 5
local TILE_UNIT_COL_COUNT = 7
local ZHENXING_ITEM_CSB_NAME = "csb/ui/UIBuZhenItem.csb"
local selectID = 0

local EditorLevelData = class("EditorLevelData")

function EditorLevelData:ctor()
    --pvp 关卡ID
    self._PVPLevelID = 0
    --pvp 武将List
    self._WuJiangList = 0
    --pvp 武将Array
    self._WuJiangArray = 0
    --pvp 士兵List
    self._SoldierList = 0
    --士兵Array
    self._SoldierArray = 0
    --等级
    self._Level = 0
end

--Tile数据结构
local TileData = class("TileData")
function TileData:ctor()
    --行与列
    self._Row = 0
    self._Col = 0
    --左下坐标
    self._X = 0
    self._Y = 0
    --占用标识(-1:空的  0:)
    self._Tag = TILE_EMPTY
end

-----------------------------------UI 必须的接口 begin-----------------------------------
--构造
function UIBuZhen:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_BuZhenEditor
    self._ResourceName =  "UIBuZhen.csb"
    --TableView
    self._WuJiangTableView = nil
    --网格数据构建
    self._BuZhenTileTable = nil
    --武将数目
    self._WarriorCount = 0
    --武将Cell数目
    self._WarriorCells = 0
    --显示的武将
    self._ShowWarriorIDTable = 0
    --选择框
    self._SelectFrame = nil
    --当前武将索引
    self._CurWarrriorIndex = 0
    --点击的Cell的index
    self._CurCellIdx = 0
    --点击的CellItem的index
    self._CellType = 0
    --当前选中的武将TableID
    self._CurrentSelectWuJiangTableID = 0
    --布阵区域节点
    self._BuZhenNode = nil
    --当前选择的阵形
    self._CurrentZhenXing = 1
    --当前操作的外显Node
    self._CurrentOpNode = nil
    --结束位置
    self._CellEndX = 0
    self._CellEndY = 0
    --是否移动了武将阵形
    self._IsMoveZhenXing = false
    --布阵时选择了新的兵
    self._SelectNewSoldierCallBack = nil
    ----------------编辑器部分
    --关卡选择List
    self._LevelChooseListView = nil
    --PVP关卡列表
    self._PVPLevelList = nil
    --PVP关卡数组
    self._PVPLevelArray = nil
    --士兵武将等级
    self._EditorUnitLevelTextfield = nil
    --信息Label
    self._EditorInfoLabel = nil
    --当前选择的关卡
    self._CurrentSelectLevel = 0
end
--Load
function UIBuZhen:Load()
    UIBase.Load(self)
    --保存退出
    local saveQuitButton = self:GetUIByName("Button_Save")
    if saveQuitButton ~= nil then
        saveQuitButton:addTouchEventListener(self.OnSaveQuitClicked)
        saveQuitButton:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 250), 2)
        saveQuitButton:getTitleRenderer():setPositionY(32)
    end
    --布阵区域
    local imageBuZhenZone = self:GetUIByName("Image_BuZhenZone")
    if imageBuZhenZone ~= nil then
        imageBuZhenZone:addTouchEventListener(self.OnBuZhenZoneEvent)
    end
    --阵形按钮
    for i = 1, 3 do
        local buttonName = stringFormat("Button_ZhenXing_%d", i)
        local button = self:GetUIByName(buttonName)
        if button ~= nil then
            button:setTag(i)
            button:addTouchEventListener(self.OnZhenXingButton)
            button:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 250), 2)
            button:getTitleRenderer():setPositionY(32)
        end
    end
    local zhenXingButtonAuto = self:GetUIByName("Button_ZhenXingAuto")
    zhenXingButtonAuto:addTouchEventListener(self.OnZhenXingButton)
    zhenXingButtonAuto:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 250), 2)
    zhenXingButtonAuto:getTitleRenderer():setPositionY(32)
    --回城按钮
    local huiChengButton = self:GetUIByName("Button_HuiCheng")
    if huiChengButton ~= nil then
        huiChengButton:addTouchEventListener(self.OnHuiChengButton)
    end
    self._BuZhenNode = self:GetUIByName("Image_BuZhenZone")
    --[[
    if self._WuJiangTableView == nil then
        local tableViewBgPanel = self:GetUIByName("Panel_InfoList")
        if tableViewBgPanel ~= nil then
            local contentSize = tableViewBgPanel:getContentSize()
            local offsetX = 0--(contentSize.width - CELL_SIZE_WIDTH) / 2
            local offsetY = 0
            self._WuJiangTableView = CreateTableView(offsetX, offsetY, contentSize.width, contentSize.height, cc.TABLEVIEW_FILL_BOTTOMUP, self)
            tableViewBgPanel:addChild(self._WuJiangTableView)
        end
    end
    ]]--
    self._WuJiangTableView = CreateTableView(40, 57, 200, 415, cc.TABLEVIEW_FILL_BOTTOMUP, self)
    self._RootPanelNode:addChild(self._WuJiangTableView, 0, 0)
    if self._SelectFrame == nil then
        self._SelectFrame = display.newSprite("meishu/ui/gg/UI_gg_hongquan.png", 0, 0)
        self._SelectFrame:retain()
    end
    if self._BuZhenTileTable == nil then
        self._BuZhenTileTable = {}
        for i = 1, TILE_ROW_COUNT do
            if self._BuZhenTileTable[i] == nil then
                self._BuZhenTileTable[i] = {}
            end
            for j = 1, TILE_COL_COUNT do
                local newTile = TileData:new()
                newTile._Row = i
                newTile._Col = j
                newTile._X = (j - 1) * SIZE_ONE_TILE
                newTile._Y = (i - 1) * SIZE_ONE_TILE
                newTile._Tag = TILE_EMPTY
                self._BuZhenTileTable[i][j] = newTile
            end
        end
    end
    --添加编辑器部分
    for i = 2, 3 do
        local buttonName = stringFormat("Button_ZhenXing_%d", i)
        local button = self:GetUIByName(buttonName)
        if button ~= nil then
            button:setVisible(false)
        end
    end
    local data = nil
    local editorUI = cc.CSLoader:createNode("csb/ui/UIBuZhenEditor.csb")
    self._RootPanelNode:addChild(editorUI)
    self._LevelChooseListView = seekNodeByName(editorUI, "ListView_LevelList")
    self._EditorInfoLabel = seekNodeByName(editorUI, "Text_Info")
    self._EditorInfoLabel:setString("Editor")
    self._EditorUnitLevelTextfield = seekNodeByName(editorUI, "TextField_Level")
    self._EditorUnitLevelTextfield:setString("1")
    self._PVPLevelList = {}
    self._PVPLevelArray = {}
    local levelDataManager = TableDataManager:GetLevelDataManager()
    local characterDataManager = TableDataManager:GetCharacterDataManager()
    self._EditorUnitLevelTextfield:addEventListener(UIBuZhen.OnLevelChanged)
    local pvpTableData = TableDataManager:GetPVPDataManager()
    for k, v in pairs(levelDataManager)do
        if v.pvp ~= nil and v.pvp ~= 0 and v.pvp ~= "0" then
            --
            local bingList = v.bingList
           -- local data= SplitSet(bingList)
            
            local pvpData = pvpTableData[v.pvp]
            if pvpData ~= nil then
                bingList = pvpData.pvplist
                data= SplitSet(bingList)
            end

            
            local newData = EditorLevelData:new()
            newData._PVPLevelID = v.pvp
            newData._WuJiangList = {}
            newData._SoldierList = {}
            newData._WuJiangArray = {}
            newData._SoldierArray = {}
            for i = 1, #data do
                local tableID = tonumber(data[i][1])
                local level = tonumber(data[i][2])
                newData._Level = level
                local tableData = characterDataManager[tableID]
                if tableData == nil then
                    print("army.txt tableData nil", tableID)
                end
                if tableData.type == CharacterType.CharacterType_Soldier then --兵
                    if  newData._SoldierList[tableID] == nil then
                        newData._SoldierList[tableID] = tableID
                        table.insert(newData._SoldierArray, tableID)
                    end
                elseif tableData.type ==  CharacterType.CharacterType_Leader then --武将
                    if newData._WuJiangList[tableID] == nil then
                        newData._WuJiangList[tableID] = tableID
                        table.insert(newData._WuJiangArray, tableID)
                    end
                end
            end
            self._PVPLevelList[newData._PVPLevelID] = newData
            tableInsert(self._PVPLevelArray, newData)
        end
    end
    
    if self._LevelChooseListView ~= nil then
        for k, v in pairs(self._PVPLevelArray)do
            local newValue = v
            local newText = ccui.Text:create()
            local showStr = stringFormat("Level:%d",  newValue._PVPLevelID)
            newText:setString(showStr)
            newText:setFontSize(15)
            newText:setTouchEnabled(true)
            newText:setTag(newValue._PVPLevelID)
            
            newText:addTouchEventListener(UIBuZhen.OnLevelTextClicked)
            local custom_item = ccui.Layout:create()
            custom_item:setContentSize(newText:getContentSize())
            custom_item:addChild(newText)
            newText:setPosition(cc.p(custom_item:getContentSize().width / 2.0, custom_item:getContentSize().height / 2.0))
            self._LevelChooseListView:pushBackCustomItem(custom_item)
        end
    end
end

--Unload
function UIBuZhen:Unload()
    UIBase.Unload(self)
    self._WuJiangTableView = nil
    if self._SelectFrame ~= nil then
        self._SelectFrame:release()
        self._SelectFrame = nil
    end
    self._BuZhenNode = nil
    self._EditorUnitLevelTextfield = nil
    self._EditorInfoLabel = nil
end

--open
function UIBuZhen:Open()
    UIBase.Open(self)
    self._SelectNewSoldierCallBack = AddEvent(GameEvent.UIEvent_SoldierSelect, self.OnSoldierSelect)
    self._CurrentSelectLevel = 0
    --初始化
    self:ResetAllTileData()
    self:RefreshWuJiangInfo()
    self._CurrentZhenXing = 1
    self:ShowZhenXing(self._CurrentZhenXing)
    --初始化关卡列表
    --self._LevelChooseListView
end

--close
function UIBuZhen:Close()
    UIBase.Close(self)
    self._ShowWarriorIDTable = nil
    --清除当前阵形的表现Node 
    self:DeleteZhenXingNode(self._CurrentZhenXing)
    self._CurrentSelectLevel = 0
end

-----------------------------------UI 必须的接口 end-----------------------------------
----显示排序
function UIBuZhen:ReSortWarrior()
    if self._ShowWarriorIDTable == 0 then
        return
    end
    table.sort(self._ShowWarriorIDTable, function(a, b)
        local warrior1 = CharacterServerDataManager:GetLeader(a)
        local warrior2 = CharacterServerDataManager:GetLeader(b)

        if warrior1._CurrentState == warrior2._CurrentState then
            if warrior1._CharacterData.quality == warrior2._CharacterData.quality then
                if warrior1._Level > warrior2._Level then
                    return true
                else
                    return false
                end
            else
                return warrior1._CharacterData.quality > warrior2._CharacterData.quality
            end
        else
            return warrior1._CurrentState > warrior2._CurrentState
        end
    end)
end

--刷新左侧武将列表
function UIBuZhen:RefreshWuJiangInfo()
    self._WarriorCount = table.nums(CharacterServerDataManager._OwnLeaderList)
    self._WarriorCells = mathCeil( self._WarriorCount / ITEMCOUNT_ONECELL)
    if CharacterServerDataManager._OwnLeaderList ~= nil then
        self._ShowWarriorIDTable = {}
        for k, v in pairs(CharacterServerDataManager._OwnLeaderList) do
            table.insert(self._ShowWarriorIDTable, k)
        end
    end
    self:ReSortWarrior()
    self._WuJiangTableView:reloadData()
end
--显示某一阵形(根据数据显示阵形)
function UIBuZhen:ShowZhenXing(index)
    local currentZhenXingData = CharacterServerDataManager:GetZhenXingData(index)
    if currentZhenXingData == nil then
        return
    end
    --大格子数据
    for k, v in pairs(currentZhenXingData)do
        local zhenXingData = v
        local row = zhenXingData._ZhenXingStartRow
        local col = zhenXingData._ZhenXingStartCol
        local wuJiangTableID = zhenXingData._WuJiangTableID
        local soldierTableID = zhenXingData._SoldierTableID
        if zhenXingData._TipRootNode == nil then
            local newUIZhenXingNode = cc.CSLoader:createNode(ZHENXING_ITEM_CSB_NAME)
            if soldierTableID ~= nil then
                if self._BuZhenNode ~= nil then
                    self._BuZhenNode:addChild(newUIZhenXingNode)
                    local button = seekNodeByName(newUIZhenXingNode, "Image_ItemZone")
                    if button ~= nil then
                        button:addTouchEventListener(self.OnBuZhenTipEvent)        
                        button:removeAllChildren()
                        self:InitSoldierPosition(button, wuJiangTableID, 0, 0, false)
                        self:InitSoldierPosition(button, soldierTableID, 0, 0, false)
                        button:setTag(wuJiangTableID)
                    end
                    newUIZhenXingNode:setTag(wuJiangTableID)
                    newUIZhenXingNode:retain()
                    zhenXingData._TipRootNode = newUIZhenXingNode
                    local x = (col - 1) * SIZE_ONE_TILE
                    local y = (row - 1) * SIZE_ONE_TILE
                    newUIZhenXingNode:setPosition(x, y)
                end
            end           
        end
        self:UpdateTileOtherData(row, col, TILE_USED)
    end
end
--删除当前阵形的表现,不会销毁数据
function UIBuZhen:DeleteZhenXingNode(zhenXingID)
    local currentZhenXingData = CharacterServerDataManager:GetZhenXingData(zhenXingID)
    if currentZhenXingData == nil then
        return
    end
    for k, v in pairs(currentZhenXingData)do
        if v._TipRootNode ~= nil then
            v._TipRootNode:removeAllChildren()
            v._TipRootNode:release()
            v._TipRootNode = nil
        end
    end
end
--改变阵形
function UIBuZhen:ChangeZhenXing(destZhenXing)
    if self._CurrentZhenXing == destZhenXing then
        return
    end
    --清理格子数据
    self:ResetAllTileData()
    --清理当前阵型表现
    self:DeleteZhenXingNode(self._CurrentZhenXing)
    self._CurrentZhenXing = destZhenXing
    self:ShowZhenXing(destZhenXing)
end

--格子是否合法

--找一空闲的位置给阵形
function UIBuZhen:GetOnePosition()
    local destRow , destCol = 1, 1
    local row = 1
    local isHave = false
    while row <= TILE_ROW_COUNT  do
        local col = 1
        while col <= TILE_COL_COUNT do
            local newTile1 = self._BuZhenTileTable[row][col]
            local newTile2 = self._BuZhenTileTable[row + TILE_UNIT_ROW_COUNT - 1][col + TILE_UNIT_COL_COUNT - 1]
            if newTile1 ~= nil and newTile2 ~= nil then
                if newTile1._Tag == TILE_EMPTY and newTile2._Tag == TILE_EMPTY then
                    destRow = row
                    destCol = col
                    isHave = true
                    break
                end
            end
            col = col + TILE_UNIT_COL_COUNT
        end
        if isHave == true then
            break
        end
        row = row + TILE_UNIT_ROW_COUNT
    end
    print("GetOnePosition", destRow, destCol)
    return mathCeil((destCol- 1 )* SIZE_ONE_TILE), mathCeil((destRow  - 1) * SIZE_ONE_TILE) 
end
--初始化阵形(x, y:该武将未被布阵时的初始化x,y位置 世界位置)
function UIBuZhen:CreateGetZhenXing(wuJiangTableID, x, y)
    print("CreateGetZhenXing ", wuJiangTableID)
    x = mathCeil(x)
    y = mathCeil(y)
    local currentZhenXingData = CharacterServerDataManager._AllZhenXingTable[self._CurrentZhenXing]
    local currentWuJiangZhenXingData = CharacterServerDataManager:GetZhenXingData(self._CurrentZhenXing, wuJiangTableID)
    local isNew = false
    if currentWuJiangZhenXingData == nil then
        isNew = true
        --创建数据
        local defaultSoldierID = CharacterServerDataManager:GetSoldierLess()
        local newZhenXingData = CharacterServerDataManager:CreateZhenXingData()
        newZhenXingData._ZhenXingID = self._CurrentZhenXing
        newZhenXingData._ZhenXingStartRow = -1
        newZhenXingData._ZhenXingStartCol = -1
        newZhenXingData._WuJiangTableID = wuJiangTableID
        newZhenXingData._SoldierTableID = defaultSoldierID
        currentZhenXingData[wuJiangTableID] = newZhenXingData
        currentWuJiangZhenXingData = newZhenXingData
    else
        isNew = false
    end
    if  currentWuJiangZhenXingData._TipRootNode == nil then
        local defaultSoldierID = CharacterServerDataManager:GetSoldierLess()
        --表现相关的
        --x = x - TILE_UNIT_COL_COUNT * SIZE_ONE_TILE / 2
        --y = y - TILE_UNIT_ROW_COUNT * SIZE_ONE_TILE / 2
        local newNode = nil
        newNode = cc.CSLoader:createNode(ZHENXING_ITEM_CSB_NAME)
        local button = seekNodeByName(newNode, "Image_ItemZone")
        if button ~= nil then
            button:addTouchEventListener(self.OnBuZhenTipEvent)        
            button:removeAllChildren()
            self:InitSoldierPosition(button, wuJiangTableID, 0, 0, false)
            self:InitSoldierPosition(button, defaultSoldierID, 0, 0, false)
            button:setTag(wuJiangTableID)
        end
        print("wuJiangTableID" , wuJiangTableID)
        newNode:setTag(wuJiangTableID)
        self._Panel_Center:addChild(newNode)
        --self._BuZhenNode:addChild(newNode)
        local parentNode = newNode:getParent()
        local nodePosition = parentNode:convertToNodeSpace(cc.p(x, y))
        print("nodePosition", nodePosition.x, nodePosition.y)
        newNode:setPosition(nodePosition)   
        newNode:retain()     
        currentWuJiangZhenXingData._TipRootNode = newNode
    end

    local tipNode = currentWuJiangZhenXingData._TipRootNode
    return isNew, tipNode
end

--移除阵形(当前阵形的某武将阵形数据及表现)
function UIBuZhen:DeleteZhenXing(wuJiangTableID)
    local currentWuJiangZhengXingData = CharacterServerDataManager:GetZhenXingData(self._CurrentZhenXing, wuJiangTableID)
    if currentWuJiangZhengXingData ~= nil then
        --格子数据更新
        local curRow = currentWuJiangZhengXingData._ZhenXingStartRow
        local curCol = currentWuJiangZhengXingData._ZhenXingStartCol
        if curRow ~= -1 and curCol ~= -1 then
            print("DeleteZhenXing ", curRow, curCol, curRow + TILE_UNIT_ROW_COUNT, curCol + TILE_UNIT_COL_COUNT)
            self:UpdateTileOtherData(curRow, curCol, TILE_EMPTY)
        end
        --
        CharacterServerDataManager:DeleteZhenXingData(self._CurrentZhenXing, wuJiangTableID)
        --表现删除
        if currentWuJiangZhengXingData._TipRootNode ~= nil then
            currentWuJiangZhengXingData._TipRootNode:removeAllChildren()
            currentWuJiangZhengXingData._TipRootNode:release()
            currentWuJiangZhengXingData._TipRootNode = nil
        end
    end
end
--清某武将老格子数据
function UIBuZhen:ClearOldTileData(currentWuJiangZhengXingData)
    --清空老格子数据
    if currentWuJiangZhengXingData == nil then
        return
    end
    local oldRow = currentWuJiangZhengXingData._ZhenXingStartRow
    local oldCol = currentWuJiangZhengXingData._ZhenXingStartCol
    if oldRow ~= -1 and oldCol ~= -1 then
        for row = oldRow, oldRow + TILE_UNIT_ROW_COUNT do
            for col = oldCol, oldCol + TILE_UNIT_COL_COUNT do
                local tileData = self._BuZhenTileTable[row][col]
                if tileData ~= nil then
                    tileData._Tag = TILE_EMPTY
                end
            end
        end
    end
end

--创建阵形，并更新数据
function UIBuZhen:UpdateZhenXingAtPosition(wuJiangTableID)
    print("UpdateZhenXingAtPosition ", wuJiangTableID)
    local currentWuJiangZhengXingData = CharacterServerDataManager:GetZhenXingData(self._CurrentZhenXing, wuJiangTableID)
    if currentWuJiangZhengXingData == nil then
        return
    end
    local tipNode = currentWuJiangZhengXingData._TipRootNode
    --判定位置是否合法
    if tipNode ~= nil then
        local parentNode = tipNode:getParent()
        if parentNode ~= nil then
            local currentPositionX, currentPositionY = tipNode:getPosition()
           -- print("UpdateZhenXingAtPosition currentPositionX, currentPositionY", currentPositionX, currentPositionY)
            local worldPosition = parentNode:convertToWorldSpace(cc.p(currentPositionX, currentPositionY))
            local buZhenPosition = self._BuZhenNode:convertToNodeSpace(worldPosition)
            local buZhenX = mathFloor(buZhenPosition.x)
            local buZhenY = mathFloor(buZhenPosition.y)
            --print("UpdateZhenXingAtPosition buZhen ", buZhenX, buZhenY, buZhenPosition.x, buZhenPosition.y)
            --清空老格子数据
            self:UpdateTileOtherData(currentWuJiangZhengXingData._ZhenXingStartRow, currentWuJiangZhengXingData._ZhenXingStartCol, TILE_EMPTY)
            if  buZhenX >= -SIZE_ONE_TILE and buZhenX <= TILE_COL_COUNT  * SIZE_ONE_TILE - TILE_UNIT_COL_COUNT * SIZE_ONE_TILE + SIZE_ONE_TILE
                and buZhenY >= -SIZE_ONE_TILE and buZhenY <= TILE_ROW_COUNT  * SIZE_ONE_TILE - TILE_UNIT_ROW_COUNT * SIZE_ONE_TILE + SIZE_ONE_TILE then
                --合法位置，校正位置到格子内
                local buZhenRow = mathCeil(buZhenY / SIZE_ONE_TILE) + 1
                local buZhenCol = mathCeil(buZhenX / SIZE_ONE_TILE) + 1
                print("UpdateZhenXingAtPosition buZhen ", buZhenX, buZhenY, buZhenRow, buZhenCol)
                if buZhenRow <= 0 then
                    buZhenRow = 1
                end
                if buZhenRow >= TILE_ROW_COUNT - TILE_UNIT_ROW_COUNT + 1 then
                   buZhenRow = TILE_ROW_COUNT - TILE_UNIT_ROW_COUNT + 1
                end
                if buZhenCol <= 0 then
                    buZhenCol = 1
                end
                if buZhenCol >= TILE_COL_COUNT - TILE_UNIT_COL_COUNT + 1 then
                   buZhenCol = TILE_COL_COUNT - TILE_UNIT_COL_COUNT + 1
                end
                --当前格子是否有单位
                local tileData =  self._BuZhenTileTable[buZhenRow][buZhenCol] 
                if tileData ~= nil then
                    if  tileData._Tag ~= TILE_EMPTY then
                        print("have unit", buZhenRow, buZhenCol)
                        self:DeleteZhenXing(wuJiangTableID)
                        return
                    end
                end
                --右上格子
                tileData =  self._BuZhenTileTable[buZhenRow + TILE_UNIT_ROW_COUNT - 1 ][buZhenCol + TILE_UNIT_COL_COUNT - 1] 
                if tileData ~= nil then
                    if  tileData._Tag ~= TILE_EMPTY then
                        self:DeleteZhenXing(wuJiangTableID)
                        return 
                    end
                end
                --右下格子
                tileData = self._BuZhenTileTable[buZhenRow][buZhenCol + TILE_UNIT_COL_COUNT - 1] 
                if tileData ~= nil then
                    if  tileData._Tag ~= TILE_EMPTY then
                        self:DeleteZhenXing(wuJiangTableID)
                        return 
                    end
                end
                --左上
                tileData = self._BuZhenTileTable[buZhenRow + TILE_UNIT_ROW_COUNT - 1][buZhenCol] 
                if tileData ~= nil then
                    if  tileData._Tag ~= TILE_EMPTY then
                        self:DeleteZhenXing(wuJiangTableID)
                        return 
                    end
                end

                currentWuJiangZhengXingData._ZhenXingStartRow = buZhenRow
                currentWuJiangZhengXingData._ZhenXingStartCol = buZhenCol
                local newBuZhenX = (buZhenCol - 1) * SIZE_ONE_TILE
                local newBuZhenY = (buZhenRow - 1) * SIZE_ONE_TILE
                print("buZhen row col ", buZhenRow, buZhenCol, newBuZhenX, newBuZhenY)
                local currentPosition = cc.p(newBuZhenX, newBuZhenY)
                currentWuJiangZhengXingData._InitX = newBuZhenX
                currentWuJiangZhengXingData._InitY = newBuZhenY
                local worldPosition  = self._BuZhenNode:convertToWorldSpace(currentPosition)
                local newPosition = parentNode:convertToNodeSpace(worldPosition)
                --print("UpdateZhenXingAtPosition", newBuZhenX, newBuZhenY, )
                tipNode:setPosition(newPosition)
                --更新新格子数据
                self:UpdateTileOtherData(buZhenRow, buZhenCol, TILE_USED)
            else
                --位置不在布阵区域
                print("invalid position ........")
                self:DeleteZhenXing(wuJiangTableID)
            end    
        end
    end

end

--当前格子是否有单位
function UIBuZhen:IsHaveUnitInTile(wuJiangTableID)
    local currentWuJiangZhengXingData = CharacterServerDataManager:GetZhenXingData(self._CurrentZhenXing, wuJiangTableID)
    if currentWuJiangZhengXingData == nil then
        return
    end
    local tipNode = currentWuJiangZhengXingData._TipRootNode
    --判定位置是否合法
    if tipNode ~= nil then
        local parentNode = tipNode:getParent()
        if parentNode ~= nil then
            local currentPositionX, currentPositionY = tipNode:getPosition()
           
            local worldPosition = parentNode:convertToWorldSpace(cc.p(currentPositionX, currentPositionY))
            local buZhenPosition = self._BuZhenNode:convertToNodeSpace(worldPosition)
            local buZhenX = mathFloor(buZhenPosition.x)
            local buZhenY = mathFloor(buZhenPosition.y)
            print("---IsHaveUnitInTile start ", buZhenX, buZhenY)
            if  buZhenX >= -SIZE_ONE_TILE  and buZhenX <= TILE_COL_COUNT  * SIZE_ONE_TILE - TILE_UNIT_COL_COUNT * SIZE_ONE_TILE + SIZE_ONE_TILE
                and buZhenY >= -SIZE_ONE_TILE  and buZhenY <= TILE_ROW_COUNT  * SIZE_ONE_TILE - TILE_UNIT_ROW_COUNT * SIZE_ONE_TILE + SIZE_ONE_TILE  then
                --合法位置，校正位置到格子内
                local buZhenRow = mathCeil(buZhenY / SIZE_ONE_TILE)
                local buZhenCol = mathCeil(buZhenX / SIZE_ONE_TILE)
                if buZhenRow <= 0 then
                    buZhenRow = 1
                end
                if buZhenRow >= TILE_ROW_COUNT - TILE_UNIT_ROW_COUNT then
                   -- buZhenRow = TILE_ROW_COUNT - TILE_UNIT_ROW_COUNT
                end
                if buZhenCol <= 0 then
                    buZhenCol = 1
                end
                if buZhenCol >= TILE_COL_COUNT - TILE_UNIT_COL_COUNT then
                   -- buZhenCol = TILE_COL_COUNT - TILE_UNIT_COL_COUNT
                end

                local buZhenRealX = (buZhenCol - 1 )* SIZE_ONE_TILE
                local buZhenRealY = (buZhenRow - 1) * SIZE_ONE_TILE
                buZhenRealX = mathCeil(buZhenRealX)
                buZhenRealY = mathCeil(buZhenRealY)
                local realWorldPosition = self._BuZhenNode:convertToWorldSpace(cc.p(buZhenRealX, buZhenRealY))
                local tipNodeParentPosition = parentNode:convertToNodeSpace(realWorldPosition)
                buZhenRealX = mathCeil(tipNodeParentPosition.x)
                buZhenRealY = mathCeil(tipNodeParentPosition.y)
                
                --当前格子是否有单位
                local tileData =  self._BuZhenTileTable[buZhenRow][buZhenCol] 
                if tileData ~= nil then
                    if  tileData._Tag ~= TILE_EMPTY then
                       -- print("--IsHaveUnitInTile  AA ", buZhenRow, buZhenCol, buZhenRealX, buZhenRealY)
                        return true, buZhenRealX, buZhenRealY
                    end
                end
                --右上格子
                tileData =  self._BuZhenTileTable[buZhenRow + TILE_UNIT_ROW_COUNT - 1 ][buZhenCol + TILE_UNIT_COL_COUNT - 1] 
                if tileData ~= nil then
                    if  tileData._Tag ~= TILE_EMPTY then
                        print("--IsHaveUnitInTile  BB ", buZhenRow, buZhenCol, buZhenRealX, buZhenRealY)
                        return true, buZhenRealX, buZhenRealY
                    end
                end
                --右下格子
                tileData = self._BuZhenTileTable[buZhenRow][buZhenCol + TILE_UNIT_COL_COUNT - 1] 
                if tileData ~= nil then
                    if  tileData._Tag ~= TILE_EMPTY then
                        --print("--IsHaveUnitInTile  CC ", buZhenRow, buZhenCol, buZhenRealX, buZhenRealY)
                        return true, buZhenRealX, buZhenRealY
                    end
                end
                --左上
                tileData = self._BuZhenTileTable[buZhenRow + TILE_UNIT_ROW_COUNT - 1][buZhenCol] 
                if tileData ~= nil then
                    if  tileData._Tag ~= TILE_EMPTY then
                        --print("--IsHaveUnitInTile  DD ", buZhenRow, buZhenCol, buZhenRealX, buZhenRealY)
                        return true, buZhenRealX, buZhenRealY
                    end
                end
                print("IsHaveUnitInTile false ",  buZhenRealX, buZhenRealY, buZhenRow, buZhenCol)
                return false, buZhenRealX, buZhenRealY
            else
                local buZhenRow = mathCeil(buZhenY / SIZE_ONE_TILE)
                local buZhenCol = mathCeil(buZhenX / SIZE_ONE_TILE)
                --[[
                if buZhenRow <= 0 then
                    buZhenRow = 1
                end

                if buZhenRow >= TILE_ROW_COUNT - TILE_UNIT_ROW_COUNT then
                    buZhenRow = TILE_ROW_COUNT - TILE_UNIT_ROW_COUNT
                end
              
                if buZhenCol <= 0 then
                    buZhenCol = 1
                end
              
                if buZhenCol >= TILE_COL_COUNT - TILE_UNIT_COL_COUNT then
                    buZhenCol = TILE_COL_COUNT - TILE_UNIT_COL_COUNT
                end
                ]]--
                local buZhenRealX = (buZhenCol - 1) * SIZE_ONE_TILE
                local buZhenRealY = (buZhenRow - 1) * SIZE_ONE_TILE
                buZhenRealX = mathCeil(buZhenRealX)
                buZhenRealY = mathCeil(buZhenRealY)
                local realWorldPosition = self._BuZhenNode:convertToWorldSpace(cc.p(buZhenRealX, buZhenRealY))
                local tipNodeParentPosition = parentNode:convertToNodeSpace(realWorldPosition)
                buZhenRealX = mathCeil(tipNodeParentPosition.x)
                buZhenRealY = mathCeil(tipNodeParentPosition.y)
               -- print("--IsHaveUnitInTile  over", buZhenX, buZhenY, buZhenRow, buZhenCol, buZhenRealX, buZhenRealY)
                return true, buZhenRealX, buZhenRealY
            end    
        end
    end
end

function UIBuZhen:GetTilePosition()


end
--设置武将士兵位置
function UIBuZhen:InitSoldierPosition(parentNode, soldierTableID, startTileRow, startTileCol, isUpdateData)
    if parentNode == nil then
        return
    end
    local armyDataTable = TableDataManager:GetCharacterDataManager()
    local armyData =  armyDataTable[soldierTableID]
    local tileYZone = TILE_UNIT_ROW_COUNT * SIZE_ONE_TILE
    if armyData ~= nil then
        if armyData.type == CharacterType.CharacterType_Leader then
            local newNode = cc.CSLoader:createNode(GetWarriorCsbPath(armyData.resName))
            local newTimeline = cc.CSLoader:createTimeline(GetWarriorCsbPath(armyData.resName))
            newNode:runAction(newTimeline)
            newTimeline:play("Walk", true)
            local newTileRow =  ZHEN_XING_WUJIANG_POS[1][1]
            local newTileCol =  ZHEN_XING_WUJIANG_POS[1][2]
            local newX = (newTileCol - 1 ) * SIZE_ONE_TILE
            local newY = (newTileRow - 1) * SIZE_ONE_TILE
            newNode:setPosition(newX, newY)
            newNode:setName("wuJiangNode")
            newNode:setTag(soldierTableID)
            parentNode:addChild(newNode, tileYZone - newY)
            if isUpdateData == true then
                self:UpdateTileData(startTileRow + newTileRow, startTileCol + newTileCol, TILE_HAVE_UNIT)
            end
        else
            --根据所占人口布局
            local people = armyData.people
            if people == 1 then
                for row = 1, 5 do
                    for col = 1, 4 do
                        local newNode = cc.CSLoader:createNode(GetSoldierCsbPath(armyData.resName))
                        local newTimeline = cc.CSLoader:createTimeline(GetSoldierCsbPath(armyData.resName))
                        newNode:runAction(newTimeline)
                        newTimeline:play("Walk", true)
                        local newTileRow = ZHEN_XING_PEO_1[row][col][1]
                        local newTileCol = ZHEN_XING_PEO_1[row][col][2]
                        local newX = (newTileCol - 1) * SIZE_ONE_TILE
                        local newY = (newTileRow - 1) * SIZE_ONE_TILE
                        newNode:setPosition(newX, newY)
                        local nodeName = stringFormat("soldierNode_%d_%d", row, col)
                        newNode:setName(nodeName)
                        newNode:setTag(soldierTableID)
                        parentNode:addChild(newNode, tileYZone - newY)
                        if isUpdateData == true then
                            self:UpdateTileData(startTileRow + newTileRow, startTileCol + newTileCol, TILE_HAVE_UNIT)
                        end
                    end
                end
            elseif people == 5 then
                for row = 1, 2 do
                    for col = 1, 2 do
                        local newNode = cc.CSLoader:createNode(GetSoldierCsbPath(armyData.resName))
                        local newTimeline = cc.CSLoader:createTimeline(GetSoldierCsbPath(armyData.resName))
                        newNode:runAction(newTimeline)
                        newTimeline:play("Walk", true)
                        local newTileRow = ZHEN_XING_PEO_5[row][col][1]
                        local newTileCol = ZHEN_XING_PEO_5[row][col][2]
                        local newX = (newTileCol - 1) * SIZE_ONE_TILE
                        local newY = (newTileRow - 1) * SIZE_ONE_TILE
                        newNode:setPosition(newX, newY)
                        local nodeName = stringFormat("soldierNode_%d_%d", row, col)
                        newNode:setName(nodeName)
                        newNode:setTag(soldierTableID)
                        parentNode:addChild(newNode, tileYZone - newY)
                        if isUpdateData == true then
                            self:UpdateTileData(startTileRow + newTileRow, startTileCol + newTileCol, TILE_HAVE_UNIT)
                        end
                    end
                end
            elseif people == 10 then
                for row = 1, 2 do
                    local newNode = cc.CSLoader:createNode(GetSoldierCsbPath(armyData.resName))
                    local newTimeline = cc.CSLoader:createTimeline(GetSoldierCsbPath(armyData.resName))
                    newNode:runAction(newTimeline)
                    newTimeline:play("Walk", true)
                    local newTileRow = ZHEN_XING_PEO_10[row][1]
                    local newTileCol = ZHEN_XING_PEO_10[row][2]
                    local newX = (newTileCol - 1) * SIZE_ONE_TILE
                    local newY = (newTileRow - 1) * SIZE_ONE_TILE
                    newNode:setPosition(newX, newY)
                    local nodeName = stringFormat("soldierNode_%d_%d", newTileRow, newTileCol)
                    newNode:setName(nodeName)
                    newNode:setTag(soldierTableID)
                    parentNode:addChild(newNode, tileYZone - newY)
                    if isUpdateData == true then
                        self:UpdateTileData(startTileRow + newTileRow, startTileCol + newTileCol, TILE_HAVE_UNIT)
                    end
                end
            end
        end
    end
end
--将某个大格子内其它格子置为无兵状态
function UIBuZhen:UpdateTileOtherData(bigTileRow, bigTileCol, tag)
    if bigTileRow == -1 or bigTileCol == -1 then
        return
    end
    print("UpdateTileOtherData", bigTileRow, bigTileCol, tag)
    for i = bigTileRow, bigTileRow + TILE_UNIT_ROW_COUNT - 1 do
        for j = bigTileCol, bigTileCol + TILE_UNIT_COL_COUNT - 1 do
            local tileData = self._BuZhenTileTable[i][j]
            if tileData ~= nil then
                tileData._Tag = tag
            end
        end
    end
end
--设置Tile数据
function UIBuZhen:UpdateTileData(tileRow, tileCol, tag)
    if tileRow <= 0 or tileCol <= 0 then
        return
    end
    if tileRow > TILE_ROW_COUNT or tileCol > TILE_COL_COUNT then
        return
    end
    local newTile = self._BuZhenTileTable[tileRow][tileCol]
    newTile._Tag = tag
end

--重置所有Tile的数据,置为未布置兵状态
function UIBuZhen:ResetAllTileData()
    for i = 1, TILE_ROW_COUNT do
        for j = 1, TILE_COL_COUNT do
            local newTile = self._BuZhenTileTable[i][j]
            if newTile ~= nil then
                newTile._Tag = TILE_EMPTY
            end
        end
    end
end

--替换兵
function UIBuZhen:ChangeSoldier(currentWuJiangTableID, soldierTableID)

    local currentWuJiangZhenXingData = CharacterServerDataManager:GetZhenXingData(self._CurrentZhenXing, currentWuJiangTableID)
    if currentWuJiangZhenXingData == nil then
        return
    end
    if currentWuJiangZhenXingData._TipRootNode == nil then
        return
    end
    print("UIBuZhen:ChangeSoldier", currentWuJiangTableID, soldierTableID)
    local button = seekNodeByName(currentWuJiangZhenXingData._TipRootNode, "Image_ItemZone")
    button:removeAllChildren()
    self:InitSoldierPosition(button, currentWuJiangTableID, 0, 0, false)
    self:InitSoldierPosition(button, soldierTableID, 0, 0, false)
    currentWuJiangZhenXingData._SoldierTableID = soldierTableID
end
--
function UIBuZhen:SetZhenXingShowImage(currentWuJiangTableID, isVisible)
    local currentWuJiangZhenXingData = CharacterServerDataManager:GetZhenXingData(self._CurrentZhenXing, currentWuJiangTableID)
    if currentWuJiangZhenXingData == nil then
        return
    end
    if currentWuJiangZhenXingData._TipRootNode == nil then
        return
    end
    local button = seekNodeByName(currentWuJiangZhenXingData._TipRootNode, "Image_ItemZone")
    if isVisible == false then
        button:loadTexture(image_name_null)
    end
end
--布阵区域的处理
function UIBuZhen:OnBuZhenZone(sender, eventType)

end

--处理阵形按钮点击事件(3个阵型按钮)
function UIBuZhen:OnZhenXingButtonEvent(sender, eventType)
    if eventType == ccui.TouchEventType.began then

    elseif eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
        self:ChangeZhenXing(tag)
    end

end

--处理UI的布阵事件
function UIBuZhen:OnUIBuZhenEvent(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        local beginPositon = sender:getTouchBeganPosition()
        self._CurrentSelectWuJiangTableID = sender:getTag()
        print("OnUIBuZhenEvent _CurrentSelectWuJiangTableID" , self._CurrentSelectWuJiangTableID)
        local currentData = CharacterServerDataManager:GetZhenXingData(self._CurrentZhenXing, self._CurrentSelectWuJiangTableID)
        self:UpdateTileOtherData(currentData._ZhenXingStartRow, currentData._ZhenXingStartCol, TILE_EMPTY)
        self._IsMoveZhenXing = false
        --计算世界的初始偏移量
        self._MoveZhenXingOffsetPosition = cc.p(0, 0)
        if currentData._TipRootNode ~= nil then
            local parentNode = currentData._TipRootNode:getParent()
            if parentNode ~= nil then
                local curX, curY = currentData._TipRootNode:getPosition()
                local worldPosition = parentNode:convertToWorldSpace(cc.p(curX, curY))
                self._MoveZhenXingOffsetPosition = cc.pSub(worldPosition, beginPositon)
            end
        end
    elseif eventType == ccui.TouchEventType.ended then
        local worldPosition = sender:getTouchEndPosition()

        if self._IsMoveZhenXing == false then
            UISystem:OpenUI(UIType.UIType_SoldierSelectListUI)
            local selectSoldierUIInstance = UISystem:GetUIInstance(UIType.UIType_SoldierSelectListUI)
            if selectSoldierUIInstance ~= nil then
                selectSoldierUIInstance:SetCurrentSelectSoldier(self:GetCurrentSoldierID())
            end
        else
            -- print("OnUIBuZhenEvent ended", self._CurrentSelectWuJiangTableID)
            if self._CurrentSelectWuJiangTableID ~= nil and self._CurrentSelectWuJiangTableID ~= 0 then
                self:UpdateZhenXingAtPosition(self._CurrentSelectWuJiangTableID)
            end
        end
        self:SetZhenXingShowImage(self._CurrentSelectWuJiangTableID, false)
    elseif eventType == ccui.TouchEventType.canceled then
        local worldPosition = sender:getTouchEndPosition()
        -- print("OnUIBuZhenEvent canceled", self._CurrentSelectWuJiangTableID)
        if self._CurrentSelectWuJiangTableID ~= nil and self._CurrentSelectWuJiangTableID ~= 0 then
            self:UpdateZhenXingAtPosition(self._CurrentSelectWuJiangTableID)
        end
        self:SetZhenXingShowImage(self._CurrentSelectWuJiangTableID, false)
    elseif eventType == ccui.TouchEventType.moved then
        self._IsMoveZhenXing = true
        local movePosition =  sender:getTouchMovePosition()
        if self._CurrentSelectWuJiangTableID ~= nil and self._CurrentSelectWuJiangTableID ~= 0 then
            local currentData = CharacterServerDataManager:GetZhenXingData(self._CurrentZhenXing, self._CurrentSelectWuJiangTableID)
            if currentData ~= nil then
                local opNode = currentData._TipRootNode
                local parentNode = opNode:getParent()
                if parentNode ~= nil then
                    dump(self._MoveZhenXingOffsetPosition)
                    movePosition = cc.pAdd(movePosition, self._MoveZhenXingOffsetPosition)
                    local buZhenUIPosition =  parentNode:convertToNodeSpace(movePosition)
                    opNode:setPosition(buZhenUIPosition)
                    local button = seekNodeByName(opNode, "Image_ItemZone")
                    local isHave, realX, realY = self:IsHaveUnitInTile(self._CurrentSelectWuJiangTableID)
                    realX = mathCeil(realX)
                    realY = mathCeil(realY)
                    opNode:setPosition(cc.p(realX, realY))
                    -- print("isHave ", isHave, button, realX, realY)
                    if isHave == true then
                        if button ~= nil then
                            button:loadTexture(image_name_wrong)
                        end 
                    else
                        if button ~= nil then
                            button:loadTexture(image_name_right)
                        end 
                    end
                end
            end
        end
    end
end


-----------------------------------TableView相关begin-----------------------------------

function UIBuZhen:OnTableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    print("idx begin ", idx, cell)
    local layout
    if not cell then
        cell = cc.TableViewCell:new()
        cell:retain()
    end
    cell:removeAllChildren(true)
    layout = cc.CSLoader:createNode("csb/ui/WarriorItem.csb")
    layout:retain()
    -- setSwallowTouches false
    local panel = seekNodeByName(layout, "Panel_1")
    panel:setSwallowTouches(false)
    local button = seekNodeByName(panel, "Button_2")
    button:addTouchEventListener(self.TableViewItemTouchEvent)
    button:setSwallowTouches(false)
    seekNodeByName(panel, "Image_2"):setSwallowTouches(false)
    seekNodeByName(panel, "Image_1"):setSwallowTouches(false)
    seekNodeByName(panel, "Image_4"):setSwallowTouches(false)
    layout:setPosition(cc.p(0, 0))
    cell:addChild(layout, 0, idx)
    print("idx end", idx, cell)
    self:InitCell(cell, idx, layout)
    return cell

end


function UIBuZhen:InitCell(cell, idx, layout)
    if cell == nil then
        return
    end
    local panel = seekNodeByName(layout, "Panel_1")
    local head1 = seekNodeByName(panel, "Image_2")
    local name1 = seekNodeByName(panel, "Text_1")
    local level = seekNodeByName(panel, "Text_2")
    local flag1 = seekNodeByName(panel, "Flag")
    seekNodeByName(panel, "Button_2"):setColor(cc.c3b(250, 250, 250))
    local uiInstance = UISystem:GetUIInstance(UIType.UIType_BuZhenEditor)
    flag1:setLocalZOrder(100)
    
    if idx + 1 <= self._WarriorCount then
        local warrior = CharacterServerDataManager:GetLeader(self._ShowWarriorIDTable[idx + 1])
        print("UIBuZhen:InitCell ", self._ShowWarriorIDTable[idx + 1])
        local head1Name = warrior._CharacterData["headName"]
        head1:setVisible(true)
        head1:loadTexture(GetWarriorHeadPath(head1Name), UI_TEX_TYPE_LOCAL)
        name1:setString(warrior._CharacterData["name"])
        level:setString("LV" .. warrior._Level)
        name1:setTextColor(GetQualityColor(warrior._CharacterData["quality"]))
        flag1:setVisible(false)
        local flagF = uiInstance:JudgeWarriorZhen(self._ShowWarriorIDTable[idx + 1])
        if flagF == 1 then
            seekNodeByName(layout, "Image_4"):setVisible(true)
            --            ccui.Helper:seekWidgetByName(panel, "Button_2"):setColor(cc.c3b(82, 48, 48))
        end
        if selectID == idx then
            seekNodeByName(panel, "Image_1"):loadTexture("meishu/ui/gg/UI_gg_hongquan.png")
        else
            seekNodeByName(panel, "Image_1"):loadTexture("meishu/ui/gg/null.png")
        end
    end
end

function UIBuZhen:JudgeWarriorZhen(warriorID)
    local uiInstance = UISystem:GetUIInstance(UIType.UIType_BuZhenEditor)
    local currentData = CharacterServerDataManager._AllZhenXingTable[uiInstance._CurrentZhenXing]
    --    local currentZhenXingData = CharacterServerDataManager:GetZhenXingData(uiInstance._CurrentZhenXing)
    local flag = 0
    for k, v in pairs(currentData)do
        local zhenXingData = v
        if zhenXingData ~= nil then
            local wuJiangTableID = zhenXingData._WuJiangTableID
            if warriorID == wuJiangTableID then
                flag = 1
                break
            end
        end
    end
    return flag
end

function UIBuZhen:TableViewItemTouchEvent(value)
    print("TableViewItemTouchEvent", value)
    local eventType = value
    if type(value) == "table" then
        eventType = value.eventType
    end
    if eventType == ccui.TouchEventType.began then


    elseif eventType == ccui.TouchEventType.ended then
        local uiInstance = UISystem:GetUIInstance(UIType.UIType_BuZhenEditor)
        --        local tag = self:getTag()
        --        uiInstance._CellType = tag
        --        uiInstance._SelectFrame:setVisible(true)
        --        uiInstance._SelectFrame:removeFromParent(false)
        --        uiInstance._SelectFrame:setAnchorPoint(0.5, 0.5)
        --        uiInstance._SelectFrame:ignoreAnchorPointForPosition(false)
        --        self:getParent():addChild(uiInstance._SelectFrame)
        --        uiInstance._SelectFrame:setPosition(self:getPositionX() - 70, self:getPositionY())
        --        uiInstance._CellEndX = self:getTouchEndPosition().x
        --        uiInstance._CellEndY = self:getTouchEndPosition().y

        local tag = self:getTag()
        uiInstance._CellType = tag
        uiInstance._SelectFrame:setVisible(false)
        uiInstance._SelectFrame:removeFromParent(false)
        uiInstance._SelectFrame:setAnchorPoint(0.5, 0.5)
        uiInstance._SelectFrame:ignoreAnchorPointForPosition(false)
        self:getParent():addChild(uiInstance._SelectFrame)
        uiInstance._SelectFrame:setPosition(self:getPositionX() - 70, self:getPositionY())
        uiInstance._CurButton = self
    elseif eventType == ccui.TouchEventType.moved then

    end
end

---TableView事件回调
function UIBuZhen.ScrollViewDidScroll(view)
    local uiInstance = UISystem:GetUIInstance(UIType.UIType_BuZhenEditor)
    if uiInstance ~= nil then

    end
end

function UIBuZhen.CellSizeForTable(view, idx)
    print("CellSizeForTable", idx)
    return CELL_SIZE_WIDTH, CELL_SIZE_HEIGHT
end


function UIBuZhen.TableCellAtIndex(view, idx)
    print("TableCellAtIndex", idx)
    local uiInstance = UISystem:GetUIInstance(UIType.UIType_BuZhenEditor)
    if uiInstance ~= nil then
        return uiInstance:OnTableCellAtIndex(view, idx)
    end
    return nil
end

function UIBuZhen.NumberOfCellsInTableView()
    local uiInstance = UISystem:GetUIInstance(UIType.UIType_BuZhenEditor)
    if uiInstance ~= nil then
        return uiInstance._WarriorCells
    end
end


-----------------------------------TableView相关 end-----------------------------------
--
local cellIndex = 0
----点击,左侧武将列表武将点击
function UIBuZhen.TableCellTouched(view, cell)
    local uiInstance = UISystem:GetUIInstance(UIType.UIType_BuZhenEditor)
    if uiInstance ~= nil then
        local idx = nil
        if cell == nil then
            idx = cellIndex
        else
            idx = cell:getIdx()
        end
        uiInstance._CurCellIdx = idx
        uiInstance._CurWarrriorIndex = idx * ITEMCOUNT_ONECELL + uiInstance._CellType
        -- uiInstance._CurCellIdx = cell:getIdx()
        -- uiInstance._CurWarrriorIndex = cell:getIdx() * ITEMCOUNT_ONECELL + uiInstance._CellType
        local tableID = uiInstance._ShowWarriorIDTable[uiInstance._CurCellIdx + uiInstance._CellType]
        uiInstance._CurrentSelectWuJiangTableID = tableID
        --
        --当前武将未上阵时，判断上阵的武将数目
        local currentWuJiangZhengXingData = CharacterServerDataManager:GetZhenXingData(uiInstance._CurrentZhenXing, tableID)
        if currentWuJiangZhengXingData == nil  then
            local currentWuJiangCount = CharacterServerDataManager:GetCurrentZhenXingWuJiangCount(uiInstance._CurrentZhenXing)
            local maxWuJiangCount = 3 
            local TechnologyManager = GameGlobal:GetServerTechnologyDataManager()
            --            local techData = TechnologyManager:GetTechnologyByType(TechnologyType.PVP_PeopleCount)
            local techData = TechnologyManager:GetTechMaxPvpById()
            if techData ~= nil then
                --                maxWuJiangCount = maxWuJiangCount + techData.val
                --数据获取多1
                maxWuJiangCount = maxWuJiangCount + techData.val - 1
                print(maxWuJiangCount, techData.val)
            end
            if currentWuJiangCount >= maxWuJiangCount then
                --提示信息
               -- local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                --UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_bz_wuJiang_OverMax))
                --return
            end
            uiInstance._WarriorNum = currentWuJiangCount + 1
            --uiInstance:setDuiWuText()
        end

        print("TableCellTouched tableID", tableID)
        local destX, destY = uiInstance:GetOnePosition()
        --print(destX, destY)
        if uiInstance._BuZhenNode ~= nil then
            local worldPosition = uiInstance._BuZhenNode:convertToWorldSpace(cc.p(destX, destY))
            destX = worldPosition.x 
            destY = worldPosition.y 
        end
        --local isNew, tipNode = uiInstance:CreateGetZhenXing(tableID, uiInstance._CellEndX, uiInstance._CellEndY)
        print(destX, destY)
        local isNew, tipNode = uiInstance:CreateGetZhenXing(tableID, destX, destY)
        if isNew == true then
            uiInstance:UpdateZhenXingAtPosition(tableID)
        end
        selectID = idx
    end
    uiInstance._WuJiangTableView:reloadData()
end

--布阵区域
function UIBuZhen.OnBuZhenZoneEvent(sender, eventType)
    print("OnBuZhenZoneEvent", eventType)
    local uiInstance = UISystem:GetUIInstance(UIType.UIType_BuZhenEditor)
    uiInstance:OnBuZhenZone(sender, eventType)
end

--阵型一二三
function UIBuZhen.OnZhenXingButton(sender, eventType)
    local uiInstance = UISystem:GetUIInstance(UIType.UIType_BuZhenEditor)
    uiInstance:OnZhenXingButtonEvent(sender, eventType)
end

------------------------
---士兵选择
function UIBuZhen.OnSoldierSelect(event)
    print("event.selectSoldierID", event._usedata.selectSoldierID)
    local soldierTableID = event._usedata.selectSoldierID
    local uiInstance = UISystem:GetUIInstance(UIType.UIType_BuZhenEditor)
    uiInstance:ChangeSoldier(uiInstance._CurrentSelectWuJiangTableID, soldierTableID)
end
--布阵提示点击
function UIBuZhen.OnBuZhenTipEvent(sender, eventType)
    local uiInstance = UISystem:GetUIInstance(UIType.UIType_BuZhenEditor)
    uiInstance:OnUIBuZhenEvent(sender, eventType)
end
--确认保存(编辑器下的特殊处理)
function UIBuZhen.OnSaveOKClick()
    --[[
    print("send save packet")
    --发送数据包
    local newBuZhenPacket = NetSystem:CreateToSendPacket(PacketDefine.PacketDefine_BuZhenPVPSave_Send)
    if newBuZhenPacket ~= nil then
        --填充数据
        newBuZhenPacket:ResetData()
        for i = 1, 3 do
            local currentData = CharacterServerDataManager._AllZhenXingTable[i]
            if currentData ~= nil then
                newBuZhenPacket._SaveData[i]._Name = tostring(i)
                local currentIndex = 1
                for k, v in pairs(currentData)do
                    newBuZhenPacket._SaveData[i]._Data[currentIndex]._WuJiangTableID = v._WuJiangTableID
                    newBuZhenPacket._SaveData[i]._Data[currentIndex]._SoldierTableID = v._SoldierTableID
                    newBuZhenPacket._SaveData[i]._Data[currentIndex]._TileRow = v._ZhenXingStartRow
                    newBuZhenPacket._SaveData[i]._Data[currentIndex]._TileCol = v._ZhenXingStartCol
                    print("OnSaveOKClick ", i, currentIndex, v._WuJiangTableID)
                    currentIndex = currentIndex + 1
                end
            end 
        end
    end
    ]]--
    --存储到TableDataManager._PVPLevelConfigDataManager
    --保存当前关卡的数据
    local uiInstance = UISystem:GetUIInstance(UIType.UIType_BuZhenEditor)
    if uiInstance._CurrentSelectLevel ~= 0 then
        local currentZhenXingData = CharacterServerDataManager:GetZhenXingData(1)
        local saveZhenXingData = TableDataManager._PVPLevelConfigDataManager[uiInstance._CurrentSelectLevel]
        local newSaveZhenXingData = {}
        local currentIndex = 0
        for k, v in pairs(currentZhenXingData)do
            currentIndex = currentIndex + 1
            local newZhenXingData = {}
            uiInstance:CopyZhenXingData(v, newZhenXingData)
            local unitlevel = tonumber(uiInstance._EditorUnitLevelTextfield:getString())
            if unitlevel == nil then
                unitlevel = 1
            end
            newZhenXingData._Level = unitlevel
            newSaveZhenXingData[currentIndex] = newZhenXingData
        end
        TableDataManager._PVPLevelConfigDataManager[uiInstance._CurrentSelectLevel] = newSaveZhenXingData
    end
    --数据保存
    local fileName = "src/main/DataPool/PVPLevelConfig.lua"
    local file = io.open(fileName, "wb")
    SaveTable(file,"TableDataManager._PVPLevelConfigDataManager", TableDataManager._PVPLevelConfigDataManager)
    io.close(file)
    
    UISystem:CloseUI(UIType.UIType_BuZhenEditor)
    
    CharacterServerDataManager:RestoreBuZhenEditor()


end
--退出点击
function UIBuZhen.OnSaveQuitClicked(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        --当前上阵武将数目判定
        local uiInstance = UISystem:GetUIInstance(UIType.UIType_BuZhenEditor)
        local currentWuJiangCount = CharacterServerDataManager:GetCurrentZhenXingWuJiangCount(uiInstance._CurrentZhenXing)
        local maxWuJiangCount = 3
        local TechnologyManager = GameGlobal:GetServerTechnologyDataManager()
        local techData = TechnologyManager:GetTechnologyByType(TechnologyType.PVP_PeopleCount)
        if techData ~= nil then
            maxWuJiangCount = maxWuJiangCount + techData.val
        end
        if currentWuJiangCount < maxWuJiangCount then
            local tip =  UISystem:OpenUI(UIType.UIType_TipUI)
            tip:RegisteDelegate(UIBuZhen.OnSaveOKClick, 1, GameGlobal:GetTipDataManager(UI_bz_wuJiang_NoMax))
            return
        end
        UIBuZhen.OnSaveOKClick()
    end

end
--回城确认点击
function UIBuZhen.OnHuiChengOkClick()
    UISystem:CloseUI(UIType.UIType_BuZhenEditor)
    CharacterServerDataManager:RestoreZhenXingData()
end
--回城点击
function UIBuZhen.OnHuiChengButton(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        --提示信息
        local tip =  UISystem:OpenUI(UIType.UIType_TipUI)
        tip:RegisteDelegate(UIBuZhen.OnHuiChengOkClick, 1, GameGlobal:GetTipDataManager(UI_bz_NoSaveNoQuit))
    end
end

-- 获取当前的士兵ID，用于换兵时的对号
function UIBuZhen:GetCurrentSoldierID()
    local currentZhenXingData = CharacterServerDataManager:GetZhenXingData(self._CurrentZhenXing)
    if currentZhenXingData == nil then
        return
    end
    local soldierID = nil
    local zhenXingData = currentZhenXingData[self._CurrentSelectWuJiangTableID]
    if zhenXingData ~= nil then
        soldierID = zhenXingData._SoldierTableID
    end
    return soldierID         
end
----------------------------------------编辑器  逻辑部分begin-----------------------------------------------------
--纯数据拷贝
function UIBuZhen:CopyZhenXingData(src, dest)
    dest._ZhenXingStartRow = src._ZhenXingStartRow
    dest._ZhenXingStartCol = src._ZhenXingStartCol
    dest._WuJiangTableID = src._WuJiangTableID
    dest._SoldierTableID = src._SoldierTableID
    
end
--选择关卡
function UIBuZhen:OnSelectLevel(level)
    local currentLevelData = self._PVPLevelList[level]
    if currentLevelData == nil then
        return
    end
    if level ==  self._CurrentSelectLevel then
        return
    end
    DispatchEvent(GameEvent.GameEvent_CommonTest, {levelID = level})
    --保存上一关卡的数据
    if self._CurrentSelectLevel ~= 0 then
        local currentZhenXingData = CharacterServerDataManager:GetZhenXingData(1)
        local saveZhenXingData = TableDataManager._PVPLevelConfigDataManager[self._CurrentSelectLevel]
        local currentUnitLevel = 1
        local currentUILevel = tonumber(self._EditorUnitLevelTextfield:getString())
        if currentUILevel ~= nil then
            currentUnitLevel = currentUILevel
        end
        local newSaveZhenXingData = {}
        local currentIndex = 0
        for k, v in pairs(currentZhenXingData)do
            currentIndex = currentIndex + 1
            local newZhenXingData = {}
            self:CopyZhenXingData(v, newZhenXingData)
            newZhenXingData._Level = currentUnitLevel
            newSaveZhenXingData[currentIndex] = newZhenXingData
        end
        TableDataManager._PVPLevelConfigDataManager[self._CurrentSelectLevel] = newSaveZhenXingData
    end
    --
    --清除当前阵形的表现Node 
    self:DeleteZhenXingNode(self._CurrentZhenXing)
    CharacterServerDataManager._AllZhenXingTable[self._CurrentZhenXing] = {}
    
    self._EditorInfoLabel:setString("Level:" .. tostring(level))

    --构造阵型数据
    local unitLevel = 1
    local zhenXingData = TableDataManager._PVPLevelConfigDataManager[level]
    if zhenXingData ~= nil then
        for k, v in  pairs(zhenXingData)do
            local zhenXingData = CharacterServerDataManager:CreateZhenXingData()
            self:CopyZhenXingData(v, zhenXingData)
            if v._Level == nil then
                v._Level = 1
            end
            unitLevel = v._Level
            CharacterServerDataManager._AllZhenXingTable[self._CurrentZhenXing][v._WuJiangTableID] = zhenXingData
        end
    else
        --从PVP 关卡配置表初始化
       local currentData =  self._PVPLevelList[level] 
       if currentData ~= nil then
            unitLevel =  currentData._Level
       end
    end
    --显示等级
    self._EditorUnitLevelTextfield:setString(tostring(unitLevel))
    --构造关卡武将数据
    local wuJiangCount = #currentLevelData._WuJiangArray
    CharacterServerDataManager._OwnLeaderList = {}
    CharacterServerDataManager._OwnLeaderLen = wuJiangCount
    dump(currentLevelData._WuJiangArray)
    print("wuJiangCount ", wuJiangCount)
    for i = 1, wuJiangCount do
        local tableID = currentLevelData._WuJiangArray[i]
        local newWuJiangData =  CharacterServerDataManager:CreateLeader(tableID)
        newWuJiangData._Level = unitLevel
        local characterDataManager = TableDataManager:GetCharacterDataManager()
        local armyTableData = characterDataManager[tableID]
        newWuJiangData._Attack = armyTableData.attack +  armyTableData.attackup * (unitLevel - 1)
        newWuJiangData._Hp = armyTableData.hp + armyTableData.hpup * (unitLevel - 1)
    end
    --构造关卡小兵数据
    CharacterServerDataManager._OwnSolderList = {}
    local soldierCount = #currentLevelData._SoldierArray
    for i = 1, soldierCount do
        local tableID = currentLevelData._SoldierArray[i]
        local newSoldierData = CharacterServerDataManager:CreateSoldier(tableID)
        newSoldierData._Level = unitLevel
        local characterDataManager = TableDataManager:GetCharacterDataManager()
        local armyTableData = characterDataManager[tableID]
        newSoldierData._Attack = armyTableData.attack +  armyTableData.attackup * (unitLevel - 1)
        newSoldierData._Hp = armyTableData.hp + armyTableData.hpup * (unitLevel - 1)
    end

    self:ResetAllTileData()
    self:RefreshWuJiangInfo()
    self._CurrentZhenXing = 1
    self:ShowZhenXing(self._CurrentZhenXing)
    self._CurrentSelectLevel = level
end
--设置当前单位等级
function UIBuZhen:SetCurrentUnitLevel(level)
    local zhenXingData = TableDataManager._PVPLevelConfigDataManager[self._CurrentSelectLevel]
    for k, v in  pairs(zhenXingData)do
        v._Level = level
    end
    --CharacterServerDataManager
    local characterDataManager = TableDataManager:GetCharacterDataManager()

    for k, v in pairs(CharacterServerDataManager._OwnLeaderList)do
        if v ~= nil then
            v._Level = level
            local armyTableData = characterDataManager[v._TableID]
            v._Attack = armyTableData.attack +  armyTableData.attackup * (level - 1)
            v._Hp = armyTableData.hp + armyTableData.hpup * (level - 1)
        end
    end
    --CharacterServerDataManager
    for k, v in pairs(CharacterServerDataManager._OwnSolderList)do
        if v ~= nil then
            v._Level = level
            local armyTableData = characterDataManager[v._TableID]
            v._Attack = armyTableData.attack +  armyTableData.attackup * (level - 1)
            v._Hp = armyTableData.hp + armyTableData.hpup * (level - 1)
        end
    end
end
--关卡选择点击
function UIBuZhen.OnLevelTextClicked(sender, eventType)
   if eventType == ccui.TouchEventType.ended then
     print("OnLevelTextClicked", sender:getTag())
     local uiInstance = UISystem:GetUIInstance(UIType.UIType_BuZhenEditor)
        uiInstance:OnSelectLevel(sender:getTag())
   end
end
--等级改变
function UIBuZhen.OnLevelChanged(sender, eventType)
    local uiInstance = UISystem:GetUIInstance(UIType.UIType_BuZhenEditor)
    local currentLevel = tonumber(uiInstance._EditorUnitLevelTextfield:getString())
    if currentLevel ~= nil then
        uiInstance:SetCurrentUnitLevel(currentLevel)
    end
end
----------------------------------------编辑器  逻辑部分end-----------------------------------------------------
return UIBuZhen
