----
-- 文件名称：TalkDataManager
-- 功能描述：聊天数据
-- 文件说明：
-- 作    者：秦宝
-- 创建时间：2015-8-31
--  修改：

local CharacterDataManager =  GetCharacterDataManager()
local TalkDataManager = class("TalkDataManager")
-- 聊天数据
local TalkData = class("TalkData")

function TalkData:ctor(tableID)
    -- 表格ID
    self._TableID = tableID

    -- 类型
    self.type = 0

    -- 玩家ID
    self.id = 0

    -- 玩家名称
    self.name = 0

    -- 内容
    self.text = 0

    -- 国家
    self._Country = 0

    -- 私聊对象ID
    self._SiLiaoId = 0

    -- 私聊对象玩家名
    self._SiLiaoName = 0

    -- 私聊对象国家
    self._SiLiaoCountry = 0

    -- VIP
    self.vip = 0

end

-- 创建聊天数据  tableID:表格ID
function TalkDataManager:CreateTalk(tableID)
    local newTalkData = TalkData.new(tableID)
    
    return newTalkData
end

-- 管理器
function TalkDataManager:ctor()
    -- 系统
    self._SystemList = {
    --        [2] = {
    --            type = 3, --系统
    --            text = "服务器将于10分钟后关闭，请玩家提前下线，避免造成不必要的损失.服务器将于10分钟后关闭，请玩家提前下线，避免造成不必要的损失",
    --        },
    --        [1] = {
    --            type = 5,
    --            [1] = {
    --                text = "恭喜玩家",
    --                color = "cc.c3b(255, 255, 255)"
    --            },
    --            [2] = {
    --                text = "tewrsdfs（VIP0）",
    --                color = "cc.c3b(255, 255, 0)"
    --            },
    --            [3] = {
    --                text = "通过重铸获得",
    --                color = "cc.c3b(255, 255, 255)"
    --            },
    --            [4] = {
    --                text = "追星赶月斧",
    --                color = "cc.c3b(244, 183, 17)"
    --            },
    --            [5] = {
    --                text = "武将实力突飞猛进",
    --                color = "cc.c3b(255, 255, 255)"
    --            }
    --        }
    }
    -- 世界
    self._WorldList = {}
    -- 私聊
    self._SiLiaoList = {}
    --综合
    self._ZongHeList = {}
    
    self._LimitNum = 200  --在UITalk中的update中，TouchEvent中有用到
    self._NewestInfoNum = 0  --最新的消息数，玩家看过之后清0
    self._NewestSystemInfoIndex = 2   --以滚动播放过的公告最大下标
end

---- 获取某条聊天记录
--function TalkDataManager:GetTalk(tableID)
--    return  self._TalkList[tableID]
--end

local newTalkDataManager = TalkDataManager:new()

function TalkDataManager:GetTalkDataManager()
    return newTalkDataManager
end

return newTalkDataManager