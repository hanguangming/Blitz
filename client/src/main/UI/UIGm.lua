----
-- 文件名称：UIGm.lua
-- 功能描述：gm命令界面
-- 实现道具的添加（道具、经验、金钱等都对应有相应的id）
-- 文件说明：gm命令界面方便内部测试
-- 作    者：刘胜勇
-- 创建时间：2015-7-11
--  修改

require("main.UI.UIBase")
require("main.UI.UITypeDefine") 
--ui基类
local UISystem = GameGlobal:GetUISystem() 
local UIGm = class("UIGm", UIBase)
local _Instance = nil 

function UIGm:ctor()
    UIBase.ctor(self)
    self.Type = UIType.UIType_GMUI
    self._ResourceName = "UIGM.csb"  
end
--加载UI 类似UI初始化
function UIGm:Load()
    UIBase.Load(self)
    --玩家名称
    self. _NameText = self:GetUIByName("TextField_4")
    --使用类型
    self._TypeText = self:GetUIByName("TextField_3")
    self._TypeText:setString("1")
    --道具id
    self._PropIdText = self:GetUIByName("TextField_1")
    --道具数量
    self._PropNumText = self:GetUIByName("TextField_2")
    self._PropNumText:setString("1")
    --道具确定按钮
    self._PropBtn = self:GetUIByName("Button_1")
    self._PropBtn:setTag(1)
    self._PropBtn:addTouchEventListener(self.TouchEvent)
    
    --关闭按钮
    local _CLoseBtn = self:GetUIByName("Close")
    _CLoseBtn:setTag(-1)
    _CLoseBtn:addTouchEventListener(self.TouchEvent)

    _Instance = self
end
--UI卸载
function UIGm:Unload()
    UIBase:Unload()
    self._ResourceName = nil
    self.Type = nil
end
--UI打开
function UIGm:Open()
    UIBase.Open(self)
end
--UI关闭
function UIGm:Close()
    UIBase.Close(self)
end
--事件处理
function UIGm:TouchEvent(eventType)
    local gmUI = UISystem:GetUIInstance(UIType.UIType_GMUI)
    if eventType == ccui.TouchEventType.ended then
        local tag = self:getTag()
        if tag == -1 then
            UISystem:CloseUI(UIType.UIType_GMUI)
        elseif tag ==1 then
            local name = gmUI:GetUIByName("TextField_4")
            if name:getString() ~= nil then
                local gNetSystem = GetNetSystem()
                local newTestPacket = gNetSystem:CreateToSendPacket(PacketDefine.PacketDefine_addItemTest_Send)
                newTestPacket.szName = name:getString()
                newTestPacket.vtype = tonumber(gmUI:GetUIByName("TextField_3"):getString())
                newTestPacket.vid = tonumber(gmUI:GetUIByName("TextField_1"):getString())
                newTestPacket.vnum = tonumber(gmUI:GetUIByName("TextField_2"):getString())
                gNetSystem:SendPacket(newTestPacket)
            end
        end
    end
end
return UIGm