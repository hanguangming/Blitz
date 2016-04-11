----
-- 文件名称：GuoZhanMapPlayer.lua
-- 功能描述：国战地图上的玩家
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-8-13
local TableDataManager = GameGlobal:GetDataTableManager()
local CharacterTableDataManager = TableDataManager:GetCharacterDataManager()
local WorldMapDataManager = TableDataManager:GetWorldMapTableDataManager()
local GuoZhanMapPlayer = class("GuoZhanMapPlayer")
local GuoZhanServerDataManager = GameGlobal:GetGuoZhanServerDataManager()
local TechnologyManager = GameGlobal:GetServerTechnologyDataManager()

--国战地图玩家
function GuoZhanMapPlayer:ctor()
    ----------逻辑相关----------
    --serverID
    self._PlayerServerID = 0
    --tableID
    self._PlayerTableID = 0
    --当前移动的格子索引
    self._CurrentMoveTileIndex = 1
    --移动的Path列表
    self._CurrentMovePathList = nil
    --当前移动方向
    self._CurrentMoveDir = nil
    --当前移动的起始位置
    self._CurrentMoveStartPosition = nil
    --当前移动目标位置
    self._CurrentMoveDestPosition = nil
    --当前移动速度
    self._CurrentMoveSpeed = 0
    --当前应该移动距离
    self._CurrentMoveDistance = 0
    ----------表现相关----------
    self._CharacterRootNode = nil
    --动作
    self._CharacterTimeLineAction = nil
    --是否主角
    self._IsSelf = false
end

--初始化
function GuoZhanMapPlayer:Init(serverID, tableID, isSelf)
    self._PlayerServerID = serverID
    self._PlayerTableID = tableID
    self._IsSelf = isSelf
    
    local characterData = CharacterTableDataManager[tableID]
    if characterData ~= nil then
        self._CharacterRootNode = cc.CSLoader:createNode(GetWarriorCsbPath(characterData.resName))
        self._CharacterRootNode:retain()
        self._CharacterTimeLineAction = cc.CSLoader:createTimeline(GetWarriorCsbPath(characterData.resName))
        if self._CharacterTimeLineAction ~= nil then
            self._CharacterTimeLineAction:retain()
        end
        self._CharacterTimeLineAction:play("Walk", true)
        self._CharacterRootNode:runAction(self._CharacterTimeLineAction)
        self._CharacterRootNode:setVisible(true)
    end
end

--销毁
function GuoZhanMapPlayer:Destroy()
    self._CharacterRootNode:removeFromParent()
    if self._CharacterRootNode ~= nil then
        self._CharacterRootNode:release()
        self._CharacterRootNode = nil
    end
    if self._CharacterTimeLineAction ~= nil then
        self._CharacterTimeLineAction:release()
        self._CharacterTimeLineAction = nil
    end
    self._CurrentMoveStartPosition = nil
    self._CurrentMovePathList = nil
    self._CurrentMoveDestPosition = nil
end

--播放行走动画
function GuoZhanMapPlayer:PlayWalkAnim()
    if self._CharacterRootNode == nil then
        return
    end
    local numAction = self._CharacterRootNode:getNumberOfRunningActions()
    if numAction == 0 then
        if self._CharacterTimeLineAction ~= nil then
            self._CharacterRootNode:runAction(self._CharacterTimeLineAction)
            self._CharacterTimeLineAction:play("Walk", true)
        end
    end
end

function GuoZhanMapPlayer:updateWuJiangID(serverID, tableID, isSelf)
    if self._PlayerTableID == tableID then
        return 0
    end
    self:Destroy()
    return 1
end

--Node
function GuoZhanMapPlayer:GetRootPlayerNode()
    return self._CharacterRootNode
end
--设置位置
function GuoZhanMapPlayer:SetPositionJuDian(juDianTableID)
    local startMapData = WorldMapDataManager[juDianTableID]
    local startRow = startMapData.row
    local startCol = startMapData.col
    local tileWidth = GuoZhanServerDataManager._TileWidth
    local tileHeight = GuoZhanServerDataManager._TileHeight

    local startPositionX = (startCol - 1) * tileWidth + 0.5 * tileWidth
    local startPositionY = (startRow - 1) * tileHeight + 0.5 * tileHeight
    
    if self._CharacterRootNode ~= nil then
        self._CharacterRootNode:setPosition(cc.p(startPositionX, startPositionY))
    end
end
local flag = 1
function GuoZhanMapPlayer:removeGuoZhanPathIcon(num)
    if self._IsSelf then
        local UISystem = require("main.UI.UISystem")
        local uiInstance = UISystem:GetUIInstance(UIType.UIType_WorldMap)
        if num == 1 then
            flag = 0
            uiInstance:removePathIcon(num)
        else
            if flag == 1 then
                uiInstance:removePathIcon(num)
            else
                flag = 1
            end
        end
    end
end

--StartMove
function GuoZhanMapPlayer:StartMove(startJuDianID, endJuDianID)
    --测试用
    --startJuDianID = 530017
    --endJuDianID = 450014
    if self._IsSelf then
        if self._IsSelf then
            self:removeGuoZhanPathIcon(1)
        end
    end
    local startMapData = WorldMapDataManager[startJuDianID]
    local endMapData = WorldMapDataManager[endJuDianID]
    if startMapData == nil or endMapData == nil then
        self._CurrentMovePathList = nil
        print("NOTE：please check that worldmap.txt of client is same with server..................................................")
        return
    end
    local startRow = startMapData.row --53
    local startCol = startMapData.col --17
    local endRow = endMapData.row --45
    local endCol = endMapData.col --14
    --移动的路径列表
    self._CurrentMovePathList = GuoZhanServerDataManager:GetPathList(startRow, startCol, endRow, endCol)
    if self._CurrentMovePathList == nil then
        print("############GuoZhanMapPlayer:StartMove self._CurrentMovePathList == nil############", startJuDianID, endJuDianID, startRow, startCol, endRow, endCol)
        return
    end
    
    self._CurrentMoveTileIndex = 1
    self:SetCurrentMove()
    --遍历路径,计算移动路径的总长度
    local totalPathLen = 0
    for i = 2, #self._CurrentMovePathList do
        local currentRow = self._CurrentMovePathList[i].row
        local currentCol = self._CurrentMovePathList[i].col
        local lastRow = self._CurrentMovePathList[i - 1].row
        local lastCol = self._CurrentMovePathList[i - 1].col
        if currentRow == lastRow or lastCol == currentCol then
            totalPathLen = totalPathLen + 1
        else
            --1.41 根2
            totalPathLen = totalPathLen + 1.41
        end
    end
    local dirVec = self:GetInitDir(startRow, startCol, endRow, endCol)
    local dirX = dirVec.x
    local characterSprite = self._CharacterRootNode:getChildByTag(1)
    if dirX < 0 then
        characterSprite:setFlippedX(true)
    else
        characterSprite:setFlippedX(false)
    end
    self._CharacterRootNode:setVisible(true)
    --计算移动速度,相邻城之间走10秒
    local tech = TechnologyManager:GetTechnologyDataByID(5)
    if tech == nil then
        self._CurrentMoveSpeed = totalPathLen * SIZE_ONE_TILE / 10
    else
        self._CurrentMoveSpeed = totalPathLen * SIZE_ONE_TILE / tech.val
    end
    if self._CurrentMoveSpeed < 25 then
        self._CurrentMoveSpeed = 25
    end
    --print("move speed", self._CurrentMoveSpeed)
end
--飞行
function  GuoZhanMapPlayer:StartMoveFeiXing(endJuDianID)
    self:SetPositionJuDian(endJuDianID)
    self._CurrentMoveStartPosition = nil
    self._CurrentMovePathList = nil
end
--获取朝向
function GuoZhanMapPlayer:GetInitDir(startRow, startCol, endRow, endCol)
    local tileWidth = GuoZhanServerDataManager._TileWidth
    local tileHeight = GuoZhanServerDataManager._TileHeight

    local startPositionX = (startCol - 1) * tileWidth + 0.5 * tileWidth
    local startPositionY = (startRow - 1) * tileHeight + 0.5 * tileHeight
    local destX = (endCol - 1) * tileWidth + 0.5 * tileWidth
    local destY = (endRow - 1) * tileHeight + 0.5 * tileHeight
    local startPosition = cc.p(startPositionX, startPositionY)
    local destPosition = cc.p(destX, destY)
    local moveVec = cc.pSub(destPosition, startPosition)
    return cc.pNormalize(moveVec)
end
--设置起始，结束位置，方向等
function GuoZhanMapPlayer:SetCurrentMove()
    --起点与终点
    if self._CurrentMovePathList == nil then
        return
    end
    local currentData = self._CurrentMovePathList[self._CurrentMoveTileIndex]
    local nextData = self._CurrentMovePathList[self._CurrentMoveTileIndex + 1]
    --数据非法了
    if currentData == nil or nextData == nil then
        return
    end
    local startRow = currentData.row
    local startCol = currentData.col
    local endRow = nextData.row
    local endCol = nextData.col
    local tileWidth = GuoZhanServerDataManager._TileWidth
    local tileHeight = GuoZhanServerDataManager._TileHeight
    
    local startPositionX = (startCol - 1) * tileWidth + 0.5 * tileWidth
    local startPositionY = (startRow - 1) * tileHeight + 0.5 * tileHeight
    local destX = (endCol - 1) * tileWidth + 0.5 * tileWidth
    local destY = (endRow - 1) * tileHeight + 0.5 * tileHeight
    self._CurrentMoveStartPosition = cc.p(startPositionX, startPositionY)
    self._CurrentMoveDestPosition = cc.p(destX, destY)
    local moveVec = cc.pSub(self._CurrentMoveDestPosition, cc.p(startPositionX, startPositionY))
    self._CurrentMoveDir = cc.pNormalize(moveVec)
    self._CurrentMoveDistance = cc.pGetLength(moveVec)
    
    if self._CharacterRootNode ~= nil then
        self._CharacterRootNode:setPosition(cc.p(startPositionX, startPositionY))
    end
    
    if self._IsSelf then
        self:removeGuoZhanPathIcon(0)
    end
end
--帧更新
function GuoZhanMapPlayer:Update(deltaTime)
   
   if self._CharacterRootNode == nil then
      return
   end
   if self._CurrentMoveDir == nil then
      return
   end
   if self._CurrentMoveStartPosition == nil then
      return
   end
    if self._CurrentMovePathList == nil then
        return
    end
     
    if self._CurrentMoveTileIndex >= #self._CurrentMovePathList then
        return
    end
    
    local currentPositionX,  currentPositionY = self._CharacterRootNode:getPosition()
    local newPosition = cc.pAdd(cc.p(currentPositionX,  currentPositionY) , cc.pMul(self._CurrentMoveDir, self._CurrentMoveSpeed * deltaTime))
    self._CharacterRootNode:setPosition(newPosition)
    local nowOffsetPosition = cc.pSub(newPosition, self._CurrentMoveStartPosition)
    local currentDistance = cc.pGetLength(nowOffsetPosition)
    --当前移动结束

    if currentDistance >= self._CurrentMoveDistance then
        self._CurrentMoveTileIndex = self._CurrentMoveTileIndex + 1
        --结束
        if self._CurrentMoveTileIndex == #self._CurrentMovePathList then
            if self._IsSelf == false then
                --self._CharacterRootNode:setVisible(false)
            end
            return
        end
        --初始化下次移动参数
        self:SetCurrentMove()
    end
end

return GuoZhanMapPlayer
