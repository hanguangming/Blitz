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

local UIBuZhen = class("UIBuZhen", UIBase)
local NetSystem = GameGlobal:GetNetSystem()
--单个CELL武将数目
local ITEMCOUNT_ONECELL = 1
local CELL_SIZE_WIDTH = 120
local CELL_SIZE_HEIGHT = 85
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
    self._Type = UIType.UIType_BuZhen
    self._ResourceName =  "UIBuZhen.csb"
end
--Load
function UIBuZhen:Load()
    UIBase.Load(self)
    --保存退出
    local saveQuitButton = self:GetWigetByName("Button_Save")
    if saveQuitButton ~= nil then
        saveQuitButton:addTouchEventListener(handler(self, self.OnSaveQuitClicked))
        saveQuitButton:getTitleRenderer():enableOutline(cc.c4b(253, 206, 58, 250), 1)
        saveQuitButton:getTitleRenderer():setPositionY(38)
    end

    self._SelectFrameImage = {}
    for i = 1, 3 do
        self._SelectFrameImage[i] = self:GetWigetByName("Image_"..(i + 3))
    end

    local buttonTitle = self:GetWigetByName("Button_2")
    buttonTitle:getTitleRenderer():enableOutline(cc.c4b(110, 43, 17, 250), 1)
    buttonTitle:getTitleRenderer():setPositionY(26)
    self._DuiWuText = self:GetWigetByName("Text_1")

    --阵型1，阵型2，阵型3按钮注册点击调用
    for i = 1, 3 do
        local buttonName = string.format("Button_ZhenXing_%d", i)
        local button = self:GetWigetByName(buttonName)
        assert(button)
        button:addTouchEventListener(function(_, eventType)
            if eventType == ccui.TouchEventType.ended then
                self:switchFormation(i)
            end
        end)
    end
    --自动布阵
    local zhenXingButtonAuto = self:GetWigetByName("Button_ZhenXingAuto")
    if zhenXingButtonAuto ~= nil then
        zhenXingButtonAuto:addTouchEventListener(handler(self, self.OnDeployAuto))
    end
    --回城按钮
    local huiChengButton = self:GetWigetByName("Button_HuiCheng")
    if huiChengButton ~= nil then
        huiChengButton:addTouchEventListener(handler(self, self.OnHuiChengButton))
    end
    self._BuZhenNode = self:GetWigetByName("Image_BuZhenZone")
    self._WuJiangTableView = CreateTableView_(42, 60, 200, 425, cc.TABLEVIEW_FILL_BOTTOMUP, self)
    self._RootPanelNode:addChild(self._WuJiangTableView, 0, 0)

    self._GridImage = self:GetWigetByName("Image_1")
end

function UIBuZhen:init()
    --当前选中的武将TableID
    self._CurrentSelectWuJiangTableID = 0

    -- 当前是几号阵型？
    self._CurFormationIndex = 1

    --是否移动了武将阵形
    self._IsMoveZhenXing = false

    self._MoveZhenXingOffsetPosition = cc.p(0, 0)

    --阵型改变标识
    self._ZhenXingChangeIdentify = {[1] = 0, [2] = 0, [3] = 0}
    
    self._ShowWarriorIDTable = {}
    
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

--open
function UIBuZhen:Open()
    UIBase.Open(self)

    self:init()

    self._SelectFrame = display.newSprite("meishu/ui/gg/UI_gg_hongquan.png", 0, 400, {scale9 = true, capInsets = cc.rect(40, 40, 20, 20), rect = cc.rect(0, 0, 89, 89)})
    self._SelectFrame:setPreferredSize(cc.size(85, 83))
    self._SelectFrame:setPosition(50, 35)
    self._SelectFrame:retain()
    
    self:checkAndRepair()

    --初始化
    self:ResetAllTileData()
    self:RefreshWuJiangInfo()
    
    self:ShowZhenXing(self._CurFormationIndex)
    self._GridImage:setVisible(false)
    self:refreshCurWarriorAmount()
    self:addEvent(GameEvent.GameEvent_UIBuZhen_SoldierSelect, function(target, event)
        self:ChangeSoldier(self._CurrentSelectWuJiangTableID, event._usedata.selectSoldierID)
    end)
end

--close
function UIBuZhen:Close()
    UIBase.Close(self)

    removeNodeAndRelease(self._SelectFrame, true)
    --清除当前阵形的表现Node 
    self:DeleteZhenXingNode(self._CurFormationIndex)
end

--修改左下角退伍显示人数
function UIBuZhen:refreshCurWarriorAmount()
    self._DuiWuText:setString("队伍：".. self:getCurWorriorAmount() .. "/" ..self:getMaxWorriorAmount())
end

-- 检查和修复布阵数据不同步错误
function UIBuZhen:checkAndRepair()
    for i = 1, 3 do
        self:deleteFormationError(i)
    end
end

function UIBuZhen:deleteFormationError(formationIndex)
    local formationData = CharacterServerDataManager:GetZhenXingData(formationIndex) or {}
    for warriorId, _ in pairs(formationData) do
        if not CharacterServerDataManager._OwnLeaderList[warriorId] then
            CharacterServerDataManager:DeleteZhenXingData(formationIndex, warriorId)
        end
    end
end

function UIBuZhen:ReSortWarrior()
    table.sort(self._ShowWarriorIDTable, function(a, b)
        local warrior1 = CharacterServerDataManager:GetLeader(a)
        local warrior2 = CharacterServerDataManager:GetLeader(b)
        if warrior1._CurrentState == warrior2._CurrentState then
        if warrior1._CharacterData.quality == warrior2._CharacterData.quality then
            if warrior1._Level == warrior2._Level then
                if a == b then
                    return false
                else
                    return a > b
                end
            else
                return warrior1._Level > warrior2._Level
            end
        else
            if warrior1._CharacterData.quality == 0 then
                if warrior2._CharacterData.quality == 1 or warrior2._CharacterData.quality == 2 then
                    return true
                else
                    return false
                end 
            end
            if warrior2._CharacterData.quality == 0 then
                if warrior1._CharacterData.quality == 1 or warrior1._CharacterData.quality == 2 then
                    return false
                else
                    return true
                end 
            end
            return warrior1._CharacterData.quality > warrior2._CharacterData.quality
        end   
        else
            return warrior1._CurrentState > warrior2._CurrentState
        end    
    end)
end

function UIBuZhen:getCurWorriorAmount()
    local formationData = CharacterServerDataManager:GetZhenXingData(self._CurFormationIndex) or {}
    return table.nums(formationData)
end

function UIBuZhen:getMaxWorriorAmount()
   local amount = GetGlobalData()._TechnologyList[3][2]
    if tonumber(amount) == 0 then
       amount = 3
    else
       amount = amount - 4
    end
    return amount
end

--刷新左侧武将列表
function UIBuZhen:RefreshWuJiangInfo()
    local amount = table.nums(CharacterServerDataManager._OwnLeaderList)
    self._WarriorCells = mathCeil( amount / ITEMCOUNT_ONECELL)
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
    local formationData = CharacterServerDataManager:GetZhenXingData(index)
    if formationData == nil then
        return
    end
    -- 切换到当前阵型按钮视图显示
    for i = 1, 3 do
        if i == index then
            self._SelectFrameImage[i]:setVisible(true)
        else
            self._SelectFrameImage[i]:setVisible(false)
        end
    end
    --大格子数据
    for _, zhenxingData in pairs(formationData) do
        local row = zhenxingData._ZhenXingStartRow
        local col = zhenxingData._ZhenXingStartCol

        if zhenxingData._TipRootNode == nil then
            local newUIZhenXingNode = self:addArmyFormationNode(zhenxingData._WuJiangTableID, zhenxingData._SoldierTableID)
            zhenxingData._TipRootNode = newUIZhenXingNode
            
            local x = mathCeil((col - 1) * SIZE_ONE_TILE)
            local y = mathCeil((row - 1) * SIZE_ONE_TILE)
            newUIZhenXingNode:setPosition(x, y)

            self._BuZhenNode:addChild(newUIZhenXingNode)
            self._BuZhenNode:reorderChild(newUIZhenXingNode, -y + 1000)        
        end
        self:UpdateTileOtherData(row, col, TILE_USED)
    end
    self:refreshCurWarriorAmount()
end

function UIBuZhen:addArmyFormationNode(warriorId, soldierId)
    local formationNode = cc.CSLoader:createNode(ZHENXING_ITEM_CSB_NAME)
    local button = seekNodeByName(formationNode, "Image_ItemZone")
    if button ~= nil then
        button:addTouchEventListener(handler(self,self.OnBuZhenTipEvent))        
        button:removeAllChildren()
        self:InitSoldierPosition(button, warriorId, 0, 0, false)
        self:InitSoldierPosition(button, soldierId, 0, 0, false)
        button:setTag(warriorId)
        button:loadTexture(image_name_null)
    end
    formationNode:setTag(warriorId)
    formationNode:retain()
    return formationNode
end

--删除当前阵形的表现,不会销毁数据
function UIBuZhen:DeleteZhenXingNode(zhenXingID)
    local currentZhenXingData = CharacterServerDataManager:GetZhenXingData(zhenXingID)
    if currentZhenXingData == nil then
        return
    end
    for _, data in pairs(currentZhenXingData)do
        self:DeleteWuJiangNode(data)
    end
end
--改变阵形
function UIBuZhen:switchFormation(formationIndex)
    if self._CurFormationIndex == formationIndex then
        return
    end

    --清理格子数据
    self:ResetAllTileData()
    --清理当前阵型表现
    self:DeleteZhenXingNode(self._CurFormationIndex)

    self._CurFormationIndex = formationIndex
    self:ShowZhenXing(formationIndex)
    self._WuJiangTableView:reloadData()
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
            --当前格子是否有单位
            local newTile1 =  self._BuZhenTileTable[row][col] 
            --右上格子
            local newTile2 = self._BuZhenTileTable[row + TILE_UNIT_ROW_COUNT - 1 ][col + TILE_UNIT_COL_COUNT - 1] 
            --右下格子
            local newTile3 = self._BuZhenTileTable[row][col + TILE_UNIT_COL_COUNT - 1] 
            --左上
            local newTile4 = self._BuZhenTileTable[row + TILE_UNIT_ROW_COUNT - 1][col] 
            if newTile1 ~= nil and newTile2 ~= nil and newTile3 ~= nil and newTile4 ~= nil then
                if newTile1._Tag == TILE_EMPTY and newTile2._Tag == TILE_EMPTY and newTile3._Tag == TILE_EMPTY and newTile4._Tag == TILE_EMPTY then
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
    return (destCol- 1 )* SIZE_ONE_TILE , (destRow  - 1) * SIZE_ONE_TILE 
end
--初始化阵形(x, y:该武将未被布阵时的初始化x,y位置 世界位置)
function UIBuZhen:CreateGetZhenXing(wuJiangTableID, x, y)
    x = mathCeil(x)
    y = mathCeil(y)
    
    local currentZhenXingData = CharacterServerDataManager._AllZhenXingTable[self._CurFormationIndex]
    local zhenXingData = CharacterServerDataManager:GetZhenXingData(self._CurFormationIndex, wuJiangTableID)
    local isNew = false
    if zhenXingData == nil or not CharacterServerDataManager:GetLeader(wuJiangTableID) then
        isNew = true
        --创建数据
        local defaultSoldierID = CharacterServerDataManager:GetSoldierLess()
        local newZhenXingData = CharacterServerDataManager:CreateZhenXingData()
        newZhenXingData._ZhenXingID = self._CurFormationIndex
        newZhenXingData._ZhenXingStartRow = -1
        newZhenXingData._ZhenXingStartCol = -1
        newZhenXingData._WuJiangTableID = wuJiangTableID
        newZhenXingData._SoldierTableID = defaultSoldierID
        currentZhenXingData[wuJiangTableID] = newZhenXingData
        zhenXingData = newZhenXingData
    else
        isNew = false
    end
    if  zhenXingData._TipRootNode == nil then
        local defaultSoldierID = CharacterServerDataManager:GetSoldierLess()
        
        local newUIZhenXingNode = self:addArmyFormationNode(wuJiangTableID, defaultSoldierID)
        zhenXingData._TipRootNode = newUIZhenXingNode
        
        self._Panel_Center:addChild(newUIZhenXingNode)
        local posX, posY = newUIZhenXingNode:getPosition()
        self._Panel_Center:reorderChild(newUIZhenXingNode, -posY + 1000)
        local parentNode = newUIZhenXingNode:getParent()
        local nodePosition = parentNode:convertToNodeSpace(cc.p(x, y))

        newUIZhenXingNode:setPosition(nodePosition.x, nodePosition.y) 
    end

    local tipNode = zhenXingData._TipRootNode
    return isNew, tipNode
end

--移除阵形(当前阵形的某武将阵形数据及表现)
function UIBuZhen:DeleteWuJiang(formationIndex, wuJiangTableID)
    local currentWuJiangZhengXingData = CharacterServerDataManager:GetZhenXingData(formationIndex, wuJiangTableID)
    if currentWuJiangZhengXingData ~= nil then
        --格子数据更新
        local curRow = currentWuJiangZhengXingData._ZhenXingStartRow
        local curCol = currentWuJiangZhengXingData._ZhenXingStartCol
        if curRow ~= -1 and curCol ~= -1 then
            print("DeleteZhenXing ", curRow, curCol, curRow + TILE_UNIT_ROW_COUNT, curCol + TILE_UNIT_COL_COUNT)
            self:UpdateTileOtherData(curRow, curCol, TILE_EMPTY)
        end
        --
        CharacterServerDataManager:DeleteZhenXingData(formationIndex, wuJiangTableID)
        --表现删除
        self:DeleteWuJiangNode(currentWuJiangZhengXingData)
    end

    self:refreshCurWarriorAmount()
    self._WuJiangTableView:reloadData()
end

function UIBuZhen:DeleteWuJiangNode(data)
    if data._TipRootNode ~= nil and not tolua.isnull(data._TipRootNode) then
        data._TipRootNode:removeAllChildren()
        data._TipRootNode:release()
        data._TipRootNode = nil
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
    local currentWuJiangZhengXingData = CharacterServerDataManager:GetZhenXingData(self._CurFormationIndex, wuJiangTableID)
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
            --统一使用mathCeil
            local buZhenX = mathCeil(buZhenPosition.x)
            local buZhenY = mathCeil(buZhenPosition.y)          
            --print("UpdateZhenXingAtPosition buZhen ", buZhenX, buZhenY, buZhenPosition.x, buZhenPosition.y)
            --清空老格子数据
            self:UpdateTileOtherData(currentWuJiangZhengXingData._ZhenXingStartRow, currentWuJiangZhengXingData._ZhenXingStartCol, TILE_EMPTY)
            if buZhenX >= -SIZE_ONE_TILE and buZhenX <= TILE_COL_COUNT  * SIZE_ONE_TILE - TILE_UNIT_COL_COUNT * SIZE_ONE_TILE + SIZE_ONE_TILE
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
                        self:DeleteWuJiang(self._CurFormationIndex, wuJiangTableID)
                        return
                    end
                end
                --右上格子
                tileData =  self._BuZhenTileTable[buZhenRow + TILE_UNIT_ROW_COUNT - 1 ][buZhenCol + TILE_UNIT_COL_COUNT - 1] 
                if tileData ~= nil then
                    if  tileData._Tag ~= TILE_EMPTY then
                        self:DeleteWuJiang(self._CurFormationIndex, wuJiangTableID)
                        return 
                    end
                end
                --右下格子
                tileData = self._BuZhenTileTable[buZhenRow][buZhenCol + TILE_UNIT_COL_COUNT - 1] 
                if tileData ~= nil then
                    if  tileData._Tag ~= TILE_EMPTY then
                        self:DeleteWuJiang(self._CurFormationIndex, wuJiangTableID)
                        return 
                    end
                end
                --左上
                tileData = self._BuZhenTileTable[buZhenRow + TILE_UNIT_ROW_COUNT - 1][buZhenCol] 
                if tileData ~= nil then
                    if  tileData._Tag ~= TILE_EMPTY then
                        self:DeleteWuJiang(self._CurFormationIndex, wuJiangTableID)
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
                self:DeleteWuJiang(self._CurFormationIndex, wuJiangTableID)
            end    
        end
    end
end

--当前格子是否有单位
function UIBuZhen:IsHaveUnitInTile(wuJiangTableID)
    local currentWuJiangZhengXingData = CharacterServerDataManager:GetZhenXingData(self._CurFormationIndex, wuJiangTableID)
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
            local buZhenX = mathCeil(buZhenPosition.x)
            local buZhenY = mathCeil(buZhenPosition.y)
            print("---IsHaveUnitInTile start ", buZhenX, buZhenY)
            if  buZhenX >= -SIZE_ONE_TILE  and buZhenX <= TILE_COL_COUNT  * SIZE_ONE_TILE - TILE_UNIT_COL_COUNT * SIZE_ONE_TILE + SIZE_ONE_TILE
                and buZhenY >= -SIZE_ONE_TILE  and buZhenY <= TILE_ROW_COUNT  * SIZE_ONE_TILE - TILE_UNIT_ROW_COUNT * SIZE_ONE_TILE + SIZE_ONE_TILE  then
                --合法位置，校正位置到格子内
                --(此处位置的合法性与函数UpdateZhenXingAtPosition的判断方法不统一，所以加1)
                local buZhenRow = mathCeil(buZhenY / SIZE_ONE_TILE) + 1
                local buZhenCol = mathCeil(buZhenX / SIZE_ONE_TILE) + 1
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

--设置武将士兵位置
function UIBuZhen:InitSoldierPosition(parentNode, soldierTableID, startTileRow, startTileCol, isUpdateData)
    if parentNode == nil then
        return
    end

    local armyDataTable = GameGlobal:GetCharacterDataManager()
    local armyData =  armyDataTable[soldierTableID]
    local tileYZone = TILE_UNIT_ROW_COUNT * SIZE_ONE_TILE

    if armyData ~= nil then
        local type = armyData.type
        local type1 = CharacterType.CharacterType_Leader
        if tonumber(type) == tonumber(type1) then
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
                        local nodeName = string.format("soldierNode_%d_%d", row, col)
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
                        local nodeName = string.format("soldierNode_%d_%d", row, col)
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
                    local nodeName = string.format("soldierNode_%d_%d", newTileRow, newTileCol)
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

    local currentWuJiangZhenXingData = CharacterServerDataManager:GetZhenXingData(self._CurFormationIndex, currentWuJiangTableID)
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
    self._ZhenXingChangeIdentify[self._CurFormationIndex] = 1
end
--
function UIBuZhen:SetZhenXingShowImage(currentWuJiangTableID, isVisible)
    local currentWuJiangZhenXingData = CharacterServerDataManager:GetZhenXingData(self._CurFormationIndex, currentWuJiangTableID)
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

function UIBuZhen:TouchEndedIsHave()
    if self._CurrentSelectWuJiangTableID ~= nil and self._CurrentSelectWuJiangTableID ~= 0 then
        --获取当前武将在该位置是否可布阵，若不可布阵，则判断武将是否在布阵区域中，若不在则移除当前武将，若在则当前武将回到起始位置
        local isHave, realX, realY = self:IsHaveUnitInTile(self._CurrentSelectWuJiangTableID)
        --不可布阵
        if isHave == true then
            local currentData = CharacterServerDataManager:GetZhenXingData(self._CurFormationIndex, self._CurrentSelectWuJiangTableID)
            if currentData ~= nil then
                --在布阵区域中
                --找到边界点
                local rightX = TILE_COL_COUNT  * SIZE_ONE_TILE - TILE_UNIT_COL_COUNT * SIZE_ONE_TILE + SIZE_ONE_TILE
                local topY = TILE_ROW_COUNT  * SIZE_ONE_TILE - TILE_UNIT_ROW_COUNT * SIZE_ONE_TILE + SIZE_ONE_TILE
                local leftX = -SIZE_ONE_TILE
                local bottomY = -SIZE_ONE_TILE
                --获取当前武将阵型坐标
                local tipNode = currentData._TipRootNode
                local parentNode = tipNode:getParent()
                local currentPositionX, currentPositionY = tipNode:getPosition()
                local worldPosition = parentNode:convertToWorldSpace(cc.p(currentPositionX, currentPositionY))
                local buZhenPosition = self._BuZhenNode:convertToNodeSpace(worldPosition)
                local buZhenX = mathCeil(buZhenPosition.x)
                local buZhenY = mathCeil(buZhenPosition.y)
                realX = buZhenX
                realY = buZhenY
                if realX >= leftX and realX <= rightX and realY >= bottomY and realY <= topY then
                    local row = currentData._ZhenXingStartRow
                    local col = currentData._ZhenXingStartCol
                    local x = (col - 1) * SIZE_ONE_TILE
                    local y = (row - 1) * SIZE_ONE_TILE
                    --进行坐标转换
                    local realWorldPosition = self._BuZhenNode:convertToWorldSpace(cc.p(x, y))
                    local tipNodeParentPosition = parentNode:convertToNodeSpace(realWorldPosition)
                    x = mathCeil(tipNodeParentPosition.x)
                    y = mathCeil(tipNodeParentPosition.y)
                    tipNode:setPosition(cc.p(x, y))
                end
            end
        end
        self:UpdateZhenXingAtPosition(self._CurrentSelectWuJiangTableID)
    end
end

-----------------------------------TableView相关begin-----------------------------------

function UIBuZhen:InitCell(cell, idx, layout)
    if cell == nil then
        return
    end
    local panel = seekNodeByName(layout, "Panel_1")
    local head1 = seekNodeByName(panel, "Image_2")
    local name1 = seekNodeByName(panel, "Text_1")

    local judgeShangZhen = seekNodeByName(panel, "Image_4")
    local battleImage = seekNodeByName(panel, "Image_Battle")
    local headDiColorImage = seekNodeByName(panel, "Image_35")
    local level = seekNodeByName(panel, "Text_2")
    local trainImage = seekNodeByName(panel, "Image_TrainIcon")
    local TypeImage = seekNodeByName(panel, "Image_Type")

    if idx + 1 <= table.nums(CharacterServerDataManager._OwnLeaderList) then
        local warrior = CharacterServerDataManager:GetLeader(self._ShowWarriorIDTable[idx + 1])
        local head1Name = warrior._CharacterData["headName"]
        head1:setVisible(true)
        head1:loadTexture(GetWarriorHeadPath(head1Name), UI_TEX_TYPE_LOCAL)
        name1:setString(warrior._CharacterData["name"])
        local flagF = self:JudgeWarriorZhen(self._ShowWarriorIDTable[idx + 1])
        if flagF == 1 then
            judgeShangZhen:setVisible(true)
        end

        battleImage:setVisible(false)
        headDiColorImage:loadTexture(GetHeadColorImage(warrior._CharacterData["quality"]))
        level:setString("lv"..warrior._Level)
        TypeImage:loadTexture(GetSoldierProperty(warrior._CharacterData["soldierType"]))
        trainImage:setVisible(false)
        if warrior._Time ~= 0 then
            trainImage:setVisible(true)
        end
    end
end

function UIBuZhen:JudgeWarriorZhen(warriorID)
    local currentData = CharacterServerDataManager._AllZhenXingTable[self._CurFormationIndex]
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

function UIBuZhen:onWarriorCellClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self._CellType = sender:getTag()
        self._SelectFrame:setVisible(false)
        self._SelectFrame:removeFromParent(false)
        self._SelectFrame:setAnchorPoint(0.5, 0.5)
        self._SelectFrame:ignoreAnchorPointForPosition(false)
        self._SelectFrame:setPosition(sender:getPositionX() - 70, sender:getPositionY())

        sender:getParent():addChild(self._SelectFrame)
    end
end

function UIBuZhen:CellSizeForTable(view, idx)
    return CELL_SIZE_WIDTH, CELL_SIZE_HEIGHT
end


function UIBuZhen:TableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    local layout
    if not cell then
        cell = cc.TableViewCell:new()
    end
    cell:removeAllChildren(true)
    layout = cc.CSLoader:createNode("csb/ui/WarriorItem.csb")
    -- setSwallowTouches false
    local panel = seekNodeByName(layout, "Panel_1")
    panel:setSwallowTouches(false)
    local button = seekNodeByName(panel, "Button_2")
    button:addTouchEventListener(handler(self, self.onWarriorCellClick))
    button:setSwallowTouches(false)
    seekNodeByName(panel, "Image_2"):setSwallowTouches(false)
    seekNodeByName(panel, "Image_1"):setSwallowTouches(false)
    seekNodeByName(panel, "Image_4"):setSwallowTouches(false)
    layout:setPosition(cc.p(0, 0))
    cell:addChild(layout, 0, idx)
    self:InitCell(cell, idx, layout)
    return cell
end

function UIBuZhen:NumberOfCellsInTableView()
    return self._WarriorCells
end
-----------------------------------TableView相关 end-----------------------------------

local cellIndex = 0
----点击,左侧武将列表武将点击
function UIBuZhen:TableCellTouched(view, cell)
    local idx = nil
    if cell == nil then
        idx = cellIndex
    else
        idx = cell:getIdx()
    end
    self._CurCellIdx = idx
    local tableID = self._ShowWarriorIDTable[self._CurCellIdx + self._CellType]
    self._CurrentSelectWuJiangTableID = tableID
    --
    --当前武将未上阵时，判断上阵的武将数目
    local currentWuJiangZhengXingData = CharacterServerDataManager:GetZhenXingData(self._CurFormationIndex, tableID)
    if currentWuJiangZhengXingData == nil  then
        local currentWuJiangCount = CharacterServerDataManager:GetCurrentZhenXingWuJiangCount(self._CurFormationIndex)
        if currentWuJiangCount >= self:getMaxWorriorAmount() then
            --提示信息
            local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
            UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_bz_wuJiang_OverMax))
            return
        end
    end

    print("TableCellTouched tableID", tableID)
    local destX, destY = self:GetOnePosition()

    local worldPosition = self._BuZhenNode:convertToWorldSpace(cc.p(destX, destY))
    destX = worldPosition.x 
    destY = worldPosition.y 

    print(destX, destY)
    self._ZhenXingChangeIdentify[self._CurFormationIndex] = 1
    local isNew, tipNode = self:CreateGetZhenXing(tableID, destX, destY)
    if isNew == true then
        self:UpdateZhenXingAtPosition(tableID)
    end

    self:refreshCurWarriorAmount()
    self._WuJiangTableView:reloadData()
end

function UIBuZhen:OnDeployAuto(sender, eventType)
    local currentWuJiangCount = CharacterServerDataManager:GetCurrentZhenXingWuJiangCount(self._CurFormationIndex)

    local row = self:getMaxWorriorAmount()
    for i = 0, row do
        currentWuJiangCount = CharacterServerDataManager:GetCurrentZhenXingWuJiangCount(self._CurFormationIndex)
        cellIndex = i
        self._CellType = 1
        --拥有武将数小于可布阵最大武将数时，终止循环
        if self._WarriorCells <= currentWuJiangCount then
            break
        end
        if currentWuJiangCount < self:getMaxWorriorAmount() then
            self:TableCellTouched(nil, nil)
        end
        if i ~= row or self:getMaxWorriorAmount() % 2 == 0 then
            currentWuJiangCount = CharacterServerDataManager:GetCurrentZhenXingWuJiangCount(self._CurFormationIndex)
            self._CellType = 1
            if currentWuJiangCount < self:getMaxWorriorAmount() then
                self:TableCellTouched(nil, nil)
            end
        end
    end
end

--布阵提示点击
function UIBuZhen:OnBuZhenTipEvent(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        self._CurWarriorSelectedZOrder = sender:getParent():getLocalZOrder()
        local beginPositon = sender:getTouchBeganPosition()
        self._CurrentSelectWuJiangTableID = sender:getTag()
        print("OnUIBuZhenEvent _CurrentSelectWuJiangTableID" , self._CurrentSelectWuJiangTableID)
        local currentData = CharacterServerDataManager:GetZhenXingData(self._CurFormationIndex, self._CurrentSelectWuJiangTableID)
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
        sender:getParent():setLocalZOrder(100000)
    elseif eventType == ccui.TouchEventType.ended then
        local worldPosition = sender:getTouchEndPosition()
        self._ZhenXingChangeIdentify[self._CurFormationIndex] = 1
        if self._IsMoveZhenXing == false then
            local soldierSelectBoard = UISystem:OpenUI(UIType.UIType_SoldierSelectListUI)
            if soldierSelectBoard ~= nil then
                soldierSelectBoard:SetCurrentSelectSoldier(self:GetCurrentSoldierID())
            end
            if self._CurrentSelectWuJiangTableID ~= nil and self._CurrentSelectWuJiangTableID ~= 0 then
                self:UpdateZhenXingAtPosition(self._CurrentSelectWuJiangTableID)
            end
        else
            self:TouchEndedIsHave()
        end
        self:SetZhenXingShowImage(self._CurrentSelectWuJiangTableID, false)
        local parent = sender:getParent()
        if parent and not tolua.isnull(parent) then
            parent:setLocalZOrder(self._CurWarriorSelectedZOrder)
        end
        self._GridImage:setVisible(false)
    elseif eventType == ccui.TouchEventType.canceled then
        local worldPosition = sender:getTouchEndPosition()
        self:TouchEndedIsHave()
        self:SetZhenXingShowImage(self._CurrentSelectWuJiangTableID, false)
        local parent = sender:getParent()
        if parent and not tolua.isnull(parent) then
            parent:setLocalZOrder(self._CurWarriorSelectedZOrder)
        end
        self._GridImage:setVisible(false)
    elseif eventType == ccui.TouchEventType.moved then
        self._GridImage:setVisible(true)
        self._IsMoveZhenXing = true
        local movePosition =  sender:getTouchMovePosition()
        if self._CurrentSelectWuJiangTableID ~= nil and self._CurrentSelectWuJiangTableID ~= 0 then
            local currentData = CharacterServerDataManager:GetZhenXingData(self._CurFormationIndex, self._CurrentSelectWuJiangTableID)
            if currentData ~= nil then
                local opNode = currentData._TipRootNode
                local parentNode = opNode:getParent()
                if parentNode ~= nil then
                    movePosition = cc.pAdd(movePosition, self._MoveZhenXingOffsetPosition)
                    local buZhenUIPosition =  parentNode:convertToNodeSpace(movePosition)
                    opNode:setPosition(buZhenUIPosition)
                    local button = seekNodeByName(opNode, "Image_ItemZone")
                    --此处存在BUG，isHave在下面setPosition之后需要再次获取(isHave获得之后武将阵型的位置被再次set，而isHave没有再次获取，用旧的isHave判断button的底色不准确，在被靠近武将边上时判断会出错)
                    local isHave, realX, realY = self:IsHaveUnitInTile(self._CurrentSelectWuJiangTableID)
                    realX = mathCeil(realX)
                    realY = mathCeil(realY)
                    opNode:setPosition(cc.p(realX, realY))
                    --print("isHave ", isHave, button, realX, realY)
                    --再次获取isHave值，保证武将阵型设置完位置后底色的准确性
                    local isHave, realX, realY = self:IsHaveUnitInTile(self._CurrentSelectWuJiangTableID)
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
--确认保存
function UIBuZhen:OnSaveOKClick()
    UISystem:CloseUI(UIType.UIType_BuZhen)
    print("send save packet")
    --发送数据包
    local newBuZhenPacket = NetSystem:GetMsgPacket(PacketDefine.PacketDefine_FormationSave_Send)
    if newBuZhenPacket ~= nil then
        --填充数据
        newBuZhenPacket:ResetData()
        local zhenXingNum = 0
        for i = 1, 3 do
        
            local currentData = CharacterServerDataManager._AllZhenXingTable[i]
            if currentData ~= nil then
                print("OnSaveOKClickOnSaveOKClickOnSaveOKClick")
                newBuZhenPacket._SaveData[i]._Name = tostring(i)
                local currentIndex = 1
                for k, v in pairs(currentData)do
                    newBuZhenPacket._SaveData[i]._Data[currentIndex]._WuJiangTableID = v._WuJiangTableID
                    newBuZhenPacket._SaveData[i]._Data[currentIndex]._SoldierTableID = v._SoldierTableID
                    newBuZhenPacket._SaveData[i]._Data[currentIndex]._TileRow = v._ZhenXingStartRow
                    newBuZhenPacket._SaveData[i]._Data[currentIndex]._TileCol = v._ZhenXingStartCol
                    print("OnSaveOKClick ", i, currentIndex, v._WuJiangTableID)
                    currentIndex = currentIndex + 1
                    zhenXingNum = zhenXingNum + 1
                end
                if currentIndex == 1 then
                    newBuZhenPacket._ChangeIdentify[i] = 0
                else
                    newBuZhenPacket._ChangeIdentify[i] = self._ZhenXingChangeIdentify[i]
                end
            end
        end
        if zhenXingNum > 0 then
            NetSystem:SendPacket(newBuZhenPacket)
        end
    end
end
--退出点击
function UIBuZhen:OnSaveQuitClicked(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        --当前上阵武将数目判定
        local currentWuJiangCount = CharacterServerDataManager:GetCurrentZhenXingWuJiangCount(self._CurFormationIndex)
        if currentWuJiangCount < self:getMaxWorriorAmount() then
            local tip =  UISystem:OpenUI(UIType.UIType_TipUI)
            tip:RegisteDelegate(handler(self, self.OnSaveOKClick), 1, GameGlobal:GetTipDataManager(UI_bz_wuJiang_NoMax))
            return
        end
        self:OnSaveOKClick()
    end
end
-- 获取当前的士兵ID，用于换兵时的对号
function UIBuZhen:GetCurrentSoldierID()
    local currentZhenXingData = CharacterServerDataManager:GetZhenXingData(self._CurFormationIndex)
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

--回城点击
function UIBuZhen:OnHuiChengButton(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        --提示信息
        local tip =  UISystem:OpenUI(UIType.UIType_TipUI)
        tip:RegisteDelegate(function()
            UISystem:CloseUI(UIType.UIType_BuZhen)
            CharacterServerDataManager:RestoreZhenXingData()
        end, 1, GameGlobal:GetTipDataManager(UI_bz_NoSaveNoQuit))
    end
end


return UIBuZhen
