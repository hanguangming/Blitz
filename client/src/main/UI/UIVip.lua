----
-- 文件名称：UISignIn.lua
-- 功能描述：UISignIn
-- 文件说明：
-- 作    者：
-- 创建时间：2015-8-5
-- 修改 ：
-- 
--
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
local UISystem = require("main.UI.UISystem")

local UIVip = class("UIVip", UIBase)

--构造函数
function UIVip:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_VipUI
    self._ResourceName = "UIVip.csb" 
end

--Load
function UIVip:Load()
    UIBase.Load(self)
    _Instance = self
    local cancel = self:GetUIByName("Close")
    cancel:setTag(-1)
    cancel:addTouchEventListener(self.TouchEvent)
    
    self._RootPanelNode:setSwallowTouches(true) 
    local center = seekNodeByName(self._RootPanelNode, "Panel_Center")
    self._GoldText = seekNodeByName(self:GetUIByName("UI_Gold"), "Text_1")
    self._MoneyText = seekNodeByName(self:GetUIByName("UI_Money"), "Text_1")
    self._VipText1 = self:GetUIByName("bfvip1")
    self._VipText2 = self:GetUIByName("bfvip2")
    self._VipLevel = self:GetUIByName("VIPLevelText")
    self._VipInfo = self:GetUIByName("vip_info")
--    for i = 3, 3 do
--        local btn = self:GetUIByName("Button_"..i)
--        btn:setTag(i)
--        btn:addTouchEventListener(self.TouchEvent)
--        btn:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 250), 2)
--        btn:getTitleRenderer():setPositionY(33)
--    end

    local roleInfo = GetPlayer()
    self._PageView = self:GetUIByName("PageView")
    self._PageView:setCustomScrollThreshold(200)
    self._PageView:addPage(_Instance:InitCell(nil, roleInfo._VIPLevel - 1))
    self._PageView:addEventListener(self.pageViewEvent)
end

function UIVip:pageViewEvent()
    --_Instance._VipLevel:setString(tostring(_Instance._PageView:getCurPageIndex() + 1))
end

--Unload
function UIVip:Unload()
    UIBase.Unload(self)
end

--打开
function UIVip:Open()
    UIBase.Open(self)
    self.OpenCallBack = AddEvent(GameEvent.GameEvent_UIVIP_Succeed, self.OpenUISuccess)
    performWithDelay(self._RootPanelNode, self.RequestInfo, 0)
    local roleInfo = GetPlayer()
    self._VipLevel:setString(roleInfo._VIPLevel)
    local str = string.gsub(tostring(self._VipInfo:getString()), "@num", "2000".."", 1)
    str = string.gsub(str, "@nnn", roleInfo._VIPLevel, 1)
    str = string.gsub(str, "@nnn", (roleInfo._VIPLevel + 1), 1)
    self._VipInfo:setString(str)
end

--关闭
function UIVip:Close()
    UIBase.Close(self)
    RemoveEvent(self.OpenCallBack)
    self.OpenCallBack = nil
end

function UIVip:OpenUISuccess()
    local tag = 0
    if self._usedata[1] == 0 then
        --_Instance._ButtonList[tag]:getTitleRenderer():setString("购买")
    elseif self._usedata[1] == 1 then
       -- _Instance._ButtonList[tag]:getTitleRenderer():setString("领取")
    elseif self._usedata[1] == 2 then
       -- _Instance._ButtonList[tag]:getTitleRenderer():setString("已领取")
       -- _Instance._ButtonList[tag]:setBright(false)
       -- _Instance._ButtonList[tag]:setTouchEnabled(false)
    end
end

function UIVip:RequestInfo()
    local roleInfo = GetPlayer()
    for i = 0, 10 do
        if (roleInfo._VIPLevel - 1) ~= i then
            _Instance._PageView:insertPage(_Instance:InitCell(nil, i), i)
        end
    end
    --SendMsg(PacketDefine.PacketDefine_GetRewardInfo_Send, {0, 1})
    local roleInfo = GetPlayer()
    local vipLevel = nil
    --没有V12数据， 暂时这么处理
    if roleInfo._VIPLevel == 12 then
        vipLevel = 11
    else
        vipLevel = roleInfo._VIPLevel
    end
    _Instance._PageView:scrollToPage(vipLevel - 1)
end

function UIVip.ScrollViewDidScroll()

end

function UIVip.NumberOfCellsInTableView()
    return 11
end  

function UIVip.TableCellTouched(view, cell)
    local index = cell:getIdx()
end

function UIVip.CellSizeForTable(view, idx)
    return 350, 720
end

function UIVip.TableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
        cell:retain()
    end
    cell:removeAllChildren(true)
    local layout = cc.CSLoader:createNode("csb/ui/VipItem.csb")
    for i = 1, 2 do
        local btn = seekNodeByName(layout,"Button_"..i)
        btn:setTag(idx * 2 + i)
        btn:addTouchEventListener(_Instance.TouchEvent)
    end
    cell:addChild(layout, 0, idx)
   
    _Instance:InitCell(cell, idx)
    return cell
end

local VIPData = GameGlobal:GetVipDataManager()

function UIVip:InitCell(cell, idx)
    local layout = cc.CSLoader:createNode("csb/ui/VipItem.csb")
    layout:retain()
    for i = 1, 2 do
        local btn = seekNodeByName(layout,"Button_"..i)
        btn:setTag(idx * 2 + i)
        btn:addTouchEventListener(_Instance.TouchEvent)
    end
    
    --local layout = cell:getChildByTag(idx)
    local panel = seekNodeByName(layout, "Panel_2")
    local descs = {"desc2", "desc3", "desc5", "desc6", "desc7", "desc9", "desc8", "desc10"}
    local index = 1
--    local rid = {3136, 3123, 3123, 3124, 3125, 3126, 3127, 3128, 3129, 3130, 3131, 3132}
--    local CustomRewardDataManager = GameGlobal:GetCustomRewardDataManager()
--
--    local str = CustomRewardDataManager[rid[idx + 1]].prop
--    local data = {}
--    data= SplitSet(str)
--    for i = 1, 5 do
--        local icon = seekNodeByName(layout, "icon_"..i)
--        if i <= #data then
--            icon:loadTextures("meishu/ui/gg/"..GetPropDataManager()[tonumber(data[i][1])]["quality"]..".png", "meishu/ui/gg/"..GetPropDataManager()[tonumber(data[i][1])]["quality"]..".png")
--            seekNodeByName(icon, "Image_1"):loadTexture(GetPropDataManager()[tonumber(data[i][1])]["icon"])
--            seekNodeByName(icon, "Text_1"):setString(tonumber(data[i][3]))
--        else
--            seekNodeByName(icon, "Text_1"):setString("")
--        end
--    end
--    
--    local str = CustomRewardDataManager[rid[idx + 1]]["prop"]
--    local data = {}
--    data= SplitSet(str)
--    for i = 6, 10 do
--        local icon = seekNodeByName(layout, "icon_"..i)
--        if i <= 5 + #data then
--            icon:loadTextures("meishu/ui/gg/"..GetPropDataManager()[tonumber(data[i - 5][1])]["quality"]..".png", "meishu/ui/gg/"..GetPropDataManager()[tonumber(data[i - 5][1])]["quality"]..".png")
--            seekNodeByName(icon, "Image_1"):loadTexture(GetPropDataManager()[tonumber(data[i - 5][1])]["icon"])
--            seekNodeByName(icon, "Text_1"):setString(tonumber(data[i - 5][3]))
--        else
--            seekNodeByName(icon, "Text_1"):setString("")
--        end
--    end
    local text = {}
    for i = 1, 9 do
        text[i] = seekNodeByName(panel, "Text_"..i)
        text[i]:setString("")
    end
    
    for i = 1, 9 do
        if (idx + 1) > 3 and (i > 4 and i < 9) then
        elseif (idx + 1) > 1 and (i == 5 or i == 6) then
        elseif i == 9 and (idx + 1) > 1 then 
            text[index]:setString(string.format(ChineseConvert["UIVipText"], ((idx + 1) - 1)))
            index = index + 1
        elseif (idx + 1) < 3 and i > 6 then
        elseif i < 9 then  
            text[index]:setString(VIPData[idx + 1][descs[i]])
            index = index + 1
        end
    end
    
    for i = index, 9 do
        seekNodeByName(layout, "star_"..(i - 1)):setVisible(false)
    end
    return tolua.cast(layout, "ccui.Layout")
end

function UIVip:TouchEvent(eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = self:getTag()
        if tag == -1 then
            UISystem:CloseUI(UIType.UIType_VipUI) 
        elseif tag == 1 then
            SendMsg(PacketDefine.PacketDefine_GetRewardInfo_Send, {1, 1})
        elseif tag == 2 then
            SendMsg(PacketDefine.PacketDefine_GetRewardInfo_Send, {1, 1})
        end
    end
end

return UIVip
