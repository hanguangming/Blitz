-- 文件名称：ArtResourceUtility.lua
-- 功能描述：通用功能的函数 涉及到的美术资源
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-6-19
--  修改：
-- 

--Army表中的资源路径
--
ARMY_RESOURCEPATH_ICON = ""
--技能CSB文件
local SKILL_SKILLCSB_PATH = "csb/texiao/jineng/"
local SKILL_ATTACKCSB_PATH = "csb/texiao/pugong/"


--获取Army图标
function GetArmyIconName(characterTableData)
    if  characterTableData.type == CharacterType.CharacterType_Soldier then
        return "meishu/xiaobing/touxiang/" .. characterTableData.headName ..".png"
    else
        return "meishu/wujiang/touxiang/" .. characterTableData.headName ..".png"
    end          
end
--获取 Army CSB
function GetArmyCSBName(characterTableData)
    if  characterTableData.type == CharacterType.CharacterType_Soldier then
        return "csb/xiaobing/" .. characterTableData.resName ..".csb"
    else
        return "csb/wujiang/" .. characterTableData.resName ..".csb"
    end    
end
--获取技能图标
function GetSkillIcon(skillData)
    return "meishu/jineng/" .. skillData.icon .. ".png"
end

local SkillType = 
    {
        --投掷类技能：如弓箭，炮弹等,老的形式将去掉
        SkillType_Throw = 0,
        --简单的普攻
        SkillType_Attack = 1,
        --手动放置类(武将技)
        SkillType_ManualPut = 2,
    }
--获取技能的CSB文件路径(logicSkill:对应Logic下的Skill)
function GetSkillCSBName(logicSkill)
    local skillCSBName = ""
    local tableCSBName = logicSkill._SkillTableData.effectFile
    if logicSkill._SkillType == SkillType.SkillType_ManualPut then
        if tableCSBName ~= nil 
            and tableCSBName ~= "" 
            and tableCSBName ~= "0" 
            and tableCSBName ~= 0  then
            skillCSBName = SKILL_SKILLCSB_PATH .. tableCSBName ..".csb"
        end
    else
        if tableCSBName ~= nil
            and tableCSBName ~= "" 
            and tableCSBName ~= "0" 
            and tableCSBName ~= 0 then
            skillCSBName = SKILL_ATTACKCSB_PATH .. tableCSBName ..".csb"
        end
    end
    return skillCSBName
end

--获取技能CSB文件路径
function GetSkillCSBNameByTableData(tableData, isLeaderSkill)
    local skillCSBName = ""
    local tableCSBName = tableData.effectFile
    if isLeaderSkill then
        if tableCSBName ~= nil 
            and tableCSBName ~= "" 
            and tableCSBName ~= "0" 
            and tableCSBName ~= 0  then
            skillCSBName = SKILL_SKILLCSB_PATH .. tableCSBName ..".csb"
        end
    else
        if tableCSBName ~= nil
            and tableCSBName ~= "" 
            and tableCSBName ~= "0" 
            and tableCSBName ~= 0 then
            skillCSBName = SKILL_ATTACKCSB_PATH .. tableCSBName ..".csb"
        end
    end
    return skillCSBName
end

--根据国家ID获取图标资源
function GetCountryIconName(country)
    if country == CountryType.CountryType_Wei then
        return "meishu/ui/zhujiemian/UI_zjm_wei.png"
    elseif country == CountryType.Shu then
        return "meishu/ui/zhujiemian/UI_zjm_shu.png"
    elseif country == CountryType.Wu then
        return "meishu/ui/zhujiemian/UI_zjm_wu.png"
    end
end

--获取职业资源
function GetSoldierProperty(type)
    if tonumber(type) == SoldierType.SoldierType_Qiang then
        return "meishu/ui/gg/UI_gg_gongji.png"
    elseif tonumber(type) == SoldierType.SoldierType_Dun then 
        return "meishu/ui/gg/UI_gg_fangyu.png"
    elseif tonumber(type) == SoldierType.SoldierType_Gong then
        return "meishu/ui/gg/UI_gg_yuancheng.png"
    else
        return "meishu/ui/gg/UI_gg_yuancheng.png"
    end
end

--查看每个小关卡小兵信息,返回小兵底框资源
function GetEnmeyInfoSoldireProperty(type)
    if tonumber(type) == SoldierType.SoldierType_Qiang then
        return "meishu/ui/guanqia/UI_gq_bing_leixing_gongji.png"
    elseif tonumber(type) == SoldierType.SoldierType_Dun then 
        return "meishu/ui/guanqia/UI_gq_bing_leixing_fangyu.png"
    elseif tonumber(type) == SoldierType.SoldierType_Gong then
        return "meishu/ui/guanqia/UI_gq_bing_leixing_yuancheng.png"
    else
        return "meishu/ui/guanqia/UI_gq_bing_leixing_yuancheng.png"
    end
end

--查看每个小关卡boss信息,返回boss底框资源
function GetEnmeyBossInfoProperty(type)
    if tonumber(type) == SoldierType.SoldierType_Qiang then
        return "meishu/ui/guanqia/UI_gq_jiang_leixing_gongji.png"
    elseif tonumber(type) == SoldierType.SoldierType_Dun then 
        return "meishu/ui/guanqia/UI_gq_jiang_leixing_fangyu.png"
    elseif tonumber(type) == SoldierType.SoldierType_Gong then
        return "meishu/ui/guanqia/UI_gq_jiang_leixing_yuancheng.png"
    else
        return "meishu/ui/guanqia/UI_gq_jiang_leixing_yuancheng.png"
    end
end

function GetWarriorStarImage(type)
    if type == 1 then
        return nil
    elseif type == 0 then
        return "meishu/ui/gg/UI_gg_pinzhi_02.png"
    elseif type == 2 then
        return "meishu/ui/gg/UI_gg_pinzhi_01.png"
    elseif type == 3 then
        return "meishu/ui/gg/UI_gg_pinzhi_03.png"
    elseif type == 4 then
        return "meishu/ui/gg/UI_gg_pinzhi_04.png"
    elseif type == 5 then
        return "meishu/ui/gg/UI_gg_pinzhi_05.png"
    elseif type == 6 then
        return "meishu/ui/gg/UI_gg_pinzhi_06.png"
    elseif type == 7 then
        return "meishu/ui/gg/UI_gg_pinzhi_07.png"
    else
        return "meishu/ui/gg/UI_gg_pinzhi_02.png"
    end
end

--武将士兵列表头像资质底色
function GetHeadColorImage(type)
    if type == 1 then
        return "meishu/ui/gg/UI_gg_touxiangpinzhi_01.png"
    elseif type == 0 then
        return "meishu/ui/gg/UI_gg_touxiangpinzhi_03.png"
    elseif type == 2 then
        return "meishu/ui/gg/UI_gg_touxiangpinzhi_02.png"
    elseif type == 3 then
        return "meishu/ui/gg/UI_gg_touxiangpinzhi_04.png"
    elseif type == 4 then
        return "meishu/ui/gg/UI_gg_touxiangpinzhi_05.png"
    elseif type == 5 then
        return "meishu/ui/gg/UI_gg_touxiangpinzhi_06.png"
    elseif type == 6 then
        return "meishu/ui/gg/UI_gg_touxiangpinzhi_07.png"
    elseif type == 7 then
        return nil
    end
end
