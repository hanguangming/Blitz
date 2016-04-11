--GloblDataManager.lua

local GlobalDataManager = class("GloblDataManager")
-- 聊天数据
local GlobalData = class("GlobalData")

g_ServeList = {}
g_ServerLoginIP = 0
g_ServerLoginPort = 0
g_PlayerName = ""
g_CountryID = 0
gCurUseHufuNum = 0
gcity = 0
gUid = 0
gSessionKey = 0 
-- 存储所有新建csb文件的数组
gAllCsbNodeList = {}
g_customPass = {}
gJudianList = {}
gMapImageList = {}
gGameLevel = nil 
 
function GlobalData:ctor(tableID)
    self._SmeltTime = {}
    self._SmeltEquip = {}
    self._RecruitTime = {}
    self._TrainTime = {}
    self._RecruitList = {}
    self._TechnologyList = {}
    self._TaskData = {}
    self._BroadData = {}
    self._BuidId = {}
end

function GlobalData:removeTaskByID(id)
    for i, v in pairs(self._TaskData) do
        if id == v[1] then
            table.remove(self._TaskData, i)
        end
    end
end

function GlobalData:updateTaskByID(data)
    for i, v in pairs(self._TaskData) do
        if data[1] == v[1] then
            self._TaskData[i] = data 
            return 
        end
    end
    table.insert(self._TaskData, data)
end

function GlobalDataManager:GetInstacneData()
    if self._GlobalData == nil then
        self._GlobalData = GlobalData.new()
    end
    return self._GlobalData
end

-- 管理器
function GlobalDataManager:ctor()
   self._GlobalData = nil 
end

local gGlobalDataManager = GlobalDataManager:new()

function GlobalDataManager:GetGloblDataManager()
    return gGlobalDataManager
end

return GlobalDataManager