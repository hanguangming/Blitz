----
-- 文件名称：UISetting.lua
-- 功能描述：测试UI
-- 文件说明：
-- 作    者：王雷雷
-- 创建时间：2015-6-16
-- 修改 ：
--  测试UI动画的支持情况
--
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
local UISystem = require("main.UI.UISystem")
local ANI_PATH = "csb/texiao/ui/"
local UISetting = class("UISetting", UIBase)

--构造函数
function UISetting:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_Setting
    self._ResourceName =  "UISetting.csb"
end

--Load
function UISetting:Load()
    UIBase.Load(self)
    _Instance = self
    local center = seekNodeByName(self._RootPanelNode, "Panel_Center")
    seekNodeByName(center, "CheckBox_1"):addEventListener(self.TouchCheckBox)
    seekNodeByName(center, "CheckBox_2"):addEventListener(self.TouchCheckBox)
    seekNodeByName(center, "CheckBox_1"):setTag(1)
    seekNodeByName(center, "CheckBox_2"):setTag(2)
    seekNodeByName(center, "CheckBox_1"):setSelected(GetMusicFlag())
    seekNodeByName(center, "CheckBox_2"):setSelected(GetSoundFlag())
    seekNodeByName(center, "Slider_1"):addEventListener(self.TouchSlider)
    seekNodeByName(center, "Slider_2"):addEventListener(self.TouchSlider)
    seekNodeByName(center, "Slider_1"):setTag(1)
    seekNodeByName(center, "Slider_2"):setTag(2)
    seekNodeByName(center, "Slider_1"):setPercent(GetMusicVolume())
    seekNodeByName(center, "Slider_2"):setPercent(GetSoundVolume())
    seekNodeByName(seekNodeByName(center, "Slider_1"), "Text_1"):enableOutline(cc.c4b(114, 81, 46, 250), 1)
    seekNodeByName(seekNodeByName(center, "Slider_1"), "Text_1"):setString(GetSoundVolume().."%")
    seekNodeByName(seekNodeByName(center, "Slider_2"), "Text_1"):setString(GetSoundVolume().."%")
    seekNodeByName(seekNodeByName(center, "Slider_2"), "Text_1"):enableOutline(cc.c4b(114, 81, 46, 250), 1)
    self._MuiscFlag = seekNodeByName(center, "Flag1")
    self._SoundFlag = seekNodeByName(center, "Flag2")
    self._MuiscPre = seekNodeByName(seekNodeByName(center, "Slider_1"), "Text_1")
    self._SoundPre = seekNodeByName(seekNodeByName(center, "Slider_2"), "Text_1")
    self._MuiscFlag:enableOutline(cc.c4b(114, 81, 46, 250), 1)
    self._SoundFlag:enableOutline(cc.c4b(114, 81, 46, 250), 1)
    if GetMusicFlag() then
        self._MuiscFlag:setColor(cc.c3b(92,180,10))
        self._MuiscPre:setColor(cc.c3b(92,180,10))
    else
        self._MuiscFlag:setColor(cc.c3b(158,156,157))
        self._MuiscPre:setColor(cc.c3b(158,156,157))
    end
    
    if GetSoundFlag() then
        self._SoundFlag:setColor(cc.c3b(92,180,10))
        self._SoundPre:setColor(cc.c3b(92,180,10))
    else
        self._SoundFlag:setColor(cc.c3b(158,156,157))
        self._SoundPre:setColor(cc.c3b(158,156,157))
    end
    local close = seekNodeByName(center, "Close")
    close:setTag(-1)
    close:addTouchEventListener(self.TouchEvent)
    self._TabButton = {} 
    local name ={GameGlobal:GetTipDataManager(UI_BUTTON_NAME_63), GameGlobal:GetTipDataManager(UI_BUTTON_NAME_64)}
    --CreateBaseUIAction(self._RootPanelNode, -50, 195, -1, GameGlobal:GetTipDataManager(UI_BUTTON_NAME_76), name, 2, self.TouchEvent, self.EndCallBack)

end

function UISetting.EndCallBack(value)
    _Instance._TabButton = value
    _Instance._TabButton[1]:setTag(1)
    _Instance._TabButton[2]:setTag(2)
end

function UISetting:TouchSlider()
    if self:getTag() == 1 then
        SetMusicVolume(self:getPercent())
        seekNodeByName(self, "Text_1"):setString(math.floor(self:getPercent()).."%")
    elseif self:getTag() == 2 then
        SetSoundVolume(self:getPercent())
        seekNodeByName(self, "Text_1"):setString(math.floor(self:getPercent()).."%")
    end
end

function UISetting:TouchCheckBox()
    if self:getTag() == 1 then
        if self:isSelected() then
            OpenMusic()
            PlayMusic(Sound_10, true)
            _Instance._MuiscPre:setColor(cc.c3b(92,180,10))
            _Instance._MuiscFlag:setColor(cc.c3b(92,180,10))
        else
            StopMusic()
            _Instance._MuiscPre:setColor(cc.c3b(158,156,157))
            _Instance._MuiscFlag:setColor(cc.c3b(158,156,157))
        end
    elseif self:getTag() == 2 then
        if self:isSelected() then
            OpenSound()
            PlaySound(Sound_11, true)
            _Instance._SoundPre:setColor(cc.c3b(92,180,10))
            _Instance._SoundFlag:setColor(cc.c3b(92,180,10))
        else
            StopSound()
            _Instance._SoundPre:setColor(cc.c3b(158,156,157))
            _Instance._SoundFlag:setColor(cc.c3b(158,156,157))
        end
    end
end

--Unload
function UISetting:Unload()
    UIBase.Unload(self)

end

--打开
function UISetting:Open()
    UIBase.Open(self)
end

--关闭
function UISetting:Close()
    UIBase.Close(self)
end

function UISetting:TouchEvent(eventType)
    if eventType == ccui.TouchEventType.ended then
        local tag = self:getTag()
        if tag == -1 then
            UISystem:CloseUI(UIType.UIType_Setting)
        elseif tag == 1 then
            seekNodeByName(self, "Text_1"):setColor(cc.c3b(255, 209, 0))
            seekNodeByName(_Instance._TabButton [2], "Text_1"):setColor(cc.c3b(188, 188, 188))
        elseif tag == 2 then
            seekNodeByName(self, "Text_1"):setColor(cc.c3b(255, 209, 0))
            seekNodeByName(_Instance._TabButton [1], "Text_1"):setColor(cc.c3b(188, 188, 188))
        end
    end
end

return UISetting
