require("cocos.ui.GuiConstants")
require("cocos.extension.ExtensionConstants")
require("cocos.cocos2d.deprecated")
local audio = require("cocos.framework.audio")

local vertDefaultSource = "\n"..
    "attribute vec4 a_position; \n" ..
    "attribute vec2 a_texCoord; \n" ..
    "attribute vec4 a_color; \n"..                                                    
    "#ifdef GL_ES  \n"..
    "varying lowp vec4 v_fragmentColor;\n"..
    "varying mediump vec2 v_texCoord;\n"..
    "#else                      \n" ..
    "varying vec4 v_fragmentColor; \n" ..
    "varying vec2 v_texCoord;  \n"..
    "#endif    \n"..
    "void main() \n"..
    "{\n" ..
    "gl_Position = CC_PMatrix * a_position; \n"..
    "v_fragmentColor = a_color;\n"..
    "v_texCoord = a_texCoord;\n"..
    "}"

local pszFragSource = "#ifdef GL_ES \n" ..
    "precision mediump float; \n" ..
    "#endif \n" ..
    "varying vec4 v_fragmentColor; \n" ..
    "varying vec2 v_texCoord; \n" ..
    "void main(void) \n" ..
    "{ \n" ..
    "vec4 c = texture2D(CC_Texture0, v_texCoord); \n" ..
    "gl_FragColor.xyz = vec3(0.4*c.r + 0.4*c.g +0.4*c.b); \n"..
    "gl_FragColor.w = c.w; \n"..
    "}"
    
function GrayNode(node)
    local shader = cc.GLProgram:createWithByteArrays(vertDefaultSource,pszFragSource)
    shader:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION)
    shader:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
    shader:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORDS)
    shader:link()
    shader:updateUniforms()
end

-- create scene 
function CreateStopTouchScene(callback)
    local scene = cc.CSLoader:createNode("csb/ui/Scene.csb")
    local panel = seekNodeByName(scene, "Panel_1")
    local list = seekNodeByName(scene, "ListView_1"):setVisible(false)
    panel:setSwallowTouches(true) 
    panel:addTouchEventListener(callback)
    panel:setTag(-1)
    return panel 
end

function CreateInfoBack(x ,y, w, h, callBack, type, tag, opacity)
    local bg = display.newLayer(cc.c4b(0, 0, 0, 0), cc.size(w, h))
    local ss = ccui.Scale9Sprite:create("meishu/ui/gg/UI_gg_shenghuidi_01.png")
    ss:setContentSize(w, h)
    ss:setColor(cc.c3b(0, 0, 0))
    if opacity == nil then
        ss:setOpacity(0)
    else
        ss:setOpacity(opacity)
    end
    ss:setAnchorPoint(0, 0)
    bg:addChild(ss)
    bg:setPosition(x, 540 - y - h)
    bg:ignoreAnchorPointForPosition(false)
    bg:setAnchorPoint(0.5, 0)
    local resName = "meishu/ui/gg/UI_gg_anniu3_"
    local name = ""
    if type == 1 then
        name = "打开"
    elseif type == 2 then
        name = "卖出"
    elseif type == 3 then
        name = "合成"
    elseif type == 4 then
        name = GameGlobal:GetTipDataManager(UI_BUTTON_NAME_4)
    elseif type == 5 then
        name = GameGlobal:GetTipDataManager(UI_BUTTON_NAME_5)
    elseif type == 6 then
        name = GameGlobal:GetTipDataManager(UI_BUTTON_NAME_4)
    end
   
    if type > 0 then
        local  item1 = cc.MenuItemImage:create(resName.. "01.png", resName.."02.png")
        item1:registerScriptTapHandler(callBack)
        item1:setTag(tag)
        item1:setPosition(w / 2, 90)
        item1:setAnchorPoint(0.5, 0.5)
        
        local des = cc.Label:createWithTTF(name, FONT_FZLTTHJW, BASE_FONT_SIZE_MID + 4)
        des:setAnchorPoint(cc.p(0.5, 0.5))
        des:setColor(cc.c3b(144, 54, 1))
        des:setPosition(cc.p(50, 22))
        item1:addChild(des)
        
        local  menu = cc.Menu:create()
        menu:setPosition(0, 0)
        menu:addChild(item1)
        bg:addChild(menu)
    end
    return bg
end

function CreateServerList(parent, x ,y, server, callBack)
    local h = #server * 60 + 100
    local w = 200
    local bg = display.newLayer(cc.c4b(0, 0, 0, 0), cc.size(w, h))
    local ss = ccui.Scale9Sprite:create("meishu/ui/gg/UI_gg_shenghuidi_01.png")
    ss:setContentSize(w, h)
    ss:setColor(cc.c3b(0, 0, 0))
    ss:setOpacity(200)
    ss:setAnchorPoint(0, 0)
    bg:addChild(ss)
    bg:setPosition(x, 540 - y )
    bg:ignoreAnchorPointForPosition(false)
    bg:setAnchorPoint(0.5, 0)
    local resName = "meishu/ui/gg/UI_ck_xiaokuang.png"
    local  menu = cc.Menu:create()
    menu:setPosition(0, 0)

    for i = 1, #server do
        local  item1 = cc.MenuItemImage:create(resName, resName)
        item1:registerScriptTapHandler(callBack)
        item1:setTag(i)
        item1:setPosition(x / 2, 60 + i * 40)
        item1:setAnchorPoint(0.5, 0.5)
    
        local des = cc.Label:createWithTTF(server[i].ip, FONT_JINZHUANG, BASE_FONT_SIZE)
        des:setAnchorPoint(cc.p(0.5, 0.5))
        des:setColor(cc.c3b(252, 241, 209))
        des:setPosition(cc.p(62.5, 15))
        des:enableOutline(cc.c4b(0, 0, 0, 250), 2)
        item1:addChild(des)
    
        menu:addChild(item1)
    end
    
    bg:addChild(menu)
    parent:addChild(bg, 0, 0)
    return bg
end

function CreateButton(parent, x, y, tag, normal, select, callback, type, older)
    local item1
    if type == 1 then
        item1 = cc.MenuItemImage:create(normal, select)
    else
        item1 = cc.MenuItemSprite:create(normal, select)
    end
    item1:registerScriptTapHandler(callback)
    item1:setTag(tag)
    item1:setPosition(x, y)
    item1:setAnchorPoint(0.5, 0.5)
    local  menu = cc.Menu:create()
    menu:addChild(item1)
    menu:setPosition(0, 0)
    if older == nil then
        older = 0
    end
    parent:addChild(menu, older)
    return item1
end

function CreateTableView(x, y, w, h, dir, obj)
    local gridView = cc.TableView:create(cc.size(w, h))
    gridView:setPosition(cc.p(x, y))
    gridView:setDirection(dir)
    gridView:setVerticalFillOrder(0)
    gridView:setBounceable(true)
    gridView:setDelegate()
    gridView:registerScriptHandler(obj.ScrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    gridView:registerScriptHandler(obj.TableCellTouched, cc.TABLECELL_TOUCHED)
    gridView:registerScriptHandler(obj.CellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    gridView:registerScriptHandler(obj.TableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    gridView:registerScriptHandler(obj.NumberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    return gridView
end

-- 为了以后逐步把项目迁移到不再需要 Instance_ 变量
function CreateTableView_(x, y, w, h, dir, obj)
    local gridView = cc.TableView:create(cc.size(w, h))
    gridView:setPosition(cc.p(x, y))
    gridView:setDirection(dir)
    gridView:setVerticalFillOrder(0)
    gridView:setBounceable(true)
    gridView:setDelegate()

    local didScroll = obj.ScrollViewDidScroll or function() end
    local didTouch = obj.TableCellTouched or function() end
    gridView:registerScriptHandler(handler(obj, didScroll), cc.SCROLLVIEW_SCRIPT_SCROLL)
    gridView:registerScriptHandler(handler(obj, didTouch),  cc.TABLECELL_TOUCHED)
    gridView:registerScriptHandler(handler(obj, obj.CellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    gridView:registerScriptHandler(handler(obj, obj.TableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    gridView:registerScriptHandler(handler(obj, obj.NumberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    return gridView
end

function SplitBroad(str, data)
    local start1 = 1
    local start2 = 1
    local color = {[1] = cc.c3b(255, 255, 255), [11] = cc.c3b(255, 0, 0), [12] = cc.c3b(255, 250, 0), [13] = cc.c3b(0, 250, 0)}
    local richText = ccui.RichText:create()  
    richText:ignoreContentAdaptWithSize(false)  
    richText:setContentSize(cc.size(800, 100)) 

    for i = 1, 4 do
        local index1 = string.find(str, "#", start1)
        local index2 = string.find(str, ">", start2)
        local endIndex = index2
        local starIndex = index1
        if index1 == nil or start2 == nil then
            break
        end
        local re1 = ccui.RichElementText:create( 2 * (i - 1) + 1, color[1], 255, string.sub(str, start2, index1 - 1 ), FONT_FZLTTHJW, 20 )  
        richText:pushBackElement(re1)  
        local ctype = tonumber(string.sub(str, index1 + 1, index1 + 2))
        local flag = string.sub(str, index1, index2)
        local type = string.find(flag, "name")
        if type == nil then
            type = string.find(flag, "vip")
            if type == nil then
                type = string.find(flag, "id")
                if type ~= nil then
                    if tonumber(data.id) > 10000 then 
                        str,_ = string.gsub(str, 'id', GetPropDataManager()[tonumber(data.id)]["name"])
                        starIndex= string.find(str, "#", start1)
                        endIndex = string.find(str, ">", start2)
                        local re2 = ccui.RichElementText:create( 2 * (i - 1) + 2, GetQualityColor(tonumber(GetPropDataManager()[tonumber(data.id)]["quality"])), 255, string.sub(str, starIndex + 1, endIndex - 1), FONT_FZLTTHJW, 20 )  
                        richText:pushBackElement(re2) 
                    else
                        print(data.id)
                        str,_ = string.gsub(str, 'id', GameGlobal:GetCharacterDataManager()[tonumber(data.id)]["name"])
                        starIndex= string.find(str, "#", start1)
                        endIndex = string.find(str, ">", start2)
                        local re2 = ccui.RichElementText:create( 2 * (i - 1) + 2, GetQualityColor(tonumber(GameGlobal:GetCharacterDataManager()[tonumber(data.id)]["quality"])), 255, string.sub(str, starIndex + 1, endIndex - 1), FONT_FZLTTHJW, 20 )  
                        richText:pushBackElement(re2) 
                    end
                else
                    type = string.find(flag, "id2")
                    if type ~= nil then
                        if tonumber(data.id) > 10000 then 
                            str,_ = string.gsub(str, 'id2', GetPropDataManager()[tonumber(data.id)]["name"])
                            starIndex= string.find(str, "#", start1)
                            endIndex = string.find(str, ">", start2)
                            local re2 = ccui.RichElementText:create( 2 * (i - 1) + 2, GetQualityColor(tonumber(GetPropDataManager()[tonumber(data.id)]["quality"])), 255, string.sub(str, starIndex + 1, endIndex - 1), FONT_FZLTTHJW, 20 )  
                            richText:pushBackElement(re2) 
                        else
                            print(data.id)
                            str,_ = string.gsub(str, 'id2', GameGlobal:GetCharacterDataManager()[tonumber(data.id)]["name"])
                            starIndex= string.find(str, "#", start1)
                            endIndex = string.find(str, ">", start2)
                            local re2 = ccui.RichElementText:create( 2 * (i - 1) + 2, GetQualityColor(tonumber(GameGlobal:GetCharacterDataManager()[tonumber(data.id)]["quality"])), 255, string.sub(str, starIndex + 1, endIndex - 1), FONT_FZLTTHJW, 20 )  
                            richText:pushBackElement(re2) 
                        end
                    end
                end 
            else
                str,_ = string.gsub(str, 'vip', "")
                starIndex = string.find(str, "#", start1)
                endIndex = string.find(str, ">", start2)
                local re2 = ccui.RichElementText:create( 2 * (i - 1) + 2, color[ctype], 255, string.sub(str, starIndex + 3, starIndex + 5), FONT_FZLTTHJW, 20 )  
                richText:pushBackElement(re2) 
                
                local reimg = ccui.RichElementImage:create( 2 * (i - 1) + 3, color[1], 255, "meishu/ui/vip/UI_vip_"..data.vip..".png" ) 
                richText:pushBackElement(reimg)  
                
                local re2 = ccui.RichElementText:create( 2 * (i - 1) + 4, color[ctype], 255, string.sub(str, starIndex + 6, endIndex - 1), FONT_FZLTTHJW, 20 )  
                richText:pushBackElement(re2) 
                
            end
        else
            str,_ = string.gsub(str, 'name', data.name)
            starIndex= string.find(str, "#", start1)
            endIndex = string.find(str, ">", start2)
            local re2 = ccui.RichElementText:create( 2 * (i - 1) + 2, color[ctype], 255, string.sub(str, starIndex + 3, endIndex - 1), FONT_FZLTTHJW, 20 )  
            richText:pushBackElement(re2)  
        end
        start1 = starIndex + 1
        start2 = endIndex + 1
    end
    richText:setLocalZOrder(10)  
    return richText
end

function RichText()  
    local richText = ccui.RichText:create()  
    richText:ignoreContentAdaptWithSize(false)  
    richText:setContentSize(cc.size(100, 100))  
  
    local re1 = ccui.RichElementText:create( 1, cc.c3b(255, 255, 255), 255, "This color is white. ", "Helvetica", 10 )  
    local re2 = ccui.RichElementText:create( 2, cc.c3b(255, 255,   0), 255, "And this is yellow. ", "Helvetica", 10 )  
    local re3 = ccui.RichElementText:create( 3, cc.c3b(0,   0, 255), 255, "This one is blue. ", "Helvetica", 10 )  
    local re4 = ccui.RichElementText:create( 4, cc.c3b(0, 255,   0), 255, "And green. ", "Helvetica", 10 )  
    local re5 = ccui.RichElementText:create( 5, cc.c3b(255,  0,   0), 255, "Last one is red ", "Helvetica", 10 )  
    local re6 = ccui.RichElementText:create( 7, cc.c3b(255, 127,   0), 255, "Have fun!! ", "Helvetica", 10 )  
    local reimg = ccui.RichElementImage:create( 6, cc.c3b(255, 255, 255), 255, "cocosui/sliderballnormal.png" )  
  
--    -- 添加ArmatureFileInfo, 由ArmatureDataManager管理  
--    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo( "cocosui/100/100.ExportJson" )  
--    local arr = ccs.Armature:create( "100" )  
--    arr:getAnimation():play( "Animation1" )  
--    local recustom = ccui.RichElementCustomNode:create( 1, cc.c3b(255, 255, 255), 255, arr )  
--    richText:pushBackElement(recustom)  
    richText:pushBackElement(re1)  
    richText:insertElement(re2, 1)  
    richText:pushBackElement(re3)  
    richText:pushBackElement(re4)  
    richText:pushBackElement(re5)  
    richText:insertElement(reimg, 2)  
 
    richText:pushBackElement(re6)  
  
    richText:setLocalZOrder(10)  
  
    return richText  
end 

gNextBroadOpen = true

function showBroad(value)
    if  GameGlobal:GetUISystem():GetUIRootNode():getChildByTag(211) == nil then
        local bg = ccui.Scale9Sprite:create("meishu/ui/gg/UI_gg_shenghuidi_01.png")
        bg:setContentSize(500, 50)
        bg:setColor(cc.c3b(0, 0, 0))
        local clippingNode = cc.ClippingNode:create(bg)
        clippingNode:setContentSize(cc.size(500, 50))
        clippingNode:addChild(bg)
        clippingNode:setPosition(740, 450)
        clippingNode:addChild(bg, 1)
        clippingNode:setAnchorPoint(0.5, 0.5)
        bg:setOpacity(200)
        bg:setAnchorPoint(0.5, 0.5)
        GameGlobal:GetUISystem():GetUIRootNode():addChild(clippingNode, 800, 211)
    end
    
    if GetGlobalData()._BroadData[1] ~= nil and gNextBroadOpen then
        local bg = GameGlobal:GetUISystem():GetUIRootNode():getChildByTag(211)
        local tt = SplitBroad(GameGlobal:GetDataTableManager()._BroadcastDataManager[GetGlobalData()._BroadData[1]["guid"]].des, GetGlobalData()._BroadData[1])
        tt:setPosition(500, 10)
        tt:setAnchorPoint(0.5, 1)
        gNextBroadOpen = false
        transition.moveBy(tt, {time = 10, x = -800, y = 0, onComplete = removeRichText})
        bg:addChild(tt, 1000, 0)
    else
        if  GameGlobal:GetUISystem():GetUIRootNode():getChildByTag(211) ~= nil then
            GameGlobal:GetUISystem():GetUIRootNode():removeChildByTag(211)
        end
    end
end

function removeRichText(sender)
    sender:removeFromParent()
    gNextBroadOpen= true
    table.remove(GetGlobalData()._BroadData, 1)
    
    showBroad()
end

function handlers(self, method, arg)
    return function(...) 
        return method(self, ..., arg)
    end
end

function SimulateClickButton(node, callback)
    local delay = cc.DelayTime:create(0)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    node:runAction(sequence)
end 

function CreateTipAction(parent, str, pos, time)
    local frame = display.newSprite("meishu/ui/gg/UI_gg_tishitiao.png", pos.x, pos.y)
    frame:setScaleX(0.3)
    local label = cc.Label:createWithTTF(str, FONT_MSYH, BASE_FONT_SIZE + 5)
    label:setAnchorPoint(0.5, 0.5)
    label:setScaleX(3.3)
    label:setPosition(480, 23)
    label:setColor(cc.c3b(0, 250, 0))
    frame:addChild(label)
    parent:addChild(frame, 1000)    
    transition.moveBy(frame, {x = 0, y = 100, time = 0.8, delay = time, removeSelf = true})
end

function createSprite(parent, name, x, y, zOrder, tag)
   local sprite = display.newSprite(name, x, y)
   parent:addChild(sprite)
   if tag ~= nil then
        sprite:setTag(tag)
   end
    if zOrder ~= nil then
        sprite:setLocalZOrder(zOrder)
   end
   return sprite
end

function frameListien(self)
    print(self)
end

function CreateAnimation(parent, x, y, aniName, action, loop, sort, time, endcallback, frame)
    local animNode = cc.CSLoader:createNode(aniName)

    local anim = cc.CSLoader:createTimeline(aniName)
   
    if sort == nil then
        sort = 0
    end
    
    if time == nil then
        time = 1
    end
    anim:setTimeSpeed(time)
    parent:addChild(animNode, sort, 1)
    
    anim:play(action, loop)
    animNode:runAction(anim)
    animNode:setPosition(cc.p(x, y))
    animNode:setUserObject(anim)
    animNode._usedata = anim
   
    if frame ~= nil then
        anim:gotoFrameAndPlay(0, 114, false)
    end
    if endcallback ~= nil then
        performWithDelay(animNode, endcallback, 1)
    end
   
    return animNode
end

function removeNodeAndRelease(node, isRelease)
    if node ~= nil and not tolua.isnull(node) then
        node:removeFromParent(true)
        if isRelease then
            if node:getReferenceCount() > 0 then
                node:release()
            end
        end   
    end
end

function CreateAnimationObject(x, y, aniName)
    local animNode = cc.CSLoader:createNode(aniName)
    local anim = cc.CSLoader:createTimeline(aniName)
    animNode:runAction(anim)
    animNode:setPosition(cc.p(x, y))
    anim:retain()
    animNode._usedata = anim
    animNode:retain()
    return animNode
end

function playAnimationObject(parent, index, x, y, actionName, loop)
    local parentNode = g_AnimationList[index]:getParent()
    if parentNode == nil then
        g_AnimationList[index]:setPosition(cc.p(x, y))
        parent:addChild(g_AnimationList[index], 1)
    end
    g_AnimationList[index]._usedata:resume()
    g_AnimationList[index]._usedata:setCurrentFrame(g_AnimationList[index]._usedata:getStartFrame())
    if loop then
        g_AnimationList[index]._usedata:play(actionName, true)
    else
        g_AnimationList[index]._usedata:play(actionName, false)
    end
    
end

local g_Loading 

function WaitLoading(self)
    g_Loading:setPositionX(9.6 * self:getPercentage())
end

function createProgress(parent, sprite, x, y, type, percent)
    local pt = cc.ProgressTimer:create(sprite)
    if type == 0 then
        pt:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
        pt:setReverseDirection(true)
    elseif type == 1 then
        pt:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        pt:setMidpoint(cc.p(0,0))
        pt:setBarChangeRate(cc.p(1, 0))
    else
    end
    pt:setPosition(cc.p(x, y))
    local action = cc.ProgressTo:create(0, percent)
    pt:runAction(action)
    parent:addChild(pt, 1001, 1001)
end

function EnterLoading(parent, type, endcallback)
    local layout = cc.CSLoader:createNode("csb/ui/UILoading.csb")
    GrayNode(seekNodeByName(layout, "Sprite1"))
    local load = seekNodeByName(layout, "LoadingBar_1")
    local pt = cc.ProgressTimer:create(seekNodeByName(layout, "Sprite1"))
   
    if type == 0 then
        pt:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    elseif type == 1 then
        pt:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        pt:setMidpoint(cc.p(0,0))
        pt:setBarChangeRate(cc.p(1, 0))
        
        g_Loading = display.newSprite("meishu/ui/gg/null.png", 0, 0)
        parent:addChild(g_Loading, 1005)
        GetSoldierCsbPath(10041)
        CreateAnimation(g_Loading, -720, -175, "csb/texiao/ui/T_u_londingjiemian.csb", "work", true, 1003, 1)
        CreateAnimation(g_Loading, -720 + 530, -175 + 250,  GetSoldierCsbPath(10041), "Walk", true, 1, 1)
        CreateAnimation(g_Loading, -720 + 600, -175 + 250,  GetSoldierCsbPath(10024), "Walk", true, 1, 1)
        CreateAnimation(g_Loading, -720 + 620, -180 + 250,  GetSoldierCsbPath(10059), "Walk", true, 1, 1)
        CreateAnimation(g_Loading, -720 + 625, -170 + 250,  GetSoldierCsbPath(10004), "Walk", true, 1, 1)
        CreateAnimation(g_Loading, -720 + 650, -170 + 250,  GetSoldierCsbPath(10106), "Walk", true, 1, 1)
        CreateAnimation(g_Loading, -720 + 660, -185 + 250,  GetSoldierCsbPath(10069), "Walk", true, 1, 1)
        CreateAnimation(g_Loading, -720 + 700, -175 + 250,  GetWarriorCsbPath(5650), "Walk", true, 1, 1)
    else
        local  map = cc.TMXTiledMap:create("TestMap.tmx")
        map:getLayer("bg"):setPosition(-1000, 300)
        local drawNode = cc.DrawNode:create() 
        map:addChild(drawNode, 10)
        drawNode:drawLine(cc.p(100, 100), cc.p(100, 400), cc.c4f(1,1,1,1))
        drawNode:drawCircle(cc.p(480, 270), 100, 0, 100, false, cc.c4f(0,0,0,1))
        drawNode:drawDot(cc.p(480, 270), 50, cc.c4f(1,0,0,1))
        drawNode:drawQuadBezier(cc.p(480, 150), cc.p(400, 300), cc.p(680, 390), 1000, cc.c4f(0,1,0,1))
        drawNode:drawPoint(cc.p(480, 120), 1, cc.c4f(1,1,1,1))
        drawNode:drawSolidCircle(cc.p(480, 100), 100, 0,100, cc.c4f(1,1,1,1))
        drawNode:drawSegment(cc.p(480, 400), cc.p(580, 300), 50, cc.c4f(1,1,1,1))
        drawNode:drawTriangle(cc.p(480, 400), cc.p(580, 300), cc.p(580, 200), cc.c4f(1,0,1,1))
        drawNode:drawRect(cc.p(200, 200), cc.p(50, 50), cc.c4f(1,1,0,1))
        --  drawRect
        parent:addChild(map, 1002, 1)
        local  group = map:getObjectGroup("object")
        local  objects = group:getObjects()
        local  len = table.getn(objects)
        for i = 1, len, 1 do
            print("object: %s", objects[i].x)
            print("object: %s", objects[i].name)
        end
    end
    pt:setPosition(cc.p(480, 262))
    local action = cc.ProgressTo:create(5, 100)
    pt:runAction(action)
    parent:addChild(layout, 1000, 1)
    parent:addChild(pt, 1001, 0)
    schedule(pt, WaitLoading, 0)
    if endcallback ~= nil then
        performWithDelay(pt, endcallback, 5)
    end
end

function MoveStartAction(node, callback, step, time, type, delaytime, self)
    local x = node:getPositionX()
    local y = node:getPositionY()
    local delay = cc.DelayTime:create(delaytime)
    node:setPosition(cc.p(x, y))
    local move
    if type == 0 then
        move = cc.MoveBy:create(time, cc.p(-step, 0))
    else
        move = cc.MoveBy:create(time, cc.p(0, -step))
    end

    local sequence = cc.Sequence:create(delay, move, cc.CallFunc:create(function(...) callback(self, node) end))
    node:runAction(sequence)
end

function MoveCloseAction(node, callback)
    local move = cc.MoveBy:create(0.2, cc.p(-960,0))
    local sequence = cc.Sequence:create(move, cc.CallFunc:create(callback))
    node:runAction(sequence)
end

local fileUtils = cc.UserDefault:getInstance()
local g_Music = true
local g_Sound = true
local g_MusicVolume = 100
local g_SoundVolume = 100

function SaveDate(key, value, type)
    if type == 1 then
        fileUtils:setBoolForKey(key, value)
    elseif type == 2 then
        fileUtils:setIntegerForKey(key, value)
    elseif type == 3 then
        fileUtils:setFloatForKey(key, value)
    elseif type == 4 then
        fileUtils:setStringForKey(key, value)
    elseif type == 5 then
        fileUtils:setDoubleForKey(key, value)
    end
end

function GetDate(key, type)
    if type == 1 then
        return fileUtils:getBoolForKey(key)
    elseif type == 2 then
        return fileUtils:getIntegerForKey(key)
    elseif type == 3 then
        return fileUtils:getFloatForKey(key)
    elseif type == 4 then
        return fileUtils:getStringForKey(key)
    elseif type == 5 then
        return fileUtils:getDoubleForKey(key)
    end
end

if cc.UserDefault:isXMLFileExist() then
    g_Music = GetDate("g_Music", 1) == 0 and true or GetDate("g_Music", 1)
    g_Sound = GetDate("g_Sound", 1) == 0 and true or GetDate("g_Sound", 1)
    g_MusicVolume = GetDate("g_MusicVolume", 2) == 0 and 1 or GetDate("g_MusicVolume", 2)
    g_SoundVolume = GetDate("g_SoundVolume", 2) == 0 and 1 or GetDate("g_SoundVolume", 2)
end

function PlayMusic(id, isloop)
    if g_Music then
        audio.playMusic("audio/"..id..".mp3", isloop)
        audio.setMusicVolume(g_MusicVolume)
    end
end

function PlaySound(id, isloop)
    if g_Sound then
        if isloop == nil then
            isloop = false
        end
        audio.playSound("audio/"..id..".mp3", isloop)
        audio.setSoundsVolume(g_SoundVolume)
    end
end

function GetMusicFlag()
    return g_Music
end

function GetSoundFlag()
    return g_Sound
end

function GetMusicVolume()
    return g_MusicVolume
end

function GetSoundVolume()
    return g_SoundVolume
end

function SetMusicVolume(value)
    g_MusicVolume = value / 100
    SaveDate("g_MusicVolume", g_MusicVolume, 2)
end

function SetSoundVolume(value)
    g_SoundVolume = value / 100
    SaveDate("g_SoundVolume", g_SoundVolume, 2)
    audio.setSoundsVolume(g_SoundVolume)
end

function OpenMusic()
    g_Music = true
    SaveDate("g_Music", g_Music, 1)
end

function OpenSound()
    g_Sound = true
    SaveDate("g_Sound", g_Sound, 1)
end

function StopMusic()
    if g_Music then
        audio.stopMusic(true)
    end
    g_Music = false
    SaveDate("g_Music", g_Music, 1)
end

function StopSound()
    if g_Sound then
        audio.stopAllSounds()
    end
    g_Sound = false
    SaveDate("g_Sound", g_Sound, 1)
end

function OnQuickConfirm()
    GameGlobal:GetUISystem():OpenUI(UIType.UIType_UIRecharge)
end

function OpenRechargeTip(str)
    local UITip =  GameGlobal:GetUISystem():OpenUI(UIType.UIType_TipUI)
    if str == nil then
        UITip:SetStyle(0, GameGlobal:GetTipDataManager(UI_sc_01)..",请去充值")
    else
        UITip:SetStyle(0, str)
    end
    UITip:RegisteDelegate(OnQuickConfirm, 1)
end

function CreateTimeString(curTime)
    local offTime = curTime - os.time()
    if offTime <= 0 then
        offTime = 0
        local timeStr = string.format("%02d:%02d:%02d", 0, 0, 0)
        return timeStr
    end

    local hour =  math.floor(offTime / 3600)-- 时
    local minute = math.floor((offTime - hour * 3600) / 60) -- 分
    local second = offTime % 60  -- 秒
    local timeStr = string.format("%02d:%02d:%02d", hour, minute, second)
    return timeStr
end

-- 计算字符串的宽度
function CalculateStringWidth(str, fontSize)
    local lenInByte = string.len(str)
    local width = 0
    local flag = 0
    for i=1,lenInByte do
        local curByte = string.byte(str, i)
        local byteCount = 1;
        if curByte>0 and curByte<=127 then
            byteCount = 1
        else
            byteCount = 3
        end

        local char
        if flag == 0 then
            char = string.sub(str, i, i+byteCount-1)
            if byteCount == 1 then
                if char~="\n" then
                    width = width + fontSize*0.5 +0.5
                else
                end
            else
                width = width + fontSize + 0.5
                flag = flag + 1
                --                print(char, width)
            end
        else
            flag = flag + 1
        end

        if flag >= 3 then
            flag = 0
        end
    end
    return width
end

function table.nums(t) 
    local count = 0
    for k, v in pairs( t ) do
        count = count + 1
    end
    return count
end
