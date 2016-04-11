----
-- 文件名称：UISmelt.lua
-- 功能描述：UISmelt
-- 文件说明：UISmelt
-- 作    者：田凯
-- 创建时间：2015-6-26
--  修改
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
require("cocos.ui.DeprecatedUIEnum")
require("cocos.extension.ExtensionConstants")
local ItemDataManager = require("main.ServerData.ItemDataManager") 
local UISystem = GameGlobal:GetUISystem()
local UISmelt = class("UISmelt", UIBase)
-- 高品阶装备背景特效
local UI_EQUIP_BG_YELLOW_EFFECT    = "csb/texiao/ui/T_u_yelian_1.csb"
local UI_EQUIP_BG_BLUE_EFFECT    = "csb/texiao/ui/T_u_yelian_3_blue.csb"

function UISmelt:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_UISmelt
    self._ResourceName = "UISmelt.csb"  
end

function UISmelt:Load()
    UIBase.Load(self)
    self._GridView = CreateTableView_(70, 145, 880, 306, 0, self)
    self._GridView:setTouchEnabled(false)
    self._RootPanelNode:addChild(self._GridView)
    self._RootPanelNode:setPosition(0, 0)
    self._RootPanelNode:setSwallowTouches(true) 
    self._ButtonList = {}
    self._ButtonList[1] = self:GetUIByName("Button_t1")
    self._ButtonList[2] = self:GetUIByName("Button_t2")
    self._ButtonList[3] = self:GetUIByName("Button_t3")
    self._ButtonList[5] = self:GetUIByName("Recruit1")
    self._ButtonList[6] = self:GetUIByName("Recruit2")
    self._ButtonList[7] = self:GetUIByName("Recruit3")
    for i = 1, 7 do
        if i ~= 4 then
            self._ButtonList[i]:setTag(i)
            self._ButtonList[i]:addTouchEventListener(handler(self, self.TouchEvent))
        end
    end
    self._ButtonList[2]:setBrightStyle(1)
    self._ButtonList[3]:setBrightStyle(1)
    local canel = self:GetUIByName("Close")
    canel:setTag(-1)
    canel:addTouchEventListener(handler(self, self.TouchEvent))
   
    self._Time1 = seekNodeByName(self._ButtonList[5], "Text_1")
    self._Time2 = seekNodeByName(self._ButtonList[6], "Text_1")
    self._Time3 = seekNodeByName(self._ButtonList[7], "Text_1")
    self._Time1:setString("")
    self._Time2:setString("")
    self._Time3:setString("")
    self._Num1 = seekNodeByName(self._ButtonList[5], "Text_2")
    self._Num2 = seekNodeByName(self._ButtonList[6], "Text_2")
    self._Num3 = seekNodeByName(self._ButtonList[7], "Text_2")
    self._GaoJiPropImage = seekNodeByName(self._ButtonList[7], "Image_2")
    
    self._ShopItemList = ItemDataManager:GetStoreListByType(0)
end

function UISmelt:onTimeChange(sender)
    if (self._EquipList[sender:getTag()] - os.time()) <= 0 then
        self._EquipList[sender:getTag()] = 0
        sender:setString(ChineseConvert["UITitle_4"])
        sender._Time1:setTextColor(cc.c3b(33, 131, 22))
    end
    local timeStr =  CreateTimeString(self._EquipList[sender:getTag()]).."后免费"
    sender:setString(timeStr)
end

function UISmelt:NumberOfCellsInTableView()
    return 5
end

function UISmelt:TableCellTouched(view, cell)
    local index = cell:getIdx()
end

function UISmelt:TableCellButtonTouched(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local index = sender:getTag()
        if GetPlayer()._Silver >= self._EquipList[4 + index][4] then
            SendMsg(PacketDefine.PacketDefine_ForgeBuy_Send, {index})
        else
            local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
            UITip:SetStyle(1, string.gsub(GameGlobal:GetTipDataManager(UI_zs_04), "转生", ""))
        end
    end
end

function UISmelt:CellSizeForTable(view, idx)
    return 155, 306
end

function UISmelt:TableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
    end
    cell:removeAllChildren(true)
    local layout = cc.CSLoader:createNode("csb/ui/SmeltItem.csb")
    layout:setPositionX(5)
    cell:addChild(layout, 0, idx)
    self:InitCell(cell, idx)
    return cell
end

function UISmelt:InitCell(cell, idx)
    local layout = cell:getChildByTag(idx)
    local panel = seekNodeByName(layout, "Panel_1")
    if panel ~= nil then
        panel:setSwallowTouches(false) 
        local button = ccui.Helper:seekWidgetByName(panel, "Button_1")
        button:setSwallowTouches(false) 
        button:setVisible(false)
        button:setTag(idx)
        ccui.Helper:seekWidgetByName(panel, "Flag"):setVisible(false)
        if idx < 5 then
            local PropDataManager = GetPropDataManager()   
            if self._EquipList[4 + idx] == nil then
                return
            end
            local id = self._EquipList[4 + idx][2]
            if id == 0 then
                return
            end
            button:addTouchEventListener(handler(self, self.TableCellButtonTouched))
            ccui.Helper:seekWidgetByName(panel, "Image_1"):setSwallowTouches(false) 
            ccui.Helper:seekWidgetByName(panel, "Image_2"):setSwallowTouches(false) 
            -- 帅气背景
            if tonumber(PropDataManager[id]["quality"]) >= 4 then
                ccui.Helper:seekWidgetByName(panel, "Image_Quality"):setVisible(true)
                local imageQuality = ccui.Helper:seekWidgetByName(panel, "Image_Quality")
                local w = ccui.Helper:seekWidgetByName(panel, "Image_Quality"):getContentSize().width
                local h = ccui.Helper:seekWidgetByName(panel, "Image_Quality"):getContentSize().height
                local equipEffectIndex = 0;
                local tag = 0;
                -- 特效数量
                local effectMaxNum = 2;
                if tonumber(PropDataManager[id]["quality"]) == 4 then
                    -- 蓝
                    equipEffectIndex = 1 + idx
                elseif tonumber(PropDataManager[id]["quality"]) == 5 then
                    -- 黄
                    equipEffectIndex = 6 + idx
                    tag = 1
                end
                if self._EquipList[4 + idx][3] ~= 1 then
                    self:playAnimationObject(equipEffectIndex, 300 + tag + idx*effectMaxNum, w / 2 + 75 + idx*158, h / 2 + 250, false)
                end            
            else
                ccui.Helper:seekWidgetByName(panel, "Image_Quality"):setVisible(false)
            end
            local icon = ccui.Helper:seekWidgetByName(panel, "equip")
            icon:setSwallowTouches(false) 
            icon:loadTexture(GetPropPath(id), UI_TEX_TYPE_LOCAL)
            local text = ccui.Helper:seekWidgetByName(panel, "price")
            for i = 1, #self._ShopItemList do
                if tonumber(self._ShopItemList[i].id2) == id then
                    text:setString(self._ShopItemList[i].price4)
                    self._EquipList[4 + idx][4] = self._ShopItemList[i].price4
                end
            end
            local name = ccui.Helper:seekWidgetByName(panel, "name")
            name:setString(PropDataManager[id]["name"])
            if self._EquipList[4 + idx][3] == 1 then
                ccui.Helper:seekWidgetByName(panel, "Flag"):setVisible(true)
                button:setVisible(false)
            else
                button:setVisible(true)
                ccui.Helper:seekWidgetByName(panel, "Flag"):setVisible(false)
            end
        end
    end
end

function UISmelt:CheckEquip()
    for i = 1, 5 do
        if self._EquipList == nil or self._EquipList[3 + i] == nil then
            return false
        end
        local id = self._EquipList[3 + i][2]
        if id > 0 then
            local PropDataManager = GetPropDataManager()   
            if self._EquipList[3 + i][3] == 0 and  tonumber(PropDataManager[id]["quality"]) >= 4 then
                return true
            end
        end
    end
    return false
end

function UISmelt:Unload()
    UIBase.Unload()
    self._ResourceName = nil
    self._Type = nil
end

function UISmelt:Open()
    UIBase.Open(self)
    self:animationEffectInit()
    self._BuySuccessAni = CreateAnimationObject(480, 250, "csb/texiao/ui/T_u_ziti_goumai.csb")
    self:openUISucceed()
    self.flagTip = 0
    self:addEvent(GameEvent.GameEvent_UIEquipSmelt_Succeed, self.openUISucceed)
    self:addEvent(GameEvent.GameEvent_GameEvent_UIEquip_Buy, self.updateBuyItem)
    self:addEvent(GameEvent.GameEvent_MyselfInfoChange, self.playInfoChangeListener)
end

function UISmelt:updateBuyItem()
    if self._RootPanelNode:getChildByTag(191) == nil then
        self._RootPanelNode:addChild(self._BuySuccessAni, 1, 191)
    end
    self._BuySuccessAni._usedata:play("animation0", false)
   
    self._Num1:setString(ItemDataManager:GetItemCount(30006))
    self._Num2:setString(ItemDataManager:GetItemCount(30004))
    self._Num3:setString(ItemDataManager:GetItemCount(30005))
end

function UISmelt:Close()
    UIBase.Close(self)
    self:releaseEquipBGEffect()
end

function UISmelt:playInfoChangeListener()
    self:refreshSmeltBtnInfo()
end

function UISmelt:refreshSmeltBtnInfo()
    if GetPlayer()._VIPLevel > 1 then
        self._Time3:setString(ChineseConvert["UITitle_4"])
        self._Time3:setTextColor(cc.c3b(33, 131, 22))
        self._Time3:setPositionY(-5)
        self._GaoJiPropImage:setVisible(true)
        self._Num3:setVisible(true)
    else
        self._Time3:setString(GameGlobal:GetTipDataManager(UI_BUTTON_NAME_33))
    end
end

function UISmelt:openUISucceed()
    self._EquipList =  GetGlobalData()._SmeltTime
    self._EquipList[4] = GetGlobalData()._SmeltEquip[1]
    self._EquipList[5] = GetGlobalData()._SmeltEquip[2]
    self._EquipList[6] = GetGlobalData()._SmeltEquip[3]
    self._EquipList[7] = GetGlobalData()._SmeltEquip[4]
    self._EquipList[8] = GetGlobalData()._SmeltEquip[5]
    self._Time1:setTag(1)
    self._Time2:setTag(2)
    self._Time3:setTag(3)
    if tonumber(self._EquipList[1] - os.time()) > 0 then
        self._EquipList[1] = self._EquipList[1]
        local timeStr =  CreateTimeString(self._EquipList[1]).."后免费"
        self._Time1:setString(timeStr)
        self._Time1:setTextColor(cc.c3b(202, 49, 52))
        schedule(self._Time1, handler(self, self.onTimeChange), 1)
    else
        self._Time1:setString(ChineseConvert["UITitle_4"])
        self._Time1:setTextColor(cc.c3b(33, 131, 22))
    end
    if tonumber(self._EquipList[2] - os.time()) > 0 then
        self._EquipList[2] = self._EquipList[2]
        local timeStr =  CreateTimeString(self._EquipList[2]).."后免费"
        self._Time2:setString(timeStr)
        self._Time2:setTextColor(cc.c3b(202, 49, 52))
        schedule(self._Time2, handler(self, self.onTimeChange), 1)
    else
        self._Time2:setString(ChineseConvert["UITitle_4"])
        self._Time2:setTextColor(cc.c3b(33, 131, 22))
    end
    if tonumber(self._EquipList[3]- os.time()) > 0 then
        self._EquipList[3] = self._EquipList[3]
        local timeStr =  CreateTimeString(self._EquipList[3]).."后免费"
        self._Time3:setString(timeStr)
        self._Time3:setTextColor(cc.c3b(202, 49, 52))
        schedule(self._Time3, handler(self, self.onTimeChange), 1)
        self._Time3:setPositionY(-5)
        self._GaoJiPropImage:setVisible(true)
        self._Num3:setVisible(true)
    else
        self:refreshSmeltBtnInfo()
    end
    
    self._GridView:reloadData() 
    self._Num1:setString(ItemDataManager:GetItemCount(30006))
    self._Num2:setString(ItemDataManager:GetItemCount(30004))
    self._Num3:setString(ItemDataManager:GetItemCount(30005))

end

function UISmelt:TouchEvent(sender, eventType, x, y)
    print(eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
        if tag == -2  then
        elseif tag == -1  then
            UISystem:CloseUI(UIType.UIType_EquipUI)
            UISystem:CloseUI(UIType.UIType_UISmelt) 
        elseif tag == 2  then
            UISystem:CloseUI(UIType.UIType_UISmelt) 
            UISystem:OpenUI(UIType.UIType_EquipUI)
            local equip = UISystem:GetUIInstance(UIType.UIType_EquipUI)
            equip:ChangeTag(1)
        elseif tag == 3  then
            UISystem:CloseUI(UIType.UIType_UISmelt) 
            UISystem:OpenUI(UIType.UIType_EquipUI)
            local equip = UISystem:GetUIInstance(UIType.UIType_EquipUI)
            equip:ChangeTag(2)
        elseif tag == 5  then   
            PlaySound(Sound_23)
            if self:CheckEquip() then
                return
            end
            if ItemDataManager:GetItemCount(30006) > 0 or tonumber(self._EquipList[1] - os.time()) <= 0 then
                SendMsg(PacketDefine.PacketDefine_ForgeRefresh_Send, {1})
            else
                local uiInstance = UISystem:OpenUI(UIType.UIType_BuyItem)
                uiInstance:OpenItemInfoNotifiaction(30006)
            end
        elseif tag == 6  then   
            PlaySound(Sound_24)
            if self:CheckEquip() then
                return
            end
            if ItemDataManager:GetItemCount(30004) > 0 or tonumber(self._EquipList[2] - os.time()) <= 0 then
                SendMsg(PacketDefine.PacketDefine_ForgeRefresh_Send, {2})
            else
--                local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
--                UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_yl_02))
                local uiInstance = UISystem:OpenUI(UIType.UIType_BuyItem)
                uiInstance:OpenItemInfoNotifiaction(30004)
            end
        elseif tag == 7  then 
            if GetPlayer()._VIPLevel < 2 then
                OpenRechargeTip("vip2可开启高级冶炼功能，是否充值？")
                return
            end
            PlaySound(Sound_25)   
            if self:CheckEquip() then
                return
            end
            if ItemDataManager:GetItemCount(30005) > 0 or tonumber(self._EquipList[3]- os.time()) <= 0 then
                SendMsg(PacketDefine.PacketDefine_ForgeRefresh_Send, {3})
            else
--                local UITip =  UISystem:OpenUI(UIType.UIType_TipUI)
--                UITip:SetStyle(1, GameGlobal:GetTipDataManager(UI_yl_03))
                local uiInstance = UISystem:OpenUI(UIType.UIType_BuyItem)
                uiInstance:OpenItemInfoNotifiaction(30005)
            end
        end
    end
end

function UISmelt:animationEffectInit()  
    self._EquipEffect = {}
    for i = 1, 10 do
        if i >= 5 then
            self._EquipEffect[i] = CreateAnimationObject(0, 0, UI_EQUIP_BG_BLUE_EFFECT)
        else
            self._EquipEffect[i] = CreateAnimationObject(0, 0, UI_EQUIP_BG_YELLOW_EFFECT)
        end
    end
end

function UISmelt:releaseEquipBGEffect()
    if self._EquipEffect ~= nil then
        for i = 1, #self._EquipEffect do
            removeNodeAndRelease(self._EquipEffect[i])
        end
        self._EquipEffect = nil
    end
end

function UISmelt:playAnimationObject(index,tag, x, y, loop)
    if self._EquipEffect[index] == nil then
        if index < 6 then
            self._EquipEffect[index] = CreateAnimationObject(0, 0, UI_EQUIP_BG_BLUE_EFFECT)
        else
            self._EquipEffect[index] = CreateAnimationObject(0, 0, UI_EQUIP_BG_YELLOW_EFFECT)
        end
    end
    if self._RootPanelNode:getChildByTag(tag) == nil then
        self._EquipEffect[index]:setPosition(cc.p(x, y))
        self._RootPanelNode:addChild(self._EquipEffect[index], 1,tag)
    end
    self._EquipEffect[index]._usedata:resume()
    self._EquipEffect[index]._usedata:setCurrentFrame(self._EquipEffect[index]._usedata:getStartFrame())
    if loop then
        self._EquipEffect[index]._usedata:play("animation0", true)
    else
        self._EquipEffect[index]._usedata:play("animation0", false)
    end
end

return UISmelt