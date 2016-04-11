----
-- 文件名称：battleMain.lua
-- 功能描述：PVP战斗逻辑测试
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-10-18
--  修改：

require ("main.GameGlobal") 
local GameLevelPVP = require("main.Logic.GameLevelPVP")
local GuoZhanServerDataManager = GameGlobal:GetGuoZhanServerDataManager()
--服务器阵形数据结构
--[[
struct G_FightTeam {
    uint32 hero_id;
    uint32 hero_attack;
    uint32 hero_attack_speed;
    uint32 hero_hp;
    uint32 hero_cur_hp;

    uint32 soldier_id;
    uint32 soldier_attack;
    uint32 soldier_attack_speed;
    uint32 soldier_hp;
    uint8 soldier_num;
    uint8 soldier_cur_num;

    int32 x;
    int32 y;
};

struct G_FightCorps {
    G_FightTeam teams[];
};
]]--

--服务器数据 -->客户端阵形数据(corpsData:服务器数据    dataTable:输出数据的Table)
local function CreateZhenXingData(corpsData, dataTable)
    if corpsData == nil or dataTable == nil then
        print("error: CreateZhenXingData corpsData == nil or dataTable == nil", corpsData, dataTable)
        return
    end
    --武将阵形数据
    local startRow = corpsData.x
    local startCol = corpsData.y
    local levelZhenXingData = GuoZhanServerDataManager:CreateGuoZhanZhenXing()
    levelZhenXingData._SoldierTableID = corpsData.hero_id
    levelZhenXingData._TileX = startRow + ZHEN_XING_WUJIANG_POS[1][1]
    levelZhenXingData._TileY = startCol + ZHEN_XING_WUJIANG_POS[1][2]
    levelZhenXingData._HP = corpsData.hero_cur_hp
    levelZhenXingData._AttackSpeed = corpsData.hero_attack_speed
    levelZhenXingData._Attack = corpsData.hero_attack
    levelZhenXingData._BelongWuJiangTableID = corpsData.hero_id
    levelZhenXingData._BigZhenXingRow = startRow
    levelZhenXingData._BigZhenXingCol = startCol
    table.insert(dataTable, levelZhenXingData)

    local soldierCount = corpsData.soldier_cur_num
    local soldierTableID = corpsData.soldier_id
    local armyDataManager = GameGlobal:GetDataTableManager():GetCharacterDataManager()
    local armyData = armyDataManager[soldierTableID]
    local currentCount = 0
    --小兵阵形数据 根据所占人口
    local people = armyData.people
    if people == 1 then
        for row = 1, 5 do
            if currentCount >= soldierCount then
                break
            end
            for col = 1, 4 do
                if currentCount >= soldierCount then
                    break
                end 
                local levelZhenXingData = GuoZhanServerDataManager:CreateGuoZhanZhenXing()
                levelZhenXingData._SoldierTableID = corpsData.soldier_id
                levelZhenXingData._TileX = startRow + ZHEN_XING_PEO_1[row][col][1]
                levelZhenXingData._TileY = startCol + ZHEN_XING_PEO_1[row][col][2]
                levelZhenXingData._HP = corpsData.soldier_hp
                levelZhenXingData._AttackSpeed = corpsData.soldier_attack_speed
                levelZhenXingData._Attack = corpsData.soldier_attack
                levelZhenXingData._BelongWuJiangTableID = corpsData.hero_id
                levelZhenXingData._BigZhenXingRow = startRow
                levelZhenXingData._BigZhenXingCol = startCol
                table.insert(dataTable, levelZhenXingData)
                currentCount = currentCount + 1
            end
        end
    elseif people == 5 then
        for row = 1, 2 do
            if currentCount >= soldierCount then
                break
            end
            for col = 1, 2 do
                if currentCount >= soldierCount then
                    break
                end
                local levelZhenXingData = GuoZhanServerDataManager:CreateGuoZhanZhenXing()
                levelZhenXingData._SoldierTableID = corpsData.soldier_id
                levelZhenXingData._TileX = startRow + ZHEN_XING_PEO_5[row][col][1]
                levelZhenXingData._TileY = startCol + ZHEN_XING_PEO_5[row][col][2]
                levelZhenXingData._HP = corpsData.soldier_hp
                levelZhenXingData._AttackSpeed = corpsData.soldier_attack_speed
                levelZhenXingData._Attack = corpsData.soldier_attack
                levelZhenXingData._BelongWuJiangTableID = corpsData.hero_id
                levelZhenXingData._BigZhenXingRow = startRow
                levelZhenXingData._BigZhenXingCol = startCol
                table.insert(dataTable, levelZhenXingData)
                currentCount = currentCount + 1
            end
        end
    elseif people == 10 then
        for row = 1, 2 do
            if currentCount >= soldierCount then
                break
            end
            local levelZhenXingData = GuoZhanServerDataManager:CreateGuoZhanZhenXing()
            levelZhenXingData._SoldierTableID = corpsData.soldier_id
            levelZhenXingData._TileX = startRow + ZHEN_XING_PEO_10[row][1]
            levelZhenXingData._TileX = startCol + ZHEN_XING_PEO_10[row][2]
            levelZhenXingData._HP = corpsData.soldier_hp
            levelZhenXingData._AttackSpeed = corpsData.soldier_attack_speed
            levelZhenXingData._Attack = corpsData.soldier_attack
            levelZhenXingData._BelongWuJiangTableID = corpsData.hero_id
            levelZhenXingData._BigZhenXingRow = startRow
            levelZhenXingData._BigZhenXingCol = startCol
            table.insert(dataTable, levelZhenXingData)
            currentCount = currentCount + 1
        end
    end
end
--缓存的数据
local attackerInfo = nil
local defenderInfo = nil

--初始化阵形数据(数据结构转换,转换成端的数据)
function InitZhenXingData(attackerCorps, defenderCorps)
    attackerInfo = attackerCorps
    defenderInfo = defenderCorps
    GuoZhanServerDataManager._GuoZhanAttackerZhenXingData = {}
    --攻方
    local attackerZhenXing = attackerCorps.teams
    local teamCount = #attackerZhenXing
    if teamCount == 0 then
        print("error: InitZhenXingData teamCount == 0")
    end
    for i = 1, teamCount do
        CreateZhenXingData(attackerZhenXing[i], GuoZhanServerDataManager._GuoZhanAttackerZhenXingData)
    end
    --守方
    GuoZhanServerDataManager._GuoZhanDefenderZhenXingData = {}
    local defenderZhenXing = defenderCorps.teams
    local defenderCount = #defenderZhenXing
    if defenderCount == 0 then
        print("error: InitZhenXingData defenderCount == 0")
    end
    for i = 1, defenderCount do
        CreateZhenXingData(defenderZhenXing[i], GuoZhanServerDataManager._GuoZhanDefenderZhenXingData)
    end
end

--获取结果（目前设定的Update:33毫秒）
function GetBattleResult()
    local battleFrameCount = 0
    local battleResult = 0
    -- -2:国战PVP战斗
    local battleLevel = GameLevelPVP.new(-2, false)
    if battleLevel ~= nil then
        battleLevel:Init()
        battleLevel:InitGuoZhanPVPSoldiers()
        battleLevel:SetLevelState(LevelState.LevelState_Runing)
        battleLevel._CurrentFrameCount = 0
        print("start battle ", os.clock())
        local isEnd = false
        while(isEnd == false)do
            battleLevel:Update(0)
            isEnd = battleLevel:GetIsFinished()
        end
        print("end battle", os.clock())
    end
    print("battle total frame ", battleLevel:GetTotalFrame())
    battleFrameCount = battleLevel:GetTotalFrame()
    --当前剩余的兵,组织serverData回传
    local corpsTable = {}
    local winnerInfo = nil
    --攻方输
    local currentCharacterList = nil
    if battleLevel._BattleResult == BattleResult.BattleResult_Lose then
        currentCharacterList = battleLevel._EnemySoldierIDList
        --攻方全死
        if attackerInfo ~= nil then
            local teamCount = #attackerInfo.teams
            for i = 1, teamCount do
                local zhenXingInfo = attackerInfo.teams[i]
                zhenXingInfo.hero_cur_hp = 0
                zhenXingInfo.soldier_cur_num = 0
            end
        end
        winnerInfo = defenderInfo
    --攻方赢
    elseif battleLevel._BattleResult == BattleResult.BattleResult_Win then
        currentCharacterList = battleLevel._SelfSoldierIDList
        --守方全死
        if defenderInfo ~= nil then
            local teamCount = #defenderInfo.teams
            for i = 1, teamCount do
                local zhenXingInfo = defenderInfo.teams[i]
                zhenXingInfo.hero_cur_hp = 0
                zhenXingInfo.soldier_cur_num = 0
            end
        end 
        winnerInfo = attackerInfo
    end
    for k, v in pairs(currentCharacterList)do
        if v ~= nil then
            local currentCharacter = battleLevel._CharacterPVPManager:GetCharacterByClientID(v)
            if currentCharacter ~= nil then
                local wuJiangTableID = currentCharacter._BelongWuJiangTableID
                local soldierTableID = currentCharacter._CharacterTableID
                if corpsTable[wuJiangTableID] == nil then
                    corpsTable[wuJiangTableID] = {}
                    corpsTable[wuJiangTableID].soldier_cur_num = 0
                    corpsTable[wuJiangTableID].hero_cur_hp = 0
                    corpsTable[wuJiangTableID].hero_id = wuJiangTableID
                end
                local teamData = corpsTable[wuJiangTableID]
                if soldierTableID == wuJiangTableID then
                    teamData.hero_cur_hp = currentCharacter._CurrentHP
                else
                    teamData.soldier_cur_num = teamData.soldier_cur_num + 1
                end
            end
        end
    end
    --填充胜利方的阵形信息
    if winnerInfo ~= nil then
        local winnerTeamCount = #winnerInfo.teams
        for i = 1, winnerTeamCount do
            local zhenXingInfo = winnerInfo.teams[i]
            local wuJiangTableID = zhenXingInfo.hero_id
            local leftSoldierInfo = corpsTable[wuJiangTableID]
            if leftSoldierInfo == nil then
                zhenXingInfo.hero_cur_hp = 0
                zhenXingInfo.soldier_cur_num = 0
            else
                zhenXingInfo.hero_cur_hp = leftSoldierInfo.hero_cur_hp
                zhenXingInfo.soldier_cur_num = leftSoldierInfo.soldier_cur_num
            end
        end
    end
    --
    if battleLevel._BattleResult == BattleResult.BattleResult_Lose then
        battleResult = 2
    else
        battleResult = 1
    end
    
    local resultInfo = 
    {
        attacker = attackerInfo,
        defender = defenderInfo,
        result = battleResult,
        frames = battleFrameCount,
    }
    return resultInfo
end

--测试数据
local function InitTestZhenXing()
    --[[
    local tableInsert = table.insert
    local GuoZhanServerDataManager = GameGlobal:GetGuoZhanServerDataManager()
    
    local zhenXing = GuoZhanServerDataManager:CreateGuoZhanZhenXing()
    zhenXing._SoldierTableID = 10001
    zhenXing._Attack = 20
    zhenXing._HP = 300
    zhenXing._TileX = 9
    zhenXing._TileY = 10
    tableInsert(GuoZhanServerDataManager._GuoZhanDefenderZhenXingData, zhenXing)

    zhenXing = GuoZhanServerDataManager:CreateGuoZhanZhenXing()
    zhenXing._SoldierTableID = 5504
    zhenXing._Attack = 100
    zhenXing._HP = 2000
    zhenXing._TileX = 9
    zhenXing._TileY = 15
    tableInsert(GuoZhanServerDataManager._GuoZhanAttackerZhenXingData, zhenXing)

    zhenXing = GuoZhanServerDataManager:CreateGuoZhanZhenXing()
    zhenXing._SoldierTableID = 10001
    zhenXing._Attack = 20
    zhenXing._HP = 300
    zhenXing._TileX = 9
    zhenXing._TileY = 10
    tableInsert(GuoZhanServerDataManager._GuoZhanAttackerZhenXingData, zhenXing)
    ]]--
    local attackerCorps = 
    {
        uid = "1",
        vip = 0,
        name = "test001",
        teams = 
        {
            [1] = 
            {
                hero_id = 5504,
                hero_attack = 1000,
                hero_attack_speed = 100,
                hero_hp = 2000,
                hero_cur_hp = 2000,
                
                soldier_id = 10001,
                soldier_attack = 200,
                soldier_attack_speed = 100,
                soldier_hp = 300,
                soldier_num = 20,
                soldier_cur_num = 20,
                
                x = 9, 
                y = 11
            }
        }
    }
    
    local defenderCorps = 
    {
        uid = "2",
        vip = 0,
        name = "test002",
        teams = 
        {
            [1] = 
            {
                hero_id = 5504,
                hero_attack = 1000,
                hero_attack_speed = 100,
                hero_hp = 2000,
                hero_cur_hp = 2000,

                soldier_id = 10001,
                soldier_attack = 200,
                soldier_attack_speed = 100,
                soldier_hp = 300,
                soldier_num = 20,
                soldier_cur_num = 20,

                x = 9, 
                y = 9,
            }
        }
    }
    InitZhenXingData(attackerCorps, defenderCorps)
end

local function main()
    --InitZhenXingData()
    InitTestZhenXing()
    GetBattleResult()
end

__G__TRACKBACK__ = function(msg)
    local msg = debug.traceback(msg, 3)
    print(msg)
    return msg
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
