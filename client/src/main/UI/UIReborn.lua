----
-- 文件名称：UIReborn.lua
-- 功能描述：测试UI
-- 文件说明：
-- 作    者  田凯
-- 创建时间：2015-7-9
-- 修改 ：
--  测试UI动画的支持情况
--
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
local UISystem =  GameGlobal:GetUISystem()
local WarriorData = GetCharacterDataManager()
local CharacterServerDataManager = require("main.ServerData.CharacterServerDataManager")
local SkillDataManager = GetSkillDataManager()
local UIReborn = class("UIReborn", UIBase)
local G_RebornSliver = 500000
-- 武将转生成功特效
local UI_REBORN_ADD_EFFECT    = "csb/texiao/ui/T_u_zhuansheng_tx2.csb"
-- 武将转生成功特效
local UI_REBORN_SUCCESS_EFFECT    = "csb/texiao/ui/T_u_zhuansheng_tx1.csb"

-- 构造函数 
function UIReborn:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_RebornUI
    self._ResourceName =  "UIReborn.csb"
end

-- Load
function UIReborn:Load()
    UIBase.Load(self)
    local panel1 = seekNodeByName(self._RootPanelNode, "Panel_2")
    local panel2 = seekNodeByName(self._RootPanelNode, "Panel_3")
    local w1 = seekNodeByName(self._RootPanelNode, "warrior1")
    local w2 = seekNodeByName(self._RootPanelNode, "warrior2")

    self._Name1 = seekNodeByName(w1, "name")
    self._Name2 = seekNodeByName(w2, "name")
    self._Skill1 = seekNodeByName(self._RootPanelNode, "skill1")
    self._Skill2 = seekNodeByName(self._RootPanelNode, "skill2")
    self._SkillName1 = seekNodeByName(self._Skill1, "name")
    self._SkillName2 = seekNodeByName(self._Skill2, "name")
    self._Data1 = {}
    self._Data2 = {}
    
    for i = 1 , 13 do
        self._Data1[i] = seekNodeByName(panel1, "Text_"..i)  
    end

    for i = 1 , 12 do
        self._Data2[i] = seekNodeByName(panel2, "Text_"..i)    
    end
    
    self._NeedWarrior = {}
    self._NeedWarriorName = {}
    self._NeedWarriorStar = {}
    self._NeedWarriorAdd = {}
    for i = 1 , 6 do
        local node = seekNodeByName(self._RootPanelNode, "Node_"..i)
        self._NeedWarrior[i] = seekNodeByName(node, "Image_1")
        self._NeedWarrior[i]:setSwallowTouches(false)
        self._NeedWarriorStar[i] = seekNodeByName(node, "Image_2")
        self._NeedWarriorStar[i]:setSwallowTouches(false)
        self._NeedWarriorName[i] = seekNodeByName(node, "Text_1")
        self._NeedWarriorName[i]:setFontName(FONT_FZLTTHJW) 
        self._NeedWarriorName[i]:enableOutline(BASE_FONT_OUTCOLOR, 1)  
        if i > 1 then
            self._NeedWarriorAdd[i] = seekNodeByName(node, "Button_1")
            self._NeedWarriorAdd[i]:setTag(i)
            self._NeedWarriorAdd[i]:addTouchEventListener(handler(self, self.TouchEvent))            
        end
    end
  
    local reborn = self:GetUIByName("Button_reborn")
    self._CostTongBiText = self:GetUIByName("Text_TongBiCost")
    reborn:setTag(7)
    reborn:addTouchEventListener(handler(self, self.TouchEvent))
    local quickAdd = self:GetUIByName("Button_qadd")
    quickAdd:setTag(8)
    quickAdd:addTouchEventListener(handler(self, self.TouchEvent))
    self._GetName = seekNodeByName(self._RootPanelNode, "GetName")
    local close = seekNodeByName(self._RootPanelNode, "Close")
    close:setTag(-1)
    close:addTouchEventListener(handler(self, self.TouchEvent))
end

-- Unload
function UIReborn:Unload()
    UIBase.Unload(self)
    self._Data1 = nil
    self._Data2 = nil
    self._NeedWarrior = nil
    self._NeedWarriorName = nil
    self._NeedWarriorAdd = nil
    self._RebornQuality  = nil
end

-- 打开
function UIReborn:Open()
    UIBase.Open(self)
    self._RebornQuality = 0
    self._CurSelectList = { 0 }
    self:addRebornAnimationEffect()
    self:addEvent(GameEvent.GameEvent_UIReborn_Succeed, self.OpenUISuccess)
    self:addEvent(GameEvent.GameEvent_Reborn_Succeed, self.RebornSuccess)
    self:addEvent(GameEvent.GameEvent_UIRebornListSelect_Succeed, self.SelectSuccess)
end

-- 关闭
function UIReborn:Close()
    UIBase.Close(self)
    self:releaseRebornSuccessEffect()
end

function UIReborn:RebornSuccess()
    local WID = GameGlobal:GetChangeDataManager()[self._RebornID]["newid"]
    local CharacterServerDataManager = GameGlobal:GetCharacterServerDataManager() 
    local warrior = CharacterServerDataManager:GetLeader(WID)
    self:RebornReset()
    self:createRebornSuccessEffect()
    DispatchEvent(GameEvent.GameEvent_UIReborn_Succeed, warrior)
end

function UIReborn:OpenUISuccess(event)
    local warrior = event._usedata
    self._RebornQuality = warrior._CharacterData["quality"]
    self._RebornID = warrior._TableID
    self._RebornWarrior = warrior
    local WID = 0
    if GameGlobal:GetChangeDataManager()[warrior._TableID] ~= nil then
         WID = GameGlobal:GetChangeDataManager()[warrior._TableID]["newid"]
    end
    local changeDataManager = GameGlobal:GetChangeDataManager()
    
    if changeDataManager[warrior._TableID] ~= nil then
        local rebornCostMoney = changeDataManager[warrior._TableID]["moneycost"]
        if tonumber(rebornCostMoney) >= 10000 then
            self._CostTongBiText:setString(string.format(math.floor(rebornCostMoney/10000).."%s","万"))
        else
            self._CostTongBiText:setString(rebornCostMoney)
        end
    end
    self._NeedWarriorName[1]:setString(warrior._CharacterData.name)
    self._NeedWarriorName[1]:setColor(GetQualityColor(warrior._CharacterData.quality))
    self._NeedWarriorStar[1]:loadTexture(GetHeadColorImage(warrior._CharacterData.quality))
    self._NeedWarrior[1]:loadTexture(GetWarriorBodyPath(warrior._CharacterData.headName), UI_TEX_TYPE_LOCAL)
    
    self._Name1:setString(warrior._CharacterData.name)
    self._Name1:setColor(GetQualityColor(self._RebornQuality))
    self._Data1[6]:setString(warrior._CharacterData["hpup"])
    self._Data1[7]:setString(warrior._Attack - warrior._EquipAtk)
    self._Data1[8]:setString(warrior._Hp - warrior._EquipHp)
    self._Data1[9]:setString(warrior._CharacterData["attackup"])
    self._Data1[10]:setString(warrior._AtkSpeed - warrior._EquipAtkSpeed)
    self._Data1[11]:setString(warrior._MoveSpeed)
    self._Data1[12]:setString(warrior._CharacterSkillData2["name"])
    
    local quality = warrior._CharacterData["quality"]
    local qualityList = {[0] = 3, [1] = 0, [2] = 2, [3] = 4, [4] = 5, [5] = 6, [6] = 7, [7] = 8}
    if quality ~= nil then
        self._Data1[13]:setString(GetWarriorQuality(qualityList[warrior._CharacterData["quality"]]))
    else
        self._Data1[13]:setString("")
    end
    self._Skill1:loadTexture(GetSkillPath(warrior._CharacterData["skillicon"]), UI_TEX_TYPE_LOCAL) 
    self._SkillName1:setString(warrior._CharacterSkillData2["name"])
    if WID == 0 then
        CreateTipAction(self._RootUINode, ChineseConvert["UITitle_9"], cc.p(700, 270)) 
        return
    end

    local warriorUp = WarriorData[WID]
    
    self._Data2[6]:setString("+"..warriorUp.hpup - warrior._CharacterData["hpup"])
    self._Data2[7]:setString("+"..warriorUp.attack + warriorUp.attackup * (warrior._Level - 1) - warrior._Attack + warrior._EquipAtk)
    self._Data2[8]:setString("+"..warriorUp.hp + warriorUp.hpup * (warrior._Level - 1) - warrior._Hp + warrior._EquipHp)
    self._Data2[9]:setString("+"..warriorUp.attackup - warrior._CharacterData["attackup"])
    self._Data2[10]:setString("+"..warriorUp.attackSpeed - warrior._AtkSpeed + warrior._EquipAtkSpeed)
    self._Data2[11]:setString(SkillDataManager[warriorUp.skill2]["name"])
    
    local quality = warriorUp.quality
    if quality ~= nil then
        self._Data2[12]:setString(GetWarriorQuality(qualityList[warriorUp.quality]))
    else
        self._Data2[12]:setString("")
    end
    self._Name2:setString(warriorUp.name)
    self._GetName:setString(warriorUp.name)
    self._Skill2:loadTexture(GetSkillPath(warriorUp.skillicon), UI_TEX_TYPE_LOCAL)
    self._SkillName2:setString(SkillDataManager[warriorUp.skill2]["name"])
    
    -- 找出最宽数值-用于右侧绿色数值对齐
    local width = 0
    local maxWidthId = 0
    for i = 6, 13 do
        local curWidth = self._Data1[i]:getContentSize().width + self._Data1[i]:getPositionX()
        if curWidth > width then
            width = curWidth
            maxWidthId = i
        end
    end
    -- 获取X坐标
    local backPositionX = self._Data1[maxWidthId]:getContentSize().width - 26
    -- 位置设置
    for i = 6, 12 do
        self._Data2[i]:setPositionX(backPositionX)
    end
end

function UIReborn:TouchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
        if not UISystem:IsForefront(self._Type) then
            return
        end

        if tag == -1 then
            self:RebornReset()
            UISystem:CloseUI(UIType.UIType_RebornUI)
            UISystem:CloseUI(UIType.UIType_UIRecruit) 
        elseif tag == 2 then
            self:SelectWarriorAndClean(sender, tag)
        elseif tag == 3 then
            self:SelectWarriorAndClean(sender, tag)
        elseif tag == 4 then
            self:SelectWarriorAndClean(sender, tag)
        elseif tag == 5 then
            self:SelectWarriorAndClean(sender, tag)
        elseif tag == 6 then
            self:SelectWarriorAndClean(sender, tag)
        elseif tag == 7 then
            local gamePlayerDataManager = GameGlobal:GetGamePlayerDataManager()
            local roleInfo = gamePlayerDataManager:GetMyselfData()
            
            if self:CheckReborn() then
                local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_zs_03))
                return
            elseif self:CheckReborn2() ~= "" then
                local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                UITip:RegisteDelegate(handler(self, self.CommitTipButton), 1)
                local str = string.gsub(GameGlobal:GetTipDataManager(UI_zs_01), "@name", self:CheckReborn2(), 1)
                UITip:SetStyle(0, str)
            elseif roleInfo._Silver < G_RebornSliver then
                local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_zs_04))
            else
                SendMsg(PacketDefine.PacketDefine_HeroUp_Send, {self._RebornID, 5, self._CurSelectList})
            end  
        elseif tag == 8 then
            self:QuickSelectSuccess()
        elseif tag == 9 then
            UISystem:CloseUI(UIType.UIType_RebornUI)
        elseif tag == 10 then
            UISystem:CloseUI(UIType.UIType_RebornUI)
            local recruit = UISystem:OpenUI(UIType.UIType_UIRecruit)
            recruit:EnterPlayAnimation(true)
            SendMsg(PacketDefine.PacketDefine_RecruitStore_Send)
        elseif tag == 11 then
            UISystem:CloseUI(UIType.UIType_RebornUI)
            local warrior = UISystem:GetUIInstance(UIType.UIType_WarriorUI)
            SimulateClickButton(warrior._TabButton[3], handler(self, warrior.TouchEvent, 2)) 
        end
    end
end

function UIReborn:CommitTipButton(sender)
    if self:CheckReborn3() then
        performWithDelay(UISystem:GetUIRootNode(), self.DelayOpenTip, 0)
    elseif GetPlayer()._Silver < G_RebornSliver then
        performWithDelay(UISystem:GetUIRootNode(), self.DelayOpenTip2, 0)
    else
        SendMsg(PacketDefine.PacketDefine_HeroUp_Send, {self._RebornID, 5, self._CurSelectList})
    end
end

function UIReborn:Commit2TipButton(sender)
    if GetPlayer()._Silver < G_RebornSliver then
        performWithDelay(UISystem:GetUIRootNode(), self.DelayOpenTip2, 0)
    else
        SendMsg(PacketDefine.PacketDefine_HeroUp_Send, {self._RebornID, 5, self._CurSelectList})
    end
end

function UIReborn:DelayOpenTip2()
    local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
    UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_zs_04))
end

function UIReborn:DelayOpenTip()
    local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
    UITip:RegisteDelegate(handler(self, self.Commit2TipButton), 1)
    UITip:SetStyle(0, "有高等级武将在材料中，是否继续转生？")
end

function UIReborn:SelectWarriorAndClean(node, tag)
    if self._CurSelectList[tag] == nil then
        UISystem:OpenUI(UIType.UIType_RebornWarriorListUI)
        self._CurFrameIndex = tag
        performWithDelay(node, handler(self, self.DelayCallBack), 0)
    else
        self._CurSelectList[tag] = nil
        self._NeedWarriorName[tag]:setString("")
        self._NeedWarriorStar[tag]:loadTexture("meishu/ui/gg/null.png", UI_TEX_TYPE_LOCAL)
        self._NeedWarrior[tag]:loadTexture("meishu/ui/gg/null.png", UI_TEX_TYPE_LOCAL)
    end
end

function UIReborn:CheckWarriorNum()
    local rebornWarriorList = {}
    for i, v in pairs(CharacterServerDataManager._OwnLeaderList) do
        if v._CharacterData["quality"] == self._RebornQuality then
            table.insert( rebornWarriorList, i)
        end
    end
    return #rebornWarriorList < 10
end

function UIReborn:QuickSelectSuccess()
    self._RebornWarriorList = {}
    for i, v in pairs(CharacterServerDataManager._OwnLeaderList) do
        if v._CharacterData["quality"] == self._RebornQuality and i ~= self._RebornID then
            table.insert( self._RebornWarriorList, i)
        end
    end
    
    local sortWarriorByLevlefunction = function( a, b )
        local warrior1 = CharacterServerDataManager:GetLeader(a)
        local warrior2 = CharacterServerDataManager:GetLeader(b)
        local WID1 = warrior1._CharacterData["uphero"]
        local WID2 = warrior2._CharacterData["uphero"]
        if WID1 == WID2 then
            return warrior1._Level < warrior2._Level
        else
            return WID1 < WID2
        end
    end
    table.sort(self._RebornWarriorList, sortWarriorByLevlefunction)
    
    for i = 1, #self._RebornWarriorList do
        local warrior = CharacterServerDataManager:GetLeader(self._RebornWarriorList[i])
        local color = GetQualityColor(tonumber(warrior._CharacterData["quality"]))
        if i < 6 then
            self._CurSelectList[i + 1] = self._RebornWarriorList[i]
            self._NeedWarriorName[i + 1]:setString(warrior._CharacterData["name"])
            self._NeedWarriorName[i + 1]:setColor(color)
            self._NeedWarriorStar[i + 1]:loadTexture(GetHeadColorImage(warrior._CharacterData["quality"]))
            self._NeedWarrior[i + 1]:loadTexture(GetWarriorHeadPath(warrior._CharacterData["headName"]), UI_TEX_TYPE_LOCAL)
        end
    end
    return #self._RebornWarriorList
end

function UIReborn:CheckReborn()
    for i = 2, 6 do
       if self._CurSelectList[i] == nil then
            return true
       end
    end
    return false
end

function UIReborn:CheckReborn2()
    local str = ""
    for i = 2, 6 do
        local warrior1 = CharacterServerDataManager:GetLeader(self._CurSelectList[i])
        if GameGlobal:GetChangeDataManager()[tonumber(self._CurSelectList[i])] ~= nil then
            local WID1 = GameGlobal:GetChangeDataManager()[tonumber(self._CurSelectList[i])]["newid"]
            if WID1 > 0 then 
                str = str..warrior1._CharacterData["name"]..","
            end
        end
    end
    return str
end

function UIReborn:CheckReborn3()
    for i = 2, 6 do
        local warrior1 = CharacterServerDataManager:GetLeader(self._CurSelectList[i])
        if GameGlobal:GetChangeDataManager()[tonumber(self._CurSelectList[i])] ~= nil then
            local WID1 = GameGlobal:GetChangeDataManager()[tonumber(self._CurSelectList[i])]["newid"]
            if WID1 > 0 and warrior1._Level > 1 then 
               return true
            end
        end
    end
    return false
end

function UIReborn:RebornReset()
    for i = 2, 6 do
        self._CurSelectList[i] = nil
        self._NeedWarriorName[i]:setString("")
        self._NeedWarriorStar[i]:loadTexture("meishu/ui/gg/null.png", UI_TEX_TYPE_LOCAL)
        self._NeedWarrior[i]:loadTexture("meishu/ui/gg/null.png", UI_TEX_TYPE_LOCAL)
    end
end

function UIReborn:SelectSuccess()
    for i = 2, 6 do
        if self._CurSelectList[i] ~= nil then
            local warrior = CharacterServerDataManager:GetLeader(self._CurSelectList[i])
            local color = GetQualityColor(tonumber(warrior._CharacterData["quality"]))
            local warriorId = i
            self._NeedWarriorName[warriorId]:setString(warrior._CharacterData["name"])
            self._NeedWarriorName[warriorId]:setColor(color)
            self._NeedWarriorStar[warriorId]:loadTexture(GetHeadColorImage(warrior._CharacterData["quality"]))
            self._NeedWarrior[warriorId]:loadTexture(GetWarriorHeadPath(warrior._CharacterData["headName"]), UI_TEX_TYPE_LOCAL)
        end
    end
    performWithDelay(self._NeedWarrior[self._CurFrameIndex], self.DelayCloseCallBack, 0.05)
end

function UIReborn:DelayCloseCallBack()
    UISystem:CloseUI(UIType.UIType_RebornWarriorListUI) 
end

function UIReborn:DelayCallBack(sender)
    DispatchEvent(GameEvent.GameEvent_UIRebornList_Succeed, self._RebornQuality)
end

function UIReborn:createRebornSuccessEffect()
    local node = seekNodeByName(self._RootPanelNode, "Node_1")
    local w = seekNodeByName(self._RootPanelNode, "Node_1"):getContentSize().width
    local h = seekNodeByName(self._RootPanelNode, "Node_1"):getContentSize().height
    self:playAnimationRebornEffectObject(node, self._RebornSuccessEffect, w / 2 - 5, w / 2 - 5, "animation0")
end

function UIReborn:releaseRebornSuccessEffect()
    for i = 1 , 5 do
        removeNodeAndRelease(self._RebornAddEffecs[i],true)
    end
    self.RebornAddEffec = nil
    removeNodeAndRelease(self._RebornSuccessEffect,true)
    self._RebornSuccessEffect = nil
end

function UIReborn:addRebornAnimationEffect()
    if self._RebornSuccessEffect == nil then
        self._RebornSuccessEffect = CreateAnimationObject(0, 0, UI_REBORN_SUCCESS_EFFECT)
    end 
    self._RebornAddEffecs = {}
    for i = 1 , 5 do
        if self._RebornAddEffecs[i] == nil then
            self._RebornAddEffecs[i] = CreateAnimationObject(0, 0, UI_REBORN_ADD_EFFECT)
        end
        local node = seekNodeByName(self._RootPanelNode, "Node_"..(i + 1))
        local parent = seekNodeByName(node, "Button_1")
        local w = parent:getContentSize().width
        local h = parent:getContentSize().height
        self:playAnimationRebornEffectObject(parent, self._RebornAddEffecs[i], w / 2, h / 2, "animation0", true)
    end
end

function UIReborn:playAnimationRebornEffectObject(parent, animation, x, y, actionName, loop)
    local parentNode = animation:getParent()
    if parentNode == nil then
        animation:setPosition(cc.p(x, y))
        parent:addChild(animation, 1)
    end
    animation._usedata:resume()
    animation._usedata:setCurrentFrame(animation._usedata:getStartFrame())
    if loop then
        animation._usedata:play(actionName, true)
    else
        animation._usedata:play(actionName, false)
    end
end

return UIReborn
