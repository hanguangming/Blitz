local Technology = class("Technology")
local TechnologyManager = class("TechnologyManager")

-- 数据结构定义
function Technology:ctor(tableID)
    -- tableID excel中的表格ID
    local TechnologyData = GameGlobal:GetTechnologyDataManager()
    self._TableID = tableID
    self._TableData = TechnologyData[tableID]
    self._State = 0
    self._Count = 0
    self._Value = 0  -- times or time
end

function TechnologyManager:ctor()
    -- 所有科技的数据 key:serverID
    self._AllTechnologyTable = {}
    self._AllTechnologyIDTable = {}
    self._TechnologyCount = 0
end

-- 获取某物品
function TechnologyManager:GetTechnology(tableID)
    for i,v in pairs(self._AllTechnologyTable) do
        if v._TableID == tableID then
            return self._AllTechnologyTable[i]
        end
    end
    return nil
end

-- 获取某物品
function TechnologyManager:SetTechnology(tableID, obj)
    for i,v in pairs(self._AllTechnologyTable) do
        if v._TableID == tableID then
             self._AllTechnologyTable[i] = obj
        end
    end
end

function TechnologyManager:UpdateTechnology(tableID)
    local TechnologyData = GameGlobal:GetTechnologyDataManager()
    local TableData = TechnologyData[tableID]
    if GetGlobalData()._TechnologyList[TableData.valtype] == nil then 
        return
    end
    
    local obj = Technology.new(tableID)

    if TableData.untype1 == 1 then
         if GetGlobalData()._TechnologyList[TableData.valtype][2] == 0 then
            if  GetPlayer()._Level < TableData.unval1 or TableData.unval2 > 0 then
                obj._State = 4
            else
                obj._State = GetGlobalData()._TechnologyList[TableData.valtype][4] >= TableData.count and 1 or 0
            end
         elseif tableID <= GetGlobalData()._TechnologyList[TableData.valtype][2] then
            obj._State = 3
         elseif tableID > GetGlobalData()._TechnologyList[TableData.valtype][2] then
            local TableDataOpen = TechnologyData[GetGlobalData()._TechnologyList[TableData.valtype][2]]
            if  GetPlayer()._Level < TableData.unval1 or GetGlobalData()._TechnologyList[TableData.valtype][2] < TableData.unval2  then
                obj._State = 4
            else
                obj._State = GetGlobalData()._TechnologyList[TableData.valtype][4] >= TableData.count and 1 or 0
            end
         end
    else
        print(GetGlobalData()._TechnologyList[TableData.valtype][2])
        if GetGlobalData()._TechnologyList[TableData.valtype][2] == 0 then
            print(GetPlayer()._MaxLevel,  tonumber(TableData.unval1) - 1000)
            if  GetPlayer()._MaxLevel <= tonumber(TableData.unval1) - 1000 then
                obj._State = 4
            else
                obj._State = GetGlobalData()._TechnologyList[TableData.valtype][4] >= TableData.count and 1 or 0
            end
        elseif tableID <= GetGlobalData()._TechnologyList[TableData.valtype][2] then
            obj._State = 3
        elseif tableID > GetGlobalData()._TechnologyList[TableData.valtype][2] then
            if  GetPlayer()._MaxLevel <= tonumber(TableData.unval1) - 1000 then
                obj._State = 4
            else
                obj._State = GetGlobalData()._TechnologyList[TableData.valtype][4] >= TableData.count and 1 or 0
            end
        end
    end
    
    obj._time =  GetGlobalData()._TechnologyList[TableData.valtype][5]
    obj._Count = GetGlobalData()._TechnologyList[TableData.valtype][4]
    obj._timeEnd =  GetGlobalData()._TechnologyList[TableData.valtype][5] + os.time()
    
    if tableID == GetGlobalData()._TechnologyList[TableData.valtype][3] and GetGlobalData()._TechnologyList[TableData.valtype][5] > 0 then
        obj._State = 2
    end
    if self._AllTechnologyIDTable[tableID] == nil then
        --table.insert(self._AllTechnologyTable, obj)
        self._AllTechnologyTable[tableID] = obj
    else
        self:SetTechnology(tableID, obj)
    end
    
    self._AllTechnologyIDTable[tableID] = tableID
    return obj
end

-- 删除物品
function TechnologyManager:DeleteTechnology(tableID)
    self._AllTechnologyTable[tableID] = nil
end


--获取某一类型的科技数据
function TechnologyManager:GetTechnologyByType(type)
    local techData = nil
    for k, v in pairs(self._AllTechnologyTable)do
        local TechnologyDataManager = GameGlobal:GetDataTableManager():GetTechnologyDataManager()
        local tableData = TechnologyDataManager[k]
        if tableData ~= nil and tableData.techtype == type then
            techData = tableData
            break
        end
    end
    return techData
end

function TechnologyManager:GetTechnologyDataByID(type)
    local TechnologyDataManager = GameGlobal:GetDataTableManager():GetTechnologyDataManager()
    local id = GetGlobalData()._TechnologyList[type][2]
    if id > 0 then
        return TechnologyDataManager[id]
    end
    return nil
end

function TechnologyManager:GetTechMaxPvpById()
    local techData = nil
    for i = 16, 8, -1 do
        if self._AllTechnologyTable[i] ~= nil then
            local TechnologyDataManager = GameGlobal:GetDataTableManager():GetTechnologyDataManager()
            local tableData = TechnologyDataManager[i]
            return tableData
        end
    end
    return nil
end

local DataManager = TechnologyManager:new()

return DataManager