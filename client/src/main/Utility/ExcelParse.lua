
-- 文件名称：ExcelParse
-- 功能描述：解析excel数据表
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-4-30
--  修改：新的表格读取方式，使用ExcelParseNew,后面的表改用 ExcelParseNew   2.15-6-16
-- 
--cocos2d环境
require("main.Utility.Utility")

local function getFileContent(fileName)
    local fileContent = ""
    --
    if not home_dir then
        local fileUtils = cc.FileUtils:getInstance()
        fileContent = fileUtils:getStringFromFile(fileName)
        --fileContent = string.gsub(fileContent, '\r', "")
    else
        local data_dir = home_dir() .. "/client/res/"
        local fd,err = io.open(data_dir..fileName,"r")
        if fd ~= nil then
            local data = fd:read("*all")
            if data ~= nil then
                fileContent = data
            end
            io.close(fd)
        end
    end

    fileContent = string.gsub(fileContent, '\r', "")
    return fileContent
end

--fieldTableData 字段定义Table  fieldTableData ~= nil 时，为新的表格调用方式
function ExcelParse(fileName, fieldTableData)
    --Army.txt
    local fileContent = getFileContent(fileName)
    local tablegetn = table.getn

    local linesdata = Split(fileContent,"\n")

    assert(tablegetn(linesdata) >= 4)
    --备注栏
    local rowhead = Split(linesdata[1],"\t")
    local colNumber = tablegetn(rowhead)
    --类型
    local rowtype = Split(linesdata[2],"\t")
    assert(tablegetn(rowtype) == colNumber)
    --字段名
    local colNameTable = Split(linesdata[3],"\t")
    assert(tablegetn(colNameTable) == colNumber)
    --字段替换
    if fieldTableData ~= nil then
        for k, v in pairs(colNameTable)do
            local newValue = fieldTableData[v]
            if newValue ~= nil then
                colNameTable[k] = newValue
            end
        end
    end
    local tableData = {}

    local lineindex = 4
    local tableinsert = table.insert
    while true do
        if linesdata[lineindex] == nil then
            break
        end
        local linedata = Split(linesdata[lineindex],"\t")
        if tablegetn(linedata) ~= colNumber then
            print("ExcelParse linedata error", lineindex, fileName)
        end
        assert(tablegetn(linedata) == colNumber)        

        local linetable = {}    

        local colIndex = 1
        while true do 
            if colIndex > colNumber then
                break
            end

            if rowtype[colIndex] == "number" or  rowtype[colIndex] == "float" then
                linetable[colNameTable[colIndex]] = tonumber(linedata[colIndex])
            else
                local colContent = linedata[colIndex]
                colContent = TrimString(colContent,"\"")
                if colContent ~= nil then
                    linetable[colNameTable[colIndex]] = colContent
                else
                    print("%s nil", colNameTable[colIndex])
                end
            end     
            colIndex = colIndex + 1     
        end

        tableinsert(tableData, tonumber(linedata[1]), linetable)

        lineindex = lineindex + 1
    end
    return  tableData
end


--新的表格解析方式  ExcelParseNew    callback:回调函数
function ExcelParseNew(fileName, fieldTableData, callback, isHaveID)
    local fileContent = getFileContent(fileName)
    local tablegetn = table.getn

    local linesdata = Split(fileContent,"\n")
    local startIndex = 4
    assert(tablegetn(linesdata) >= startIndex)
    --备注栏
   local rowhead = Split(linesdata[1],"\t")
    --字段名
    local colNameTable = Split(linesdata[2],"\t")
    local colNumber = tablegetn(colNameTable)
    --类型  (要求：类型字段数与字段名数目相同)
    local rowtype = Split(linesdata[3],"\t")
    assert(tablegetn(rowtype) == colNumber)

    --字段名称替换（程序中用到的字段名与表格中的字段名部分不一致）
    if fieldTableData ~= nil then
        for k, v in pairs(colNameTable)do
            local newValue = fieldTableData[v]
            if newValue ~= nil then
                colNameTable[k] = newValue
            end
        end
    end
    local tableData = {}

    local lineindex = startIndex
    local tableinsert = table.insert
    while true do
        if linesdata[lineindex] == nil then
            break
        end
        local linedata = Split(linesdata[lineindex],"\t")
        if tablegetn(linedata) ~= colNumber then
            print("ExcelParse linedata error", lineindex, fileName)
        end
        assert(tablegetn(linedata) == colNumber)        

        local linetable = {}    

        local colIndex = 1
        while true do 
            if colIndex > colNumber then
                break
            end

            if rowtype[colIndex] == "number" or  rowtype[colIndex] == "float" then
                linetable[colNameTable[colIndex]] = tonumber(linedata[colIndex])
            else
                local colContent = linedata[colIndex]
                colContent = TrimString(colContent,"\"")
                if colContent ~= nil then
                    linetable[colNameTable[colIndex]] = colContent
                else
                    print("%s nil", colNameTable[colIndex])
                end
            end     
            colIndex = colIndex + 1     
        end

        --tableinsert(tableData, tonumber(linedata[1]), linetable)
        if isHaveID == nil or isHaveID == true then
            local key = tonumber(linedata[1])
            tableData[key] = linetable
        else
            tableinsert(tableData,  linetable)
        end

        lineindex = lineindex + 1
    end
    return  tableData
end
--新的表格解析(老的暂时保留，待全部修改完，再删除老的表格txt)
function ExcelParseVer2(fileName, fieldTableData, callback, isHaveID)
    local fileContent = getFileContent(fileName)
  
    local tablegetn = table.getn

    local linesdata = Split(fileContent,"\n")
    local startIndex = 5
    assert(tablegetn(linesdata) >= startIndex)
    --备注栏
    local rowhead = Split(linesdata[1],"\t")
    --字段名
    local colNameTable = Split(linesdata[3],"\t")
    local colNumber = tablegetn(colNameTable)
    --类型  (要求：类型字段数与字段名数目相同)
    local rowtype = Split(linesdata[2],"\t")
    assert(tablegetn(rowtype) == colNumber)

    --字段名称替换（程序中用到的字段名与表格中的字段名部分不一致）
    if fieldTableData ~= nil then
        for k, v in pairs(colNameTable)do
            local newValue = fieldTableData[v]
            if newValue ~= nil then
                colNameTable[k] = newValue
            end
        end
    end
    local tableData = {}

    local lineindex = startIndex
    local tableinsert = table.insert
    while true do
        if linesdata[lineindex] == nil then
            break
        end
        local linedata = Split(linesdata[lineindex],"\t")
        if tablegetn(linedata) ~= colNumber then
            print("ExcelParse linedata error", lineindex, fileName)
        end
        --assert(tablegetn(linedata) == colNumber)        

        local linetable = {}    

        local colIndex = 1
        while true do 
            if colIndex > colNumber then
                break
            end

            if rowtype[colIndex] == "number" or  rowtype[colIndex] == "float" then
                linetable[colNameTable[colIndex]] = tonumber(linedata[colIndex])
            else
                local colContent = linedata[colIndex]
                colContent = TrimString(colContent,"\"")
                if colContent ~= nil then
                    linetable[colNameTable[colIndex]] = colContent
                else
                    print("%s nil", colNameTable[colIndex])
                end
            end     
            colIndex = colIndex + 1     
        end

        --tableinsert(tableData, tonumber(linedata[1]), linetable)
        if isHaveID == nil or isHaveID == true then
            
            local key = tonumber(linedata[1])
            if key == nil then
                tableData[linedata[1]] = linetable
            else
                tableData[key] = linetable
            end
        else
            tableinsert(tableData,  linetable)
        end

        lineindex = lineindex + 1
    end
    return  tableData
end

function ExcelParseVer3(fileName)
    local fileContent = getFileContent(fileName)
    local tablegetn = table.getn

    local linesdata = Split(fileContent,"\n")
    local startIndex = 5
    assert(tablegetn(linesdata) >= startIndex)
    --备注栏
    local rowhead = Split(linesdata[1],"\t")
    --字段名
    local colNameTable = Split(linesdata[3],"\t")
    local colNumber = tablegetn(colNameTable)
    --类型  (要求：类型字段数与字段名数目相同)
    local rowtype = Split(linesdata[2],"\t")
    assert(tablegetn(rowtype) == colNumber)

    local tableData = {}

    local lineindex = startIndex
    local curLineTable = nil
    local tableIndex = 2
    local tableinsert = table.insert
    while true do
        if linesdata[lineindex] == nil then
            break
        end
        local linedata = Split(linesdata[lineindex],"\t")
        if tablegetn(linedata) ~= colNumber then
            print("ExcelParse linedata error", lineindex, fileName)
        end
        assert(tablegetn(linedata) == colNumber)        

        local linetable = {}    
        local colIndex = 1
        while true do 
            if colIndex > colNumber then
                break
            end
            if rowtype[colIndex] == "number" or  rowtype[colIndex] == "float" then
                linetable[colNameTable[colIndex]] = tonumber(linedata[colIndex])
            else
                local colContent = linedata[colIndex]
                colContent = TrimString(colContent,"\"")
                if colContent ~= nil then
                    linetable[colNameTable[colIndex]] = colContent
                else
                    print("%s nil", colNameTable[colIndex])
                end
            end     
           
            colIndex = colIndex + 1     
        end
        if linedata[1] ~= "" and tonumber(linedata[1]) > 0 then
            local data = {}
            data[1] = linetable
            tableinsert(tableData,linedata[1], data)
            curLineTable = data
        else
            tableinsert(curLineTable, linetable)
        end
        lineindex = lineindex + 1
    end
    return  tableData
end
