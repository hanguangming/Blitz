-- 
-- 文件名称：Utility
-- 功能描述：通用功能的函数
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-4-30
--  修改：
-- 
--全局控制变量,自动战斗用来测试PVE
TEST_AUTO_BATTLE = false


require("main.Utility.ChineseConvert")
local PacketPathPrefix = "main.NetSystem.Packet."

function loadLua(path)
    local BasePath = ""
    local DirList = {}
    if device.platform == "android" then
        local pathdrir string.gsub(cc.FileUtils:getInstance():fullPathForFilename("server.xml"), "res/server.xml", "")
        BasePath = pathdrir
    end
    for entry in lfs.dir(BasePath.."src/main/NetSystem/Packet/"..path) do
        local isLua = entry ~= "__init__.lua" and string.find(entry, ".lua") ~= nil
        local isLc = entry ~= "__init__.lc" and string.find(entry, ".lc") ~= nil
        if entry ~= "." and entry ~= ".." and (isLua or isLc) then
            local s, n = string.gsub(entry, "%.lua+", "")
            local start, endIndex = string.find(s, "CS")
            table.insert(DirList, PacketPathPrefix..path.."."..s)
        end
    end 
    return DirList
end

--分割字符串到表
function Split(str, delim, maxNb)
    -- Eliminate bad cases...   
    local localstring = string
    if localstring.find(str, delim) == nil then  
        return { str }  
    end  
    if maxNb == nil or maxNb < 1 then  
        maxNb = 0    -- No limit   
    end  
    local result = {}  
    local pat = "(.-)" .. delim .. "()"   
    local nb = 0  
    local lastPos   
    for part, pos in localstring.gfind(str, pat) do  
        nb = nb + 1  
        result[nb] = part   
        lastPos = pos   
        if nb == maxNb then break end  
    end  
    -- Handle the last field   
    if nb ~= maxNb then  
        result[nb + 1] = localstring.sub(str, lastPos)   
    end  
    return result   
end

function SplitSet(str)
    local data = {}
    for s in string.gfind(str, "[^(]+") do
        local v,_ = string.gsub(s, '%)', "")
        table.insert(data, Split(v, ',')) 
    end
    return data
end

function SplitSet2(str)
    local data = {}
    for s in string.gfind(str, "[^(]+") do
        local v,_ = string.gsub(s, '%)', "")
        table.insert(data, v) 
    end
    return data
end

--查找节点
function seekNodeByName(parent, name)
    if not parent or parent.getChildren == nil then
        return
    end

    -- Log.d("parent.name ###%s### type %s  name ###%s### type %s", parent:getName(), type(parent:getName()), name, type(name))

    if parent:getName() == name then
        return parent
    end

    local findNode
    local children = parent:getChildren()
    local childCount = parent:getChildrenCount() 
    if childCount < 1 then
        return
    end
    for i=1, childCount do
        if "table" == type(children) then
            parent = children[i]
        elseif "userdata" == type(children) then
            parent = children:objectAtIndex(i - 1)
        end

        if parent then
            findNode = seekNodeByName(parent, name)
            if findNode then
                return findNode
            end
        end
    end

    return
end

--去除字符
function TrimString(strContent, flag)
    if strContent == 0 or strContent == nil then
        return
    end
    return string.gsub(strContent, flag, "")
end

--以下为序列化函数
function basicSerialize (o)  
    if type(o) == "number" then  
       return tostring(o)  
    else       -- assume it is a string  
       return string.format("%q", o)  
    end  
end 

--保存Table数据到Lua文件
function SaveTable(file, name, value, saved)  
    saved = saved or {}    
    if type(value) == "number" or type(value) == "string" then  
        file.write(file,name.." = ")  
        file.write(file,basicSerialize(value).."\r\n")  
    elseif type(value) == "table" then  
        file.write(file,name.." = ")
        if saved[value] then     -- value already saved?  
            -- use its previous name  
            file.write(file,saved[value].."\r\n")  
        else  
            saved[value] = name -- save name for next time  
            file.write(file,"{}\r\n")     -- create a new table  
            for k,v in pairs(value) do -- save its fields  
                local fieldname = string.format("%s[%s]", name, basicSerialize(k))  
                SaveTable(file,fieldname, v, saved)  
            end  
        end  
    else
    --nothing to do
    --error("cannot save a " .. type(value))  
    end  
end 
--保存Lua Table到文件
function SaveTableToFile(fileName, name, toSaveData)
    local file = io.open(fileName, "wb")
    SaveTable(file,name,toSaveData)
    io.close(file)
end

function SortTable(a, b) 
     print("==============================")
    return tonumber(a.id) < tonumber(b.id)
end

--保存Table数据到Lua文件
function SaveTable1(file, value)    
    if type(value) == "table" then 
        print("==+++++++++++++++++++++++++++++++===="..value[20].id)
        table.sort(value, SortTable)
        local level = 20
        for i, v in pairs(value) do
            print(i.."----------------------------"..v["id"])
            local data = SplitSet(value[level]["pvp"])
          
            
            local warrior = false
            file.write(file,level.."    \t")
            for j = 1, #data do
                if math.floor(tonumber(data[j][1]) / 100000) > 1 then
                    warrior = true
                    file.write(file, "("..data[j][1]..","..data[j][4]..")") 
                elseif math.floor(tonumber(data[j][1]) / 100000) == 1 and warrior then
                    warrior = false
                    file.write(file, "("..data[j][1]..","..data[j][4]..")") 
                end
            end
            file.write(file,"\t\r\n")  
            level = level + 10
        end 
    end  
end

function GetEquipType(type)
    print(type)
    return ChineseConvert["UIEquip_"..type]
end

--国家标识字体颜色
function GetCountryFontColor(type)
    if tonumber(type) == CountryType.CountryType_Wei then
        return cc.c3b(119, 221, 255)
    elseif tonumber(type) == CountryType.CountryType_Shu then
        return cc.c3b(255, 140, 140)
    elseif tonumber(type) == CountryType.CountryType_Wu then
        return cc.c3b(133, 201, 100)
    end
end

--武将资质
function GetWarriorQuality(type)
    local text = ChineseConvert["UIWarriorQuality_" .. type]
    return text
end

--士兵攻击类型 字符串
function GetSoldierType(type)
    if tonumber(type) == SoldierType.SoldierType_Qiang then
        return ChineseConvert["UISoldierText_GongJi"]
    elseif tonumber(type) == SoldierType.SoldierType_Dun then
        return ChineseConvert["UISoldierText_FangYu"]
    elseif tonumber(type) == SoldierType.SoldierType_Gong then
        return ChineseConvert["UISoldierText_YuanCheng"]
    end 
end
--攻击范围字符串
function GetSoldierAttackType(type)
    if tonumber(type) == AttackType.AttackType_DanTi then
        return ChineseConvert["UISoldierText_DanTi"]
    else
        return ChineseConvert["UISoldierText_QunTi"]
    end
end

--获取国家汉字(魏蜀吴)
function GetCountryChinese(type)
    if type == CountryType.CountryType_Wei then
        return ChineseConvert["Utility_Country_Wei"]
    elseif type == CountryType.CountryType_Shu then
        return ChineseConvert["Utility_Country_Shu"]
    elseif type == CountryType.CountryType_Wu then
        return ChineseConvert["Utility_Country_Wu"]
    end
end

--获取势力
function GetGuoZhanBelongChinese(type)
    if type == CountryType.CountryType_Wei then
        return ChineseConvert["Utility_Country_Wei"]
    elseif type == CountryType.CountryType_Shu then
        return ChineseConvert["Utility_Country_Shu"]
    elseif type == CountryType.CountryType_Wu then
        return ChineseConvert["Utility_Country_Wu"]
    elseif type == 4 then
        return ChineseConvert["Utility_ManZu"]
    elseif type == 5 then
        return ChineseConvert["Utility_HuangJin"]
    end
    return nil
end

function GetGuoZhanBelongImage(type)
    if type == CountryType.CountryType_Wei then
        return "meishu/ui/gg/UI_gg_wei.png"
    elseif type == CountryType.CountryType_Shu then
        return "meishu/ui/gg/UI_gg_shu.png"
    elseif type == CountryType.CountryType_Wu then
        return "meishu/ui/gg/UI_gg_wu.png"
    end
    return nil
end

function GetJudianColor(type)
    if type == CountryType.CountryType_Wei then
        return cc.c3b(0 ,199 , 249)
    elseif type == CountryType.CountryType_Shu then
        return cc.c3b(255 ,109 , 0)
    elseif type == CountryType.CountryType_Wu then
        return cc.c3b(0 ,255 , 0)
    elseif type == 4 then
        return cc.c3b(184 ,19 , 190)
    elseif type == 5 then
        return cc.c3b(255 ,255 , 0)
    end
    return cc.c3b(255 ,255 , 255)
end

function GetQualityColor(type)
    if type == 1 then
        return cc.c3b(244 ,244 , 244)
    elseif type == 0 then
        return cc.c3b(90 ,148 , 255)
    elseif type == 2 then
        return cc.c3b(75 ,235 , 19)
    elseif type == 3 then
        return cc.c3b(19 ,237 , 214)
    elseif type == 4 then
        return cc.c3b(203 ,121 , 255)
    elseif type == 5 then
        return cc.c3b(255 ,204 , 94)
    elseif type == 6 then
        return cc.c3b(255 ,162 , 72)
    elseif type == 7 then
        return cc.c3b(255 ,72 , 115)
    elseif type == 8 then
        return cc.c3b(115, 74, 18)
    end
end
 
function GetSoliderQualityColor(type)
    if type == 1 then 
        return cc.c3b(252 ,242 , 209)
    elseif type == 2 then
        return cc.c3b(71 ,255 , 119)
    elseif type == 3 then
        return cc.c3b(91 ,221 , 253)
    elseif type == 4 then
        return cc.c3b(255 ,102 , 242)
    elseif type == 5 then
        return cc.c3b(255 ,138 , 0)
    elseif type == 6 then
        return cc.c3b(255 ,165 , 36)
    end
end

function GetEquipQualityColor(type)
    if type == 1 then 
        return cc.c3b(252 ,242 , 209)
    elseif type == 2 then
        return cc.c3b(71 ,255 , 119)
    elseif type == 3 then
        return cc.c3b(91 ,221 , 253)
    elseif type == 4 then
        return cc.c3b(255 ,102 , 242)
    elseif type == 5 then
        return cc.c3b(255 ,138 , 0)
    elseif type == 6 then
        return cc.c3b(255 ,165 , 36)
    end
end

function GetPropPath(propId)
    if tonumber(propId) == 1 then
        return "meishu/ui/gg/UI_gg_yuanbao_01.png"
    elseif tonumber(propId) == 2 then
        return "meishu/ui/gg/UI_gg_tongqian_01.png"
    elseif tonumber(propId) == 3 then
        return "meishu/ui/wupin/30016.png"
    elseif tonumber(propId) == 4 then
        return "meishu/ui/gg/UI_gg_rongyu_01.png"
    elseif tonumber(propId) == 5 then
        return "meishu/ui/gg/UI_gg_zhaomuzhi.png"
    elseif tonumber(propId) == 6 then
        return "meishu/ui/gg/UI_gg_zhanli.png"
    else
        return "meishu/ui/wupin/"..GetPropDataManager()[tonumber(propId)]["icon"]..".png"
    end
end

function GetWarriorPath(propId)
    return "meishu/wujiang/touxiang/"..propId..".png"
end

function GetWarriorBodyPath(propId)
    return "meishu/wujiang/quanshenxiang/"..propId..".png"
end

function GetSkillPath(propId)
    return "meishu/jineng/"..propId..".png"
end

function GetWarriorHeadPath(propId)
    return "meishu/wujiang/touxiang/"..propId..".png"
end

function GetWarriorCsbPath(propId)
    return "csb/wujiang/"..propId..".csb"
end

function GetSoldierBodyPath(propId)
    return "meishu/xiaobing/quanshenxiang/"..propId..".png"
end

function GetSoldierHeadPath(propId)
    return "meishu/xiaobing/touxiang/"..propId..".png"
end

function GetSoldierCsbPath(propId)
    return "csb/xiaobing/"..propId..".csb"
end