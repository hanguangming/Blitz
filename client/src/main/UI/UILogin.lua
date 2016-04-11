----
-- 文件名称：UIlogin.lua
-- 功能描述：登录UI
-- 文件说明：登录ui
-- 作    者：王峰
-- 创建时间：2015-6-2
--  修改
require("main.UI.UIBase")
require("main.UI.UITypeDefine")
require("src.cocos.ui.GuiConstants")
local UISystem =  GameGlobal:GetUISystem()
local UILogin = class("UILogin", UIBase)
function UILogin:ctor()
    UIBase.ctor(self)
    self._Type = UIType.UIType_LoginUI
    self._ResourceName = "UILoginGame.csb"  
end

function UILogin:Load()
    UIBase.Load(self)

    self._frmLogin = cc.CSLoader:createNode("csb/ui/GameRegister.csb")
    self._frmLogin:retain()
    self._txtUser = seekNodeByName(self._frmLogin, "TextField_Name")
    self._txtPwd = seekNodeByName(self._frmLogin, "TextField_Code")
    self._btnLogin = seekNodeByName(self._frmLogin, "Button_1")
    self._btnLogin:addTouchEventListener(function(...) self:onLogin(...) end)
    self._btnReg = seekNodeByName(self._frmLogin, "Button_2")
    self._btnReg:addTouchEventListener(function(...) self:onRegister(...) end)

    self._btnServer = self:FindNode("ServerBtn");
    self._btnServer:addTouchEventListener(function(...) self:onSelServer(...) end)
    self._txtServer = self:FindNode("ServerName");
    self._btnEnter = self:FindNode("Btn_EnterGame");
    self._btnEnter:addTouchEventListener(function(...) self:onEnter(...) end);

    self:LoadServerList()
    self._serverid = GetDate("server", 4);
    self._user = GetDate("username", 4);
    self._pwd = GetDate("password", 4);
end

function UILogin:Unload()
    UIBase:Unload()
    self._ResourceName = nil
    self.Type = nil
end

function UILogin:Open() 
    UIBase.Open(self)
    self:addEvent(GameEvent.GameEvent_UILogin_Succeed, self.onLoginSucceed)
    self:updateServerInfo();
end

function UILogin:Close()
    UIBase.Close(self)
end

function UILogin:LoadServerList()
    local xhr = cc.XMLHttpRequest:new() -- http请求  
    xhr.responseType = 0 -- 响应类型  
    xhr:open("GET", "http://server-list.sanguoqyz.com:8000/serverlist.php") -- 打开链接  
    self._serverList = {}

    -- 状态改变时调用  
    local function onReadyStateChange()  
        -- 显示状态文本  
        local state = Split(xhr.statusText, " ");
        if state and state[1] == "200" then
            self._serverList = loadstring("return" .. xhr.response)()
            self:updateServerInfo()
        else
            self._serverList = nil;
        end
    end  

    -- 注册脚本回调方法  
    xhr:registerScriptHandler(onReadyStateChange)  
    xhr:send() -- 发送请求  
end

function UILogin:onLoginSucceed(event)
    self._logining = nil;
    SaveDate("username", self._user, 4)
    SaveDate("password", self._pwd, 4)
    SaveDate("server", self._serverid, 4)

    UISystem:OpenUI(UIType.UIType_LoadingUI)
    self:closeUI();
end 

function UILogin:onSelServer(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if self._serverList then
            if self._serverList[1] then
                UISystem:OpenUI(UIType.UIType_Server, self)
            end
        else
            self:LoadServerList()
        end
    end
end

function UILogin:onEnter(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local widget = cc.CSLoader:createNode("csb/ui/GameRegister.csb")
        self:addChild(self._frmLogin, 0, 0)
        self._txtUser:setString(self._user);
        self._txtPwd:setString(self._pwd);
    end
end

function UILogin:onLogin(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local server = self:getServer(self._serverid)
        if not self._logining and server then
            self._logining = true
            self._user = self._txtUser:getString()
            self._pwd = self._txtPwd:getString()
            local data = {self._user, self._pwd, "qzone", "pf3366", 4}

            local netSystem = GetNetSystem()
            netSystem._LoginIP = server.ip;
            netSystem._LoginPort = server.port;
            netSystem:CreateLoginConnect(server.ip, server.port)
            SendLoginMsg(PacketDefine.PacketDefine_Login_Send, data)
        end
    end
end

function UILogin:onRegister(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
    end
end

function UILogin:getServer(servid)
    if self._serverList then
        for k, v in pairs(self._serverList) do
            if v.id == servid then
                return v
            end
        end
    end
end

function UILogin:getRecommendServer()
    if self._serverList then
        for k, v in pairs(self._serverList) do
            if v.r and v.r ~= 0 then
                return v
            end
        end
    end
end

function UILogin:setServer(servid)
    self._serverid = servid
    self:updateServerInfo()
end

function UILogin:updateServerInfo()
    local server = self:getServer(self._serverid)
    if server then
        self._txtServer:setString(server.name);
    else
        server = self:getRecommendServer();
        if server then
            self._txtServer:setString(server.name);
            self._serverid = server.id;
        else
            self._txtServer:setString("未选择服务器");
        end
    end
end

return UILogin


