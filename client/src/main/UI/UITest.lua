----
-- 文件名称：UITest.lua
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

local UITest = class("UITest", UIBase)

--构造函数
function UITest:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_TestUI
    self._ResourceName =  "UIAllTest.csb"
end

--Load
function UITest:Load()
    UIBase.Load(self)
end

--Unload
function UITest:Unload()
    UIBase.Unload(self)

end

--打开
function UITest:Open()
    UIBase.Open(self)
end

--关闭
function UITest:Close()
    UIBase.Close(self)
end

return UITest
