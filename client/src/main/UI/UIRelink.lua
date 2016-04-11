----
-- 文件名称：UIRelink.lua
-- 功能描述：测试UI
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-6-16
-- 修改 ：
--  测试UI动画的支持情况
--
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
local UISystem = require("main.UI.UISystem")

local UIRelink = class("UIRelink", UIBase)

--构造函数
function UIRelink:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_ReLinkUI
    self._ResourceName =  "Scene.csb"
end

--Load
function UIRelink:Load()
    UIBase.Load(self)
    CreateAnimation(self._RootPanelNode, 480, 270, "csb/texiao/ui/T_u_chongxinlianjie_new.csb", "Walk", true, 0, 1) 
end

--Unload
function UIRelink:Unload()
    UIBase.Unload(self)

end

--打开
function UIRelink:Open()
    UIBase.Open(self)
    --performWithDelay(GameGlobal:GetUISystem():GetUIRootNode(), self.EnterGame, 1)
end

function UIRelink:EnterGame()
    local playerUserName = GetDate("username", 4)
    local playerCode = GetDate("password", 4)
    local data = {playerUserName, playerCode, "qzone", "pf3366", 4}
    SendLoginMsg(PacketDefine.PacketDefine_Login_Send, data)
end

--关闭
function UIRelink:Close()
    UIBase.Close(self)
end

return UIRelink
