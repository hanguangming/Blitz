----
-- 文件名称：EnterCustomDataManager.lua
-- 功能描述：进入关卡服务端返回数据
-- 文件说明：
-- 作    者：刘胜勇
-- 创建时间：2015-7-17
--  修改：

local EnterCustomSelfData = class("EnterCustomSelfData")

--数据结构
--构造函数
function EnterCustomSelfData:ctor()
    --进入结果 1成功 2 失败
    self._Result = nil
    --异或值
    self._Param = nil
    --进入的关卡
    self._Level = nil
end

--数据管理器
local CustomDataManager = class("CustomDataManager")

--构造
function CustomDataManager:ctor()
    --主角玩家信息
    self._MyselfData = nil
    --其它玩家数据

end

--获取主角玩家信息
function CustomDataManager:GetMyselfData()
    if self._MyselfData == nil then
        self._MyselfData = EnterCustomSelfData.new()
    end
    return self._MyselfData
end

return CustomDataManager