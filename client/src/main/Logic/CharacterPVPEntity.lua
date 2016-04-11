----
-- 文件名称：CharacterPVPEntity.lua
-- 功能描述：PVP角色类(显示部分)
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-9-29
--

local stringFormat = string.format
local mathAbs = math.abs
local mathFloor = math.floor
local mathPower = math.pow
local mathSqrt = math.sqrt
local mathCeil = math.ceil

local UISystem = GameGlobal:GetUISystem()

--依赖的数据结构
BuffEntityInfo = class("BuffEntityInfo")
function BuffEntityInfo:ctor(csbName)
    --csb
    self._CSBName = csbName
    --Buff Node
    self._CharacterBuffNode = 0
    --Buff 动画
    self._CharacterBuffTimelineAction = 0
end

--初始化
function BuffEntityInfo:Init()
    if self._CSBName == "" then
        return
    end
    --
    local newBuffNode = cc.CSLoader:createNode(buff._CSBFileName)
    local newAnim = cc.CSLoader:createTimeline(buff._CSBFileName)
    if newBuffNode ~= nil then
        newBuffNode:retain()
        newBuff._CharacterBuffNode = newBuffNode
        if self._CharacterRootNode ~= nil then
            self._CharacterRootNode:addChild(newBuff._CharacterBuffNode)
        else
            print("invalid rootNode ....")
        end
        if newAnim ~= nil then
            newAnim:retain()
            newBuff._CharacterBuffNode:runAction(newAnim)
            newAnim:play("Buff", true)
            newBuff._CharacterBuffTimelineAction = newAnim
        end
    end
end

--销毁
function BuffEntityInfo:Destroy()
    if self._CharacterBuffNode ~= nil then
        self._CharacterBuffNode:removeFromParent()
        self._CharacterBuffNode:release()
        self._CharacterBuffNode = nil
    end
    if self._CharacterBuffTimelineAction ~= nil then
        self._CharacterBuffTimelineAction:release()
        self._CharacterBuffTimelineAction = nil
    end
end

local CharacterPVPEntity = class("CharacterPVPEntity")

--构造
function CharacterPVPEntity:ctor()
    --根节点
    self._CharacterRootNode = nil
    --动作
    self._CharacterTimeLineAction = nil
    --死亡淡出动画
    self._CharacterFadeOutAnim = nil
    --死亡冒出的文字
    self._DeadTextNode = nil
    --血条
    self._HPProgressBar = nil
    --血条背景
    self._HpProgressBg = nil
    --用于调试的节点
    self._DebugLabel = nil
end

--初始化
function CharacterPVPEntity:Init(characterData)
    local csbName = GetArmyCSBName(characterData)
    self._CharacterRootNode = cc.CSLoader:createNode(csbName)
    self._CharacterRootNode:retain()
    self._CharacterRootNode:setCascadeOpacityEnabled(true)
    
    self._CharacterTimeLineAction = cc.CSLoader:createTimeline(csbName)
    if self._CharacterTimeLineAction ~= nil then
        self._CharacterTimeLineAction:retain()
    end
    
    cc.SpriteFrameCache:getInstance():addSpriteFrames("meishu/ui/zhandou/UI_zd_wenzi.plist")
end

--销毁
function CharacterPVPEntity:Destroy()
    --print("Character:Destroy")
    if self._CharacterTimeLineAction ~= nil then
        self._CharacterTimeLineAction:release()
        self._CharacterTimeLineAction = nil
    end

    if  self._CharacterFadeOutAnim ~= nil then
        self._CharacterFadeOutAnim:release()
        self._CharacterFadeOutAnim = nil
    end
    
    if self._HPProgressBar ~= nil then
        self._HPProgressBar:release()
        self._HPProgressBar = nil
    end
    
    if self._CharacterRootNode ~= nil then
        self._CharacterRootNode:removeFromParent()
        self._CharacterRootNode:removeAllChildren()
        self._CharacterRootNode:release()
        self._CharacterRootNode = nil
    end
    self._HpProgressBg = nil
end

function CharacterPVPEntity:GetCharacterNode()
    return self._CharacterRootNode
end
--设置位置
function CharacterPVPEntity:SetPosition(x, y, character)
    if self._CharacterRootNode ~= nil then
        self._CharacterRootNode:setPosition(x, y)
        local parentNode = self._CharacterRootNode:getParent()
        if parentNode ~= nil then
            parentNode:reorderChild(self._CharacterRootNode, -y)
        end
        --更新UI,由于SetPosition会频繁调用，所以就不走Event驱动逻辑了
        local battleUI = UISystem:GetUIInstance(UIType.UIType_BattleUI)
        if battleUI ~= nil then
            battleUI:UpdatePVEMapSprite(character)
        end
    end
end

--初始化血条
function CharacterPVPEntity:InitHPProgressBar(isEnemy, characterType)

    local resName = "meishu/ui/zhandou/UI_zd_wujiangxue_02.png"

    if characterType == CharacterType.CharacterType_Soldier then
        resName = "meishu/ui/zhandou/UI_zd_shibingxue_02.png"
    end
    if isEnemy == true then
        resName = "meishu/ui/zhandou/UI_zd_wujiangxue_03.png"
        if characterType == CharacterType.CharacterType_Soldier then
            resName = "meishu/ui/zhandou/UI_zd_shibingxue_03.png"
        end
    end
    
    if self._HPProgressBar == nil then
        self._HpProgressBg = display.newSprite("meishu/ui/zhandou/UI_zd_wujiangxue_01.png",0,0)
        if characterType == CharacterType.CharacterType_Soldier then
            self._HpProgressBg = display.newSprite("meishu/ui/zhandou/UI_zd_shibingxue_01.png",0,0)
        end
        self._HPProgressBar = cc.ProgressTimer:create(cc.Sprite:create(resName))
        self._HPProgressBar:retain()
        self._HPProgressBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        self._HPProgressBar:setMidpoint(cc.p(0, 0))
        self._HPProgressBar:setBarChangeRate(cc.p(1, 0))
        self._HPProgressBar:setPercentage(100)
        self._HPProgressBar:setPosition(cc.p(0, 0))
        self._HPProgressBar:setVisible(false)
        self._HpProgressBg:setVisible(false)
        if self._CharacterRootNode ~= nil then
            local hpParentNode = self._CharacterRootNode:getChildByTag(2)
            if hpParentNode ~= nil then
                hpParentNode:addChild(self._HpProgressBg)
                hpParentNode:addChild(self._HPProgressBar)
            end
        end
    end
end

--获取fade
function CharacterPVPEntity:IsDieFadeOutDone()
    if self._CharacterFadeOutAnim == nil then
        print("error invalid _CharacterFadeOutAnim ")
        return 
    end
    return self._CharacterFadeOutAnim:isDone()
end


--获取当前动画是否结束
function CharacterPVPEntity:IsCurrentAnimDone()
    if self._CharacterTimeLineAction == nil or self._CharacterTimeLineAction == 0 then
        print("error: _CharacterTimeLineAction invalid ")
        return
    end
    return self._CharacterTimeLineAction:getCurrentFrame() >= self._CharacterTimeLineAction:getEndFrame()
end

--血条显示与隐藏
function CharacterPVPEntity:SetHPProgressBarVisible(isShow)
    if self._HPProgressBar ~= nil then
        self._HPProgressBar:setVisible(isShow)
        self._HpProgressBg:setVisible(isShow)
    end
end
--设置血条百分比
function CharacterPVPEntity:SetHPProgressBarPercent(percent)
    if self._HPProgressBar ~= nil then
        self._HPProgressBar:setPercentage(percent)
    end
end
--设置实体朝向
function CharacterPVPEntity:SetDirectonX(dirX)
    if self._CharacterRootNode == nil then
        return
    end
    local characterSprite = self._CharacterRootNode:getChildByTag(1)
    if characterSprite == nil then
        printError(" Character:SetDirectonX sprite == nil %d", self._CharacterTableID)
        return
    end
    --characterSprite = tolua.cast(characterSprite, "cc.Sprite")
    if dirX == -1 then
        characterSprite:setFlippedX(true)
    else
        characterSprite:setFlippedX(false)
    end
end

--设置角色状态(显示相关的)
function CharacterPVPEntity:SetState(state, character)
    self._CurrentState = state
    --print("Character:SetState ", self._ClientID, state)
    if state == CharacterState.CharacterState_Walk then
        if self._CharacterTimeLineAction ~= nil then
            local numAction = self._CharacterRootNode:getNumberOfRunningActions()
            if numAction == 0 then
                self._CharacterRootNode:runAction(self._CharacterTimeLineAction)
            end
            self._CharacterTimeLineAction:play("Walk", true)
            if character ~= nil then
                self._CharacterTimeLineAction:setTimeSpeed(character:GetWalkAnimSpeed())
            end
        end
        self._CurrentSearchEnemyInterval = self._SEARCH_ENEMY_TIME
    elseif state == CharacterState.CharacterState_Walk_Idle then
        if self._CharacterTimeLineAction ~= nil then
            self._CharacterTimeLineAction:play("Walk", true)
            if character ~= nil then
                self._CharacterTimeLineAction:setTimeSpeed(character:GetWalkAnimSpeed())
            end
        end
    elseif  state == CharacterState.CharacterState_Walk_ToTarget then
        if self._CharacterTimeLineAction ~= nil then
        -- self._CharacterTimeLineAction:play("Walk", true)
        end
    elseif state == CharacterState.CharacterState_Attack then
        if self._CharacterTimeLineAction ~= nil then
            self._CharacterTimeLineAction:play("Attack", false)
            if character ~= nil then
                self._CharacterTimeLineAction:setTimeSpeed(character:GetAttackAnimSpeed())
            end
        end
    elseif state == CharacterState.CharacterState_WalkForTime then
        if self._CharacterTimeLineAction ~= nil then
            self._CharacterTimeLineAction:play("Walk", true)
            if character ~= nil then
                self._CharacterTimeLineAction:setTimeSpeed(character:GetWalkAnimSpeed())
            end
        end
    elseif state == CharacterState.CharacterState_Die then
        if self._DeadTextNode == nil then
            local index = math.random(1,9)
            local frameName = stringFormat("UI_zd_wenzi_%03d.png", index)
            self._DeadTextNode = cc.Sprite:createWithSpriteFrameName(frameName)
            local hpParentNode = self._CharacterRootNode:getChildByTag(2)
            if hpParentNode ~= nil then
                hpParentNode:addChild(self._DeadTextNode)
            end
            if self._HPProgressBar ~= nil then
                self._HPProgressBar:setVisible(false)
                self._HPProgressBar:setScale(0)
            end
            if self._HpProgressBg ~= nil then
                self._HpProgressBg:setVisible(false)
                self._HpProgressBg:setScale(0)
            end
        end
        if self._CharacterTimeLineAction ~= nil then
            self._CharacterTimeLineAction:play("Dead", false)
            self._CharacterTimeLineAction:setTimeSpeed(1)
        end
    elseif state == CharacterState.CharacterState_DieFadeOut then
        if self._CharacterFadeOutAnim == nil then
            self._CharacterFadeOutAnim = cc.FadeOut:create(1)
            self._CharacterFadeOutAnim:retain()
        end
        if self._DeadTextNode ~= nil then
            self._DeadTextNode:setVisible(false)
        end 
        local characterSprite = self._CharacterRootNode:getChildByTag(1)
        if self._CharacterRootNode ~= nil then
            self._CharacterTimeLineAction:pause()
            self._CharacterTimeLineAction:gotoFrameAndPause(self._CharacterTimeLineAction:getEndFrame())
            self._CharacterRootNode:stopAction(self._CharacterTimeLineAction)
            self._CharacterRootNode:runAction(self._CharacterFadeOutAnim)
        end
    end
end

return CharacterPVPEntity