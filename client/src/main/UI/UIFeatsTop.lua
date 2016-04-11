----
-- 文件名称：UIFeatsTop.lua
-- 功能描述：UIFeatsTop
-- 文件说明：
-- 作    者：
-- 创建时间：2015-8-5
-- 修改 ：
-- 
--
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
local UISystem = require("main.UI.UISystem")

local UIFeatsTop = class("UIFeatsTop", UIBase)
local _Instance = nil
--构造函数
function UIFeatsTop:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_FeatsTop
    self._ResourceName = "UIFeats1.csb" 
end

--Load
function UIFeatsTop:Load()
    UIBase.Load(self)
    _Instance = self
    self._FeatsLabelData = {}
    for i = 1, 4 do
        self._FeatsLabelData[i] = seekNodeByName(self:GetUIByName("feats"..i), "Text_1")
    end
    self._FeatsLabelData[5] = self:GetUIByName("Label_8")
    self._FeatsLabelData[6] = self:GetUIByName("Label_7")
    self:GetUIByName("Text_2"):enableOutline(cc.c4b(0, 0, 0, 250), 2)
    --self:GetUIByName("Text_3"):enableOutline(cc.c4b(0, 0, 0, 250), 2)
    self:GetUIByName("Label_4"):enableOutline(cc.c4b(0, 0, 0, 250), 2)
    self:GetUIByName("Label_5"):enableOutline(cc.c4b(0, 0, 0, 250), 2)
    local center = seekNodeByName(self._RootPanelNode, "Panel_Center")
    self._GridView = CreateTableView(-300, -190, 700, 250, 1, self)
    center:addChild(self._GridView)
    self:UpdateFeatData()
    for i = 4, 3 do
        local btn = self:GetUIByName("Button_"..i)
        btn:setTag(i)
        btn:addTouchEventListener(self.TouchEvent)
        btn:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 250), 2)
        btn:getTitleRenderer():setPositionY(33)
    end
    local cancel = self:GetUIByName("Close")
    cancel:setTag(-1)
    cancel:addTouchEventListener(self.TouchEvent)
end

--Unload
function UIFeatsTop:Unload()
    UIBase.Unload(self)
end

--打开
function UIFeatsTop:Open()
    UIBase.Open(self)

    local roleInfo = GetPlayer()
     for i = 1, 5 do
        self._FeatsLabelData[i]:setString(GetPlayer()._GongXun[i])
    end
    
end

--关闭
function UIFeatsTop:Close()
    UIBase.Close(self)
end

function UIFeatsTop:UpdateFeatData()
    _Instance._TopDataList = GetPlayer()._GongXunTop
    _Instance._GridView:reloadData()
    if GetPlayer()._GongXunTop[0] == 0 then
        _Instance._FeatsLabelData[6]:setString(ChineseConvert["UITitle_7"])
    else
        _Instance._FeatsLabelData[6]:setString(GetPlayer()._GongXunTop[0])
    end
end

function UIFeatsTop.ScrollViewDidScroll()

end

function UIFeatsTop.NumberOfCellsInTableView()
    return math.floor(#_Instance._TopDataList % 2) ==0 and math.floor(#_Instance._TopDataList / 2) or math.floor(#_Instance._TopDataList / 2) + 1
end

function UIFeatsTop.TableCellTouched(view, cell)
    local index = cell:getIdx()
end

function UIFeatsTop.CellSizeForTable(view, idx)
    return 100, 100
end

function UIFeatsTop.TableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
        cell:retain()
    end
    cell:removeAllChildren(true)
    local layout = cc.CSLoader:createNode("csb/ui/FeatsItem.csb")
    seekNodeByName(layout,"Panel_1"):setSwallowTouches(false)
    cell:addChild(layout, 0, idx)
    _Instance:InitCell(cell, idx)
    return cell
end

function UIFeatsTop:InitCell(cell, idx)
    local layout = cell:getChildByTag(idx)
    local layer1 = seekNodeByName(layout, "Image_1")
    if _Instance._TopDataList[idx * 2 + 1][1] == 1 then
        seekNodeByName(layer1, "s1"):setVisible(true)
        seekNodeByName(layer1, "s3"):setVisible(false)
    elseif _Instance._TopDataList[idx * 2 + 1][1] == 3 then
        seekNodeByName(layer1, "s1"):setVisible(false)
        seekNodeByName(layer1, "s3"):setVisible(true)
    else
        seekNodeByName(layer1, "s1"):setVisible(false)
        seekNodeByName(layer1, "s3"):setVisible(false)
        seekNodeByName(layer1, "Text_3"):setString(_Instance._TopDataList[idx * 2 + 1][1])
    end
    seekNodeByName(layer1, "Text_4"):setString(_Instance._TopDataList[idx * 2 + 1][3])
    seekNodeByName(layer1, "Text_2"):setString("Lv".._Instance._TopDataList[idx * 2 + 1][2])
    seekNodeByName(layer1, "Text_1"):setString(_Instance._TopDataList[idx * 2 + 1][4])
    local layer2 = seekNodeByName(layout, "Image_2")
    layer2:setVisible(false)
    if idx * 2 + 2 <= #_Instance._TopDataList then
        layer2:setVisible(true)
        if _Instance._TopDataList[idx * 2 + 2][1] == 2 then
            seekNodeByName(layer2, "s1"):setVisible(true)
        else
            seekNodeByName(layer2, "s1"):setVisible(false)
            seekNodeByName(layer2, "Text_3"):setString(_Instance._TopDataList[idx * 2 + 2][1])
        end
        seekNodeByName(layer2, "Text_2"):setString("Lv".._Instance._TopDataList[idx * 2 + 2][2])
        seekNodeByName(layer2, "Text_1"):setString(_Instance._TopDataList[idx * 2 + 2][4])
        seekNodeByName(layer2, "Text_4"):setString(_Instance._TopDataList[idx * 2 + 2][3])
    end
end

function UIFeatsTop:TouchEvent(eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = self:getTag()
        if tag == -1 then
            UISystem:CloseUI(UIType.UIType_FeatsTop) 
        elseif tag == 0 then

        end
    end
end

return UIFeatsTop
