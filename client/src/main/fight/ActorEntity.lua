----
-- 文件名称：ActorEntity.lua
-- 功能描述：角色   显示相关
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-11-10
-- 
-- 
local CharacterState =
{
    CharacterState_Invalid = -1,
    CharacterState_Stay = 1,
    --初始方向的移动
    CharacterState_Walk = 2,
    CharacterState_Attack = 3,
    CharacterState_Attack_Interval = 4,
    --攻击行走
    CharacterState_Attack_Walk = 5,
    --死亡
    CharacterState_Die = 6,
    --死亡淡出
    CharacterState_DieFadeOut = 7,

}


local UISystem = GameGlobal:GetUISystem()
local TableDataManager =  GameGlobal:GetDataTableManager()
local CharacterTableDataManager = TableDataManager:GetCharacterDataManager()
local ActorEntityManager = nil
local ActorEntitySkillManager = nil

local ActorEntity = 
{

}

--清理变量
function ActorEntity:Clear()
    --GUID
    self._GUID = 0
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
    --当前状态
    self._CurrentState = -1
    --偏移X Y
    self._OffsetX = 0
    self._OffsetY = 0
    --技能TableID
    self._AttackSkillTableID = 0
    if ActorEntityManager == nil then
        ActorEntityManager = require("main.fight.ActorEntityManager")
    end
    if ActorEntitySkillManager == nil then
       ActorEntitySkillManager =  require("main.fight.ActorEntitySkillManager")
    end
    
end

--初始化()
function ActorEntity:Init(guid, tableID, isAttacker, offsetX, offsetY)
    self._GUID = guid 
    local characterData = CharacterTableDataManager[tableID]
    if characterData == nil then
        print("ActorEntity:Init characterData == nil", tableID)
    end
    local csbName = GetArmyCSBName(characterData)
    self._csbName = csbName
    self._AttackSkillTableID = characterData.skill1
    self._CharacterRootNode = cc.CSLoader:createNode(csbName)
    self._CharacterRootNode:retain()
    self._CharacterRootNode:setCascadeOpacityEnabled(true)

    self._CharacterTimeLineAction = cc.CSLoader:createTimeline(csbName)
    if self._CharacterTimeLineAction ~= nil then
        self._CharacterTimeLineAction:retain()
    end
    if offsetX ~= nil then
        self._OffsetX = offsetX
    end
    if offsetY ~= nil then
        self._OffsetY = offsetY
    end
    local characterType = characterData.type
    self:InitHPProgressBar(isAttacker, characterType)
    self:AddToCurrentLevel()
    
end

--销毁
function ActorEntity:Destroy()
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

--添加 
function ActorEntity:AddToCurrentLevel()
--    local Game = GameGlobal:GetGameInstance()
--    local curStateInstance = Game:GetCurrentGameStateInstance()
--    if curStateInstance ~= nil and curStateInstance.GetGameLevel ~= nil then
--        local currentLevel = curStateInstance:GetGameLevel()
--        if currentLevel ~= nil then
--            local levelRootNode = currentLevel:GetRootNode()
            local levelRootNode = GameGlobal:GetGameLevel():GetRootNode()
            if levelRootNode ~= nil then
                local parentNode = self._CharacterRootNode:getParent()
                if parentNode == nil then
                    levelRootNode:addChild(self._CharacterRootNode)
                end
            end
--        end
--    end
end

--根节点
function ActorEntity:GetCharacterNode()
    return self._CharacterRootNode
end
--设置位置
function ActorEntity:SetPosition(x, y, character)
    if self._CharacterRootNode ~= nil then
        self._x = x
        self._y = y
        self._CharacterRootNode:setPosition( self._OffsetX + x,  self._OffsetY + y)
        local parentNode = self._CharacterRootNode:getParent()
        if parentNode ~= nil then
            parentNode:reorderChild(self._CharacterRootNode, 2000 - y)
        end
    end
end

--初始化血条
function ActorEntity:InitHPProgressBar(isAttacker, characterType)

    local resName = "meishu/ui/zhandou/UI_zd_wujiangxue_02.png"
    if characterType == CharacterType.CharacterType_Soldier then
        resName = "meishu/ui/zhandou/UI_zd_shibingxue_02.png"
    end
    if isAttacker == false then
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
    
--        local unitid = cc.Label:createWithTTF(unit_id(self._unit), FONT_FZLTTHJW, BASE_FONT_SIZE)
--        unitid:setAnchorPoint(0, 0.5)
--        unitid:setPosition(cc.p(40, 0))
--        unitid:setColor(cc.c3b(0, 250, 0))
--        self._HPProgressBar:addChild(unitid)
        
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
function ActorEntity:IsDieFadeOutDone()
    if self._CharacterFadeOutAnim == nil then
        print("error invalid _CharacterFadeOutAnim ")
        return 
    end
    return self._CharacterFadeOutAnim:isDone()
end


--获取当前动画是否结束
function ActorEntity:IsCurrentAnimDone()
    if self._CharacterTimeLineAction == nil or self._CharacterTimeLineAction == 0 then
        print("error: _CharacterTimeLineAction invalid ")
        return
    end
    return self._CharacterTimeLineAction:getCurrentFrame() >= self._CharacterTimeLineAction:getEndFrame()
end

--血条显示与隐藏
function ActorEntity:SetHPProgressBarVisible(isShow)
    if self._HPProgressBar ~= nil then
        self._HPProgressBar:setVisible(isShow)
        self._HpProgressBg:setVisible(isShow)
    end
end
--设置血条百分比
function ActorEntity:SetHPProgressBarPercent(percent)
    --TODO:一段时间后隐藏
    if self._HPProgressBar ~= nil then
        self._HPProgressBar:setPercentage(percent)
    end
end
--设置实体朝向
function ActorEntity:SetDirectonX(dirX)
    if self._CharacterRootNode == nil then
        return
    end
    local characterSprite = self._CharacterRootNode:getChildByTag(1)
    if characterSprite == nil then
        printError(" Character:SetDirectonX sprite == nil %d", self._CharacterTableID)
        return
    end
    --characterSprite = tolua.cast(characterSprite, "cc.Sprite")
    if dirX < 0 then
        characterSprite:setFlippedX(true)
    else
        characterSprite:setFlippedX(false)
    end
end

--获取动画播放速度
function ActorEntity:GetWalkAnimSpeed()
    
end
--获取攻击动画播放速度
function ActorEntity:GetAttackAnimSpeed()

end

--设置角色状态(显示相关的)()
function ActorEntity:SetState(state, target, x, y)
    --print("ActorEntity:SetState -----111",state, target, x, y)
    if self._CurrentState == state or self._CurrentState == CharacterState.CharacterState_DieFadeOut then
        return
    end
   
    local character = nil
    self._CurrentState = state
    --print("ActorEntity:SetState -----",state, target, x, y)
    if state == CharacterState.CharacterState_Stay then
        if self._CharacterTimeLineAction ~= nil then
            local numAction = self._CharacterRootNode:getNumberOfRunningActions()
            if numAction == 0 then
                self._CharacterRootNode:runAction(self._CharacterTimeLineAction)
            end
            
            --self._CharacterTimeLineAction:play("Walk", true)
            self:SetHPProgressBarVisible(false)
            if character ~= nil then
                self._CharacterTimeLineAction:setTimeSpeed(character:GetWalkAnimSpeed())
            end
        end
    elseif state == CharacterState.CharacterState_Walk then
        if self._CharacterTimeLineAction ~= nil then
            local numAction = self._CharacterRootNode:getNumberOfRunningActions()
            if numAction == 0 then
                self._CharacterRootNode:runAction(self._CharacterTimeLineAction)
            end
            self:SetHPProgressBarVisible(false)
            --self._CharacterTimeLineAction:play("Walk", true) 
            
            if character ~= nil then
               self._CharacterTimeLineAction:setTimeSpeed(character:GetWalkAnimSpeed())
            end
        end
    elseif state == CharacterState.CharacterState_Attack then
        if self._CharacterTimeLineAction ~= nil then
            local numAction = self._CharacterRootNode:getNumberOfRunningActions()
            if numAction == 0 then
                self._CharacterRootNode:runAction(self._CharacterTimeLineAction)
            end
            
            self._CharacterTimeLineAction:play("Attack", false)
            if character ~= nil then
                self._CharacterTimeLineAction:setTimeSpeed(character:GetAttackAnimSpeed())
            end
            --技能表现
            --print("ActorEntity:SetState -----",state, target, x, y)
            if target ~= nil and get_value_5(self._unit) == 3 then
                local targetX, targetY = unit_pos(target)
                self._AttackSkillTableID = get_value_4(self._unit)
                local offsetX = self._OffsetX
                local offsetY = self._OffsetY 
                self._skill = ActorEntitySkillManager:CreateAttackEntity(self._AttackSkillTableID,  x + offsetX, y + offsetY, targetX + offsetX, targetY + offsetY)
            end
        end
    elseif state == CharacterState.CharacterState_Die then
        if self._DeadTextNode == nil then
            local index = math.random(1,9)
            local frameName = string.format("UI_zd_wenzi_%03d.png", index)
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
    elseif state == CharacterState.CharacterState_DieFadeOut then
        
    end
end

--帧更新
function ActorEntity:Update()
    local currentState = self._CurrentState
    if currentState == CharacterState.CharacterState_Walk  or currentState == CharacterState.CharacterState_Attack_Interval or currentState == CharacterState.CharacterState_Attack_Walk then
        local currentAnim = self._CharacterTimeLineAction
        if currentAnim:getCurrentFrame() >= currentAnim:getEndFrame() then
            currentAnim:play("Walk", true)
        end
    elseif currentState == CharacterState.CharacterState_Die then
        local currentAnim = self._CharacterTimeLineAction
        if currentAnim:getCurrentFrame() >= currentAnim:getEndFrame() then
            currentAnim:play("Dead", false)
            self:SetState(CharacterState.CharacterState_DieFadeOut)
            if self._CharacterFadeOutAnim == nil then
                self._CharacterFadeOutAnim = cc.FadeOut:create(1)
                self._CharacterFadeOutAnim:retain()
            end
            if self._DeadTextNode ~= nil then
                self._DeadTextNode:setVisible(false)
            end 
            
--            local characterSprite = self._CharacterRootNode:getChildByTag(1)
--            if self._CharacterRootNode ~= nil then
--                self._CharacterTimeLineAction:gotoFrameAndPause(self._CharacterTimeLineAction:getEndFrame())
--                self._CharacterRootNode:stopAction(self._CharacterTimeLineAction)
                local actions = transition.sequence({cc.DelayTime:create(0.5), self._CharacterFadeOutAnim, cc.CallFunc:create(self.DestroyOut, {guid = self._GUID})})
                self._CharacterRootNode:runAction(actions)
--            end
        end
   end
end

function ActorEntity:DestroyOut(args)
    ActorEntityManager:DestroyEntity(args.guid)
    if self._skill ~= nil then
        self._skill:Destroy()
    end
end

return ActorEntity
