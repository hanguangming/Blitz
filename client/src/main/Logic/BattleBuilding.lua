----
-- 文件名称：BattleBuilding.lua
-- 功能描述：战斗场景中两边的城池 (特殊的角色，拥有血量，可被攻击),需要重写所有的接口
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-5-6
local Character = require("main.Logic.Character")

BattleBuilding = class("BattleBuilding", Character)
local DispatchEvent = DispatchEvent
--构造
function BattleBuilding:ctor()
    Character.ctor(self)
end

function BattleBuilding:Init()
    --print("BattleBuilding:Init ")
    --TODO:配置
    self._TotalHP = 0
    self._CurrentHP = 0
    self._CharacterType = CharacterType.CharacterType_Building
    self:SetState(CharacterState.CharacterState_Invalid)
end
--销毁
function BattleBuilding:Destroy()

end
--设置状态
function BattleBuilding:SetState(state)
    self._CurrentState = state
end
--帧更新
function BattleBuilding:Update()
    return
end

-------------------------------------------------set get------------------------------------------------
--获取根节点
function BattleBuilding:GetCharacterNode()
    return nil
end

--获取状态
function BattleBuilding:GetCharacterState()
    return self._CurrentState
end

--位置
function BattleBuilding:SetPosition(x, y)
    self._CharacterPositionX = x
    self._CharacterPositionY = y
end

----是否敌方设置
function BattleBuilding:IsEnemy(isEnemy)
    self._IsEnemy = isEnemy
end

--总血量设定
function BattleBuilding:SetBuildingTotalHP(hp)
    self._TotalHP = hp
end
--设置朝向 dirX: 1:右 -1:左
function BattleBuilding:SetDirectonX(dirX)
    
end
--ID
function BattleBuilding:SetClientGUID(guid)
    self._ClientID = guid
end
--Get ID
function BattleBuilding:GetClientGUID()
    return self._ClientID
end
--设置 当前血量
function BattleBuilding:SetCurrentHP(hp)
    if hp ~= self._CurrentHP then
        self._CurrentHP = hp
        --DispatchEvent(GameEvent.GameEvent_BuildHPChange, {guid = self._ClientID })
        if self._CurrentHP <= 0 then
            self:SetState(CharacterState.CharacterState_Dead)
        end
    end
end
--获取 当前血量
function BattleBuilding:GetCurrentHP()
    return self._CurrentHP
end

return BattleBuilding

