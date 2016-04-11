----
-- 文件名称：GuoZhanServerDataManager
-- 功能描述：国战数据管理器
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-8-11
--  修改：
--  
local AStar = require("main.Utility.AStar")
local fileUtils = cc.FileUtils:getInstance() 
local TableDataManager = GameGlobal:GetDataTableManager()
local WorldMapTableDataManager = TableDataManager:GetWorldMapTableDataManager()
local tableInsert = table.insert

--城池状态
JuDianState = 
{
    --正常
    JuDianState_Normal = 0,
    --交战
    JuDianState_Battle = 1,  
    --远征
    JuDianState_YuanZheng = 2
}
--国战主角状态
GuoZhanSelfState = 
{
    --正常
    GuoZhanSelfState_Normal = 1,
    --行走
    GuoZhanSelfState_Walk = 2,
    --战斗
    GuoZhanSelfState_Battle = 3,
}

--国战交战中要显示的玩家数据
local GuoZhanBattlePlayerData = class("GuoZhanBattlePlayerData")

function GuoZhanBattlePlayerData:ctor()
    --玩家名称
    self._PlayerName = ""
    self._Guid = 0
    --头像
    self._HeadId = ""
    --等级
    self._Level = 0
    --VIP 等级
    self._VIPLevel = 0
    --官员ID
    self._GuanYuanID = 0
    --国家
    self._Country = 0
end

--战斗校验时玩家数据  ---- new 10.22
local BattlePlayerData = class("BattlePlayerData")
function BattlePlayerData:ctor()
    --玩家
    self._GUID = 0
    --vip
    self._Vip = 0
    --name
    self._Name = ""
end

--战斗阵形数据
local BattleZhenXingDataNew = class("BattleZhenXingDataNew") 
function BattleZhenXingDataNew:ctor()
    --
    self._WuJiangTableID = 0
    self._WuJiangAttack = 0
    self._WuJiangAttackSpeed = 0
    self._WuJiangHP = 0
    self._WuJiangCurHP = 0

    self._SoldierTableID = 0
    self._SoldierAttack  = 0
    self._SoldierAttackSpeed = 0 
    self._SoldierHP  = 0
    self._SoldierNum = 0
    self._SoldierCurNum  = 0 
    self._ZhenXingStartRow = 0
    self._ZhenXingStartCol = 0
end

--阵形数据
local  ZhenXingData = class("ZhenXingData")
function ZhenXingData:ctor()
    --阵形ID
    self._ZhenXingID = 0
    --阵形初始位置 行列
    self._ZhenXingStartRow = 0
    self._ZhenXingStartCol = 0
    --武将TableID
    self._WuJiangTableID = 0
    self._SoldierTableID = 0
    --阵型位置X
    self._InitX = 0
    self._InitY = 0
    --根节点
    self._TipRootNode = nil
    -------------来自服务器的额外数据
    --血量
    self._WuJiangHP = 0
    --攻击
    self._WuJiangAttack = 0
    --士兵的
    self._SoldierLevel = 0
    self._SoldierHP = 0
    self._SoldierAttack = 0
end


--国战阵形数据
local GuoZhanZhenXingData = class("GuoZhanZhenXingData")

function GuoZhanZhenXingData:ctor()
    --SoldierID
    self._SoldierTableID = 0
    --攻击
    self._Attack = 0
    --血量
    self._HP = 0
    --攻速
    self._AttackSpeed = nil
    --位置(格子)
    self._TileX = 0
    self._TileY = 0
    --如果是小兵，隶属于哪个武将
    self._BelongWuJiangTableID = 0
    --大阵的行列
    self._BigZhenXingRow = 0
    self._BigZhenXingCol = 0
    --原小兵的总数目
    self._SoldierCount = 0
end

--据点逻辑数据 
local JuDianData = class("JuDianData")

function JuDianData:ctor()
    --据点ID
    self._JuDianTableID = 0
    --据点表格数据
    self._JuDianTableData = nil
    --据点状态
    self._JuDianState = 0
    --当前所属（魏蜀吴）
    self._CurrentBelong = -1
    
end

local GuoZiData = class("GuoZiData")

function GuoZiData:ctor()
    self._GuoZiDataNum = 0 
    self._Sliver = 0
    -- beishu
    self._Times = 0
    self._GuoJiaNum = 0
    self._GuoJiaTable = {}
end

--国战战斗缓存信息 --临时作废，先留着
local CacheGuoZhanBattleInfo = class("CacheGuoZhanBattleInfo")
function CacheGuoZhanBattleInfo:ctor()
    --战斗ID
    self._BattleID = 0
    --战斗攻方玩家数据
    self._AttackerPlayerData = {}
    --战斗守方玩家数据
    self._DefenderPlayerData = {}
    --战斗攻方阵型数据
    self._BattleAttackerZhenXingData = {}
    --战斗守方阵型数据
    self._BattleDefenderZhenXingData = {}
    --战斗结果
    
end

local GuoZhanServerDataManager = class("GuoZhanServerDataManager") 

function GuoZhanServerDataManager:ctor()
    --是否已经初始化
    self._IsInit = false
    --世界地图数据(0 1是否可通行数据),本地文件worldmap.jason中的数据,原始数据
    self._WorldMapData = {}
    --当前地图数据
    self._CurrentMapData = {}
    --记录所有据点占用的格子（k: tileID value: judianTableID）
    self._AllJuDianTileData = {}
    --Tile
    self._TileWidth = 0
    self._TileHeight = 0
    --Tile count
    self._WidthTiles = 0
    self._HeightTiles = 0
    ------服务器下发的
    --当前主角行走路径List
    self._SelfWalkPathIDList = {}
    --当前所有据点状态数据
    self._AllJuDianData = {}
    --当前国战中攻方玩家数据
    self._GuoZhanAttackerPlayerData = nil
    --当前国战中守方玩家数据
    self._GuoZhanDefenderPlayerData = nil
    --当前国战中攻方阵型数据
    self._GuoZhanAttackerZhenXingData = {}
    --当前国战中守方阵型数据
    self._GuoZhanDefenderZhenXingData = {}
    --当前战斗中攻方玩家列表
    self._GuoZhanAttackerPlayerInfoList = {}
    --当前战斗中守方玩家列表
    self._GuoZhanDefenderPlayerInfoList = {}
    --用于校验的战斗结果数据
    --战斗ID
    self._BattleCheckBattleID = 0
    --战斗数据
    self._BattleCheckAttackerZhenXingData = {}
    self._BattleCheckDefenderZhenXingData = {}
    self._BattleCheckAttackerPlayerInfo = BattlePlayerData.new()
    self._BattleCheckDefenderPlayerInfo = BattlePlayerData.new()
    --校验的战斗结果
    self._CheckBattleResultAttackerZhenXingData = {}
    self._CheckBattleResultDefenderZhenXingData = {}
    --战斗结果
    self._CheckBattleBattleResult = 0
    --战斗结果帧数
    self._CheckBattleBattleResultFrame = 0
    --总兵力
    self._TotalSoldierCount = 0
    --当前兵力
    self._CurrentSoldierCount = 0
    --当前剩余回复次数
    self._HuiFuCount = 0
    --开箱暴击数
    
    --状态(正常1 行走2 战斗3)
    self._CurrentState = 0
    --功勋
    self._GongXunValue = 0
    --募兵令消耗数
    self._MuBingLingCount = 0
    --官员令
    self._ShadowNum = 0
    --已使用影子数
    self._GuoZI = nil
    --当前城池内国战战斗信息缓存
    self._CacheGuoZhanBattleInfo = nil

--当前阵型
    self._CurrentZhenXing = nil
end

--初始化世界地图数据
function GuoZhanServerDataManager:Init()
    if self._IsInit == false then
        self._IsInit = true
        
        self._WorldMapData = {}
        local worldMapData = TableDataManager._WorldMapJasonData
        --数据读取 
        if worldMapData ~= nil then
            self._TileWidth = worldMapData.tileWidth
            self._TileHeight = worldMapData.tileHeight
            self._WidthTiles = worldMapData.widthTiles
            self._HeightTiles = worldMapData.heightTiles
            --map data 初始不可通行
            for i = 1, self._HeightTiles do
                self._WorldMapData[i] = {}
                for j = 1,  self._WidthTiles do
                    self._WorldMapData[i][j] = 1
                end
            end
            --将Path置为可通行
            if worldMapData.paths ~= nil then
                local pathCount = #worldMapData.paths
                for i = 1, pathCount do
                    local rowColData = worldMapData.paths[i]
                    local row = rowColData[1]
                    local col = rowColData[2]
                    if row ~= nil and col ~= nil then
                        self._WorldMapData[row][col] = 0
                    end
                end
            end
        end
        self._AllJuDianData = {}
        self._AllJuDianTileData = {}
        if  WorldMapTableDataManager ~= nil then
            for k, v in pairs(WorldMapTableDataManager)do
               local currentData = self:CreateJuDianData(v)
               self:SetJuDianTiles(currentData)
            end
        end
        self._CurrentMapData = clone(self._WorldMapData)
    end
end

--获取路径列表
function GuoZhanServerDataManager:GetPathList(startRow, startCol, destRow, destCol)
    local start = {row = startRow, col = startCol}
    local dest = {row = destRow, col = destCol}
    AStar:init(self._WorldMapData, start, dest,  false)
    local path = AStar:searchPath()
    local newPathList = nil
    if path ~= nil then
        newPathList = {}
        local count = #path
        for i = 1, count do
            local newPath = {}
            newPath.row = path[count - i + 1].row
            newPath.col = path[count - i + 1].col
            tableInsert(newPathList, newPath)
        end
    end
    --print("GetPathList", startRow, startCol, destRow, destCol)
    --dump(path)
    return newPathList
end
--获取移动经过的城池(startJuDianTableID:起始城池ID, destJuDianTableID:结束城池ID)
function GuoZhanServerDataManager:GetMoveCityListByJuDian(startJuDianTableID, destJuDianTableID)
    local startJuDianData = self._AllJuDianData[startJuDianTableID]
    local destJuDianData = self._AllJuDianData[destJuDianTableID]
    if startJuDianData == nil or destJuDianData == nil then
        print("invalid city id", startJuDianTableID, destJuDianTableID)
        return
    end
    return self:GetMoveCityList(startJuDianData._JuDianTableData.row, startJuDianData._JuDianTableData.col, destJuDianData._JuDianTableData.row, destJuDianData._JuDianTableData.col)
end

--获取移动路径经过的城池
function GuoZhanServerDataManager:GetMoveCityList(startRow, startCol, destRow,destCol)
    local tempSaveTable = {}
    local start = {row = startRow, col = startCol}
    local dest = {row = destRow, col = destCol}
    AStar:init(self._CurrentMapData, start, dest,  false)
    local path = AStar:searchPath()
    local newPathList = nil
    if path ~= nil then
        newPathList = {}
        local count = #path
        for i = 1, count do
            local tileID =  path[count - i + 1].row * 10000 + path[count - i + 1].col
            --print("tile:", path[count - i + 1].row, path[count - i + 1].col)
            local juDianTileID = self._AllJuDianTileData[tileID]
            local juDianServerData = self._AllJuDianData[juDianTileID]
            if juDianServerData ~= nil then
                if tempSaveTable[juDianTileID] == nil then
                    local name = juDianServerData._JuDianTableData.name
                    tempSaveTable[juDianTileID] = juDianTileID
                    tableInsert(newPathList, {juDianTileID, name})
                end
            end
        end
    end
    print("GetMoveCityList ", startRow, startCol, destRow,destCol)
    return newPathList
end
--设置据点状态
function GuoZhanServerDataManager:SetJuDianState(judianTableID, state, belong)
    local juDianServerData = self._AllJuDianData[judianTableID]
    if juDianServerData == nil then
        print("error: SetJuDianState invalid data", judianTableID )
        return
    end
    --设置状态
    juDianServerData._CurrentBelong = belong
    if juDianServerData._CurrentBelong == -1 then
        juDianServerData._CurrentBelong = juDianServerData._JuDianTableData.mbelong
    end
    juDianServerData._JuDianState = state
    local GamePlayerDataManager = GameGlobal:GetGamePlayerDataManager()
    local myselfData = GamePlayerDataManager:GetMyselfData()
    local myCountry = myselfData._Country
    --地图数据(设置是否可通行)
--    if myCountry == juDianServerData._CurrentBelong then
        self:ChangeJuDianMapDataToOri(juDianServerData)
--    else
--        self:ChangeJuDianMapDataTo1(juDianServerData)
--    end
end

--设置据点地图数据为不可通行
function GuoZhanServerDataManager:ChangeJuDianMapDataTo1(currentJuDianData)
    for startRow = -2, 2 do
        for startCol = -2, 2 do
            local currentRow = currentJuDianData._JuDianTableData.row + startRow
            local currentCol =  currentJuDianData._JuDianTableData.col + startCol
            self._CurrentMapData[currentRow][currentCol] = 1
        end
    end
end

--设置据点地图数据为可通行
function GuoZhanServerDataManager:ChangeJuDianMapDataToOri(currentJuDianData)
    local oldData = self._WorldMapData
    for startRow = -2, 2 do
        for startCol = -2, 2 do
            local currentRow = currentJuDianData._JuDianTableData.row + startRow
            local currentCol =  currentJuDianData._JuDianTableData.col + startCol
            self._CurrentMapData[currentRow][currentCol] = oldData[currentRow][currentCol]
        end
    end
end
--设置某据点的格子(5*5范围内格子都属于该城池)
function GuoZhanServerDataManager:SetJuDianTiles(currentJuDianData)
    if currentJuDianData == nil then
        return
    end
    for startRow = -2, 2 do
        for startCol = -2, 2 do
            local currentRow = currentJuDianData._JuDianTableData.row + startRow
            local currentCol =  currentJuDianData._JuDianTableData.col + startCol
            local tileID = currentRow * 10000 + currentCol
            self._AllJuDianTileData[tileID] = currentJuDianData._JuDianTableID
        end
    end
end

function GuoZhanServerDataManager:CreateGuoZiData()
    local newJuDianData = GuoZiData:new()
    self._GuoZI = newJuDianData
    return newJuDianData
end

function GuoZhanServerDataManager:GetGuoZiData()
    return self._GuoZI
end

--创建据点数据
function GuoZhanServerDataManager:CreateJuDianData(juDianTableData)
    local newJuDianData = JuDianData:new()
    local tableID = juDianTableData.id
    newJuDianData._JuDianTableID = tableID
    newJuDianData._JuDianTableData = juDianTableData
    newJuDianData._JuDianState = 0
    newJuDianData._CurrentBelong = juDianTableData.mbelong - 1
    self._AllJuDianData[tableID] = newJuDianData
    return newJuDianData
end

--获取据点数据
function GuoZhanServerDataManager:GetJuDianData(tableID)
    return self._AllJuDianData[tableID]
end

--创建国战玩家数据
function GuoZhanServerDataManager:CreateGetGuoZhanAttackerPlayerData()
    if self._GuoZhanAttackerPlayerData == nil then
        self._GuoZhanAttackerPlayerData = GuoZhanBattlePlayerData:new()
    end
    return self._GuoZhanAttackerPlayerData
end
--创建国战玩家数据
function GuoZhanServerDataManager:CreateGetGuoZhanDefenderPlayerData()
    if self._GuoZhanDefenderPlayerData == nil then
        self._GuoZhanDefenderPlayerData = GuoZhanBattlePlayerData:new()
    end
    return self._GuoZhanDefenderPlayerData
end

--创建国战玩家数据
function GuoZhanServerDataManager:CreateGuoZhanPlayerData()
    return GuoZhanBattlePlayerData:new()
end

function GuoZhanServerDataManager:DeleteGuoZhanPlayerData(uid)
    for i = 1, #self._GuoZhanAttackerPlayerInfoList do
        if self._GuoZhanAttackerPlayerInfoList[i] ~= nil and self._GuoZhanAttackerPlayerInfoList[i]._Guid == uid then
            table.remove(self._GuoZhanAttackerPlayerInfoList, i)
        end
    end
   
    for i = 1, #self._GuoZhanDefenderPlayerInfoList do
        if self._GuoZhanDefenderPlayerInfoList[i] ~= nil and self._GuoZhanDefenderPlayerInfoList[i]._Guid == uid then
            table.remove(self._GuoZhanDefenderPlayerInfoList, i)
        end
    end
end

function GuoZhanServerDataManager:UpdateGuoZhanPlayerData(uid, state)
    for i = 1, #self._GuoZhanAttackerPlayerInfoList do
        if self._GuoZhanAttackerPlayerInfoList[i] ~= nil and self._GuoZhanAttackerPlayerInfoList[i]._Guid == uid then
            self._GuoZhanAttackerPlayerInfoList[i]._State = state
        end
    end

    for i = 1, #self._GuoZhanDefenderPlayerInfoList do
        if self._GuoZhanDefenderPlayerInfoList[i] ~= nil and self._GuoZhanDefenderPlayerInfoList[i]._Guid == uid then
            self._GuoZhanDefenderPlayerInfoList[i]._State = state
        end
    end
end


--创建国战阵型数据
function GuoZhanServerDataManager:CreateGuoZhanZhenXing()
    return GuoZhanZhenXingData:new()
end
--创建国战阵型New
function GuoZhanServerDataManager:CreateGuoZhanZhenXingNew()
    return BattleZhenXingDataNew.new()
end

local newGuoZhanServerDataManager = GuoZhanServerDataManager:new()

return newGuoZhanServerDataManager