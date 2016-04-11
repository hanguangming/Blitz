----
-- 文件名称：GameGlobal.lua
-- 功能描述：游戏中全局变量
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-5-29
--  修改：
--全局变量初始化
--
require("main.Utility.ArtResourceUtility")
require("main.Utility.Json")
require("main.Utility.LogSystem")
require("main.Utility.Utility")
require("main.fight.GameFormation")
require("main.fight.Fight")

local NetSystem = require("main.NetSystem.NetSystem")
local TimerManager = require("main.Utility.Timer")
local UISystem = require ("main.UI.UISystem")

local Game = nil
GameGlobal = {}

function GameGlobal:GetGameInstance()
    if Game == nil then
        Game = require ("main.Game")
    end
    return Game
end

local TableDataManager = require ("main.DataPool.TableDataManager")
--获取数据表管理器
function GameGlobal:GetDataTableManager()
    return TableDataManager
end

local GamePlayerDataManager = require ("main.ServerData.GamePlayerDataManager")
local GlobalDataManager = require ("main.ServerData.GlobalDataManager")
local CharacterServerDataManager = require("main.ServerData.CharacterServerDataManager")
local ItemDataManager = require("main.ServerData.ItemDataManager")
local TalkDataManager = require("main.ServerData.TalkDataManager")
local MailServerDataManager = require("main.ServerData.MailServerDataManager")
local BattleServerDataManager = require("main.ServerData.BattleServerDataManager")
local GuoZhanServerDataManager = require("main.ServerData.GuoZhanServerDataManager")
--关卡进入服务端返回数据
local EnterCustomDataManager = require("main.ServerData.EnterCustomDataManager")
local TechnologyDataManager = require("main.ServerData.TechnologyDataManager")

--获取 UISystem
function GameGlobal:GetUISystem()
    return UISystem
end

--玩家信息数据管理器
function GameGlobal:GetGamePlayerDataManager()
    return GamePlayerDataManager
end
--
function GameGlobal:GetCharacterServerDataManager()
    return CharacterServerDataManager
end

function GameGlobal:GetServerTechnologyDataManager()
    return TechnologyDataManager
end

function GameGlobal:GetGuoZhanServerDataManager()
    return GuoZhanServerDataManager
end

function GameGlobal:GetItemDataManager()
    return ItemDataManager
end

function GameGlobal:GetTalkDataManager()
    return TalkDataManager
end

--邮件数据
function GameGlobal:GetMailServerDataManager()
    return MailServerDataManager
end

gEquipTable = nil
gEquipCostTable = nil

function GameGlobal:GetEquipDataManager()
    if gEquipTable == nil then
        gEquipTable = {}
        local equip =  TableDataManager:GetEquipDataManager()
        for _, v in pairs(equip) do
            if gEquipTable[tonumber(v.id)] == nil then
                gEquipTable[tonumber(v.id)] = {}
            end
            gEquipTable[tonumber(v.id)][v.lv] = v
        end
    end
    return gEquipTable
end

function GameGlobal:GetEquipCostDataManager()
    if gEquipCostTable == nil then
        gEquipCostTable = {}
        local equip =  TableDataManager:GetEquipCostDataManager()
        for _, v in pairs(equip) do
            if gEquipCostTable[tonumber(v.type)] == nil then
                gEquipCostTable[tonumber(v.type)] = {}
            end
            gEquipCostTable[tonumber(v.type)][v.lv] = v
        end
    end
    return gEquipCostTable
end

GameGlobal:GetEquipCostDataManager()
GameGlobal:GetEquipDataManager() 

function GameGlobal:GetExchangeDataManager()
    return TableDataManager:GetExchangeDataManager()
end

--经验表
function GameGlobal:GetExpDataManager()
    return TableDataManager:GetExpDataManager()
end
--关卡表
function GameGlobal:GetCustomDataManager()
    return TableDataManager:GetCustomTableDataManager()
end
--关卡内某一类型的关卡
function GameGlobal:GetTypeCustomDataManager(type)
    return TableDataManager:GetTypeCustom(type)
end

--关卡boss表
function GameGlobal:GetCustomPVPDataManager()
    return TableDataManager:GetPVPDataManager()
end


function GameGlobal:GameLevelState(state)
    local currentLevel = gGameLevel
    if state == nil and currentLevel ~= nil then
        return currentLevel._LevelLogicType
    end
    currentLevel._LevelLogicType = state 
end

function GameGlobal:GlobalLevelState(state)
    if state then
        gState = state
    end 
    return gState
end

function GameGlobal:GetGameLevel()
    return gGameLevel
end

function GameGlobal:GetTipDataManager(key)
    return TableDataManager:GetTipDataManager(key)
end

function GameGlobal:GetFactorDataManager()
    return TableDataManager:GetSoldierRelationDataManager()
end

function GameGlobal:GetWarriorIDList()
    return TableDataManager:GetWarriorIDList()
end

function GameGlobal:GetRechargeDataManager()
    return TableDataManager:GetRechargeDataManager()
end

function GameGlobal:GetSoliderIDList()
    return TableDataManager._SoliderData
end

function GameGlobal:GetVipDataManager()
    return TableDataManager:GetVipDataManager()
end
--玩家进入关卡数据
function GameGlobal:GetEnterCustomDataManager()
    return EnterCustomDataManager
end
--关卡奖励数据
function GameGlobal:GetCustomRewardDataManager()
    return TableDataManager:GetCustomRewardDataManager()
end
--道具表
function GameGlobal:GetPropDataManager()
    return TableDataManager:GetPropDataManager()
end
--角色信息表
function GameGlobal:GetCharacterDataManager()
     return TableDataManager:GetCharacterDataManager()
end
--战斗数据管理器
function GameGlobal:GetBattleServerDataManager()
    return BattleServerDataManager
end

function GameGlobal:GetSkillDataManager()
    return TableDataManager:GetSkillDataManager()
end

function GameGlobal:GetSkillPosDataManager()
    return TableDataManager:GetSkillPosDataManager()
end

function GameGlobal:GetWorldMapTableDataManager()
    return TableDataManager:GetWorldMapTableDataManager()
end

function GameGlobal:GetChangeDataManager()
    return TableDataManager:GetChangeDataManager()
end

function GameGlobal:GetSkillBuffTableDataManager()
    return TableDataManager:GetSkillBuffTableDataManager()
end

--获取NetSystem
function  GameGlobal:GetNetSystem()
    return NetSystem
end

function  GameGlobal:GetNpcDataManager()
    return TableDataManager:GetNpcDataManager()
end

function  GameGlobal:GetParameterDataManager()
    return TableDataManager:GetParameterDataManager()
end

function GameGlobal:GetTimerManager()
    return TimerManager
end

function GameGlobal:GetTechnologyDataManager()
    return TableDataManager:GetTechnologyDataManager()
end

function GameGlobal:GetTaskDataManager()
    return TableDataManager:GetTaskDataManager()
end

function GameGlobal:GetFeatDataManager()
    return TableDataManager:GetFeatDataManager()
end

function GameGlobal:GetShopDataManager()
    return TableDataManager:GetShopDataManager()
end

function GameGlobal:GetRandomNameDataManager()
    return TableDataManager:GetRandomNameDataManager()
end

local MsgEvent = {}
-- send message
function SendMsg(msg, data, event)
    local netSystem = GetNetSystem()
    local newTestPacket = netSystem:GetMsgPacket(msg)
    if data ~= nil and newTestPacket ~= nil then
        newTestPacket._objData = data
        newTestPacket:init(data)
    end
    if MsgEvent[msg] == nil then
        netSystem:SendPacket(newTestPacket)
        MsgEvent[msg] = event
    end
end

function SendLoginMsg(msg, data)
    local netSystem = GetNetSystem()
    local newTestPacket = netSystem:GetMsgPacket(msg)
    if data ~= nil and newTestPacket ~= nil then
        newTestPacket._objData = data
        newTestPacket:init(data)
    end
   
    if  netSystem._Socket ~= nil and netSystem._Socket.name == "game" then
    else
        netSystem:CheckLoginConnect()
        netSystem:SendPacket(newTestPacket)
    end
end

function SendMapMsg(msg, data, event)
    local netSystem = GetNetSystem()
    local newTestPacket = netSystem:GetMsgPacket(msg)
    if data ~= nil and newTestPacket ~= nil then
        newTestPacket._objData = data
        newTestPacket:init(data)
    end
    if MsgEvent[msg] == nil then
        netSystem:SendMapPacket(newTestPacket)
        MsgEvent[msg] = event
    end
end

function RemoveMsg(msg)
    if MsgEvent[msg] ~= nil then
        MsgEvent[msg] = nil
    end
end

function GetPlayer()
    local gamePlayerDataManager = GameGlobal:GetGamePlayerDataManager()
    local myselfData = gamePlayerDataManager:GetMyselfData()
    return myselfData
end

function GetGlobalData()
    local object = GlobalDataManager:GetInstacneData()
    return object
end

---测试新添加的Timer
function GameGlobal.TestFunction()
    --printInfo("TestFunction one second " )
end
ActorEntityManager = require("main.fight.ActorEntityManager")

local newTimerID = TimerManager:AddTimer(1, GameGlobal.TestFunction)
