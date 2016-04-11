local GameFormation = class("GameFormation") 

function GameFormation:ctor()
    self._TableData = {}
    self._WuJiangTableID = 0
    self._WuJiangAttack = 0
    self._WuJiangAttackSpeed = 0
    self._WuJiangHP = 0
    self._WuJiangCurHP = 0

    self._SoldierTableID = 0
    self._SoldierAttack  = 0
    self._SoldierAttackSpeed = 0
    self._SoldierHP  = 0
    self._SoldierNum = 0
    self._SoldierCurNum  = 0
    self._ZhenXingStartRow = 0
    self._ZhenXingStartCol = 0
end


FormationManager = class("FormationManager")
local TILE_ROW_COUNT = 25
local TILE_COL_COUNT = 40
local _Instance

function FormationManager:ctor()
    self._AttackFormationList = {}
    self._DefenderFormationList = {}
    
    self._AttackFormationCalculate = {}
    self._DefenderFormationCalculate = {}
end

function FormationManager:GetInstance()
    if _Instance == nil then
        _Instance = FormationManager.new()
    end
    return _Instance
end

function FormationManager:Create(type, data)
    local formation = GameFormation.new()
    formation._TableData = data
    formation._WuJiangTableID = data[1]
    formation._WuJiangAttack = data[2]
    formation._WuJiangAttackSpeed = data[3]
    formation._WuJiangHP = data[4]
    formation._WuJiangCurHP = data[5]

    formation._SoldierTableID = data[6]
    formation._SoldierAttack = data[7]
    formation._SoldierAttackSpeed = data[8]
    formation._SoldierHP = data[9]
    formation._SoldierNum = data[10]
    formation._SoldierCurNum = data[11]
    
    formation._ZhenXingStartRow = data[12]
    formation._ZhenXingStartCol = data[13]
    return formation
end

function FormationManager:AttackFormationCalculate(list)
    if list ~= nil then
        self._AttackFormationCalculate = list
    end
    return self._AttackFormationCalculate
end

function FormationManager:DefenderFormationCalculate(list)
    if list ~= nil then
        self._DefenderFormationCalculate = list
    end
    return self._DefenderFormationCalculate
end

function FormationManager:AttackFormationList(list)
    if list ~= nil then
        self._AttackFormationList = list
    end
    return self._AttackFormationList
end

function FormationManager:DefenderFormationList(list)
    if list ~= nil then
        self._DefenderFormationList = list
    end
    return self._DefenderFormationList
end