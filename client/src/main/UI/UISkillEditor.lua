----
-- 文件名称：UISkillEditor.lua
-- 功能描述：技能编辑器
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-6-25
-- 修改 ：

require("main.UI.UIBase")
require("main.UI.UITypeDefine")
require("cocos.ui.GuiConstants")
require("main.Utility.ChineseConvert")
local stringFormat = string.format
local TableDataManager = GameGlobal:GetDataTableManager() 
local CharacterManager = require("main.Logic.CharacterManager")
local SkillManager = require("main.Logic.SkillManager")
--Button_Quit
local UISkillEditor = class("UISkillEditor", UIBase)
--可调整 的参数列表
local paramList = 
{
    --子弹飞行速度
    BulletSpeed = 1,
    --路径类型
    BulletPathType = 2,
    --偏移X
    BulletOffsetX = 3,
    --偏移Y
    BulletOffsetY = 4,
    --触发伤害时间
    TrigerHurt = 5,
    --中间点系数
    BulletMiddleFactor = 6, 
    --运动结束时的特效动画
    MoveEndAnimName = 7,
} 
--参数对应 的控件列表
local nameList = 
{
    [paramList.BulletSpeed] = "TextField_MoveSpeed",
    [paramList.BulletPathType] = "TextField_PathType",
    [paramList.BulletOffsetX] = "TextField_InitOffsetX",
    [paramList.BulletOffsetY] = "TextField_InitOffsetY",
    [paramList.TrigerHurt] = "TextField_TrigerHurtTime",
    [paramList.BulletMiddleFactor] = "TextField_MiddleFactor",
    [paramList.MoveEndAnimName] = "TextField_MoveEndAnim",
}
--构造函数
function UISkillEditor:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_SkillEditor
    self._ResourceName =  "UISkillEditor.csb"
    --参数textField列表
    self._ParamTextFieldList = {}
    --listView
    self._ArmyListView = nil
    --选中显示的输入框
    self._SelectText = nil
    --当前的角色Client ID
    self._CurrentClientID = 0
    --当前角色的TableID
    self._CurrentTableID = 0
    --响应场景点击事件的Panel
    self._PanelClick = 0
    --当前的目标ID
    self._CurrentTargetID = nil
    --武将多选checkBox
    self._CheckBoxWuJiang = nil
end

--Load
function UISkillEditor:Load()
    UIBase.Load(self)
    local quitButton = self:GetUIByName("Button_Quit")
    quitButton:addTouchEventListener(UISkillEditor.OnQuitClick)
    local saveButton = self:GetUIByName("Button_Save")
    saveButton:addTouchEventListener(UISkillEditor.OnSaveClick)
    for i = 1, 7 do
        self._ParamTextFieldList[i] = self:GetUIByName(nameList[i])
        self._ParamTextFieldList[i]:addEventListener(UISkillEditor.OnParamChanged)
    end
    self._ArmyListView = self:GetUIByName("ListView_CharacterList") 
    self._SelectText = self:GetUIByName("TextField_Select")
    self._PanelClick = self:GetUIByName("Panel_Scene")
    self._CheckBoxWuJiang = self:GetUIByName("CheckBox_WuJiangSelect")
    self._CheckBoxWuJiang:addEventListener(UISkillEditor.SelectedStateEvent)
    self._PanelClick:addTouchEventListener(UISkillEditor.OnSceneClick)
end

----Unload
function UISkillEditor:Unload()
    UIBase.Unload(self)
    --
end

--打开
function UISkillEditor:Open()
    UIBase.Open(self)

    local tableData = TableDataManager:GetCharacterDataManager()
    local newTableData = {}
    local index = 1
    for k, v in pairs(tableData)do
        newTableData[index] = k
        index = index + 1
    end
    
    local sortfunction = function( a, b )
        if a ~= 0 and b ~= 0 then
            local valueA = tableData[a]
            local valueB = tableData[b]
            if valueA.type ~= valueB.type then
                return valueB.id > valueA.id
            end
            if valueA.type ==  CharacterType.CharacterType_Soldier  then
                return valueB.id > valueA.id
            end
            if valueB.type == CharacterType.CharacterType_Leader then
                return valueB.resName > valueA.resName
            end
        end
    end
    table.sort( newTableData, sortfunction )
    if self._ArmyListView ~= nil then
        for k, v in pairs(newTableData)do
            local newValue = tableData[v]
            local newText = ccui.Text:create()
            local showStr = stringFormat("%s:%d", newValue.name, newValue.id)
            newText:setString(showStr)
            newText:setFontSize(15)
            newText:setTouchEnabled(true)
            newText:setTag(newValue.id)
            
            newText:addTouchEventListener(UISkillEditor.OnArmyTextClicked)
            local custom_item = ccui.Layout:create()
            custom_item:setContentSize(newText:getContentSize())
            custom_item:addChild(newText)
            newText:setPosition(cc.p(custom_item:getContentSize().width / 2.0, custom_item:getContentSize().height / 2.0))
            self._ArmyListView:pushBackCustomItem(custom_item)
        end
    end
    self._CheckBoxWuJiang:setSelected(false)
end

--关闭
function UISkillEditor:Close()
    UIBase.Close(self)
    --编辑器清理
    self._CurrentClientID = nil
    self._CurrentTargetID = nil
end


-------------------------------------------------------
--点击了场景某位置
function UISkillEditor:OnClickScene(touchPosition)
    if self._CurrentClientID ~= nil and self._CurrentClientID ~= 0 then
        local currentSoldier = CharacterManager:GetCharacterByClientID(self._CurrentClientID)
        local targetCharacter = nil
        local currentGameInstance = GameGlobal:GetGameInstance()
        local gameEditor = currentGameInstance:GetStateInstance(GameState.GameState_SkillEditor)
        local currentLevel = gameEditor:GetGameLevel()
        if self._CurrentTargetID ~= nil then
            targetCharacter = CharacterManager:GetCharacterByClientID(self._CurrentTargetID)
            local destPositon = currentLevel:GetLevelSkillPosition(touchPosition)
            if destPositon ~= nil then
                targetCharacter:SetPosition(destPositon.x, destPositon.y)
            end
        end
        if currentSoldier ~= nil then
            currentSoldier._CharacterTargetClientID = self._CurrentTargetID
            currentSoldier:SetState(CharacterState.CharacterState_Attack)
            --参数使用编辑器的参数
            local currentMoveSpeed = self._ParamTextFieldList[paramList.BulletSpeed]:getString()
            local currentPathType = self._ParamTextFieldList[paramList.BulletPathType]:getString()
            local currentOffsetX = self._ParamTextFieldList[paramList.BulletOffsetX]:getString()
            local currentOffsetY = self._ParamTextFieldList[paramList.BulletOffsetY]:getString()
            local hutTime = self._ParamTextFieldList[paramList.TrigerHurt]:getString()
            local middleFactor = self._ParamTextFieldList[paramList.BulletMiddleFactor]:getString()
            local moveEndAnim = self._ParamTextFieldList[paramList.MoveEndAnimName]:getString()
         --   printInfo("param: %s,%s,%s,%s,%s,%s %s",currentMoveSpeed, currentPathType, currentOffsetX, currentOffsetY, hutTime, middleFactor, moveEndAnim)
            local currentSkill = SkillManager:GetSkillEditorSkill()
            if currentSkill ~= nil then
                currentSkill._BulletMoveSpeed = tonumber(currentMoveSpeed)
                currentSkill._BulletPathType = tonumber(currentPathType)
                currentSkill._MiddleFactor = tonumber(middleFactor)
                currentSkill._AttackAnimLength = tonumber(hutTime)
                currentSkill._InitOffsetX = tonumber(currentOffsetX)
                currentSkill._InitOffsetY = tonumber(currentOffsetY)
                currentSkill._ThrowSkillFinishAnimCSBName = moveEndAnim
                --临时替换
                if currentSkill._SkillTableData.effectFile == "" or currentSkill._SkillTableData.effectFile == "0" then
                    currentSkill._SkillTableData.effectFile = "csb/texiao/pugong/21001.csb"
                end
               
                --更新数据表
                local skillTableID = currentSoldier._CharacterData.skill1
                local attackEffectData = TableDataManager._SkillAttackEffectDataManager[skillTableID]
                if attackEffectData ~= nil then
                    attackEffectData._MoveSpeed = tonumber(currentMoveSpeed)
                    attackEffectData._Path = tonumber(currentPathType)
                    attackEffectData._OffsetX = tonumber(currentOffsetX)
                    attackEffectData._OffsetY = tonumber(currentOffsetY)
                    attackEffectData._HurtHitTime = tonumber(hutTime)
                    attackEffectData._MiddleFactor = tonumber(middleFactor)
                    attackEffectData._EndAnimCSBName = moveEndAnim
                end
               
            end
        end
    end 
end
--选 择了角色
function UISkillEditor:OnClickArmyText(id)
    local currentGameInstance = GameGlobal:GetGameInstance()
    local gameEditor = currentGameInstance:GetStateInstance(GameState.GameState_SkillEditor)
    local currentLevel = gameEditor:GetGameLevel()
    if self._CurrentClientID ~= nil then
        if currentLevel ~= nil then
            currentLevel:RemoveFromSoldiers(self._CurrentClientID)
        end
    end
    local tableDataManager = TableDataManager:GetCharacterDataManager()
    local tableData = tableDataManager[id]
    local showString = stringFormat("%s:%d",tableData.name, tableData.id)
    self._SelectText:setString(showString)

    if currentLevel ~= nil then
        local currentSoldier =  currentLevel:AddSoldier(id)
        if currentSoldier ~= nil then
            currentSoldier:SetPosition(200, 270)
            self._CurrentClientID = currentSoldier:GetClientGUID()
        end
    end
    
    if self._CurrentTargetID == nil then
        local newTargetSoldier = currentLevel:AddEnemySoldier(10001, 1)
        if newTargetSoldier ~= nil then
            newTargetSoldier:SetPosition(480, 270)
            self._CurrentTargetID = newTargetSoldier:GetClientGUID()
        end
    end
    --更新UI参数
    local currentSoldier = CharacterManager:GetCharacterByClientID(self._CurrentClientID)
    local skillTableID = currentSoldier._CharacterData.skill1
    local attackEffectData = TableDataManager._SkillAttackEffectDataManager[skillTableID]
    if attackEffectData ~= nil then
        self._ParamTextFieldList[paramList.BulletSpeed]:setString(tostring(attackEffectData._MoveSpeed))
        self._ParamTextFieldList[paramList.BulletPathType]:setString(tostring(attackEffectData._Path))
        self._ParamTextFieldList[paramList.BulletOffsetX]:setString(tostring(attackEffectData._OffsetX))
        self._ParamTextFieldList[paramList.BulletOffsetY]:setString(tostring(attackEffectData._OffsetY))
        self._ParamTextFieldList[paramList.TrigerHurt]:setString(tostring(attackEffectData._HurtHitTime))
        self._ParamTextFieldList[paramList.BulletMiddleFactor]:setString(tostring(attackEffectData._MiddleFactor))
        self._ParamTextFieldList[paramList.MoveEndAnimName]:setString(attackEffectData._EndAnimCSBName)
    end
end
--设置参数数据(isMultySelect:是否是多选)
function UISkillEditor:SetParamData()
    local isMultySelect = self._CheckBoxWuJiang:isSelected()
    if self._CurrentClientID == nil or self._CurrentClientID == 0 then
        return
    end
    local currentMoveSpeed = self._ParamTextFieldList[paramList.BulletSpeed]:getString()
    local currentPathType = self._ParamTextFieldList[paramList.BulletPathType]:getString()
    local currentOffsetX = self._ParamTextFieldList[paramList.BulletOffsetX]:getString()
    local currentOffsetY = self._ParamTextFieldList[paramList.BulletOffsetY]:getString()
    local hutTime = self._ParamTextFieldList[paramList.TrigerHurt]:getString()
    local middleFactor = self._ParamTextFieldList[paramList.BulletMiddleFactor]:getString()
    local moveEndAnim = self._ParamTextFieldList[paramList.MoveEndAnimName]:getString()
    
    local currentSoldier = CharacterManager:GetCharacterByClientID(self._CurrentClientID)
    if currentSoldier == nil then
        return
    end
    --更新数据表
    if isMultySelect == true then
        local characterFileName = currentSoldier._CharacterData.resName
        local tableData = TableDataManager:GetCharacterDataManager()
        for k, v in pairs(tableData)do
            if v.resName == characterFileName then
                print("multy %d", v.id)
                local skillTableID = v.skill1
                local attackEffectData = TableDataManager._SkillAttackEffectDataManager[skillTableID]
                if attackEffectData ~= nil then
                    attackEffectData._MoveSpeed = tonumber(currentMoveSpeed)
                    attackEffectData._Path = tonumber(currentPathType)
                    attackEffectData._OffsetX = tonumber(currentOffsetX)
                    attackEffectData._OffsetY = tonumber(currentOffsetY)
                    attackEffectData._HurtHitTime = tonumber(hutTime)
                    attackEffectData._MiddleFactor = tonumber(middleFactor)
                    attackEffectData._EndAnimCSBName = moveEndAnim
                   -- printInfo(" apply param: %s,%s,%s,%s,%s,%s %s",currentMoveSpeed, currentPathType, currentOffsetX, currentOffsetY, hutTime, middleFactor, moveEndAnim)
                end
            end
        end
        --printInfo("multy apply param: %s,%s,%s,%s,%s,%s %s",currentMoveSpeed, currentPathType, currentOffsetX, currentOffsetY, hutTime, middleFactor, moveEndAnim)
    else
        local skillTableID = currentSoldier._CharacterData.skill1
        local attackEffectData = TableDataManager._SkillAttackEffectDataManager[skillTableID]
        if attackEffectData ~= nil then
            attackEffectData._MoveSpeed = tonumber(currentMoveSpeed)
            attackEffectData._Path = tonumber(currentPathType)
            attackEffectData._OffsetX = tonumber(currentOffsetX)
            attackEffectData._OffsetY = tonumber(currentOffsetY)
            attackEffectData._HurtHitTime = tonumber(hutTime)
            attackEffectData._MiddleFactor = tonumber(middleFactor)
            attackEffectData._EndAnimCSBName = moveEndAnim
           -- printInfo("single apply param: %s,%s,%s,%s,%s,%s %s",currentMoveSpeed, currentPathType, currentOffsetX, currentOffsetY, hutTime, middleFactor, moveEndAnim)
        end
    end
    
    
    
end
--武将多选单选状态改变 OnSelectStateChange,应用当前参数到多个武将上
function UISkillEditor:OnSelectStateChange()
    local isMultySelect = self._CheckBoxWuJiang:isSelected()
    if self._CurrentClientID ~= nil and self._CurrentClientID ~= 0 then
        local currentSoldier = CharacterManager:GetCharacterByClientID(self._CurrentClientID)
        if currentSoldier ~= nil then
            --self:SetParamData(isMultySelect)
        end
    end
    
end
--退出点击
function UISkillEditor.OnQuitClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local game = GameGlobal:GetGameInstance()
        game:SetGameState(GameState.GameState_Maincity)
        local uiSystem = GameGlobal:GetUISystem()
        uiSystem:CloseUI(UIType.UIType_SkillEditor)
        --保存数据成.Lua代码文件
        local saveTableData = TableDataManager._SkillAttackEffectDataManager
        if saveTableData ~= nil then
            local fileUtils = cc.FileUtils:getInstance()
            local fileName = "src/main/DataPool/SkillAttackEffect.lua"--fileUtils:fullPathForFilename("src/main/DataPool/SkillAttackEffect.lua")
            print("fileName = " .. fileName)
            local file = io.open(fileName, "wb")
            SaveTable(file,"TableDataManager._SkillAttackEffectDataManager",saveTableData)
            io.close(file)
        end
    end
end
--只保存
function UISkillEditor.OnSaveClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        --保存数据成.Lua代码文件
        local saveTableData = TableDataManager._SkillAttackEffectDataManager
        if saveTableData ~= nil then
            local fileUtils = cc.FileUtils:getInstance()
            local fileName = "src/main/DataPool/SkillAttackEffect.lua"--fileUtils:fullPathForFilename("src/main/DataPool/SkillAttackEffect.lua")
            print("fileName = " .. fileName)
            local file = io.open(fileName, "wb")
            SaveTable(file,"TableDataManager._SkillAttackEffectDataManager",saveTableData)
            io.close(file)
        end
    end
end
--武将多选单选点击
function UISkillEditor.SelectedStateEvent(sender, eventType)
    if eventType == ccui.CheckBoxEventType.selected then
       
    elseif eventType == ccui.CheckBoxEventType.unselected then
       
    end
    local uiSystem = GameGlobal:GetUISystem()
    if uiSystem ~= nil then
        local skillEditorUI = uiSystem:GetUIInstance(UIType.UIType_SkillEditor)
        if skillEditorUI ~= nil then
            skillEditorUI:OnSelectStateChange()
        end 
    end
end

--选中点击事件处理
function UISkillEditor.OnArmyTextClicked(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
        local id = tonumber(tag)
      --  printInfo("OnArmyTextClicked %d", tag)
        local uiSystem = GameGlobal:GetUISystem()
        if uiSystem ~= nil then
            local skillEditorUI = uiSystem:GetUIInstance(UIType.UIType_SkillEditor)
            if skillEditorUI ~= nil then
                skillEditorUI:OnClickArmyText(id)
            end 
        end
    end
end

--场景中位置点击
function UISkillEditor.OnSceneClick(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local touchPosition = sender:getTouchEndPosition()
        local uiSystem = GameGlobal:GetUISystem()
        local skillEditorUI = uiSystem:GetUIInstance(UIType.UIType_SkillEditor)
        if skillEditorUI ~= nil then
            skillEditorUI:OnClickScene(touchPosition)
        end
    end
end

--参数改变
function UISkillEditor.OnParamChanged(sender, eventType)
   -- printInfo("UISkillEditor:OnParamChanged %d", eventType)
    if eventType == ccui.TextFiledEventType.attach_with_ime then
        
    elseif eventType == ccui.TextFiledEventType.detach_with_ime then

    elseif eventType == ccui.TextFiledEventType.insert_text then
        
    elseif eventType == ccui.TextFiledEventType.delete_backward then
        
    end
    local uiSystem = GameGlobal:GetUISystem()
    local skillEditorUI = uiSystem:GetUIInstance(UIType.UIType_SkillEditor)
    if skillEditorUI ~= nil then
        skillEditorUI:SetParamData()
    end
end

return UISkillEditor