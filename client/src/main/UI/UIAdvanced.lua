----
-- 文件名称：UIAdvanced.lua
-- 功能描述：测试UI
-- 文件说明：
-- 作    者  田凯
-- 创建时间：2015-7-8
-- 修改 ：
--  测试UI动画的支持情况
--
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
local CharacterDataManager = GetCharacterDataManager()
local SoldierData = GameGlobal:GetCharacterServerDataManager()
local ItemDataManager = GameGlobal:GetItemDataManager()
local PropDataManager = GetPropDataManager()
local UISystem =  GameGlobal:GetUISystem()
local UIAdvanced = class("UIAdvanced", UIBase)
-- 士兵进阶 箭头特效
local UI_ADVANCED_ARROW_EFFECT    = "csb/texiao/ui/T_u_SBjinjie.csb"

-- 构造函数
function UIAdvanced:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_AdvancedUI
    self._ResourceName =  "UIAdvanced.csb"
end

-- Load
function UIAdvanced:Load()
    UIBase.Load(self)
        
    local panel1 = seekNodeByName(self._RootPanelNode, "Panel_2")
    local panel2 = seekNodeByName(self._RootPanelNode, "Panel_3")
    self._BodyImage1 = seekNodeByName(panel1, "Image_1")
    self._BodyImage2 = seekNodeByName(panel2, "Image_1")
    self._Data1 = {}
    self._Data2 = {}   
    for i = 1 , 12 do
        if i >= 11 then
            self._Data1[i] = seekNodeByName(panel1, "Text_"..(i + 6))
        else
            self._Data1[i] = seekNodeByName(panel1, "Text_"..i)
        end  
    end
    self._LevelText = seekNodeByName(panel1, "Text_14")
    
    for i = 1 , 12 do
        if i >= 11 then
            self._Data2[i] = seekNodeByName(panel2, "Text_"..(i + 8))
        else
            self._Data2[i] = seekNodeByName(panel2, "Text_"..i)
        end     
    end
    
    self._OpenFlag = seekNodeByName(self._RootPanelNode, "Sprite_Flag")
    self._Name1 = seekNodeByName(panel1, "name")
    self._Name2 = seekNodeByName(panel2, "name")
    self._FlagText = seekNodeByName(panel1, "Text_Flag")
    self._JiangFontText = seekNodeByName(panel1, "Text_21")
    self._Name3 = seekNodeByName(panel1, "name_3")
    self._AniNode1 = self:GetUIByName("Node_1")
    self._AniNode2 = self:GetUIByName("Node_2")
    
    self._ItemIcon = seekNodeByName(self._RootPanelNode, "icon")
    self._ItemNum = seekNodeByName(self._RootPanelNode, "Num")
    self._ItemNumCha = seekNodeByName(self._RootPanelNode, "Num_Cha")
    self._ItemNum:setString("")
    local x, y = self._ItemNum:getPosition()
    self._ItemNum = cc.Label:createWithTTF("", "fonts/msyh.ttf", BASE_FONT_SIZE_MID + 2)
    self._ItemNum:setAnchorPoint(0, 0.5)
    self._ItemNum:setPosition(x, y)
     self._ItemNum:setColor(cc.c3b(121,76,53))
    panel2:addChild(self._ItemNum, 1000, 0)
    self._ItemIcon:loadTexture("meishu/ui/gg/null.png")
    self._ItemNum:setString("1000/10")
    local advanced =  self:GetUIByName("AdvanceBtn")
    advanced:setTag(1)
    advanced:addTouchEventListener(handler(self, self.touchEvent))
    local close = self:GetWigetByName("Close")
    close:setTag(-1)
    close:addTouchEventListener(handler(self, self.touchEvent))
end

-- 打开
function UIAdvanced:Open()
    UIBase.Open(self)
    self:createArrowEffects()
    self:addEvent(GameEvent.GameEvent_UIAdvanced_Buy, self.updateAdvancedItem)
    self:addEvent(GameEvent.GameEvent_UIAdvanced_Succeed, self.openUISuccess)
end

-- 关闭
function UIAdvanced:Close()
    UIBase.Close(self)
    -- 移除特效
    self:releaseArrowEffects()
end

function UIAdvanced:AdvancedSucceed()
    CreateAnimation(self._RootPanelNode, 480, 250, "csb/texiao/ui/T_u_ziti_jinjie.csb", "animation0", false, 0, 1)
end

function UIAdvanced:openUISuccess(event)
    local soldier = event._usedata
    if soldier == nil then
        return
    end
    self._Solider = soldier
   
    local tmp =  soldier._CharacterData.quality   
    self._ItemIcon:loadTexture(GetPropPath(PropDataManager[30009]["icon"]))
    if ItemDataManager:GetItemCount(30009) ~= nil then
        self._ItemNum:setString(ItemDataManager:GetItemCount(30009).."/".. GameGlobal:GetChangeDataManager()[self._Solider._TableID]["itemnumber"])
        if ItemDataManager:GetItemCount(30009) <  GameGlobal:GetChangeDataManager()[self._Solider._TableID]["itemnumber"] then
            local r, _ = string.find(self._ItemNum:getString(), '/')
            for i = 0, r - 2, 1 do
                local letter = self._ItemNum:getLetter(tonumber(i))
                letter:setColor(cc.c3b(255,0,0))
            end
        end
    else
        self._ItemNum:setString("0/".. GameGlobal:GetChangeDataManager()[self._Solider._TableID]["itemnumber"]) 
        local r, _ = string.find(self._ItemNum:getString(), '/')
        for i = 0, r - 2, 1 do
            local letter = self._ItemNum:getLetter(tonumber(i))
            letter:setColor(cc.c3b(255,0,0))
        end
    end
    self._BodyImage1:loadTexture(GetSoldierBodyPath(soldier._CharacterData.bodyImage))
    self._Name1:setString(soldier._CharacterData.name)
    self._Data1[7]:setString(soldier._Attack)
    self._Data1[8]:setString(soldier._Hp)
    self._Data1[9]:setString(soldier._AtkSpeed)
    self._Data1[10]:setString(soldier._MoveSpeed)
    self._Data1[11]:setString(soldier._CharacterData.hpup)
    self._Data1[12]:setString(soldier._CharacterData.attackup)
    
    if self._Solider._CharacterData.quality > GetGlobalData()._TechnologyList[1][2] then
        self._OpenFlag:setVisible(true)
    else
        self._OpenFlag:setVisible(false)
    end
    local CData 
    local WID = GameGlobal:GetChangeDataManager()[soldier._TableID]["newid"]
    if WID == 0 then
        CData = CharacterDataManager[soldier._TableID]
    else   
        CData = CharacterDataManager[WID]
    end
    
    if WID == 0 then
        self._BodyImage2:setVisible(false)
        self._OpenFlag:setVisible(false)
        self._Name2:setVisible(false)
        self._ItemNum:setVisible(false)
        for i = 6, 10 do
            self._Data2[i]:setVisible(false)
        end
        -- 最大进阶等级
        self:GetUIByName("Text_Tip"):setVisible(true)
        
    else
        self._BodyImage2:loadTexture(GetSoldierBodyPath(CData.bodyImage))
        local animNode = cc.CSLoader:createNode(GetSoldierCsbPath(CData.resName))
        local anim = cc.CSLoader:createTimeline(GetSoldierCsbPath(CData.resName))
        self._AniNode2:addChild(animNode)
        anim:play("Walk",true)
        animNode:runAction(anim)
    end
    self._LevelText:setString(soldier._Level)
    self._Name2:setString(CData.name)
    -- 设置字位置
    self._FlagText:setPositionX(self._Name1:getContentSize().width + self._JiangFontText:getPositionX())
    local posX = self._Name1:getContentSize().width + self._JiangFontText:getPositionX() + self._FlagText:getContentSize().width
    self._Name3:setPositionX(posX)
    self._Name3:setString(CData.name)
    -- 将整个居中
    local stringLen = self._Name3:getPositionX() + self._Name3:getContentSize().width - self._JiangFontText:getPositionX() + self._JiangFontText:getContentSize().width
    local moveDis = math.floor((340 - stringLen) / 2) - self._JiangFontText:getPositionX() + self._JiangFontText:getContentSize().width
    -- 设置x
    self._Name3:setPositionX(self._Name3:getPositionX() + moveDis)
    self._JiangFontText:setPositionX(self._JiangFontText:getPositionX() + moveDis)
    self._Name1:setPositionX(self._Name1:getPositionX() + moveDis)
    self._FlagText:setPositionX(self._FlagText:getPositionX() + moveDis)
    self._Data2[7]:setString("+"..CData.attack + (soldier._Level - 1) * CData.attackup - soldier._Attack)
    self._Data2[8]:setString("+"..CData.hp + (soldier._Level - 1) * CData.hpup - soldier._Hp)
    self._Data2[9]:setString("+"..CData.attackSpeed - soldier._AtkSpeed)
    self._Data2[10]:setString("+"..CData.moveSpeed - soldier._MoveSpeed)
    self._Data2[11]:setString("+"..CData.hpup - soldier._CharacterData.hpup)
    self._Data2[12]:setString("+"..CData.attackup - soldier._CharacterData.attackup)
    -- 找出最宽数值-用于右侧绿色数值对齐
    local width = 0
    local maxWidthId = 0
    for i = 7, 12 do
        local curWidth = self._Data1[i]:getContentSize().width
        if curWidth > width then
            width = curWidth
            maxWidthId = i
        end
    end
    -- 获取X坐标
    local backPositionX = self._Data1[maxWidthId]:getContentSize().width - 30
    for i = 7, 12 do
        self._Data2[i]:setPositionX(backPositionX)
    end
    -- 动画重复添加  清除
    self._AniNode1:removeAllChildren()
    local animNode = cc.CSLoader:createNode(GetSoldierCsbPath(soldier._CharacterData.resName))
    local anim = cc.CSLoader:createTimeline(GetSoldierCsbPath(soldier._CharacterData.resName))
    self._AniNode1:addChild(animNode)
    anim:play("Walk",true)
    animNode:runAction(anim)
end

function UIAdvanced:touchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
        if tag == -1 then
            UISystem:CloseUI(UIType.UIType_AdvancedUI)
        elseif tag == 1 then 
            local tmp =  tonumber(self._Solider._CharacterData.quality)
            local WID = GameGlobal:GetChangeDataManager()[self._Solider._TableID]["newid"]
            
            if WID == 0 then
                local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_sb_03))
                return
            end
           
            if self._Solider._CharacterData.quality > GetGlobalData()._TechnologyList[1][2] then
                return 
            end
            
            if ItemDataManager:GetItemCount(30009) >=  GameGlobal:GetChangeDataManager()[self._Solider._TableID]["itemnumber"] then
                local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                local tips = string.gsub(GameGlobal:GetTipDataManager(UI_sb_01), "@number",  GameGlobal:GetChangeDataManager()[self._Solider._TableID]["itemnumber"], 1)
                -- 进阶 名称 获取 暂时从UI _Name2 ， _Name3 获取
                tips = string.gsub(tips, "%@id", self._Name2:getString(), 1)
                tips = string.gsub(tips, "%@id", self._Name3:getString(), 1)
                UITip:SetStyle(0, tips)
                UITip:RegisteDelegate(handler(self, self.commitTipButton), 1)
            else
                self:commitTipButtonBuy()
            end
        elseif tag == 3 then 
            UISystem:CloseUI(UIType.UIType_AdvancedUI)
            local soldier = UISystem:GetUIInstance(UIType.UIType_SoldierUI)
            soldier:updateSolider()
            SimulateClickButton(soldier._JumpToTrainBtn, handler(self, soldier.touchEvent, 2)) 
        elseif tag == 2 then 
            UISystem:CloseUI(UIType.UIType_AdvancedUI)
        end
    end
end

function UIAdvanced:commitTipButtonBuy()
    local uiInstance = UISystem:OpenUI(UIType.UIType_BuyItem)
    uiInstance:OpenItemInfoNotifiaction(30009)
    -- 缺失道具大于99时购买数量直接显示99
    if ItemDataManager:GetItemCount(30009) ~= nil then
        local tmp = self._Solider._CharacterData.quality  
        if (ItemDataManager:GetItemCount(30009) + 99) <  GameGlobal:GetChangeDataManager()[self._Solider._TableID]["itemnumber"] then
            uiInstance:setItemNum(99)
        else
            uiInstance:setItemNum( GameGlobal:GetChangeDataManager()[self._Solider._TableID]["itemnumber"] - ItemDataManager:GetItemCount(30009))
        end
    end
end

function UIAdvanced:commitTipButton(sender)
    SendMsg(PacketDefine.PacketDefine_SoldierUp_Send, {self._Solider._TableID})
end

function UIAdvanced:updateAdvancedItem()
    CreateAnimation(self._RootPanelNode, 480, 250, "csb/texiao/ui/T_u_ziti_goumai.csb", "animation0", false, 0, 1)
    local tmp = self._Solider._CharacterData.quality  
    if ItemDataManager:GetItemCount(30009) ~= nil then
        self._ItemNum:setString(ItemDataManager:GetItemCount(30009).."/".. GameGlobal:GetChangeDataManager()[self._Solider._TableID]["itemnumber"])
        if ItemDataManager:GetItemCount(30009) <  GameGlobal:GetChangeDataManager()[self._Solider._TableID]["itemnumber"] then
            local r, _ = string.find(self._ItemNum:getString(), '/')
            for i = 0, r - 2, 1 do
                local letter = self._ItemNum:getLetter(tonumber(i))
                letter:setColor(cc.c3b(255,0,0))
            end
        else
            local r = self._ItemNum:getStringLength()
            for i = 0, r - 1, 1 do
                local letter = self._ItemNum:getLetter(tonumber(i))
                letter:setColor(cc.c3b(250,242,206))
            end
        end
    else
        self._ItemNum:setString("0/"..ITEMNUM[tmp])
    end
end

function UIAdvanced:createArrowEffects()
    -- 士兵进阶 箭头特效
    local jiantou4 = seekNodeByName(self._RootPanelNode, "UI_jj_jiantou_4")
    local w = seekNodeByName(self._RootPanelNode, "UI_jj_jiantou_4"):getContentSize().width
    local h = seekNodeByName(self._RootPanelNode, "UI_jj_jiantou_4"):getContentSize().height
    self._AdvancedArrowEffect = CreateAnimation(jiantou4, w / 2, h / 2, UI_ADVANCED_ARROW_EFFECT, "animation0", true, 1, 1)
end

function UIAdvanced:releaseArrowEffects()
    removeNodeAndRelease(self._AdvancedArrowEffect)
    self._AdvancedArrowEffect = nil
end

return UIAdvanced
