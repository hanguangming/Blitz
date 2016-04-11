require("main.Utility.ExcelParse")

local CharacterDataManager = ExcelParseVer2("Data/army.txt", {})
local SkillDataManager = ExcelParseVer2("Data/skill.txt", {})
local SkillPosDataManager = ExcelParseVer2("Data/skillpos.txt", {})
local SoldierRelationDataManager = ExcelParseNew("Data/soldierRelation.txt", {}) 
local BuffManager = ExcelParseNew("Data/buff.txt", {}) 

Fight = {}

local ZHEN_XING_PEO = 
    {
        [1] = {
            {1,1}, 
            {2,1},
            {3,1}, 
            {4,1}, 
            {5,1},
            {1,2},
            {2,2},
            {3,2},
            {4,2},
            {5,2},
            {1,3},
            {2,3},
            {3,3},
            {4,3},
            {5,3},
            {1,4},
            {2,4},
            {3,4},
            {4,4},
            {5,4}
        },
        [5] = {
            {2,1}, {2,3},
            {4,1}, {4,3}
        },
        [10] = {
            {2,2},
            {4,2}
        },
    }

local SCENE_WIDTH       = 1280
local SCENE_HEIGHT      = 640

local TILE_SHERCH       = 9
local TILE_ROW_COUNT    = 50
local TILE_COL_COUNT    = 80
local TILE_WIDTH_HEIGHT = 16
local FTPS              = 30 
local gOffBottomX       = 85
local gOffBottomY       = 80
local gOffBottomPveY       = 300
local gNextTime      = 1100
local FIGHT_STATE_STAY       = 1
local FIGHT_STATE_MOVE       = 2
local FIGHT_STATE_ATTACK     = 3
local FIGHT_STATE_ATTACK_INTERVAL = 4
local FIGHT_STATE_ATTACK_WALK = 5
local FIGHT_STATE_DEATH      = 6

local g_actor
local gEntryID 
local gEnterPve
local gOpenTick = false
local g_pause = false

local get_id            = get_value_1
local set_id            = set_value_1
local get_hp            = get_value_2
local set_hp            = set_value_2
local get_attack        = get_value_3
local set_attack        = set_value_3
local get_skillId       = get_value_4
local set_skillId       = set_value_4
local get_actorType     = get_value_5
local set_actorType     = set_value_5
local get_skillPosId    = get_value_6
local set_skillPosId    = set_value_6
local get_skillPosCol   = get_value_7
local set_skillPosCol   = set_value_7
local get_skillPosRow   = get_value_8
local set_skillPosRow   = set_value_8
local get_maxhp         = get_value_9
local set_maxhp         = set_value_9
local get_isHero        = get_value_11
local set_isHero        = set_value_11
local get_teamId        = get_value_12
local set_teamId        = set_value_12
local get_isAttacker    = get_value_13
local set_isAttacker    = set_value_13

local function calc_result(info, result)
    if gEnterPve then
        return 
    end
    local function ResetFight()
        if result == 1 then
            info["defender"]["teams"] = nil 
            local size = #info["attacker"]["teams"]
            for i = 1, size do
                info["attacker"]["teams"][i].soldier_num = 0
                info["attacker"]["teams"][i].hero_hp = 0
            end
        else
            info["attacker"]["teams"] = nil 
            local size = #info["defender"]["teams"]
            for i = 1, size do
                info["defender"]["teams"][i].soldier_num = 0
                info["defender"]["teams"][i].hero_hp = 0
            end
        end
    end

    local function FightResult(unit)
        local teamId = get_teamId(unit)
        local team
        if get_isAttacker(unit) == 0 then
            team = info["defender"]["teams"][teamId]
        else
            team = info["attacker"]["teams"][teamId]
        end
        if get_isHero(unit) == 1 then
            team.hero_hp = get_hp(unit)
        else
            team.soldier_num = team.soldier_num + 1
        end
    end
    
    info["frames"] = stage_frames()
    info["result"] = result
    info["time"] = info["frames"] * gNextTime / FTPS
    if result == 1 then
        ResetFight()
        effect_all(1, FightResult)
    elseif result == 2 then
        ResetFight()
        effect_all(0, FightResult)
    end 
end

local function get_tile_pos(people, startRow, startCol, soldierCount)
    local currentCount = 0
    local tpos = {} 
    for i = 1, soldierCount do
        local pos = {}
        pos._TileX = startRow + ZHEN_XING_PEO[people][i][1]
        pos._TileY = startCol + ZHEN_XING_PEO[people][i][2]
        table.insert(tpos, pos)
    end
    return tpos
end

local function init_soldier(render, attacker, team, hero, id, ap, a_speed, hp, maxhp, x, y)
    local max = CharacterDataManager[id].ad
    local min = CharacterDataManager[id].adm
    local type = CharacterDataManager[id].type2
    local interval = 100 / a_speed * FTPS
    local speed = CharacterDataManager[id].ms / 3000
    local w = CharacterDataManager[id].w
    local h = CharacterDataManager[id].l
    local lx = CharacterDataManager[id].lookZoneX
    local ly = CharacterDataManager[id].lookZoneY

    local skillId = CharacterDataManager[id].skill1
    local actorType = CharacterDataManager[id].type3
    local skillPosId = SkillDataManager[skillId].pos
    if hp <= 0 then
        return 
    end
    local unit = add_unit(attacker, hero, id, x, y)
    set_id(unit, id)
    set_attack(unit, ap)
    set_hp(unit, hp)
    if maxhp == 0 then
        set_maxhp(unit, hp)
    else
        set_maxhp(unit, maxhp)
    end
    set_isHero(unit, hero)
    set_isAttacker(unit, attacker)
    set_teamId(unit, team)
    set_skillId(unit, skillId)
    set_actorType(unit, actorType)
    set_skillPosId(unit, skillPosId)
    set_skillPosCol(unit, SkillPosDataManager[skillPosId].x)
    set_skillPosRow(unit, SkillPosDataManager[skillPosId].y)
    
    unit_attack_info(unit, max, max, min, min, interval)
    unit_body_info(unit, w, h, speed)
    unit_search_info(unit, lx, 100, TILE_SHERCH)
    if render then
        ActorEntityManager:CreateEntity(unit, id, attacker == 1, gOffBottomX, gOffBottomY)
    end
    return unit;
end

local function init_builder(attacker, hero, id, hp, x, y)

    local unit = add_unit(attacker, hero, id, x, y)
    unit_attack_info(unit, 0, 0, 0, 0, 0)
    unit_body_info(unit, 8, 100, 0)
    unit_search_info(unit, 0, 0, 0)
    set_hp(unit, hp)
    set_maxhp(unit, hp)
    return unit;
end

local function init_team(render, attacker, team, team_index)
    local row = team.x + 4
    local col
    if attacker == 1 then
        col = team.y + 6
    else
        col = TILE_COL_COUNT - team.y - 7
    end

    init_soldier(render, attacker, team_index, 1, team.hero_id, team.hero_attack, team.hero_attack_speed, team.hero_hp, team.hero_hp_max, col, row);

    local people = CharacterDataManager[team.soldier_id].peo
    local poss = get_tile_pos(people, team.x, team.y, team.soldier_num)
    for j = 1, team.soldier_num do
        local row = poss[j]._TileX
        local col
        if attacker == 1 then
            col = poss[j]._TileY
        else
            col = TILE_COL_COUNT - poss[j]._TileY - 1
        end
        init_soldier(render, attacker, team_index, 0, team.soldier_id, team.soldier_attack, team.soldier_attack_speed, team.soldier_hp, 0, col, row)
    end
end

local function init_fight(render, attacker, defender)
    for i = 1, #attacker do
        init_team(render, 1, attacker[i], i)
    end

    for i = 1, #defender do
        init_team(render, 0, defender[i], i)
    end

    local function start(unit)
        unit_state(unit, FIGHT_STATE_MOVE)
    end
    effect_all(0, start)
    effect_all(1, start) 
end

local function OpenUIFight(type)
    if GameGlobal:GetGameLevel() == nil or GameGlobal:GameLevelState() ~= 4 then
        GameGlobal:GetUISystem():OpenUI(UIType.UIType_BattleUI, type)
    end
end

function EndFight()
    if gEntryID ~= nil then
        ActorEntityManager:DestroyAllEntity()
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(gEntryID)
        stage_destroy()
        gEntryID = nil 
    end
end

-- 1 att 2 def -- 3 error
local function UpdateFight()
    if not g_pause then
        local result = stage_loop(true)
        if result == 1 or result == 2 then
            EndFight()
            if gEnterPve then 
                GameGlobal:GetGameLevel()._Finished = true
                SendMsg(PacketDefine.PacketDefine_StageEnd_Send, {result == 1 and 1 or 0})
            else
                if GameGlobal:GlobalLevelState() == 3 then
                    DispatchEvent(GameEvent.GameEvent_UIBattle_BattleResult, {battleResult = result == 1 and 1 or 0, round = 0})
                end
            end
        end
    end
end

local function GetSoldierRelation(unit, target)
    local FactorDataManager = SoldierRelationDataManager
    local factor = 1
    local selfType = 0
    local destType = 0
    selfType = CharacterDataManager[get_id(unit)].type3
    destType = CharacterDataManager[get_id(target)].type3
    if selfType > 3 or destType > 3 or destType < 1 or selfType < 1 then
        return 1
    end
    local factor = FactorDataManager[selfType][tostring(destType)]
    return factor
end

local function calc_damage(unit, target)
    local hp = get_hp(target) - get_attack(unit) * (gEnterPve and 1 or GetSoldierRelation(unit, target))
    --print(unit_id(target), get_attack(unit), GetSoldierRelation(unit, target), get_hp(target), "===>", get_attack(unit) * GetSoldierRelation(unit, target), hp)
    if hp <= 0 then
        set_hp(target, 0)
        unit_state(target, FIGHT_STATE_DEATH)
    else
        set_hp(target, hp)
    end
    
    if gEnterPve then
        if get_id(target) < 3 then
            DispatchEvent(GameEvent.GameEvent_BuildHPChange, {guid = get_id(target), Hp = hp, maxHp = get_maxhp(target)})
        end
    end
end

local function calc_skill_damage(skillHurt, target)
    local hp = get_hp(target) - skillHurt
    local hurtValue = 0
    if get_hp(target) >= skillHurt then
        hurtValue = skillHurt
    else
        hurtValue = get_hp(target)
    end
    --print(unit_id(target), get_attack(unit), GetSoldierRelation(unit, target), get_hp(target), "===>", get_attack(unit) * GetSoldierRelation(unit, target), hp)
    if hp <= 0 then
        set_hp(target, 0)
        unit_state(target, FIGHT_STATE_DEATH)
    else
        set_hp(target, hp)
    end 
    return hurtValue
end

local function check_damage(unit, target)
    local skillId = get_skillId(unit) 
    local actorType = get_actorType(unit) 
    local skillPosId = get_skillPosId(unit) 
    if skillPosId ~= 12 then
        local offcol = (get_skillPosCol(unit)  - 1) / 2
        local offrow = (get_skillPosRow(unit)  - 1) / 2
        local isAttack = unit_side(unit) == 0 and true or false
        local col, row = unit_cpos(target)
        local function calc_damage_each(target_each)
            calc_damage(unit, target_each)
        end
        effect_range(isAttack, col - offcol,  row - offrow, col + offcol, row + offrow, calc_damage_each)
    else
        calc_damage(unit, target)
    end
end

local function CallBackFight(unit , uid, type, frame, state, target, x, y, dir)
    if state == FIGHT_STATE_ATTACK then
        check_damage(unit, target) 
    end
    
    if x ~= nil then
        ActorEntityManager:UpdateEntity(unit, state, target, x, y, gEnterPve)  
    elseif gOpenTick then
        ActorEntityManager:UpdateEntityState(unit, state)
    end
end 

function CalculateFightInfo(info, render)
    libfight_init(SCENE_WIDTH, SCENE_HEIGHT, TILE_WIDTH_HEIGHT, 5, 5)
    gEnterPve = false
    local attacker = info["attacker"]["teams"]
    local defender = info["defender"]["teams"]

    if not render then
        stage_create(SCENE_WIDTH, SCENE_HEIGHT, info["seed"])
        init_fight(render, attacker, defender)
        unit_update_callback(CallBackFight)
        local result = 0
        while(result == 0) do
            result = stage_loop(false)
        end
        calc_result(info, result)
        stage_destroy()
        return info;
    end

    EndFight() 
    OpenUIFight(-2)

    stage_create(SCENE_WIDTH, SCENE_HEIGHT, info["seed"])
    init_fight(render, attacker, defender)
    unit_update_callback(CallBackFight)

    local skip = info["time"];
    if skip and skip > 0 then
        gOpenTick = true
        local tick = 0
        while(tick < skip) do
            stage_loop()
            tick = tick + 1
        end
        gOpenTick = false
        ActorEntityManager:DestroyDeathEntity()
    end
    gEntryID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(UpdateFight, 0, false)
end

function Fight:setPvePause(state)
    g_pause = state
end

function Fight:addPveUnit(isattack, ishero, hero_id, level, col, row, cuslevel)
    local team = {}
    gEnterPve         = true
    if gEntryID == nil then
        libfight_init(SCENE_WIDTH + 160, SCENE_HEIGHT, TILE_WIDTH_HEIGHT, 5, 5)
        stage_create(SCENE_WIDTH + 160, SCENE_HEIGHT, os.time())
        gEntryID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(UpdateFight, 0, false)
        unit_update_callback(CallBackFight)
        --GameGlobal:GetCustomDataManager()[cuslevel].hp
        local unit = init_builder(1, 0, 0, GameGlobal:GetCustomDataManager()[cuslevel].hp, 0, 10)
        unit_state(unit, FIGHT_STATE_STAY)
        local unit = init_builder(0, 0, 0, GameGlobal:GetCustomDataManager()[cuslevel].hp, 90, 10)
        unit_state(unit, FIGHT_STATE_STAY)
    end
    local CharacterTableData = GameGlobal:GetCharacterDataManager()[hero_id]
    if isattack == 1 then
        local serverData
        if CharacterTableData.type == CharacterType.CharacterType_Soldier then
            serverData = GameGlobal:GetCharacterServerDataManager():GetSoldier(hero_id)
        else
            serverData = GameGlobal:GetCharacterServerDataManager():GetLeader(hero_id)
        end 
        team["hero_hp"] = serverData._Hp
        team["hero_attack"] = serverData._Attack
        team["hero_attack_speed"] = serverData._AtkSpeed
    else
        team["hero_hp"] = CharacterTableData.hp + CharacterTableData.hpup * (level - 1)
        team["hero_attack"] = CharacterTableData.attack + CharacterTableData.attackup * (level - 1)
        team["hero_attack_speed"] = CharacterTableData.attackSpeed
    end 
    local unit = init_soldier(true, isattack, 0, ishero, hero_id, team.hero_attack, team.hero_attack_speed, team.hero_hp, 0, col, row)
   
    unit_state(unit, FIGHT_STATE_MOVE)
    ActorEntityManager:CreateEntity(unit, hero_id, isattack == 1, 0, gOffBottomPveY)
    return unit
end

function Fight:calc_skill_damage(unit, hurt, col , row, w, h, buff)
    local total = 0
    local function calc_damage_each(target_each)
        total = total + calc_skill_damage(hurt, target_each)
    end
   
    ActorEntityManager:SetEntityBuff(unit, buff)
    effect_range(false, col - (w - 1) / 2,  row - (h - 1) / 2, col + (w - 1) / 2, row + (h - 1) / 2, calc_damage_each)
    return total
end

function Fight:addPveBossUnit(isattack, ishero, hero_id, level, col, row)
    local team = {}
    gEnterPve         = true
    if gEntryID == nil then
        libfight_init(SCENE_WIDTH + 160, SCENE_HEIGHT, TILE_WIDTH_HEIGHT, 5, 5)
        stage_create(SCENE_WIDTH + 160, SCENE_HEIGHT, os.time())
        gEntryID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(UpdateFight, 0, false)
        unit_update_callback(CallBackFight)
    end
    local CharacterTableData = GameGlobal:GetCharacterDataManager()[hero_id] 
    if isattack == 1 then
        local serverData
        if CharacterTableData.type == CharacterType.CharacterType_Soldier then
            serverData = GameGlobal:GetCharacterServerDataManager():GetSoldier(hero_id)
        else
            serverData = GameGlobal:GetCharacterServerDataManager():GetLeader(hero_id)
        end 
        team["hero_hp"] = serverData._Hp
        team["hero_attack"] = serverData._Attack
        team["hero_attack_speed"] = serverData._AtkSpeed
    else
        team["hero_hp"] = CharacterTableData.hp + CharacterTableData.hpup * (level - 1)
        team["hero_attack"] = CharacterTableData.attack + CharacterTableData.attackup * (level - 1)
        team["hero_attack_speed"] = CharacterTableData.attackSpeed
    end 
    local unit = init_soldier(true, isattack, 0, ishero, hero_id, team.hero_attack, team.hero_attack_speed, team.hero_hp, 0, col, row)

    unit_state(unit, FIGHT_STATE_MOVE)
    ActorEntityManager:CreateEntity(unit, hero_id, isattack == 1, gOffBottomX, gOffBottomY)

end
