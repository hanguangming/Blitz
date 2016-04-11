----
-- 文件名称：SkillPVPEntity.lua
-- 功能描述：战斗技能显示部分（PVP里只处理普攻就可以了）
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-9-29
--  修改：
--  

local mathAbs = math.abs
local mathCeil = math.ceil
local mathSqrt = math.sqrt
local mathCos = math.cos
local mathSin = math.sin
local stringFind = string.find
local stringSub = string.sub

local skillEffectCSBPath = "csb/texiao/pugong/"  
local SkillPVPEntity = class("SkillPVPEntity")

function SkillPVPEntity:ctor()
    --运动轨迹落地点
    self._MoveEndDestPosition = nil
    --技能根节点
    self._SkillRootNode = nil
    --投掷类技能动画
    self._SkillThrowAnim = nil
    --投掷类物体自身的动画
    self._SkillThrowSelfCocosAnim = nil
    --手动施放类技能动画
    self._ManualSkillAnim = nil
    --手动施放类技能Sprite
    self._ManualSkillSprite = nil
    --手动施放类技能的伤害数字显示
    self._ManualSkillHurtLabel = nil
    --动画，运动轨迹完成后的特效动画
    self._MoveEndSkillEffectNode = nil
    self._MoveEndSkillEffectAnim = nil
end

--初始化
function SkillPVPEntity:Init(csbFileName, skillType)
    if csbFileName ~= "" and csbFileName ~= "0" then
        self._SkillRootNode = cc.CSLoader:createNode(csbFileName)
        if self._SkillRootNode ~= nil then
            self._SkillRootNode:retain()
        end
        if skillType == SkillType.SkillType_ManualPut then
            self._ManualSkillHurtLabel = cc.Label:createWithTTF("", "fonts/arial.ttf", 27)
            self._ManualSkillHurtLabel:retain()
            self._SkillRootNode:addChild(self._ManualSkillHurtLabel)
        end
        if skillType == SkillType.SkillType_Attack then
            self._SkillThrowSelfCocosAnim = cc.CSLoader:createTimeline(csbFileName)
            if self._SkillThrowSelfCocosAnim ~= nil then
                self._SkillThrowSelfCocosAnim:retain()
            end
        end
    end
end

--销毁 
function SkillPVPEntity:Destroy()
    if self._SkillThrowAnim ~= nil then
        self._SkillThrowAnim:release()
        self._SkillThrowAnim = nil
    end
    if self._ManualSkillAnim ~= nil then
        self._ManualSkillAnim:release()
        self._ManualSkillAnim = nil
    end

    if self._ManualSkillHurtLabel ~= nil then
        self._ManualSkillHurtLabel:release()
        self._ManualSkillHurtLabel = nil
    end
    if self._MoveEndSkillEffectAnim ~= nil then
        self._MoveEndSkillEffectAnim:release()
        self._MoveEndSkillEffectAnim = nil
    end
    if self._MoveEndSkillEffectNode ~= nil then
        self._MoveEndSkillEffectNode:removeFromParent()
        self._MoveEndSkillEffectNode:removeAllChildren()
        self._MoveEndSkillEffectNode:release()
        self._MoveEndSkillEffectNode = nil
    end
    if self._SkillThrowSelfCocosAnim ~= nil then
        self._SkillThrowSelfCocosAnim:release()
        self._SkillThrowSelfCocosAnim = nil
    end
    if self._SkillRootNode ~= nil then
        self._SkillRootNode:removeFromParent()
        self._SkillRootNode:removeAllChildren()
        self._SkillRootNode:release()
        self._SkillRootNode = nil
    end
end

--创建动画
function SkillPVPEntity:InitSkillMoveAnim(sendCharacter, targetCharacter, pathType, offsetX, offsetY, bulletMoveSpeed, middleFactor)
    if self._SkillThrowAnim == nil then
        local directionX  = 1
        if targetCharacter._CharacterPositionX - sendCharacter._CharacterPositionX < 0  then
            directionX = -1
            offsetX = -offsetX
        else
            directionX = 1
        end
        if targetCharacter._CharacterPositionY == sendCharacter._CharacterPositionY then
            targetCharacter._CharacterPositionY = targetCharacter._CharacterPositionY + 1
        end
        local useTime = 1
        local startPos =  cc.p(sendCharacter._CharacterPositionX + offsetX, sendCharacter._CharacterPositionY + offsetY)
        local endPos = cc.p(targetCharacter._CharacterPositionX, targetCharacter._CharacterPositionY)
        self._MoveEndDestPosition = endPos
        local twoPointDistance = cc.pGetDistance(startPos, endPos)
        if bulletMoveSpeed ~= nil and bulletMoveSpeed ~= 0 then
            useTime = twoPointDistance / bulletMoveSpeed
            --useTime =  self._BulletMoveSpeed 
        end
        local degreeForRadion = 57.32
        local radionForDegree = 0.017
        --抛物线运动的
        if pathType == SkillPathType.SkillPathType_Bezier then
            local middleY = sendCharacter._CharacterPositionY + (targetCharacter._CharacterPositionY - sendCharacter._CharacterPositionY) / 2
            local middleX = sendCharacter._CharacterPositionX + (targetCharacter._CharacterPositionX - sendCharacter._CharacterPositionX) / 2
            local middlePos = cc.p(middleX, middleY)
            local startToEndDir = cc.pSub(endPos, startPos)
            startToEndDir = cc.pNormalize(startToEndDir)
            local radionStartToEnd = cc.pToAngleSelf(startToEndDir)
            local degreeStartToEnd = radionStartToEnd * degreeForRadion
            local vertexHeight = twoPointDistance *  middleFactor * mathAbs(mathCos(radionStartToEnd))
            local sinAngle = mathSin(radionStartToEnd)
            local cosAngle = mathCos(radionStartToEnd)
            --print("InitSkillMoveAnim ", radionStartToEnd, degreeStartToEnd, vertexHeight, sinAngle, cosAngle)
            --值较正
            --右下
            if startToEndDir.x > 0 and startToEndDir.y < 0 then
                sinAngle = -sinAngle
                cosAngle = cosAngle
                --右上
            elseif startToEndDir.x > 0 and startToEndDir.y > 0 then
                sinAngle = -sinAngle
                cosAngle = cosAngle
                --左上
            elseif startToEndDir.x < 0 and startToEndDir.y > 0 then
                sinAngle = sinAngle
                cosAngle = -cosAngle
            elseif startToEndDir.x < 0 and startToEndDir.y < 0 then 
                sinAngle = sinAngle
                cosAngle = -cosAngle
            end
            --print("fix.... ", radionStartToEnd, degreeStartToEnd, vertexHeight, sinAngle, cosAngle)
            
            middlePos.x = middleX + vertexHeight * sinAngle
            middlePos.y = middleY + vertexHeight * cosAngle
            --printInfo("ori middle: %d %d start: %d %d end: %d %d", middleX, middleY, sendCharacter._CharacterPositionX, sendCharacter._CharacterPositionY, targetCharacter._CharacterPositionX, targetCharacter._CharacterPositionY)
            --printInfo("middlePos: %d %d, angle:%.2f degree:%d %.2f %.2f", middlePos.x, middlePos.y, radionStartToEnd, degreeStartToEnd, sinAngle, cosAngle)
            local bezier2 ={
                startPos,
                middlePos,
                endPos
            }

            local bezierTo1 = cc.BezierTo:create(useTime, bezier2)
            --旋转
            local dirStart = cc.pSub(middlePos,startPos)
            dirStart = cc.pNormalize(dirStart)
            local dirEnd = cc.pSub(endPos, middlePos)
            dirEnd =  cc.pNormalize(dirEnd)
            local rotateAngleStart = -1 * cc.pToAngleSelf(dirStart) * degreeForRadion 
            local rotateAngleEnd = -1 * cc.pToAngleSelf(dirEnd) * degreeForRadion 
            local skillSprite = nil
            if self._SkillRootNode ~= nil then
                skillSprite = self._SkillRootNode:getChildByTag(1)
                self._SkillRootNode:setPosition(startPos)
                self._SkillRootNode:setRotation(rotateAngleStart)
            end 
            local actionTo = cc.RotateTo:create( useTime, rotateAngleEnd)
            self._SkillThrowAnim = cc.Spawn:create(bezierTo1, actionTo)
            self._SkillThrowAnim:retain()
            self._SkillRootNode:runAction(self._SkillThrowAnim)
            if self._SkillThrowSelfCocosAnim ~= nil then
                self._SkillThrowSelfCocosAnim:play("Skill", true)
                skillSprite:runAction(self._SkillThrowSelfCocosAnim)
            end
            --printInfo("rotate: %d %d", rotateAngleStart, rotateAngleEnd)
            --直线运动的
        elseif pathType == SkillPathType.SkillPathType_Line then
            local dir = cc.pSub(endPos, startPos)
            dir = cc.pNormalize(dir)
            local angleRotate = cc.pToAngleSelf(dir) * degreeForRadion
            local skillSprite = nil
            if self._SkillRootNode ~= nil then
                self._SkillRootNode:setRotation(-1 * angleRotate)
                self._SkillRootNode:setPosition(startPos)
                skillSprite =  self._SkillRootNode:getChildByTag(1)
            end
            local actionTo = cc.MoveTo:create(useTime, endPos)
            self._SkillThrowAnim = actionTo
            self._SkillThrowAnim:retain()
            self._SkillRootNode:runAction(self._SkillThrowAnim)
            if self._SkillThrowSelfCocosAnim ~= nil then
                self._SkillThrowSelfCocosAnim:play("Skill", true)
                skillSprite:runAction(self._SkillThrowSelfCocosAnim)
            end
        end                   
    else

    end
end

--技能运动结束后的结尾动画
function SkillPVPEntity:GetSkillMoveAnim()
    return self._SkillThrowAnim 
end
--创建技能运动结束的动画
function SkillPVPEntity:CreateSkillMoveEndAnim(moveEndAnimCSBName)
    if moveEndAnimCSBName == "" or moveEndAnimCSBName == "0" then
        return 
    end
    if self._MoveEndSkillEffectNode == nil then
        self._MoveEndSkillEffectNode = cc.CSLoader:createNode(skillEffectCSBPath .. moveEndAnimCSBName)
        if  self._MoveEndSkillEffectNode ~= nil then
            self._MoveEndSkillEffectNode:retain()
            self._SkillRootNode:setVisible(false)
            local parentNode = self._SkillRootNode:getParent()
            if parentNode ~= nil then
                parentNode:addChild(self._MoveEndSkillEffectNode)
                local newOrder = -self._MoveEndDestPosition.y
                parentNode:reorderChild(self._MoveEndSkillEffectNode, newOrder)
                self._MoveEndSkillEffectNode:setPosition(self._MoveEndDestPosition) 
            end
            --动画创建
            self._MoveEndSkillEffectAnim = cc.CSLoader:createTimeline(skillEffectCSBPath .. moveEndAnimCSBName)
            if self._MoveEndSkillEffectAnim ~= nil then
                self._MoveEndSkillEffectAnim:retain()
                self._MoveEndSkillEffectNode:runAction(self._MoveEndSkillEffectAnim)
                self._MoveEndSkillEffectAnim:play("EndAnim", false)
            end
        end
    end
end

--获取根节点
function SkillPVPEntity:GetSkillRootNode()
    return self._SkillRootNode
end
--轨迹运动结束后的动画
function SkillPVPEntity:GetMoveEndSkillAnim()
    return self._MoveEndSkillEffectAnim
end
--运动动画是否结束
function SkillPVPEntity:IsSkillMoveEnd()
    if self._SkillThrowAnim == nil then
        return true
    end
    return self._SkillThrowAnim:isDone()
end

--移动结束后的动画是否结束
function SkillPVPEntity:IsMoveEndAnimFinish()
    if self._MoveEndSkillEffectAnim == nil then
        return true
    end
    return self._MoveEndSkillEffectAnim:getCurrentFrame() >= self._MoveEndSkillEffectAnim:getEndFrame()
end

--更新遮挡关系
function SkillPVPEntity:UpdateOrder()
    if self._SkillRootNode ~= nil then
        local positionY = self._SkillRootNode:getPositionY()
        local parentNode = self._SkillRootNode:getParent()
        if parentNode ~= nil then
            parentNode:reorderChild(self._SkillRootNode, -positionY)
        end
    end
end

return SkillPVPEntity
