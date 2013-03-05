----------------------------------------------------------------------------------
--
-- menu.lua
--
----------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local widget = require("widget")
local db = require("db")
local appState = require("appstate")
local scene = storyboard.newScene()

----------------------------------------------------------------------------------
-- 
--	NOTE:
--	
--	Code outside of listener functions (below) will only be executed once,
--	unless storyboard.removeScene() is called.
-- 
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local background, studentButton, exitApp

local function onExitRelease(event)
    -- this will not work in the simulator, but works fine on the device
    native.requestExit() 
end

local function onStudentRelease(event)
    print(event.target.id)
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local screenGroup = self.view

	-----------------------------------------------------------------------------
		
	--	CREATE display objects and add them to 'group' here.
	--	Example use-case: Restore 'group' from previously saved state.
	
	-----------------------------------------------------------------------------
	
--	background = display.newImage("the-abcs.png")
--	screenGroup:insert( background )
	
	text = display.newText(screenGroup, "Kwizzer", display.contentWidth/2 - 50, 100 , nil, 28)
	screenGroup:insert(text)
        
        local studentName = db:getSingleStudentName{}
        
	studentButton = widget.newButton{
            id = 1,
            label = studentName,
            labelColor = { default={0}, over={0} },
            font = native.systemFontBold,
            xOffset=2, yOffset=-1,
            -- default = "load-default.png",
            -- over = "load-over.png",
            width=50, height=25,
            left=display.contentWidth/2 - 25, top=200
        }

	exitGame = widget.newButton{
            label = "Exit",
            labelColor = { default={0}, over={0} },
            font = native.systemFontBold,
            xOffset=2, yOffset=-1,
            -- default = "load-default.png",
            -- over = "load-over.png",
            width=50, height=25,
            left=display.contentWidth/2 - 25, top=300
        }
	
	print( "\n2: createScene event" )
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view

    --local gameState = require("gamestate")
    -----------------------------------------------------------------------------

    --	INSERT code here (e.g. start timers, load audio, start listeners, etc.)

    --

    studentButton.onRelease = onStudentRelease
    exitGame.onRelease = onExitRelease
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view

    -----------------------------------------------------------------------------

    --	INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)

    -----------------------------------------------------------------------------

    db = nil
    studentButton = nil
    background = nil
    exitGame = nil
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
    local group = self.view

    -----------------------------------------------------------------------------

    --	INSERT code here (e.g. remove listeners, widgets, save state, etc.)

    -----------------------------------------------------------------------------
    
    db = nil
    studentButton = nil
    background = nil
    exitGame = nil
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

---------------------------------------------------------------------------------

return scene