
-- 文件名称：LogSystem.lua
-- 功能描述：日志,写文件的日志
-- 文件说明：该功能只用作调试用,会写入一个文件
-- 作    者：王雷雷
-- 创建时间：2015-9-9
--  修改：

local stringFormat = string.format
LogSystem = 
{
    --日志记录
   _LogTable = {},
   --当前ID
   _CurrentID = 0
}

function LogSystem:WriteLog(info, ...)
    local newInfo = stringFormat( info, ...)
    newInfo = stringFormat("%s %s \n", newInfo, os.date())
    self._CurrentID = self._CurrentID + 1
    self._LogTable[self._CurrentID] = newInfo
end

--清除所有
function LogSystem:Clear()
    self._LogTable = {}
   self._CurrentID = 0
end

--生成日志文件
function LogSystem:Output()
    local currentTime = math.ceil(os.time())
    local fileName = string.format("client_%d.log", currentTime)
    print("fileName ", fileName)
    local file = io.open(fileName, "wb")
    local logLen = #self._LogTable
    for i = 1, logLen do
        file.write(file, self._LogTable[i])
    end
    io.close(file)
end