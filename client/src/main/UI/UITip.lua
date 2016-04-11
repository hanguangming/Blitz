----
-- 文件名称：UITip.lua
-- 功能描述：测试UI
-- 文件说明：
-- 作    者：田凯
-- 创建时间：2015-6-16
-- 修改 ：
--  测试UI动画的支持情况
--
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
local UISystem =  GameGlobal:GetUISystem()
local stringFormat = string.format
local toString = tostring
local _Instance = nil 
local _CallBack = nil 
local UITip = class("UITip", UIBase)

-- 构造函数
function UITip:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_TipUI
    self._ResourceName =  "UITip.csb"
    
end

-- Load
function UITip:Load()
    UIBase.Load(self)
    self._Content = self:GetUIByName("Text_10")
--    self._RootPanelNode:setSwallowTouches(true) 
--    self._RootPanelNode:setTag(1)
--    self._RootPanelNode:addTouchEventListener(handler(self, self.TouchEvent))
--    self:GetUIByName("Panel_1"):setSwallowTouches(true) 
    self:GetUIByName("Close"):setTag(1)
    self:GetUIByName("Close"):addTouchEventListener(handler(self, self.TouchEvent))
    self._Ok = self:GetUIByName("Button_5")
    self._Ok:setTag(0)
    self._Ok:addTouchEventListener(handler(self, self.TouchEvent))
    self._Cancel = self:GetUIByName("Button_6")
    self._Cancel:setTag(1)
    self._Cancel:addTouchEventListener(handler(self, self.TouchEvent))
end

-- Unload
function UITip:Unload()
    UIBase.Unload(self)
    _CallBack = nil
    _Instance = nil
end

-- 打开
function UITip:Open()
    UIBase.Open(self)
end

-- 关闭
function UITip:Close()
    UIBase.Close(self)
end

function UITip:SetStyle(type, str)
    self._Cancel:setVisible(true)
    self._Ok:setVisible(true)
    self._Ok:setPositionX(300)
    if type == 1 then
        self._Cancel:setVisible(false)
        self._Ok:setPositionX(210)
    elseif type == 2 then
        self._Cancel:setVisible(false)
        self._Ok:setVisible(false)
        performWithDelay(self._RootPanelNode, self.CloseSelf, 1, self)
    end
    self._Content:setString(str)
end

function UITip:RegisteDelegate(callback, tag, content, delegate)
    self._CallBack = callback
    self._Ok:setVisible(true)
    self._Ok:setPositionX(300)
    self._Cancel:setVisible(true)
    self._Tag = tag
    if content ~= nil then
        self._Content:setString(content)
    end
    
    self._delegate = delegate
end

function UITip:TouchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if sender:getTag() == 0 then
            if self._CallBack ~= nil then
                if not self._delegate then
                    self._CallBack(self._Tag)
                else
                    self._CallBack(self._delegate, self._Tag)
                end
                
                self._CallBack = nil
            end
        end
        UISystem:CloseUI(UIType.UIType_TipUI)
    end
end

--TODO:修改如下代码的数字，太抽象
function UITip:OpenSkillInfo(x, y, skill, callBack)
    local h = 120
    local panel = CreateStopTouchScene(self.CloseScene)
    local  bg = CreateInfoBack(x ,y, 280, h, self.CloseScene, -1, 1)
    local base = {ChineseEquipDetail[1], ChineseEquipDetail[17]}
    local baseValue = {skill["name"], skill["desc"]}
   
    _Instance = self
    for i = 1, 2 do
        local des = cc.Label:createWithTTF(base[i], FONT_SIMHEI, BASE_FONT_SIZE)
        des:setAnchorPoint(cc.p(0, 1))
        des:setPosition(cc.p(15, h- 20 - 25 * (i - 1)))
        bg:addChild(des)

        local desData = cc.Label:createWithTTF(baseValue[i], FONT_SIMHEI, BASE_FONT_SIZE)
        desData:setDimensions(210, 75)
        desData:setAnchorPoint(cc.p(0, 1))
        desData:setPosition(cc.p(60, h - 20- 25 * (i - 1)))
        bg:addChild(desData)
    end
    panel:addChild(bg)
    UISystem:GetUIRootNode():addChild(panel:getParent(), 10000 , 101)
end

function UITip:OpenEquipInfo(x, y, item, callBack, type, wstar)
--    if _CallBack ~= nil then
--        return
--    end
    UISystem:GetUIRootNode():removeChildByTag(101, true)
    _Instance = self
    _CallBack = callBack
    local h = 400 
    if type == -1 then
        h = 350
    else
        type = type + 3
    end
    local  bg = CreateInfoBack(x ,y, 280, h, self.CloseScene, type, 1)

    local posname = GetPropDataManager()[item._ItemTableID]["subtype"] 
    local quality = GetPropDataManager()[item._ItemTableID]["star"]..ChineseEquip[8]    
    local sstar =  wstar
    if type ~= 5 then
        sstar = GetPropDataManager()[item._ItemTableID]["star"]
    end
    local equipsData = {
         item._PropData["name"], posname, item._ItemEquipLevel,item._EquipAtk, item._EquipHp, item._EquipSpeed, quality, 
        "   ("..sstar.."/50)", 
    }

    local hpNum = 0
    local atkNum = 0
    if GetPropDataManager()[item._ItemTableID]["star"] >= 50 then
        hpNum = 20
        atkNum = 36
    elseif GetPropDataManager()[item._ItemTableID]["star"] >= 30 then
        hpNum = 20
        atkNum = 20
    elseif GetPropDataManager()[item._ItemTableID]["star"] >= 25 then
        hpNum = 12
        atkNum = 12
    elseif GetPropDataManager()[item._ItemTableID]["star"] >= 20 then
        hpNum = 7
        atkNum = 7
    end 
    
    local greenColorIndex = nil
    if sstar >= 50 then
        greenColorIndex = 13
    elseif sstar >= 40 then
        greenColorIndex = 12
    elseif sstar >= 30 then
        greenColorIndex = 11
    elseif sstar >= 25 then
        greenColorIndex = 10
    elseif sstar >= 20 then
        greenColorIndex = 9
    else
        greenColorIndex = 8
    end
    
    atkNum = string.format(ChineseEquip[14], atkNum)
    hpNum = string.format(ChineseEquip[15], hpNum)
    
    local posY_Num = 1
    for i = 1, 15 do
        local key = 1
        if i == 4 or i == 5 or i == 6 then
            if tonumber(equipsData[i]) == 0 then
                key = 0
                posY_Num = posY_Num - 1
            else
                key = 1
            end
        end
        if key == 1 then
--            local des = cc.Label:createWithTTF(ChineseEquipDetail[i], FONT_FZLTTHJW, BASE_FONT_SIZE_MIN)
            local des = cc.Label:create()
            des:setAnchorPoint(cc.p(0, 0.5))
            des:setSystemFontSize(BASE_FONT_SIZE - 1)
            des:setString(ChineseEquipDetail[i])
            des:setPosition(cc.p(15, h - 25 - 20 * (posY_Num - 1)))
            des:setColor(cc.c4b(255, 221, 98, 250))
            bg:addChild(des)
            
            local value
            if i == 1 then
                value = cc.Label:createWithTTF(equipsData[i], FONT_FZLTTHJW, BASE_FONT_SIZE_MIN + 1)
            elseif i <= 8 then
                value = cc.Label:create()
                value:setString(equipsData[i])
            elseif i == 15 then
                value = cc.Label:create()
                value:setString(hpNum)
            elseif i == 14 then
                value = cc.Label:create()
                value:setString(atkNum)
            else
                value = cc.Label:create()
                value:setString(ChineseEquip[i])
            end
            value:setAnchorPoint(cc.p(0, 0.5))
            value:setSystemFontSize(BASE_FONT_SIZE - 1)
            if i == 1 then
                local color = GetQualityColor(tonumber(item._PropData["quality"]))
                value:setColor(color)
                value:enableOutline(BASE_FONT_OUTCOLOR, 1)
            end
            if i >= 9 and i <= greenColorIndex then
                des:setColor(cc.c3b(0,255,0))
                value:setColor(cc.c3b(0,255,0))
            elseif i <= 13 and i > greenColorIndex and greenColorIndex ~= 0 then
                des:setColor(cc.c3b(144,144,144))
                value:setColor(cc.c3b(144,144,144))
            end
            value:setPosition(cc.p(65, h - 25 - 20 * (posY_Num - 1)))
            bg:addChild(value)
        end
        posY_Num = posY_Num + 1
    end
    UISystem:GetUIRootNode():addChild(bg, 10000 , 101)
end

function UITip:OpenTipsInfo(x, y, width, height, data, type)
    if _CallBack ~= nil then
        return
    end
    _Instance = self
    local  panel = CreateStopTouchScene(self.CloseScene)
    local bg = display.newLayer(cc.c4b(0, 0, 0, 0), cc.size(width, height))
    local ss = ccui.Scale9Sprite:create("meishu/ui/gg/UI_wj_tips.png")
    ss:setContentSize(width, height)
    ss:setAnchorPoint(0, 1)
    ss:setPosition(cc.p(0, 0))
    bg:setAnchorPoint(0, 1)
    bg:addChild(ss, 10)
    bg:setPosition(cc.p(x, y))
    
    local beginIndex = 0
    local endIndex = 0
    if type == 1 then
        beginIndex = 1
        endIndex = 2
    elseif type == 3 then
        beginIndex = 3
        endIndex = 4
    elseif type == 2 then
        beginIndex = 5
        endIndex = 5
    elseif type == 4 then
        beginIndex = 6
        endIndex = 10
    end
    for i = beginIndex, endIndex do
--        local value = cc.Label:create()
        local value = cc.Label:createWithTTF("", "fonts/msyh.ttf", BASE_FONT_SIZE - 1)
--        value:setSystemFontSize(BASE_FONT_SIZE - 1)
        value:setColor(cc.c4b(255, 255, 255, 250))
        value:setAnchorPoint(0, 0.5)
        if i == 1 or i == 3 or i == 6 then
            value:setString(string.format(ChineseTip[i], data[1], data[2]))
            value:setPosition(cc.p(15, -25))
        elseif i == 5 then
            value:setString(string.format(ChineseTip[i], data[1]))
            value:setPosition(cc.p(15, -35))
        elseif i == 2 or i == 4 then
            value:setString(ChineseTip[i])
            value:setPosition(cc.p(15, -45))
        elseif i == 7 then
            value:setString(ChineseTip[i])
            value:setPosition(cc.p(15, -50))
            value:setTextColor(cc.c3b(255, 220, 130))
        elseif i >= 8 then
            value:setString(ChineseTip[i])
            value:setPosition(cc.p(15, -70 - (i - 8)*20))
        end
        bg:addChild(value, 10)
    end
    panel:addChild(bg, 10)
    UISystem:GetUIRootNode():addChild(panel:getParent(), 10000 , 101)
end

function UITip:OpenRewardInfo(x, y, items, callBack)
    _Instance = self
    _CallBack = callBack
    local panel = CreateStopTouchScene(self.CloseScene)
    local h = (#items -1 ) * 60
    local bg = display.newLayer(cc.c4b(0, 0, 0, 0), cc.size(200, h))
    local ss = ccui.Scale9Sprite:create("meishu/ui/gg/UI_gg_shenghuidi_01.png")
    ss:setContentSize(200, h)
    ss:setColor(cc.c3b(0, 0, 0))
    ss:setOpacity(200)
    ss:setAnchorPoint(0, 0)
    bg:addChild(ss)
    bg:setPosition(x, 540 - y - h)
    for i = 1, #items - 1 do
        print(GetPropPath(items[i + 1]["p1"]))
        local icon = display.newSprite(GetPropPath(items[i + 1]["p1"]), 40, -30 + 60 * i)
        if items[i + 1]["p1"] > 100 then
            local iconName = cc.Label:createWithTTF(GetPropDataManager()[tonumber(items[i + 1]["p1"])]["name"], FONT_SIMHEI, BASE_FONT_SIZE)
            iconName:setAnchorPoint(0, 0.5)
            iconName:setPosition(cc.p(80, -30 + 60 * i))
            local color = GetQualityColor(tonumber(GetPropDataManager()[tonumber(items[i + 1]["p1"])]["quality"]))
            iconName:setColor(color)
            bg:addChild(iconName)
        else
            local iconName = cc.Label:createWithTTF(ChineseConvert["ItemName_"..items[i + 1]["p1"]].." X"..items[i + 1]["l1"], FONT_SIMHEI, BASE_FONT_SIZE)
            iconName:setAnchorPoint(0, 0.5)
            iconName:setPosition(cc.p(80, -30 + 60 * i))
            local color = GetQualityColor(1)
            iconName:setColor(color)
            bg:addChild(iconName)
        end
        bg:addChild(icon)
    end
    panel:addChild(bg)
    UISystem:GetUIRootNode():addChild(panel:getParent(), 10000 , 101)
end

--warrior Tips
function UITip:OpenWarriorTips(x, y, item, callBack, level)

    --[[ copy from ChineseConvert
    ["UISoldierTip_1"] = "名称",
    ["UISoldierTip_2"] = "士兵类型",
    ["UISoldierTip_3"] = "攻击类型",
    ["UISoldierTip_4"] = "血量",
    ["UISoldierTip_5"] = "攻击",
    ["UISoldierTip_6"] = "攻速",
    ["UISoldierTip_7"] = "攻击距离",
    ["UISoldierTip_8"] = "移动速度",
    ["UISoldierTip_9"] = "消耗",
    ["UISoldierTip_10"] = "产出",
    ]]--
    if _CallBack ~= nil then
        return
    end
    _Instance = self
    _CallBack = callBack
    
    local h = 240
    local panel = CreateStopTouchScene(self.CloseScene)
    local  bg = CreateInfoBack(x ,y, 240, h, self.CloseScene, 0, 1, 200)
    local soldierType = GetSoldierType(item.soldierType)
    local attackType = GetSoldierAttackType(item.soldierType)
    local baseValue = {item.name, soldierType, attackType, toString(item.hp + item.hpup * (level - 1)), toString(item.attack + item.attackup * (level - 1)),
        toString(item.attackSpeed), toString(item.maxAttackDistance), toString(item.moveSpeed), toString(item.consumeFood)
        ,toString(item.outFood)}
    _Instance = self
    for i = 1, 8 do
        local desFieldName = stringFormat("%s%d","UISoldierTip_", i)
        local desShowName = ChineseConvert[desFieldName]..":"
        local des = cc.Label:createWithTTF(desShowName, FONT_SIMHEI, BASE_FONT_SIZE)
        des:setAnchorPoint(cc.p(0, 1))
        des:setPosition(cc.p(15, h- 20 - 25 * (i - 1)))
        bg:addChild(des)
        local x, y = des:getPosition()
        local offX = x + des:getContentSize().width + 5
        local desData = cc.Label:createWithTTF(baseValue[i], FONT_SIMHEI, BASE_FONT_SIZE)
        desData:setDimensions(210, 75)
        desData:setAnchorPoint(cc.p(0, 1))
        desData:setPosition(cc.p(offX, h - 20- 25 * (i - 1)))
        if i == 1 then
            local color = GetQualityColor(tonumber(item["quality"]))
            desData:setColor(color)
        end
        bg:addChild(desData)
    end
    panel:addChild(bg)
    UISystem:GetUIRootNode():addChild(panel:getParent(), 10000 , 101)

end

--士兵Tips
function UITip:OpenSoldierTips(x, y, item, callBack)
    
    --[[ copy from ChineseConvert
    ["UISoldierTip_1"] = "名称",
    ["UISoldierTip_2"] = "士兵类型",
    ["UISoldierTip_3"] = "攻击类型",
    ["UISoldierTip_4"] = "血量",
    ["UISoldierTip_5"] = "攻击",
    ["UISoldierTip_6"] = "攻速",
    ["UISoldierTip_7"] = "攻击距离",
    ["UISoldierTip_8"] = "移动速度",
    ["UISoldierTip_9"] = "消耗",
    ["UISoldierTip_10"] = "产出",
    ["UISoldierTip_11"] = "人口",
    --]]
    if _CallBack ~= nil then
        return
    end
    _Instance = self
    _CallBack = callBack
    local h = 380
    local panel = CreateStopTouchScene(self.CloseScene)
    local  bg = CreateInfoBack(x ,y, 280, h, self.CloseScene, 6, 1)
    local soldierType = GetSoldierType(item._CharacterData.soldierType)
    local attackType = GetSoldierAttackType(item._CharacterData.soldierType)
    local baseValue = {item._CharacterData.name, soldierType, attackType, toString(item._Hp), toString(item._Attack),
        toString(item._AtkSpeed), toString(item._GongJu), toString(item._MoveSpeed), toString(item._CharacterData.consumeFood)
        ,toString(item._CharacterData.outFood), toString(item._CharacterData.people)}
    
    for i = 1, 11 do
        local desFieldName = stringFormat("%s%d","UISoldierTip_", i)
        local desShowName = ChineseConvert[desFieldName]
        local des = cc.Label:createWithTTF(desShowName, FONT_SIMHEI, BASE_FONT_SIZE)
        des:setAnchorPoint(cc.p(0, 1))
        des:setPosition(cc.p(15, h- 20 - 25 * (i - 1)))
        bg:addChild(des)
        local x, y = des:getPosition()
        local offX = x + des:getContentSize().width + 5
        local desData = cc.Label:createWithTTF(baseValue[i], FONT_SIMHEI, BASE_FONT_SIZE)
        desData:setDimensions(210, 75)
        desData:setAnchorPoint(cc.p(0, 1))
        desData:setPosition(cc.p(offX, h - 20- 25 * (i - 1)))
        bg:addChild(desData)
    end
    panel:addChild(bg)
    UISystem:GetUIRootNode():addChild(panel:getParent(), 10000 , 101)

end

function UITip:CloseScene()
    local tag = 0
    
    if type(self) == "number" then
        tag = self
    else
        tag = self:getTag()
    end
    if tag == -1 then 
        UISystem:GetUIRootNode():removeChildByTag(101, true)
        if _CallBack ~= nil then
            _CallBack(-1)
            performWithDelay(UISystem:GetUIRootNode(), _Instance.RemoveCallBack, 0.2, self)
        end
    elseif tag == 1 then
       UISystem:GetUIRootNode():removeChildByTag(101, true)
       if _CallBack ~= nil then
            _CallBack(1)
            _CallBack = nil
       end
    end
end

function UITip:CloseSelf()
    print(self.__cname)
    UISystem:CloseUI(UIType.UIType_TipUI)
end

function UITip:RemoveCallBack()
    _CallBack = nil
end

return UITip
