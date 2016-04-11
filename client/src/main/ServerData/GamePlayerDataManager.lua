----
-- 文件名称：GamePlayerDataManager.lua
-- 功能描述：玩家信息数据管理 
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-6-18
--  修改：

local PlayerSelfData = class("PlayerSelfData")

--数据结构
--构造函数
function PlayerSelfData:ctor()
    --ID
    self._ServerID = 0
    self._HeadID = 0
    --用户名
    self._UserName = 0
    --铜币
    self._Silver = 0
    --等级
    self._Level = 0
    --经验
    self._Exp = 0
    --血量
    self._HP = 0
    --护甲
    self._Armorvalue = 0
    --攻击距离格子
    self._AttackDistance = 0
    --攻击速度
    self._AttackSpeed = 0
    --攻击力
    self._Attack = 0
    --初始资源
    self._InitResource = 0
    --最大人口
    self._MaxPeople = 0
    --军令值 原为精力
    self._Energy = 0
    --元宝
    self._Gold = 0
    --仓库容量
    self._MaxItems = 0
    --玩家头像地址URL
    self._PlayerHeadURL = 0
    --玩家成长等级
    self._GrowLevel = 0
    --蓝钻VIP
    self._GreenVIPLevel = 0
    --是否蓝钻
    self._IsGreen = 0
    --是否超级蓝钻
    self._IsSuperGreen = 0
    --是否年费蓝钻
    self._IsYearGreen = 0
    --VIP等级
    self._VIPLevel = 0
    --VIP经验
    self._VIPExp = 0
    --战斗力
    self._BattleValue = 0
    --国家
    self._Country = 0
    --pf
    self._Pf = 0
    --招募值
    self._ZhaoMuValue = 0
    --官员值
    self._JobLevel = 0
    --黄钻等级
    self._YellowLevel = 0
    --是否黄钻
    self._IsYellow = 0
    --是否豪华黄钻
    self._IsSuperYellow = 0
    --是否年费黄钻
    self._YearYellow = 0
    --最大关卡
    self._MaxLevel = 1
    --当前关卡需要的虎符数量
    self._NeedHuFuTimes = 0
    --当前要进入的关卡或者扫荡的关
    self._CurCustom = 0
    ------------沙场的相关信息
    --沙场点兵的奖励
    self._ShaChangReward = 0
    --沙场可挑战次数
    self._CanTianZhanCount = 0
    --荣誉值
    self._RongYuZhi  = 0
    
    self._LuckyValue  = 0
    --沙场排名
    self._MyShaChangRank = 0
end

--沙场玩家信息
local ShaChangPlayerInfo =  class("ShaChangPlayerInfo")
function ShaChangPlayerInfo:ctor()
    --当前名次
    self._CurrentRank = 0
    --可挑战次数
    self._CanPlayCount = 0

end

--沙场其它玩家信息
local ShaChangOtherPlayerInfo = class("ShaChangOtherPlayerInfo")
function ShaChangOtherPlayerInfo:ctor()
    --TableID
    self._WuJiangTableID = 0
    --名字
    self._Name = ""
    --等级
    self._Level = 0
    --VIP
    self._VIPLevel = 0
    --排名
    self._Rank = 0

end


--数据管理器
local PlayerDataManager = class("PlayerDataManager")
--构造
function PlayerDataManager:ctor()
    --主角玩家信息
    self._MyselfData = nil
    --其它玩家数据
    self._SelfShaChangInfo = nil
    --其它玩家数据
    self._OtherShaChangPlayerTable = {}
    --沙场点兵 排行榜玩家信息
    self._ShaChangTop5Info = {}
end

--获取主角玩家信息
function PlayerDataManager:GetMyselfData()
    if self._MyselfData == nil then
        self._MyselfData = PlayerSelfData.new()
    end
    return self._MyselfData
end
--创建其它玩家的沙场信息
function PlayerDataManager:CreateShaChangOtherData()
    local newOtherPlayerInfo = ShaChangOtherPlayerInfo.new()
    return newOtherPlayerInfo
end



return PlayerDataManager