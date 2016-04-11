----
-- 文件名称：ActorSkillEntity.lua
-- 功能描述：角色 技能  显示相关
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-11-12
    

local mathAbs = math.abs
local mathCeil = math.ceil
local mathSqrt = math.sqrt
local mathCos = math.cos
local mathSin = math.sin
local stringFind = string.find
local stringSub = string.sub
local TableDataManager =  GameGlobal:GetDataTableManager()
local SkillAttackTable = TableDataManager:GetSkillAttackDataManager()
local SkillDataManager = TableDataManager:GetSkillDataManager()

local skillEffectCSBPath = "csb/texiao/pugong/"  
local ActorSkillEntity = 
{
    
}

function ActorSkillEntity:Clear()
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
    --GUID
    self._GUID = 0
    --技能类型
    self._SkillType = 0
    --是否结束
    self._IsFinished = false
    --普攻轨迹运动结束后的结尾动画
    self._MoveEndAnimCSBName = ""
end

--初始化
function ActorSkillEntity:Init(guid, skillTableID, csbFileName, skillType)
    self._GUID = guid
    self._SkillType = skillType
    if csbFileName ~= "" and csbFileName ~= "0" then
        self._SkillRootNode = cc.CSLoader:createNode(csbFileName)
        if self._SkillRootNode ~= nil then
            self._SkillRootNode:retain()
        end
        if skillType == SkillType.SkillType_ManualPut then
            self._ManualSkillHurtLabel = cc.Label:createWithTTF("", "fonts/arial.ttf", 27)
            self._ManualSkillHurtLabel:retain()
            self._SkillRootNode:addChild(self._ManualSkillHurtLabel)
        elseif skillType == SkillType.SkillType_Attack then
            self._SkillThrowSelfCocosAnim = cc.CSLoader:createTimeline(csbFileName)
            if self._SkillThrowSelfCocosAnim ~= nil then
                self._SkillThrowSelfCocosAnim:retain()
            end
        end
    end
end

--销毁 
function ActorSkillEntity:Destroy()
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
function ActorSkillEntity:InitSkillMoveAnim(senderX, senderY,targetX,targetY, pathType, offsetX, offsetY, bulletMoveSpeed, middleFactor, moveEndAnimName)
    if self._SkillThrowAnim == nil then
        local directionX  = 1
        if targetX - senderX < 0  then
            directionX = -1
            offsetX = -offsetX
        else
            directionX = 1
        end
        if targetY == senderY then
            targetY = targetY + 1
        end
        local useTime = 1
        local startPos =  cc.p(senderX + offsetX, senderY + offsetY)
        local endPos = cc.p(targetX, targetY)
        self._MoveEndDestPosition = endPos
        self._MoveEndAnimCSBName = moveEndAnimName
        local twoPointDistance = cc.pGetDistance(startPos, endPos)
        if bulletMoveSpeed ~= nil and bulletMoveSpeed ~= 0 then
            useTime = twoPointDistance / bulletMoveSpeed
            --useTime =  self._BulletMoveSpeed 
        end
        local degreeForRadion = 57.32
        local radionForDegree = 0.017
        --抛物线运动的
        if pathType == SkillPathType.SkillPathType_Bezier then
            local middleY = senderY + (targetY - senderY) / 2
            local middleX = senderX + (targetX - senderX) / 2
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
function ActorSkillEntity:GetSkillMoveAnim()
    return self._SkillThrowAnim 
end
--创建技能运动结束的动画
function ActorSkillEntity:CreateSkillMoveEndAnim(moveEndAnimCSBName)
    if moveEndAnimCSBName == "" or moveEndAnimCSBName == "0" then
        return 
    end
    if self._MoveEndSkillEffectNode == nil then
        self._MoveEndSkillEffectNode = cc.CSLoader:createNode(skillEffectCSBPath .. moveEndAnimCSBName)
        if  self._MoveEndSkillEffectNode ~= nil then
            self._MoveEndSkillEffectNode:retain()
            local parentNode = self._SkillRootNode:getParent()
            if parentNode ~= nil then
                parentNode:addChild(self._MoveEndSkillEffectNode, 2000)
                local newOrder = self._MoveEndDestPosition.y
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
function ActorSkillEntity:GetSkillRootNode()
    return self._SkillRootNode
end
--轨迹运动结束后的动画
function ActorSkillEntity:GetMoveEndSkillAnim()
    return self._MoveEndSkillEffectAnim
end
--运动动画是否结束
function ActorSkillEntity:IsSkillMoveEnd()
    if self._SkillThrowAnim == nil then
        return true
    end
    return self._SkillThrowAnim:isDone()
end

--移动结束后的动画是否结束
function ActorSkillEntity:IsMoveEndAnimFinish()
    if self._MoveEndSkillEffectAnim == nil then
        return true
    end
    if self._MoveEndSkillEffectAnim:getCurrentFrame() >= self._MoveEndSkillEffectAnim:getEndFrame() then
        return true
    end
    return false
end
--是否结束
function ActorSkillEntity:IsFinished()
    return self._IsFinished
end
--更新遮挡关系
function ActorSkillEntity:UpdateOrder()
    if self._SkillRootNode ~= nil then
        local positionY = self._SkillRootNode:getPositionY()
        local parentNode = self._SkillRootNode:getParent()
        if parentNode ~= nil then
            parentNode:reorderChild(self._SkillRootNode, 2000 - positionY)
        end
    end
end

--
function ActorSkillEntity:Update()
    local skillType = self._SkillType
    if skillType == SkillType.SkillType_Attack then
        local throwAnim = self._SkillThrowAnim
        if throwAnim ~= nil then
            if throwAnim:isDone() then
                self:CreateSkillMoveEndAnim(self._MoveEndAnimCSBName)
                self._IsFinished = true
            end
        else
            self._IsFinished = true
        end
    end
end

return ActorSkillEntity
