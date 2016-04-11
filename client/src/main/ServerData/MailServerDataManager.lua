----
-- 文件名称：MailServerDataManager.lua
-- 功能描述：邮件数据管理(包括沙场战报)
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-7-27
--  修改：

local MailServerDataManager = class("MailServerDataManager")

local MailInfo = class("MailInfo")
local ItemInfo = class("ItemInfo")

--类型         --0：邮件  1：战报 
MailType = 
{
    MailType_Mail = 0,
    MailType_ZhanBao = 1
}


--物品信息
function ItemInfo:ctor()
    --ID
    self._ItemID = 0
    --Count
    self._ItemCount = 0
end
--邮件信息
function MailInfo:ctor()
   --位置
   self._MailPos = 0
   --时间
   self._MailTime = 0
   --内容
   self._Content = 0
   --类型
   self._Type = 0
   --ItemList
   self._ItemList = {}
   --显示用    内容Size
   self._ContentSize = cc.size(0, 0)
end

-- 管理器
function MailServerDataManager:ctor()
    -- 当前拥有的士兵
    self._MailList = {}

end

-- 创建士兵数据  tableID:表格ID
function MailServerDataManager:CreateMail(pos)
    local newMail = MailInfo.new()
    return newMail
end
--创建item
function MailServerDataManager:CreateItem()
    local newItem = ItemInfo.new()
    return newItem
end

local newMailServerDataManager = MailServerDataManager:new()
return newMailServerDataManager

