----
-- 文件名称：TableDataManager.lua
-- 功能描述：表格数据管理器:所有.txt数据表结构定义，表数据的管理
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-5-4
--  修改：
--  TOOD: 写工具直接转换.txt成lua代码
--  
require("main.DataPool.DataConstDefine")

local mathCeil = math.ceil
--数据表结构定义
-------------左侧表格中的数据字段，右侧是程序用到的字段,便于程序代码的可读性
--表数据字段定义(Army.txt)
CharacterTableData =
    {
        --id
        ["id"] =  "id",
        --名称
        ["name"] = "name",
        --type1 open
        ["open"] = "open",
        --描述
        ["desc"] = "desc",
        --星级
        ["star"] = "star",
        --品质
        ["qua"] = "quality",
        --类型（1:兵 2：武将 ）
        ["type2"] = "type",
        --职业
        ["job"] = "job",
        --血量
        ["hp"] = "hp",
        --攻击
        ["att"] = "attack",
        --防御
        ["def"] = "defence",
        --攻击速度
        ["as"] = "attackSpeed",
        --攻击距离最小值
        ["adm"] = "attackDistanceMin",
        --攻击距离
        ["ad"] = "maxAttackDistance",
        --移动速度
        ["ms"] = "moveSpeed",
        --花费 消耗粮草
        ["cost"] = "consumeFood",
        --产出 产出粮草
        ["prod"] = "outFood",
        --资源文件(.csb)
        ["csb"] = "resName",
        --兵种
        ["type3"] = "soldierType",
        --人口
        ["peo"] = "people",
        --hp成长
        ["hpup"] = "hpup",
        --攻击成长
        ["attup"] = "attackup",
        --防御成长
        ["defup"] = "defenceup",
        --技能1 普通攻击
        ["skill1"] = "skill1",
        --技能2 武将技能
        ["skill2"] = "skill2",
        --技能3
        ["skill3"] = "skill3",
        --技能4
        ["skill4"] = "skill4",        
        --头像
        ["icon"] = "headName",
        --圆头像
        ["icon2"] = "bodyImage",
        --全身像
        ["icon3"] = "cardImage",
        --死亡头像
        ["deadHeadName"] = "deadHeadName",
        --攻击间隔
        ["attackInterval"] = "attackInterval",
        --仇恨范围
        ["lookZoneX"] = "lookZoneX",
        ["lookZoneY"] = "lookZoneY",
        --长
        ["l"] = "width",
        --宽
        ["w"] = "height",
        --技能段数
        ["skillStageCount"]= "skillStageCount",
        --技能伤害系数
        ["skilldamage"] = "skilldamage",
        --技能CD
        ["skillcd"] = "skillcd",   
 }

--新的技能数据表,右侧为程序用到的字段
SkillTableData =
    {
        --id
        ["id"] = "id",
        --name
        ["name"] = "name",
        --类型(1:普攻  2 技能)
        ["type"] = "type",
        --技能类型
        ["skilltype"] = "skillType",
        --品质
        ["qua"] = "quality",
        --目标类型 0:全体 1:友方 2敌方
        ["target"] = "targetType",
        --区域类型 1:单体  2
        ["pos"] = "zoneType",
        --形状类型
        ["shape"] = "shapeType",        --区域文字描述
        ["posdesc"] = "zoneShowString",
        --使用几率:目前是无用字段
        ["rate"] = "rate",
        --impact:目前无用
        ["impact"] = "impact",
        --buff 列表（合并列已经去掉，换成了分的列）
        ["bufflist"] = "bufflist",
        ["buff1"] = "buff1",
        ["buff2"] = "buff2",
        ["buff3"] = "buff3",
        ["buff4"] = "buff4",
        ["buff5"] = "buff5",
        ["buff6"] = "buff6",
        --attackeffect 攻击特效
        ["attackeffect"] = "attackeffect",
        --icon 图标
        ["icon"] = "icon",
        --描述
        ["desc"] = "desc",
        --csb资源文件路径
        ["csb"] = "effectFile",
        --圆图标
        ["icon2"] = "skillCircleIcon",
    }

--经验数据表
ExpTableData =
    {
        --等级
        ["lv"] = "level",
        --主角经验
        ["exp1"] = "selfExp",
        --兵种经验
        ["exp2"] = "soldierExp",
        --普通训练
        ["tra1"] = "lowTrain",
        --专家训练
        ["tra2"] = "middleTrain",
        --大师训练
        ["tra3"]= "highTrain",
        --普通花费
        ["cost1"] = "lowCost",
        --专家花费
        ["cost2"] = "middleCost",
        --大师花费
        ["cost3"] = "highCost",
        --突飞
        ["up"]= "up",
        --升级奖励
        ["upreward"] = "upreward",
        --特权升级奖励
        ["upreward2"] = "uprewardSpecial",
        --强化花费
        ["cost4"] = "qiangHuaCost",
        --征收钱数
        ["income"] = "moneyZhengShou",

    }
    
-- 道具表

PropTableData = 
{

}

-- 装备表
EquipTableData = 
{

}

--关卡数据表
LevelTableData = 
{
    --id
    ["id"] = "id",
    --名字
    ["name"] = "name",
    --type 大关
    ["type"] = "levelStage",
    --type2 类型(普通 精英 Boss)
    ["type2"] = "levelType",
    --对话
    ["dialog"] = "dialog",
    --描述
    ["desc"] = "desc",
    --体力 防御 攻距  攻速  攻击  攻击特效 
    --城堡血量
    ["hp"] = "hp",
    --粮草
    ["food"] = "food",
    --人口
    ["maxpeo"] = "maxpeo",
    --将数 敌将  兵数  敌兵  救兵1 救兵2 救兵3
    --过关奖励
    ["rewardid"] = "rewardid",
    --特权过关奖励
    ["rewardid2"] = "rewardidSpecial",
    --功勋
    ["exp2"] = "gongXun",
    --解锁兵种
    ["unlock"] = "unlockSoldier", 
    --背景
    --敌兵出兵列表(id, count, level)
    ["binglist"] = "bingList",
    --章节
    ["zhangjie"] = "zhangjie",
    --pvp(注意:在excel里叫pvpid)
    ["pvpid"] = "pvp",
    --CSB
    ["CSB"] = "CSB",
}

--兵种相克数据
SoldierRelationTableData =
{
    --ID
    ["id"] = "id",
    --兵种 1
    ["1"] = "1",
    --兵种 2
    ["2"]= "2",
    --兵种 3
    ["3"] = "3",
    --兵种 3
    ["4"] = "4"
}
--关卡奖励数据
CustomRewardTableData =
    {
        --ID
        ["id"] = "id",
        --关卡名称
        ["name"] = "name",
        --type
        ["type"]= "type",
        --经验
        ["exp"] = "exp",
        --铜钱最小
        ["minsilver"] = "minsilver",
        --铜钱最大
        ["maxsilver"] = "maxsilver",
        --荣誉
        ["rongyu"] = "rongyu",
        --vip经验
        ["vipexp"] = "vipexp",
        --官员值
        ["repute"] = "repute",
        --影子
        ["shadow"] = "shadow",
        --体力
        ["tili"] = "tili",
        --元宝
        ["yb"] = "yb",
        --种类最小
        ["min"] = "min",
        --种类最大
        ["max"] = "max",
        --掉落道具
        ["prop"] = "prop"
    }
--TODO:补全数据结构
TipData = 
{
}

VipData = 
{
}

ExchangeData = 
{
}

TaskData = 
{
}
   
--科技数据
Technology = 
{
    --id
    ["id"] = "id",
    --name
    ["name"] = "name",
    --科技名称
    ["techname"] = "techname",      
    --科技类型
    ["techtype"] = "techtype",
    --等级
    ["lv"] = "lv",
    --系别
    ["type"] = "type",
    --解锁条件
    ["untype"] = "untype",
    --解锁值
    ["unval"] = "unval",
    --影响值
    ["val"] = "val",
    --投资次数
    ["count"] = "count",
    --消耗铜钱
    --消耗元宝
    --消耗木材
    --消耗铁矿
}

--PVP表格数据
PVPTableData = 
{
    --id
    ["id"] = "id",
    --pvp
    ["pvplist"] = "pvplist",
}
--世界地图数据
WorldMapData =
{
    --id
    ["id"] = "id",
    --
    ["row"] = "row",
    --
    ["col"] = "col",
    --
    ["belong"] = "belong",
    --
    ["name"] = "name",
    --
    ["type"] = "type",
    --
    ["dixing"] = "dixing",
    --
    ["img"] = "img",
    --相邻
    ["xiangling"] = "xiangling",
    --归属值
    ["mbelong"] = "mbelong",
    --类型值
    ["mtype"] = "mtype",
    --地形值
    ["mdixing"] = "mtype",    
}
--PVE人口规则表
PVEPeopleData = 
{
    --回合数
    ["round"] = "round",
    --人口增加数目
    ["peo"] = "peo"
}

--技能范围 数据表
SkillPosData = 
{
    --ID
    ["id"] = "id",
    ["type"] = "type",
    ["desc"] = "desc",
    ["x"] = "x",
    ["y"] = "y",
    ["csb"] = "csb",
}
require("main.Utility.ExcelParse")
--此处置成全局变量，考虑到数据表后面会独立到各个Lua文件
TableDataManager = class("TableDataManager")
--构造
function TableDataManager:ctor()
    --角色数据表
    self._CharacterDataManager = nil
    --技能数据表
    self._SkillDataManager = nil
    --关卡数据表
    self._LevelDataManager = nil
    --道具数据表
    self._PropDataManager = nil
    --兵种相克表
    self._SoldierRelationDataManager = nil

    self._SoldierExpDataManager = nil
    --技能攻击特效表
    self._SkillAttackEffectDataManager = nil
    --技能Buff表
    self._SkillBuffDataManager = nil
    --PVP关卡数据表
    self._PVPLevelConfigDataManager = nil
    --关卡奖励表
    self._CustomRewardDataManager = nil
    --PVP表
    self._PVPDataManager = nil
    --世界地图数据
    self._WorldMapDataManager = nil
    self._WorldMapJasonData = nil
    self._WarriorData = {}
    self._SoliderData = {}
    --PVE回合表
    self._PVERoundDataManager = nil
    --技能范围表
    self._SkillPosDataManager = nil    
    self:Init()
end

--
function TableDataManager:Init()
    print("TableDataManager Init enter")
    local fileUtils = cc.FileUtils:getInstance()
    --老的数据表读取
    --Army.txt
    --self._CharacterDataManager = ExcelParse("Data/Army.txt")
    --Skill.txt
    -- self._SkillDataManager = ExcelParse("Data/Skill.txt")
    --Level.txt
    --self._LevelDataManager = ExcelParse("Data/Level.txt", {})
    --
    
    ----新的数据表读取方式
    self._CharacterDataManager = ExcelParseVer2("Data/army.txt", CharacterTableData)
    self._SkillDataManager = ExcelParseVer2("Data/skill.txt", SkillTableData)
    self._LevelDataManager = ExcelParseVer2("Data/level.txt", LevelTableData, nil, false)
    self._SoldierExpDataManager = ExcelParseVer2("Data/exp.txt", ExpTableData)
    self._PropDataManager = ExcelParseVer2("Data/item.txt", PropTableData)
    self._EquipDataManager = ExcelParseVer2("Data/equip.txt", EquipTableData, nil, false)
    self._EquipCostDataManager = ExcelParseVer2("Data/equipcost.txt", {}, nil, false)
     
    self._SkillBuffDataManager = ExcelParseNew("Data/buff.txt", {})
    self._SoldierRelationDataManager = ExcelParseNew("Data/soldierRelation.txt", SoldierRelationTableData) 
    self._VipDataManager = ExcelParseVer2("Data/vip.txt", VipData)  
    self._ExchangeDataManager = ExcelParseNew("Data/heroexchange.txt", ExchangeData) 
    self._CustomRewardDataManager = ExcelParseVer3("Data/reward.txt")
    self._TechnologyDataManager = ExcelParseVer2("Data/technology.txt", CustomRewardTableData)
    self._TaskDataManager = ExcelParseVer2("Data/task.txt", TaskData)
    self._PVPDataManager = ExcelParseNew("Data/pvp.txt", PVPTableData)
    self._NpcDataManager = ExcelParseNew("Data/npc.txt", {})
    local tip = ExcelParseNew("Data/tip.txt", TipData) 
    self._WorldMapDataManager = ExcelParseVer2("Data/worldmap.txt", WorldMapData)
    self._FeatDataManager = ExcelParseNew("Data/feat.txt", {})
    self._ShopDataManager = ExcelParseVer2("Data/shop.txt", {})
    self._ChangeDataManager = ExcelParseVer2("Data/change.txt", {})
    self._BroadcastDataManager = ExcelParseVer2("Data/broadcast.txt", {})
    self._SkillPosDataManager = ExcelParseVer2("Data/skillpos.txt", SkillPosData)
    self._RandomNameDataManager = ExcelParseVer2("Data/randomName.txt", {}, nil, false)
    self._RechargeDataManager = ExcelParseVer2("Data/money.txt", {})
    self._PvpRewardDataManager = ExcelParseVer2("Data/pvpreward.txt", {})
    self._ParameterDataManager = ExcelParseVer2("Data/parameter.txt", {})
    self._RecastDataManager = ExcelParseVer2("Data/recast.txt", {})
    self._TipDataManager = {}
    local dataStr = "Data/worldmap.jason"
    local fileContent = fileUtils:getStringFromFile(dataStr)    
    self._WorldMapJasonData = decodejson(fileContent)
    for i, v in pairs(self._ChangeDataManager) do
        self._ChangeDataManager[v["id"]] = v
    end
--    local pvp1 = ExcelParseNew("Data/Pvp1.txt", TipData) 
--    local file1 = io.open("res/1.txt", "wb")
--    SaveTable1(file1,pvp1)
--    io.close(file1)
    for i, v in pairs(tip) do
        self._TipDataManager[v["val"]] = v["tardesk"]
    end
    
    for i, v in pairs(self._CharacterDataManager) do
        if tonumber(v["type"]) == 2 then
            table.insert(self._WarriorData, i)
        elseif tonumber(v["type"]) == 1 and tonumber(v["open"]) == 1 then
            table.insert(self._SoliderData, i)
        end
    end
    
    --PVE回合数
    self._PVERoundDataManager = ExcelParseVer2("Data/pve_round.txt", PVEPeopleData)   -- dump(self._SoldierRelationDataManager)
    --表格数据的特殊处理
    --技能攻击特效的特殊处理
    local fileName = "main/DataPool/SkillAttackEffect"
    local skillAttackLuaName = fileName .. ".lua"
    if device.platform ~= "windows" then
        skillAttackLuaName = fileName .. ".luac"
    end
    local fileUtils = cc.FileUtils:getInstance()
    local filePath = fileUtils:fullPathForFilename(skillAttackLuaName)
    local isExist = fileUtils:isFileExist(filePath)
    if isExist then
        require(fileName)
    else
        --初始化内容
        self._SkillAttackEffectDataManager = {}
        for k, v in pairs( self._CharacterDataManager) do
            --技能攻击特效参数表
            local SkillAttackEffectTableData = 
            {
                --子弹移动速度
                _MoveSpeed = 500,
                --路径类型
                _Path = 1,
                --偏移X Y 
                _OffsetX = 5,
                _OffsetY = 5,
                --中间点系数
                _MiddleFactor = 1.5,
                --触发伤害时间
                _HurtHitTime = 1.2,
                --结束时的动画特效
                _EndAnimCSBName =  "0",
            }
            self._SkillAttackEffectDataManager[v.skill1] = SkillAttackEffectTableData
        end
    end
    --PVP关卡配置的特殊处理
    local pvpFileName = "main/DataPool/PVPLevelConfig"
    local pvpLevelLuaName = pvpFileName .. ".lua"
    if device.platform ~= "windows" then
        pvpLevelLuaName = fileName .. ".luac"
    end
    filePath = fileUtils:fullPathForFilename(pvpLevelLuaName)
    isExist = fileUtils:isFileExist(filePath)
    if isExist then
        require(pvpFileName)
    else
        --初始化内容
        TableDataManager._PVPLevelConfigDataManager = {}
    end
end

--转换Txt成LuaScript,只有在工具中会调用的接口
function TableDataManager:ConvertTxtToLuaScript()
    print("ConvertTxtToLuaScript Start ")
    local scriptPath = cc.FileUtils:getInstance():fullPathForFilename("src/main.lua")
    local scriptPath = string.gsub(scriptPath,"src/main.lua", "")
    print("ScriptPath ", scriptPath)
    local filePathPrefix = scriptPath .. "/src/main/DataPool/Auto"
    print("file path ", filePathPrefix)
    print("write SkillDataManager...")
    SaveTableToFile(filePathPrefix .. "SkillDataManager.lua", "TableDataManager._SkillDataManager", self._SkillDataManager)
    print("write LevelDataManager...")
    SaveTableToFile(filePathPrefix .. "LevelDataManager.lua", "TableDataManager._LevelDataManager", self._LevelDataManager)
    print("write PropDataManager...")
    SaveTableToFile(filePathPrefix .. "PropDataManager.lua", "TableDataManager._PropDataManager", self._PropDataManager)
    print("write SoldierRelationDataManager...")
    SaveTableToFile(filePathPrefix .. "SoldierRelationDataManager.lua", "TableDataManager._SoldierRelationDataManager", self._SoldierRelationDataManager)
    print("write SoldierExpDataManager...")
    SaveTableToFile(filePathPrefix .. "SoldierExpDataManager.lua", "TableDataManager._SoldierExpDataManager", self._SoldierExpDataManager)
    print("write SkillBuffDataManager...")
    SaveTableToFile(filePathPrefix .. "SkillBuffDataManager.lua", "TableDataManager._SkillBuffDataManager", self._SkillBuffDataManager)
    print("write CustomRewardDataManager...")
    SaveTableToFile(filePathPrefix .. "CustomRewardDataManager.lua", "TableDataManager._CustomRewardDataManager", self._CustomRewardDataManager)
    print("write RongYuShopManager...")
    SaveTableToFile(filePathPrefix .. "RongYuShopManager.lua", "TableDataManager._RongYuShopManager", self._RongYuShopManager)
    print("write PVPDataManager...")
    SaveTableToFile(filePathPrefix .. "PVPDataManager.lua", "TableDataManager._PVPDataManager", self._PVPDataManager)
    print("write WorldMapDataManager...")
    SaveTableToFile(filePathPrefix .. "WorldMapDataManager.lua", "TableDataManager._WorldMapDataManager", self._WorldMapDataManager)
    print("write WorldMapJasonData...")
    SaveTableToFile(filePathPrefix .. "WorldMapJasonData.lua", "TableDataManager._WorldMapJasonData", self._WorldMapJasonData)
    print("write PVERoundDataManager...")
    SaveTableToFile(filePathPrefix .. "PVERoundDataManager.lua", "TableDataManager._PVERoundDataManager", self._PVERoundDataManager)    
    print("write SkillPosDataManager...")
    SaveTableToFile(filePathPrefix .. "SkillPosDataManager.lua", "TableDataManager._SkillPosDataManager", self._SkillPosDataManager) 
    print("ConvertTxtToLuaScript End ") 
    --停顿一会儿
    local i = 0
    while i < 10000 do
        i = i + 1
    end
    
end

--数据表管理器获取
function TableDataManager:GetExchangeDataManager()
    return self._ExchangeDataManager
end

function TableDataManager:GetNpcDataManager()
    return self._NpcDataManager
end

function TableDataManager:GetCharacterDataManager()
    return self._CharacterDataManager
end

function TableDataManager:GetRechargeDataManager()
    return self._RechargeDataManager
end

function TableDataManager:GetSkillDataManager()
    return self._SkillDataManager
end

function TableDataManager:GetLevelDataManager()
    return self._LevelDataManager
end
function TableDataManager:GetSoldierRelationDataManager()
    return self._SoldierRelationDataManager
end

function TableDataManager:GetExpDataManager()
    return self._SoldierExpDataManager
end

function TableDataManager:GetPropDataManager()
    return self._PropDataManager
end

function TableDataManager:GetEquipDataManager()
    return self._EquipDataManager
end

function TableDataManager:GetEquipCostDataManager()
    return self._EquipCostDataManager
end 

function TableDataManager:GetSkillAttackDataManager()
    return self._SkillAttackEffectDataManager
end

function TableDataManager:GetSkillBuffTableDataManager()
    return self._SkillBuffDataManager
end
--关卡表
function TableDataManager:GetCustomTableDataManager()
    return self._LevelDataManager
end

function TableDataManager:GetTipDataManager(key)
    return self._TipDataManager[key]
end

function TableDataManager:GetChangeDataManager()
    return self._ChangeDataManager
end

function TableDataManager:GetVipDataManager()
    return self._VipDataManager
end

function TableDataManager:GetTechnologyDataManager()
    return self._TechnologyDataManager
end

function TableDataManager:GetTaskDataManager()
    return self._TaskDataManager
end

function TableDataManager:GetFeatDataManager()
    return self._FeatDataManager
end

function TableDataManager:GetPveRewardDataManager()
    return self._PvpRewardDataManager
end

--重铸信息获取
function TableDataManager:GetRecastDataManager()
    return self._RecastDataManager
end

function TableDataManager:GetShopDataManager()
    return self._ShopDataManager
end

function TableDataManager:GetParameterDataManager()
    return self._ParameterDataManager
end

--根据关卡类型获得该类型的所有关卡数据
function TableDataManager:GetTypeCustom(type)
    local levelTypeData = {}
    for i, v in pairs(self._LevelDataManager) do
        if tonumber(v.levelStage) == type then
            table.insert(levelTypeData,v)
        end
    end
    return levelTypeData
end

function TableDataManager:GetWarriorIDList()
    return self._WarriorData
end

--PVP关卡配置数据
function TableDataManager:GetPVPLevelConfigDataManager()
    return self._PVPLevelConfigDataManager
end
--关卡奖励表数据
function TableDataManager:GetCustomRewardDataManager()
    return self._CustomRewardDataManager
end
--PVP关卡配置
function TableDataManager:GetPVPDataManager()
    return self._PVPDataManager
end
--世界地图数据
function TableDataManager:GetWorldMapTableDataManager()
    return self._WorldMapDataManager
end
--PVE回合数据
function TableDataManager:GetPVERoundDataManager()
    return self._PVERoundDataManager
end
--技能范围表
function TableDataManager:GetSkillPosDataManager()
    return self._SkillPosDataManager
end

function TableDataManager:GetRandomNameDataManager()
    return self._RandomNameDataManager
end

local newTableDataManager = TableDataManager.new()


-------------------------下面的接口将要废弃 begin -------------------------
--外部获取用
function GetCharacterDataManager()
    --return CharacterDataManager
    return newTableDataManager._CharacterDataManager
end
--获取
function GetSkillDataManager()
    -- return SkillDataManager
    return newTableDataManager._SkillDataManager
end
--获取 关卡数据
function GetLevelDataManager()
    return newTableDataManager._LevelDataManager
end

--获取 兵种相克数据
function GetSoldierRelationDataManager()
    return newTableDataManager._SoldierRelationDataManager
end

--获取 道具数据
function GetPropDataManager()
    return newTableDataManager._PropDataManager
end

function GetEquipDataManager()
    return newTableDataManager._EquipDataManager
end

-------------------------下面的接口将要废弃 end -------------------------

return newTableDataManager