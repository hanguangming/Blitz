----
-- 文件名称：DataConstDefine.lua
-- 功能描述：游戏中程序中通用的常量定义枚举,这里面的是模块间通用的定义，私有的不要放在这里面
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-5-4
--  修改：

--1 个格子的大小
SIZE_ONE_TILE = 16
--正常移动速度
NORMAL_WALK_SPEED_PIXEL = 16 / 100 * 1
--攻击速度系数
ATTACK_SPEED_FACTOR = 0.01


--角色类型定义
CharacterType = 
{
    --兵
    CharacterType_Soldier = 1,
    --武将
    CharacterType_Leader = 2,
    --战斗场景中的建筑
    CharacterType_Building = 5,
}

--兵种类型定义
SoldierType = 
{
    --枪
   SoldierType_Qiang = 1,
   --盾
   SoldierType_Dun = 2,
   --弓
   SoldierType_Gong = 3,
  
}

--攻击类型
AttackType = 
{
    --单体
    AttackType_DanTi = 1,
    --小
    AttackType_Small = 2,
    --中
    AttackType_Zhong = 3,
    --大
    AttackType_Big = 4,
    --巨大
    AttackType_JuDa= 5,
    --竖
    AttackType_Line= 7,
}
--科技类型定义
TechnologyType = 
{
    PVP_PeopleCount = "pvp_renshu" 
}

--奖励类型
RewardType = 
{
    --元宝
    RewardType_YuanBao = 1,
    --铜钱
    RewardType_TongQian = 2,
    --经验
    RewardType_Exp = 3,
    --荣誉
    RewardType_RongYu = 4,
    --招募值
    RewardType_ZhaoMuZhi = 5,
    --军令
    RewardType_JunLing = 6,
    --免费影子
    RewardType_FreeShadow = 7,
    
}

--国家定义
CountryType =
 {
    CountryType_Wei = 1,
    CountryType_Shu = 0,
    CountryType_Wu = 2,
 }
--人口为1的布阵数组
ZHEN_XING_PEO_1 = 
{
    {{1,1}, {1,2}, {1,3}, {1,4}},
    {{2,1}, {2,2}, {2,3}, {2,4}},
    {{3,1}, {3,2}, {3,3}, {3,4}},
    {{4,1}, {4,2}, {4,3}, {4,4}},
    {{5,1}, {5,2}, {5,3}, {5,4}},
}
--人口为5的布阵数组
ZHEN_XING_PEO_5 = 
{
    {{2,1}, {2,3}},
    {{4,1}, {4,3}},
}
--人口为10的布阵数组
ZHEN_XING_PEO_10 = 
{
   {2,2},
   {4,2},
}
--武将单元格坐标
ZHEN_XING_WUJIANG_POS = 
{
   {4, 6}
}