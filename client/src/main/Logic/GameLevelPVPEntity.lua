----
-- 文件名称：GameLevelPVPEntity.lua
-- 功能描述：游戏关卡:游戏场景构建(兵,地图，技能特效等)游戏关卡逻辑 显示相关部分
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-9-29
--  修改：GameLevel显示相关部分,cocos引擎部分相关

local stringFind = string.find
local stringSub = string.sub
local mathAbs = math.abs
local mathCeil = math.ceil
local mathFloor = math.floor
local mathPow = math.pow
local stringFormat = string.format

local GameLevelPVPEntity = class("GameLevelPVPEntity")

local director = cc.Director:getInstance()
local UISystem = nil

--构造
function GameLevelPVPEntity:ctor()
    --根节点
    self._LevelNode = nil
    --角色层节点
    self._LevelSoldierNode = nil
    --特效层节点
    self._LevelEffectNode = nil
    --
    self._LevelSize = nil
end

--初始化
function GameLevelPVPEntity:Init(levelSceneName)
    self._LevelSceneName = levelSceneName
    --场景节点
    self._LevelNode = cc.CSLoader:createNode(self._LevelSceneName)
    self._LevelNode:retain()
    self._LevelNode:setAnchorPoint(0.5, 0.5)
    self._LevelNode:setPositionX((cc.Director:getInstance():getWinSizeInPixels().width) / 2)
    self._LevelNode:setPositionY((cc.Director:getInstance():getWinSizeInPixels().height) / 2)
    self._LevelSoldierNode = cc.Node:create()
    self._LevelSoldierNode:retain()
    self._LevelNode:addChild(self._LevelSoldierNode)
    --self._LevelNode:setPositionY(-50)
    self._LevelEffectNode = cc.Node:create()
    self._LevelEffectNode:retain()
    self._LevelNode:addChild(self._LevelEffectNode)
    --查找场景节点下的建筑子节点，如果有创建BattleBuilding
    self._LevelNode:getChildByName("Panel_1"):setSwallowTouches(true)
    local selfHomeBuldingSprite = self._LevelNode:getChildByName("Sprite_SelfHome")
    local enemyHomeBuildingSprite = self._LevelNode:getChildByName("Sprite_EnemyHome")
    --标识场景区域的四个节点
    local levelLeftTopNode = self._LevelNode:getChildByName("Node_LeftTop")
    local levelLeftBottomNode = self._LevelNode:getChildByName("Node_LeftBottom")
    local levelRightTopNode = self._LevelNode:getChildByName("Node_RightTop")
    local levelRightBottomNode = self._LevelNode:getChildByName("Node_RightBottom")
    --
    if  levelLeftBottomNode ~= nil and levelRightTopNode ~= nil then
        self._LevelLeftBottomPositionX, self._LevelLeftBottomPositionY = levelLeftBottomNode:getPosition()
        self._LevelRightTopPositionX,  self._LevelRightTopPositionY = levelRightTopNode:getPosition()

        print("Level init pos LeftBottom", self._LevelLeftBottomPositionX, self._LevelLeftBottomPositionY)
        print("Level init pos RightTop", self._LevelRightTopPositionX, self._LevelRightTopPositionY)

        self._LevelLeftBottomPositionX = mathCeil(self._LevelLeftBottomPositionX)
        self._LevelLeftBottomPositionY = mathCeil(self._LevelLeftBottomPositionY)
        self._LevelRightTopPositionX = mathCeil(self._LevelRightTopPositionX)
        self._LevelRightTopPositionY = mathCeil(self._LevelRightTopPositionY)

        print("Level init pos LeftBottom", self._LevelLeftBottomPositionX, self._LevelLeftBottomPositionY)
        print("Level init pos RightTop", self._LevelRightTopPositionX, self._LevelRightTopPositionY)
        self._LevelInitRandomYMin = mathCeil(self._LevelLeftBottomPositionY)
        self._LevelInitRandomYMax = mathCeil(self._LevelRightTopPositionY)
    end
    --如果场景制作时，缺少了节点Node_LeftBottom Node_RightBottom，为了不报错，程序赋默认值
    if self._LevelInitRandomYMin == nil then
        self._LevelInitRandomYMin = 190
    end
    if self._LevelInitRandomYMax == nil then
        self._LevelInitRandomYMax = 490
    end
    --敌我双方的兵营
    local bgSprite = self._LevelNode:getChildByName("BG")
    bgSprite:setSwallowTouches(true)
    self._LevelSize = bgSprite:getContentSize()

end

--销毁 
function GameLevelPVPEntity:Destroy()
    --场景节点移除
    if self._LevelSoldierNode ~= nil then
        self._LevelSoldierNode:removeFromParent(true)
        self._LevelSoldierNode:removeAllChildren()
        self._LevelSoldierNode:release()
        self._LevelSoldierNode = nil
    end
    if self._LevelEffectNode ~= nil then
        self._LevelEffectNode:removeFromParent(true)
        self._LevelEffectNode:removeAllChildren()
        self._LevelEffectNode:release()
        self._LevelEffectNode = nil
    end
    if self._LevelNode ~= nil then
        self._LevelNode:removeFromParent(true)
        self._LevelNode:removeAllChildren()
        self._LevelNode:release()
        self._LevelNode = nil
    end
end

--获取场景大小
function GameLevelPVPEntity:GetLevelSize()
   return  self._LevelSize
end
--
function GameLevelPVPEntity:GetLevelRootNode()
    return self._LevelNode
end
--添加技能
function GameLevelPVPEntity:AddSkillNode(skillRootNode)
    if skillRootNode == nil then
        return
    end
    local parentNode = skillRootNode:getParent()
    if parentNode == nil then
        self._LevelSoldierNode:addChild(skillRootNode)
    end
end
--添加武将技能节点
function GameLevelPVPEntity:AddLeaderSkillNode(skillRootNode, position)
    if skillRootNode == nil then
        return
    end
    local parentNode = skillRootNode:getParent()
    if parentNode == nil then
        local skillPosition = self._LevelSoldierNode:convertToNodeSpace(position)
        self._LevelSoldierNode:addChild(skillRootNode)
        skillRootNode:setPosition(skillPosition)
    end
end

--校正位置
function GameLevelPVPEntity:FixLevelPosition()
    local parentNode = self._LevelNode:getParent()
    if parentNode ~= nil then
        --local parentSpaceSize = parentNode:getContentSize()
        -- dump(parentSpaceSize, "parentSpaceSize")
        local levelContentSize = self._LevelNode:getContentSize()
        local winSize = cc.Director:getInstance():getWinSizeInPixels()
        local newY = (winSize.height - self._LevelSize.height )/ 2
        self._LevelNode:setPositionX((levelContentSize.width) / 2)
        self._LevelNode:setPositionY(newY + levelContentSize.height / 2)
    end
end
--添加士兵
function  GameLevelPVPEntity:AddSoldierNode(soldierNode)
    if soldierNode == nil then
        return 
    end
    local parentNode = soldierNode:getParent()
    if parentNode == nil then
        self._LevelSoldierNode:addChild(soldierNode)
    end
end
--获取技能位置
function GameLevelPVPEntity:GetLevelSkillPosition(worldPositon)
    return self._LevelSoldierNode:convertToNodeSpace(worldPositon)
end
--移动
function GameLevelPVPEntity:MoveX(deltaX)
    if self._LevelNode ~= nil then
        local winsize =  director:getWinSize()
        --dump(winsize,"winsize")
        --local winsizePix = director:getWinSizeInPixels()
        --dump(winsizePix,"winsizePix")
        local currentX =  self._LevelNode:getPositionX()
        local currentY = self._LevelNode:getPositionY()

        currentX = currentX + deltaX
        if currentX >= -(self._LevelSize.width * self._LevelNode:getScale() - winsize.width - winsize.width * self._LevelNode:getScale() / 2) and currentX <= winsize.width / 2 *self._LevelNode:getScale() then
            self._LevelNode:setPosition(currentX, currentY)
        end
    end
end
--更新位置X
function GameLevelPVPEntity:UpdateX(scaletmp)
    if self._LevelNode ~= nil then
        local winsize =  director:getWinSize()
        local currentX =  self._LevelNode:getPositionX()
        if currentX <= (- self._LevelSize.width * scaletmp + winsize.width + winsize.width * scaletmp / 2)  then
            currentX = (- self._LevelSize.width * scaletmp + winsize.width + winsize.width * scaletmp / 2)
            self._LevelNode:setPositionX(currentX) 
        elseif currentX >= winsize.width / 2 * scaletmp then
            currentX = winsize.width / 2 * scaletmp
            self._LevelNode:setPositionX(currentX)
        end
    end
end

--缩放
function GameLevelPVPEntity:setScale(scale)
    if self._LevelNode ~= nil then
        self._LevelNode:setScale(scale)
    end
end
--更新UI位置
function GameLevelPVPEntity:UpdateUIPosition(position)

end

return GameLevelPVPEntity