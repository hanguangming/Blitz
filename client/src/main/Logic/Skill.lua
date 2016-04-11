----
-- 文件名称：Skill.lua
-- 功能描述：战斗技能
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-4-27
--  修改：
-- 制作规范：手动施放的技能sprite的tag值为: 1
--          武将技能动画名称为：Skill
--          发射的物体序列帧动画名字 texiao
--          移动结束后的动画特效：动画名字：EndAnim
--  
--Demo 临时数据  TODO：将数据提取到.txt文件
local skillEffectCSBPath = "csb/texiao/pugong/"
local SkillBuffManager = require("main.Logic.SkillBuffManager")
local CharacterManager = nil

local SkillType = 
{
    --投掷类技能：如弓箭，炮弹等,老的形式将去掉
    SkillType_Throw = 0,
    --简单的普攻
    SkillType_Attack = 1,
    --手动放置类(武将技)
    SkillType_ManualPut = 2,
}
--运动轨迹
local SkillPathType =
{
    --直线
    SkillPathType_Line = 1,
    --抛物线
    SkillPathType_Bezier = 2,
}

local mathAbs = math.abs
local TableDataManager = GameGlobal:GetDataTableManager()
local SkillDataManager = TableDataManager:GetSkillDataManager()
local SoldierRelationDataManager = TableDataManager:GetSoldierRelationDataManager()
local SkillTipDataManager = TableDataManager:GetSkillPosDataManager()
local mathCeil = math.ceil
local mathSqrt = math.sqrt
local mathCos = math.cos
local mathSin = math.sin
local stringFind = string.find
local stringSub = string.sub
local Skill = class("Skill")
local GameBattle = nil
local hurt = 20 * gHurtFactor
--构造
--skillTableID:表格ID
--senderID:施放者ID
--targetID:目标ID
function Skill:ctor(skillTableID, senderID, targetID, isLeaderSkill, skillHurtFactor)
    --print("skillTableID ", skillTableID)
    --表格数据
    self._SkillTableData = SkillDataManager[skillTableID]
    --技能表格ID
    self._SkillTableID = skillTableID
    --施放者ID
    self._SenderID = senderID
    --目标ID
    self._TargetID = targetID
    --施术者TableID
    self._SenderTableID = 0
    --目标TableID
    self._TargetTableID = 0
    --技能根节点
    self._SkillRootNode = nil
    --技能形状类型
    self._SkillShapeType = -1
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
    --技能唯一标识
    self._ClientGUID = 0
    --当前持续时间
    self._CurrentTrigerTime = 0
    --触发伤害的时间
    self._TrigerTime = 0 --self._SkillTableData.trigerTime
    self._AnimLengthHalf = 0
    --触发总次数
    self._TrigerTotalCount = 1
    --当前触发次数
    self._CurrentTrigerCount = 0
    --触发时间
    self._SenderIsEnemy = false
    --技能类型
    if isLeaderSkill == nil or isLeaderSkill == false then
        self._SkillType = SkillType.SkillType_Attack
    else
        self._SkillType = SkillType.SkillType_ManualPut
    end
    --初始技能位置
    self._InitPositionX = 0
    self._InitPositionY = 0
    --施法者的攻 击力
    self._SenderAttack = 0
    --作用范围类型
    self._ZoneType = 0
    --子弹飞行速度
    self._BulletMoveSpeed = 0
    --子弹路径类型(1:直线  2：抛物线)
    self._BulletPathType = 2
    --子弹 中间点系数
    self._MiddleFactor = 1
    --攻击动画时长,多长时间后触发伤害
    self._AttackAnimLength = 0
    --初始偏移X
    self._InitOffsetX = 0
    --初始偏移Y
    self._InitOffsetY = 0
    --结束动画
    self._ThrowSkillFinishAnimCSBName = "0"
    --动画，运动轨迹完成后的特效动画
    self._MoveEndSkillEffectNode = nil
    self._MoveEndSkillEffectAnim = nil
    --轨迹运动的目标位置
    self._MoveEndDestPosition = nil
    --是否结束
    self._IsFinished = false
    --群攻技能的作用范围 
    self._ZoneX = 0
    self._ZoneY = 0
    --buff list
    self._BuffIDList = 0
    --是否已创建Buff
    self._IsCreateBuff = false
    --技能伤害系数
    if isLeaderSkill == false then
        self._SkillHurtFactor = 1
    else
        self._SkillHurtFactor = skillHurtFactor / 100
    end
    --当前震屏次数
    self._CurrentShakeCount = 0
    self._ShakeCount = 2
    self._IsShake = false    
    self._SkillEffectCSBFileName = ""
    self:Init()
end

--初始化
function Skill:Init()
    self._SkillShapeType = self._SkillTableData.shapeType
    --BuffID List
    local currentString = self._SkillTableData.bufflist
   -- print("bufflist currentString: ", currentString)
    --临时测试用，当表格里没配置时，强制写一个
    if currentString == "" or currentString == nil or currentString == "0" then
       --currentString = "(4003,3003)"
    end
    self._BuffIDList = {}
    --合并列 去掉了
    --[[
    if currentString ~= nil and currentString ~= "0" and currentString ~= "" then
        local tagPosStart = stringFind(currentString,"%(")
        local tagPosEnd = stringFind(currentString,"%)")
        local info = stringSub(currentString, tagPosStart + 1, tagPosEnd - 1)
        local idStrList = Split(info, ",")
        if idStrList ~= nil then
            for k, v in pairs(idStrList)do
                self._BuffIDList[k] = tonumber(v) 
            end
        end
    end
    ]]--
    local currentIndex = 0
    for i = 1, 6 do
        local fieldName = "buff" .. tostring(i)
        local value = self._SkillTableData[fieldName]
        if value ~= 0 then
            currentIndex = currentIndex + 1
            self._BuffIDList[currentIndex] = value
        end
    end
    self._SkillEffectCSBFileName = GetSkillCSBName(self)
    --print("self._SkillEffectCSBFileName: ", self._SkillEffectCSBFileName, self._SkillTableID)
    --初始化 csb 
    if self._SkillType == SkillType.SkillType_ManualPut  then
        --武将技时如果表格中未配置csb,程序赋一默认值
        if self._SkillEffectCSBFileName == "" or self._SkillEffectCSBFileName == "0" then
            print("wujiang skill error: _SkillEffectCSBFileName invalid ", self._SkillTableID)
            self._SkillEffectCSBFileName = "csb/texiao/jineng/22001.csb"
        end
    end

    if self._SkillEffectCSBFileName ~= "" and self._SkillEffectCSBFileName ~= "0" then
        self._SkillRootNode = cc.CSLoader:createNode(self._SkillEffectCSBFileName)
        if self._SkillRootNode ~= nil then
            self._SkillRootNode:retain()
        end

        if self._SkillType == SkillType.SkillType_ManualPut then
            self._ManualSkillHurtLabel = cc.Label:createWithTTF("", "fonts/arial.ttf", 27)
            self._ManualSkillHurtLabel:retain()
            self._SkillRootNode:addChild(self._ManualSkillHurtLabel, 1000)
        end
        if self._SkillType == SkillType.SkillType_Attack then
             self._SkillThrowSelfCocosAnim = cc.CSLoader:createTimeline(self._SkillEffectCSBFileName)
             if self._SkillThrowSelfCocosAnim ~= nil then
                self._SkillThrowSelfCocosAnim:retain()
             end
        end
    end

    if CharacterManager == nil then
        CharacterManager = require("main.Logic.CharacterManager")
    end
    local sendCharacter = CharacterManager:GetCharacterByClientID(self._SenderID) 
    local targetCharacter = CharacterManager:GetCharacterByClientID(self._TargetID)
    if sendCharacter ~= nil then
        self._SenderAttack = sendCharacter._Attack
        self._InitPositionX = sendCharacter._CharacterPositionX
        self._InitPositionY = sendCharacter._CharacterPositionY
        self._SenderIsEnemy = sendCharacter._IsEnemy
        self._SenderTableID = sendCharacter._CharacterTableID
    end
    if targetCharacter ~= nil then
        self._TargetTableID = targetCharacter._CharacterTableID
    end
    
    --初始化攻击参数：
    self._ZoneX = 20
    self._ZoneY = 20
    self._ZoneType = self._SkillTableData.zoneType
    local posData = SkillTipDataManager[self._ZoneType]
    self._SkillPosZone = posData
    if posData ~= nil then
        self._ZoneX = posData.x * SIZE_ONE_TILE
        self._ZoneY = posData.y * SIZE_ONE_TILE
    else
        printError("config skillpos.txt error invalid type skillTableID: %d", self._SkillTableID)
    end

    local skillAttackTable = TableDataManager:GetSkillAttackDataManager()
    local skillAttackParam = skillAttackTable[self._SkillTableID]
    if skillAttackParam ~= nil then
        self._BulletMoveSpeed = skillAttackParam._MoveSpeed
        self._BulletPathType = skillAttackParam._Path
        self._MiddleFactor = skillAttackParam._MiddleFactor
        self._AttackAnimLength = skillAttackParam._HurtHitTime
        self._InitOffsetX = skillAttackParam._OffsetX
        self._InitOffsetY = skillAttackParam._OffsetY
        self._ThrowSkillFinishAnimCSBName = skillAttackParam._EndAnimCSBName
    end
    if sendCharacter ~= nil then
        if self._AttackAnimLength ~= nil then
            self._AttackAnimLength = self._AttackAnimLength * (1 / sendCharacter:GetAttackAnimSpeed())
        end
    end
    --伤害触发时机,武将技，近战普攻强制改为0
     if self._SkillType == SkillType.SkillType_ManualPut then
        self._AttackAnimLength = 0
     elseif self._SkillType == SkillType.SkillType_Attack then
        if self._SkillEffectCSBFileName == "" or self._SkillEffectCSBFileName == "0" then
            self._AttackAnimLength = 0
        end 
     end
end

--销毁
function Skill:Destroy()
    --print("Skill:Destroy ", self._ClientGUID)
    self._SkillTableData = nil
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
        self._SkillRootNode:removeAllChildren()        
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
    
    self._MoveEndDestPosition = nil
    self._BuffIDList = nil
end
--
local function GetSoldierRelation(senderID, targetID)
    local sendCharacter = CharacterManager:GetCharacterByClientID(senderID) 
    local targetCharacter = CharacterManager:GetCharacterByClientID(targetID)
    local soldierRelationFactor = 1
    local selfType = 0
    local destType = 0
    if sendCharacter ~= nil then
        selfType = sendCharacter._CharacterData.soldierType
    end
    if targetCharacter ~= nil then
        if targetCharacter._CharacterData ~= nil then
            destType = targetCharacter._CharacterData.soldierType
        end
    end
    local relationData = SoldierRelationDataManager[selfType]
    if relationData ~= nil then
        if relationData[tostring(destType)] ~= nil then
            soldierRelationFactor = relationData[tostring(destType)]
        end
    end 
    --print("soldierRelationFactor", soldierRelationFactor, selfType, destType)
    return soldierRelationFactor
end

--计算伤害
function Skill:CalcHurtNumber(targetCharacter, senderID, targetID)
     local hurt = 0
     local totalHurt = 0
     if self._ZoneType == AttackType.AttackType_DanTi then
         --正式的
        local soldierRelationFactor = GetSoldierRelation(senderID, targetID)
        --LogSystem:WriteLog("CalcHurtNumber AttackType_DanTi enter factor:%d ", soldierRelationFactor)
        if self._SenderAttack ~= nil then
            hurt = self._SenderAttack * gHurtFactor * soldierRelationFactor * self._SkillHurtFactor 
            hurt = mathCeil(hurt)
        end
        if targetCharacter ~= nil then
            local currentHp = targetCharacter:GetCurrentHP()
            currentHp = currentHp - hurt 
            targetCharacter:SetCurrentHP(currentHp)
            --LogSystem:WriteLog("Hurt danTi sender:%d --> target:%d  pos(%d,%d) hurt:%d nowHP:%d", self._SenderTableID, self._TargetTableID, targetCharacter._CharacterPositionX, targetCharacter._CharacterPositionY, hurt, currentHp)
        end
        --可能计算不正错的值
        if hurt <= 5 then
            printInfo("hurt:%d skill:%d factor:%d", hurt, self._SkillTableID, soldierRelationFactor)
        end
        return hurt
     else
        local currentLevel = GameGlobal:GetGameLevel()
        if currentLevel ~= nil then
            --LogSystem:WriteLog("start calc %d..................", self._ClientGUID)
            local enemyIDList = nil
            if self._SenderIsEnemy == true then
                enemyIDList = currentLevel._SelfSoldierIDList
            else
                enemyIDList = currentLevel._EnemySoldierIDList
            end
            for k, v in pairs(enemyIDList)do
                -- print("false ", v)
                local curCharacter = CharacterManager:GetCharacterByClientID(v)
                if curCharacter ~= nil then
                    local skillPositionX = self._InitPositionX
                    local skillPositionY = self._InitPositionY
                    if self._SkillRootNode ~= nil then
                        skillPositionX = self._SkillRootNode:getPositionX()
                        skillPositionY = self._SkillRootNode:getPositionY()
                    end
                    local soldierRelationFactor = GetSoldierRelation(senderID, targetID)
                    if self._SenderAttack ~= nil then
                        hurt = self._SenderAttack * gHurtFactor * soldierRelationFactor * self._SkillHurtFactor 
                        hurt = mathCeil(hurt)
                    end
                    --LogSystem:WriteLog("hurt:%d attack:%d factor:%d rFactor:%d  sFactor: %d", hurt, self._SenderAttack, gHurtFactor, soldierRelationFactor, self._SkillHurtFactor)
                    local posXOffset = curCharacter._CharacterPositionX - skillPositionX
                    local posYOffset = curCharacter._CharacterPositionY - skillPositionY
                    if  mathAbs(posXOffset) <= self._ZoneX / 2  and mathAbs(posYOffset) <= self._ZoneY / 2 then
                        local currentHp = curCharacter:GetCurrentHP()
                        currentHp = currentHp - hurt
                        curCharacter:SetCurrentHP(currentHp)
                        totalHurt = totalHurt + hurt
                        --LogSystem:WriteLog("ID:%d Hurt qunTi sender:%d pos(%d,%d) --> target:%d pos(%d,%d) hurt:%d nowHP: %d totalHp: %d", self._ClientGUID, self._SenderTableID, skillPositionX, skillPositionY, curCharacter._CharacterTableID, curCharacter._CharacterPositionX, curCharacter._CharacterPositionY, hurt, currentHp,curCharacter._TotalHP)
                    end
                end
            end
            --LogSystem:WriteLog("finish calc .........................", self._ClientGUID)
        end
        --printInfo("totalHurt %d", totalHurt)
        return totalHurt
     end
end

--填充作用目标(作用目标列表,根据技能作用范围，计算Buff的作用目标列表)
function Skill:SelectBuffTargetList(targetList)
    if targetList == nil then
        return
    end
    if self._ZoneType == AttackType.AttackType_DanTi then
        targetList[1] = self._TargetID
    else
        local currentLevel = GameGlobal:GetGameLevel()
        local currentTargetIndex = 1
        if currentLevel ~= nil then
            local enemyIDList = nil
            if self._SenderIsEnemy == true then
                enemyIDList = currentLevel._SelfSoldierIDList
            else
                enemyIDList = currentLevel._EnemySoldierIDList
            end
            for k, v in pairs(enemyIDList)do
                -- print("false ", v)
                local curCharacter = CharacterManager:GetCharacterByClientID(v)
                if curCharacter ~= nil then
                    local skillPositionX = self._InitPositionX
                    local skillPositionY = self._InitPositionY
                    if self._SkillRootNode ~= nil then
                        skillPositionX = self._SkillRootNode:getPositionX()
                        skillPositionY = self._SkillRootNode:getPositionY()
                    end
                    local posXOffset = curCharacter._CharacterPositionX - skillPositionX
                    local posYOffset = curCharacter._CharacterPositionY - skillPositionY
                    if  mathAbs(posXOffset) <= self._ZoneX / 2  and mathAbs(posYOffset) <= self._ZoneY / 2 then
                        targetList[currentTargetIndex] = v
                        currentTargetIndex = currentTargetIndex + 1
                    end
                end
            end
        end
    end
end
--帧更新
function Skill:Update(deltaTime)
    if self._IsFinished == true then
        return
    end
    self._CurrentTrigerTime = self._CurrentTrigerTime + deltaTime

     if self._IsCreateBuff == false then
        self._IsCreateBuff = true
        --如果 Buff不为空，加Buff
        if self._BuffIDList ~= 0 and self._BuffIDList ~= nil then
            for k, v in pairs(self._BuffIDList)do
                local newBuff = SkillBuffManager:CreateBuff(v, self._SenderID, self._ClientGUID, self)
            end
        end
     end
    
    --普攻
    if self._SkillType == SkillType.SkillType_Attack then
        ---无表现的普攻只是在特定的时间产生伤害值
        if self._SkillEffectCSBFileName == "" or self._SkillEffectCSBFileName == "0" then
            --普攻无表现的
            if self._CurrentTrigerTime >=  self._AttackAnimLength then
                local sendCharacter = CharacterManager:GetCharacterByClientID(self._SenderID) 
                local targetCharacter = CharacterManager:GetCharacterByClientID(self._TargetID)
                if targetCharacter ~= nil then
                    self:CalcHurtNumber(targetCharacter, self._SenderID, self._TargetID)
                end
                self._IsFinished = true
            end
       --有表现的普攻会投掷出弓箭,炮弹,火球等
        else
            if self._SkillRootNode == nil then
                self._SkillRootNode = cc.CSLoader:createNode(self._SkillEffectCSBFileName)
                self._SkillRootNode:retain()
            end
            if self._SkillThrowSelfCocosAnim == nil then
                self._SkillThrowSelfCocosAnim = cc.CSLoader:createTimeline(self._SkillEffectCSBFileName)
                if self._SkillThrowSelfCocosAnim ~= nil then
                    self._SkillThrowSelfCocosAnim:retain()
                end
            end

             if self._CurrentTrigerTime <  self._AttackAnimLength then
                return
             end
            --普攻有表现的
            local sendCharacter = CharacterManager:GetCharacterByClientID(self._SenderID) 
            local targetCharacter = CharacterManager:GetCharacterByClientID(self._TargetID)
            if self._SkillThrowAnim == nil then
                if sendCharacter == nil or targetCharacter == nil then
                    self._IsFinished = true
                    return
                end
                local offsetX = self._InitOffsetX
                local offsetY = self._InitOffsetY
                local directionX  = 1
                if targetCharacter._CharacterPositionX - sendCharacter._CharacterPositionX < 0  then
                    directionX = -1
                    offsetX = -offsetX
                else
                    directionX = 1
                end
                local useTime = 1
                local startPos =  cc.p(sendCharacter._CharacterPositionX + offsetX, sendCharacter._CharacterPositionY + offsetY)
                local endPos = cc.p(targetCharacter._CharacterPositionX, targetCharacter._CharacterPositionY)
                self._MoveEndDestPosition = endPos
                local twoPointDistance = cc.pGetDistance(startPos, endPos)
                if self._BulletMoveSpeed ~= nil and self._BulletMoveSpeed ~= 0 then
                    useTime = twoPointDistance / self._BulletMoveSpeed 
                    --useTime =  self._BulletMoveSpeed 
                end
                local degreeForRadion = 57.32
                local radionForDegree = 0.017
                --抛物线运动的
                if self._BulletPathType == SkillPathType.SkillPathType_Bezier then
                    local middleY = sendCharacter._CharacterPositionY + (targetCharacter._CharacterPositionY - sendCharacter._CharacterPositionY) / 2
                    local middleX = sendCharacter._CharacterPositionX + (targetCharacter._CharacterPositionX - sendCharacter._CharacterPositionX) / 2
                    local middlePos = cc.p(middleX, middleY)
                    local startToEndDir = cc.pSub(endPos, startPos)
                    startToEndDir = cc.pNormalize(startToEndDir)
                    local radionStartToEnd = cc.pToAngleSelf(startToEndDir)
                    local degreeStartToEnd = radionStartToEnd * degreeForRadion
                    local vertexHeight = twoPointDistance *  self._MiddleFactor * mathAbs(mathCos(radionStartToEnd))
                    local sinAngle = mathSin(radionStartToEnd)
                    local cosAngle = mathCos(radionStartToEnd)
                    
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
                elseif self._BulletPathType == SkillPathType.SkillPathType_Line then
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
                --下面为测试立即触发伤害的情况
               --self:CalcHurtNumber(targetCharacter, self._SenderID, self._TargetID)
            else
                --普攻发射的弓箭炮弹等打到目标后
                if self._SkillThrowAnim:isDone() then
                    local targetCharacter = CharacterManager:GetCharacterByClientID(self._TargetID)
                    if self._ThrowSkillFinishAnimCSBName ~= "" and self._ThrowSkillFinishAnimCSBName ~= "0" then
                        local endCSBFileName = skillEffectCSBPath .. self._ThrowSkillFinishAnimCSBName
                        --print("Skill End anim" .. endCSBFileName)
                        if self._MoveEndSkillEffectNode == nil then
                            --伤害计算 临时注释，测试伤害立即触发的情况
                            self:CalcHurtNumber(targetCharacter, self._SenderID, self._TargetID)
                            self._MoveEndSkillEffectNode = cc.CSLoader:createNode(endCSBFileName)
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
                                self._MoveEndSkillEffectAnim = cc.CSLoader:createTimeline(endCSBFileName)
                                if self._MoveEndSkillEffectAnim ~= nil then
                                    self._MoveEndSkillEffectAnim:retain()
                                    self._MoveEndSkillEffectNode:runAction(self._MoveEndSkillEffectAnim)
                                    self._MoveEndSkillEffectAnim:play("EndAnim", false)
                                end
                            end
                        end
                    else
                        self:CalcHurtNumber(targetCharacter, self._SenderID, self._TargetID)
                        self._IsFinished = true    
                    end
                end
                --移动结束后的动画特效
                if self._MoveEndSkillEffectAnim ~= nil then
                    if self._MoveEndSkillEffectAnim:getCurrentFrame() >= self._MoveEndSkillEffectAnim:getEndFrame() then
                        --print("endAnim finish..........")
                        self._IsFinished = true
                    end
                end
                self:UpdateOrder()
            end
        end

    elseif self._SkillType == SkillType.SkillType_Throw then
        
    --武将技能
    elseif self._SkillType == SkillType.SkillType_ManualPut then
        local sendCharacter = CharacterManager:GetCharacterByClientID(self._SenderID) 
        if self._ManualSkillAnim == nil then
            self._ManualSkillAnim = cc.CSLoader:createTimeline(self._SkillEffectCSBFileName)
            self._ManualSkillAnim:retain()
            self._SkillRootNode:runAction(self._ManualSkillAnim)
            self._ManualSkillAnim:play("Skill", false)
            --临时
            if self._ManualSkillAnim:IsAnimationInfoExists("Skill") == true then
                local animInfo = self._ManualSkillAnim:getAnimationInfo("Skill")
                if animInfo ~= nil  then
                    local animLength = (animInfo.endIndex - animInfo.startIndex) / 60
                   -- self._TrigerTime = animLength / 2
                    self._AnimLengthHalf = animLength / 2
                   self._TrigerTime = 0
                end
            end
            local currentPositionX, currentPositionY = self._SkillRootNode:getPosition()
            local hurt = self._SenderAttack * self._SkillHurtFactor 
            hurt = mathCeil(hurt)
            print(self._SenderAttack , self._SkillHurtFactor , self._SkillPosZone.x, self._SkillPosZone.y)
            self._totalHurt = Fight:calc_skill_damage(self._unit, hurt, math.floor(currentPositionX / 16) , math.floor((currentPositionY - 300) / 16), self._SkillPosZone.x, self._SkillPosZone.y, self._BuffIDList)
        else
            if self._ManualSkillAnim:getCurrentFrame() >= self._ManualSkillAnim:getEndFrame() then
                self._IsFinished = true
                Fight:setPvePause(false)
                GameGlobal:GetGameLevel():DeDarkLevel()
            end
        end
        if self._CurrentTrigerCount < self._TrigerTotalCount then
            if self._CurrentTrigerTime >=  self._TrigerTime then
                --print("leader skill hurt...........", self._CurrentTrigerCount, self._TrigerTotalCount)
                self._CurrentTrigerTime = 0
                local soldierRelationFactor = GetSoldierRelation(self._SenderID, self._TargetID)
                if self._Attack ~= nil then
                    hurt = self._Attack * gHurtFactor * soldierRelationFactor
                end
                local totalHurt = self._totalHurt --self:CalcHurtNumber(nil, self._SenderID, self._TargetID)
                
                if self._ManualSkillHurtLabel ~= nil then
                    self._ManualSkillHurtLabel:setString(tostring(totalHurt))
                    local currentPositionX, currentPositionY = self._ManualSkillHurtLabel:getPosition()
                    self._ManualSkillHurtLabel:setScale(0.1)
                    local destX = currentPositionX 
                    local destY = currentPositionY + 50
                    local scaleAction = cc.ScaleTo:create(0.5, 1.2, 1.2)
                    local moveAction = cc.MoveTo:create(0.5, cc.p(destX, destY))
                    local finalAction = cc.Spawn:create(scaleAction, moveAction)
                    self._ManualSkillHurtLabel:runAction(finalAction)
                end

                self._CurrentTrigerCount = self._CurrentTrigerCount + 1
            end
        end
        if self._CurrentShakeCount < self._ShakeCount then
            if self._IsShake == false then
                if self._CurrentTrigerTime >=  self._AnimLengthHalf then
                    local currentLevel = GameGlobal:GetGameLevel()
                    currentLevel:Shake(self._ClientGUID, 0.05, 0, 6)
                    self._CurrentShakeCount = self._CurrentShakeCount + 1
                    --print("skill shake ", self._CurrentShakeCount)
                    self._IsShake = true
                end
            end
        end
    end

end

------------------------------- set get------------------------------- 
-- 
function Skill:SetClientID(clientID)
    self._ClientGUID = clientID
end
--
function Skill:GetClientID(clientID)
    return self._ClientGUID
end
--
function Skill:GetSkillRootNode()
    return self._SkillRootNode
end
--
function Skill:IsFinished()
    return self._IsFinished
end

--武将技能位置
function Skill:SetLeaderSkillPosition(position)
    
end
--更新遮挡
function Skill:UpdateOrder()
    if self._SkillRootNode ~= nil then
        local positionY = self._SkillRootNode:getPositionY()
        local parentNode = self._SkillRootNode:getParent()
        if parentNode ~= nil then
            parentNode:reorderChild(self._SkillRootNode, -positionY)
        end
    end
end

return Skill