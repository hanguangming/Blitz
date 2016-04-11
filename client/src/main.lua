cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src")
cc.FileUtils:getInstance():addSearchPath("res")

require "config"
require "cocos.init"
function print(...)
    release_print(...)
end

function idle_run(func, ...)
	local sharedScheduler = cc.Director:getInstance():getScheduler()
	local handle
	local cb = func;
	local param = {...}
	handle = sharedScheduler:scheduleScriptFunc(
		function()
			sharedScheduler:unscheduleScriptEntry(handle)
			cb(param)
		end, 
		0, false);
end

local function showLogo() 
	local stageWidth = cc.Director:getInstance():getWinSizeInPixels().width;
	local stageHeight = cc.Director:getInstance():getWinSizeInPixels().height;
	local widget = cc.CSLoader:createNode("csb/ui/UIGameLogo.csb");
	local x = (stageWidth - widget:getContentSize().width) / 2;
	local y = (stageHeight - widget:getContentSize().height) / 2;
	widget:setPosition(cc.p(x, y));

	local bg = cc.DrawNode:create() 
    bg:drawSolidRect(cc.p(0, 0), cc.p(stageWidth, stageHeight), cc.c4f(1, 1, 1, 1))

	local scene = display.newScene();
    display.runScene(scene);
    scene:addChild(bg);
    scene:addChild(widget);
end


local function main()
	showLogo();
	idle_run(
		function()
		    require("app.MyApp"):create():run()
    		require("main.Game")
		end
	);
end
 
local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)  
end

