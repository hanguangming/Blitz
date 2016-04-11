----
-- 文件名称：UIlogin.lua
-- 功能描述：背包
-- 文件说明：背包
-- 作    者：王峰
-- 创建时间：2015-6-6
--  修改
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
require("src.cocos.ui.GuiConstants")

local UISystem = require("main.UI.UISystem")
local UIPackage = class("UIPackage", UIBase)
function UIPackage:ctor()
    UIBase:ctor(self)
    self._ResourceName = "UIPackage.csb"  
end
--//获得物品Item并拷贝
function UIPackage:GetItem()
    local item = self:GetUIByName("Panel_SpriteItem")
    local item_copy = item:clone()
    return item_copy
end
--//获得pageItem并拷贝
function UIPackage:GetPageItem()
    local layout_temp = self:GetUIByName("PanelItem")
    local layout = layout_temp:clone() 
    layout.text = layout:getChildByName("pageText")
    return layout   
    
end
--//更新背包物品
function UIPackage:UpdatePackage(root,page,table)
    local function ItemCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            print("************物品",sender:getTag())
        end
    end
    
    for i = 1,5 do
        for j =1, 7 do
            local imageView = ccui.ImageView:create("demoArt/head/31001.png")
            imageView:setPosition(j*70,325-i*65)
            root:addChild(imageView)
            if (i - 1)*5 + j+ (page - 1) *35 <=#table then
                local imageItem = self:GetItem()
                imageItem:setPosition(j*70,325-i*65)
                root:addChild(imageItem,5)
                imageItem:setTag((i - 1)*5 + j)
                imageItem:addTouchEventListener(ItemCallBack)
            end
        end
    end
end

function UIPackage:Load()
    UIBase.Load(self)
    local testTable = {
        1,
        1,
        1,
        1,
    }
    --//创建PageView
    local pageView = self:GetUIByName("PageView_Package")
    pageView:setContentSize(cc.size(600,400))
    for i = 1,math.ceil(#testTable/35)  do
        local pageViewItem = self:GetPageItem()
        pageViewItem.text:setString(string.format("page %d",i))
        self:UpdatePackage(pageViewItem,i,testTable)
        pageView:insertPage(pageViewItem,i)
    end
 
end
function UIPackage:Unload() 
    UIBase.Unload(self)
end
function UIPackage:Open()
    UIBase.Open(self)
end
function UIPackage:Close()
    UIBase.Close(self)
end
return UIPackage