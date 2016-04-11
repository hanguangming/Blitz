----
-- 文件名称：BattleServerDataManager.lua
-- 功能描述：战场相关数据
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-7-28
--  修改：

--沙场点兵排行榜数据
local ShaChangRankPlayerInfo = class("ShaChangRankPlayerInfo")

function  ShaChangRankPlayerInfo:ctor()
    --沙场排名
    self._Rank = 0
    --沙场等级
    self._Level = 0
    --名字
    self._Name = 0
    --VIP
    self._VIP = 0
    --国家
    self._Country = 0
    --战斗力
    self._BattleValue = 0
end

local BattleServerDataManager = class("BattleServerDataManager") 

function BattleServerDataManager:ctor()
    --沙场排行数据
    self._ShaChangRankData = {}
    --当前选择的阵型索引
    --PVE中的PVP选择的阵型索引
    self._CurrentPVEPVPZhenXing = 1
end

--创建沙场排行数据
function BattleServerDataManager:CreateShaChangRankData()
    local newRankData = ShaChangRankPlayerInfo:new()
    return newRankData
end
local newBattleServerDataManager = BattleServerDataManager:new()

return newBattleServerDataManager