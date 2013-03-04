----------------------------------------------------------------------------------
--
-- menu.lua
--
----------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
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

local background, newGame, loadGame, exitGame

local function onNewGameTouch( self, event )
	if event.phase == "began" then
		storyboard.gotoScene("backstory")
		return true
	end
end

local function onExitTouch( self, event )
	if event.phase == "began" then
            native.requestExit() 
	end
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local screenGroup = self.view

	-----------------------------------------------------------------------------
		
	--	CREATE display objects and add them to 'group' here.
	--	Example use-case: Restore 'group' from previously saved state.
	
	-----------------------------------------------------------------------------
	
	background = display.newImage("Images/blackbackground.png")
	screenGroup:insert( background )
	
	text = display.newText("SpaceBallz", 100, 75, nil, 20)
	screenGroup:insert(text)
	
	newGame = display.newImage("Images/newgame.png", 20, 200)
	screenGroup:insert(newGame)
	newGame.touch = onNewGameTouch 
	
	loadGame = display.newText("Load Game (not ready)", 70, 300, nil, 20)
	screenGroup:insert(loadGame)
	
	exitGame = display.newText("Exit", 130, 400, nil, 20)
	screenGroup:insert(exitGame)
	exitGame.touch = onExitTouch
	
	print( "\n2: createScene event" )
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	local gameState = require("gamestate")
	-----------------------------------------------------------------------------
		
	--	INSERT code here (e.g. start timers, load audio, start listeners, etc.)
	
	-----------------------------------------------------------------------------
	
	newGame:addEventListener( "touch", newGame )
	exitGame:addEventListener( "touch", exitGame )
		
	storyboard.purgeScene("gameover")
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
	
	--	INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)
	
	-----------------------------------------------------------------------------
	
	background:removeEventListener( "touch", background )
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
	
	--	INSERT code here (e.g. remove listeners, widgets, save state, etc.)
	
	-----------------------------------------------------------------------------
	
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