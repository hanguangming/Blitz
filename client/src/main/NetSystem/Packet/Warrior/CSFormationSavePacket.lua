----
-- 文件名称：CSFormationSavePacket.lua
-- 功能描述：重新登录包
-- 文件说明：重新登录包
-- 作    者：田凯
-- 创建时间：2015-9-17
--  修改

--包定义
local CSFormationSavePacket = class("CSFormationSavePacket", PacketBase)
CSFormationSavePacket._PacketID = PacketDefine.PacketDefine_FormationSave_Send

--构造函数
local SaveZhenXingData = class("SaveZhenXingData")
function SaveZhenXingData:ctor()
    --武将ID
    self._WuJiangTableID = 0
    --士兵ID
    self._SoldierTableID = 0
    --位置
    self._TileRow = 0
    self._TileCol = 0
end

--构造函数
function CSFormationSavePacket:ctor()
    self.super.ctor(self)
    self._PacketID = CSFormationSavePacket._PacketID
    
    --数据格式
    self._SaveData = {}
    --阵型数
    self._MaxZhenXing = 3
    --最大数目
    self._MaxWuJiangCount = 20
    --阵型改动标识
    self._ChangeIdentify = {[1] = 0, [2] = 0, [3] = 0}
end

function CSFormationSavePacket:init(data)
    self._Index = data[1]
end

function CSFormationSavePacket:Write()
    self:WritePacketContentID()
    --计算阵型数
    local zhenXingNum = 0
    --[[
    for i = 1, self._MaxZhenXing do
        for j = 1, self._MaxWuJiangCount do
            local newData = self._SaveData[i]._Data[j]
            if newData._WuJiangTableID ~= 0 then
                zhenXingNum = zhenXingNum + 1
            end
            break
        end
    end
    --]]
    --包的其它字段
    --zhenXingNum = 0
    for i = 1, 3 do
        if self._ChangeIdentify[i] == 1 then
            zhenXingNum = zhenXingNum + 1
        end
    end
    dump(self._ChangeIdentify)
    print(zhenXingNum)
    self._ContentStream:writeInt(zhenXingNum)
    for i = 1, self._MaxZhenXing do
        --计算武将数
        local wuJiangNum = 0
        for j = 1, self._MaxWuJiangCount do
            local newData = self._SaveData[i]._Data[j]
            if newData._WuJiangTableID == 0 then
                break
            end
            wuJiangNum = wuJiangNum + 1
        end
        if wuJiangNum ~= 0 then
            if self._ChangeIdentify[i] == 1 then
                --当前阵型
                self._ContentStream:writeByte(i - 1)
                self._ContentStream:writeInt(wuJiangNum)
                for j = 1, self._MaxWuJiangCount do
                    local newData = self._SaveData[i]._Data[j]
                    if newData._WuJiangTableID == 0 then
                        break
                    end
                    self._ContentStream:writeInt(newData._WuJiangTableID)
                    self._ContentStream:writeInt(newData._SoldierTableID)
                    self._ContentStream:writeInt(newData._TileRow)
                    self._ContentStream:writeInt(newData._TileCol)
                    --print("=======send Data ", i, j, newData._WuJiangTableID, newData._SoldierTableID, newData._TileRow, newData._TileCol)
                end
            end
        end
    end
    --]]
    --最终数据流(包长|包ID|内容)
    self:WritePacketLength()
    self:WritePacketContent()
end

function CSFormationSavePacket:Read(byteStream)
    self.super.Read(self, byteStream)
    if self._IntResult == 0 then
        self._IntResult = byteStream:readInt()
    end
end

--重置数据
function CSFormationSavePacket:ResetData()
    self._SaveData = {}
    for i = 1, self._MaxZhenXing do
        self._SaveData[i] = {}
        self._SaveData[i]._Name = ""
        self._SaveData[i]._Data = {}
        --阵形数据
        for j = 1, self._MaxWuJiangCount do
            local newData = SaveZhenXingData.new()
            newData._WuJiangTableID = 0
            newData._SoldierTableID = 0
            newData._TileRow = 0
            newData._TileCol = 0
            self._SaveData[i]._Data[j] = newData
        end
    end
end

-------------------------------------------------------- new code ----------------------------------------

--包处理
function CSFormationSavePacket:Execute()
    print(self.__cname, self._IntResult) 
end

--不要忘记最后的return
return CSFormationSavePacket