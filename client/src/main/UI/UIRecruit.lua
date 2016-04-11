----
-- 文件名称：UIRecruit.lua
-- 功能描述：UIRecruit
-- 文件说明：UIRecruit
-- 作    者：田凯
-- 创建时间：2015-6-26
--  修改
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
require("cocos.ui.DeprecatedUIEnum")
require("cocos.extension.ExtensionConstants")
local ItemDataManager = require("main.ServerData.ItemDataManager") 
local GamePlayerDataManager = GameGlobal:GetGamePlayerDataManager()
local CharacterServerDataManager = require("main.ServerData.CharacterServerDataManager")
local CharacterDataManager =  GameGlobal:GetCharacterDataManager()
local UISystem = GameGlobal:GetUISystem()
local _Instance = nil 
local flagTip = 0
local recruitWarriorId = 0

local TX_FONT_ZHAOMU = "csb/texiao/ui/T_u_ziti_zhaomu.csb"
local TX_FONT_GUANGQUAN = "csb/texiao/ui/T_u_zhaomu_guangquan.csb"
local TX_FONT_GUANGQUANS = "csb/texiao/ui/T_u_zhaomu_guangS.csb"
local TX_FONT_GONGXI = "csb/texiao/ui/T_u_zhaomu_guang.csb"
local TX_FONT_GOUMAISUCCESS = "csb/texiao/ui/T_u_ziti_goumai.csb"
--图片提取
local ZM_GAOJI_BUTTON = "meishu/ui/zhaomu/UI_zm_gaoji_03.png"
local IMAGE_NAME_DI = "meishu/ui/zhaomu/UI_zm_mingzidi.png"
local IMAGE_NULL = "meishu/ui/gg/null.png"

local UIRecruit = class("UIRecruit", UIBase)

function UIRecruit:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_UIRecruit
    self._ResourceName = "UIRecruit.csb"  
    --特效动画节点
    self._TeXiaoNodeList = nil
    --特效节点动画
    self._TeXiaoNodeAnimList = nil
end

function UIRecruit:Load()
    UIBase.Load(self)
    _Instance = self
    self._RecruitIndex = 1
    -- tableView 
    local center = seekNodeByName(self._RootPanelNode, "Panel_Center")
    self._RootPanelNode:setSwallowTouches(true) 
--    self._GridView = CreateTableView(-287, -25, 300, 240, 1, self)
--    center:addChild(self._GridView)
    self._RootPanelNode:setPosition(0, 0)
    
--    self._SelectFrame = display.newSprite("meishu/ui/gg/UI_gg_xuanzhongkuang.png", 0, 800)
--    self._GridView:addChild(self._SelectFrame, 10)
--    self._SelectFrame:retain()
    
    self._ButtonList = {}
    self._ButtonList[5] = self:GetWigetByName("Recruit1")
    self._ButtonList[6] = self:GetWigetByName("Recruit2")
    self._ButtonList[7] = self:GetWigetByName("Recruit3")
    self._Image4 = self:GetWigetByName("Image_4")
    self._WarriorBtn = self:GetWigetByName("Button_10")
    self._WarriorBtn:getTitleRenderer():enableOutline(cc.c4b(249, 213, 153, 250), 1)
    self._WarriorBtn:getTitleRenderer():setPositionY(28)
    self._WarriorBtn:addTouchEventListener(self.OpenWarriorShop)
    for i = 5, 7 do
        self._ButtonList[i]:addTouchEventListener(self.TouchEvent)
        self._ButtonList[i]:setTag(i)
    end
--    self._ButtonList[8] = self:GetUIByName("RecruitStart")
--    self._ButtonList[8]:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 250), 2)
--    self._ButtonList[8]:getTitleRenderer():setPositionY(32)
    self._RecruitValue = self:GetUIByName("Text_21")
    self._PurplValue = self:GetUIByName("Text_22")
    self._YellowHunValue = self:GetUIByName("Text_23")
--    self._LuckValue = seekNodeByName(self:GetUIByName("Image_16"), "Text_1")
   
    local close = self:GetWigetByName("Close")
    close:setTag(-1)
    close:addTouchEventListener(self.TouchEvent)
    self._Time1 = seekNodeByName(self._ButtonList[5], "Text_1")
    self._Time1:setTag(1)
    self._Time2 = seekNodeByName(self._ButtonList[6], "Text_1")
    self._Time2:setTag(2)
    self._Time3 = seekNodeByName(self._ButtonList[7], "Text_1")
    self._Time3:setTag(3)
    self._Time1:setString("")
    self._Time2:setString("")
    self._Time3:setString("")
    self._Num1 = seekNodeByName(self._ButtonList[5], "Text_2")
    self._Num2 = seekNodeByName(self._ButtonList[6], "Text_2")
    self._Num3 = seekNodeByName(self._ButtonList[7], "Text_2")
    self._BodyImage = {}
    self._BodyAni = {}
    for i = 1, 6 do
        self._BodyAni[i] = self:GetUIByName("Node_"..i)
        if i ~= 6 then
            self._BodyImage[i] = self:GetWigetByName("BodyImage"..i)
            self._BodyImage[i]:setTag(10 + i)
            self._BodyImage[i]:addTouchEventListener(self.TouchEvent)
        end
    end
    local panel = self:GetUIByName("Panel_2")
    self._WarriorData = {}
    for i = 1, 8 do
        self._WarriorData[i] = seekNodeByName(panel, "Text_"..i.."_0")
    end
    self._WarriorData[9] = seekNodeByName(panel, "Skill")

    self._WarriorNameLabels = {}
    self._WarriorNameBg = {}
    for i = 1, 5 do
        self._WarriorNameLabels[i] = seekNodeByName(center, "WarriorNameLabel"..i)
        self._WarriorNameBg[i] = seekNodeByName(center, "Image_Bg_"..i)
    end

    self._Recruit3Icon = seekNodeByName(self._ButtonList[7], "Image_4")
    self._RecruitAmountLabel = seekNodeByName(self._ButtonList[7], "Text_2")
    self._RecruitVipLimitLabel= seekNodeByName(self._ButtonList[7], "Text_VIP3_Open_Label")
end

function UIRecruit:EnterPlayAnimation(isplay)
--    local name ={ChineseConvert["UITitle_1"], GameGlobal:GetTipDataManager(UI_BUTTON_NAME_22), GameGlobal:GetTipDataManager(UI_BUTTON_NAME_6)}
--    if isplay then 
--        CreateBaseUIAction(self._RootPanelNode, -100, 312, -1, GameGlobal:GetTipDataManager(UI_BUTTON_NAME_9), name, 3, self.TouchEvent, self.EndCallBack, true)
--    else
--        CreateBaseUIAction(self._RootPanelNode, -100, 312, -1, GameGlobal:GetTipDataManager(UI_BUTTON_NAME_9), name, 3, self.TouchEvent, self.EndCallBack)
--    end
end

function UIRecruit.EndCallBack(value)
    for i = 1, 3 do
        _Instance._ButtonList[i] = value[i]
        _Instance._ButtonList[i]:setTag(i)
        seekNodeByName(value[i], "Text_1"):setColor(cc.c3b(188, 188, 188))
    end
    seekNodeByName(value[2], "Text_1"):setColor(cc.c3b(255, 209, 0))
     for i = 5, 7 do
        _Instance._ButtonList[i]:addTouchEventListener(_Instance.TouchEvent)
        _Instance._ButtonList[i]:setTag(i)
     end
end

function UIRecruit:OnTimeChange()
    _Instance._WarriorList[self:getTag() + 6] = _Instance._WarriorList[self:getTag() + 6] - 1
    if (_Instance._CDTime[self:getTag()] - os.time()) <= 0 then
        _Instance._CDTime[self:getTag()] = 0
        self:setString(ChineseConvert["UITitle_4"])
        return 
    end
    local timeStr =  CreateTimeString(_Instance._CDTime[self:getTag()]).."后免费"
    self:setString(timeStr)
end

function UIRecruit:SimulateClickButton(id)
    local cell = self._GridView:cellAtIndex(0)
    if cell ~= nil then
        local layout = cell:getChildByTag(0)
        local panel = seekNodeByName(layout, "Panel_1")
        
        local button = seekNodeByName(panel, "Button_"..id)
        if button ~= nil then
            SimulateClickButton(button, handlers(self, self.TableViewItemTouchEvent, 2)) 
        end
    end
end

function UIRecruit.ScrollViewDidScroll()

end

function UIRecruit.NumberOfCellsInTableView()
    return 1
end

function UIRecruit.TableCellTouched(view, cell)
    local index = cell:getIdx()
    
end

function UIRecruit:TableViewItemTouchEvent(value)
     local eventType = value
     if type(value) == "table" then
        eventType = value.eventType
     end
     if eventType == ccui.TouchEventType.ended then
        local index = self:getTag()
        if _Instance._WarriorList == nil then
            return
        end
        if tonumber(_Instance._WarriorList[index]) > 0 then
            _Instance._RecruitIndex = index
            _Instance._BodyImage:loadTexture(CharacterDataManager[_Instance._WarriorList[index]]["bodyImage"], UI_TEX_TYPE_LOCAL)
            _Instance:ChangeWarriorCsb(CharacterDataManager[_Instance._WarriorList[index]]["resName"], "Walk")
            _Instance._WarriorData[1]:setString(CharacterDataManager[_Instance._WarriorList[index]]["name"]) 
            _Instance._WarriorData[2]:setString(GetSoldierType(CharacterDataManager[_Instance._WarriorList[index]]["soldierType"]))
            _Instance._WarriorData[3]:setString(CharacterDataManager[_Instance._WarriorList[index]]["attack"])
            _Instance._WarriorData[4]:setString(CharacterDataManager[_Instance._WarriorList[index]]["hp"])
            _Instance._WarriorData[5]:setString(CharacterDataManager[_Instance._WarriorList[index]]["attackSpeed"])
            local SkillDataManager = GetSkillDataManager()
            local skill = SkillDataManager[CharacterDataManager[_Instance._WarriorList[index]].skill2]
            _Instance._WarriorData[6]:setString(SkillDataManager[CharacterDataManager[_Instance._WarriorList[index]].skill2].name)
            local infoList = Split(string.sub(skill["impact"], 2, string.len(skill["impact"]) - 1), ",")
            local skillAtk = 0
            if infoList[2] == 1 then
                skillAtk = CharacterDataManager[_Instance._WarriorList[index]]["attack"] * infoList[1]
            else
                skillAtk = CharacterDataManager[_Instance._WarriorList[index]]["attack"] * infoList[1] / 100
            end
            _Instance._WarriorData[7]:setString(math.floor(skillAtk))
            _Instance._WarriorData[8]:setString(SkillDataManager[CharacterDataManager[_Instance._WarriorList[index]].skill2].zoneShowString)
            _Instance._WarriorData[9]:loadTexture(SkillDataManager[CharacterDataManager[_Instance._WarriorList[index]].skill2].icon, UI_TEX_TYPE_LOCAL)
            _Instance._SelectFrame:setVisible(true)
            _Instance._SelectFrame:removeFromParent(false)
            _Instance._SelectFrame:setAnchorPoint(0.5, 0.5)
            _Instance._SelectFrame:ignoreAnchorPointForPosition(false)
            self:getParent():addChild(_Instance._SelectFrame)
            _Instance._SelectFrame:setPosition(self:getPosition())
        end
    end
end

function UIRecruit.CellSizeForTable(view, idx)
    return 240, 295
end

function UIRecruit.TableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
        cell:retain()
    end
    cell:removeAllChildren(true)
    local layout = cc.CSLoader:createNode("csb/ui/RecruitItem.csb")
    layout:setPosition(5, 0)
    cell:addChild(layout, 0, idx)
    _Instance:InitCell(cell, idx)
    return cell
end

function UIRecruit:InitCell(cell, idx)
    local layout = cell:getChildByTag(idx)
    local panel = seekNodeByName(layout, "Panel_1")
    if panel ~= nil then
        panel:setSwallowTouches(false) 
        
        for i = 1, 5 do
            local button = ccui.Helper:seekWidgetByName(panel, "Button_"..i)
            button:setTag(i)
            button:addTouchEventListener(self.TableViewItemTouchEvent)
            button:setSwallowTouches(false) 
            local star = ccui.Helper:seekWidgetByName(button, "Image_"..i)
            star:setSwallowTouches(false) 
            local icon = ccui.Helper:seekWidgetByName(button, "head")
            icon:setSwallowTouches(false) 
            local CharacterDataManager =  GetCharacterDataManager()
            if _Instance._WarriorList[i] > 0 then
                local text = ccui.Helper:seekWidgetByName(button, "Text_1")
                local color = GetQualityColor(tonumber(CharacterDataManager[_Instance._WarriorList[i]]["quality"]))
                text:setString(CharacterDataManager[_Instance._WarriorList[i]]["name"])
                text:setFontName(FONT_SIMHEI) 
                text:setFontSize(BASE_FONT_SIZE) 
                text:enableOutline(cc.c4b(0, 0, 0, 250), 1)
                --text:setColor(color)
                icon:loadTexture(GetWarriorHeadPath(CharacterDataManager[_Instance._WarriorList[i]]["headName"]), UI_TEX_TYPE_LOCAL)
                star:loadTexture("meishu/ui/gg/"..(CharacterDataManager[_Instance._WarriorList[i]]["quality"])..".png", UI_TEX_TYPE_LOCAL)
            end
        end
    end
end

function UIRecruit:Unload()
    UIBase:Unload()
    self._ResourceName = nil
    self._Type = nil
end

function UIRecruit:Open()
    UIBase.Open(self)
    self.OpenCallBack = AddEvent(GameEvent.GameEvent_UIRecruitOpen_Succeed, self.OpenUISucceed)
    self._RecruitCallBack = AddEvent(GameEvent.GameEvent_UIRecruit_Succeed, self.RecruitSucceed)
    self._RecruitSucceedCallBack = AddEvent(GameEvent.GameEvent_UIRecruitWarrior_Succeed, self.RecruitWarriorSucceed)
    self._BuyItemCallBack = AddEvent(GameEvent.GameEvent_UIAdvanced_Buy, self.UpdateRecruitItem)
    
    self:addEvent(GameEvent.GameEvent_MyselfInfoChange, self.playInfoChangeListener)
    
    self._TeXiaoNodeList = {}
    self._TeXiaoNodeAnimList = {}
    --添加"招募成功"字样动画
    local newTeXiaoNode =  cc.CSLoader:createNode(TX_FONT_ZHAOMU)
    local newTeXiaoNodeAnim2 = cc.CSLoader:createTimeline(TX_FONT_ZHAOMU) 
    newTeXiaoNode:runAction(newTeXiaoNodeAnim2)
    newTeXiaoNode:retain()
    self._TeXiaoNodeList[1] = newTeXiaoNode
    newTeXiaoNodeAnim2:retain()
    self._TeXiaoNodeAnimList[1] = newTeXiaoNodeAnim2
    --添加武将周身光效动画
    self._TeXiaoNodeList[2] = {}
    self._TeXiaoNodeAnimList[2] = {}
    for i = 1, 6 do
        newTeXiaoNode =  cc.CSLoader:createNode(TX_FONT_GUANGQUAN)
        newTeXiaoNodeAnim2 = cc.CSLoader:createTimeline(TX_FONT_GUANGQUAN) 
        newTeXiaoNode:runAction(newTeXiaoNodeAnim2)
        newTeXiaoNode:retain()
        self._TeXiaoNodeList[2][i] = newTeXiaoNode
        newTeXiaoNodeAnim2:retain()
        self._TeXiaoNodeAnimList[2][i] = newTeXiaoNodeAnim2
    end
    --添加招到高资质武将字样动画
    newTeXiaoNode =  cc.CSLoader:createNode(TX_FONT_GUANGQUANS)
    newTeXiaoNodeAnim2 = cc.CSLoader:createTimeline(TX_FONT_GUANGQUANS) 
    newTeXiaoNode:runAction(newTeXiaoNodeAnim2)
    newTeXiaoNode:retain()
    self._TeXiaoNodeList[3] = newTeXiaoNode
    newTeXiaoNodeAnim2:retain()
    self._TeXiaoNodeAnimList[3] = newTeXiaoNodeAnim2
    --添加"恭喜主公募得良将"字样动画
    newTeXiaoNode =  cc.CSLoader:createNode(TX_FONT_GONGXI)
    newTeXiaoNodeAnim2 = cc.CSLoader:createTimeline(TX_FONT_GONGXI) 
    newTeXiaoNode:runAction(newTeXiaoNodeAnim2)
    newTeXiaoNode:retain()
    self._TeXiaoNodeList[4] = newTeXiaoNode
    newTeXiaoNodeAnim2:retain()
    self._TeXiaoNodeAnimList[4] = newTeXiaoNodeAnim2
    --添加"购买成功"字样动画
    newTeXiaoNode =  cc.CSLoader:createNode(TX_FONT_GOUMAISUCCESS)
    newTeXiaoNodeAnim2 = cc.CSLoader:createTimeline(TX_FONT_GOUMAISUCCESS) 
    newTeXiaoNode:runAction(newTeXiaoNodeAnim2)
    newTeXiaoNode:retain()
    self._TeXiaoNodeList[5] = newTeXiaoNode
    newTeXiaoNodeAnim2:retain()
    self._TeXiaoNodeAnimList[5] = newTeXiaoNodeAnim2
    self:OpenUISucceed()
end

function UIRecruit:playInfoChangeListener()
    self:refreshRecruitBtnInfo()
end

function UIRecruit:refreshRecruitBtnInfo()
    local myselfData = GamePlayerDataManager:GetMyselfData()
    assert(myselfData)
    local vipLevel = myselfData._VIPLevel or 0

    if vipLevel >=3 then
        self._Recruit3Icon:setVisible(true)
        self._RecruitAmountLabel:setVisible(true)
        self._RecruitVipLimitLabel:setVisible(false)
        
        if tonumber(self._WarriorList[9] - os.time()) > 0 then
            local timeStr =  CreateTimeString(self._WarriorList[9]).."后免费"
            self._Time3:setString(timeStr)
            schedule(self._Time3, self.OnTimeChange, 1)
        else
            self._Time3:setString(ChineseConvert["UITitle_4"])
        end
    else
        self._Recruit3Icon:setVisible(false)
        self._RecruitAmountLabel:setVisible(false)
        self._RecruitVipLimitLabel:setVisible(true)
    end
end

function UIRecruit:UpdateRecruitItem()
    _Instance._Num1:setString(ItemDataManager:GetItemCount(30001))
    _Instance._Num2:setString(ItemDataManager:GetItemCount(30002))
    _Instance._Num3:setString(ItemDataManager:GetItemCount(30003))
    --动画-购买成功
    local currentSelectNode =  _Instance._TeXiaoNodeList[5]
    local anim = _Instance._TeXiaoNodeAnimList[5]
    local parentNode = currentSelectNode:getParent()
    if parentNode == nil then
        currentSelectNode:setPosition(cc.p(480, 270))
        _Instance._RootUINode:addChild(currentSelectNode, 11)
    end
    anim:play("animation0", false)
end

function UIRecruit:Close()
    UIBase.Close(self)
    if self.OpenCallBack ~= nil then
        RemoveEvent(self.OpenCallBack)
        self.OpenCallBack = nil 
    end
    if self._RecruitCallBack ~= nil then
        RemoveEvent(self._RecruitCallBack)
        self._RecruitCallBack = nil
    end
    if self._RecruitSucceedCallBack ~= nil then
        RemoveEvent(self._RecruitSucceedCallBack)
        self._RecruitSucceedCallBack = nil
    end
    
    if self._BuyItemCallBack ~= nil then
        RemoveEvent(self._BuyItemCallBack)
        self._BuyItemCallBack = nil
    end
    if self._TeXiaoNodeList ~= nil then
        for k,v in pairs(self._TeXiaoNodeList)do
            if v ~= nil and type(v) ~= "table" then
                v:removeFromParent()
                v:removeAllChildren()
                v:release()
            elseif v ~= nil and type(v) == "table" then
                for k,c in pairs(v)do
                    c:removeFromParent()
                    c:removeAllChildren()
                    c:release()
                end
            end
        end
        self._TeXiaoNodeList = nil
    end
    if self._TeXiaoNodeAnimList ~= nil then
        for k,v in pairs(self._TeXiaoNodeAnimList)do
            if v ~= nil and type(v) ~= "table" then
                v:release()
            elseif v ~= nil and type(v) == "table" then
                for k,c in pairs(v)do
                    c:release()
                end
            end
        end
        self._TeXiaoNodeAnimList = nil
    end
    self._WarriorList = nil
    flagTip = 0
end

function UIRecruit:RecruitSucceed()
--    CreateAnimation(_Instance._BodyAni[6], 0, 120, "csb/texiao/ui/T_u_zhaomu_guang.csb", "animation0", false, 0, 1)
end

function UIRecruit:RecruitWarriorSucceed()
    --动画-招募成功
    local currentSelectNode =  _Instance._TeXiaoNodeList[1]
    local anim = _Instance._TeXiaoNodeAnimList[1]
    local parentNode = currentSelectNode:getParent()
    if parentNode == nil then
        currentSelectNode:setPosition(cc.p(480, 270))
        _Instance._RootUINode:addChild(currentSelectNode)
    end
    anim:play("animation0", false)
    _Instance._RecruitValue:setString(GetPlayer()._ZhaoMuValue)
end

function UIRecruit:ChangeWarriorCsb(resName, action)
    if _Instance._CurWarrior~= nil then
        _Instance._CurWarrior:removeFromParent(true)
        _Instance._CurWarrior = nil
    end
    _Instance._CurWarrior = cc.CSLoader:createNode(resName)
    local ani = cc.CSLoader:createTimeline(resName)
    _Instance._CurWarrior:setPosition(cc.p(620, 363))
    _Instance._RootUINode:addChild(_Instance._CurWarrior, 80)
    _Instance._CurWarrior:runAction(ani)
    ani:play(action, true)
end

function UIRecruit:CheckWarrior()
    for i = 1, 5 do
        if _Instance._WarriorList == nil then
            return false
        end
        local id = _Instance._WarriorList[i]
        if id ~= nil and id > 0 then
            local CharacterDataManager =  GetCharacterDataManager() 
            if CharacterDataManager[_Instance._WarriorList[i]] ~= nil and (CharacterDataManager[_Instance._WarriorList[i]]["quality"] >= 3) then
                return true
            end
        end
    end
    return false
end

function UIRecruit:OpenUISucceed()
    _Instance._WarriorList = {}
    local rlist =  GetGlobalData()._RecruitList
    local index = 1
    local cloneWarrior = {}
    for i = 1, 5 do
        if rlist[i] ~= nil and rlist[i] > 0 then
            table.insert(cloneWarrior, rlist[i])
            table.insert(_Instance._WarriorList, rlist[i])
            print(rlist[i], i)
        end
    end
    for i = 1, 5 do
        _Instance._WarriorList[i] = 0
        _Instance._BodyImage[i]:loadTextures(tostring(IMAGE_NULL) ,tostring(IMAGE_NULL), UI_TEX_TYPE_LOCAL)
        _Instance._BodyAni[i]:removeAllChildren(true)
        _Instance._WarriorNameBg[i]:setVisible(false)

        if i == 1 then
            _Instance._BodyImage[i]:setPosition(-57, 140)
        elseif i == 2 then
            _Instance._BodyImage[i]:setPosition(110, 95)
        elseif i == 3 then
            _Instance._BodyImage[i]:setPosition(321, 65)
        elseif i == 4 then
            _Instance._BodyImage[i]:setPosition(540, 95)
        elseif i == 5 then
            _Instance._BodyImage[i]:setPosition(701, 140)
        end
    end
    
    if #cloneWarrior > 0 then
        --_Instance._GridView:reloadData()
        local  num = #cloneWarrior 
       
        local pos = {}
        if num == 3 then
            pos = {3, 4, 2}
        elseif num == 2 then
            pos = {2, 4}
        else
            pos = {3, 4, 2, 5, 1}
        end
        if #cloneWarrior > 1 then
            if cloneWarrior[1] > 0 then
                table.sort(cloneWarrior, function(a, b)
                    if a > 0 and b > 0 then
                        if CharacterDataManager[a] ~= nil and CharacterDataManager[b] ~= nil then
                            local quality1 = tonumber(CharacterDataManager[a]["quality"])
                            local quality2 = tonumber(CharacterDataManager[b]["quality"])
                            if quality1 == 0 then
                                quality1 = 2.5
                            end
                            if quality2 == 0 then
                                quality2 = 2.5
                            end
                            return quality1 > quality2
                        end
                    end
                end)
            end
        end
        
        for i = 1, #cloneWarrior do
            if cloneWarrior[i] > 0 then
                if CharacterDataManager[cloneWarrior[i]] ~= nil then
                    local path = GetWarriorBodyPath(CharacterDataManager[cloneWarrior[i]]["bodyImage"])
                    _Instance._BodyImage[pos[i]]:loadTextures(path ,path, UI_TEX_TYPE_LOCAL)
                    _Instance._BodyImage[pos[i]]:setLocalZOrder(12)
                    _Instance._WarriorList[pos[i]] = cloneWarrior[i]
                    local type = tonumber(CharacterDataManager[cloneWarrior[i]]["quality"])
                    --@TEMP:名字在玩家头上，以防需求变化
                    -- local sprite = cc.Sprite:create(tostring(IMAGE_NAME_DI))
                    -- sprite:setAnchorPoint(0.5, 0.5)
                    -- sprite:setPosition(cc.p(0, _Instance._BodyImage[pos[i]]:getContentSize().height * 0.7))
                    -- _Instance._BodyAni[pos[i]]:addChild(sprite, 10)
                    -- local name = cc.Label:createWithTTF(CharacterDataManager[cloneWarrior[i]]["name"], FONT_FZLTTHJW, BASE_FONT_SIZE)
                    -- name:setAnchorPoint(0.5, 0.5)
                    -- name:setPosition(cc.p(0, _Instance._BodyImage[pos[i]]:getContentSize().height * 0.7))
                    -- name:setColor(GetQualityColor(type))
                    -- _Instance._BodyAni[pos[i]]:addChild(name, 10)

                    _Instance._WarriorNameBg[pos[i]]:setVisible(true)
                    _Instance._WarriorNameLabels[pos[i]]:setColor(GetQualityColor(type))
                    _Instance._WarriorNameLabels[pos[i]]:setString(CharacterDataManager[cloneWarrior[i]]["name"])
                    
                    _Instance._BodyImage[pos[i]]:setOpacity(100)
                    local seq1 = cc.Sequence:create(cc.DelayTime:create(0.05), cc.CallFunc:create(function()
                        _Instance._BodyImage[pos[i]]:setOpacity(255)
                    end))
                    
                    local inFade =  cc.FadeIn:create(1.0)
                    local moveBy = cc.MoveBy:create(0.2, cc.p(0, -5))
                    local spawn = cc.Spawn:create(inFade, moveBy)
                    _Instance._BodyImage[pos[i]]:runAction(spawn)
                    
                    local scale = 1
                    if pos[i] == 1 or pos[i] == 5 then
                        scale = 0.8
                    elseif pos[i] == 2 or pos[i] == 4 then
                        scale = 0.9
                    else
                        scale = 1.0
                    end
                    if type >= 3 then
                        --动画-高品质武将特效-从天而降
                        local currentSelectNode1 =  _Instance._TeXiaoNodeList[3]
                        local anim1 = _Instance._TeXiaoNodeAnimList[3]
                        local parentNode = currentSelectNode1:getParent()
                        if parentNode == nil then
--                            currentSelectNode1:setPosition(cc.p(480, 230))
--                            _Instance._RootUINode:addChild(currentSelectNode1, 0)
                            currentSelectNode1:setPosition(cc.p(322, 77))
                            _Instance._BodyAni[3]:getParent():addChild(currentSelectNode1, 8)
                        end
                        anim1:play("animation0", false)
                        local seq = cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function()
                            --动画-恭喜主公募得良将
                            local currentSelectNode =  _Instance._TeXiaoNodeList[4]
                            local anim = _Instance._TeXiaoNodeAnimList[4]
                            local parentNode = currentSelectNode:getParent()
                            if parentNode == nil then
                                currentSelectNode:setPosition(cc.p(480, 270))
                                _Instance._RootUINode:addChild(currentSelectNode, 12)
                            end
                            anim:play("animation0", false)
                        end))
                        _Instance._RootPanelNode:runAction(seq)
--                        local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
--                        UITip:SetStyle(2, "请先招募稀有武将！")
                    end
                    --动画-武将周身光效
                    local frame = {[0] = "blue", "bai", "green", "qing", "zi", "yellow", "cheng"}
                    local currentSelectNode =  _Instance._TeXiaoNodeList[2][pos[i]]
                    local anim = _Instance._TeXiaoNodeAnimList[2][pos[i]]
                    local parentNode = currentSelectNode:getParent()
                    if parentNode == nil then
                        currentSelectNode:setPosition(cc.p(-4, 40))
                        currentSelectNode:setScale(scale)
                        _Instance._BodyAni[pos[i]]:addChild(currentSelectNode, 9)
                    end
                    anim:play(tostring(frame[type]), false)
                end
            end
        end
    end
   
    _Instance._WarriorList[7] = GetGlobalData()._RecruitTime[4]
    _Instance._WarriorList[8] = GetGlobalData()._RecruitTime[5]
    _Instance._WarriorList[9] = GetGlobalData()._RecruitTime[6]
    if _Instance._WarriorList[7] ~= nil then 
        _Instance._CDTime = {}
        if tonumber(_Instance._WarriorList[7] - os.time()) > 0 then
            local timeStr =  CreateTimeString(_Instance._WarriorList[7]).."后免费"
            _Instance._Time1:setString(timeStr)
            schedule(_Instance._Time1, _Instance.OnTimeChange, 1)
        else
            _Instance._Time1:setString(ChineseConvert["UITitle_4"])
        end
        if tonumber(_Instance._WarriorList[8] - os.time()) > 0 then
            local timeStr =  CreateTimeString(_Instance._WarriorList[8]).."后免费"
            _Instance._Time2:setString(timeStr)
            schedule(_Instance._Time2, _Instance.OnTimeChange, 1)
        else
            _Instance._Time2:setString(ChineseConvert["UITitle_4"])
        end
        
        _Instance:refreshRecruitBtnInfo()
        
        _Instance._CDTime [1] = _Instance._WarriorList[7]
        _Instance._CDTime [2] = _Instance._WarriorList[8]
        _Instance._CDTime [3] = _Instance._WarriorList[9]

--        _Instance._LuckValue:setString(_Instance._WarriorList[10])
    end
    _Instance._RecruitIndex = _Instance._RecruitIndex - 1
    if _Instance._RecruitIndex < 1 then
        _Instance._RecruitIndex = 1 
    end
    
    local ItemDataManager = GameGlobal:GetItemDataManager() 
    _Instance._PurplValue:setString(ItemDataManager:GetItemCount(15001))
    _Instance._YellowHunValue:setString(ItemDataManager:GetItemCount(15002))
    
    _Instance._Num1:setString(ItemDataManager:GetItemCount(30001))
    _Instance._Num2:setString(ItemDataManager:GetItemCount(30002))
    _Instance._Num3:setString(ItemDataManager:GetItemCount(30003))
    _Instance._RecruitValue:setString(GetPlayer()._ZhaoMuValue)
--    _Instance:SimulateClickButton(_Instance._RecruitIndex)
--    RemoveMsg(PacketDefine.PacketDefine_UpdateDrunkery_Send)
--    if _Instance:CheckWarrior() and flagTip == 1 then
--        local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
--        UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_zm_04))
--    end 
    flagTip = 1
end

function UIRecruit:TouchEvent(eventType, x, y)
    if eventType == ccui.TouchEventType.ended then
        local tag = self:getTag()
        print(tag) 
        if tag == -2  then
        elseif tag == -1 then
            UISystem:CloseUI(UIType.UIType_UIRecruit) 
            UISystem:CloseUI(UIType.UIType_WarriorUI) 
            UISystem:CloseUI(UIType.UIType_TrainUI) 
        elseif tag == 1 then
            UISystem:CloseUI(UIType.UIType_UIRecruit) 
            UISystem:OpenUI(UIType.UIType_WarriorUI)
--            local warrior = UISystem:OpenUI(UIType.UIType_WarriorUI)
--            warrior:EnterPlayAnimation(true)
--            SendMsg(PacketDefine.PacketDefine_SmeltEquipList_Send)
        elseif tag == 3 then
            UISystem:CloseUI(UIType.UIType_UIRecruit) 
            local warrior = UISystem:GetUIInstance(UIType.UIType_WarriorUI)
--            if warrior == nil then
--                warrior = UISystem:OpenUI(UIType.UIType_WarriorUI)
--            end
            if warrior and not warrior:CheckWarriorNull() then 
                return
            end
            local  train = UISystem:OpenUI(UIType.UIType_TrainUI)
            train:ChangeTabState(1)
            UISystem:CloseUI(UIType.UIType_WarriorUI) 
--            UISystem:OpenUI(UIType.UIType_WarriorStore)
        elseif tag == 5  then
            if ItemDataManager:GetItemCount(30001) > 0 or math.floor(_Instance._CDTime [1]- os.time()) <= 0 then
                if _Instance:CheckWarrior() then
                    local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                    UITip:SetStyle(2, "请先招募稀有武将！")
                    return
                end
                SendMsg(PacketDefine.PacketDefine_Recruit_Send, {1})
            else 
--                local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
--                UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_zm_01))
                local uiInstance = UISystem:OpenUI(UIType.UIType_BuyItem)
                uiInstance:OpenItemInfoNotifiaction(30001)
            end
        elseif tag == 6  then
            if ItemDataManager:GetItemCount(30002) > 0 or _Instance._CDTime [2]- os.time() <= 0 then
                if _Instance:CheckWarrior() then
                    local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                    UITip:SetStyle(2, "请先招募稀有武将！")
                    return
                end
                SendMsg(PacketDefine.PacketDefine_Recruit_Send, {2})
            else
--                local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
--                UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_zm_02))
                local uiInstance = UISystem:OpenUI(UIType.UIType_BuyItem)
                uiInstance:OpenItemInfoNotifiaction(30002)
            end
        elseif tag == 7  then
            if  GetPlayer()._VIPLevel < 3 then
                local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                UITip:SetStyle(0, "vip3可开启高级招募功能，是否充值？")
                UITip:RegisteDelegate(UIRecruit.OnQuickConfirm, 1)
                return
            end
            if ItemDataManager:GetItemCount(30003) > 0 or _Instance._CDTime [3]- os.time() <= 0 then
                if _Instance:CheckWarrior() then
                    local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                    UITip:SetStyle(2, "请先招募稀有武将！")
                    return 
                end
                SendMsg(PacketDefine.PacketDefine_Recruit_Send, {3})
            else
--                local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
--                UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_zm_03))
                local uiInstance = UISystem:OpenUI(UIType.UIType_BuyItem)
                uiInstance:OpenItemInfoNotifiaction(30003)
            end
        elseif tag >= 11  then 
            if _Instance._WarriorList[tag - 10] > 0 then
                recruitWarriorId = tag - 10
                _Instance:WarriorRecruitBtn()
            else
                local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
                UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_zs_03))
            end
        end
    end
end

function UIRecruit:OnQuickConfirm()
    UISystem:OpenUI(UIType.UIType_UIRecharge)
end

function UIRecruit:WarriorRecruitBtn()
    local layout = cc.CSLoader:createNode("csb/ui/RecruitTip.csb")
    local close = seekNodeByName(layout, "Close")
    close:addTouchEventListener(_Instance.CloseTip)
    _Instance._RootPanelNode:addChild(layout, 100, 123)

    local warrior = CharacterDataManager[_Instance._WarriorList[recruitWarriorId]]

    seekNodeByName(layout, "Image_20"):loadTexture(GetWarriorBodyPath(warrior["bodyImage"]))

    local type = tonumber(warrior["quality"])
    local text1 = seekNodeByName(layout, "Text_1")
    text1:setTextColor(GetQualityColor(type))
    text1:setString(warrior["name"])

    seekNodeByName(layout, "Text_18"):enableOutline(cc.c4b(70, 35, 15, 250), 1)
    seekNodeByName(layout, "Text_21"):setString(warrior["hp"])
    seekNodeByName(layout, "Text_22"):setString(warrior["attack"])
    seekNodeByName(layout, "Text_19"):setString(GetSoldierType(warrior["soldierType"]))
    
    local SkillDataManager = GetSkillDataManager()
    -- 获取技能名称
    local skillId = tonumber(warrior["skill1"])
    for i,v in pairs(GetSkillDataManager()) do
        if skillId == v.id then
            seekNodeByName(layout, "Text_20"):setString(v["zoneShowString"])
            break
        end
    end
    seekNodeByName(layout, "Text_23"):setString(GetWarriorQuality(warrior["intelligent"])) 
    local intelligent = warrior["intelligent"]
    local intelligentTable = {1, 2, 0, 3, 4, 5, 6, 7, 0, 0}
    seekNodeByName(layout, "Text_23"):setTextColor(GetQualityColor(intelligentTable[intelligent]))
    
    seekNodeByName(layout, "Text_18"):setString(warrior["skillname"])
    if GetWarriorStarImage(type) ~= nil then
        seekNodeByName(layout, "Image_ZiZhi"):loadTexture(GetWarriorStarImage(type), UI_TEX_TYPE_LOCAL)
    end
    local btn = seekNodeByName(layout, "Button_2")
    btn:getTitleRenderer():enableOutline(cc.c4b(253, 206, 58, 250), 1)
    btn:getTitleRenderer():setPositionY(40)
    btn:addTouchEventListener(_Instance.WarriorRecruit)
    seekNodeByName(seekNodeByName(layout, "Image_21"), "Text_24"):enableOutline(cc.c4b(77, 39, 18, 250), 2)
    local path = GetSkillPath(warrior["skillicon"])
    seekNodeByName(layout, "Button_11"):loadTextures(path ,path, UI_TEX_TYPE_LOCAL)
    --光效
    local node = seekNodeByName(layout, "Node_8")
    local type = tonumber(warrior["quality"])
    local frame = {[0] = "blue", "bai", "green", "qing", "zi", "yellow", "cheng"}
    --动画-武将周身动画
    local currentSelectNode =  _Instance._TeXiaoNodeList[2][6]
    local anim = _Instance._TeXiaoNodeAnimList[2][6]
    local parentNode = currentSelectNode:getParent()
    if parentNode == nil then
        currentSelectNode:setPosition(cc.p(0, 28))
        node:addChild(currentSelectNode, 11)
    end
    anim:play(tostring(frame[type]), false)
end

function UIRecruit:WarriorRecruit(eventType)
    if eventType == ccui.TouchEventType.ended then
        local curWarriorCount = table.nums(CharacterServerDataManager._OwnLeaderList)
        local gamePlayerDataManager = GameGlobal:GetGamePlayerDataManager()
        local myselfData = gamePlayerDataManager:GetMyselfData()
        local maxWarriorCount = GameGlobal:GetVipDataManager()[myselfData._VIPLevel].heromax
        --武将已达上限，提示玩家
        if maxWarriorCount > curWarriorCount then
            SendMsg(PacketDefine.PacketDefine_HeroEmploy_Send, {_Instance._WarriorList[recruitWarriorId] , 1})
            _Instance._RootPanelNode:removeChildByTag(123, true)
            _Instance._WarriorList[recruitWarriorId] = 0
            _Instance._BodyImage[recruitWarriorId]:loadTextures(tostring(IMAGE_NULL) ,tostring(IMAGE_NULL), UI_TEX_TYPE_LOCAL)
            _Instance._BodyAni[recruitWarriorId]:removeAllChildren(true)
        else
            CreateTipAction(_Instance._RootUINode, "拥有武将已达上限", cc.p(480, 270))
        end
        
    end
end

function UIRecruit:OpenWarriorShop(eventType)
    if eventType == ccui.TouchEventType.ended then
        UISystem:OpenUI(UIType.UIType_WarriorStore)
    end
end

function UIRecruit:CloseTip(eventType)
    if eventType == ccui.TouchEventType.ended then
        _Instance._RootPanelNode:removeChildByTag(123, true)
    end
end

return UIRecruit