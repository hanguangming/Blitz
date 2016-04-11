----
-- 文件名称：UICustomEnmeyBossInfo.lua
-- 功能描述：查看敌方boss关信息
-- 文件说明：查看敌方boss关信息
-- 作    者：刘胜勇
-- 创建时间：2015-7-28
--  修改

require("main.UI.UIBase")
require("main.UI.UITypeDefine") 
require("src.cocos.ui.GuiConstants")

local UISystem = GameGlobal:GetUISystem() 
local UICustomEnmeyBossInfo = class("UICustomEnmeyBossInfo", UIBase)

-- 获取玩家信息数据
local GamePlayerDataManager = GameGlobal:GetGamePlayerDataManager()
-- 获取物品信息数据
local ItemDataManager = GameGlobal:GetItemDataManager()
-- 获取关卡表数据
local CustomDataManager = GameGlobal:GetCustomDataManager()
-- 获取boss(关卡pvp)表数据
local BossDataManager = GameGlobal:GetCustomPVPDataManager()
-- 获取角色信息表数据
local CharacterDataManager = GameGlobal:GetCharacterDataManager()
local CharacterServerDataManager = GameGlobal:GetCharacterServerDataManager()
-- 虎符id
local ITEM_HUFU_ID = 30019

function UICustomEnmeyBossInfo:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_CustomEnmeyBossInfo
    self._ResourceName = "UICustomEnmeyInfoBoss.csb"  
end

-- UI加载
function UICustomEnmeyBossInfo:Load()
    UIBase.Load(self)

    -- 阵形1按钮
    local zhenXingBtn1 = self:GetUIByName("BtnZhen1")
    zhenXingBtn1:setTag(1)
 
    -- 阵形2按钮
    local zhenXingBtn2 = self:GetUIByName("BtnZhen2")
    zhenXingBtn2:setTag(2)

    -- 阵形3按钮
    local zhenXingBtn3 = self:GetUIByName("BtnZhen3")
    zhenXingBtn3:setTag(3)

    -- 关闭按钮
    local closeBtn = self:GetUIByName("Close")
    closeBtn:setTag(-1)

    -- 添加BossTableView
    local center = seekNodeByName(self._RootPanelNode, "Panel_Center")
    self._gridView = CreateTableView_(-275, -35, 760, 330, 0, self)
    center:addChild(self._gridView)
        
    -- 注册按钮监听事件
    zhenXingBtn1:addTouchEventListener(handler(self, self.touchEvent))
    zhenXingBtn2:addTouchEventListener(handler(self, self.touchEvent))
    zhenXingBtn3:addTouchEventListener(handler(self, self.touchEvent))
    closeBtn:addTouchEventListener(handler(self,self.touchEvent))
   
end

-- UI卸载
function UICustomEnmeyBossInfo:Unload()
    UIBase.Unload() 
end

-- UI打开
function UICustomEnmeyBossInfo:Open()
    UIBase.Open(self)
    
    -- 选中的小boss关卡
    self._bossLevelId = nil
    
    -- 当前选中的阵型
    self._curZhenXing = nil
    
    -- 初始化Boss表数据
    self._bossData = {}
    
    -- 注册打开boss关卡监听事件
    self:addEvent(GameEvent.GameEvent_UICustomEnmeyBossInfo_Succeed, self.selectSuccessListener)
end

-- UI关闭
function UICustomEnmeyBossInfo:Close()
    UIBase.Close(self)
    -- Boss表数据清空
    self._bossData = nil 
end

-- 监听事件回调
function UICustomEnmeyBossInfo:selectSuccessListener(event)
    self._bossLevelId = event._usedata
    --    local levelTableData = CustomDataManager[self._bossLevelId]
    local bossTabelData = BossDataManager[self._bossLevelId] --Boss表数据
    if not bossTabelData then
        print("bossTabelData is nil")
        return
    end
    local data = {}
    data= SplitSet(BossDataManager[self._bossLevelId]["pvplist"])

    -- Boss的数据
    local bossData = {}
    for i = 1, #data do
        local tableID = tonumber(data[i][1])
        local tableData = CharacterDataManager[tableID]
        if tableData["type"] == 2 then --武将
            if bossData[tableID] == nil then
                bossData[tableID] = data[i]
             end
        end
    end
  
    for i, v in pairs(bossData) do
        -- pvp时数据格式同PVE时数据不一致(只有两个数据ID Level)程序校正
        if bossTabelData.pvp ~= 0 then
            v[3] = v[2]
        end
        table.insert(self._bossData, v)
    end
    
    -- 刷新数据
    self._gridView:reloadData() 

end

function UICustomEnmeyBossInfo:NumberOfCellsInTableView()
    return #self._bossData
end

function UICustomEnmeyBossInfo:TableCellTouched(view, cell)
    local index = cell:getIdx()
end

function UICustomEnmeyBossInfo:CellSizeForTable(view, idx)
    return 170, 320
end
function UICustomEnmeyBossInfo:TableCellAtIndex(view, idx)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
    end
    cell:removeAllChildren(true)
    local layout = cc.CSLoader:createNode("csb/ui/CustomBosssHeroItem.csb")
    local panel = seekNodeByName(layout, "Panel_1")
    panel:setSwallowTouches(false)
    seekNodeByName(panel, "Icon"):setSwallowTouches(false)
    cell:addChild(layout, 0, idx)  
    
    self:InitCell(cell, idx)
    return cell
end

function UICustomEnmeyBossInfo:InitCell(cell, idx) 
    local CELL_COL_ROW = #self._bossData
    local layout = cell:getChildByTag(tonumber(idx))
    local panel = seekNodeByName(layout, "Panel_1")
    if idx + 1  <= CELL_COL_ROW then
        panel:setVisible(true)
        local soldier =  CharacterDataManager[tonumber(self._bossData[idx + 1][1])]
        local head = seekNodeByName(panel, "Icon")   
        -- 武将后的背景框,不同属性，背景不同
        local background = seekNodeByName(panel, "bg");
        local qualityImage = seekNodeByName(panel, "Image_quality")
        if soldier ~= nil then 
            head:loadTexture(GetWarriorBodyPath(soldier["bodyImage"])) 
            head:setScale(0.7)
            -- 武将属性背景
            background:loadTexture(GetEnmeyBossInfoProperty(soldier["soldierType"])) 
            -- 武将品质
            qualityImage:loadTexture(GetWarriorStarImage(soldier["quality"])) 
            local name = seekNodeByName(panel, "Name")
            name:setString("lv."..self._bossData[idx + 1][3].."  "..soldier["name"])
            name:setColor(cc.c3b(115, 74, 18))
            --name:enableOutline(cc.c4b(0, 0, 0, 250), 1) --描边
        end
    end
   
end

-- 触摸监听事件处理
function UICustomEnmeyBossInfo:touchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
        if tag == -1 then
            UISystem:CloseUI(UIType.UIType_CustomEnmeyBossInfo)
        -- 进入战斗
        elseif tag == 1 or tag == 2 or tag == 3 then
            self._curZhenXing = tag
            local currentZhenXingData = CharacterServerDataManager:GetZhenXingData(self._curZhenXing)
            if #currentZhenXingData ~= 0 then
                return
            end
            -- 判断军令数量
            if GetPlayer()._Energy > 0 then  
                local BattleServerDataManager = GameGlobal:GetBattleServerDataManager()
                BattleServerDataManager._CurrentPVEPVPZhenXing = self._curZhenXing
                self:enterBattle()
            else
                if GameGlobal:GetItemDataManager():GetItemCount(ITEM_HUFU_ID) >= math.floor(GetPlayer()._NeedHuFuTimes / GameGlobal:GetParameterDataManager()["tiger_times"].value) + 1 then
                    UISystem:OpenUI(UIType.UIType_UseHuFu)
                    UISystem:GetUIInstance(UIType.UIType_UseHuFu):SetBattleType(false, self._bossLevelId)
                else
                    UISystem:OpenUI(UIType.UIType_BuyItem)
                    local uiInstance = UISystem:GetUIInstance(UIType.UIType_BuyItem)
                    local num = math.floor(GetPlayer()._NeedHuFuTimes / GameGlobal:GetParameterDataManager()["tiger_times"].value) + 1 - GameGlobal:GetItemDataManager():GetItemCount(ITEM_HUFU_ID)
                    uiInstance:OpenItemInfoNotifiaction(ITEM_HUFU_ID, num)
                end       
            end
        end
    end
end

-- 选择阵型后进入战斗场景
function UICustomEnmeyBossInfo:enterBattle()
    if self._bossLevelId ~= nil then
        UISystem:CloseUI(UIType.UIType_CustomEnmeyBossInfo)
        UISystem:CloseAllUI()
        SendMsg(PacketDefine.PacketDefine_Stage_Send, {CustomDataManager[self._bossLevelId]["id"]})
        GameGlobal:GetUISystem():OpenUI(UIType.UIType_BattleUI, self._bossLevelId)
    end
end

return UICustomEnmeyBossInfo